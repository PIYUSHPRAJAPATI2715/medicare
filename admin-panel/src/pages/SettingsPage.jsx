import React, { useEffect, useState } from 'react';
import { Settings, Save, Plus, Trash2, Ticket, Sliders } from 'lucide-react';
import { apiService } from '../services/api';

export default function SettingsPage() {
  const [settings, setSettings] = useState(null);
  const [coupons, setCoupons] = useState([]);
  const [newCity, setNewCity] = useState('');
  const [newLanguage, setNewLanguage] = useState('');
  const [newCoupon, setNewCoupon] = useState({ code: '', discount: 50, minAmount: 200 });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    const res = await apiService.getSettings();
    if (res.success) {
      setSettings(res.data);
      setCoupons(res.coupons || []);
    }
  };

  const handleSaveSettings = async (e) => {
    e.preventDefault();
    const res = await apiService.updateSettings(settings);
    if (res.success) alert('System configuration updated successfully!');
  };

  const handleAddCity = () => {
    if (!newCity) return;
    setSettings({ ...settings, availableCities: [...settings.availableCities, newCity] });
    setNewCity('');
  };

  const handleRemoveCity = (city) => {
    setSettings({ ...settings, availableCities: settings.availableCities.filter(c => c !== city) });
  };

  const handleAddLanguage = () => {
    if (!newLanguage) return;
    setSettings({ ...settings, consultationLanguages: [...settings.consultationLanguages, newLanguage] });
    setNewLanguage('');
  };

  const handleRemoveLanguage = (lang) => {
    setSettings({ ...settings, consultationLanguages: settings.consultationLanguages.filter(l => l !== lang) });
  };

  const handleAddCouponSubmit = async (e) => {
    e.preventDefault();
    const res = await apiService.addCoupon(newCoupon);
    if (res.success) {
      setNewCoupon({ code: '', discount: 50, minAmount: 200 });
      loadData();
    }
  };

  const handleDeleteCoupon = async (code) => {
    await apiService.deleteCoupon(code);
    loadData();
  };

  if (!settings) return <div className="p-8 text-slate-500 font-medium">Loading System Config...</div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Dynamic App Configuration & Banners</h1>
          <p className="text-slate-500 text-sm mt-0.5">Control pricing, fees, available cities, languages & promotional coupons dynamically</p>
        </div>
        <button
          onClick={handleSaveSettings}
          className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold px-5 py-2.5 rounded-xl text-sm shadow-md shadow-emerald-500/20"
        >
          <Save className="w-4 h-4" /> Save All Config
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Platform Fees & GST Settings */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-sm space-y-4">
          <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <Sliders className="w-5 h-5 text-blue-600" /> Platform Fee & Tax Rates
          </h2>
          <div className="grid grid-cols-2 gap-4 pt-2">
            <div>
              <label className="block text-xs font-bold text-slate-600 mb-1">Platform Tech Fee (₹)</label>
              <input
                type="number"
                value={settings.platformFee}
                onChange={(e) => setSettings({ ...settings, platformFee: Number(e.target.value) })}
                className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-semibold"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-slate-600 mb-1">Applicable GST Rate (%)</label>
              <input
                type="number"
                value={settings.gstPercentage}
                onChange={(e) => setSettings({ ...settings, gstPercentage: Number(e.target.value) })}
                className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-semibold"
              />
            </div>
          </div>
          <div>
            <label className="block text-xs font-bold text-slate-600 mb-1">Support Contact Email</label>
            <input
              type="email"
              value={settings.contactEmail}
              onChange={(e) => setSettings({ ...settings, contactEmail: e.target.value })}
              className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
            />
          </div>
        </div>

        {/* Dynamic Cities Config */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-sm space-y-4">
          <h2 className="text-base font-bold text-slate-900">Available Cities Selector</h2>
          <div className="flex gap-2">
            <input
              type="text"
              placeholder="Add new city..."
              value={newCity}
              onChange={(e) => setNewCity(e.target.value)}
              className="flex-1 border border-slate-300 rounded-xl p-2 text-sm"
            />
            <button
              onClick={handleAddCity}
              className="px-4 py-2 bg-blue-600 text-white rounded-xl text-xs font-bold"
            >
              Add
            </button>
          </div>
          <div className="flex filter flex-wrap gap-2 pt-2">
            {settings.availableCities.map((city) => (
              <span key={city} className="inline-flex items-center gap-1.5 bg-blue-50 text-blue-700 font-bold px-3 py-1.5 rounded-xl text-xs">
                {city}
                <button onClick={() => handleRemoveCity(city)} className="text-blue-400 hover:text-blue-900">×</button>
              </span>
            ))}
          </div>
        </div>

        {/* Promo Coupons Engine */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200/80 shadow-sm space-y-4 lg:col-span-2">
          <h2 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <Ticket className="w-5 h-5 text-indigo-600" /> Active Promotional Discount Coupons
          </h2>
          <form onSubmit={handleAddCouponSubmit} className="grid grid-cols-1 sm:grid-cols-4 gap-3 bg-slate-50 p-4 rounded-xl">
            <input
              type="text"
              placeholder="Coupon Code"
              required
              value={newCoupon.code}
              onChange={(e) => setNewCoupon({ ...newCoupon, code: e.target.value })}
              className="border border-slate-300 rounded-xl p-2 text-xs font-bold uppercase"
            />
            <input
              type="number"
              placeholder="Discount (₹)"
              required
              value={newCoupon.discount}
              onChange={(e) => setNewCoupon({ ...newCoupon, discount: Number(e.target.value) })}
              className="border border-slate-300 rounded-xl p-2 text-xs"
            />
            <input
              type="number"
              placeholder="Min Order Amount (₹)"
              required
              value={newCoupon.minAmount}
              onChange={(e) => setNewCoupon({ ...newCoupon, minAmount: Number(e.target.value) })}
              className="border border-slate-300 rounded-xl p-2 text-xs"
            />
            <button type="submit" className="bg-indigo-600 text-white font-bold rounded-xl text-xs py-2">
              Add Coupon
            </button>
          </form>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2">
            {coupons.map((cp) => (
              <div key={cp.code} className="border border-slate-200 rounded-xl p-4 bg-slate-50 flex items-center justify-between">
                <div>
                  <span className="font-extrabold text-indigo-700 text-sm">{cp.code}</span>
                  <p className="text-xs text-slate-500">Save ₹{cp.discount} (Min ₹{cp.minAmount})</p>
                </div>
                <button onClick={() => handleDeleteCoupon(cp.code)} className="text-red-500 hover:bg-red-50 p-1.5 rounded-lg">
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
