import React, { useState, useEffect } from 'react';
import { fetchUsers } from '../../services/api';
import { initialUsers } from '../../data/mockData';
import ImageUpload from '../../components/ImageUpload';
import { Users, Search, Mail, Phone, Calendar, UserCheck, Plus, X, Check, MapPin } from 'lucide-react';

const AVATAR_PRESETS = [
  { title: 'Patient 1', url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400' },
  { title: 'Patient 2', url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400' },
  { title: 'Patient 3', url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400' },
  { title: 'Patient 4', url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400' },
];

const DEFAULT_AVATAR = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';

export default function UsersPage() {
  const [users, setUsers] = useState(() => {
    try {
      const saved = localStorage.getItem('drconnects24_custom_users');
      return saved ? JSON.parse(saved) : initialUsers;
    } catch {
      return initialUsers;
    }
  });

  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Form state
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    currentCity: 'Jaipur',
    status: 'active',
    avatarUrl: AVATAR_PRESETS[0].url,
  });

  useEffect(() => {
    fetchUsers().then(res => {
      if (res && res.data && Array.isArray(res.data) && res.data.length > 0) {
        setUsers(prev => {
          const customIds = new Set(prev.filter(u => u.id.startsWith('custom_')).map(u => u.id));
          const customs = prev.filter(u => customIds.has(u.id));
          const existingIds = new Set(customs.map(u => u.id));
          const incoming = res.data.filter(u => !existingIds.has(u.id));
          return [...customs, ...incoming];
        });
      }
    }).catch(console.error);
  }, []);

  const handleOpenModal = () => {
    setFormData({
      name: '',
      email: '',
      phone: '+91 ',
      currentCity: 'Jaipur',
      status: 'active',
      avatarUrl: AVATAR_PRESETS[Math.floor(Math.random() * AVATAR_PRESETS.length)].url,
    });
    setIsModalOpen(true);
  };

  const handleSaveUser = (e) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.email.trim()) {
      alert('Please enter user name and email.');
      return;
    }

    const newUser = {
      id: `custom_u_${Date.now()}`,
      name: formData.name.trim(),
      email: formData.email.trim(),
      phone: formData.phone.trim() || '+91 99999 00000',
      role: 'patient',
      status: formData.status || 'active',
      createdAt: new Date().toISOString(),
      avatarUrl: formData.avatarUrl || DEFAULT_AVATAR,
      currentCity: formData.currentCity.trim() || 'Jaipur',
    };

    const updated = [newUser, ...users];
    setUsers(updated);
    try {
      localStorage.setItem('drconnects24_custom_users', JSON.stringify(updated));
    } catch (err) {
      console.warn('LocalStorage save failed:', err);
    }

    setIsModalOpen(false);
  };

  const filtered = users.filter(u =>
    (u.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (u.email || '').toLowerCase().includes(search.toLowerCase()) ||
    (u.phone || '').toLowerCase().includes(search.toLowerCase()) ||
    (u.currentCity || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Patient User Database</h1>
          <p className="text-xs text-slate-500 font-medium">Registered patients across drconnects24.com network.</p>
        </div>
        <div className="flex items-center gap-2">
          <div className="hidden sm:flex items-center gap-2 bg-blue-50 text-blue-700 px-3.5 py-2 rounded-xl border border-blue-100 text-xs font-bold">
            <Users className="w-4 h-4" />
            <span>{users.length} Patients</span>
          </div>
          <button
            onClick={handleOpenModal}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-blue-600/20 active:scale-95"
          >
            <Plus className="w-4 h-4" /> Add Patient
          </button>
        </div>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          placeholder="Search patient users by name, email, or city..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
        />
      </div>

      {/* List / Table */}
      {filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-500 shadow-sm">
          <Users className="w-10 h-10 text-slate-300 mx-auto mb-2" />
          <p className="text-sm font-bold text-slate-700">No patient users found</p>
          <p className="text-xs text-slate-400 mt-1">Try searching for a different keyword or name.</p>
        </div>
      ) : (
        <>
          {/* Mobile Card List (< 768px) */}
          <div className="md:hidden space-y-3">
            {filtered.map((u) => (
              <div key={u.id} className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm space-y-2">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <img
                      src={u.avatarUrl || DEFAULT_AVATAR}
                      alt={u.name}
                      className="w-10 h-10 rounded-full object-cover border border-slate-200"
                      onError={(e) => { e.currentTarget.src = DEFAULT_AVATAR; }}
                    />
                    <div>
                      <h3 className="font-bold text-slate-900 text-sm">{u.name}</h3>
                      <p className="text-xs text-slate-500 font-medium">{u.email}</p>
                    </div>
                  </div>
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-emerald-100 text-emerald-800 capitalize">
                    {u.status || 'Active'}
                  </span>
                </div>

                <div className="flex justify-between items-center text-xs pt-2 border-t border-slate-100 font-medium text-slate-600">
                  <span>Phone: {u.phone}</span>
                  <span className="font-semibold text-slate-800">{u.currentCity || 'Jaipur'}</span>
                </div>
              </div>
            ))}
          </div>

          {/* Desktop Table (>= 768px) */}
          <div className="hidden md:block bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-[11px] font-extrabold text-slate-500 uppercase tracking-wider">
                  <th className="py-3.5 px-4">Patient Name</th>
                  <th className="py-3.5 px-4">Contact Information</th>
                  <th className="py-3.5 px-4">Location City</th>
                  <th className="py-3.5 px-4">Account Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs font-medium">
                {filtered.map((u) => (
                  <tr key={u.id} className="hover:bg-slate-50/80 transition">
                    <td className="py-3.5 px-4">
                      <div className="flex items-center gap-3">
                        <img
                          src={u.avatarUrl || DEFAULT_AVATAR}
                          alt={u.name}
                          className="w-9 h-9 rounded-full object-cover border border-slate-200"
                          onError={(e) => { e.currentTarget.src = DEFAULT_AVATAR; }}
                        />
                        <span className="font-bold text-slate-900">{u.name}</span>
                      </div>
                    </td>
                    <td className="py-3.5 px-4">
                      <p className="text-slate-800 font-medium">{u.email}</p>
                      <p className="text-[11px] text-slate-500">{u.phone}</p>
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-slate-800">{u.currentCity || 'Jaipur'}</td>
                    <td className="py-3.5 px-4">
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-extrabold bg-emerald-100 text-emerald-800 capitalize">
                        {u.status || 'Active'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      {/* Add User Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4 max-h-[90vh] overflow-y-auto">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
                  <Users className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">Add Patient User</h2>
                  <p className="text-xs text-slate-500">Create new patient record with avatar photo</p>
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
            <form onSubmit={handleSaveUser} className="space-y-4">
              <ImageUpload
                label="Profile Avatar (Upload from device or choose preset)"
                value={formData.avatarUrl}
                onChange={(newUrl) => setFormData({ ...formData, avatarUrl: newUrl })}
                aspectRatio="aspect-square"
                presets={AVATAR_PRESETS}
                placeholder={DEFAULT_AVATAR}
              />

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Full Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Rahul Sharma"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Email Address *</label>
                <input
                  type="email"
                  required
                  placeholder="e.g. rahul@example.com"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Phone Number</label>
                  <input
                    type="text"
                    placeholder="+91 98765 43210"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">City</label>
                  <input
                    type="text"
                    placeholder="Jaipur"
                    value={formData.currentCity}
                    onChange={(e) => setFormData({ ...formData, currentCity: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Account Status</label>
                <select
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                >
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
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
                  <Check className="w-4 h-4" /> Save Patient
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
