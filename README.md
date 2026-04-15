# OpenDevLog

## GitHub Sync

1. Run the app with `npm install` and `npm run dev`.
2. Create a GitHub Personal Access Token.
3. Open the app and fill in the `GitHub Sync` section.
4. Enter your token and repo as `username/repository`.
5. Click `Sync Now`.

The app writes one file named `devlog.md` and makes only one commit per manual sync.

### PAT permissions

Use a token with `repo` permission.

### How to create a GitHub Personal Access Token

1. Open GitHub.
2. Go to `Settings`.
3. Open `Developer settings`.
4. Open `Personal access tokens`.
5. Choose `Tokens (classic)` or a fine-grained token.
6. Create a new token.
7. Grant `repo` access or repository contents write access.
8. Copy the token and paste it into the app.

The token is stored only in your browser localStorage.
