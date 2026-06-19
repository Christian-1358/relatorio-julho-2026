import { motion } from 'framer-motion';
import { X, Car as CarIcon, Battery, Lock, LockOpen, Thermometer, MapPin, Gauge, Zap, Radio, AlertCircle } from 'lucide-react';
import { GlassCard } from '../glass/GlassCard';
import { GlassButton } from '../glass/GlassButton';
import { StatusIndicator } from '../glass/StatusIndicator';
import type { Car } from '../../types/car';

interface CarDetailPanelProps {
  car: Car;
  onClose: () => void;
  onCommand: (command: string, params?: Record<string, unknown>) => void;
}

export const CarDetailPanel = ({ car, onClose, onCommand }: CarDetailPanelProps) => {
  const commands: Array<{
    cmd: string;
    icon: any;
    label: string;
    variant: 'primary' | 'secondary' | 'danger' | 'success';
    params?: Record<string, unknown>;
  }> = [
    { cmd: car.isLocked ? 'unlock' : 'lock', icon: car.isLocked ? LockOpen : Lock, label: car.isLocked ? 'Desbloquear' : 'Bloquear', variant: car.isLocked ? 'success' : 'danger' },
    { cmd: 'climate', params: { enabled: !car.acIsOn }, icon: Thermometer, label: car.acIsOn ? 'Desligar AC' : 'Ligar AC', variant: 'primary' },
    { cmd: 'lights', params: { on: !car.lightsAreOn }, icon: Zap, label: car.lightsAreOn ? 'Lights Off' : 'Lights On', variant: 'secondary' },
    { cmd: 'engine', params: { running: !car.engineRunning }, icon: Radio, label: car.engineRunning ? 'Engine Off' : 'Engine On', variant: 'secondary' },
    { cmd: 'trunk', params: { open: !car.trunkIsOpen }, icon: CarIcon, label: car.trunkIsOpen ? 'Close Trunk' : 'Open Trunk', variant: 'secondary' },
    { cmd: 'horn', icon: AlertCircle, label: 'Horn', variant: 'secondary' },
  ];

  return (
    <>
      {/* Backdrop */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 bg-black/50 z-40"
        onClick={onClose}
      />

      {/* Panel */}
      <motion.div
        initial={{ x: '100%' }}
        animate={{ x: 0 }}
        exit={{ x: '100%' }}
        transition={{ type: 'spring', damping: 25 }}
        className="fixed right-0 top-0 h-full w-full max-w-md bg-background/95 backdrop-blur-xl border-l border-white/10 z-50 overflow-y-auto"
      >
        {/* Header */}
        <div className="sticky top-0 bg-background/95 backdrop-blur-xl border-b border-white/10 p-6 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 bg-primary/20 rounded-xl flex items-center justify-center">
              <CarIcon className="w-6 h-6 text-primary" />
            </div>
            <div>
              <h2 className="text-xl font-bold">{car.model}</h2>
              <p className="text-sm text-gray-500">{car.plate}</p>
            </div>
          </div>
          <button onClick={onClose} className="p-2 hover:bg-white/10 rounded-lg">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          {/* Status */}
          <div className="flex items-center justify-between">
            <StatusIndicator status={car.isOnline ? 'online' : 'offline'} pulse />
            <span className="text-sm text-gray-500">
              {car.isOnline ? 'Conectado agora' : `Último visto: ${car.lastSeen ? new Date(car.lastSeen).toLocaleString('pt-BR') : 'N/A'}`}
            </span>
          </div>

          {/* Battery */}
          <GlassCard className="p-5">
            <div className="flex items-center gap-4 mb-4">
              <Battery className={`w-8 h-8 ${car.batteryLevel > 20 ? 'text-online' : 'text-error'}`} />
              <div className="flex-1">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-gray-400">Bateria</span>
                  <span className="text-2xl font-bold">{car.batteryLevel}%</span>
                </div>
                <div className="w-full bg-surface rounded-full h-3">
                  <div
                    className={`h-3 rounded-full transition-all ${car.batteryLevel > 50 ? 'bg-online' : car.batteryLevel > 20 ? 'bg-warning' : 'bg-error'}`}
                    style={{ width: `${car.batteryLevel}%` }}
                  />
                </div>
                <p className="text-sm text-gray-500 mt-2">Autonomia: {car.range} km</p>
              </div>
            </div>
          </GlassCard>

          {/* Car Info Grid */}
          <div className="grid grid-cols-2 gap-3">
            {[
              { icon: Gauge, label: 'Velocidade', value: `${car.speed} km/h` },
              { icon: Thermometer, label: 'Temperatura', value: `${car.temperature}°C` },
              { icon: MapPin, label: 'Localização', value: car.latitude ? 'Disponível' : 'N/A' },
              { icon: Lock, label: 'Status', value: car.isLocked ? 'Bloqueado' : 'Desbloqueado' },
            ].map(({ icon: Icon, label, value }) => (
              <GlassCard key={label} className="p-4">
                <Icon className="w-5 h-5 text-primary mb-2" />
                <p className="text-xs text-gray-500">{label}</p>
                <p className="font-semibold mt-1">{value}</p>
              </GlassCard>
            ))}
          </div>

          {/* Commands */}
          <div>
            <h3 className="text-lg font-semibold mb-4">Comandos</h3>
            <div className="grid grid-cols-2 gap-3">
              {commands.map(({ cmd, params, icon: Icon, label, variant }) => (
                <GlassButton
                  key={cmd + (params ? JSON.stringify(params) : '')}
                  variant={variant}
                  onClick={() => onCommand(cmd, params)}
                  className="flex-col py-4 h-auto"
                >
                  <Icon className="w-6 h-6 mb-2" />
                  <span className="text-xs">{label}</span>
                </GlassButton>
              ))}
            </div>
          </div>

          {/* Climate Control */}
          <GlassCard className="p-5">
            <h3 className="font-semibold mb-4">Controle de Clima</h3>
            <div className="flex items-center justify-between">
              <span className="text-gray-400">Temperatura</span>
              <span className="text-xl font-bold">{car.climateTemp}°C</span>
            </div>
            <div className="flex gap-2 mt-4">
              <GlassButton
                variant="secondary"
                onClick={() => onCommand('climate', { temperature: Math.max(16, car.climateTemp - 1) })}
                className="flex-1"
              >
                -
              </GlassButton>
              <GlassButton
                variant="secondary"
                onClick={() => onCommand('climate', { temperature: Math.min(30, car.climateTemp + 1) })}
                className="flex-1"
              >
                +
              </GlassButton>
            </div>
          </GlassCard>

          {/* Driver */}
          {car.driver && (
            <GlassCard className="p-5">
              <h3 className="font-semibold mb-3">Motorista</h3>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-accent/20 rounded-full flex items-center justify-center">
                  <span className="text-accent font-bold">{car.driver.name.charAt(0)}</span>
                </div>
                <div>
                  <p className="font-medium">{car.driver.name}</p>
                  <p className="text-sm text-gray-500">{car.driver.email}</p>
                </div>
              </div>
            </GlassCard>
          )}
        </div>
      </motion.div>
    </>
  );
};
