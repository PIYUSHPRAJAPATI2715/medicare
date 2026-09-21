import React, { useEffect, useState } from 'react';
import { Stethoscope, Calendar, Video, IndianRupee, Star, CircleDot, Clock, ArrowRight } from 'lucide-react';
import { doctorApiService } from '../services/api';

export default function DoctorDashboardPage({ onStartCall }) {
  const [doctor, setDoctor] = useState(null);
  const [appointments, setAppointments] = useState([]);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    const docRes = await doctorApiService.getDoctorProfile('d1');
    if (docRes.success) setDoctor(docRes.data);

    const aptRes = await doctorApiService.getDoctorAppointments('d1');
    if (aptRes.success) setAppointments(aptRes.data);
  };

  const handleToggleOnline = async () => {
    if (!doctor) return;
    const newStatus = !doctor.isOnline;
    setDoctor({ ...doctor, isOnline: newStatus });
    await doctorApiService.updateDoctorStatus(doctor.id, newStatus);
  };

  if (!doctor) return <div className="p-8 text-slate-500 font-medium">Loading Doctor Dashboard...</div>;

  const upcomingCalls = appointments.filter(a => a.status === 'upcoming');
  const completedCalls = appointments.filter(a => a.status === 'completed');
  const totalEarnings = completedCalls.reduce((sum, a) => sum + (a.fee || 499), 0);

  return (
    <div className="space-y-6">
      {/* Doctor Profile Banner */}
      <div className="bg-gradient-to-r from-blue-700 via-indigo-700 to-blue-800 rounded-2xl p-6 text-white shadow-xl shadow-blue-500/10 flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div className="flex items-center gap-4">
          <img src={doctor.imageUrl} alt="" className="w-20 h-20 rounded-2xl object-cover border-2 border-white/40 shadow-md" />
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-extrabold">{doctor.name}</h1>
              <span className="px-2.5 py-0.5 bg-emerald-400/20 text-emerald-300 text-xs font-bold rounded-lg border border-emerald-400/30">Verified Provider</span>
            </div>
            <p className="text-blue-100 text-sm mt-0.5">{doctor.specialty} • {doctor.qualification}</p>
            <p className="text-xs text-blue-200 mt-1">{doctor.clinicName} ({doctor.clinicAddress})</p>
          </div>
        </div>

        {/* Online Toggle Card */}
        <div className="bg-white/10 backdrop-blur-md p-4 rounded-2xl border border-white/20 flex items-center gap-4">
          <div>
            <p className="text-xs font-bold text-blue-100">Consultation Availability</p>
            <p className="text-sm font-extrabold text-white mt-0.5">{doctor.isOnline ? 'Accepting Live Video Calls' : 'Offline / On Break'}</p>
          </div>
          <button
            onClick={handleToggleOnline}
            className={`flex items-center gap-2 px-4 py-2.5 rounded-xl font-extrabold text-xs transition-all shadow-md ${
              doctor.isOnline ? 'bg-emerald-500 hover:bg-emerald-600 text-white shadow-emerald-500/30' : 'bg-slate-700 hover:bg-slate-600 text-slate-200'
            }`}
          >
            <CircleDot className={`w-3.5 h-3.5 ${doctor.isOnline ? 'animate-pulse' : ''}`} />
            {doctor.isOnline ? 'Go Offline' : 'Go Online'}
          </button>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-500 uppercase">Upcoming Visits</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-1">{upcomingCalls.length}</h3>
          </div>
          <div className="p-3.5 rounded-2xl bg-blue-50 text-blue-600"><Calendar className="w-6 h-6" /></div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-500 uppercase">Consultations Done</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-1">{completedCalls.length}</h3>
          </div>
          <div className="p-3.5 rounded-2xl bg-emerald-50 text-emerald-600"><Video className="w-6 h-6" /></div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-500 uppercase">Est. Monthly Earnings</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-1">₹{totalEarnings || 14970}</h3>
          </div>
          <div className="p-3.5 rounded-2xl bg-indigo-50 text-indigo-600"><IndianRupee className="w-6 h-6" /></div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-500 uppercase">Patient Rating</p>
            <h3 className="text-2xl font-extrabold text-slate-900 mt-1">{doctor.ratingPercentage}%</h3>
          </div>
          <div className="p-3.5 rounded-2xl bg-amber-50 text-amber-600"><Star className="w-6 h-6 fill-amber-400" /></div>
        </div>
      </div>

      {/* Upcoming Patients Queue */}
      <div className="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-sm space-y-4">
        <h2 className="text-base font-extrabold text-slate-900">Today's Patient Consultation Queue</h2>
        <div className="divide-y divide-slate-100">
          {upcomingCalls.map((apt) => (
            <div key={apt.id} className="py-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center font-bold text-lg">
                  P
                </div>
                <div>
                  <h4 className="font-bold text-slate-900 text-sm">Piyush Prajapati (Patient)</h4>
                  <p className="text-xs text-slate-500 flex items-center gap-2 mt-0.5">
                    <span className="flex items-center gap-1 text-blue-600 font-semibold"><Clock className="w-3.5 h-3.5" /> {apt.timeSlot}</span>
                    <span>•</span>
                    <span className="capitalize font-medium">{apt.type} Visit</span>
                    <span>•</span>
                    <span>Language: {apt.selectedLanguage || 'English'}</span>
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                {apt.type === 'video' ? (
                  <button
                    onClick={() => onStartCall(apt)}
                    className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold px-4 py-2.5 rounded-xl text-xs transition-all shadow-md shadow-emerald-600/20"
                  >
                    <Video className="w-4 h-4" /> Start Agora Video Call
                  </button>
                ) : (
                  <span className="px-3 py-1.5 bg-slate-100 text-slate-600 text-xs font-bold rounded-xl">Clinic Appointment</span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
