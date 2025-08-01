import "reflect-metadata";
import dotenv from "dotenv";
dotenv.config();

import express, { urlencoded } from "express";
import type { Response } from "express";
import router from "./routes";
import cors from "cors";
import cookieParser from "cookie-parser";
import morgan from "morgan";
import { connectDB } from "./config/db";
import { env } from "./zod/env.schema";
import { limiter } from "./middlewares/RateLimiter";
import session from 'express-session';
import sessionConfigs from "./config/sessionConfig";
import passport from "passport";

// Import Google Auth configuration
import "./config/googleAuth.config";

const app = express();
const port = env.PORT;

app.use(
  cors({
    origin: ["http://localhost:8080", env.CLIENT_URL],
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  })
);

app.use(express.json());
app.use(urlencoded({ extended: true }));
app.use(cookieParser());
app.use(session(sessionConfigs));
app.use(passport.initialize());
app.use(passport.session());
app.use(morgan("dev"));
app.use(limiter);

app.use("/api/v1",router);

app.get("/stats", (_, res: Response) => {
  res.json({
    message: "Server Up",
  });
});

const startServer = async () => {
  try {
    connectDB();
    app.listen(port, () => {
      console.log(`Server is running on http://localhost:${port}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
