export function getTodayDate() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
}

export function getYearFromDate(date) {
  return date.slice(0, 4);
}

export function getMonthNameFromDate(date) {
  const [year, month] = date.split("-");
  return new Date(Number(year), Number(month) - 1, 1).toLocaleString("en-US", {
    month: "long",
  });
}

export function getCurrentMonthLogs(logs, currentDate = getTodayDate()) {
  const prefix = currentDate.slice(0, 7);

  return Object.entries(logs || {})
    .filter(([date]) => date.startsWith(prefix))
    .sort(([left], [right]) => left.localeCompare(right))
    .reduce((result, [date, value]) => {
      result[date] = value;
      return result;
    }, {});
}

export function isSameMonth(date, currentDate = getTodayDate()) {
  return date.slice(0, 7) === currentDate.slice(0, 7);
}

export function formatMonthHeading(date) {
  const [year, month] = date.split("-");
  const label = new Date(Number(year), Number(month) - 1, 1).toLocaleString("en-US", {
    month: "long",
    year: "numeric",
  });

  return label;
}
