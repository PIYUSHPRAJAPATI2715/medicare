import React, { useState, useEffect } from 'react';
import { fetchDoctors, fetchPendingDoctors, verifyDoctor } from '../../services/api';
import { CheckCircle2, XCircle, FileText, ExternalLink, ShieldCheck, Clock, Search } from 'lucide-react';

export default function DoctorsApprovalPage() {
  const [activeTab, setActiveTab] = useState('all'); // 'all' | 'pending'
  const [doctors, setDoctors] = useState([]);
  const [pendingDoctors, setPendingDoctors] = useState([]);
  const [selectedDoctor, setSelectedDoctor] = useState(null);
  const [rejectionNotes, setRejectionNotes] = useState('');
  const [search, setSearch] = useState('');

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const docRes = await fetchDoctors();
      if (docRes.data) setDoctors(docRes.data);

      const pendingRes = await fetchPendingDoctors();
      if (pendingRes.data) setPendingDoctors(pendingRes.data);
    } catch (e) {
      console.error('Error fetching doctors:', e);
    }
  };

  const handleVerify = async (id, status) => {
    try {
      await verifyDoctor(id, status, status === 'rejected' ? rejectionNotes : 'Verified & Approved by Admin');
      setSelectedDoctor(null);
      setRejectionNotes('');
      loadData();
    } catch (e) {
      alert('Verification failed. Try again.');
    }
  };

  const displayList = activeTab === 'all' ? doctors : pendingDoctors;
  const filtered = displayList.filter(d => d.name.toLowerCase().includes(search.toLowerCase()) || d.specialty.toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Doctor Management & Medical Verification</h1>
          <p className="text-xs text-slate-500 font-medium">Verify MCI / State Council registrations, degree certificates, and clinic identity proofs.</p>
        </div>
        <div className="flex bg-slate-200 p-1 rounded-xl">
          <button
            onClick={() => setActiveTab('all')}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition ${activeTab === 'all' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-600 hover:text-slate-900'}`}
          >
            All Doctors ({doctors.length})
          </button>
          <button
            onClick={() => setActiveTab('pending')}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition flex items-center gap-1.5 ${activeTab === 'pending' ? 'bg-amber-600 text-white shadow-sm' : 'text-slate-600 hover:text-slate-900'}`}
          >
            <Clock className="w-3.5 h-3.5" />
            Pending Verification ({pendingDoctors.length})
          </button>
        </div>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          placeholder="Search by doctor name or specialty..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
        />
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-slate-50 border-b border-slate-200 text-[11px] font-extrabold text-slate-500 uppercase tracking-wider">
              <th className="py-3.5 px-4">Doctor Details</th>
              <th className="py-3.5 px-4">Specialty & Exp</th>
              <th className="py-3.5 px-4">Medical Registration</th>
              <th className="py-3.5 px-4">Fee</th>
              <th className="py-3.5 px-4">Verification Status</th>
              <th className="py-3.5 px-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-xs font-medium">
            {filtered.map((doc) => (
              <tr key={doc.id} className="hover:bg-slate-50/80 transition">
                <td className="py-3.5 px-4">
                  <div className="flex items-center gap-3">
                    <img src={doc.imageUrl} alt={doc.name} className="w-10 h-10 rounded-full object-cover border border-slate-200" />
                    <div>
                      <p className="font-bold text-slate-900">{doc.name}</p>
                      <p className="text-[11px] text-slate-500">{doc.qualification}</p>
                    </div>
                  </div>
                </td>
                <td className="py-3.5 px-4">
                  <span className="font-semibold text-slate-800">{doc.specialty}</span>
                  <p className="text-[11px] text-slate-500">{doc.experienceYears} Years Exp</p>
                </td>
                <td className="py-3.5 px-4">
                  <p className="font-mono text-slate-800 font-bold">{doc.medicalLicenseNo || 'MCI-REG-8821'}</p>
                  <p className="text-[11px] text-slate-500">{doc.stateMedicalCouncil || 'Delhi Medical Council'}</p>
                </td>
                <td className="py-3.5 px-4 font-bold text-slate-900">₹{doc.consultationFee}</td>
                <td className="py-3.5 px-4">
                  <span className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold capitalize inline-flex items-center gap-1 ${
                    doc.verificationStatus === 'approved'
                      ? 'bg-emerald-100 text-emerald-800'
                      : doc.verificationStatus === 'rejected'
                      ? 'bg-red-100 text-red-800'
                      : 'bg-amber-100 text-amber-800'
                  }`}>
                    {doc.verificationStatus || 'approved'}
                  </span>
                </td>
                <td className="py-3.5 px-4 text-right">
                  <button
                    onClick={() => setSelectedDoctor(doc)}
                    className="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-lg text-xs font-bold transition flex items-center gap-1 ml-auto"
                  >
                    <FileText className="w-3.5 h-3.5" />
                    Inspect Documents
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Document Inspection Modal */}
      {selectedDoctor && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 shadow-2xl space-y-5 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-start border-b border-slate-100 pb-4">
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-blue-600 bg-blue-50 px-2 py-0.5 rounded">
                  Medical License Audit
                </span>
                <h3 className="text-lg font-black text-slate-900 mt-1">{selectedDoctor.name}</h3>
                <p className="text-xs text-slate-500">{selectedDoctor.specialty} · {selectedDoctor.qualification}</p>
              </div>
              <button onClick={() => setSelectedDoctor(null)} className="text-slate-400 hover:text-slate-600 text-xl font-bold">×</button>
            </div>

            {/* Document Proof Links */}
            <div className="space-y-3">
              <h4 className="text-xs font-extrabold uppercase tracking-wider text-slate-500">Submitted Documentation Proofs</h4>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <a href={selectedDoctor.qualificationCertUrl || selectedDoctor.imageUrl} target="_blank" rel="noreferrer" className="p-3 bg-slate-50 border border-slate-200 rounded-xl flex items-center justify-between text-xs font-bold text-slate-700 hover:border-blue-500 transition">
                  <span>Degree Certificate</span>
                  <ExternalLink className="w-3.5 h-3.5 text-blue-600" />
                </a>
                <a href={selectedDoctor.idProofUrl || selectedDoctor.imageUrl} target="_blank" rel="noreferrer" className="p-3 bg-slate-50 border border-slate-200 rounded-xl flex items-center justify-between text-xs font-bold text-slate-700 hover:border-blue-500 transition">
                  <span>Identity Proof (ID)</span>
                  <ExternalLink className="w-3.5 h-3.5 text-blue-600" />
                </a>
                <a href={selectedDoctor.clinicAddressProofUrl || selectedDoctor.imageUrl} target="_blank" rel="noreferrer" className="p-3 bg-slate-50 border border-slate-200 rounded-xl flex items-center justify-between text-xs font-bold text-slate-700 hover:border-blue-500 transition">
                  <span>Clinic License</span>
                  <ExternalLink className="w-3.5 h-3.5 text-blue-600" />
                </a>
              </div>
            </div>

            {/* Verification Controls */}
            <div className="pt-4 border-t border-slate-100 space-y-3">
              <textarea
                placeholder="Optional notes or rejection rationale..."
                value={rejectionNotes}
                onChange={(e) => setRejectionNotes(e.target.value)}
                className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-xs font-medium focus:outline-none focus:border-blue-500"
                rows={2}
              />
              <div className="flex justify-end gap-2">
                <button
                  onClick={() => handleVerify(selectedDoctor.id, 'rejected')}
                  className="px-4 py-2 bg-red-50 hover:bg-red-100 text-red-700 rounded-xl text-xs font-bold transition flex items-center gap-1.5"
                >
                  <XCircle className="w-4 h-4" /> Reject Doctor
                </button>
                <button
                  onClick={() => handleVerify(selectedDoctor.id, 'approved')}
                  className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-emerald-600/20"
                >
                  <CheckCircle2 className="w-4 h-4" /> Approve & Verify
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
