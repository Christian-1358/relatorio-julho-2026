import { Server as SocketIOServer, Socket } from 'socket.io';
import { Server as HTTPServer } from 'http';
import jwt from 'jsonwebtoken';
import { carService, CarStatusUpdate } from './carService.js';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  fleetId?: string;
}

let io: SocketIOServer | null = null;

export const initializeSocketService = (httpServer: HTTPServer): SocketIOServer => {
  io = new SocketIOServer(httpServer, {
    cors: {
      origin: process.env.CLIENT_URL || 'http://localhost:5173',
      methods: ['GET', 'POST'],
      credentials: true,
    },
  });

  io.use((socket: AuthenticatedSocket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Authentication required'));
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { userId: string };
      socket.userId = decoded.userId;
      next();
    } catch (error) {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket: AuthenticatedSocket) => {
    console.log(`Client connected: ${socket.userId}`);

    socket.on('car:subscribe', async ({ carIds }: { carIds: string[] }) => {
      carIds.forEach(carId => {
        socket.join(`car:${carId}`);
      });
      socket.emit('subscribed', { carIds });
    });

    socket.on('car:unsubscribe', ({ carIds }: { carIds: string[] }) => {
      carIds.forEach(carId => {
        socket.leave(`car:${carId}`);
      });
    });

    socket.on('car:command', async (data: { carId: string; command: string; params?: Record<string, unknown> }) => {
      const result = await carService.executeCommand(data.carId, {
        command: data.command as 'lock' | 'unlock' | 'climate' | 'engine' | 'lights' | 'trunk' | 'horn',
        params: data.params,
      });

      socket.emit('command:result', {
        carId: data.carId,
        command: data.command,
        success: result.success,
        error: result.error,
      });

      if (result.success) {
        const car = await carService.getCarById(data.carId);
        if (car && car.fleetId) {
          io?.to(`car:${data.carId}`).emit('car:status', {
            carId: data.carId,
            status: car,
          });
        }
      }
    });

    socket.on('disconnect', () => {
      console.log(`Client disconnected: ${socket.userId}`);
    });
  });

  return io;
};

export const emitCarUpdate = (carId: string, status: CarStatusUpdate): void => {
  if (io) {
    io.to(`car:${carId}`).emit('car:status', { carId, status });
  }
};

export const emitNewAlert = (fleetId: string, alert: unknown): void => {
  if (io) {
    io.to(`fleet:${fleetId}`).emit('alert:new', { alert });
  }
};

export const emitLocationUpdate = (carId: string, lat: number, lng: number): void => {
  if (io) {
    io.to(`car:${carId}`).emit('car:location', { carId, lat, lng, timestamp: Date.now() });
  }
};

export const getIO = (): SocketIOServer | null => io;
