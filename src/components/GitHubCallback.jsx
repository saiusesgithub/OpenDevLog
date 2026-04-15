import { useEffect, useState } from "react";
import { exchangeOAuthCode } from "../utils/github";
import { saveGitHubConfig } from "../utils/storage";

export default function GitHubCallback() {
  const [message, setMessage] = useState("Completing GitHub login...");

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const code = params.get("code");
    const error = params.get("error");

    if (error) {
      setMessage("GitHub login was cancelled. Return to the app and try again.");
      return;
    }

    if (!code) {
      setMessage("No GitHub authorization code was returned.");
      return;
    }

    async function completeLogin() {
      try {
        const data = await exchangeOAuthCode(code);
        saveGitHubConfig({
          token: data.access_token,
          repo: "",
        });
        window.location.replace("/");
      } catch (callbackError) {
        setMessage(callbackError.message || "GitHub login failed.");
      }
    }

    completeLogin();
  }, []);

  return (
    <div className="min-h-screen px-4 py-8 text-slate-100">
      <div className="mx-auto max-w-xl rounded-3xl border border-slate-800 bg-slate-900/80 p-8 shadow-2xl shadow-slate-950/40">
        <p className="text-sm uppercase tracking-[0.25em] text-slate-500">GitHub OAuth</p>
        <h1 className="mt-2 text-3xl font-semibold text-white">Connecting your account</h1>
        <p className="mt-4 text-sm text-slate-300">{message}</p>
      </div>
    </div>
  );
}
