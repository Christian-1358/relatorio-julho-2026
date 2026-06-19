import { useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { carsApi } from '../api/carsApi';
import { useFleetStore } from '../store/fleetStore';
import toast from 'react-hot-toast';

export const useCars = () => {
  const queryClient = useQueryClient();
  const { setCars, setSelectedCarId } = useFleetStore();

  const { data: cars = [], isLoading, error } = useQuery({
    queryKey: ['cars'],
    queryFn: carsApi.getAll,
    refetchInterval: 5000, // Poll every 5 seconds like mobile app
  });

  // Update store when cars change
  useEffect(() => {
    if (cars.length > 0) {
      setCars(cars);
    }
  }, [cars, setCars]);

  const sendCommandMutation = useMutation({
    mutationFn: ({ carId, command, params }: { carId: string; command: string; params?: Record<string, unknown> }) =>
      carsApi.sendCommand(carId, { command: command as any, params }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['cars'] });
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Command failed');
    },
  });

  return {
    cars,
    isLoading,
    error,
    sendCommand: (carId: string, command: string, params?: Record<string, unknown>) =>
      sendCommandMutation.mutate({ carId, command, params }),
    selectCar: setSelectedCarId,
  };
};
