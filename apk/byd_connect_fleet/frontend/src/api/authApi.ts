import api from './client';
import type { LoginResponse, AuthTokens } from '../types/auth';

export const authApi = {
  async login(email: string, password: string): Promise<LoginResponse> {
    const response = await api.post<LoginResponse>('/auth/login', { email, password });
    return response.data;
  },

  async verify2FA(userId: string, code: string): Promise<AuthTokens & { error?: string }> {
    const response = await api.post<AuthTokens & { error?: string }>('/auth/verify-2fa', { userId, code });
    return response.data;
  },

  async register(email: string, password: string, name: string): Promise<{ userId?: string; error?: string }> {
    const response = await api.post('/auth/register', { email, password, name });
    return response.data;
  },

  async logout(): Promise<void> {
    await api.post('/auth/logout');
  },

  async setup2FA(): Promise<{ secret: string; qrCode: string } | { error: string }> {
    const response = await api.post('/auth/setup-2fa');
    return response.data;
  },

  async enable2FA(code: string): Promise<{ success: boolean; error?: string }> {
    const response = await api.post('/auth/enable-2fa', { code });
    return response.data;
  },

  async forgotPassword(email: string): Promise<{ message: string }> {
    const response = await api.post('/auth/forgot-password', { email });
    return response.data;
  },

  async resetPassword(token: string, newPassword: string): Promise<{ success: boolean; message: string }> {
    const response = await api.post('/auth/reset-password', { token, newPassword });
    return response.data;
  },
};
