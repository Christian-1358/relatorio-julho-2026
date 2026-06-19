import { create } from 'zustand';

interface UIState {
  sidebarOpen: boolean;
  carDetailOpen: boolean;
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;
  setCarDetailOpen: (open: boolean) => void;
}

export const useUIStore = create<UIState>((set) => ({
  sidebarOpen: true,
  carDetailOpen: false,

  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
  setSidebarOpen: (open) => set({ sidebarOpen: open }),
  setCarDetailOpen: (open) => set({ carDetailOpen: open }),
}));
