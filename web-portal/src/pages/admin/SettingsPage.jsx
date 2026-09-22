import React from 'react';
import { Settings, Save, ShieldCheck, Globe, Percent } from 'lucide-react';

export default function SettingsPage() {
  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">System & Fee Settings</h1>
        <p className="text-xs text-slate-500 font-medium">Configure platform commission, tax percentages, and supported cities.</p>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm space-y-5">
        <h3 className="text-sm font-extrabold text-slate-900 border-b border-slate-100 pb-3">Financial Configuration</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">Platform Convenience Fee (₹)</label>
            <input type="number" defaultValue={49} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs font-semibold focus:outline-none focus:border-blue-500" />
          </div>
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">GST Percentage (%)</label>
            <input type="number" defaultValue={18} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs font-semibold focus:outline-none focus:border-blue-500" />
          </div>
        </div>

        <h3 className="text-sm font-extrabold text-slate-900 border-b border-slate-100 pb-3 pt-4">Target Domain & App Branding</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">Live Web Portal Domain</label>
            <input type="text" defaultValue="drconnects24.com" className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs font-semibold focus:outline-none focus:border-blue-500" />
          </div>
          <div>
            <label className="block text-xs font-bold text-slate-700 mb-1">Support Contact Email</label>
            <input type="email" defaultValue="support@drconnects24.com" className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs font-semibold focus:outline-none focus:border-blue-500" />
          </div>
        </div>

        <div className="pt-4 border-t border-slate-100 flex justify-end">
          <button className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-2 shadow-md shadow-blue-600/20">
            <Save className="w-4 h-4" /> Save Settings
          </button>
        </div>
      </div>
    </div>
  );
}
