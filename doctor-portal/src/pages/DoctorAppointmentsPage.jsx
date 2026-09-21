import React, { useEffect, useState } from 'react';
import { Calendar, Video, Building2, CheckCircle2, Clock, User } from 'lucide-react';
import { doctorApiService } from '../services/api';

export default function DoctorAppointmentsPage({ onStartCall }) {
  const [appointments, setAppointments] = useState([]);

  useEffect(() => {
    loadAppointments();
  }, []);

  const loadAppointments = async () => {
    const res = await doctorApiService.getDoctorAppointments('d1');
    if (res.success) setAppointments(res.data);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-slate-900">Patient Appointments & History</h1>
        <p className="text-slate-500 text-sm mt-0.5">Manage your scheduled patient visits and video consultation queue</p>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200/80 text-xs font-bold text-slate-500 uppercase tracking-wider">
              <th className="py-3.5 px-5">Patient Name</th>
              <th className="py-3.5 px-5">Consultation Type</th>
              <th className="py-3.5 px-5">Date & Time</th>
              <th className="py-3.5 px-5">Language</th>
              <th className="py-3.5 px-5">Status</th>
              <th className="py-3.5 px-5 text-right">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {appointments.map((apt) => (
              <tr key={apt.id} className="hover:bg-slate-50/80 transition-colors">
                <td className="py-3.5 px-5 font-bold text-slate-900 flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center text-xs">
                    P
                  </div>
                  <span>Piyush Prajapati</span>
                </td>
                <td className="py-3.5 px-5 font-semibold text-slate-700 capitalize">
                  {apt.type === 'video' ? 'Video Consult' : 'In-Person Visit'}
                </td>
                <td className="py-3.5 px-5 font-medium text-slate-600">
                  {new Date(apt.date).toLocaleDateString()} at {apt.timeSlot}
                </td>
                <td className="py-3.5 px-5 font-medium text-slate-600">{apt.selectedLanguage || 'English'}</td>
                <td className="py-3.5 px-5">
                  <span className={`px-2.5 py-1 rounded-lg text-xs font-bold capitalize ${
                    apt.status === 'upcoming' ? 'bg-blue-100 text-blue-800' :
                    apt.status === 'completed' ? 'bg-emerald-100 text-emerald-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {apt.status}
                  </span>
                </td>
                <td className="py-3.5 px-5 text-right">
                  {apt.type === 'video' && apt.status === 'upcoming' && (
                    <button
                      onClick={() => onStartCall(apt)}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-extrabold shadow-sm"
                    >
                      Start Call
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
