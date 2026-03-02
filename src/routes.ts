import { Express } from 'express';
import { env } from '@config/env';

import authRoutes         from '@features/auth/routes/auth.routes';
import userRoutes         from '@features/user/routes/user.routes';
import trainerRoutes      from '@features/trainer/routes/trainer.routes';
import clientRoutes       from '@features/client/routes/client.routes';
import workoutRoutes      from '@features/workout/routes/workout.routes';
import exerciseRoutes     from '@features/exercise/routes/exercise.routes';
import nutritionRoutes    from '@features/nutrition/routes/nutrition.routes';
import biometricsRoutes   from '@features/biometrics/routes/biometrics.routes';
import runRoutes          from '@features/run/routes/run.routes';
import shopRoutes         from '@features/shop/routes/shop.routes';
import chatRoutes         from '@features/chat/routes/chat.routes';
import notificationRoutes from '@features/notification/routes/notification.routes';
import adminRoutes        from '@features/admin/routes/admin.routes';

export const registerRoutes = (app: Express): void => {
  const p = env.API_PREFIX;

  app.get(`${p}/health`, (_req, res) =>
    res.json({ status: 'ok', ts: new Date().toISOString() }),
  );

  app.use(`${p}/auth`,          authRoutes);
  app.use(`${p}/users`,         userRoutes);
  app.use(`${p}/trainers`,      trainerRoutes);
  app.use(`${p}/clients`,       clientRoutes);
  app.use(`${p}/workouts`,      workoutRoutes);
  app.use(`${p}/exercises`,     exerciseRoutes);
  app.use(`${p}/nutrition`,     nutritionRoutes);
  app.use(`${p}/biometrics`,    biometricsRoutes);
  app.use(`${p}/runs`,          runRoutes);
  app.use(`${p}/shop`,          shopRoutes);
  app.use(`${p}/chats`,         chatRoutes);
  app.use(`${p}/notifications`, notificationRoutes);
  app.use(`${p}/admin`,         adminRoutes);
};
