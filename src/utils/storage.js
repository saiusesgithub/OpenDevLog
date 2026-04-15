const STORAGE_KEY = "open-dev-log";
const GITHUB_KEY = "open-dev-log-github";
const GITHUB_SYNC_RESULT_KEY = "open-dev-log-github-sync-result";

function isStorageAvailable() {
  try {
    return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
  } catch {
    return false;
  }
}

export function getLogs() {
  if (!isStorageAvailable()) {
    return {};
  }

  try {
    const rawValue = window.localStorage.getItem(STORAGE_KEY);

    if (!rawValue) {
      return {};
    }

    const parsedValue = JSON.parse(rawValue);
    return parsedValue?.logs && typeof parsedValue.logs === "object" ? parsedValue.logs : {};
  } catch {
    return {};
  }
}

export function saveLogs(logs) {
  if (!isStorageAvailable()) {
    return logs;
  }

  const safeLogs = logs && typeof logs === "object" ? logs : {};

  try {
    window.localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        logs: safeLogs,
      })
    );
  } catch {
    return safeLogs;
  }

  return safeLogs;
}

export function getLogByDate(date) {
  const logs = getLogs();
  return logs[date] || null;
}

export function updateLog(date, data) {
  const logs = getLogs();
  const nextLogs = {
    ...logs,
    [date]: {
      oneLine: data?.oneLine || "",
      notes: data?.notes || "",
    },
  };

  return saveLogs(nextLogs);
}

export function getGitHubConfig() {
  if (!isStorageAvailable()) {
    return { token: "", repo: "" };
  }

  try {
    const rawValue = window.localStorage.getItem(GITHUB_KEY);

    if (!rawValue) {
      return { token: "", repo: "" };
    }

    const parsedValue = JSON.parse(rawValue);
    return {
      token: parsedValue?.token || "",
      repo: parsedValue?.repo || "",
    };
  } catch {
    return { token: "", repo: "" };
  }
}

export function saveGitHubConfig(config) {
  if (!isStorageAvailable()) {
    return config;
  }

  const safeConfig = {
    token: config?.token || "",
    repo: config?.repo || "",
  };

  try {
    window.localStorage.setItem(GITHUB_KEY, JSON.stringify(safeConfig));
  } catch {
    return safeConfig;
  }

  return safeConfig;
}

export function getLastGitHubSyncResult() {
  if (!isStorageAvailable()) {
    return null;
  }

  try {
    const rawValue = window.localStorage.getItem(GITHUB_SYNC_RESULT_KEY);

    if (!rawValue) {
      return null;
    }

    return JSON.parse(rawValue);
  } catch {
    return null;
  }
}

export function saveLastGitHubSyncResult(result) {
  if (!isStorageAvailable()) {
    return result;
  }

  const safeResult = {
    status: result?.status || "",
    message: result?.message || "",
    syncedAt: result?.syncedAt || "",
  };

  try {
    window.localStorage.setItem(GITHUB_SYNC_RESULT_KEY, JSON.stringify(safeResult));
  } catch {
    return safeResult;
  }

  return safeResult;
}
