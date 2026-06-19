import { NavLink } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  LayoutDashboard,
  Car as CarIcon,
  Map,
  Bell,
  Users,
  CreditCard,
  LogOut,
} from 'lucide-react';
import { useAuthStore } from '../../store/authStore';
import { useFleetStore } from '../../store/fleetStore';

const navItems = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/fleet', icon: CarIcon, label: 'Frota' },
  { to: '/map', icon: Map, label: 'Mapa' },
  { to: '/alerts', icon: Bell, label: 'Alertas' },
  { to: '/drivers', icon: Users, label: 'Motoristas' },
  { to: '/billing', icon: CreditCard, label: 'Planos' },
];

export const Sidebar = () => {
  const { logout } = useAuthStore();
  const { unreadAlertsCount } = useFleetStore();

  return (
    <motion.aside
      initial={{ x: -100, opacity: 0 }}
      animate={{ x: 0, opacity: 1 }}
      className="fixed left-0 top-0 h-full w-64 bg-surface/80 backdrop-blur-xl border-r border-white/10 z-40 flex flex-col"
    >
      {/* Logo */}
      <div className="p-6 border-b border-white/10">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary rounded-xl flex items-center justify-center">
            <CarIcon className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="font-bold text-lg">BYD Connect</h1>
            <p className="text-xs text-gray-500">Fleet Management</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map(({ to, icon: Icon, label }) => (
          <NavLink
            key={to}
            to={to}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-3 rounded-xl transition-colors ${
                isActive
                  ? 'bg-primary/20 text-primary border border-primary/30'
                  : 'text-gray-400 hover:text-white hover:bg-white/5'
              }`
            }
          >
            <Icon className="w-5 h-5" />
            <span className="font-medium">{label}</span>
            {label === 'Alertas' && unreadAlertsCount > 0 && (
              <span className="ml-auto bg-error text-white text-xs font-bold px-2 py-0.5 rounded-full">
                {unreadAlertsCount}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      {/* Logout */}
      <div className="p-4 border-t border-white/10">
        <button
          onClick={logout}
          className="flex items-center gap-3 px-4 py-3 w-full text-gray-400 hover:text-white hover:bg-white/5 rounded-xl transition-colors"
        >
          <LogOut className="w-5 h-5" />
          <span className="font-medium">Sair</span>
        </button>
      </div>
    </motion.aside>
  );
};
