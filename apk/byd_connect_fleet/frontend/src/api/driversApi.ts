import api from './client';
import type { Driver } from '../types/car';

export const driversApi = {
  async getAll(): Promise<Driver[]> {
    const response = await api.get<Driver[]>('/drivers');
    return response.data;
  },

  async getById(id: string): Promise<Driver> {
    const response = await api.get<Driver>(`/drivers/${id}`);
    return response.data;
  },

  async create(data: { name: string; email: string; phone?: string; cpf: string; licenseNumber?: string }): Promise<Driver> {
    const response = await api.post<Driver>('/drivers', data);
    return response.data;
  },

  async update(id: string, data: Partial<Driver>): Promise<Driver> {
    const response = await api.put<Driver>(`/drivers/${id}`, data);
    return response.data;
  },

  async delete(id: string): Promise<{ success: boolean }> {
    const response = await api.delete(`/drivers/${id}`);
    return response.data;
  },
};
