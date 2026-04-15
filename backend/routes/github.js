import axios from "axios";
import express from "express";

const router = express.Router();
const GITHUB_API_VERSION = "2022-11-28";

router.get("/auth/github", (request, response) => {
  const clientId = process.env.GITHUB_CLIENT_ID;
  const redirectUri = process.env.REDIRECT_URI;

  if (!clientId || !redirectUri) {
    response.status(500).json({ message: "GitHub OAuth environment variables are missing." });
    return;
  }

  const authUrl = new URL("https://github.com/login/oauth/authorize");
  authUrl.searchParams.set("client_id", clientId);
  authUrl.searchParams.set("redirect_uri", redirectUri);
  authUrl.searchParams.set("scope", "repo");

  response.redirect(authUrl.toString());
});

router.get("/auth/github/callback", async (request, response) => {
  const code = request.query.code;

  if (!code) {
    response.status(400).json({ message: "Missing GitHub OAuth code." });
    return;
  }

  try {
    const tokenResponse = await axios.post(
      "https://github.com/login/oauth/access_token",
      {
        client_id: process.env.GITHUB_CLIENT_ID,
        client_secret: process.env.GITHUB_CLIENT_SECRET,
        code,
      },
      {
        headers: {
          Accept: "application/json",
        },
      }
    );

    if (!tokenResponse.data.access_token) {
      response.status(400).json({
        message: tokenResponse.data.error_description || "GitHub OAuth token exchange failed.",
      });
      return;
    }

    response.json({
      access_token: tokenResponse.data.access_token,
    });
  } catch (error) {
    response.status(500).json({
      message: getGitHubProxyError(error, "GitHub OAuth token exchange failed."),
    });
  }
});

router.get("/api/github/user/repos", async (request, response) => {
  const token = readBearerToken(request);

  if (!token) {
    response.status(401).json({ message: "Missing GitHub access token." });
    return;
  }

  try {
    const repoResponse = await axios.get("https://api.github.com/user/repos?sort=updated&per_page=100", {
      headers: buildGitHubHeaders(token),
    });

    response.json(
      repoResponse.data.map((repo) => ({
        id: repo.id,
        name: repo.name,
        full_name: repo.full_name,
        private: repo.private,
      }))
    );
  } catch (error) {
    sendGitHubError(response, error, "Failed to load repositories.");
  }
});

router.post("/api/github/user/repos", async (request, response) => {
  const token = readBearerToken(request);

  if (!token) {
    response.status(401).json({ message: "Missing GitHub access token." });
    return;
  }

  try {
    const repoResponse = await axios.post(
      "https://api.github.com/user/repos",
      {
        name: request.body.name,
        private: Boolean(request.body.private),
      },
      {
        headers: buildGitHubHeaders(token),
      }
    );

    response.status(201).json({
      name: repoResponse.data.name,
      full_name: repoResponse.data.full_name,
      private: repoResponse.data.private,
    });
  } catch (error) {
    sendGitHubError(response, error, "Failed to create repository.");
  }
});

router.post("/api/github/repos/:owner/:repo/sync", async (request, response) => {
  const token = readBearerToken(request);
  const owner = request.params.owner;
  const repo = request.params.repo;
  const files = Array.isArray(request.body.files) ? request.body.files : [];
  const commitDate = request.body.commitDate || new Date().toISOString().slice(0, 10);

  if (!token) {
    response.status(401).json({ message: "Missing GitHub access token." });
    return;
  }

  if (files.length === 0) {
    response.status(400).json({ message: "No completed logs to sync." });
    return;
  }

  try {
    const repoResponse = await axios.get(`https://api.github.com/repos/${owner}/${repo}`, {
      headers: buildGitHubHeaders(token),
    });
    const defaultBranch = repoResponse.data.default_branch;
    const refResponse = await axios.get(`https://api.github.com/repos/${owner}/${repo}/git/ref/heads/${defaultBranch}`, {
      headers: buildGitHubHeaders(token),
    });
    const latestCommitSha = refResponse.data.object.sha;
    const commitResponse = await axios.get(`https://api.github.com/repos/${owner}/${repo}/git/commits/${latestCommitSha}`, {
      headers: buildGitHubHeaders(token),
    });
    const baseTreeSha = commitResponse.data.tree.sha;
    const treeResponse = await axios.get(`https://api.github.com/repos/${owner}/${repo}/git/trees/${baseTreeSha}?recursive=1`, {
      headers: buildGitHubHeaders(token),
    });
    const existingFiles = new Map(treeResponse.data.tree.map((item) => [item.path, item.sha]));
    const treeEntries = [];

    for (const file of files) {
      if (!file.path || typeof file.content !== "string") {
        continue;
      }

      const blobResponse = await axios.post(
        `https://api.github.com/repos/${owner}/${repo}/git/blobs`,
        {
          content: file.content,
          encoding: "utf-8",
        },
        {
          headers: buildGitHubHeaders(token),
        }
      );

      treeEntries.push({
        path: file.path,
        mode: "100644",
        type: "blob",
        sha: blobResponse.data.sha,
        previousSha: existingFiles.get(file.path) || null,
      });
    }

    const newTreeResponse = await axios.post(
      `https://api.github.com/repos/${owner}/${repo}/git/trees`,
      {
        base_tree: baseTreeSha,
        tree: treeEntries.map(({ path, mode, type, sha }) => ({
          path,
          mode,
          type,
          sha,
        })),
      },
      {
        headers: buildGitHubHeaders(token),
      }
    );

    const newCommitResponse = await axios.post(
      `https://api.github.com/repos/${owner}/${repo}/git/commits`,
      {
        message: `Update OpenDevLog entries - ${commitDate}`,
        tree: newTreeResponse.data.sha,
        parents: [latestCommitSha],
      },
      {
        headers: buildGitHubHeaders(token),
      }
    );

    await axios.patch(
      `https://api.github.com/repos/${owner}/${repo}/git/refs/heads/${defaultBranch}`,
      {
        sha: newCommitResponse.data.sha,
        force: false,
      },
      {
        headers: buildGitHubHeaders(token),
      }
    );

    response.json({
      message: `Synced ${treeEntries.length} OpenDevLog files.`,
      syncedAt: new Date().toISOString(),
    });
  } catch (error) {
    sendGitHubError(response, error, "Failed to sync OpenDevLog entries.");
  }
});

function buildGitHubHeaders(token) {
  return {
    Authorization: `Bearer ${token}`,
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": GITHUB_API_VERSION,
  };
}

function readBearerToken(request) {
  const authHeader = request.headers.authorization || "";

  if (!authHeader.startsWith("Bearer ")) {
    return "";
  }

  return authHeader.slice("Bearer ".length).trim();
}

function sendGitHubError(response, error, fallbackMessage) {
  const status = error.response?.status || 500;
  response.status(status).json({
    message: getGitHubProxyError(error, fallbackMessage),
  });
}

function getGitHubProxyError(error, fallbackMessage) {
  return error.response?.data?.message || error.response?.data?.error_description || fallbackMessage;
}

export default router;
