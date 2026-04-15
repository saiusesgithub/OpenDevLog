const STORAGE_KEY = "open-dev-log";

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
