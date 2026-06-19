import { motion } from 'framer-motion';

interface StatusIndicatorProps {
  status: 'online' | 'offline' | 'warning' | 'error';
  label?: string;
  pulse?: boolean;
}

export const StatusIndicator = ({ status, label, pulse = false }: StatusIndicatorProps) => {
  const colors = {
    online: 'bg-online',
    offline: 'bg-offline',
    warning: 'bg-warning',
    error: 'bg-error',
  };

  return (
    <div className="flex items-center gap-2">
      <div className="relative">
        <div className={`w-2.5 h-2.5 rounded-full ${colors[status]}`} />
        {pulse && status === 'online' && (
          <motion.div
            className={`absolute inset-0 w-2.5 h-2.5 rounded-full ${colors[status]}`}
            animate={{ scale: [1, 2], opacity: [0.5, 0] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          />
        )}
      </div>
      {label && <span className="text-sm text-gray-400 capitalize">{label}</span>}
    </div>
  );
};
