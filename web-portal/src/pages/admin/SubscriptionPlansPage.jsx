import React, { useState, useEffect } from 'react';
import {
  CreditCard,
  Plus,
  Check,
  X,
  Edit2,
  Trash2,
  ShieldCheck,
  Zap,
  Users,
  TrendingUp,
  Lock,
  Sparkles
} from 'lucide-react';

const INITIAL_PLANS = [
  {
    id: 'plan_starter',
    name: 'Starter Care Pass',
    tagline: 'Ideal for immediate doctor consultation & quick recovery',
    price: 199,
    originalPrice: 499,
    durationDays: 30,
    durationLabel: '1 Month',
    consultationLimit: 3,
    isPopular: false,
    badgeText: 'AFFORDABLE',
    isActive: true,
    subscribersCount: 1420,
    features: [
      '3 Video or Audio Consultations with top doctors',
      '24/7 Unlimited Doctor Chat & Follow-ups',
      'Official Digital Prescriptions with instant download',
      '10% Flat Discount on all pharmacy tablet orders',
      'Free home medicine delivery on orders above ₹199'
    ]
  },
  {
    id: 'plan_gold',
    name: 'Gold Family Shield',
    tagline: 'Complete year-round coverage for up to 4 family members',
    price: 699,
    originalPrice: 1999,
    durationDays: 180,
    durationLabel: '6 Months',
    consultationLimit: -1, // Unlimited
    isPopular: true,
    badgeText: 'MOST POPULAR',
    isActive: true,
    subscribersCount: 3840,
    features: [
      'Unlimited 24/7 Video & Audio Consultations',
      'Direct connection to MD Specialists & Super-specialists',
      'Family coverage for up to 4 family profiles',
      'Instant Electronic Rx with Priority Pharmacy Dispatch',
      '20% Off all prescribed tablets & medicines',
      'Priority 2-hour doorstep tablet delivery',
      '₹0 Convenience fees on all appointments'
    ]
  },
  {
    id: 'plan_platinum',
    name: 'Platinum 365 SuperCare',
    tagline: 'Premium VIP medical access, full health checkups & 1-year coverage',
    price: 1299,
    originalPrice: 3499,
    durationDays: 365,
    durationLabel: '1 Year',
    consultationLimit: -1, // Unlimited
    isPopular: false,
    badgeText: 'BEST VALUE',
    isActive: true,
    subscribersCount: 2150,
    features: [
      'Unlimited Consultations for the entire year (365 Days)',
      'Full Comprehensive Annual Health Checkup Included (62 Tests)',
      'VIP Priority Doctor Routing within 60 seconds',
      'Dedicated Personal Health Care Manager',
      '25% Off on all prescribed medicines & diagnostic tests',
      'Free doorstep sample collection & free express delivery'
    ]
  }
];

export default function SubscriptionPlansPage() {
  const [plans, setPlans] = useState(() => {
    const saved = localStorage.getItem('medicare_subscription_plans');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {
        console.error('Error parsing plans:', e);
      }
    }
    return INITIAL_PLANS;
  });

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingPlan, setEditingPlan] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    tagline: '',
    price: '',
    originalPrice: '',
    durationDays: '30',
    durationLabel: '1 Month',
    consultationLimit: '-1',
    badgeText: '',
    isPopular: false,
    isActive: true,
    featuresText: ''
  });

  useEffect(() => {
    localStorage.setItem('medicare_subscription_plans', JSON.stringify(plans));
  }, [plans]);

  const totalSubscribers = plans.reduce((acc, p) => acc + (p.subscribersCount || 0), 0);
  const estimatedRevenue = plans.reduce((acc, p) => acc + (p.price * (p.subscribersCount || 0)), 0);

  const handleOpenAdd = () => {
    setEditingPlan(null);
    setFormData({
      name: '',
      tagline: '',
      price: '',
      originalPrice: '',
      durationDays: '30',
      durationLabel: '1 Month',
      consultationLimit: '-1',
      badgeText: '',
      isPopular: false,
      isActive: true,
      featuresText: 'Unlimited 24/7 Video & Audio Consultations\nInstant Electronic Prescriptions\n15% Off all prescribed tablets'
    });
    setIsModalOpen(true);
  };

  const handleOpenEdit = (plan) => {
    setEditingPlan(plan);
    setFormData({
      name: plan.name,
      tagline: plan.tagline,
      price: plan.price.toString(),
      originalPrice: plan.originalPrice.toString(),
      durationDays: plan.durationDays.toString(),
      durationLabel: plan.durationLabel,
      consultationLimit: plan.consultationLimit.toString(),
      badgeText: plan.badgeText || '',
      isPopular: plan.isPopular || false,
      isActive: plan.isActive !== false,
      featuresText: (plan.features || []).join('\n')
    });
    setIsModalOpen(true);
  };

  const handleDelete = (id) => {
    if (window.confirm('Are you sure you want to delete this subscription plan?')) {
      setPlans(plans.filter((p) => p.id !== id));
    }
  };

  const handleToggleActive = (id) => {
    setPlans(
      plans.map((p) => (p.id === id ? { ...p, isActive: !p.isActive } : p))
    );
  };

  const handleSavePlan = (e) => {
    e.preventDefault();
    const features = formData.featuresText
      .split('\n')
      .map((f) => f.trim())
      .filter(Boolean);

    const planPayload = {
      id: editingPlan ? editingPlan.id : `plan_${Date.now()}`,
      name: formData.name,
      tagline: formData.tagline,
      price: parseFloat(formData.price) || 199,
      originalPrice: parseFloat(formData.originalPrice) || parseFloat(formData.price) * 2,
      durationDays: parseInt(formData.durationDays, 10) || 30,
      durationLabel: formData.durationLabel,
      consultationLimit: parseInt(formData.consultationLimit, 10),
      badgeText: formData.badgeText.trim() || null,
      isPopular: formData.isPopular,
      isActive: formData.isActive,
      subscribersCount: editingPlan ? editingPlan.subscribersCount : 0,
      features: features.length > 0 ? features : ['Unlimited Doctor Consultations', 'Free Digital Rx']
    };

    if (editingPlan) {
      setPlans(plans.map((p) => (p.id === editingPlan.id ? planPayload : p)));
    } else {
      setPlans([...plans, planPayload]);
    }

    setIsModalOpen(false);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <span className="text-[10px] font-extrabold uppercase tracking-wider text-amber-600 bg-amber-50 px-2 py-0.5 rounded">
            Admin Monetization & Paywall
          </span>
          <h1 className="text-2xl font-black text-slate-900 mt-1">Subscription Plans Manager</h1>
          <p className="text-xs text-slate-500 font-medium">
            Manage plans, pricing, and consult limits. Unsubscribed patients are automatically intercepted and asked to subscribe before calling or chatting.
          </p>
        </div>

        <button
          onClick={handleOpenAdd}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-amber-600 hover:bg-amber-700 text-white rounded-xl text-xs font-bold shadow-md shadow-amber-600/20 transition"
        >
          <Plus className="w-4 h-4" />
          Create New Plan
        </button>
      </div>

      {/* Paywall Rule Alert Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-2xl p-4 flex items-start gap-3">
        <div className="p-2 bg-blue-600 text-white rounded-xl">
          <Lock className="w-4 h-4" />
        </div>
        <div className="flex-1">
          <h4 className="text-xs font-bold text-blue-900 uppercase tracking-wide">
            Paywall Enforcement Active
          </h4>
          <p className="text-xs text-blue-700 font-medium mt-0.5">
            When patients tap to connect (Video Call, Audio Call, or Chat) without an active subscription, they are prompted to purchase one of the active plans configured here.
          </p>
        </div>
      </div>

      {/* Overview Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white border border-slate-200 rounded-2xl p-4 shadow-sm flex items-center gap-3">
          <div className="p-3 bg-amber-50 text-amber-600 rounded-xl">
            <CreditCard className="w-5 h-5" />
          </div>
          <div>
            <div className="text-2xl font-black text-slate-900">{plans.length}</div>
            <div className="text-xs font-bold text-slate-400 uppercase tracking-wider">Total Plans ({plans.filter(p => p.isActive).length} Active)</div>
          </div>
        </div>

        <div className="bg-white border border-slate-200 rounded-2xl p-4 shadow-sm flex items-center gap-3">
          <div className="p-3 bg-blue-50 text-blue-600 rounded-xl">
            <Users className="w-5 h-5" />
          </div>
          <div>
            <div className="text-2xl font-black text-slate-900">{totalSubscribers.toLocaleString()}</div>
            <div className="text-xs font-bold text-slate-400 uppercase tracking-wider">Active Subscribers</div>
          </div>
        </div>

        <div className="bg-white border border-slate-200 rounded-2xl p-4 shadow-sm flex items-center gap-3">
          <div className="p-3 bg-emerald-50 text-emerald-600 rounded-xl">
            <TrendingUp className="w-5 h-5" />
          </div>
          <div>
            <div className="text-2xl font-black text-slate-900">₹{estimatedRevenue.toLocaleString()}</div>
            <div className="text-xs font-bold text-slate-400 uppercase tracking-wider">Estimated Revenue</div>
          </div>
        </div>
      </div>

      {/* Plans List Grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {plans.map((plan) => {
          const discount = Math.round(((plan.originalPrice - plan.price) / plan.originalPrice) * 100);

          return (
            <div
              key={plan.id}
              className={`bg-white rounded-3xl border ${
                plan.isPopular ? 'border-amber-400 ring-2 ring-amber-400/20' : 'border-slate-200'
              } p-6 shadow-sm flex flex-col justify-between relative transition-all ${
                !plan.isActive ? 'opacity-60 bg-slate-50' : ''
              }`}
            >
              {plan.badgeText && (
                <div className="absolute -top-3 right-6 bg-gradient-to-r from-amber-500 to-amber-600 text-white text-[10px] font-black uppercase px-3 py-1 rounded-full shadow-sm">
                  {plan.badgeText}
                </div>
              )}

              <div>
                <div className="flex items-center justify-between mb-2">
                  <h3 className="text-lg font-black text-slate-900">{plan.name}</h3>
                  <button
                    onClick={() => handleToggleActive(plan.id)}
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      plan.isActive
                        ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                        : 'bg-slate-200 text-slate-600'
                    }`}
                  >
                    {plan.isActive ? 'Active' : 'Disabled'}
                  </button>
                </div>

                <p className="text-xs text-slate-500 font-medium mb-4">{plan.tagline}</p>

                <div className="flex items-baseline gap-2 mb-4 pb-4 border-b border-slate-100">
                  <span className="text-3xl font-black text-slate-900">₹{plan.price}</span>
                  <span className="text-sm font-bold text-slate-400 line-through">₹{plan.originalPrice}</span>
                  <span className="text-xs font-extrabold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">
                    {discount}% OFF
                  </span>
                  <span className="text-xs text-slate-400 font-semibold ml-auto">{plan.durationLabel}</span>
                </div>

                <div className="mb-4">
                  <span className="text-[11px] font-bold text-slate-600 bg-slate-100 px-2.5 py-1 rounded-lg">
                    {plan.consultationLimit <= 0
                      ? '⚡ Unlimited Consultations'
                      : `📞 ${plan.consultationLimit} Consultations Allowed`}
                  </span>
                </div>

                <div className="space-y-2 mb-6">
                  <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400">Included Perks:</div>
                  {(plan.features || []).map((feat, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-xs font-medium text-slate-700">
                      <Check className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
                      <span>{feat}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="pt-4 border-t border-slate-100 flex items-center justify-between">
                <span className="text-xs font-bold text-slate-500">
                  {plan.subscribersCount || 0} Subscribers
                </span>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => handleOpenEdit(plan)}
                    className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition"
                    title="Edit Plan"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(plan.id)}
                    className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-xl transition"
                    title="Delete Plan"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Add / Edit Plan Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-5 pb-3 border-b border-slate-100">
              <h3 className="text-base font-extrabold text-slate-900">
                {editingPlan ? 'Edit Subscription Plan' : 'Create New Subscription Plan'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSavePlan} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Plan Name *</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Starter Health Pass"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Tagline / Short Description</label>
                <input
                  type="text"
                  placeholder="e.g. Best for individuals & instant consultations"
                  value={formData.tagline}
                  onChange={(e) => setFormData({ ...formData, tagline: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Discounted Price (₹) *</label>
                  <input
                    type="number"
                    required
                    placeholder="199"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Original Price (₹) *</label>
                  <input
                    type="number"
                    required
                    placeholder="499"
                    value={formData.originalPrice}
                    onChange={(e) => setFormData({ ...formData, originalPrice: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Duration Label</label>
                  <input
                    type="text"
                    placeholder="1 Month / 6 Months / 1 Year"
                    value={formData.durationLabel}
                    onChange={(e) => setFormData({ ...formData, durationLabel: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Consultation Limit</label>
                  <input
                    type="number"
                    placeholder="-1 for Unlimited"
                    value={formData.consultationLimit}
                    onChange={(e) => setFormData({ ...formData, consultationLimit: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                  />
                  <span className="text-[10px] text-slate-400">Enter -1 for unlimited consultations</span>
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Badge Text (Optional)</label>
                <input
                  type="text"
                  placeholder="e.g. MOST POPULAR, BEST VALUE"
                  value={formData.badgeText}
                  onChange={(e) => setFormData({ ...formData, badgeText: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">
                  Features & Perks (One per line)
                </label>
                <textarea
                  rows={4}
                  value={formData.featuresText}
                  onChange={(e) => setFormData({ ...formData, featuresText: e.target.value })}
                  placeholder="Unlimited Video & Audio Consultations&#10;Instant Electronic Rx&#10;15% Off all medicines"
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs font-medium focus:outline-none focus:border-amber-500"
                />
              </div>

              <div className="flex items-center gap-6 pt-2">
                <label className="flex items-center gap-2 cursor-pointer text-xs font-bold text-slate-700">
                  <input
                    type="checkbox"
                    checked={formData.isPopular}
                    onChange={(e) => setFormData({ ...formData, isPopular: e.target.checked })}
                    className="rounded text-amber-600 focus:ring-amber-500"
                  />
                  Mark as Popular Plan
                </label>

                <label className="flex items-center gap-2 cursor-pointer text-xs font-bold text-slate-700">
                  <input
                    type="checkbox"
                    checked={formData.isActive}
                    onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                    className="rounded text-emerald-600 focus:ring-emerald-500"
                  />
                  Active (Visible to Patients)
                </label>
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2.5 border border-slate-200 rounded-xl text-xs font-bold text-slate-600 hover:bg-slate-50 transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-amber-600 hover:bg-amber-700 text-white rounded-xl text-xs font-bold shadow-md shadow-amber-600/20 transition"
                >
                  {editingPlan ? 'Save Changes' : 'Create Plan'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
