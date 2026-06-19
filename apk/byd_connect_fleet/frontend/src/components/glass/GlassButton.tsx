import { motion } from 'framer-motion';
import type { ReactNode, ButtonHTMLAttributes } from 'react';

interface GlassButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  variant?: 'primary' | 'secondary' | 'danger' | 'success';
  size?: 'sm' | 'md' | 'lg';
}

export const GlassButton = ({
  children,
  variant = 'secondary',
  size = 'md',
  className = '',
  ...props
}: GlassButtonProps) => {
  const baseStyles = 'font-medium rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed';

  const variants = {
    primary: 'bg-primary hover:bg-primary/80 text-white',
    secondary: 'bg-surface/60 hover:bg-surface/80 border border-white/10 text-white',
    danger: 'bg-error/20 hover:bg-error/30 border border-error/30 text-error',
    success: 'bg-online/20 hover:bg-online/30 border border-online/30 text-online',
  };

  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2',
    lg: 'px-6 py-3 text-lg',
  };

  return (
    <motion.button
      className={`${baseStyles} ${variants[variant]} ${sizes[size]} ${className}`}
      whileTap={{ scale: 0.95 }}
      {...(props as any)}
    >
      {children}
    </motion.button>
  );
};
