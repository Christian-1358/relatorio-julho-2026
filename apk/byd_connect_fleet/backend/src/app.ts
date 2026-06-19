import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import dotenv from 'dotenv';

import authRoutes from './routes/authRoutes.js';
import carRoutes from './routes/carRoutes.js';
import driverRoutes from './routes/driverRoutes.js';
import alertRoutes from './routes/alertRoutes.js';
import billingRoutes from './routes/billingRoutes.js';
import { errorMiddleware } from './middleware/errorMiddleware.js';
import { initializeSocketService } from './services/socketService.js';

dotenv.config();

const app = express();
const httpServer = createServer(app);

// Initialize Socket.IO
initializeSocketService(httpServer);

// Middleware
app.use(cors({ origin: process.env.CLIENT_URL || 'http://localhost:5173', credentials: true }));
app.use(express.json());

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/cars', carRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/alerts', alertRoutes);
app.use('/api/billing', billingRoutes);

// Error handling
app.use(errorMiddleware);

const PORT = process.env.PORT || 3001;

httpServer.listen(PORT, () => {
  console.log(`🚀 Fleet Backend running on port ${PORT}`);
  console.log(`📡 Socket.IO ready for real-time connections`);
});

export default app;
