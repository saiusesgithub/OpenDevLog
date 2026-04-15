import { getHeatmapDays } from "../utils/streak";

export default function StreakDisplay({ logs, currentStreak, totalDaysLogged }) {
  const heatmapDays = getHeatmapDays(logs);

  return (
    <section className="rounded-3xl border border-slate-800 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/40">
      <div className="grid gap-4 lg:grid-cols-[220px_220px_minmax(0,1fr)]">
        <div className="rounded-2xl border border-slate-800 bg-slate-950/60 p-4">
          <p className="text-sm uppercase tracking-[0.25em] text-slate-500">Current Streak</p>
          <p className="mt-3 text-3xl font-semibold text-white">{currentStreak} days</p>
        </div>
        <div className="rounded-2xl border border-slate-800 bg-slate-950/60 p-4">
          <p className="text-sm uppercase tracking-[0.25em] text-slate-500">Total Days Logged</p>
          <p className="mt-3 text-3xl font-semibold text-white">{totalDaysLogged}</p>
        </div>
        <div className="rounded-2xl border border-slate-800 bg-slate-950/60 p-4">
          <p className="text-sm uppercase tracking-[0.25em] text-slate-500">Activity</p>
          <div className="mt-3 grid grid-cols-14 gap-2">
            {heatmapDays.map((day) => (
              <div
                key={day.date}
                title={`${day.date}: ${day.active ? "logged" : "empty"}`}
                className={`h-4 w-4 rounded-sm border ${
                  day.active
                    ? "border-emerald-400/60 bg-emerald-400/80"
                    : "border-slate-800 bg-slate-800/80"
                }`}
              />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
