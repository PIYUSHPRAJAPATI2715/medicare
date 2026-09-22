import React, { useState, useEffect } from 'react';
import { fetchAppointments } from '../../services/api';
import { Calendar, Video, MapPin, Clock } from 'lucide-react';

export default function AppointmentsPage() {
  const [appointments, setAppointments] = useState([]);

  useEffect(() => {
    fetchAppointments().then(res => {
      if (res.data) setAppointments(res.data);
    }).catch(console.error);
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Platform Consultation Records</h1>
        <p className="text-xs text-slate-500 font-medium">All video and in-person patient appointments scheduled on drconnects24.com.</p>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200 text-[11px] font-extrabold text-slate-500 uppercase tracking-wider">
              <th className="py-3.5 px-4">Patient</th>
              <th className="py-3.5 px-4">Doctor</th>
              <th className="py-3.5 px-4">Date & Slot</th>
              <th className="py-3.5 px-4">Type</th>
              <th className="py-3.5 px-4">Fee</th>
              <th className="py-3.5 px-4">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-xs font-medium">
            {appointments.map((apt) => (
              <tr key={apt.id} className="hover:bg-slate-50/80 transition">
                <td className="py-3.5 px-4 font-bold text-slate-900">{apt.patientName}</td>
                <td className="py-3.5 px-4 font-bold text-blue-700">{apt.doctorName}</td>
                <td className="py-3.5 px-4">
                  <p className="text-slate-800 font-semibold">{apt.date}</p>
                  <p className="text-[11px] text-slate-500">{apt.timeSlot}</p>
                </td>
                <td className="py-3.5 px-4">
                  <span className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold inline-flex items-center gap-1 ${apt.type === 'video' ? 'bg-blue-100 text-blue-800' : 'bg-emerald-100 text-emerald-800'}`}>
                    {apt.type === 'video' ? <Video className="w-3 h-3" /> : <MapPin className="w-3 h-3" />}
                    {apt.type === 'video' ? 'Video Consult' : 'In-Person'}
                  </span>
                </td>
                <td className="py-3.5 px-4 font-bold text-slate-900">₹{apt.fee}</td>
                <td className="py-3.5 px-4">
                  <span className="px-2.5 py-1 rounded-full text-[10px] font-extrabold bg-emerald-100 text-emerald-800 capitalize">
                    {apt.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
