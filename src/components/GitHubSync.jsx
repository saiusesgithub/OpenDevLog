import { useEffect, useState } from "react";
import {
  clearGitHubConfig,
  getGitHubConfig,
  getLastGitHubSyncResult,
  saveGitHubConfig,
  saveLastGitHubSyncResult,
} from "../utils/storage";
import { createRepository, fetchUserRepos, pushToGitHub } from "../utils/github";

export default function GitHubSync({ onPrepareSync }) {
  const [token, setToken] = useState("");
  const [repo, setRepo] = useState("");
  const [repos, setRepos] = useState([]);
  const [newRepoName, setNewRepoName] = useState("opendevlog");
  const [isLoading, setIsLoading] = useState(false);
  const [isRepoLoading, setIsRepoLoading] = useState(false);
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

  useEffect(() => {
    if (!token) {
      setRepos([]);
      return;
    }

    async function loadRepos() {
      setIsRepoLoading(true);
      setError("");

      try {
        const nextRepos = await fetchUserRepos(token);
        setRepos(nextRepos);
      } catch (repoError) {
        if (repoError.status === 401) {
          handleLogout("GitHub session expired. Connect again.");
          return;
        }

        setError(repoError.message || "Failed to load repositories.");
      } finally {
        setIsRepoLoading(false);
      }
    }

    loadRepos();
  }, [token]);

  const handleConnect = () => {
    window.location.href = "/auth/github";
  };

  const handleLogout = (message = "") => {
    clearGitHubConfig();
    setToken("");
    setRepo("");
    setRepos([]);
    setStatus("");
    setError(message);
  };

  const handleCreateRepo = async () => {
    const trimmedName = newRepoName.trim();

    setError("");
    setStatus("");

    if (!trimmedName) {
      setError("Enter a repository name first.");
      return;
    }

    setIsLoading(true);

    try {
      const createdRepo = await createRepository(token, trimmedName);
      const nextRepo = createdRepo.full_name;
      const nextRepos = [createdRepo, ...repos.filter((item) => item.full_name !== nextRepo)];

      setRepos(nextRepos);
      setRepo(nextRepo);
      saveGitHubConfig({ token, repo: nextRepo });
      setStatus(`Created and selected ${nextRepo}.`);
    } catch (repoError) {
      if (repoError.status === 401) {
        handleLogout("GitHub session expired. Connect again.");
        return;
      }

      setError(repoError.message || "Failed to create repository.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleRepoChange = (value) => {
    setRepo(value);
    saveGitHubConfig({ token, repo: value });
  };

  const handleSync = async () => {
    setError("");
    setStatus("");

    if (!token) {
      setError("Connect GitHub first.");
      return;
    }

    if (!repo.trim()) {
      setError("Select or create a repository first.");
      return;
    }

    setIsLoading(true);

    try {
      const logs = onPrepareSync();
      const result = await pushToGitHub(token, repo, logs);
      const nextResult = saveLastGitHubSyncResult({
        status: "success",
        message: result.message,
        syncedAt: result.syncedAt,
      });

      setStatus(result.message);
      setLastResult(nextResult);
    } catch (syncError) {
      if (syncError.status === 401) {
        handleLogout("GitHub session expired. Connect again.");
        return;
      }

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

  const isSyncDisabled = !token || !repo.trim() || isLoading;

  return (
    <section className="rounded-3xl border border-slate-800 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/40">
      <div className="mb-5">
        <p className="text-sm uppercase tracking-[0.25em] text-slate-500">GitHub Sync</p>
        <h2 className="mt-2 text-xl font-semibold text-white">GitHub OAuth sync</h2>
        <p className="mt-2 text-sm text-slate-400">
          Connect once, pick a repository, and push one clean `devlog.md` commit when you want.
        </p>
      </div>

      <div className="space-y-4">
        {!token ? (
          <button
            type="button"
            onClick={handleConnect}
            className="rounded-xl bg-sky-500 px-4 py-3 text-sm font-medium text-slate-950 transition hover:bg-sky-400"
          >
            Connect GitHub
          </button>
        ) : (
          <>
            <div className="flex flex-col gap-3 rounded-2xl border border-slate-800 bg-slate-950/70 p-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p className="text-sm font-medium text-slate-200">GitHub connected</p>
                <p className="mt-1 text-xs text-slate-500">OAuth token is stored locally so you stay logged in.</p>
              </div>
              <button
                type="button"
                onClick={() => handleLogout()}
                className="rounded-xl border border-slate-700 px-4 py-2 text-sm text-slate-300 transition hover:border-slate-500 hover:text-white"
              >
                Logout
              </button>
            </div>

            <div className="rounded-2xl border border-slate-800 bg-slate-950/70 p-4">
              <p className="text-sm font-medium text-slate-200">Create new repo</p>
              <div className="mt-3 flex flex-col gap-3 sm:flex-row">
                <input
                  type="text"
                  value={newRepoName}
                  onChange={(event) => setNewRepoName(event.target.value)}
                  placeholder="opendevlog"
                  className="w-full rounded-2xl border border-slate-700 bg-slate-950/80 px-4 py-3 text-slate-100 outline-none transition placeholder:text-slate-500 focus:border-sky-500"
                />
                <button
                  type="button"
                  onClick={handleCreateRepo}
                  disabled={isLoading}
                  className="rounded-xl border border-sky-500 px-4 py-3 text-sm font-medium text-sky-300 transition hover:bg-sky-500/10 disabled:cursor-not-allowed disabled:border-slate-700 disabled:text-slate-500"
                >
                  Create New Repo
                </button>
              </div>
            </div>

            <label className="block">
              <span className="mb-2 block text-sm font-medium text-slate-200">Select existing repo</span>
              <select
                value={repo}
                onChange={(event) => handleRepoChange(event.target.value)}
                className="w-full rounded-2xl border border-slate-700 bg-slate-950/80 px-4 py-3 text-slate-100 outline-none transition focus:border-sky-500"
              >
                <option value="">Choose a repository</option>
                {repos.map((item) => (
                  <option key={item.id || item.full_name} value={item.full_name}>
                    {item.full_name}
                  </option>
                ))}
              </select>
              <p className="mt-2 text-xs text-slate-500">
                {isRepoLoading ? "Loading repositories..." : `${repos.length} repositories available.`}
              </p>
            </label>
          </>
        )}

        <button
          type="button"
          onClick={handleSync}
          disabled={isSyncDisabled}
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
          <p className="font-medium text-slate-200">OAuth setup</p>
          <p className="mt-2">Create a GitHub OAuth App and set the callback URL to http://localhost:5173/callback.</p>
          <p className="mt-1">The backend exchanges the code for an access token. The client secret never reaches the frontend.</p>
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
