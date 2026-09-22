import React from 'react';
import { Users, UserCheck, Stethoscope, Building2, Calendar, TrendingUp, DollarSign, Award } from 'lucide-react';

export default function AdminDashboardPage() {
  const stats = [
    { title: 'Total Verified Doctors', value: '42', change: '+12% this month', icon: UserCheck, color: 'bg-blue-500' },
    { title: 'Pending Registration Approvals', value: '3', change: 'Requires document review', icon: Award, color: 'bg-amber-500' },
    { title: 'Registered Patients', value: '1,280', change: '+18% this month', icon: Users, color: 'bg-emerald-500' },
    { title: 'Platform Consultations', value: '3,450', change: '+24% this week', icon: Calendar, color: 'bg-indigo-500' },
  ];

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-gradient-to-r from-slate-900 to-slate-800 text-white rounded-2xl p-6 shadow-xl border border-slate-700/50 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <span className="text-xs font-bold text-amber-400 uppercase tracking-widest bg-amber-400/10 px-2.5 py-1 rounded-md border border-amber-400/20">
            System Administration
          </span>
          <h1 className="text-2xl font-black mt-2 tracking-tight">drconnects24.com Governance Center</h1>
          <p className="text-slate-400 text-xs mt-1 font-medium">Manage doctors, document verification, patient records & platform analytics</p>
        </div>
        <div className="flex gap-2">
          <div className="bg-slate-800/80 border border-slate-700 rounded-xl px-4 py-2 text-right">
            <p className="text-[10px] text-slate-400 font-bold uppercase">System Status</p>
            <p className="text-xs font-bold text-emerald-400 flex items-center justify-end gap-1">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" /> Live Healthy
            </p>
          </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((s) => {
          const Icon = s.icon;
          return (
            <div key={s.title} className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
              <div className={`p-3 rounded-xl text-white ${s.color}`}>
                <Icon className="w-6 h-6" />
              </div>
              <div>
                <p className="text-xs font-semibold text-slate-500">{s.title}</p>
                <h3 className="text-xl font-extrabold text-slate-900 mt-0.5">{s.value}</h3>
                <p className="text-[11px] font-bold text-emerald-600 mt-0.5">{s.change}</p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Quick Action Banner */}
      <div className="bg-amber-50 border border-amber-200 rounded-2xl p-5 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Award className="w-8 h-8 text-amber-600" />
          <div>
            <h4 className="text-sm font-bold text-amber-900">3 Doctors awaiting license verification</h4>
            <p className="text-xs text-amber-700">Review degree credentials, MCI state council registration, and identity proofs.</p>
          </div>
        </div>
        <a
          href="/admin/doctors"
          className="px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white rounded-xl text-xs font-bold transition shadow-sm"
        >
          Review Applications
        </a>
      </div>
    </div>
  );
}
