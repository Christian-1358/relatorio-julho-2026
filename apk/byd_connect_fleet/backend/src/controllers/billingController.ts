import { Request, Response, NextFunction } from 'express';
import prisma from '../config/database.js';

export const billingController = {
  async getPlans(_req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const plans = await prisma.plan.findMany({
        where: { isActive: true },
        orderBy: { price: 'asc' },
      });
      res.json(plans);
    } catch (error) {
      next(error);
    }
  },

  async getSubscription(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = (req as any).userId;

      const subscription = await prisma.subscription.findFirst({
        where: { userId },
        include: { plan: true },
        orderBy: { startedAt: 'desc' },
      });

      if (!subscription) {
        res.status(404).json({ error: 'No subscription found' });
        return;
      }

      res.json(subscription);
    } catch (error) {
      next(error);
    }
  },

  async createSubscription(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = (req as any).userId;
      const { planId } = req.body;

      if (!planId) {
        res.status(400).json({ error: 'planId required' });
        return;
      }

      const plan = await prisma.plan.findUnique({ where: { id: planId } });
      if (!plan) {
        res.status(404).json({ error: 'Plan not found' });
        return;
      }

      // Calculate expiry (1 month from now for monthly plans)
      const expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 1);

      const subscription = await prisma.subscription.create({
        data: {
          userId,
          planId,
          status: 'ACTIVE',
          expiresAt,
        },
        include: { plan: true },
      });

      res.status(201).json(subscription);
    } catch (error) {
      next(error);
    }
  },

  async cancelSubscription(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = (req as any).userId;
      const { subscriptionId } = req.params;

      await prisma.subscription.update({
        where: { id: subscriptionId },
        data: { status: 'CANCELLED' },
      });

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },
};
