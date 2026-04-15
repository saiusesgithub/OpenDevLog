# OpenDevLog

## GitHub OAuth Setup

### 1. Create a GitHub OAuth App

1. Open GitHub and go to `Settings`.
2. Open `Developer settings`.
3. Open `OAuth Apps`.
4. Click `New OAuth App`.
5. Set the application name to `OpenDevLog`.
6. Set the homepage URL to `http://localhost:5173`.
7. Set the authorization callback URL to `http://localhost:5173/callback`.
8. Create the app and copy the client ID and client secret.

### 2. Configure the backend

Create `backend/.env` with:

```env
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret
REDIRECT_URI=http://localhost:5173/callback
PORT=3001
```

### 3. Install and run locally

1. In the project root run `npm install`.
2. In `backend/` run `npm install`.
3. In one terminal run `npm run dev`.
4. In another terminal run `npm run dev:backend`.

### 4. Run with Docker

Build the image:

```bash
docker build -t opendevlog .
```

Run both frontend and backend in one container:

```bash
docker run --rm -it -p 5173:5173 -p 3001:3001 -e GITHUB_CLIENT_ID=your_client_id -e GITHUB_CLIENT_SECRET=your_client_secret -e REDIRECT_URI=http://localhost:5173/callback -e PORT=3001 opendevlog
```

### 5. Use GitHub sync

1. Click `Connect GitHub`.
2. Approve the OAuth app.
3. Return to the app.
4. Create a new repo named `opendevlog` or select an existing repo.
5. Click `Sync Now`.

The app writes one file named `devlog.md` and makes only one commit per manual sync.
