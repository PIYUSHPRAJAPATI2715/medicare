import React, { useState, useEffect } from 'react';
import { fetchSpecialties } from '../../services/api';
import { initialSpecialties } from '../../data/mockData';
import { Stethoscope, Plus, Search } from 'lucide-react';

export default function SpecialtiesPage() {
  const [specialties, setSpecialties] = useState(initialSpecialties);

  useEffect(() => {
    fetchSpecialties().then(res => {
      if (res && res.data && Array.isArray(res.data)) setSpecialties(res.data);
    }).catch(console.error);
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Medical Specialties Management</h1>
          <p className="text-xs text-slate-500 font-medium">Dynamic medical departments, descriptions, and icon themes.</p>
        </div>
        <button className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-sm">
          <Plus className="w-4 h-4" /> Add New Specialty
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {specialties.map((spec) => (
          <div key={spec.id} className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm space-y-3">
            <div className="flex justify-between items-center">
              <div className="p-3 rounded-xl" style={{ backgroundColor: spec.bgColorHex || '#EBF5FF', color: spec.iconColorHex || '#1A56DB' }}>
                <Stethoscope className="w-6 h-6" />
              </div>
              <span className="text-xs font-extrabold px-2.5 py-1 rounded-full bg-slate-100 text-slate-700">
                {spec.doctorCount || 24} Doctors
              </span>
            </div>
            <div>
              <h3 className="text-base font-extrabold text-slate-900">{spec.name}</h3>
              <p className="text-xs text-slate-500 mt-1 leading-relaxed font-medium">{spec.description}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
