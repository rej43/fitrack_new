import mongoose from "mongoose";
import dotenv from "dotenv";
import { env } from "../zod/env.schema";
dotenv.config();

export async function connectDB(): Promise<void> {
  const uri = env.MONGODB_URI;

  if (!uri) {
    throw new Error("MONGODB_URI is not defined in environment variables.");
  }

  try {
    await mongoose.connect(uri);
    console.log("MongoDB connected successfully");
  } catch (error) {
    console.error("Error connecting to MongoDB:", error);
    throw error;
  }
}
