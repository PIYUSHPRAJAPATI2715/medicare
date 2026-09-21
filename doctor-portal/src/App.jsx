import React, { useState } from 'react';
import { LayoutDashboard, Calendar, Video, Stethoscope, CircleDot, ShieldCheck } from 'lucide-react';
import DoctorDashboardPage from './pages/DoctorDashboardPage';
import DoctorAppointmentsPage from './pages/DoctorAppointmentsPage';
import VideoCallRoomPage from './pages/VideoCallRoomPage';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [activeCallAppointment, setActiveCallAppointment] = useState(null);

  const handleStartCall = (appointment) => {
    setActiveCallAppointment(appointment);
    setActiveTab('videocall');
  };

  const handleEndCall = () => {
    setActiveCallAppointment(null);
    setActiveTab('dashboard');
  };

  return (
    <div className="flex h-screen bg-slate-50 font-sans overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col border-r border-slate-800 shrink-0">
        <div className="p-5 flex items-center gap-3 border-b border-slate-800">
          <div className="w-9 h-9 bg-emerald-600 rounded-xl flex items-center justify-center text-white font-extrabold shadow-lg shadow-emerald-500/30">
            DR
          </div>
          <div>
            <h1 className="font-extrabold text-white text-base leading-tight">Doctor Portal</h1>
            <p className="text-xs text-emerald-400 font-medium">MediCare+ Provider Portal</p>
          </div>
        </div>

        <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
          <button
            onClick={() => setActiveTab('dashboard')}
            className={`w-full flex items-center gap-3 px-3.5 py-3 rounded-xl font-bold text-sm transition-all ${
              activeTab === 'dashboard' ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/30' : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
            }`}
          >
            <LayoutDashboard className="w-5 h-5" />
            <span>Dashboard</span>
          </button>

          <button
            onClick={() => setActiveTab('appointments')}
            className={`w-full flex items-center gap-3 px-3.5 py-3 rounded-xl font-bold text-sm transition-all ${
              activeTab === 'appointments' ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/30' : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
            }`}
          >
            <Calendar className="w-5 h-5" />
            <span>Appointments</span>
          </button>

          {activeCallAppointment && (
            <button
              onClick={() => setActiveTab('videocall')}
              className={`w-full flex items-center gap-3 px-3.5 py-3 rounded-xl font-bold text-sm transition-all bg-red-600 text-white animate-pulse`}
            >
              <Video className="w-5 h-5" />
              <span>Active Agora Call</span>
            </button>
          )}
        </nav>

        <div className="p-4 border-t border-slate-800">
          <div className="bg-slate-800/60 p-3 rounded-xl flex items-center gap-3">
            <ShieldCheck className="w-8 h-8 text-emerald-400" />
            <div>
              <p className="text-xs font-bold text-white">Provider Verified</p>
              <p className="text-[11px] text-emerald-400 font-semibold flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span> Agora HD Connected
              </p>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Container */}
      <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <header className="h-16 bg-white border-b border-slate-200/80 px-6 flex items-center justify-between shrink-0">
          <h2 className="text-base font-extrabold text-slate-800 capitalize">
            Provider Consultation Center
          </h2>
          <div className="flex items-center gap-3">
            <div className="text-right">
              <p className="text-xs font-bold text-slate-900">Dr. Rajesh Sharma</p>
              <p className="text-[11px] text-emerald-600 font-semibold">General Physician • Online</p>
            </div>
            <img
              src="https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400"
              alt=""
              className="w-9 h-9 rounded-full object-cover border border-emerald-500"
            />
          </div>
        </header>

        <div className="flex-1 overflow-y-auto p-6">
          {activeTab === 'dashboard' && <DoctorDashboardPage onStartCall={handleStartCall} />}
          {activeTab === 'appointments' && <DoctorAppointmentsPage onStartCall={handleStartCall} />}
          {activeTab === 'videocall' && <VideoCallRoomPage appointment={activeCallAppointment} onEndCall={handleEndCall} />}
        </div>
      </main>
    </div>
  );
}
