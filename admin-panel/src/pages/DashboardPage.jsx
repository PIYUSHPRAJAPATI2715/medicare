import React, { useEffect, useState } from 'react';
import { Users, Stethoscope, Building2, CalendarCheck, IndianRupee, Activity, TrendingUp } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from 'recharts';
import { apiService } from '../services/api';

export default function DashboardPage() {
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    const res = await apiService.getAnalytics();
    if (res.success) {
      setAnalytics(res.data);
    }
    setLoading(false);
  };

  if (loading) {
    return <div className="p-8 text-slate-500 font-medium">Loading Dashboard Analytics...</div>;
  }

  const statCards = [
    { label: 'Total Patients', value: analytics?.totalUsers || 0, icon: Users, color: 'bg-blue-500', light: 'bg-blue-50 text-blue-600' },
    { label: 'Verified Doctors', value: analytics?.totalDoctors || 0, icon: Stethoscope, color: 'bg-emerald-500', light: 'bg-emerald-50 text-emerald-600' },
    { label: 'Partner Hospitals', value: analytics?.totalHospitals || 0, icon: Building2, color: 'bg-sky-500', light: 'bg-sky-50 text-sky-600' },
    { label: 'Total Revenue', value: `₹${(analytics?.totalRevenue || 0).toLocaleString()}`, icon: IndianRupee, color: 'bg-indigo-500', light: 'bg-indigo-50 text-indigo-600' },
  ];

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="bg-gradient-to-r from-blue-700 via-blue-600 to-indigo-700 rounded-2xl p-6 text-white shadow-lg shadow-blue-500/10 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <span className="px-3 py-1 bg-white/20 rounded-full text-xs font-semibold uppercase tracking-wider text-white">System Admin Portal</span>
          <h1 className="text-2xl font-bold mt-2">MediCare+ Global Control Center</h1>
          <p className="text-blue-100 text-sm mt-1">Manage users, doctors, specialties, verified hospitals, dynamic settings, and Agora video consultations.</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 bg-emerald-500/20 text-emerald-300 px-4 py-2 rounded-xl text-sm font-semibold border border-emerald-400/30">
            <span className="w-2.5 h-2.5 bg-emerald-400 rounded-full animate-ping"></span>
            Agora API Active
          </div>
        </div>
      </div>

      {/* Stats Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {statCards.map((card, idx) => {
          const Icon = card.icon;
          return (
            <div key={idx} className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
              <div>
                <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider">{card.label}</p>
                <h3 className="text-2xl font-extrabold text-slate-900 mt-1">{card.value}</h3>
              </div>
              <div className={`p-3.5 rounded-2xl ${card.light}`}>
                <Icon className="w-6 h-6" />
              </div>
            </div>
          );
        })}
      </div>

      {/* Analytics Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Monthly Revenue Chart */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 border border-slate-200/80 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-base font-bold text-slate-900">Revenue & Booking Trends</h2>
              <p className="text-xs text-slate-500 mt-0.5">Monthly platform earnings growth</p>
            </div>
            <div className="flex items-center gap-1 text-xs font-bold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-lg">
              <TrendingUp className="w-3.5 h-3.5" />
              +28% Growth
            </div>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={analytics?.revenueMonthly || []}>
                <defs>
                  <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#1a56db" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#1a56db" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="month" stroke="#94a3b8" fontSize={12} />
                <YAxis stroke="#94a3b8" fontSize={12} />
                <Tooltip />
                <Area type="monotone" dataKey="revenue" stroke="#1a56db" strokeWidth={3} fillOpacity={1} fill="url(#colorRev)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Specialty Distribution */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-sm">
          <div className="mb-6">
            <h2 className="text-base font-bold text-slate-900">Doctors by Specialty</h2>
            <p className="text-xs text-slate-500 mt-0.5">Specialist coverage across network</p>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={analytics?.specialtyDistribution || []}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" stroke="#94a3b8" fontSize={10} tickFormatter={(v) => v.split(' ')[0]} />
                <YAxis stroke="#94a3b8" fontSize={12} />
                <Tooltip />
                <Bar dataKey="doctors" fill="#0284c7" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}
