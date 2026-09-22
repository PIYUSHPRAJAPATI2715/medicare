import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { Stethoscope, Calendar, DollarSign, Users, Video, CheckCircle2, AlertCircle } from 'lucide-react';

export default function DoctorDashboardPage() {
  const { user } = useAuth();
  const [isOnline, setIsOnline] = useState(true);

  return (
    <div className="space-y-6">
      {/* Verification Status Alert Banner */}
      <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 shadow-sm">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-emerald-600 text-white rounded-xl">
            <CheckCircle2 className="w-5 h-5" />
          </div>
          <div>
            <h4 className="text-sm font-extrabold text-emerald-950">MCI Medical License Approved</h4>
            <p className="text-xs text-emerald-700 font-medium">Verified Practitioner Profile on drconnects24.com</p>
          </div>
        </div>
        <div className="flex items-center gap-2 bg-white px-3 py-1.5 rounded-xl border border-emerald-200">
          <span className={`w-2.5 h-2.5 rounded-full ${isOnline ? 'bg-emerald-500 animate-pulse' : 'bg-slate-400'}`} />
          <span className="text-xs font-bold text-slate-800">{isOnline ? 'Available for Video Consults' : 'Offline'}</span>
          <button
            onClick={() => setIsOnline(!isOnline)}
            className="ml-2 text-[10px] font-bold px-2 py-0.5 rounded bg-slate-100 hover:bg-slate-200 text-slate-700"
          >
            Toggle Status
          </button>
        </div>
      </div>

      {/* Doctor Welcome Header */}
      <div className="bg-gradient-to-r from-blue-700 to-indigo-800 text-white rounded-2xl p-6 shadow-xl flex justify-between items-center">
        <div>
          <span className="text-xs font-extrabold text-blue-200 uppercase tracking-widest bg-blue-500/20 px-2.5 py-1 rounded-md">
            Doctor Portal
          </span>
          <h1 className="text-2xl font-black mt-2 tracking-tight">Welcome back, {user?.name || 'Dr. Rajesh Sharma'}</h1>
          <p className="text-blue-100 text-xs mt-1 font-medium">Manage today's consultations, electronic prescriptions, and live Agora video calls.</p>
        </div>
      </div>

      {/* Doctor Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="p-3 rounded-xl bg-blue-500 text-white">
            <Calendar className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500">Today's Appointments</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-0.5">8 Patients</h3>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="p-3 rounded-xl bg-emerald-500 text-white">
            <DollarSign className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500">Total Consult Earnings</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-0.5">₹14,500</h3>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="p-3 rounded-xl bg-indigo-500 text-white">
            <Users className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500">Patient Satisfaction</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-0.5">98% Rating</h3>
          </div>
        </div>
      </div>

      {/* Immediate Video Consult Queue */}
      <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm space-y-4">
        <div className="flex justify-between items-center">
          <h3 className="text-sm font-extrabold text-slate-900">Live Consultation Queue</h3>
          <span className="text-xs font-bold text-blue-600">3 Patients Waiting</span>
        </div>

        <div className="space-y-3">
          <div className="p-4 bg-blue-50/60 border border-blue-200/80 rounded-2xl flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-blue-600 animate-ping" />
                <span className="text-xs font-extrabold text-blue-900">NEXT IN QUEUE</span>
              </div>
              <h4 className="text-base font-extrabold text-slate-900 mt-1">Piyush Prajapati</h4>
              <p className="text-xs text-slate-500">Fever & Cough · Scheduled slot 04:00 PM</p>
            </div>
            <a
              href="/doctor/video-call/consult-piyush"
              className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-extrabold transition shadow-md shadow-blue-600/20 flex items-center gap-2"
            >
              <Video className="w-4 h-4" /> Start Video Consultation
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
