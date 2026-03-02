import { Server } from 'socket.io';
import { logger } from '../logger';

export const initSocket = (io: Server): void => {
  io.on('connection', (socket) => {
    logger.info(`Socket connected: ${socket.id}`);

    socket.on('chat:join',  (chatId: string) => socket.join(`chat:${chatId}`));
    socket.on('chat:leave', (chatId: string) => socket.leave(`chat:${chatId}`));
    socket.on('chat:message', (data) => io.to(`chat:${data.chatId}`).emit('chat:message:new', data));

    // Real-time GPS run (broadcast to all)
    socket.on('run:location', (data) => socket.broadcast.emit('run:location:update', data));

    socket.on('disconnect', () => logger.info(`Socket disconnected: ${socket.id}`));
  });
};
