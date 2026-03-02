import 'dotenv/config';

function required(key: string): string {
  const v = process.env[key];
  if (!v) throw new Error(`Missing required env var: ${key}`);
  return v;
}

export const env = {
  NODE_ENV:  process.env.NODE_ENV   || 'development',
  PORT:      parseInt(process.env.PORT || '3000'),
  API_PREFIX: process.env.API_PREFIX || '/api/v1',

  DATABASE_URL: required('DATABASE_URL'),

  JWT_SECRET:             required('JWT_SECRET'),
  JWT_EXPIRES_IN:         process.env.JWT_EXPIRES_IN         || '15m',
  JWT_REFRESH_SECRET:     required('JWT_REFRESH_SECRET'),
  JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || '7d',

  GOOGLE_CLIENT_ID:     process.env.GOOGLE_CLIENT_ID     || '',
  GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET || '',
  GOOGLE_CALLBACK_URL:  process.env.GOOGLE_CALLBACK_URL  || '',

  CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME || '',
  CLOUDINARY_API_KEY:    process.env.CLOUDINARY_API_KEY    || '',
  CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET || '',

  STRIPE_SECRET_KEY:     process.env.STRIPE_SECRET_KEY    || '',
  STRIPE_WEBHOOK_SECRET: process.env.STRIPE_WEBHOOK_SECRET || '',

  CORS_ORIGIN:         process.env.CORS_ORIGIN         || 'http://localhost:8081',
  OPENFOODFACTS_BASE:  process.env.OPENFOODFACTS_BASE   || 'https://world.openfoodfacts.org/api/v0',
} as const;
