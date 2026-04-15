import dotenv from "dotenv";
import express from "express";
import githubRoutes from "./routes/github.js";

dotenv.config();

const app = express();
const port = Number(process.env.PORT) || 3001;

app.use(express.json());
app.use(githubRoutes);

app.listen(port, () => {
  console.log(`OpenDevLog backend listening on http://localhost:${port}`);
});
