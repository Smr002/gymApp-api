import 'express-async-errors';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';

import { env } from '@config/env';
import { errorHandler } from '@shared/middleware/errorHandler';
import { notFoundHandler } from '@shared/middleware/notFoundHandler';
import { rateLimiter } from '@shared/middleware/rateLimiter';
import { logger } from '@infra/logger';
import { initSocket } from '@infra/realtime/socket';
import { registerRoutes } from './routes';

const app = express();
const httpServer = createServer(app);

export const io = new SocketServer(httpServer, {
  cors: { origin: env.CORS_ORIGIN, credentials: true },
});

app.use(helmet());
app.use(cors({ origin: env.CORS_ORIGIN, credentials: true }));
app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(rateLimiter);

registerRoutes(app);
initSocket(io);

app.use(notFoundHandler);
app.use(errorHandler);

httpServer.listen(env.PORT, () => {
  logger.info(`🚀 Server → http://localhost:${env.PORT}${env.API_PREFIX}  [${env.NODE_ENV}]`);
});

export default app;
