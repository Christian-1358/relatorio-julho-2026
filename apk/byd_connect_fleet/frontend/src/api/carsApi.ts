import api from './client';
import type { Car, CarCommand, FleetStats } from '../types/car';

export const carsApi = {
  async getAll(): Promise<Car[]> {
    const response = await api.get<Car[]>('/cars');
    return response.data;
  },

  async getById(id: string): Promise<Car> {
    const response = await api.get<Car>(`/cars/${id}`);
    return response.data;
  },

  async getStats(): Promise<FleetStats> {
    const response = await api.get<FleetStats>('/cars/stats');
    return response.data;
  },

  async sendCommand(id: string, command: CarCommand): Promise<{ success: boolean; error?: string }> {
    const response = await api.post(`/cars/${id}/command`, command);
    return response.data;
  },

  async create(data: { plate: string; model: string; vin: string; imageUrl?: string }): Promise<Car> {
    const response = await api.post<Car>('/cars', data);
    return response.data;
  },

  async delete(id: string): Promise<{ success: boolean }> {
    const response = await api.delete(`/cars/${id}`);
    return response.data;
  },

  async assignDriver(id: string, driverId: string | null): Promise<Car> {
    const response = await api.put<Car>(`/cars/${id}/driver`, { driverId });
    return response.data;
  },
};
