FROM node:22-bullseye

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY backend/package.json backend/package-lock.json ./backend/
RUN npm --prefix backend install

COPY . .

EXPOSE 3001
EXPOSE 5173

CMD ["sh", "-lc", "npm --prefix backend run dev & sleep 2 && npm run dev -- --host 0.0.0.0"]
