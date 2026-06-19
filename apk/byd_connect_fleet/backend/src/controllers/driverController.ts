import { Request, Response, NextFunction } from 'express';
import prisma from '../config/database.js';

export const driverController = {
  async getAllDrivers(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      const drivers = await prisma.driver.findMany({
        where: { fleetId, isActive: true },
        include: { cars: true },
        orderBy: { name: 'asc' },
      });
      res.json(drivers);
    } catch (error) {
      next(error);
    }
  },

  async getDriverById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const driver = await prisma.driver.findUnique({
        where: { id },
        include: { cars: true },
      });

      if (!driver) {
        res.status(404).json({ error: 'Driver not found' });
        return;
      }

      res.json(driver);
    } catch (error) {
      next(error);
    }
  },

  async createDriver(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      const { name, email, phone, cpf, licenseNumber } = req.body;

      if (!name || !email || !cpf) {
        res.status(400).json({ error: 'name, email and cpf required' });
        return;
      }

      const driver = await prisma.driver.create({
        data: { name, email, phone, cpf, licenseNumber, fleetId },
      });

      res.status(201).json(driver);
    } catch (error) {
      next(error);
    }
  },

  async updateDriver(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { name, email, phone, licenseNumber, isActive } = req.body;

      const driver = await prisma.driver.update({
        where: { id },
        data: { name, email, phone, licenseNumber, isActive },
      });

      res.json(driver);
    } catch (error) {
      next(error);
    }
  },

  async deleteDriver(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;

      // Soft delete - just mark as inactive
      await prisma.driver.update({
        where: { id },
        data: { isActive: false },
      });

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },
};
