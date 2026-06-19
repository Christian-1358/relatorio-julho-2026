import { create } from 'zustand';
import type { Car, Driver, Alert } from '../types/car';

interface FleetState {
  cars: Car[];
  drivers: Driver[];
  alerts: Alert[];
  selectedCarId: string | null;
  unreadAlertsCount: number;
  setCars: (cars: Car[]) => void;
  updateCar: (carId: string, updates: Partial<Car>) => void;
  setDrivers: (drivers: Driver[]) => void;
  setAlerts: (alerts: Alert[]) => void;
  addAlert: (alert: Alert) => void;
  setSelectedCarId: (id: string | null) => void;
  setUnreadCount: (count: number) => void;
}

export const useFleetStore = create<FleetState>((set) => ({
  cars: [],
  drivers: [],
  alerts: [],
  selectedCarId: null,
  unreadAlertsCount: 0,

  setCars: (cars) => set({ cars }),

  updateCar: (carId, updates) => set((state) => ({
    cars: state.cars.map((car) =>
      car.id === carId ? { ...car, ...updates } : car
    ),
  })),

  setDrivers: (drivers) => set({ drivers }),

  setAlerts: (alerts) => set({ alerts }),

  addAlert: (alert) => set((state) => ({
    alerts: [alert, ...state.alerts],
    unreadAlertsCount: state.unreadAlertsCount + 1,
  })),

  setSelectedCarId: (id) => set({ selectedCarId: id }),

  setUnreadCount: (count) => set({ unreadAlertsCount: count }),
}));
