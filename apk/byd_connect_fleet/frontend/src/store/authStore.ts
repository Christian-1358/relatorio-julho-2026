import { create } from 'zustand';
import type { User } from '../types/auth';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  requires2FA: boolean;
  pendingUserId: string | null;
  setUser: (user: User | null) => void;
  setRequires2FA: (requires: boolean, userId?: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: !!localStorage.getItem('accessToken'),
  requires2FA: false,
  pendingUserId: null,

  setUser: (user) => set({ user, isAuthenticated: !!user }),

  setRequires2FA: (requires, userId) => set({
    requires2FA: requires,
    pendingUserId: userId || null,
  }),

  logout: () => {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    set({ user: null, isAuthenticated: false, requires2FA: false, pendingUserId: null });
  },
}));
