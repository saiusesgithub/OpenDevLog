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

export async function exchangeOAuthCode(code) {
  const response = await fetch(`/auth/github/callback?code=${encodeURIComponent(code)}`);

  if (!response.ok) {
    throw await createFrontendError(response);
  }

  return response.json();
}

export async function fetchUserRepos(token) {
  const response = await fetch("/api/github/user/repos", {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw await createFrontendError(response);
  }

  return response.json();
}

export async function createRepository(token, name) {
  const response = await fetch("/api/github/user/repos", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      name,
      private: false,
    }),
  });

  if (!response.ok) {
    throw await createFrontendError(response);
  }

  return response.json();
}

export async function pushToGitHub(token, repo, logs) {
  const content = buildMarkdown(logs);

  if (!content) {
    const error = new Error("No completed logs to sync.");
    error.status = 400;
    throw error;
  }

  const [owner, name] = repo.split("/");
  const response = await fetch(`/api/github/repos/${encodeURIComponent(owner)}/${encodeURIComponent(name)}/contents/devlog.md`, {
    method: "PUT",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      content,
    }),
  });

  if (!response.ok) {
    throw await createFrontendError(response);
  }

  return response.json();
}

async function createFrontendError(response) {
  let message = "GitHub request failed.";

  try {
    const data = await response.json();
    message = data.message || message;
  } catch {
    message = "GitHub request failed.";
  }

  const error = new Error(message);
  error.status = response.status;
  return error;
}
