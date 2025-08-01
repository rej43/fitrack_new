import jwt from 'jsonwebtoken';
import { env } from '../zod/env.schema';

export const generateToken = (userId: string) => {
  if(!env.JWT_SECRET){
    throw new Error("JWT Secret is not defined");
  }

  return jwt.sign(userId, env.JWT_SECRET, {
    expiresIn: "7d", 
  });
}