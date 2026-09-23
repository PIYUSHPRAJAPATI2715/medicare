import React, { useState, useEffect } from 'react';
import { fetchHospitals } from '../../services/api';
import { initialHospitals } from '../../data/mockData';
import { Building2, MapPin, Star, Plus } from 'lucide-react';

export default function HospitalsPage() {
  const [hospitals, setHospitals] = useState(initialHospitals);

  useEffect(() => {
    fetchHospitals().then(res => {
      if (res && res.data && Array.isArray(res.data)) setHospitals(res.data);
    }).catch(console.error);
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Partner Hospitals & Clinics</h1>
          <p className="text-xs text-slate-500 font-medium">Affiliated healthcare facilities and clinical centers.</p>
        </div>
        <button className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-sm">
          <Plus className="w-4 h-4" /> Add Hospital
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {hospitals.map((h) => (
          <div key={h.id} className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden space-y-3">
            <img src={h.imageUrl} alt={h.name} className="w-full h-40 object-cover" />
            <div className="p-4 space-y-2">
              <div className="flex justify-between items-start">
                <h3 className="text-sm font-extrabold text-slate-900">{h.name}</h3>
                <span className="flex items-center gap-1 text-xs font-bold text-amber-600 bg-amber-50 px-2 py-0.5 rounded">
                  <Star className="w-3.5 h-3.5 fill-amber-400" /> {h.rating}
                </span>
              </div>
              <p className="text-xs text-slate-500 flex items-center gap-1">
                <MapPin className="w-3.5 h-3.5 text-slate-400" /> {h.address}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
