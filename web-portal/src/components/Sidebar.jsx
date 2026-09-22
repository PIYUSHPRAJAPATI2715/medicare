import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  LayoutDashboard,
  Users,
  UserCheck,
  Stethoscope,
  Building2,
  Calendar,
  Settings,
  Video,
  LogOut,
  ShieldCheck,
  Activity,
  ClipboardList
} from 'lucide-react';

export default function Sidebar() {
  const { user, logout } = useAuth();
  const isAdmin = user?.role === 'admin';

  const adminNav = [
    { name: 'Dashboard', path: '/admin/dashboard', icon: LayoutDashboard },
    { name: 'Doctors & Approvals', path: '/admin/doctors', icon: UserCheck, badge: 'New Doc Verification' },
    { name: 'Patients', path: '/admin/users', icon: Users },
    { name: 'Specialties', path: '/admin/specialties', icon: Stethoscope },
    { name: 'Hospitals', path: '/admin/hospitals', icon: Building2 },
    { name: 'Appointments', path: '/admin/appointments', icon: Calendar },
    { name: 'Settings', path: '/admin/settings', icon: Settings },
  ];

  const doctorNav = [
    { name: 'My Dashboard', path: '/doctor/dashboard', icon: LayoutDashboard },
    { name: 'Patient Queue', path: '/doctor/appointments', icon: ClipboardList },
    { name: 'Video Consult Room', path: '/doctor/video-call/consult-live', icon: Video, badge: 'HD Agora' },
  ];

  const navItems = isAdmin ? adminNav : doctorNav;

  return (
    <aside className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col justify-between hidden md:flex min-h-screen">
      <div>
        {/* Brand Header */}
        <div className="p-5 border-b border-slate-800 flex items-center gap-3">
          <div className={`p-2.5 rounded-xl text-white ${isAdmin ? 'bg-amber-600' : 'bg-blue-600'}`}>
            {isAdmin ? <ShieldCheck className="w-5 h-5" /> : <Stethoscope className="w-5 h-5" />}
          </div>
          <div>
            <h2 className="text-base font-extrabold text-white tracking-tight">drconnects24</h2>
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 bg-slate-800 px-2 py-0.5 rounded">
              {isAdmin ? 'Admin Control' : 'Doctor Portal'}
            </span>
          </div>
        </div>

        {/* Navigation Items */}
        <nav className="p-4 space-y-1.5">
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) =>
                  `flex items-center justify-between px-3.5 py-3 rounded-xl text-xs font-bold transition-all ${
                    isActive
                      ? isAdmin
                        ? 'bg-amber-600/20 text-amber-400 border border-amber-500/30'
                        : 'bg-blue-600/20 text-blue-400 border border-blue-500/30'
                      : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
                  }`
                }
              >
                <div className="flex items-center gap-3">
                  <Icon className="w-4 h-4" />
                  <span>{item.name}</span>
                </div>
                {item.badge && (
                  <span className="text-[9px] font-extrabold px-1.5 py-0.5 rounded bg-blue-500/20 text-blue-300 border border-blue-400/30">
                    {item.badge}
                  </span>
                )}
              </NavLink>
            );
          })}
        </nav>
      </div>

      {/* User Profile Footer */}
      <div className="p-4 border-t border-slate-800">
        <div className="flex items-center gap-3 p-2 bg-slate-950/60 rounded-xl border border-slate-800 mb-3">
          <img
            src={user?.avatarUrl}
            alt={user?.name}
            className="w-9 h-9 rounded-lg object-cover border border-slate-700"
          />
          <div className="overflow-hidden">
            <p className="text-xs font-bold text-white truncate">{user?.name}</p>
            <p className="text-[10px] text-slate-400 truncate">{user?.email}</p>
          </div>
        </div>

        <button
          onClick={logout}
          className="w-full flex items-center justify-center gap-2 py-2.5 px-3 bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/30 rounded-xl text-xs font-bold transition"
        >
          <LogOut className="w-3.5 h-3.5" />
          Sign Out
        </button>
      </div>
    </aside>
  );
}
