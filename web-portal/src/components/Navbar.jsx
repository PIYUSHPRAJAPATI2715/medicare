import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Globe, Bell, Shield, Stethoscope, RefreshCw, Menu } from 'lucide-react';

export default function Navbar({ onToggleMobileMenu }) {
  const { user, login } = useAuth();
  const navigate = useNavigate();
  const isAdmin = user?.role === 'admin';

  return (
    <header className="h-16 bg-white border-b border-slate-200 px-4 sm:px-6 flex items-center justify-between sticky top-0 z-30 shadow-sm">
      <div className="flex items-center gap-2 sm:gap-3">
        {/* Mobile Menu Hamburger Button */}
        <button
          onClick={onToggleMobileMenu}
          className="md:hidden p-2 rounded-xl text-slate-600 hover:bg-slate-100 transition border border-slate-200"
          aria-label="Toggle navigation menu"
        >
          <Menu className="w-5 h-5 text-slate-700" />
        </button>

        <div className="flex items-center gap-1.5 px-2.5 py-1 bg-slate-100 rounded-lg text-xs font-semibold text-slate-700">
          <Globe className="w-3.5 h-3.5 text-blue-600" />
          <span className="truncate max-w-[120px] sm:max-w-none">drconnects24.com</span>
        </div>
        <span className="hidden sm:inline text-xs text-slate-400 font-medium">|</span>
        <span className="hidden lg:inline text-xs font-bold text-slate-600">
          {isAdmin ? 'System Governance & Document Verification' : 'Doctor Portal & HD Live Consultations'}
        </span>
      </div>

      <div className="flex items-center gap-2 sm:gap-3">
        {/* Quick Role Switcher Button */}
        <button
          onClick={() => {
            const nextRole = isAdmin ? 'doctor' : 'admin';
            login(nextRole);
            navigate(nextRole === 'doctor' ? '/doctor/dashboard' : '/admin/dashboard');
          }}
          className="flex items-center gap-1 sm:gap-1.5 px-2.5 sm:px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-bold transition border border-slate-200"
          title="Switch view mode between Doctor and Admin"
        >
          <RefreshCw className="w-3.5 h-3.5 text-blue-600" />
          <span className="hidden sm:inline">Switch to {isAdmin ? 'Doctor View' : 'Admin View'}</span>
          <span className="sm:hidden">{isAdmin ? 'Doctor' : 'Admin'}</span>
        </button>

        <div className="hidden sm:block w-px h-6 bg-slate-200" />

        {/* Notifications */}
        <button className="p-2 rounded-lg text-slate-500 hover:bg-slate-100 relative transition">
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-blue-600 rounded-full ring-2 ring-white" />
        </button>

        {/* User Info Badge */}
        <div className="flex items-center gap-2 pl-1 sm:pl-2">
          <img
            src={user?.avatarUrl || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'}
            alt={user?.name || 'User'}
            className="w-8 h-8 rounded-full object-cover ring-2 ring-slate-200"
            onError={(e) => {
              e.currentTarget.src = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400';
            }}
          />
          <div className="hidden lg:block text-left">
            <p className="text-xs font-bold text-slate-800 leading-none">{user?.name}</p>
            <span className={`text-[10px] font-bold ${isAdmin ? 'text-amber-600' : 'text-blue-600'}`}>
              {isAdmin ? 'Administrator' : 'Verified Doctor'}
            </span>
          </div>
        </div>
      </div>
    </header>
  );
}

