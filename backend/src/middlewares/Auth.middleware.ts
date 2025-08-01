import type { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User, UserClass } from '../models/UserModel';
import { env } from '../zod/env.schema';
import { IJwtPayload } from '../types/jwt.types';
import { DocumentType } from '@typegoose/typegoose';

export const isAuthenticated = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const authHeader = req.header('Authorization');
    const token = authHeader?.split(' ')[1];

    if (!token) {
      res.status(401).json({ message: 'No token, authorization denied' });
      return;
    }

    if (!env.JWT_SECRET) {
      res.status(500).json({ message: 'Server configuration error' });
      return;
    }

    const decoded = jwt.verify(token, env.JWT_SECRET) as IJwtPayload;
    
    const user = await User.findById(decoded.userId).select('-password');
    if (!user) {
      res.status(401).json({ message: 'User not found' });
      return;
    }

    req.user = user as DocumentType<UserClass>;
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({ message: 'Invalid token' });
      return;
    }
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({ message: 'Token expired' });
      return;
    }
    res.status(500).json({ message: 'Server error' });
  }
}; 