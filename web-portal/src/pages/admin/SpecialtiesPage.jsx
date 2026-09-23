import React, { useState, useEffect } from 'react';
import { fetchSpecialties } from '../../services/api';
import { initialSpecialties } from '../../data/mockData';
import ImageUpload from '../../components/ImageUpload';
import { Stethoscope, Plus, Search, X, Check, Activity, Heart, Sparkles, Brain, Baby, Eye, Shield } from 'lucide-react';

const SPECIALTY_PRESETS = [
  { title: 'General Medicine', url: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400' },
  { title: 'Dermatology & Skin', url: 'https://images.unsplash.com/photo-1594824813566-78a933758f46?w=400' },
  { title: 'Pediatric Care', url: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400' },
  { title: 'Cardiology & Heart', url: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400' },
  { title: 'Neurology & Brain', url: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400' },
  { title: 'Orthopedics & Bone', url: 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=400' },
];

const COLOR_THEMES = [
  { label: 'Blue (General)', bg: '#EBF5FF', icon: '#1A56DB' },
  { label: 'Pink (Dermatology)', bg: '#FDF2F8', icon: '#DB2777' },
  { label: 'Amber (Pediatrics)', bg: '#FEF3C7', icon: '#D97706' },
  { label: 'Red (Cardiology)', bg: '#FEE2E2', icon: '#DC2626' },
  { label: 'Purple (Psychiatry)', bg: '#F3E8FF', icon: '#9333EA' },
  { label: 'Emerald (Wellness)', bg: '#ECFDF5', icon: '#059669' },
];

const DEFAULT_SPECIALTY_IMG = 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400';

export default function SpecialtiesPage() {
  const [specialties, setSpecialties] = useState(() => {
    try {
      const saved = localStorage.getItem('drconnects24_custom_specialties');
      return saved ? JSON.parse(saved) : initialSpecialties;
    } catch {
      return initialSpecialties;
    }
  });

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [search, setSearch] = useState('');

  // Form state
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    doctorCount: 12,
    bgColorHex: COLOR_THEMES[0].bg,
    iconColorHex: COLOR_THEMES[0].icon,
    imageUrl: SPECIALTY_PRESETS[0].url,
  });

  useEffect(() => {
    fetchSpecialties().then(res => {
      if (res && res.data && Array.isArray(res.data) && res.data.length > 0) {
        setSpecialties(prev => {
          const customIds = new Set(prev.filter(s => s.id.startsWith('custom_')).map(s => s.id));
          const customs = prev.filter(s => customIds.has(s.id));
          const existingIds = new Set(customs.map(s => s.id));
          const incoming = res.data.filter(s => !existingIds.has(s.id));
          return [...customs, ...incoming];
        });
      }
    }).catch(console.error);
  }, []);

  const handleOpenModal = () => {
    setFormData({
      name: '',
      description: '',
      doctorCount: 15,
      bgColorHex: COLOR_THEMES[0].bg,
      iconColorHex: COLOR_THEMES[0].icon,
      imageUrl: SPECIALTY_PRESETS[0].url,
    });
    setIsModalOpen(true);
  };

  const handleSaveSpecialty = (e) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      alert('Please enter a specialty name.');
      return;
    }

    const newSpecialty = {
      id: `custom_s_${Date.now()}`,
      name: formData.name.trim(),
      description: formData.description.trim() || 'Specialized clinical diagnosis and treatments.',
      doctorCount: Number(formData.doctorCount) || 5,
      bgColorHex: formData.bgColorHex,
      iconColorHex: formData.iconColorHex,
      imageUrl: formData.imageUrl || DEFAULT_SPECIALTY_IMG,
    };

    const updated = [newSpecialty, ...specialties];
    setSpecialties(updated);
    try {
      localStorage.setItem('drconnects24_custom_specialties', JSON.stringify(updated));
    } catch (err) {
      console.warn('LocalStorage save failed:', err);
    }

    setIsModalOpen(false);
  };

  const filtered = specialties.filter(s =>
    (s.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (s.description || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Medical Specialties Management</h1>
          <p className="text-xs text-slate-500 font-medium">Departments, custom icons, treatment summaries, and doctors count.</p>
        </div>
        <button
          onClick={handleOpenModal}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-blue-600/20 active:scale-95"
        >
          <Plus className="w-4 h-4" /> Add New Specialty
        </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          placeholder="Search medical specialties or departments..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
        />
      </div>

      {/* Grid */}
      {filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-500 shadow-sm">
          <Stethoscope className="w-10 h-10 text-slate-300 mx-auto mb-2" />
          <p className="text-sm font-bold text-slate-700">No specialties found</p>
          <p className="text-xs text-slate-400 mt-1">Try a different search query or add a new specialty.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {filtered.map((spec) => (
            <div key={spec.id} className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden flex flex-col hover:shadow-md transition">
              {/* Image banner if present */}
              {spec.imageUrl ? (
                <div className="h-32 w-full bg-slate-100 overflow-hidden relative">
                  <img
                    src={spec.imageUrl}
                    alt={spec.name}
                    className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
                    onError={(e) => {
                      e.currentTarget.style.display = 'none';
                    }}
                  />
                  <div className="absolute top-2.5 right-2.5">
                    <span className="text-xs font-extrabold px-2.5 py-1 rounded-full bg-white/95 backdrop-blur-sm text-slate-800 shadow-sm border border-slate-200">
                      {spec.doctorCount || 10}+ Doctors
                    </span>
                  </div>
                </div>
              ) : null}

              <div className="p-5 flex-1 flex flex-col justify-between space-y-3">
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <div
                      className="p-3 rounded-xl flex items-center justify-center"
                      style={{ backgroundColor: spec.bgColorHex || '#EBF5FF', color: spec.iconColorHex || '#1A56DB' }}
                    >
                      <Stethoscope className="w-5 h-5" />
                    </div>
                    {!spec.imageUrl && (
                      <span className="text-xs font-extrabold px-2.5 py-1 rounded-full bg-slate-100 text-slate-700">
                        {spec.doctorCount || 10} Doctors
                      </span>
                    )}
                  </div>
                  <div>
                    <h3 className="text-base font-extrabold text-slate-900">{spec.name}</h3>
                    <p className="text-xs text-slate-500 mt-1 leading-relaxed font-medium">{spec.description}</p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Specialty Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 space-y-5 max-h-[90vh] overflow-y-auto">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
                  <Stethoscope className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">Add Medical Specialty</h2>
                  <p className="text-xs text-slate-500">Create new clinical department with image and theme</p>
                </div>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveSpecialty} className="space-y-4">
              {/* Image Upload */}
              <ImageUpload
                label="Department Cover Photo (Upload or choose preset)"
                value={formData.imageUrl}
                onChange={(newUrl) => setFormData({ ...formData, imageUrl: newUrl })}
                aspectRatio="aspect-video"
                presets={SPECIALTY_PRESETS}
                placeholder={DEFAULT_SPECIALTY_IMG}
              />

              {/* Name */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Specialty Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Neurology, Oncology, Orthopedics"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              {/* Description */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Description / Key Treatments</label>
                <textarea
                  rows={2}
                  placeholder="e.g. Brain disorders, spine surgery, stroke treatment & neurology consults"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              {/* Doctors Count */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Available Specialists Count</label>
                <input
                  type="number"
                  min="1"
                  value={formData.doctorCount}
                  onChange={(e) => setFormData({ ...formData, doctorCount: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              {/* Color Theme Selector */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">Color Badge Theme</label>
                <div className="grid grid-cols-3 gap-2">
                  {COLOR_THEMES.map((theme, i) => (
                    <button
                      key={i}
                      type="button"
                      onClick={() => setFormData({ ...formData, bgColorHex: theme.bg, iconColorHex: theme.icon })}
                      className={`p-2.5 rounded-xl border text-left flex items-center gap-2 transition ${
                        formData.bgColorHex === theme.bg
                          ? 'border-blue-600 ring-2 ring-blue-500/20 bg-white'
                          : 'border-slate-200 hover:border-slate-300 bg-slate-50'
                      }`}
                    >
                      <div className="w-4 h-4 rounded-full flex-shrink-0" style={{ backgroundColor: theme.icon }} />
                      <span className="text-[11px] font-bold text-slate-700 truncate">{theme.label.split(' ')[0]}</span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Buttons */}
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
                  <Check className="w-4 h-4" /> Save Specialty
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
