export default function LogList({ dates, selectedDate, onSelectDate }) {
  return (
    <aside className="rounded-3xl border border-slate-800 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/40">
      <div className="mb-4">
        <p className="text-sm uppercase tracking-[0.25em] text-slate-500">Previous Logs</p>
        <h2 className="mt-2 text-xl font-semibold text-white">Browse by date</h2>
      </div>

      <div className="space-y-2">
        {dates.length === 0 ? (
          <p className="rounded-2xl border border-dashed border-slate-700 px-4 py-6 text-sm text-slate-400">
            No logs available yet.
          </p>
        ) : (
          dates.map((date) => {
            const isActive = date === selectedDate;

            return (
              <button
                key={date}
                type="button"
                onClick={() => onSelectDate(date)}
                className={`flex w-full items-center justify-between rounded-2xl border px-4 py-3 text-left text-sm transition ${
                  isActive
                    ? "border-sky-500 bg-sky-500/10 text-sky-200"
                    : "border-slate-800 bg-slate-950/50 text-slate-300 hover:border-slate-700 hover:text-white"
                }`}
              >
                <span>{date}</span>
                <span className="text-xs uppercase tracking-[0.2em] text-slate-500">Open</span>
              </button>
            );
          })
        )}
      </div>
    </aside>
  );
}
