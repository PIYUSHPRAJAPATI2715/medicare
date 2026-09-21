import React, { useEffect, useState } from 'react';
import { Stethoscope, Plus, Search, CheckCircle, XCircle, Trash2, Edit3, CircleDot } from 'lucide-react';
import { apiService } from '../services/api';

export default function DoctorsPage() {
  const [doctors, setDoctors] = useState([]);
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    specialty: 'General Physician',
    qualification: 'MBBS, MD',
    experienceYears: 8,
    consultationFee: 500,
    clinicName: 'MediCare Care Clinic',
    clinicAddress: 'Jaipur',
    isOnline: true,
  });

  useEffect(() => {
    loadDoctors();
  }, []);

  const loadDoctors = async () => {
    const res = await apiService.getDoctors();
    if (res.success) setDoctors(res.data);
  };

  const handleToggleOnline = async (doc) => {
    await apiService.updateDoctor(doc.id, { isOnline: !doc.isOnline });
    loadDoctors();
  };

  const handleToggleVerified = async (doc) => {
    await apiService.updateDoctor(doc.id, { isVerified: !doc.isVerified });
    loadDoctors();
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    const res = await apiService.createDoctor(formData);
    if (res.success) {
      setShowModal(false);
      loadDoctors();
    }
  };

  const handleDelete = async (id) => {
    if (confirm('Delete this doctor record?')) {
      await apiService.deleteDoctor(id);
      loadDoctors();
    }
  };

  const filtered = doctors.filter(
    d => d.name.toLowerCase().includes(search.toLowerCase()) || d.specialty.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Doctor Directory & Verification</h1>
          <p className="text-slate-500 text-sm mt-0.5">Manage doctor credentials, fees, clinic locations, and instant online status</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-bold px-4 py-2.5 rounded-xl text-sm transition-all shadow-md shadow-blue-500/20"
        >
          <Plus className="w-4 h-4" /> Add Doctor
        </button>
      </div>

      {/* Search Bar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-3">
        <Search className="w-5 h-5 text-slate-400" />
        <input
          type="text"
          placeholder="Search by doctor name, specialty or clinic..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-transparent border-none text-sm focus:outline-none text-slate-800 placeholder-slate-400 font-medium"
        />
      </div>

      {/* Doctors Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        {filtered.map((doc) => (
          <div key={doc.id} className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-start gap-4">
              <img src={doc.imageUrl} alt="" className="w-16 h-16 rounded-2xl object-cover border border-slate-200 shadow-sm" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <h3 className="font-extrabold text-slate-900 text-base truncate">{doc.name}</h3>
                  {doc.isVerified && <CheckCircle className="w-4 h-4 text-emerald-500 shrink-0" />}
                </div>
                <p className="text-xs font-bold text-blue-600 mt-0.5">{doc.specialty}</p>
                <p className="text-xs text-slate-500 mt-0.5">{doc.qualification} • {doc.experienceText}</p>
              </div>
              <button
                onClick={() => handleDelete(doc.id)}
                className="p-1.5 text-slate-400 hover:text-red-500 rounded-lg"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-2 bg-slate-50 p-3 rounded-xl text-xs font-semibold text-slate-600">
              <div>
                <span className="text-slate-400 font-normal">Fee:</span> ₹{doc.consultationFee}
              </div>
              <div>
                <span className="text-slate-400 font-normal">Rating:</span> {doc.ratingPercentage}% ({doc.patientStoriesCount} reviews)
              </div>
              <div className="col-span-2 truncate">
                <span className="text-slate-400 font-normal">Clinic:</span> {doc.clinicName} ({doc.clinicAddress})
              </div>
            </div>

            {/* Quick Admin Actions */}
            <div className="flex items-center justify-between pt-1 border-t border-slate-100 text-xs font-bold">
              <button
                onClick={() => handleToggleOnline(doc)}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg border transition-colors ${
                  doc.isOnline ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-slate-100 text-slate-500 border-slate-200'
                }`}
              >
                <CircleDot className={`w-3.5 h-3.5 ${doc.isOnline ? 'text-emerald-500 animate-pulse' : 'text-slate-400'}`} />
                {doc.isOnline ? 'Online Now' : 'Offline'}
              </button>

              <button
                onClick={() => handleToggleVerified(doc)}
                className={`px-3 py-1.5 rounded-lg border transition-colors ${
                  doc.isVerified ? 'bg-blue-50 text-blue-700 border-blue-200' : 'bg-amber-50 text-amber-700 border-amber-200'
                }`}
              >
                {doc.isVerified ? 'Verified Profile' : 'Unverified'}
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Add Doctor Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4">
            <h2 className="text-lg font-bold text-slate-900">Add New Doctor Profile</h2>
            <form onSubmit={handleCreate} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Doctor Name</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Specialty</label>
                  <input
                    type="text"
                    required
                    value={formData.specialty}
                    onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Fee (₹)</label>
                  <input
                    type="number"
                    required
                    value={formData.consultationFee}
                    onChange={(e) => setFormData({ ...formData, consultationFee: Number(e.target.value) })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Qualification</label>
                <input
                  type="text"
                  required
                  value={formData.qualification}
                  onChange={(e) => setFormData({ ...formData, qualification: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Clinic Name & Address</label>
                <input
                  type="text"
                  required
                  value={formData.clinicName}
                  onChange={(e) => setFormData({ ...formData, clinicName: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                />
              </div>
              <div className="flex gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="flex-1 py-2.5 bg-slate-100 text-slate-700 rounded-xl font-bold text-sm"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 bg-blue-600 text-white rounded-xl font-bold text-sm"
                >
                  Save Profile
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
