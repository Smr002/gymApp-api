import { Request, Response } from 'express';
import { AuthService } from '../service/auth.service';
import { sendSuccess } from '@utils/apiResponse';
import { registerSchema, loginSchema, refreshSchema } from '../dto/auth.dto';

const svc = new AuthService();

export const register = async (req: Request, res: Response) => {
  sendSuccess(res, await svc.register(registerSchema.parse(req.body)), 'Registered', 201);
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = loginSchema.parse(req.body);
  sendSuccess(res, await svc.login(email, password), 'Login successful');
};

export const refresh = async (req: Request, res: Response) => {
  sendSuccess(res, await svc.refresh(refreshSchema.parse(req.body).refreshToken), 'Token refreshed');
};

export const logout = async (req: Request, res: Response) => {
  await svc.logout(req.body.refreshToken);
  sendSuccess(res, null, 'Logged out');
};
