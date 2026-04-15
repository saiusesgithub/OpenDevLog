export default function DailyLog({ date, oneLine, notes, onOneLineChange, onNotesChange }) {
  const isValid = oneLine.trim().length > 0;

  return (
    <section className="rounded-3xl border border-slate-800 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/40">
      <div className="mb-6 flex items-center justify-between gap-4">
        <div>
          <p className="text-sm uppercase tracking-[0.25em] text-slate-500">Entry</p>
          <h2 className="mt-2 text-2xl font-semibold text-white">{date}</h2>
        </div>
        <span
          className={`rounded-full px-3 py-1 text-xs font-medium ${
            isValid ? "bg-emerald-500/15 text-emerald-300" : "bg-amber-500/15 text-amber-300"
          }`}
        >
          {isValid ? "Saved" : "One-line summary required"}
        </span>
      </div>

      <div className="space-y-5">
        <label className="block">
          <span className="mb-2 block text-sm font-medium text-slate-200">What did you learn today?</span>
          <input
            type="text"
            value={oneLine}
            onChange={(event) => onOneLineChange(event.target.value)}
            placeholder="Learned React basics"
            className="w-full rounded-2xl border border-slate-700 bg-slate-950/80 px-4 py-3 text-slate-100 outline-none transition placeholder:text-slate-500 focus:border-sky-500"
          />
        </label>

        <label className="block">
          <span className="mb-2 block text-sm font-medium text-slate-200">Notes</span>
          <textarea
            value={notes}
            onChange={(event) => onNotesChange(event.target.value)}
            placeholder="Studied hooks, component structure, and when to lift state."
            rows="10"
            className="min-h-52 w-full resize-y rounded-2xl border border-slate-700 bg-slate-950/80 px-4 py-3 text-slate-100 outline-none transition placeholder:text-slate-500 focus:border-sky-500"
          />
        </label>
      </div>
    </section>
  );
}
