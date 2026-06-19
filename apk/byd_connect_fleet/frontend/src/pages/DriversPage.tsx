import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { motion } from 'framer-motion';
import { Users, Plus, Edit2, Trash2, Phone, Car, X } from 'lucide-react';
import { driversApi } from '../api/driversApi';
import { GlassCard } from '../components/glass/GlassCard';
import { GlassButton } from '../components/glass/GlassButton';
import { GlassInput } from '../components/glass/GlassInput';
import { DashboardLayout } from '../components/layout/DashboardLayout';
import toast from 'react-hot-toast';

export const DriversPage = () => {
  const queryClient = useQueryClient();
  const [showModal, setShowModal] = useState(false);
  const [editingDriver, setEditingDriver] = useState<any>(null);

  const { data: drivers = [], isLoading } = useQuery({
    queryKey: ['drivers'],
    queryFn: driversApi.getAll,
  });

  const createMutation = useMutation({
    mutationFn: driversApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['drivers'] });
      setShowModal(false);
      setEditingDriver(null);
      toast.success('Motorista criado com sucesso');
    },
    onError: () => toast.error('Erro ao criar motorista'),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => driversApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['drivers'] });
      setShowModal(false);
      setEditingDriver(null);
      toast.success('Motorista atualizado');
    },
    onError: () => toast.error('Erro ao atualizar'),
  });

  const deleteMutation = useMutation({
    mutationFn: driversApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['drivers'] });
      toast.success('Motorista removido');
    },
    onError: () => toast.error('Erro ao remover'),
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const data = {
      name: formData.get('name') as string,
      email: formData.get('email') as string,
      phone: formData.get('phone') as string,
      cpf: formData.get('cpf') as string,
      licenseNumber: formData.get('licenseNumber') as string,
    };

    if (editingDriver) {
      updateMutation.mutate({ id: editingDriver.id, data });
    } else {
      createMutation.mutate(data);
    }
  };

  return (
    <DashboardLayout>
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Motoristas</h1>
            <p className="text-gray-500 mt-1">{drivers.length} motoristas cadastrados</p>
          </div>

          <GlassButton
            variant="primary"
            onClick={() => { setEditingDriver(null); setShowModal(true); }}
            className="flex items-center gap-2"
          >
            <Plus className="w-4 h-4" />
            Novo Motorista
          </GlassButton>
        </div>

        {isLoading ? (
          <div className="text-center py-12 text-gray-500">Carregando...</div>
        ) : drivers.length === 0 ? (
          <GlassCard className="p-12 text-center">
            <Users className="w-16 h-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold">Nenhum motorista</h3>
            <p className="text-gray-500 mt-2">Cadastre seu primeiro motorista</p>
          </GlassCard>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {drivers.map((driver) => (
              <motion.div key={driver.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
                <GlassCard className="p-5 space-y-4">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-accent/20 rounded-full flex items-center justify-center">
                      <span className="text-accent font-bold text-lg">{driver.name.charAt(0)}</span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold truncate">{driver.name}</h3>
                      <p className="text-sm text-gray-500 truncate">{driver.email}</p>
                    </div>
                  </div>

                  <div className="space-y-2 text-sm">
                    {driver.phone && (
                      <div className="flex items-center gap-2 text-gray-400">
                        <Phone className="w-4 h-4" />
                        <span>{driver.phone}</span>
                      </div>
                    )}
                    <div className="flex items-center gap-2 text-gray-400">
                      <Car className="w-4 h-4" />
                      <span>{driver.cars?.length || 0} veículo(s) atribuído(s)</span>
                    </div>
                  </div>

                  <div className="flex gap-2 pt-2">
                    <GlassButton
                      size="sm"
                      variant="secondary"
                      onClick={() => { setEditingDriver(driver); setShowModal(true); }}
                      className="flex-1"
                    >
                      <Edit2 className="w-4 h-4" />
                    </GlassButton>
                    <GlassButton
                      size="sm"
                      variant="danger"
                      onClick={() => deleteMutation.mutate(driver.id)}
                      className="flex-1"
                    >
                      <Trash2 className="w-4 h-4" />
                    </GlassButton>
                  </div>
                </GlassCard>
              </motion.div>
            ))}
          </div>
        )}
      </motion.div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-surface border border-white/10 rounded-2xl w-full max-w-md p-6"
          >
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold">
                {editingDriver ? 'Editar Motorista' : 'Novo Motorista'}
              </h2>
              <button onClick={() => setShowModal(false)} className="p-2 hover:bg-white/10 rounded-lg">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <GlassInput label="Nome" name="name" defaultValue={editingDriver?.name} required />
              <GlassInput label="Email" name="email" type="email" defaultValue={editingDriver?.email} required />
              <GlassInput label="Telefone" name="phone" defaultValue={editingDriver?.phone} />
              <GlassInput label="CPF" name="cpf" defaultValue={editingDriver?.cpf} required />
              <GlassInput label="CNH" name="licenseNumber" defaultValue={editingDriver?.licenseNumber} />

              <div className="flex gap-3 pt-4">
                <GlassButton type="button" variant="secondary" onClick={() => setShowModal(false)} className="flex-1">
                  Cancelar
                </GlassButton>
                <GlassButton type="submit" variant="primary" className="flex-1">
                  {editingDriver ? 'Salvar' : 'Criar'}
                </GlassButton>
              </div>
            </form>
          </motion.div>
        </div>
      )}
    </DashboardLayout>
  );
};
