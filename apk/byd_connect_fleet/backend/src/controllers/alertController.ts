import { Request, Response, NextFunction } from 'express';
import prisma from '../config/database.js';

export const alertController = {
  async getAlerts(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      const { page = 1, limit = 20, unreadOnly } = req.query;

      const where: any = { fleetId };
      if (unreadOnly === 'true') {
        where.isRead = false;
      }

      const [alerts, total] = await Promise.all([
        prisma.alert.findMany({
          where,
          orderBy: { createdAt: 'desc' },
          skip: (Number(page) - 1) * Number(limit),
          take: Number(limit),
        }),
        prisma.alert.count({ where }),
      ]);

      res.json({
        alerts,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total,
          pages: Math.ceil(total / Number(limit)),
        },
      });
    } catch (error) {
      next(error);
    }
  },

  async getUnreadCount(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      const count = await prisma.alert.count({
        where: { fleetId, isRead: false },
      });
      res.json({ count });
    } catch (error) {
      next(error);
    }
  },

  async markAsRead(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;

      await prisma.alert.update({
        where: { id },
        data: { isRead: true },
      });

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },

  async markAllAsRead(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;

      await prisma.alert.updateMany({
        where: { fleetId, isRead: false },
        data: { isRead: true },
      });

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },

  async createAlert(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      const { carId, type, title, description, severity } = req.body;

      if (!type || !title) {
        res.status(400).json({ error: 'type and title required' });
        return;
      }

      const alert = await prisma.alert.create({
        data: {
          fleetId,
          carId,
          type,
          title,
          description,
          severity: severity || 'INFO',
        },
      });

      res.status(201).json(alert);
    } catch (error) {
      next(error);
    }
  },
};
