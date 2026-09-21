import React, { useEffect, useState } from 'react';
import { Plus, Trash2, Edit2, Layers } from 'lucide-react';
import { apiService } from '../services/api';

export default function SpecialtiesPage() {
  const [specialties, setSpecialties] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    icon: 'medical_services_rounded',
    bgColorHex: '#EBF5FF',
    iconColorHex: '#1A56DB',
    doctorCount: 15,
    description: '',
  });

  useEffect(() => {
    loadSpecialties();
  }, []);

  const loadSpecialties = async () => {
    const res = await apiService.getSpecialties();
    if (res.success) setSpecialties(res.data);
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    const res = await apiService.createSpecialty(formData);
    if (res.success) {
      setShowModal(false);
      setFormData({ name: '', icon: 'medical_services_rounded', bgColorHex: '#EBF5FF', iconColorHex: '#1A56DB', doctorCount: 15, description: '' });
      loadSpecialties();
    }
  };

  const handleDelete = async (id) => {
    if (confirm('Delete this specialty category?')) {
      await apiService.deleteSpecialty(id);
      loadSpecialties();
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Medical Specialties Catalog</h1>
          <p className="text-slate-500 text-sm mt-0.5">Configure clinical specialties displayed in Flutter home screen & filters</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-bold px-4 py-2.5 rounded-xl text-sm transition-all shadow-md shadow-blue-500/20"
        >
          <Plus className="w-4 h-4" /> Add Specialty
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {specialties.map((spec) => (
          <div key={spec.id} className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm relative group hover:shadow-md transition-shadow">
            <div className="flex items-start justify-between">
              <div
                className="w-14 h-14 rounded-2xl flex items-center justify-center font-bold text-lg shadow-inner"
                style={{ backgroundColor: spec.bgColorHex, color: spec.iconColorHex }}
              >
                <Layers className="w-6 h-6" />
              </div>
              <button
                onClick={() => handleDelete(spec.id)}
                className="text-slate-400 hover:text-red-500 p-1.5 rounded-lg opacity-0 group-hover:opacity-100 transition-opacity"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
            <h3 className="font-extrabold text-slate-900 text-base mt-4">{spec.name}</h3>
            <p className="text-xs text-slate-500 mt-1 line-clamp-2">{spec.description || 'Specialized healthcare consultation'}</p>
            <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs font-bold text-slate-600">
              <span>{spec.doctorCount} Doctors Available</span>
              <span className="text-blue-600 bg-blue-50 px-2 py-0.5 rounded">Icon: {spec.icon}</span>
            </div>
          </div>
        ))}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <h2 className="text-lg font-bold text-slate-900">Add Medical Specialty</h2>
            <form onSubmit={handleCreate} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Specialty Name</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Flutter Icon Class Name</label>
                <input
                  type="text"
                  required
                  value={formData.icon}
                  onChange={(e) => setFormData({ ...formData, icon: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Background Hex</label>
                  <input
                    type="text"
                    required
                    value={formData.bgColorHex}
                    onChange={(e) => setFormData({ ...formData, bgColorHex: e.target.value })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Icon Color Hex</label>
                  <input
                    type="text"
                    required
                    value={formData.iconColorHex}
                    onChange={(e) => setFormData({ ...formData, iconColorHex: e.target.value })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Description</label>
                <textarea
                  rows="2"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
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
                  Save Specialty
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
