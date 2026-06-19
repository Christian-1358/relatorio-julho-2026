import { useQuery } from '@tanstack/react-query';
import { motion } from 'framer-motion';
import { Car, Wifi, AlertTriangle, Users, TrendingUp, MapPin } from 'lucide-react';
import { carsApi } from '../api/carsApi';
import { alertsApi } from '../api/alertsApi';
import { GlassCard } from '../components/glass/GlassCard';
import { StatusIndicator } from '../components/glass/StatusIndicator';
import { DashboardLayout } from '../components/layout/DashboardLayout';

const fadeIn = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
};

export const DashboardPage = () => {
  const { data: stats } = useQuery({
    queryKey: ['fleetStats'],
    queryFn: carsApi.getStats,
    refetchInterval: 5000,
  });

  const { data: alertsData } = useQuery({
    queryKey: ['alerts'],
    queryFn: () => alertsApi.getAll({ limit: 5 }),
    refetchInterval: 10000,
  });

  const recentAlerts = alertsData?.alerts || [];

  const statCards = [
    {
      label: 'Total de Carros',
      value: stats?.totalCars ?? 0,
      icon: Car,
      color: 'text-primary',
      bgColor: 'bg-primary/20',
    },
    {
      label: 'Online',
      value: stats?.onlineCars ?? 0,
      icon: Wifi,
      color: 'text-online',
      bgColor: 'bg-online/20',
    },
    {
      label: 'Alertas',
      value: stats?.alertsCount ?? 0,
      icon: AlertTriangle,
      color: 'text-warning',
      bgColor: 'bg-warning/20',
    },
    {
      label: 'Motoristas',
      value: stats?.driversCount ?? 0,
      icon: Users,
      color: 'text-accent',
      bgColor: 'bg-accent/20',
    },
  ];

  return (
    <DashboardLayout>
      <motion.div initial="initial" animate="animate" className="space-y-8">
        <div>
          <h1 className="text-3xl font-bold">Dashboard</h1>
          <p className="text-gray-500 mt-1">Visão geral da sua frota</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {statCards.map((stat, index) => (
            <motion.div key={stat.label} {...fadeIn} transition={{ delay: index * 0.1 }}>
              <GlassCard className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-gray-500 text-sm">{stat.label}</p>
                    <p className="text-3xl font-bold mt-1">{stat.value}</p>
                  </div>
                  <div className={`w-12 h-12 ${stat.bgColor} rounded-xl flex items-center justify-center`}>
                    <stat.icon className={`w-6 h-6 ${stat.color}`} />
                  </div>
                </div>
              </GlassCard>
            </motion.div>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Online Status */}
          <motion.div {...fadeIn} transition={{ delay: 0.2 }}>
            <GlassCard className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-semibold">Status da Frota</h2>
                <TrendingUp className="w-5 h-5 text-online" />
              </div>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-gray-400">Online</span>
                  <StatusIndicator status="online" />
                </div>
                <div className="w-full bg-surface rounded-full h-2">
                  <div
                    className="bg-online h-2 rounded-full transition-all"
                    style={{ width: `${((stats?.onlineCars ?? 0) / Math.max(stats?.totalCars ?? 1, 1)) * 100}%` }}
                  />
                </div>
                <p className="text-sm text-gray-500">
                  {stats?.onlineCars ?? 0} de {stats?.totalCars ?? 0} veículos online
                </p>
              </div>
            </GlassCard>
          </motion.div>

          {/* Recent Alerts */}
          <motion.div {...fadeIn} transition={{ delay: 0.3 }}>
            <GlassCard className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-semibold">Alertas Recentes</h2>
                <AlertTriangle className="w-5 h-5 text-warning" />
              </div>
              <div className="space-y-3">
                {recentAlerts.length === 0 ? (
                  <p className="text-gray-500 text-center py-8">Nenhum alerta recente</p>
                ) : (
                  recentAlerts.map((alert) => (
                    <div
                      key={alert.id}
                      className="flex items-start gap-3 p-3 bg-surface/50 rounded-xl"
                    >
                      <div
                        className={`w-2 h-2 rounded-full mt-2 ${
                          alert.severity === 'CRITICAL' ? 'bg-error' :
                          alert.severity === 'ERROR' ? 'bg-error' :
                          alert.severity === 'WARNING' ? 'bg-warning' : 'bg-primary'
                        }`}
                      />
                      <div className="flex-1 min-w-0">
                        <p className="font-medium text-sm">{alert.title}</p>
                        <p className="text-gray-500 text-xs mt-0.5 truncate">{alert.description}</p>
                      </div>
                      <span className="text-gray-600 text-xs">
                        {new Date(alert.createdAt).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
                      </span>
                    </div>
                  ))
                )}
              </div>
            </GlassCard>
          </motion.div>
        </div>

        {/* Quick Map Preview */}
        <motion.div {...fadeIn} transition={{ delay: 0.4 }}>
          <GlassCard className="p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-semibold">Localização dos Veículos</h2>
              <MapPin className="w-5 h-5 text-primary" />
            </div>
            <div className="bg-surface rounded-xl h-64 flex items-center justify-center">
              <p className="text-gray-500">Mapa ao vivo disponível na página Mapa</p>
            </div>
          </GlassCard>
        </motion.div>
      </motion.div>
    </DashboardLayout>
  );
};
