import api from './client';
import type { Plan, Subscription } from '../types/car';

export const billingApi = {
  async getPlans(): Promise<Plan[]> {
    const response = await api.get<Plan[]>('/billing/plans');
    return response.data;
  },

  async getSubscription(): Promise<Subscription> {
    const response = await api.get<Subscription>('/billing/subscription');
    return response.data;
  },

  async subscribe(planId: string): Promise<Subscription> {
    const response = await api.post<Subscription>('/billing/subscription', { planId });
    return response.data;
  },

  async cancelSubscription(subscriptionId: string): Promise<{ success: boolean }> {
    const response = await api.put(`/billing/subscription/${subscriptionId}/cancel`);
    return response.data;
  },
};
