import React, { useState } from 'react';
import {
  FileText,
  Truck,
  CheckCircle2,
  Clock,
  ExternalLink,
  Search,
  Filter,
  Package,
  Building,
  User,
  ShoppingBag
} from 'lucide-react';

const INITIAL_PRESCRIPTIONS = [
  {
    id: 'RX-84920',
    consultationId: 'CONS-9482',
    doctorName: 'Dr. Vipin Kumar Jain',
    doctorSpecialty: 'General Physician',
    patientName: 'Piyush Prajapati',
    patientPhone: '+91 98765 43210',
    patientAddress: 'Flat 402, Sunshine Heights, Malviya Nagar, Jaipur - 302017',
    diagnosis: 'Acute Upper Respiratory Tract Infection & Mild Bronchial Congestion',
    medicines: [
      { name: 'Augmentin 625 Duo', qty: '10 Tabs', dosage: '625 mg', price: 204.0 },
      { name: 'Dolo 650', qty: '15 Tabs', dosage: '650 mg', price: 33.5 },
      { name: 'Allegra 120mg', qty: '10 Tabs', dosage: '120 mg', price: 198.0 },
      { name: 'Alex Cough Syrup', qty: '1 Bottle', dosage: '100 ml', price: 145.0 }
    ],
    totalAmount: 495.5,
    issuedAt: 'Today, 02:15 PM',
    fulfillmentType: 'orderedOnline', // orderedOnline or buySelf
    pharmacyStatus: 'outForDelivery' // placed, packed, outForDelivery, delivered
  },
  {
    id: 'RX-84918',
    consultationId: 'CONS-9475',
    doctorName: 'Dr. Priya Sharma',
    doctorSpecialty: 'Dermatologist',
    patientName: 'Rahul Verma',
    patientPhone: '+91 98112 34567',
    patientAddress: 'B-12, Vaishali Nagar, Jaipur',
    diagnosis: 'Atopic Contact Dermatitis & Pruritus',
    medicines: [
      { name: 'Fluticasone Cream 0.05%', qty: '1 Tube', dosage: 'Apply BD', price: 185.0 },
      { name: 'Cetirizine 10mg', qty: '10 Tabs', dosage: '10 mg', price: 42.0 }
    ],
    totalAmount: 192.9,
    issuedAt: 'Today, 11:30 AM',
    fulfillmentType: 'buySelf',
    pharmacyStatus: 'none'
  },
  {
    id: 'RX-84910',
    consultationId: 'CONS-9440',
    doctorName: 'Dr. Rajesh Gupta',
    doctorSpecialty: 'Cardiologist',
    patientName: 'Sunita Meena',
    patientPhone: '+91 97840 55555',
    patientAddress: 'Sector 5, Mansarovar, Jaipur',
    diagnosis: 'Essential Hypertension Stage 1',
    medicines: [
      { name: 'Telmisartan 40mg', qty: '30 Tabs', dosage: '40 mg OD', price: 210.0 },
      { name: 'Amlodipine 5mg', qty: '30 Tabs', dosage: '5 mg OD', price: 68.0 }
    ],
    totalAmount: 236.3,
    issuedAt: 'Yesterday, 04:45 PM',
    fulfillmentType: 'orderedOnline',
    pharmacyStatus: 'delivered'
  }
];

export default function PrescriptionsManagementPage() {
  const [prescriptions, setPrescriptions] = useState(INITIAL_PRESCRIPTIONS);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');

  const filtered = prescriptions.filter((rx) => {
    const matchesSearch =
      rx.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      rx.patientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      rx.doctorName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      rx.diagnosis.toLowerCase().includes(searchTerm.toLowerCase());

    if (filterType === 'all') return matchesSearch;
    if (filterType === 'orderedOnline') return matchesSearch && rx.fulfillmentType === 'orderedOnline';
    if (filterType === 'buySelf') return matchesSearch && rx.fulfillmentType === 'buySelf';
    return matchesSearch;
  });

  const handleUpdateStatus = (rxId, newStatus) => {
    setPrescriptions(
      prescriptions.map((rx) =>
        rx.id === rxId ? { ...rx, pharmacyStatus: newStatus } : rx
      )
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <span className="text-[10px] font-extrabold uppercase tracking-wider text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">
            Post-Consultation & Pharmacy Fulfillment
          </span>
          <h1 className="text-2xl font-black text-slate-900 mt-1">Digital Prescriptions & Tablets</h1>
          <p className="text-xs text-slate-500 font-medium">
            Monitor digital prescriptions sent after calls/chats and track tablet delivery dispatch or self-purchase options.
          </p>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by Rx ID, patient, doctor, or diagnosis..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-9 pr-4 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
          />
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <button
            onClick={() => setFilterType('all')}
            className={`px-3 py-1.5 rounded-xl text-xs font-bold transition ${
              filterType === 'all'
                ? 'bg-blue-600 text-white shadow-sm'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            All Prescriptions
          </button>
          <button
            onClick={() => setFilterType('orderedOnline')}
            className={`px-3 py-1.5 rounded-xl text-xs font-bold transition flex items-center gap-1.5 ${
              filterType === 'orderedOnline'
                ? 'bg-emerald-600 text-white shadow-sm'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            <Truck className="w-3.5 h-3.5" /> Ordered for Home Delivery
          </button>
          <button
            onClick={() => setFilterType('buySelf')}
            className={`px-3 py-1.5 rounded-xl text-xs font-bold transition flex items-center gap-1.5 ${
              filterType === 'buySelf'
                ? 'bg-purple-600 text-white shadow-sm'
                : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
            }`}
          >
            <ShoppingBag className="w-3.5 h-3.5" /> Chemist / Self Purchase
          </button>
        </div>
      </div>

      {/* Prescriptions List */}
      <div className="space-y-4">
        {filtered.map((rx) => (
          <div
            key={rx.id}
            className="bg-white rounded-3xl border border-slate-200 p-6 shadow-sm hover:shadow-md transition"
          >
            <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="p-3 bg-blue-50 text-blue-600 rounded-2xl">
                  <FileText className="w-6 h-6" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-black text-slate-900">{rx.id}</span>
                    <span className="text-[10px] font-bold text-slate-400 bg-slate-100 px-2 py-0.5 rounded">
                      {rx.consultationId}
                    </span>
                    <span className="text-[10px] text-slate-400 font-semibold">{rx.issuedAt}</span>
                  </div>
                  <div className="text-xs font-bold text-slate-700 mt-0.5">
                    {rx.patientName} ({rx.patientPhone})
                  </div>
                </div>
              </div>

              {/* Status Badge */}
              <div>
                {rx.fulfillmentType === 'orderedOnline' ? (
                  <div className="flex items-center gap-2">
                    <span className="px-3 py-1 rounded-xl text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1.5">
                      <Truck className="w-3.5 h-3.5" /> Home Delivery
                    </span>
                    <select
                      value={rx.pharmacyStatus}
                      onChange={(e) => handleUpdateStatus(rx.id, e.target.value)}
                      className="bg-slate-50 border border-slate-200 rounded-xl px-2.5 py-1 text-xs font-bold text-slate-700 focus:outline-none"
                    >
                      <option value="placed">Order Placed</option>
                      <option value="packed">Medicines Packed</option>
                      <option value="outForDelivery">Out For Delivery</option>
                      <option value="delivered">Delivered to Patient</option>
                    </select>
                  </div>
                ) : (
                  <span className="px-3 py-1 rounded-xl text-xs font-bold bg-purple-50 text-purple-700 border border-purple-200 flex items-center gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5" /> Patient Buys by Themselves
                  </span>
                )}
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 my-4">
              <div>
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-1">
                  Doctor & Diagnosis:
                </span>
                <p className="text-xs font-bold text-slate-800">
                  {rx.doctorName} · <span className="text-blue-600">{rx.doctorSpecialty}</span>
                </p>
                <p className="text-xs font-medium text-slate-600 mt-1 italic">
                  "{rx.diagnosis}"
                </p>
                {rx.fulfillmentType === 'orderedOnline' && (
                  <p className="text-[11px] text-slate-500 font-medium mt-2">
                    📍 Delivery Address: {rx.patientAddress}
                  </p>
                )}
              </div>

              <div>
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-1">
                  Prescribed Tablets & Items:
                </span>
                <div className="space-y-1">
                  {rx.medicines.map((m, idx) => (
                    <div key={idx} className="flex justify-between text-xs font-semibold text-slate-700 bg-slate-50 px-3 py-1.5 rounded-lg">
                      <span>{m.name} ({m.qty})</span>
                      <span className="text-slate-500">₹{m.price.toFixed(1)}</span>
                    </div>
                  ))}
                </div>
                <div className="text-right text-xs font-black text-slate-900 mt-2">
                  Total Rx Amount: ₹{rx.totalAmount.toFixed(1)}
                </div>
              </div>
            </div>
          </div>
        ))}

        {filtered.length === 0 && (
          <div className="text-center py-12 bg-white rounded-3xl border border-slate-200 p-8">
            <Package className="w-12 h-12 text-slate-300 mx-auto mb-3" />
            <h4 className="text-sm font-bold text-slate-700">No prescriptions found</h4>
            <p className="text-xs text-slate-400 mt-1">Try refining your search filter.</p>
          </div>
        )}
      </div>
    </div>
  );
}
