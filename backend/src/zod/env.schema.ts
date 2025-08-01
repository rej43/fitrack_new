import { z } from "zod";

const envVariables = z.object({
  MONGODB_URI: z.string(),
  PORT: z.string(),
  GOOGLE_CLIENT_ID: z.string(),
  GOOGLE_CLIENT_SECRET: z.string(),
  CLIENT_URL: z.string(),
  GOOGLE_CLIENT_REDIRECT: z.string(),
  JWT_SECRET: z.string(),
  SESSION_SECRET: z.string()
});

export const env = envVariables.parse(process.env);
