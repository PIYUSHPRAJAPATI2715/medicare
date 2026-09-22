import React, { useState, useEffect } from 'react';
import { fetchUsers } from '../../services/api';
import { Users, Search, Mail, Phone, Calendar } from 'lucide-react';

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    fetchUsers().then(res => {
      if (res.data) setUsers(res.data);
    }).catch(console.error);
  }, []);

  const filtered = users.filter(u => u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Patient User Database</h1>
          <p className="text-xs text-slate-500 font-medium">Registered patients across drconnects24.com network.</p>
        </div>
      </div>

      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          placeholder="Search patient users by name or email..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
        />
      </div>

      {/* Mobile Card List (< 768px) */}
      <div className="md:hidden space-y-3">
        {filtered.map((u) => (
          <div key={u.id} className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm space-y-2">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <img src={u.avatarUrl} alt={u.name} className="w-10 h-10 rounded-full object-cover border border-slate-200" />
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
                    <img src={u.avatarUrl} alt={u.name} className="w-9 h-9 rounded-full object-cover border border-slate-200" />
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

    </div>
  );
}
