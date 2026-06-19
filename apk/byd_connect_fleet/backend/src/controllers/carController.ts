import { Request, Response, NextFunction } from 'express';
import { carService } from '../services/carService.js';

export const carController = {
  async getAllCars(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      const cars = await carService.getAllCars(fleetId);
      res.json(cars);
    } catch (error) {
      next(error);
    }
  },

  async getCarById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const car = await carService.getCarById(id);

      if (!car) {
        res.status(404).json({ error: 'Car not found' });
        return;
      }

      res.json(car);
    } catch (error) {
      next(error);
    }
  },

  async getCarStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const status = await carService.getCarStatus(id);

      if (!status) {
        res.status(404).json({ error: 'Car not found' });
        return;
      }

      res.json(status);
    } catch (error) {
      next(error);
    }
  },

  async sendCommand(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { command, params } = req.body;

      if (!command) {
        res.status(400).json({ error: 'Command required' });
        return;
      }

      const result = await carService.executeCommand(id, { command, params });

      if (!result.success) {
        res.status(400).json({ error: result.error });
        return;
      }

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },

  async getFleetStats(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      if (!fleetId) {
        res.status(400).json({ error: 'Fleet ID required' });
        return;
      }

      const stats = await carService.getFleetStats(fleetId);
      res.json(stats);
    } catch (error) {
      next(error);
    }
  },

  async createCar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const fleetId = (req as any).fleetId;
      const { plate, model, vin, imageUrl } = req.body;

      if (!plate || !model || !vin) {
        res.status(400).json({ error: 'plate, model and vin required' });
        return;
      }

      const car = await carService.createCar(fleetId, { plate, model, vin, imageUrl });
      res.status(201).json(car);
    } catch (error) {
      next(error);
    }
  },

  async deleteCar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const success = await carService.deleteCar(id);

      if (!success) {
        res.status(404).json({ error: 'Car not found' });
        return;
      }

      res.json({ success: true });
    } catch (error) {
      next(error);
    }
  },

  async assignDriver(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { driverId } = req.body;

      const car = await carService.assignDriver(id, driverId);

      if (!car) {
        res.status(404).json({ error: 'Car not found' });
        return;
      }

      res.json(car);
    } catch (error) {
      next(error);
    }
  },
};
