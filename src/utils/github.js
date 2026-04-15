import { getMonthNameFromDate, getTodayDate, getYearFromDate } from "./date";

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

export async function pushToGitHub(token, repo, logs, commitDate = getTodayDate()) {
  const files = buildSyncFiles(logs);

  if (files.length === 0) {
    const error = new Error("No completed logs to sync.");
    error.status = 400;
    throw error;
  }

  const [owner, name] = repo.split("/");
  const response = await fetch(`/api/github/repos/${encodeURIComponent(owner)}/${encodeURIComponent(name)}/sync`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      files,
      commitDate,
    }),
  });

  if (!response.ok) {
    throw await createFrontendError(response);
  }

  return response.json();
}

export function getDailyFilePath(date) {
  return `${getYearFromDate(date)}/${getMonthNameFromDate(date)}/${date}.md`;
}

export function getMonthlySummaryPath(date) {
  return `${getYearFromDate(date)}/${getMonthNameFromDate(date)}/monthly-summary.md`;
}

export function getYearlySummaryPath(date) {
  const year = date.length === 4 ? date : getYearFromDate(date);
  return `${year}/yearly-summary.md`;
}

export function generateDailyMarkdown(date, log) {
  const oneLine = (log?.oneLine || "").trim();
  const journal = (log?.journal || log?.notes || "").trim();

  return `# ${date}

## One-Line Summary
${oneLine}

## Detailed Journal
${journal}
`;
}

export function generateMonthlySummaryMarkdown(year, month, logs) {
  const entries = Object.entries(logs || {})
    .filter(([date, log]) => getYearFromDate(date) === year && getMonthNameFromDate(date) === month && (log?.oneLine || "").trim())
    .sort(([left], [right]) => left.localeCompare(right));

  const lines = entries.map(([date, log]) => `- ${date} -> ${(log.oneLine || "").trim()}`);

  return `# ${month} ${year} Summary

${lines.join("\n")}
`;
}

export function generateYearlySummaryMarkdown(year, logs) {
  const entries = Object.entries(logs || {})
    .filter(([date, log]) => getYearFromDate(date) === year && (log?.oneLine || "").trim())
    .sort(([left], [right]) => left.localeCompare(right));

  const groupedByMonth = entries.reduce((result, [date, log]) => {
    const month = getMonthNameFromDate(date);

    if (!result[month]) {
      result[month] = [];
    }

    result[month].push(`- ${date} -> ${(log.oneLine || "").trim()}`);
    return result;
  }, {});

  const sections = Object.entries(groupedByMonth).map(([month, lines]) => `## ${month}
${lines.join("\n")}`);

  return `# ${year} Summary

${sections.join("\n\n")}
`;
}

function buildSyncFiles(logs) {
  const normalizedLogs = normalizeLogs(logs);
  const dates = Object.keys(normalizedLogs).sort((left, right) => left.localeCompare(right));
  const files = [];
  const monthKeys = new Set();
  const yearKeys = new Set();

  dates.forEach((date) => {
    const log = normalizedLogs[date];
    const oneLine = (log.oneLine || "").trim();
    const journal = (log.journal || "").trim();

    if (!oneLine && !journal) {
      return;
    }

    files.push({
      path: getDailyFilePath(date),
      content: generateDailyMarkdown(date, log),
    });
    monthKeys.add(`${getYearFromDate(date)}::${getMonthNameFromDate(date)}`);
    yearKeys.add(getYearFromDate(date));
  });

  monthKeys.forEach((monthKey) => {
    const [year, month] = monthKey.split("::");
    files.push({
      path: `${year}/${month}/monthly-summary.md`,
      content: generateMonthlySummaryMarkdown(year, month, normalizedLogs),
    });
  });

  yearKeys.forEach((year) => {
    files.push({
      path: getYearlySummaryPath(year),
      content: generateYearlySummaryMarkdown(year, normalizedLogs),
    });
  });

  return files;
}

function normalizeLogs(logs) {
  return Object.entries(logs || {}).reduce((result, [date, value]) => {
    result[date] = {
      oneLine: value?.oneLine || "",
      journal: value?.journal || value?.notes || "",
    };
    return result;
  }, {});
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
