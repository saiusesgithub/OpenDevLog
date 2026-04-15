import { useEffect, useState } from "react";
import {
  getGitHubConfig,
  getLastGitHubSyncResult,
  saveGitHubConfig,
  saveLastGitHubSyncResult,
} from "../utils/storage";
import { pushToGitHub } from "../utils/github";

export default function GitHubSync({ onPrepareSync }) {
  const [token, setToken] = useState("");
  const [repo, setRepo] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [status, setStatus] = useState("");
  const [lastResult, setLastResult] = useState(null);

  useEffect(() => {
    const config = getGitHubConfig();
    const previousResult = getLastGitHubSyncResult();

    setToken(config.token || "");
    setRepo(config.repo || "");
    setLastResult(previousResult);
  }, []);

  const handleSync = async () => {
    const trimmedToken = token.trim();
    const trimmedRepo = repo.trim();

    setError("");
    setStatus("");

    if (!trimmedToken || !trimmedRepo) {
      setError("Enter a GitHub token and repo first.");
      return;
    }

    setIsLoading(true);

    try {
      saveGitHubConfig({ token: trimmedToken, repo: trimmedRepo });
      const logs = onPrepareSync();
      const result = await pushToGitHub(trimmedToken, trimmedRepo, logs);
      const nextResult = saveLastGitHubSyncResult({
        status: "success",
        message: result.message,
        syncedAt: result.syncedAt,
      });

      setStatus(result.message);
      setLastResult(nextResult);
    } catch (syncError) {
      const nextResult = saveLastGitHubSyncResult({
        status: "error",
        message: syncError.message || "GitHub sync failed.",
        syncedAt: new Date().toISOString(),
      });

      setError(syncError.message || "GitHub sync failed.");
      setLastResult(nextResult);
    } finally {
      setIsLoading(false);
    }
  };

  const isDisabled = !token.trim() || !repo.trim() || isLoading;

  return (
    <section className="rounded-3xl border border-slate-800 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/40">
      <div className="mb-5">
        <p className="text-sm uppercase tracking-[0.25em] text-slate-500">GitHub Sync</p>
        <h2 className="mt-2 text-xl font-semibold text-white">Manual backup to GitHub</h2>
        <p className="mt-2 text-sm text-slate-400">
          Paste a personal access token, set a repo, and push one clean `devlog.md` commit when you want.
        </p>
      </div>

      <div className="space-y-4">
        <label className="block">
          <span className="mb-2 block text-sm font-medium text-slate-200">GitHub Personal Access Token</span>
          <input
            type="password"
            value={token}
            onChange={(event) => setToken(event.target.value)}
            placeholder="ghp_..."
            className="w-full rounded-2xl border border-slate-700 bg-slate-950/80 px-4 py-3 text-slate-100 outline-none transition placeholder:text-slate-500 focus:border-sky-500"
          />
        </label>

        <label className="block">
          <span className="mb-2 block text-sm font-medium text-slate-200">Repo name</span>
          <input
            type="text"
            value={repo}
            onChange={(event) => setRepo(event.target.value)}
            placeholder="username/opendevlog"
            className="w-full rounded-2xl border border-slate-700 bg-slate-950/80 px-4 py-3 text-slate-100 outline-none transition placeholder:text-slate-500 focus:border-sky-500"
          />
        </label>

        <button
          type="button"
          onClick={handleSync}
          disabled={isDisabled}
          className="rounded-xl bg-sky-500 px-4 py-3 text-sm font-medium text-slate-950 transition hover:bg-sky-400 disabled:cursor-not-allowed disabled:bg-slate-700 disabled:text-slate-400"
        >
          {isLoading ? "Syncing..." : "Sync Now"}
        </button>

        {status ? <p className="text-sm text-emerald-300">{status}</p> : null}
        {error ? <p className="text-sm text-rose-300">{error}</p> : null}

        <div className="rounded-2xl border border-slate-800 bg-slate-950/70 p-4">
          <p className="text-sm font-medium text-slate-200">Last sync result</p>
          {lastResult ? (
            <>
              <p
                className={`mt-2 text-sm ${
                  lastResult.status === "success" ? "text-emerald-300" : "text-rose-300"
                }`}
              >
                {lastResult.message}
              </p>
              <p className="mt-1 text-xs text-slate-500">{formatSyncTime(lastResult.syncedAt)}</p>
            </>
          ) : (
            <p className="mt-2 text-sm text-slate-400">No sync has been run yet.</p>
          )}
        </div>

        <div className="rounded-2xl border border-slate-800 bg-slate-950/70 p-4 text-sm text-slate-400">
          <p className="font-medium text-slate-200">PAT setup</p>
          <p className="mt-2">GitHub Settings -&gt; Developer settings -&gt; Personal access tokens -&gt; generate a token.</p>
          <p className="mt-1">Required permission: repo.</p>
        </div>
      </div>
    </section>
  );
}

function formatSyncTime(value) {
  if (!value) {
    return "No timestamp available.";
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "No timestamp available.";
  }

  return `Last attempt: ${date.toLocaleString()}`;
}
