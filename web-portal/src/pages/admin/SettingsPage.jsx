import React, { useState } from 'react';
import { Settings, Save, ShieldCheck, Globe, Percent, Server, CheckCircle2, AlertCircle, RefreshCw } from 'lucide-react';
import { getApiBaseUrl, setCustomApiBaseUrl, testApiConnection } from '../../services/api';

export default function SettingsPage() {
  const [apiUrl, setApiUrl] = useState(getApiBaseUrl());
  const [testStatus, setTestStatus] = useState(null); // { loading, success, message }
  const [isSaved, setIsSaved] = useState(false);

  const handleSaveApiUrl = () => {
    const updated = setCustomApiBaseUrl(apiUrl);
    setApiUrl(updated);
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2500);
  };

  const handleResetApiUrl = () => {
    localStorage.removeItem('drconnects24_api_url');
    const updated = getApiBaseUrl();
    setApiUrl(updated);
    setCustomApiBaseUrl('');
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2500);
  };

  const handleTestConnection = async () => {
    setTestStatus({ loading: true });
    const result = await testApiConnection();
    setTestStatus({
      loading: false,
      success: result.success,
      message: result.success ? 'Connected successfully! Backend is live.' : `Failed: ${result.message}`,
    });
  };

  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">System & API Settings</h1>
        <p className="text-xs text-slate-500 font-medium">Configure platform API endpoint, commission, tax percentages, and branding.</p>
      </div>

      {/* Backend API Configuration */}
      <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm space-y-4">
        <div className="flex items-center justify-between border-b border-slate-100 pb-3">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
              <Server className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-extrabold text-slate-900">Backend API Base URL</h3>
              <p className="text-[11px] text-slate-400">Configure where your web portal sends REST requests</p>
            </div>
          </div>
          <span className={`text-[11px] font-bold px-2.5 py-1 rounded-full ${
            apiUrl.includes('localhost')
              ? 'bg-amber-100 text-amber-800 border border-amber-200'
              : 'bg-emerald-100 text-emerald-800 border border-emerald-200'
          }`}>
            {apiUrl.includes('localhost') ? '⚠️ Localhost Mode' : '🌐 Production API'}
          </span>
        </div>

        <div>
          <label className="block text-xs font-bold text-slate-700 mb-1">
            API Base URL Endpoint
          </label>
          <div className="flex gap-2">
            <input
              type="text"
              value={apiUrl}
              onChange={(e) => setApiUrl(e.target.value)}
              placeholder="https://medicare-backend-api.onrender.com/api"
              className="flex-1 bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-semibold text-slate-800 focus:outline-none focus:border-blue-500"
            />
            <button
              onClick={handleSaveApiUrl}
              className="px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition shadow-sm"
            >
              {isSaved ? 'Saved!' : 'Save URL'}
            </button>
            <button
              onClick={handleResetApiUrl}
              className="px-3 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-xl text-xs font-semibold transition"
              title="Reset to default detected URL"
            >
              Reset
            </button>
          </div>
          <p className="text-[11px] text-slate-500 mt-1.5">
            Default Production URL: <code className="bg-slate-100 px-1 py-0.5 rounded text-blue-600 font-mono text-[10px]">https://medicare-backend-api.onrender.com/api</code>
          </p>
        </div>

        <div className="pt-2 flex flex-wrap items-center justify-between gap-3 border-t border-slate-100">
          <button
            onClick={handleTestConnection}
            disabled={testStatus?.loading}
            className="px-3.5 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition flex items-center gap-1.5"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${testStatus?.loading ? 'animate-spin' : ''}`} />
            Test API Connection
          </button>

          {testStatus && (
            <div className={`text-xs font-semibold flex items-center gap-1.5 px-3 py-1.5 rounded-xl ${
              testStatus.success
                ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                : 'bg-red-50 text-red-700 border border-red-200'
            }`}>
              {testStatus.success ? <CheckCircle2 className="w-4 h-4 text-emerald-600" /> : <AlertCircle className="w-4 h-4 text-red-600" />}
              {testStatus.message}
            </div>
          )}
        </div>
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
