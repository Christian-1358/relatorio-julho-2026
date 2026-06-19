import { useEffect, useCallback, useRef } from 'react';
import { io, Socket } from 'socket.io-client';
import { useFleetStore } from '../store/fleetStore';
import toast from 'react-hot-toast';

export const useSocket = () => {
  const socketRef = useRef<Socket | null>(null);
  const { updateCar, addAlert } = useFleetStore();

  const connect = useCallback(() => {
    const token = localStorage.getItem('accessToken');
    if (!token) return;

    if (socketRef.current?.connected) return;

    socketRef.current = io({
      auth: { token },
    });

    socketRef.current.on('connect', () => {
      console.log('🔌 Socket connected');
    });

    socketRef.current.on('car:status', (data: { carId: string; status: any }) => {
      updateCar(data.carId, data.status);
    });

    socketRef.current.on('car:location', (data: { carId: string; lat: number; lng: number }) => {
      updateCar(data.carId, { latitude: data.lat, longitude: data.lng });
    });

    socketRef.current.on('alert:new', (data: { alert: any }) => {
      addAlert(data.alert);
      toast(`🔔 ${data.alert.title}`, { icon: '🔔' });
    });

    socketRef.current.on('command:result', (data: { carId: string; command: string; success: boolean; error?: string }) => {
      if (data.success) {
        toast.success(`${data.command} executed successfully`);
      } else {
        toast.error(data.error || 'Command failed');
      }
    });

    socketRef.current.on('disconnect', () => {
      console.log('🔌 Socket disconnected');
    });

    socketRef.current.on('error', (error: Error) => {
      console.error('Socket error:', error);
    });
  }, [updateCar, addAlert]);

  const disconnect = useCallback(() => {
    if (socketRef.current) {
      socketRef.current.disconnect();
      socketRef.current = null;
    }
  }, []);

  const subscribeToCars = useCallback((carIds: string[]) => {
    if (socketRef.current?.connected) {
      socketRef.current.emit('car:subscribe', { carIds });
    }
  }, []);

  const unsubscribeFromCars = useCallback((carIds: string[]) => {
    if (socketRef.current?.connected) {
      socketRef.current.emit('car:unsubscribe', { carIds });
    }
  }, []);

  const sendCommand = useCallback((carId: string, command: string, params?: Record<string, unknown>) => {
    if (socketRef.current?.connected) {
      socketRef.current.emit('car:command', { carId, command, params });
      return true;
    }
    return false;
  }, []);

  useEffect(() => {
    return () => {
      disconnect();
    };
  }, [disconnect]);

  return { connect, disconnect, subscribeToCars, unsubscribeFromCars, sendCommand };
};
