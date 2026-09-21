import React, { useEffect, useState } from 'react';
import { CalendarCheck, Video, Building2, CheckCircle2, Clock, XCircle, RotateCcw } from 'lucide-react';
import { apiService } from '../services/api';

export default function AppointmentsPage() {
  const [appointments, setAppointments] = useState([]);
  const [filterStatus, setFilterStatus] = useState('all');

  useEffect(() => {
    loadAppointments();
  }, []);

  const loadAppointments = async () => {
    const res = await apiService.getAppointments();
    if (res.success) setAppointments(res.data);
  };

  const handleStatusChange = async (id, status) => {
    await apiService.updateAppointment(id, { status });
    loadAppointments();
  };

  const filtered = appointments.filter(a => filterStatus === 'all' || a.status === filterStatus);

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Appointments & Consultations Ledger</h1>
          <p className="text-slate-500 text-sm mt-0.5">Manage patient bookings, video channels, force cancellations & refunds</p>
        </div>
        <div className="flex gap-2">
          {['all', 'upcoming', 'completed', 'cancelled'].map(st => (
            <button
              key={st}
              onClick={() => setFilterStatus(st)}
              className={`px-3 py-1.5 rounded-xl text-xs font-bold capitalize transition-colors ${
                filterStatus === st ? 'bg-blue-600 text-white' : 'bg-white text-slate-600 border border-slate-200'
              }`}
            >
              {st}
            </button>
          ))}
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200/80 text-xs font-bold text-slate-500 uppercase tracking-wider">
              <th className="py-3.5 px-5">ID & Type</th>
              <th className="py-3.5 px-5">Doctor</th>
              <th className="py-3.5 px-5">Date & Slot</th>
              <th className="py-3.5 px-5">Total Paid</th>
              <th className="py-3.5 px-5">Status</th>
              <th className="py-3.5 px-5 text-right">Admin Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-sm">
            {filtered.map((apt) => (
              <tr key={apt.id} className="hover:bg-slate-50/80 transition-colors">
                <td className="py-3.5 px-5 font-medium">
                  <div className="flex items-center gap-2">
                    {apt.type === 'video' ? (
                      <span className="p-1.5 bg-blue-100 text-blue-700 rounded-lg"><Video className="w-4 h-4" /></span>
                    ) : (
                      <span className="p-1.5 bg-sky-100 text-sky-700 rounded-lg"><Building2 className="w-4 h-4" /></span>
                    )}
                    <div>
                      <p className="font-bold text-slate-900 text-xs">{apt.id}</p>
                      <p className="text-xs text-slate-400 capitalize">{apt.type} Consult</p>
                    </div>
                  </div>
                </td>
                <td className="py-3.5 px-5">
                  <p className="font-bold text-slate-800">{apt.doctor?.name || 'Dr. Specialist'}</p>
                  <p className="text-xs text-slate-400">{apt.doctor?.specialty}</p>
                </td>
                <td className="py-3.5 px-5">
                  <p className="font-semibold text-slate-700">{new Date(apt.date).toLocaleDateString()}</p>
                  <p className="text-xs text-slate-500">{apt.timeSlot}</p>
                </td>
                <td className="py-3.5 px-5 font-bold text-slate-900">₹{apt.totalAmount?.toFixed(2) || apt.fee}</td>
                <td className="py-3.5 px-5">
                  <span className={`px-2.5 py-1 rounded-lg text-xs font-bold capitalize ${
                    apt.status === 'upcoming' ? 'bg-blue-100 text-blue-800' :
                    apt.status === 'completed' ? 'bg-emerald-100 text-emerald-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {apt.status}
                  </span>
                </td>
                <td className="py-3.5 px-5 text-right space-x-2">
                  {apt.status === 'upcoming' && (
                    <>
                      <button
                        onClick={() => handleStatusChange(apt.id, 'completed')}
                        className="px-2.5 py-1 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 rounded-lg text-xs font-bold"
                      >
                        Mark Complete
                      </button>
                      <button
                        onClick={() => handleStatusChange(apt.id, 'cancelled')}
                        className="px-2.5 py-1 bg-red-50 text-red-700 hover:bg-red-100 rounded-lg text-xs font-bold"
                      >
                        Cancel & Refund
                      </button>
                    </>
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
