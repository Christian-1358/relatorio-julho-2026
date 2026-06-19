import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { motion } from 'framer-motion';
import { Check, CheckCheck, AlertCircle, Info, AlertTriangle, Shield } from 'lucide-react';
import { alertsApi } from '../api/alertsApi';
import { GlassCard } from '../components/glass/GlassCard';
import { GlassButton } from '../components/glass/GlassButton';
import { DashboardLayout } from '../components/layout/DashboardLayout';
import toast from 'react-hot-toast';

const severityConfig = {
  CRITICAL: { icon: AlertCircle, color: 'text-error', bg: 'bg-error/20' },
  ERROR: { icon: AlertCircle, color: 'text-error', bg: 'bg-error/20' },
  WARNING: { icon: AlertTriangle, color: 'text-warning', bg: 'bg-warning/20' },
  INFO: { icon: Info, color: 'text-primary', bg: 'bg-primary/20' },
};

const typeLabels: Record<string, string> = {
  MOTION: 'Movimento',
  DOOR: 'Porta',
  ALARM: 'Alarme',
  BATTERY: 'Bateria',
  TEMPERATURE: 'Temperatura',
  SPEED: 'Velocidade',
  GEOFENCE: 'Geofence',
  MAINTENANCE: 'Manutenção',
};

export const AlertsPage = () => {
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['alerts'],
    queryFn: () => alertsApi.getAll({ limit: 50 }),
    refetchInterval: 10000,
  });

  const markAllMutation = useMutation({
    mutationFn: () => alertsApi.markAllAsRead(),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alerts'] });
      toast.success('Todos os alertas marcados como lidos');
    },
  });

  const markReadMutation = useMutation({
    mutationFn: (id: string) => alertsApi.markAsRead(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alerts'] });
    },
  });

  const alerts = data?.alerts || [];
  const unreadCount = alerts.filter((a) => !a.isRead).length;

  return (
    <DashboardLayout>
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Alertas</h1>
            <p className="text-gray-500 mt-1">
              {unreadCount > 0 ? `${unreadCount} não lidos` : 'Todos os alertas foram lidos'}
            </p>
          </div>

          {unreadCount > 0 && (
            <GlassButton
              variant="secondary"
              onClick={() => markAllMutation.mutate()}
              className="flex items-center gap-2"
            >
              <CheckCheck className="w-4 h-4" />
              Marcar todos como lidos
            </GlassButton>
          )}
        </div>

        {isLoading ? (
          <div className="text-center py-12 text-gray-500">Carregando alertas...</div>
        ) : alerts.length === 0 ? (
          <GlassCard className="p-12 text-center">
            <Shield className="w-16 h-16 text-online mx-auto mb-4" />
            <h3 className="text-xl font-semibold">Nenhum alerta</h3>
            <p className="text-gray-500 mt-2">Sua frota está tranquila!</p>
          </GlassCard>
        ) : (
          <div className="space-y-3">
            {alerts.map((alert) => {
              const config = severityConfig[alert.severity];
              const Icon = config.icon;

              return (
                <motion.div
                  key={alert.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                >
                  <GlassCard
                    className={`p-4 transition-opacity ${alert.isRead ? 'opacity-60' : ''}`}
                  >
                    <div className="flex items-start gap-4">
                      <div className={`w-10 h-10 ${config.bg} rounded-xl flex items-center justify-center flex-shrink-0`}>
                        <Icon className={`w-5 h-5 ${config.color}`} />
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <h3 className="font-semibold">{alert.title}</h3>
                          {!alert.isRead && (
                            <span className="w-2 h-2 bg-primary rounded-full" />
                          )}
                        </div>
                        <p className="text-sm text-gray-500 mt-1">{alert.description}</p>
                        <div className="flex items-center gap-4 mt-2 text-xs text-gray-600">
                          <span>{typeLabels[alert.type] || alert.type}</span>
                          <span>•</span>
                          <span>
                            {new Date(alert.createdAt).toLocaleString('pt-BR', {
                              day: '2-digit',
                              month: '2-digit',
                              hour: '2-digit',
                              minute: '2-digit',
                            })}
                          </span>
                        </div>
                      </div>

                      {!alert.isRead && (
                        <GlassButton
                          size="sm"
                          variant="secondary"
                          onClick={() => markReadMutation.mutate(alert.id)}
                          className="flex-shrink-0"
                        >
                          <Check className="w-4 h-4" />
                        </GlassButton>
                      )}
                    </div>
                  </GlassCard>
                </motion.div>
              );
            })}
          </div>
        )}
      </motion.div>
    </DashboardLayout>
  );
};
