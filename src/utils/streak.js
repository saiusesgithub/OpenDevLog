import { getTodayDate } from "./date";

export function calculateCurrentStreak(logs) {
  let streak = 0;
  let currentDate = getTodayDate();

  while ((logs?.[currentDate]?.oneLine || "").trim().length > 0) {
    streak += 1;
    currentDate = shiftDate(currentDate, -1);
  }

  return streak;
}

export function calculateTotalDays(logs) {
  return Object.values(logs || {}).filter((log) => (log?.oneLine || "").trim().length > 0).length;
}

export function getHeatmapDays(logs, days = 56) {
  const result = [];
  let cursor = shiftDate(getTodayDate(), -(days - 1));

  for (let index = 0; index < days; index += 1) {
    result.push({
      date: cursor,
      active: (logs?.[cursor]?.oneLine || "").trim().length > 0,
    });

    cursor = shiftDate(cursor, 1);
  }

  return result;
}

function shiftDate(dateString, amount) {
  const date = new Date(`${dateString}T00:00:00`);
  date.setDate(date.getDate() + amount);

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
}
