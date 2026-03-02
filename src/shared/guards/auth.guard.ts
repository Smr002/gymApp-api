import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from '@config/env';
import { AppError } from '@shared/errors/AppError';
import { StatusCodes } from 'http-status-codes';

export type UserRole = 'SUPER_ADMIN' | 'TRAINER' | 'CLIENT' | 'SELLER';

export interface JwtPayload {
  userId: string;
  role:   UserRole;
  email:  string;
}

declare global {
  namespace Express {
    interface Request { user?: JwtPayload; }
  }
}

export const authenticate = (req: Request, _res: Response, next: NextFunction): void => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer '))
    throw new AppError('Authorization header missing', StatusCodes.UNAUTHORIZED);

  try {
    req.user = jwt.verify(header.split(' ')[1], env.JWT_SECRET) as JwtPayload;
    next();
  } catch {
    throw new AppError('Invalid or expired token', StatusCodes.UNAUTHORIZED);
  }
};

export const authorize = (...roles: UserRole[]) =>
  (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role))
      throw new AppError('Forbidden — insufficient permissions', StatusCodes.FORBIDDEN);
    next();
  };
