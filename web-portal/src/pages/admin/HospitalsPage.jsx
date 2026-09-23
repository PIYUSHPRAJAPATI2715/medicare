import React, { useState, useEffect } from 'react';
import { fetchHospitals } from '../../services/api';
import { initialHospitals } from '../../data/mockData';
import ImageUpload from '../../components/ImageUpload';
import { Building2, MapPin, Star, Plus, Phone, BedDouble, AlertCircle, X, Check, Search } from 'lucide-react';

const HOSPITAL_PRESETS = [
  { title: 'Super Speciality Wing', url: 'https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800' },
  { title: 'Modern Hospital Facade', url: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800' },
  { title: 'Healthcare Campus', url: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800' },
  { title: 'Clinical Center', url: 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800' },
];

const DEFAULT_HOSPITAL_IMG = 'https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=800';

export default function HospitalsPage() {
  const [hospitals, setHospitals] = useState(() => {
    try {
      const saved = localStorage.getItem('drconnects24_custom_hospitals');
      return saved ? JSON.parse(saved) : initialHospitals;
    } catch {
      return initialHospitals;
    }
  });

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [search, setSearch] = useState('');

  // Form state
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    phone: '',
    beds: 150,
    rating: 4.8,
    emergency: true,
    imageUrl: HOSPITAL_PRESETS[0].url,
  });

  useEffect(() => {
    fetchHospitals().then(res => {
      if (res && res.data && Array.isArray(res.data) && res.data.length > 0) {
        // Merge without overwriting user newly added ones
        setHospitals(prev => {
          const customIds = new Set(prev.filter(h => h.id.startsWith('custom_')).map(h => h.id));
          const customs = prev.filter(h => customIds.has(h.id));
          const existingIds = new Set(customs.map(h => h.id));
          const incoming = res.data.filter(h => !existingIds.has(h.id));
          return [...customs, ...incoming];
        });
      }
    }).catch(console.error);
  }, []);

  const handleOpenModal = () => {
    setFormData({
      name: '',
      address: '',
      phone: '+91 141 ',
      beds: 200,
      rating: 4.8,
      emergency: true,
      imageUrl: HOSPITAL_PRESETS[0].url,
    });
    setIsModalOpen(true);
  };

  const handleSaveHospital = (e) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.address.trim()) {
      alert('Please enter both hospital name and address.');
      return;
    }

    const newHospital = {
      id: `custom_h_${Date.now()}`,
      name: formData.name.trim(),
      address: formData.address.trim(),
      phone: formData.phone.trim() || '+91 141 000 0000',
      beds: Number(formData.beds) || 100,
      rating: Number(formData.rating) || 4.5,
      emergency: Boolean(formData.emergency),
      imageUrl: formData.imageUrl || DEFAULT_HOSPITAL_IMG,
    };

    const updated = [newHospital, ...hospitals];
    setHospitals(updated);
    try {
      localStorage.setItem('drconnects24_custom_hospitals', JSON.stringify(updated));
    } catch (err) {
      console.warn('LocalStorage save failed:', err);
    }

    setIsModalOpen(false);
  };

  const filtered = hospitals.filter(h =>
    (h.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (h.address || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Partner Hospitals & Clinics</h1>
          <p className="text-xs text-slate-500 font-medium">Affiliated healthcare facilities, multispecialty centers, and emergency hubs.</p>
        </div>
        <button
          onClick={handleOpenModal}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-blue-600/20 active:scale-95"
        >
          <Plus className="w-4 h-4" /> Add Hospital
        </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          placeholder="Search partner hospitals by name or location..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
        />
      </div>

      {/* Hospital Cards Grid */}
      {filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-500 shadow-sm">
          <Building2 className="w-10 h-10 text-slate-300 mx-auto mb-2" />
          <p className="text-sm font-bold text-slate-700">No partner hospitals found</p>
          <p className="text-xs text-slate-400 mt-1">Try a different search query or add a new hospital.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {filtered.map((h) => (
            <div key={h.id} className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden flex flex-col hover:shadow-md transition">
              {/* Hospital Image with error fallback */}
              <div className="relative h-44 w-full bg-slate-100 overflow-hidden">
                <img
                  src={h.imageUrl || DEFAULT_HOSPITAL_IMG}
                  alt={h.name}
                  className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
                  onError={(e) => {
                    e.currentTarget.src = DEFAULT_HOSPITAL_IMG;
                  }}
                />
                <div className="absolute top-3 right-3 flex gap-1.5">
                  <span className="flex items-center gap-1 text-[11px] font-extrabold text-amber-700 bg-white/95 backdrop-blur-sm px-2.5 py-1 rounded-full shadow-sm border border-amber-200">
                    <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400" /> {h.rating || 4.8}
                  </span>
                </div>
                {h.emergency && (
                  <div className="absolute top-3 left-3">
                    <span className="text-[10px] font-extrabold bg-red-600 text-white px-2.5 py-1 rounded-full shadow-sm uppercase tracking-wider flex items-center gap-1">
                      <span className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" /> 24/7 Emergency
                    </span>
                  </div>
                )}
              </div>

              {/* Hospital Details */}
              <div className="p-4 flex-1 flex flex-col justify-between space-y-3">
                <div className="space-y-1.5">
                  <h3 className="text-sm font-extrabold text-slate-900 leading-snug">{h.name}</h3>
                  <p className="text-xs text-slate-500 flex items-start gap-1 font-medium">
                    <MapPin className="w-3.5 h-3.5 text-slate-400 flex-shrink-0 mt-0.5" />
                    <span>{h.address}</span>
                  </p>
                </div>

                <div className="pt-2 border-t border-slate-100 flex items-center justify-between text-xs text-slate-600 font-medium">
                  <span className="flex items-center gap-1">
                    <BedDouble className="w-3.5 h-3.5 text-blue-600" />
                    <strong>{h.beds || 200}</strong> Beds
                  </span>
                  {h.phone && (
                    <span className="flex items-center gap-1 text-[11px] text-slate-500">
                      <Phone className="w-3 h-3 text-slate-400" />
                      {h.phone}
                    </span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Hospital Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 space-y-5 max-h-[90vh] overflow-y-auto">
            {/* Modal Header */}
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
                  <Building2 className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">Add Partner Hospital</h2>
                  <p className="text-xs text-slate-500">Register new hospital or clinic with photo</p>
                </div>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Modal Form */}
            <form onSubmit={handleSaveHospital} className="space-y-4">
              {/* Image Upload Component */}
              <ImageUpload
                label="Hospital Photo (Upload from device or choose preset)"
                value={formData.imageUrl}
                onChange={(newUrl) => setFormData({ ...formData, imageUrl: newUrl })}
                aspectRatio="aspect-video"
                presets={HOSPITAL_PRESETS}
                placeholder={DEFAULT_HOSPITAL_IMG}
              />

              {/* Hospital Name */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Hospital Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Apollo Super Speciality Hospital"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              {/* Address */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Full Address & City *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Tonk Road, Jaipur, Rajasthan"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              {/* Phone & Beds */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Helpline Phone</label>
                  <input
                    type="text"
                    placeholder="+91 141 234 5678"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Bed Capacity</label>
                  <input
                    type="number"
                    min="10"
                    placeholder="250"
                    value={formData.beds}
                    onChange={(e) => setFormData({ ...formData, beds: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              {/* Rating & Emergency Toggle */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 items-center">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Initial Rating (1-5)</label>
                  <input
                    type="number"
                    step="0.1"
                    min="1"
                    max="5"
                    value={formData.rating}
                    onChange={(e) => setFormData({ ...formData, rating: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div className="pt-4">
                  <label className="flex items-center gap-2 cursor-pointer bg-slate-50 p-2.5 rounded-xl border border-slate-200">
                    <input
                      type="checkbox"
                      checked={formData.emergency}
                      onChange={(e) => setFormData({ ...formData, emergency: e.target.checked })}
                      className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
                    />
                    <span className="text-xs font-bold text-slate-800">24/7 Emergency Available</span>
                  </label>
                </div>
              </div>

              {/* Modal Buttons */}
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
                  <Check className="w-4 h-4" /> Save Hospital
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
