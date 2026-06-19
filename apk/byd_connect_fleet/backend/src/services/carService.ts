import prisma from '../config/database.js';
import { Car, Alert, AlertType, Severity } from '@prisma/client';

export interface CarStatusUpdate {
  batteryLevel?: number;
  isOnline?: boolean;
  isLocked?: boolean;
  gear?: string;
  speed?: number;
  range?: number;
  temperature?: number;
  latitude?: number;
  longitude?: number;
  acIsOn?: boolean;
  trunkIsOpen?: boolean;
  lightsAreOn?: boolean;
  engineRunning?: boolean;
  climateTemp?: number;
}

export interface CarCommand {
  command: 'lock' | 'unlock' | 'climate' | 'engine' | 'lights' | 'trunk' | 'horn';
  params?: Record<string, unknown>;
}

export const carService = {
  async getAllCars(fleetId?: string): Promise<Car[]> {
    const where = fleetId ? { fleetId } : {};
    return prisma.car.findMany({
      where,
      include: { driver: true },
      orderBy: { createdAt: 'desc' },
    });
  },

  async getCarById(carId: string): Promise<Car | null> {
    return prisma.car.findUnique({
      where: { id: carId },
      include: { driver: true, fleet: true },
    });
  },

  async getCarStatus(carId: string): Promise<CarStatusUpdate | null> {
    const car = await prisma.car.findUnique({ where: { id: carId } });
    if (!car) return null;

    return {
      batteryLevel: car.batteryLevel,
      isOnline: car.isOnline,
      isLocked: car.isLocked,
      gear: car.gear,
      speed: car.speed,
      range: car.range,
      temperature: car.temperature,
      latitude: car.latitude,
      longitude: car.longitude,
      acIsOn: car.acIsOn,
      trunkIsOpen: car.trunkIsOpen,
      lightsAreOn: car.lightsAreOn,
      engineRunning: car.engineRunning,
      climateTemp: car.climateTemp,
    };
  },

  async updateCarStatus(carId: string, updates: CarStatusUpdate): Promise<Car | null> {
    try {
      const car = await prisma.car.update({
        where: { id: carId },
        data: {
          batteryLevel: updates.batteryLevel,
          isOnline: updates.isOnline,
          isLocked: updates.isLocked,
          gear: updates.gear,
          speed: updates.speed,
          range: updates.range,
          temperature: updates.temperature,
          latitude: updates.latitude,
          longitude: updates.longitude,
          acIsOn: updates.acIsOn,
          trunkIsOpen: updates.trunkIsOpen,
          lightsAreOn: updates.lightsAreOn,
          engineRunning: updates.engineRunning,
          climateTemp: updates.climateTemp,
          lastSeen: new Date(),
        },
      });
      return car;
    } catch {
      return null;
    }
  },

  async executeCommand(carId: string, command: CarCommand): Promise<{ success: boolean; error?: string }> {
    try {
      const car = await prisma.car.findUnique({ where: { id: carId } });
      if (!car) {
        return { success: false, error: 'Car not found' };
      }

      let updates: Partial<Car> = {};

      switch (command.command) {
        case 'lock':
          updates = { isLocked: true };
          break;
        case 'unlock':
          updates = { isLocked: false };
          break;
        case 'climate':
          if (command.params?.enabled !== undefined) {
            updates = { acIsOn: command.params.enabled as boolean };
          }
          if (command.params?.temperature !== undefined) {
            updates = { ...updates, climateTemp: command.params.temperature as number };
          }
          break;
        case 'engine':
          if (command.params?.running !== undefined) {
            updates = { engineRunning: command.params.running as boolean };
          }
          break;
        case 'lights':
          if (command.params?.on !== undefined) {
            updates = { lightsAreOn: command.params.on as boolean };
          }
          break;
        case 'trunk':
          if (command.params?.open !== undefined) {
            updates = { trunkIsOpen: command.params.open as boolean };
          }
          break;
        case 'horn':
          // Horn is a one-time command, no state change
          break;
        default:
          return { success: false, error: 'Unknown command' };
      }

      if (Object.keys(updates).length > 0) {
        await prisma.car.update({
          where: { id: carId },
          data: updates,
        });
      }

      return { success: true };
    } catch (error) {
      console.error('Command execution error:', error);
      return { success: false, error: 'Failed to execute command' };
    }
  },

  async createAlert(
    fleetId: string,
    carId: string | null,
    type: AlertType,
    title: string,
    description: string,
    severity: Severity = Severity.INFO
  ): Promise<Alert> {
    return prisma.alert.create({
      data: {
        fleetId,
        carId,
        type,
        title,
        description,
        severity,
      },
    });
  },

  async assignDriver(carId: string, driverId: string | null): Promise<Car | null> {
    try {
      return prisma.car.update({
        where: { id: carId },
        data: { driverId },
      });
    } catch {
      return null;
    }
  },

  async getFleetStats(fleetId: string): Promise<{
    totalCars: number;
    onlineCars: number;
    alertsCount: number;
    driversCount: number;
  }> {
    const [totalCars, onlineCars, alertsCount, driversCount] = await Promise.all([
      prisma.car.count({ where: { fleetId } }),
      prisma.car.count({ where: { fleetId, isOnline: true } }),
      prisma.alert.count({ where: { fleetId, isRead: false } }),
      prisma.driver.count({ where: { fleetId, isActive: true } }),
    ]);

    return { totalCars, onlineCars, alertsCount, driversCount };
  },

  async createCar(fleetId: string, data: {
    plate: string;
    model: string;
    vin: string;
    imageUrl?: string;
  }): Promise<Car> {
    return prisma.car.create({
      data: {
        ...data,
        fleetId,
      },
    });
  },

  async deleteCar(carId: string): Promise<boolean> {
    try {
      await prisma.car.delete({ where: { id: carId } });
      return true;
    } catch {
      return false;
    }
  },
};
