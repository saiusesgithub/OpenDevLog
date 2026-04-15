import { useEffect, useMemo, useState } from "react";
import DailyLog from "./components/DailyLog";
import ExportModal from "./components/ExportModal";
import GitHubSync from "./components/GitHubSync";
import LogList from "./components/LogList";
import StreakDisplay from "./components/StreakDisplay";
import { formatMonthHeading, getCurrentMonthLogs, getTodayDate } from "./utils/date";
import { getLogs, getLogByDate, updateLog } from "./utils/storage";
import { calculateCurrentStreak, calculateTotalDays } from "./utils/streak";

const EMPTY_LOG = { oneLine: "", notes: "" };

export default function App() {
  const today = getTodayDate();
  const [logs, setLogs] = useState(() => getLogs());
  const [selectedDate, setSelectedDate] = useState(today);
  const [draft, setDraft] = useState(() => getLogByDate(today) || EMPTY_LOG);
  const [isExportOpen, setIsExportOpen] = useState(false);
  const [exportData, setExportData] = useState({ title: "", content: "", message: "" });

  useEffect(() => {
    const existing = getLogByDate(today);

    if (!existing) {
      const nextLogs = updateLog(today, EMPTY_LOG);
      setLogs(nextLogs);
      setDraft(EMPTY_LOG);
      return;
    }

    setDraft(existing);
  }, [today]);

  useEffect(() => {
    const current = getLogByDate(selectedDate);

    if (!current) {
      const nextLogs = updateLog(selectedDate, EMPTY_LOG);
      setLogs(nextLogs);
      setDraft(EMPTY_LOG);
      return;
    }

    setDraft(current);
  }, [selectedDate]);

  useEffect(() => {
    if (!draft) {
      return undefined;
    }

    const timeoutId = window.setTimeout(() => {
      const nextLogs = updateLog(selectedDate, draft);
      setLogs(nextLogs);
    }, 200);

    return () => window.clearTimeout(timeoutId);
  }, [draft, selectedDate]);

  const sortedDates = useMemo(
    () => Object.keys(logs).sort((left, right) => right.localeCompare(left)),
    [logs]
  );
  const currentStreak = useMemo(() => calculateCurrentStreak(logs), [logs]);
  const totalDaysLogged = useMemo(() => calculateTotalDays(logs), [logs]);

  const handleFieldChange = (field, value) => {
    setDraft((current) => ({
      ...current,
      [field]: value,
    }));
  };

  const handleSelectDate = (date) => {
    setSelectedDate(date);
  };

  const handleExportMonth = () => {
    const monthLogs = getCurrentMonthLogs(logs, today);
    const lines = Object.entries(monthLogs)
      .map(([date, log]) => {
        const oneLine = (log?.oneLine || "").trim();

        if (!oneLine) {
          return null;
        }

        const day = Number(date.slice(-2));
        return `${day} -> ${oneLine}`;
      })
      .filter(Boolean);

    if (lines.length === 0) {
      setExportData({
        title: formatMonthHeading(today),
        content: "",
        message: "No completed logs found for this month.",
      });
      setIsExportOpen(true);
      return;
    }

    setExportData({
      title: formatMonthHeading(today),
      content: `${formatMonthHeading(today)}\n\n${lines.join("\n")}`,
      message: "",
    });
    setIsExportOpen(true);
  };

  return (
    <div className="min-h-screen px-4 py-8 text-slate-100">
      <div className="mx-auto flex w-full max-w-5xl flex-col gap-6">
        <header className="rounded-3xl border border-slate-800 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/40 backdrop-blur">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-sm uppercase tracking-[0.3em] text-sky-400">OpenDevLog</p>
              <h1 className="mt-2 text-3xl font-semibold text-white">Daily developer learning log</h1>
              <p className="mt-2 max-w-2xl text-sm text-slate-400">
                Open, type what you learned, close the tab. Everything is stored locally.
              </p>
            </div>
            <div className="flex gap-3">
              <button
                type="button"
                onClick={() => setSelectedDate(today)}
                className="rounded-xl border border-slate-700 bg-slate-800 px-4 py-2 text-sm font-medium text-slate-100 transition hover:border-sky-500 hover:text-sky-300"
              >
                Today
              </button>
              <button
                type="button"
                onClick={handleExportMonth}
                className="rounded-xl bg-sky-500 px-4 py-2 text-sm font-medium text-slate-950 transition hover:bg-sky-400"
              >
                Export Month
              </button>
            </div>
          </div>
        </header>

        <StreakDisplay logs={logs} currentStreak={currentStreak} totalDaysLogged={totalDaysLogged} />

        <main className="grid gap-6 lg:grid-cols-[280px_minmax(0,1fr)]">
          <LogList dates={sortedDates} selectedDate={selectedDate} onSelectDate={handleSelectDate} />
          <div className="space-y-6">
            <DailyLog
              date={selectedDate}
              oneLine={draft.oneLine}
              notes={draft.notes}
              onOneLineChange={(value) => handleFieldChange("oneLine", value)}
              onNotesChange={(value) => handleFieldChange("notes", value)}
            />
            <GitHubSync
              selectedDate={selectedDate}
              draft={draft}
              onPrepareSync={() => {
                const savedLogs = updateLog(selectedDate, draft);
                setLogs(savedLogs);
                return savedLogs;
              }}
            />
          </div>
        </main>
      </div>

      <ExportModal
        isOpen={isExportOpen}
        title={exportData.title}
        content={exportData.content}
        message={exportData.message}
        onClose={() => setIsExportOpen(false)}
      />
    </div>
  );
}
