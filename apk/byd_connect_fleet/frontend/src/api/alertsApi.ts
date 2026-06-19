import api from './client';
import type { Alert } from '../types/car';

export interface AlertsResponse {
  alerts: Alert[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

export const alertsApi = {
  async getAll(params?: { page?: number; limit?: number; unreadOnly?: boolean }): Promise<AlertsResponse> {
    const response = await api.get<AlertsResponse>('/alerts', { params });
    return response.data;
  },

  async getUnreadCount(): Promise<{ count: number }> {
    const response = await api.get<{ count: number }>('/alerts/unread-count');
    return response.data;
  },

  async markAsRead(id: string): Promise<{ success: boolean }> {
    const response = await api.put(`/alerts/${id}/read`);
    return response.data;
  },

  async markAllAsRead(): Promise<{ success: boolean }> {
    const response = await api.put('/alerts/read-all');
    return response.data;
  },
};
