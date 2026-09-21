import React, { useState } from 'react';
import { LayoutDashboard, Users, Stethoscope, Layers, Building2, CalendarCheck, Settings, ShieldCheck, Activity } from 'lucide-react';
import DashboardPage from './pages/DashboardPage';
import UsersPage from './pages/UsersPage';
import DoctorsPage from './pages/DoctorsPage';
import SpecialtiesPage from './pages/SpecialtiesPage';
import HospitalsPage from './pages/HospitalsPage';
import AppointmentsPage from './pages/AppointmentsPage';
import SettingsPage from './pages/SettingsPage';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

  const navItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'users', label: 'Users', icon: Users },
    { id: 'doctors', label: 'Doctors', icon: Stethoscope },
    { id: 'specialties', label: 'Specialties', icon: Layers },
    { id: 'hospitals', label: 'Hospitals', icon: Building2 },
    { id: 'appointments', label: 'Appointments', icon: CalendarCheck },
    { id: 'settings', label: 'App Config & Fees', icon: Settings },
  ];

  return (
    <div className="flex h-screen bg-slate-50 font-sans overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col border-r border-slate-800 shrink-0">
        <div className="p-5 flex items-center gap-3 border-b border-slate-800">
          <div className="w-9 h-9 bg-blue-600 rounded-xl flex items-center justify-center text-white font-extrabold shadow-lg shadow-blue-500/30">
            M+
          </div>
          <div>
            <h1 className="font-extrabold text-white text-base leading-tight">MediCare+</h1>
            <p className="text-xs text-blue-400 font-medium">Admin Control Panel</p>
          </div>
        </div>

        <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`w-full flex items-center gap-3 px-3.5 py-3 rounded-xl font-bold text-sm transition-all ${
                  isActive
                    ? 'bg-blue-600 text-white shadow-md shadow-blue-600/30'
                    : 'text-slate-400 hover:bg-slate-800/80 hover:text-slate-200'
                }`}
              >
                <Icon className="w-5 h-5" />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>

        <div className="p-4 border-t border-slate-800">
          <div className="bg-slate-800/60 p-3 rounded-xl flex items-center gap-3">
            <ShieldCheck className="w-8 h-8 text-emerald-400" />
            <div>
              <p className="text-xs font-bold text-white">System Status</p>
              <p className="text-[11px] text-emerald-400 font-semibold flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span> Backend Port 5050
              </p>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <header className="h-16 bg-white border-b border-slate-200/80 px-6 flex items-center justify-between shrink-0">
          <h2 className="text-base font-extrabold text-slate-800 capitalize">
            {activeTab} Management
          </h2>
          <div className="flex items-center gap-3">
            <div className="text-right">
              <p className="text-xs font-bold text-slate-900">Administrator</p>
              <p className="text-[11px] text-slate-400">admin@medicare.com</p>
            </div>
            <div className="w-9 h-9 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center border border-blue-200">
              AD
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto p-6">
          {activeTab === 'dashboard' && <DashboardPage />}
          {activeTab === 'users' && <UsersPage />}
          {activeTab === 'doctors' && <DoctorsPage />}
          {activeTab === 'specialties' && <SpecialtiesPage />}
          {activeTab === 'hospitals' && <HospitalsPage />}
          {activeTab === 'appointments' && <AppointmentsPage />}
          {activeTab === 'settings' && <SettingsPage />}
        </div>
      </main>
    </div>
  );
}
