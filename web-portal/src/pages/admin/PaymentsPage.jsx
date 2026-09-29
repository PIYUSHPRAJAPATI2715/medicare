import React, { useState, useEffect } from 'react';
import { fetchPayments } from '../../services/api';
import {
  CreditCard,
  Search,
  CheckCircle2,
  DollarSign,
  TrendingUp,
  RefreshCw,
  ShieldCheck,
  User,
  Phone,
  Mail,
  Copy,
  Check,
  Calendar,
  ExternalLink,
  Layers,
  ArrowUpRight
} from 'lucide-react';

export default function PaymentsPage() {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [copiedId, setCopiedId] = useState(null);
  const [selectedTxn, setSelectedTxn] = useState(null);

  const loadPayments = async (isBackground = false) => {
    if (!isBackground) setLoading(true);
    try {
      const res = await fetchPayments();
      if (res && res.data && Array.isArray(res.data)) {
        setPayments(res.data);
      }
    } catch (err) {
      console.warn('Error fetching payments:', err);
    } finally {
      if (!isBackground) setLoading(false);
    }
  };

  useEffect(() => {
    loadPayments();
    // Auto-poll payments every 4 seconds
    const timer = setInterval(() => {
      loadPayments(true);
    }, 4000);

    const onFocus = () => loadPayments(true);
    window.addEventListener('focus', onFocus);

    return () => {
      clearInterval(timer);
      window.removeEventListener('focus', onFocus);
    };
  }, []);

  const copyToClipboard = (text, id) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const totalRevenue = payments.reduce((sum, p) => sum + (Number(p.amount) || 0), 0);
  const subscriptionPayments = payments.filter(p => p.type === 'subscription');
  const consultationPayments = payments.filter(p => p.type === 'consultation');

  const filtered = payments.filter((p) => {
    const matchesSearch =
      (p.userName || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.userEmail || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.userPhone || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.razorpayPaymentId || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.razorpayOrderId || '').toLowerCase().includes(search.toLowerCase()) ||
      (p.purpose || '').toLowerCase().includes(search.toLowerCase());

    if (filterType === 'all') return matchesSearch;
    if (filterType === 'subscription') return matchesSearch && p.type === 'subscription';
    if (filterType === 'consultation') return matchesSearch && p.type === 'consultation';
    return matchesSearch;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Payments & Revenue Engine</h1>
            <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-blue-100 text-blue-800 border border-blue-200">
              Razorpay Live
            </span>
          </div>
          <p className="text-xs text-slate-500 font-medium">Real-time Razorpay transaction records, subscription paywall revenue, and settlements.</p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={loadPayments}
            disabled={loading}
            className="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-sm"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>
        </div>
      </div>

      {/* Analytics KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="p-3 bg-emerald-500 text-white rounded-xl">
            <DollarSign className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500">Total Captured Revenue</p>
            <h3 className="text-xl font-extrabold text-slate-900 mt-0.5">₹{totalRevenue.toLocaleString('en-IN')}</h3>
            <p className="text-[11px] font-bold text-emerald-600 mt-0.5">100% Settled</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="p-3 bg-blue-500 text-white rounded-xl">
            <ShieldCheck className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500">Care Plan Subscriptions</p>
            <h3 className="text-xl font-extrabold text-slate-900 mt-0.5">{subscriptionPayments.length} Plans</h3>
            <p className="text-[11px] font-bold text-blue-600 mt-0.5">Gold & Starter Passes</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="p-3 bg-indigo-500 text-white rounded-xl">
            <CreditCard className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500">Total Transactions</p>
            <h3 className="text-xl font-extrabold text-slate-900 mt-0.5">{payments.length}</h3>
            <p className="text-[11px] font-bold text-indigo-600 mt-0.5">Razorpay Gateway</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="p-3 bg-amber-500 text-white rounded-xl">
            <Layers className="w-6 h-6" />
          </div>
          <div>
            <p className="text-xs font-semibold text-slate-500">Consultation Bookings</p>
            <h3 className="text-xl font-extrabold text-slate-900 mt-0.5">{consultationPayments.length}</h3>
            <p className="text-[11px] font-bold text-amber-600 mt-0.5">Direct Telehealth Fees</p>
          </div>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by patient, Razorpay ID, phone..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
          />
        </div>

        <div className="flex items-center gap-1.5 bg-slate-100 p-1 rounded-xl self-stretch sm:self-auto">
          {[
            { id: 'all', label: 'All Payments' },
            { id: 'subscription', label: 'Care Plans' },
            { id: 'consultation', label: 'Consultations' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setFilterType(tab.id)}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold transition ${
                filterType === tab.id
                  ? 'bg-white text-slate-900 shadow-sm'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Transactions Table */}
      {filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-500 shadow-sm">
          <CreditCard className="w-10 h-10 text-slate-300 mx-auto mb-2" />
          <p className="text-sm font-bold text-slate-700">No payment transactions found</p>
          <p className="text-xs text-slate-400 mt-1">Transactions will appear here automatically when patients subscribe or book consultations.</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-[11px] font-extrabold text-slate-500 uppercase tracking-wider">
                  <th className="py-3.5 px-4">Patient / User</th>
                  <th className="py-3.5 px-4">Service / Plan</th>
                  <th className="py-3.5 px-4">Amount</th>
                  <th className="py-3.5 px-4">Razorpay Reference</th>
                  <th className="py-3.5 px-4">Payment Method</th>
                  <th className="py-3.5 px-4">Status</th>
                  <th className="py-3.5 px-4">Timestamp</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs font-medium">
                {filtered.map((p) => (
                  <tr
                    key={p.id}
                    onClick={() => setSelectedTxn(p)}
                    className="hover:bg-slate-50/80 transition cursor-pointer"
                  >
                    <td className="py-3.5 px-4">
                      <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center font-bold text-xs">
                          {(p.userName || 'P')[0]}
                        </div>
                        <div>
                          <p className="font-bold text-slate-900">{p.userName || 'Patient'}</p>
                          <p className="text-[10px] text-slate-500">{p.userPhone || p.userEmail || p.userId}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-3.5 px-4">
                      <div>
                        <p className="font-bold text-slate-800">{p.planName || p.purpose || 'Doctor Consultation'}</p>
                        <span className="text-[10px] font-extrabold uppercase tracking-wider text-slate-400">
                          {p.type || 'Service'}
                        </span>
                      </div>
                    </td>
                    <td className="py-3.5 px-4 font-black text-slate-900 text-sm">
                      ₹{Number(p.amount).toLocaleString('en-IN')}
                    </td>
                    <td className="py-3.5 px-4">
                      <div className="flex items-center gap-1.5 font-mono text-[11px] text-slate-600">
                        <span>{p.razorpayPaymentId || p.id}</span>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            copyToClipboard(p.razorpayPaymentId || p.id, p.id);
                          }}
                          className="p-1 hover:bg-slate-200 rounded text-slate-400 hover:text-slate-600 transition"
                        >
                          {copiedId === p.id ? <Check className="w-3 h-3 text-emerald-600" /> : <Copy className="w-3 h-3" />}
                        </button>
                      </div>
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-slate-700">
                      {p.paymentMethod || 'Razorpay UPI'}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-extrabold bg-emerald-100 text-emerald-800 capitalize">
                        <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                        {p.status || 'Captured'}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-slate-500 text-[11px]">
                      {p.createdAt ? new Date(p.createdAt).toLocaleString('en-IN', { dateStyle: 'medium', timeStyle: 'short' }) : 'Recently'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Transaction Details Modal */}
      {selectedTxn && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="p-2 bg-emerald-50 text-emerald-600 rounded-xl">
                  <CreditCard className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">Razorpay Transaction Details</h2>
                  <p className="text-[11px] text-slate-500 font-mono">{selectedTxn.razorpayPaymentId || selectedTxn.id}</p>
                </div>
              </div>
              <button
                onClick={() => setSelectedTxn(null)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100"
              >
                ✕
              </button>
            </div>

            <div className="space-y-3 text-xs">
              <div className="bg-slate-50 p-3 rounded-xl flex justify-between items-center">
                <span className="font-semibold text-slate-500">Amount Paid</span>
                <span className="text-base font-black text-slate-900">₹{selectedTxn.amount}</span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-slate-600">
                <div className="bg-slate-50 p-2.5 rounded-xl">
                  <p className="text-[10px] text-slate-400 font-bold uppercase">Patient</p>
                  <p className="font-bold text-slate-900">{selectedTxn.userName}</p>
                  <p className="text-[11px]">{selectedTxn.userPhone || selectedTxn.userEmail}</p>
                </div>
                <div className="bg-slate-50 p-2.5 rounded-xl">
                  <p className="text-[10px] text-slate-400 font-bold uppercase">Status</p>
                  <p className="font-bold text-emerald-600 capitalize">{selectedTxn.status}</p>
                  <p className="text-[11px]">Via {selectedTxn.paymentMethod}</p>
                </div>
              </div>

              <div className="bg-slate-50 p-2.5 rounded-xl space-y-1 font-mono text-[11px]">
                <p><span className="text-slate-400">Order ID:</span> {selectedTxn.razorpayOrderId || 'N/A'}</p>
                <p><span className="text-slate-400">Payment ID:</span> {selectedTxn.razorpayPaymentId || 'N/A'}</p>
                <p><span className="text-slate-400">Purpose:</span> {selectedTxn.purpose}</p>
              </div>
            </div>

            <div className="pt-2 flex justify-end">
              <button
                onClick={() => setSelectedTxn(null)}
                className="px-4 py-2 bg-slate-900 text-white rounded-xl text-xs font-bold"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
