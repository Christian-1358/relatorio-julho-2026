import { Bell, User, Menu } from 'lucide-react';
import { useFleetStore } from '../../store/fleetStore';
import { useUIStore } from '../../store/uiStore';

export const Header = () => {
  const { unreadAlertsCount } = useFleetStore();
  const { toggleSidebar } = useUIStore();

  return (
    <header className="h-16 bg-surface/80 backdrop-blur-xl border-b border-white/10 px-6 flex items-center justify-between sticky top-0 z-30">
      <button
        onClick={toggleSidebar}
        className="p-2 hover:bg-white/5 rounded-lg transition-colors lg:hidden"
      >
        <Menu className="w-5 h-5" />
      </button>

      <div className="flex items-center gap-4 ml-auto">
        <button className="relative p-2 hover:bg-white/5 rounded-lg transition-colors">
          <Bell className="w-5 h-5 text-gray-400" />
          {unreadAlertsCount > 0 && (
            <span className="absolute -top-1 -right-1 w-5 h-5 bg-error text-white text-xs font-bold rounded-full flex items-center justify-center">
              {unreadAlertsCount > 9 ? '9+' : unreadAlertsCount}
            </span>
          )}
        </button>

        <div className="flex items-center gap-3 pl-4 border-l border-white/10">
          <div className="w-8 h-8 bg-primary/20 rounded-full flex items-center justify-center">
            <User className="w-4 h-4 text-primary" />
          </div>
          <div className="hidden sm:block">
            <p className="text-sm font-medium">Admin User</p>
            <p className="text-xs text-gray-500">admin@bydfleet.com</p>
          </div>
        </div>
      </div>
    </header>
  );
};
