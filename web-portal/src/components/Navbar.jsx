import React from 'react';
import { useAuth } from '../context/AuthContext';
import { Globe, Bell, Shield, Stethoscope, RefreshCw } from 'lucide-react';

export default function Navbar() {
  const { user, login } = useAuth();
  const isAdmin = user?.role === 'admin';

  return (
    <header className="h-16 bg-white border-b border-slate-200 px-6 flex items-center justify-between sticky top-0 z-30 shadow-sm">
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2 px-3 py-1 bg-slate-100 rounded-lg text-xs font-semibold text-slate-700">
          <Globe className="w-3.5 h-3.5 text-blue-600" />
          <span>drconnects24.com</span>
        </div>
        <span className="hidden sm:inline text-xs text-slate-400 font-medium">|</span>
        <span className="hidden sm:inline text-xs font-bold text-slate-600">
          {isAdmin ? 'System Governance & Document Verification' : 'Doctor Portal & HD Live Consultations'}
        </span>
      </div>

      <div className="flex items-center gap-3">
        {/* Quick Role Switcher Button */}
        <button
          onClick={() => login(isAdmin ? 'doctor' : 'admin')}
          className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-bold transition border border-slate-200"
          title="Switch view mode between Doctor and Admin"
        >
          <RefreshCw className="w-3.5 h-3.5 text-blue-600" />
          <span>Switch to {isAdmin ? 'Doctor View' : 'Admin View'}</span>
        </button>

        <div className="w-px h-6 bg-slate-200" />

        {/* Notifications */}
        <button className="p-2 rounded-lg text-slate-500 hover:bg-slate-100 relative transition">
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-blue-600 rounded-full ring-2 ring-white" />
        </button>

        {/* User Info Badge */}
        <div className="flex items-center gap-2 pl-2">
          <img
            src={user?.avatarUrl}
            alt={user?.name}
            className="w-8 h-8 rounded-full object-cover ring-2 ring-slate-200"
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
