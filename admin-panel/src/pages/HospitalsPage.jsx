import React, { useEffect, useState } from 'react';
import { Building2, Plus, Trash2, Phone, Star, BedDouble } from 'lucide-react';
import { apiService } from '../services/api';

export default function HospitalsPage() {
  const [hospitals, setHospitals] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    address: 'Jaipur',
    phone: '+91 141 0000000',
    totalBeds: 250,
    icuBeds: 30,
    rating: 4.8,
  });

  useEffect(() => {
    loadHospitals();
  }, []);

  const loadHospitals = async () => {
    const res = await apiService.getHospitals();
    if (res.success) setHospitals(res.data);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    const res = await apiService.createHospital(formData);
    if (res.success) {
      setShowModal(false);
      loadHospitals();
    }
  };

  const handleDelete = async (id) => {
    if (confirm('Delete hospital record?')) {
      await apiService.deleteHospital(id);
      loadHospitals();
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Verified Hospitals Registry</h1>
          <p className="text-slate-500 text-sm mt-0.5">Manage verified hospital facilities, bed counts & emergency hotlines</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-bold px-4 py-2.5 rounded-xl text-sm transition-all shadow-md shadow-blue-500/20"
        >
          <Plus className="w-4 h-4" /> Add Hospital
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        {hospitals.map((hosp) => (
          <div key={hosp.id} className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-start gap-4">
              <img src={hosp.imageUrl} alt="" className="w-20 h-20 rounded-2xl object-cover border border-slate-200 shadow-sm" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <h3 className="font-extrabold text-slate-900 text-base truncate">{hosp.name}</h3>
                  <button onClick={() => handleDelete(hosp.id)} className="text-slate-400 hover:text-red-500 p-1">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
                <p className="text-xs text-slate-500 mt-1">{hosp.address}</p>
                <div className="flex items-center gap-2 mt-2">
                  <span className="flex items-center gap-1 text-xs font-bold text-amber-600 bg-amber-50 px-2 py-0.5 rounded">
                    <Star className="w-3 h-3 fill-amber-400 text-amber-400" /> {hosp.rating} ({hosp.reviewsCount} reviews)
                  </span>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-2 bg-slate-50 p-3 rounded-xl text-xs font-semibold text-slate-600">
              <div className="flex items-center gap-1.5">
                <BedDouble className="w-4 h-4 text-slate-400" />
                <span>{hosp.totalBeds} Beds ({hosp.icuBeds} ICU)</span>
              </div>
              <div className="flex items-center gap-1.5 truncate">
                <Phone className="w-4 h-4 text-slate-400" />
                <span>{hosp.phone}</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <h2 className="text-lg font-bold text-slate-900">Add Verified Hospital</h2>
            <form onSubmit={handleCreate} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Hospital Name</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Address & Location</label>
                <input
                  type="text"
                  required
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Emergency Phone</label>
                <input
                  type="text"
                  required
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Total Beds</label>
                  <input
                    type="number"
                    required
                    value={formData.totalBeds}
                    onChange={(e) => setFormData({ ...formData, totalBeds: Number(e.target.value) })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">ICU Beds</label>
                  <input
                    type="number"
                    required
                    value={formData.icuBeds}
                    onChange={(e) => setFormData({ ...formData, icuBeds: Number(e.target.value) })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
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
                  Save Hospital
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
