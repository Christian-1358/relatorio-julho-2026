import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Car as CarIcon, Battery, Lock, LockOpen, Thermometer, Filter } from 'lucide-react';
import { GlassCard } from '../components/glass/GlassCard';
import { GlassButton } from '../components/glass/GlassButton';
import { StatusIndicator } from '../components/glass/StatusIndicator';
import { CarDetailPanel } from '../components/fleet/CarDetailPanel';
import { useFleetStore } from '../store/fleetStore';
import { useCars } from '../hooks/useCars';
import { DashboardLayout } from '../components/layout/DashboardLayout';
import type { Car } from '../types/car';

export const FleetPage = () => {
  const { selectedCarId, setSelectedCarId } = useFleetStore();
  const { cars, sendCommand } = useCars();
  const [filter, setFilter] = useState<'all' | 'online' | 'offline'>('all');

  const filteredCars = cars.filter((car) => {
    if (filter === 'online') return car.isOnline;
    if (filter === 'offline') return !car.isOnline;
    return true;
  });

  const selectedCar = cars.find((c) => c.id === selectedCarId);

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Frota</h1>
            <p className="text-gray-500 mt-1">{cars.length} veículos cadastrados</p>
          </div>

          <div className="flex items-center gap-2">
            <Filter className="w-5 h-5 text-gray-500" />
            {(['all', 'online', 'offline'] as const).map((f) => (
              <GlassButton
                key={f}
                variant={filter === f ? 'primary' : 'secondary'}
                size="sm"
                onClick={() => setFilter(f)}
              >
                {f === 'all' ? 'Todos' : f === 'online' ? 'Online' : 'Offline'}
              </GlassButton>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <AnimatePresence>
            {filteredCars.map((car) => (
              <CarCard
                key={car.id}
                car={car}
                onClick={() => setSelectedCarId(car.id)}
                onCommand={(cmd) => sendCommand(car.id, cmd)}
              />
            ))}
          </AnimatePresence>
        </div>

        {filteredCars.length === 0 && (
          <div className="text-center py-12 text-gray-500">
            Nenhum veículo encontrado com este filtro
          </div>
        )}
      </div>

      {/* Car Detail Panel */}
      <AnimatePresence>
        {selectedCar && (
          <CarDetailPanel
            car={selectedCar}
            onClose={() => setSelectedCarId(null)}
            onCommand={(cmd, params) => sendCommand(selectedCar.id, cmd, params)}
          />
        )}
      </AnimatePresence>
    </DashboardLayout>
  );
};

interface CarCardProps {
  car: Car;
  onClick: () => void;
  onCommand: (cmd: string, params?: Record<string, unknown>) => void;
}

const CarCard = ({ car, onClick, onCommand }: CarCardProps) => {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
    >
      <GlassCard hover onClick={onClick} className="p-5 space-y-4">
        {/* Header */}
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 bg-surface rounded-xl flex items-center justify-center">
              <CarIcon className="w-6 h-6 text-primary" />
            </div>
            <div>
              <h3 className="font-semibold">{car.model}</h3>
              <p className="text-sm text-gray-500">{car.plate}</p>
            </div>
          </div>
          <StatusIndicator
            status={car.isOnline ? 'online' : 'offline'}
            label={car.isOnline ? 'Online' : 'Offline'}
            pulse={car.isOnline}
          />
        </div>

        {/* Battery */}
        <div className="flex items-center gap-4">
          <Battery className={`w-5 h-5 ${car.batteryLevel > 20 ? 'text-online' : 'text-error'}`} />
          <div className="flex-1">
            <div className="w-full bg-surface rounded-full h-2">
              <div
                className={`h-2 rounded-full transition-all ${car.batteryLevel > 50 ? 'bg-online' : car.batteryLevel > 20 ? 'bg-warning' : 'bg-error'}`}
                style={{ width: `${car.batteryLevel}%` }}
              />
            </div>
          </div>
          <span className="text-sm font-medium">{car.batteryLevel}%</span>
        </div>

        {/* Info Row */}
        <div className="grid grid-cols-3 gap-2 text-center">
          <div className="bg-surface/50 rounded-lg py-2">
            <p className="text-xs text-gray-500">Temp</p>
            <p className="font-medium">{car.temperature}°</p>
          </div>
          <div className="bg-surface/50 rounded-lg py-2">
            <p className="text-xs text-gray-500">Autonomia</p>
            <p className="font-medium">{car.range} km</p>
          </div>
          <div className="bg-surface/50 rounded-lg py-2">
            <p className="text-xs text-gray-500">Marcha</p>
            <p className="font-medium">{car.gear}</p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="flex gap-2">
          <GlassButton
            size="sm"
            variant={car.isLocked ? 'danger' : 'success'}
            onClick={(e) => {
              e.stopPropagation();
              onCommand(car.isLocked ? 'unlock' : 'lock');
            }}
            className="flex-1"
          >
            {car.isLocked ? <Lock className="w-4 h-4 mr-1" /> : <LockOpen className="w-4 h-4 mr-1" />}
            {car.isLocked ? 'Bloquear' : 'Desbloquear'}
          </GlassButton>
          <GlassButton
            size="sm"
            variant={car.acIsOn ? 'primary' : 'secondary'}
            onClick={(e) => {
              e.stopPropagation();
              onCommand('climate', { enabled: !car.acIsOn });
            }}
            className="flex-1"
          >
            <Thermometer className="w-4 h-4 mr-1" />
            {car.acIsOn ? 'AC On' : 'AC Off'}
          </GlassButton>
        </div>
      </GlassCard>
    </motion.div>
  );
};
