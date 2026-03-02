import { prisma } from '@infra/database/prisma';

export class AuthRepository {
  findByEmail(email: string)     { return prisma.user.findUnique({ where: { email } }); }
  findById(id: string)           { return prisma.user.findUnique({ where: { id } }); }
  findByGoogleId(googleId: string) { return prisma.user.findUnique({ where: { googleId } }); }

  createUser(data: {
    email: string; password?: string; googleId?: string;
    firstName: string; lastName: string;
    role?: 'CLIENT' | 'TRAINER' | 'SELLER';
  }) {
    return prisma.user.create({ data });
  }

  saveRefreshToken(userId: string, token: string, expiresAt: Date) {
    return prisma.refreshToken.create({ data: { userId, token, expiresAt } });
  }

  findRefreshToken(token: string) {
    return prisma.refreshToken.findUnique({ where: { token } });
  }

  deleteRefreshToken(token: string) {
    return prisma.refreshToken.delete({ where: { token } });
  }
}
