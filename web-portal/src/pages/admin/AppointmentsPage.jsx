import React, { useState, useEffect } from 'react';
import { fetchAppointments } from '../../services/api';
import { initialAppointments } from '../../data/mockData';
import { Calendar, Video, MapPin, Clock, Plus, X, Check, Search, User } from 'lucide-react';

export default function AppointmentsPage() {
  const [appointments, setAppointments] = useState(() => {
    try {
      const saved = localStorage.getItem('drconnects24_custom_appointments');
      return saved ? JSON.parse(saved) : initialAppointments;
    } catch {
      return initialAppointments;
    }
  });

  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Form state
  const [formData, setFormData] = useState({
    patientName: '',
    doctorName: 'Dr. Rajesh Sharma',
    specialty: 'General Physician',
    date: new Date().toISOString().split('T')[0],
    timeSlot: '11:00 AM',
    type: 'video',
    status: 'upcoming',
    fee: 499,
  });

  useEffect(() => {
    fetchAppointments().then(res => {
      if (res && res.data && Array.isArray(res.data) && res.data.length > 0) {
        setAppointments(prev => {
          const customIds = new Set(prev.filter(a => a.id.startsWith('custom_')).map(a => a.id));
          const customs = prev.filter(a => customIds.has(a.id));
          const existingIds = new Set(customs.map(a => a.id));
          const incoming = res.data.filter(a => !existingIds.has(a.id));
          return [...customs, ...incoming];
        });
      }
    }).catch(console.error);
  }, []);

  const handleOpenModal = () => {
    setFormData({
      patientName: '',
      doctorName: 'Dr. Rajesh Sharma',
      specialty: 'General Physician',
      date: new Date().toISOString().split('T')[0],
      timeSlot: '02:30 PM',
      type: 'video',
      status: 'upcoming',
      fee: 499,
    });
    setIsModalOpen(true);
  };

  const handleSaveAppointment = (e) => {
    e.preventDefault();
    if (!formData.patientName.trim()) {
      alert('Please enter patient name.');
      return;
    }

    const newAppointment = {
      id: `custom_apt_${Date.now()}`,
      patientName: formData.patientName.trim(),
      doctorName: formData.doctorName.trim(),
      specialty: formData.specialty.trim(),
      date: formData.date,
      timeSlot: formData.timeSlot.trim(),
      type: formData.type,
      status: formData.status,
      fee: Number(formData.fee) || 499,
    };

    const updated = [newAppointment, ...appointments];
    setAppointments(updated);
    try {
      localStorage.setItem('drconnects24_custom_appointments', JSON.stringify(updated));
    } catch (err) {}

    setIsModalOpen(false);
  };

  const filtered = appointments.filter(a =>
    (a.patientName || '').toLowerCase().includes(search.toLowerCase()) ||
    (a.doctorName || '').toLowerCase().includes(search.toLowerCase()) ||
    (a.specialty || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Platform Consultation Records</h1>
          <p className="text-xs text-slate-500 font-medium">All video and in-person patient appointments scheduled on drconnects24.com.</p>
        </div>
        <div className="flex items-center gap-2">
          <div className="hidden sm:flex items-center gap-2 bg-blue-50 text-blue-700 px-3.5 py-2 rounded-xl border border-blue-100 text-xs font-bold">
            <Calendar className="w-4 h-4" />
            <span>{appointments.length} Consults</span>
          </div>
          <button
            onClick={handleOpenModal}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-blue-600/20 active:scale-95"
          >
            <Plus className="w-4 h-4" /> Add Consultation
          </button>
        </div>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          placeholder="Search by patient, doctor, or specialty..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
        />
      </div>

      {/* Table / Empty State */}
      {filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-500 shadow-sm">
          <Calendar className="w-10 h-10 text-slate-300 mx-auto mb-2" />
          <p className="text-sm font-bold text-slate-700">No appointments found</p>
          <p className="text-xs text-slate-400 mt-1">Try a different search query or schedule a new consultation.</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 border-b border-slate-200 text-[11px] font-extrabold text-slate-500 uppercase tracking-wider">
                <th className="py-3.5 px-4">Patient</th>
                <th className="py-3.5 px-4">Doctor & Specialty</th>
                <th className="py-3.5 px-4">Date & Slot</th>
                <th className="py-3.5 px-4">Type</th>
                <th className="py-3.5 px-4">Fee</th>
                <th className="py-3.5 px-4">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs font-medium">
              {filtered.map((apt) => (
                <tr key={apt.id} className="hover:bg-slate-50/80 transition">
                  <td className="py-3.5 px-4">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center font-bold text-xs">
                        {apt.patientName.charAt(0)}
                      </div>
                      <span className="font-bold text-slate-900">{apt.patientName}</span>
                    </div>
                  </td>
                  <td className="py-3.5 px-4">
                    <p className="font-bold text-blue-700">{apt.doctorName}</p>
                    <p className="text-[11px] text-slate-500">{apt.specialty}</p>
                  </td>
                  <td className="py-3.5 px-4">
                    <p className="text-slate-800 font-semibold">{apt.date}</p>
                    <p className="text-[11px] text-slate-500">{apt.timeSlot}</p>
                  </td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold inline-flex items-center gap-1 ${
                      apt.type === 'video' ? 'bg-blue-100 text-blue-800' : 'bg-emerald-100 text-emerald-800'
                    }`}>
                      {apt.type === 'video' ? <Video className="w-3 h-3" /> : <MapPin className="w-3 h-3" />}
                      {apt.type === 'video' ? 'Video Consult' : 'In-Person'}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 font-bold text-slate-900">₹{apt.fee}</td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold capitalize ${
                      apt.status === 'completed' ? 'bg-emerald-100 text-emerald-800' :
                      apt.status === 'upcoming' ? 'bg-blue-100 text-blue-800' : 'bg-slate-100 text-slate-700'
                    }`}>
                      {apt.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Add Consultation Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
                  <Calendar className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">Schedule Consultation</h2>
                  <p className="text-xs text-slate-500">Create new appointment record</p>
                </div>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveAppointment} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Patient Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Ramesh Kumar"
                  value={formData.patientName}
                  onChange={(e) => setFormData({ ...formData, patientName: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Doctor Name</label>
                <input
                  type="text"
                  placeholder="e.g. Dr. Rajesh Sharma"
                  value={formData.doctorName}
                  onChange={(e) => setFormData({ ...formData, doctorName: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Specialty</label>
                <input
                  type="text"
                  placeholder="e.g. General Physician, Dermatologist"
                  value={formData.specialty}
                  onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Date</label>
                  <input
                    type="date"
                    value={formData.date}
                    onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Time Slot</label>
                  <input
                    type="text"
                    placeholder="10:30 AM"
                    value={formData.timeSlot}
                    onChange={(e) => setFormData({ ...formData, timeSlot: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Consultation Mode</label>
                  <select
                    value={formData.type}
                    onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  >
                    <option value="video">Agora Video Call</option>
                    <option value="inPerson">In-Person Clinic</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Fee (₹)</label>
                  <input
                    type="number"
                    min="0"
                    step="50"
                    value={formData.fee}
                    onChange={(e) => setFormData({ ...formData, fee: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-blue-600/20"
                >
                  <Check className="w-4 h-4" /> Save Appointment
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
