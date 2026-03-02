import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { AuthRepository } from '../repository/auth.repository';
import { AppError } from '@shared/errors/AppError';
import { StatusCodes } from 'http-status-codes';
import { env } from '@config/env';
import { prisma } from '@infra/database/prisma';
import type { RegisterDto } from '../dto/auth.dto';

const repo = new AuthRepository();

export class AuthService {
  async register(data: RegisterDto) {
    if (await repo.findByEmail(data.email))
      throw new AppError('Email already registered', StatusCodes.CONFLICT);

    const user = await repo.createUser({
      ...data,
      password: await bcrypt.hash(data.password, 12),
    });

    if (user.role === 'CLIENT')
      await prisma.clientProfile.create({ data: { userId: user.id } });
    else if (user.role === 'TRAINER')
      await prisma.trainerProfile.create({ data: { userId: user.id } });
    else if (user.role === 'SELLER')
      await prisma.sellerProfile.create({
        data: { userId: user.id, storeName: `${user.firstName}'s Store`, storeSlug: uuidv4().slice(0,8) },
      });

    return this.tokens(user);
  }

  async login(email: string, password: string) {
    const user = await repo.findByEmail(email);
    if (!user?.password) throw new AppError('Invalid credentials', StatusCodes.UNAUTHORIZED);
    if (!(await bcrypt.compare(password, user.password)))
      throw new AppError('Invalid credentials', StatusCodes.UNAUTHORIZED);
    if (!user.isActive) throw new AppError('Account deactivated', StatusCodes.FORBIDDEN);
    return this.tokens(user);
  }

  async refresh(token: string) {
    const stored = await repo.findRefreshToken(token);
    if (!stored || stored.expiresAt < new Date())
      throw new AppError('Invalid or expired refresh token', StatusCodes.UNAUTHORIZED);
    const user = await repo.findById(stored.userId);
    if (!user) throw new AppError('User not found', StatusCodes.NOT_FOUND);
    await repo.deleteRefreshToken(token);
    return this.tokens(user);
  }

  async logout(token: string) {
    await repo.deleteRefreshToken(token).catch(() => null);
  }

  private async tokens(user: { id: string; email: string; role: string }) {
    const payload = { userId: user.id, email: user.email, role: user.role };
    const accessToken  = jwt.sign(payload, env.JWT_SECRET, { expiresIn: env.JWT_EXPIRES_IN as string });
    const refreshToken = uuidv4();
    await repo.saveRefreshToken(user.id, refreshToken, new Date(Date.now() + 7 * 86400_000));
    return { accessToken, refreshToken, user: payload };
  }
}
