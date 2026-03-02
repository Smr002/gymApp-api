import { z } from 'zod';

export const registerSchema = z.object({
  email:     z.string().email(),
  password:  z.string().min(8, 'Password must be at least 8 characters'),
  firstName: z.string().min(1),
  lastName:  z.string().min(1),
  role:      z.enum(['CLIENT', 'TRAINER', 'SELLER']).optional().default('CLIENT'),
});

export const loginSchema = z.object({
  email:    z.string().email(),
  password: z.string().min(1),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export type RegisterDto = z.infer<typeof registerSchema>;
export type LoginDto    = z.infer<typeof loginSchema>;
