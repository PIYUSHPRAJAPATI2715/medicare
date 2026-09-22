import React from 'react';
import { Calendar, Video, CheckCircle2, Clock } from 'lucide-react';

export default function DoctorAppointmentsPage() {
  const patientQueue = [
    { id: '1', patientName: 'Piyush Prajapati', time: '04:00 PM', type: 'video', status: 'ready', symptom: 'Fever & Headaches' },
    { id: '2', patientName: 'Anjali Sharma', time: '04:30 PM', type: 'video', status: 'upcoming', symptom: 'Skin Rash Routine' },
    { id: '3', patientName: 'Vikram Singh', time: '05:00 PM', type: 'inPerson', status: 'upcoming', symptom: 'General Checkup' },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Doctor Patient Queue & Consult History</h1>
        <p className="text-xs text-slate-500 font-medium">View appointment schedule and connect with patients.</p>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200 text-[11px] font-extrabold text-slate-500 uppercase tracking-wider">
              <th className="py-3.5 px-4">Patient Name</th>
              <th className="py-3.5 px-4">Time Slot</th>
              <th className="py-3.5 px-4">Symptoms / Reason</th>
              <th className="py-3.5 px-4">Consult Type</th>
              <th className="py-3.5 px-4 text-right">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-xs font-medium">
            {patientQueue.map((apt) => (
              <tr key={apt.id} className="hover:bg-slate-50/80 transition">
                <td className="py-3.5 px-4 font-extrabold text-slate-900">{apt.patientName}</td>
                <td className="py-3.5 px-4 font-semibold text-slate-800">{apt.time}</td>
                <td className="py-3.5 px-4 text-slate-600">{apt.symptom}</td>
                <td className="py-3.5 px-4">
                  <span className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold inline-flex items-center gap-1 ${apt.type === 'video' ? 'bg-blue-100 text-blue-800' : 'bg-emerald-100 text-emerald-800'}`}>
                    {apt.type === 'video' ? 'Video Consult' : 'In-Person'}
                  </span>
                </td>
                <td className="py-3.5 px-4 text-right">
                  {apt.type === 'video' ? (
                    <a
                      href={`/doctor/video-call/consult-${apt.id}`}
                      className="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-xs font-bold transition inline-flex items-center gap-1 shadow-sm"
                    >
                      <Video className="w-3.5 h-3.5" /> Start Call
                    </a>
                  ) : (
                    <span className="text-slate-400 font-medium">In-Clinic</span>
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
