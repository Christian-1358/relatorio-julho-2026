import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { motion } from 'framer-motion';
import { Check, Star, Zap } from 'lucide-react';
import { billingApi } from '../api/billingApi';
import { GlassCard } from '../components/glass/GlassCard';
import { GlassButton } from '../components/glass/GlassButton';
import { DashboardLayout } from '../components/layout/DashboardLayout';
import toast from 'react-hot-toast';

export const BillingPage = () => {
  const queryClient = useQueryClient();

  const { data: plans = [], isLoading: plansLoading } = useQuery({
    queryKey: ['plans'],
    queryFn: billingApi.getPlans,
  });

  const { data: subscription } = useQuery({
    queryKey: ['subscription'],
    queryFn: billingApi.getSubscription,
  });

  const subscribeMutation = useMutation({
    mutationFn: billingApi.subscribe,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subscription'] });
      toast.success('Assinatura atualizada com sucesso!');
    },
    onError: () => toast.error('Erro ao processar assinatura'),
  });

  const cancelMutation = useMutation({
    mutationFn: billingApi.cancelSubscription,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subscription'] });
      toast.success('Assinatura cancelada');
    },
    onError: () => toast.error('Erro ao cancelar'),
  });

  const currentPlan = subscription?.plan;
  const isCurrentPlan = (planId: string) => subscription?.planId === planId;

  return (
    <DashboardLayout>
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-8">
        <div>
          <h1 className="text-3xl font-bold">Planos</h1>
          <p className="text-gray-500 mt-1">Escolha o plano ideal para sua frota</p>
        </div>

        {/* Current Subscription */}
        {subscription && (
          <GlassCard className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">Plano Atual</p>
                <h3 className="text-2xl font-bold mt-1">{currentPlan?.name}</h3>
                <p className="text-gray-400 mt-1">
                  {subscription.status === 'ACTIVE' ? 'Ativo' : subscription.status}
                </p>
              </div>
              <div className="text-right">
                <p className="text-2xl font-bold">R$ {currentPlan?.price}</p>
                <p className="text-gray-500">/mês</p>
              </div>
            </div>
            {subscription.status === 'ACTIVE' && (
              <div className="mt-4 pt-4 border-t border-white/10 flex justify-between items-center">
                <p className="text-sm text-gray-500">
                  Vencimento: {subscription.expiresAt && new Date(subscription.expiresAt).toLocaleDateString('pt-BR')}
                </p>
                <GlassButton
                  variant="danger"
                  size="sm"
                  onClick={() => cancelMutation.mutate(subscription.id)}
                >
                  Cancelar Assinatura
                </GlassButton>
              </div>
            )}
          </GlassCard>
        )}

        {/* Plans */}
        {plansLoading ? (
          <div className="text-center py-12 text-gray-500">Carregando planos...</div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {plans.map((plan, index) => {
              const isCurrent = isCurrentPlan(plan.id);
              const isPopular = plan.name === 'Professional';

              return (
                <motion.div
                  key={plan.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.1 }}
                >
                  <GlassCard className={`p-6 relative ${isPopular ? 'border-primary/50' : ''}`}>
                    {isPopular && (
                      <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-primary text-white text-xs font-bold px-3 py-1 rounded-full flex items-center gap-1">
                        <Star className="w-3 h-3" />
                        Mais Popular
                      </div>
                    )}

                    <div className="text-center mb-6">
                      <h3 className="text-xl font-bold">{plan.name}</h3>
                      <p className="text-gray-500 text-sm mt-1">{plan.description}</p>
                      <div className="mt-4">
                        <span className="text-4xl font-bold">R$ {plan.price}</span>
                        <span className="text-gray-500">/mês</span>
                      </div>
                    </div>

                    <div className="space-y-3 mb-6">
                      <div className="flex items-center gap-2 text-sm">
                        <Check className="w-4 h-4 text-online" />
                        <span>Até {plan.maxCars} veículos</span>
                      </div>
                      {(typeof plan.features === 'string' ? JSON.parse(plan.features) : plan.features).map((feature: string) => (
                        <div key={feature} className="flex items-center gap-2 text-sm">
                          <Check className="w-4 h-4 text-online" />
                          <span>{feature}</span>
                        </div>
                      ))}
                    </div>

                    <GlassButton
                      variant={isCurrent ? 'secondary' : isPopular ? 'primary' : 'secondary'}
                      className="w-full"
                      disabled={isCurrent}
                      onClick={() => subscribeMutation.mutate(plan.id)}
                    >
                      {isCurrent ? 'Plano Atual' : 'Assinar'}
                    </GlassButton>
                  </GlassCard>
                </motion.div>
              );
            })}
          </div>
        )}

        {/* Features Comparison Note */}
        <GlassCard className="p-6 text-center">
          <Zap className="w-8 h-8 text-warning mx-auto mb-3" />
          <h3 className="font-semibold">Precisa de mais?</h3>
          <p className="text-gray-500 text-sm mt-1">
            Entre em contato para planos personalizados para frotas maiores
          </p>
          <GlassButton variant="secondary" className="mt-4">
            Falar com Vendas
          </GlassButton>
        </GlassCard>
      </motion.div>
    </DashboardLayout>
  );
};
