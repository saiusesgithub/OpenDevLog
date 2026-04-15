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

router.put("/api/github/repos/:owner/:repo/contents/devlog.md", async (request, response) => {
  const token = readBearerToken(request);
  const owner = request.params.owner;
  const repo = request.params.repo;
  const content = request.body.content || "";

  if (!token) {
    response.status(401).json({ message: "Missing GitHub access token." });
    return;
  }

  if (!content.trim()) {
    response.status(400).json({ message: "No completed logs to sync." });
    return;
  }

  try {
    const sha = await getFileSHA(token, owner, repo);
    const today = new Date().toISOString().slice(0, 10);

    await axios.put(
      `https://api.github.com/repos/${owner}/${repo}/contents/devlog.md`,
      {
        message: `Update dev log - ${today}`,
        content: Buffer.from(content, "utf-8").toString("base64"),
        ...(sha ? { sha } : {}),
      },
      {
        headers: buildGitHubHeaders(token),
      }
    );

    response.json({
      message: sha ? "Synced and updated devlog.md." : "Synced and created devlog.md.",
      syncedAt: new Date().toISOString(),
    });
  } catch (error) {
    sendGitHubError(response, error, "Failed to sync devlog.md.");
  }
});

async function getFileSHA(token, owner, repo) {
  try {
    const fileResponse = await axios.get(`https://api.github.com/repos/${owner}/${repo}/contents/devlog.md`, {
      headers: buildGitHubHeaders(token),
    });

    return fileResponse.data.sha || null;
  } catch (error) {
    if (error.response?.status === 404) {
      return null;
    }

    throw error;
  }
}

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
