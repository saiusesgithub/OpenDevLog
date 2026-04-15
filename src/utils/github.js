import { getTodayDate } from "./date";

const FILE_PATH = "devlog.md";
const API_VERSION = "2022-11-28";

export function encodeToBase64(content) {
  const bytes = new TextEncoder().encode(content);
  let binary = "";

  bytes.forEach((byte) => {
    binary += String.fromCharCode(byte);
  });

  return btoa(binary);
}

export async function getFileSHA(token, repo) {
  const response = await fetch(`https://api.github.com/repos/${repo}/contents/${FILE_PATH}`, {
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: "application/vnd.github+json",
      "X-GitHub-Api-Version": API_VERSION,
    },
  });

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error(await getGitHubErrorMessage(response));
  }

  const data = await response.json();
  return data.sha || null;
}

export async function pushToGitHub(token, repo, logs) {
  const content = buildMarkdown(logs);

  if (!content) {
    throw new Error("No completed logs to sync.");
  }

  const sha = await getFileSHA(token, repo);
  const today = getTodayDate();
  const response = await fetch(`https://api.github.com/repos/${repo}/contents/${FILE_PATH}`, {
    method: "PUT",
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: "application/vnd.github+json",
      "Content-Type": "application/json",
      "X-GitHub-Api-Version": API_VERSION,
    },
    body: JSON.stringify({
      message: `Update dev log - ${today}`,
      content: encodeToBase64(content),
      ...(sha ? { sha } : {}),
    }),
  });

  if (!response.ok) {
    throw new Error(await getGitHubErrorMessage(response));
  }

  return {
    message: sha ? "Synced and updated devlog.md." : "Synced and created devlog.md.",
    syncedAt: new Date().toISOString(),
  };
}

function buildMarkdown(logs) {
  const entries = Object.entries(logs || {})
    .filter(([, log]) => (log?.oneLine || "").trim().length > 0)
    .sort(([left], [right]) => left.localeCompare(right));

  if (entries.length === 0) {
    return "";
  }

  const sections = entries.map(([date, log]) => {
    const lines = [`## ${date}`, `- ${log.oneLine.trim()}`];
    const notes = (log.notes || "").trim();

    if (notes) {
      lines.push(`- Notes: ${notes}`);
    }

    return lines.join("\n");
  });

  return `# OpenDevLog\n\n${sections.join("\n\n")}\n`;
}

async function getGitHubErrorMessage(response) {
  if (response.status === 401 || response.status === 403) {
    return "Invalid token or missing repo permission.";
  }

  if (response.status === 404) {
    return "Repo not found.";
  }

  try {
    const data = await response.json();
    return data.message || "GitHub API request failed.";
  } catch {
    return "GitHub API request failed.";
  }
}
