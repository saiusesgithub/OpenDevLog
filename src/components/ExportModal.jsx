export default function ExportModal({ isOpen, title, content, message, onClose }) {
  if (!isOpen) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/80 px-4">
      <div className="w-full max-w-2xl rounded-3xl border border-slate-800 bg-slate-900 p-6 shadow-2xl shadow-slate-950/50">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-sm uppercase tracking-[0.25em] text-slate-500">Monthly Export</p>
            <h3 className="mt-2 text-2xl font-semibold text-white">{title}</h3>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-xl border border-slate-700 px-3 py-2 text-sm text-slate-300 transition hover:border-slate-500 hover:text-white"
          >
            Close
          </button>
        </div>

        {message ? (
          <p className="mt-6 rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-6 text-sm text-slate-300">
            {message}
          </p>
        ) : (
          <textarea
            readOnly
            value={content}
            rows="14"
            className="mt-6 w-full rounded-2xl border border-slate-800 bg-slate-950/80 px-4 py-3 text-sm text-slate-100 outline-none"
          />
        )}
      </div>
    </div>
  );
}
