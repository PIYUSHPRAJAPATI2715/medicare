import React, { useEffect, useState } from 'react';
import { Stethoscope, Plus, Search, CheckCircle, XCircle, Trash2, Edit3, CircleDot, FileCheck, ExternalLink, AlertTriangle } from 'lucide-react';
import { apiService } from '../services/api';

export default function DoctorsPage() {
  const [doctors, setDoctors] = useState([]);
  const [activeTab, setActiveTab] = useState('all'); // 'all' or 'pending'
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [verifyDoctorModal, setVerifyDoctorModal] = useState(null);
  const [rejectionReason, setRejectionReason] = useState('');

  const [formData, setFormData] = useState({
    name: '',
    specialty: 'General Physician',
    qualification: 'MBBS, MD',
    experienceYears: 8,
    consultationFee: 500,
    clinicName: 'MediCare Care Clinic',
    clinicAddress: 'Jaipur',
    medicalLicenseNo: 'MCI/2026/10294',
    stateMedicalCouncil: 'Rajasthan Medical Council',
    isOnline: true,
  });

  useEffect(() => {
    loadDoctors();
  }, []);

  const loadDoctors = async () => {
    const res = await apiService.getDoctors(true);
    if (res.success) setDoctors(res.data);
  };

  const handleToggleOnline = async (doc) => {
    await apiService.updateDoctor(doc.id, { isOnline: !doc.isOnline });
    loadDoctors();
  };

  const handleApproveDoctor = async (docId) => {
    const res = await apiService.verifyDoctor(docId, 'approve');
    if (res.success) {
      alert(res.message);
      setVerifyDoctorModal(null);
      loadDoctors();
    }
  };

  const handleRejectDoctor = async (docId) => {
    if (!rejectionReason) {
      alert('Please state the rejection feedback notes for the doctor.');
      return;
    }
    const res = await apiService.verifyDoctor(docId, 'reject', rejectionReason);
    if (res.success) {
      alert(res.message);
      setVerifyDoctorModal(null);
      setRejectionReason('');
      loadDoctors();
    }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    const res = await apiService.createDoctor(formData);
    if (res.success) {
      setShowModal(false);
      loadDoctors();
    }
  };

  const handleDelete = async (id) => {
    if (confirm('Delete this doctor record?')) {
      await apiService.deleteDoctor(id);
      loadDoctors();
    }
  };

  const pendingDoctors = doctors.filter(d => d.verificationStatus === 'pending' || !d.isVerified);
  const verifiedDoctors = doctors.filter(d => d.isVerified && d.verificationStatus === 'approved');

  const displayedDoctors = (activeTab === 'pending' ? pendingDoctors : doctors).filter(
    d => d.name.toLowerCase().includes(search.toLowerCase()) || d.specialty.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-extrabold text-slate-900">Doctor Directory & Document Verification</h1>
          <p className="text-slate-500 text-sm mt-0.5">Verify medical licenses, council registration proofs, fees, & instant status</p>
        </div>
        <button
          onClick={() => setShowModal(true)}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-bold px-4 py-2.5 rounded-xl text-sm transition-all shadow-md shadow-blue-500/20"
        >
          <Plus className="w-4 h-4" /> Add Doctor Profile
        </button>
      </div>

      {/* Tabs Bar */}
      <div className="flex items-center gap-3 border-b border-slate-200">
        <button
          onClick={() => setActiveTab('all')}
          className={`pb-3 px-2 text-sm font-extrabold border-b-2 transition-colors ${
            activeTab === 'all' ? 'border-blue-600 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-800'
          }`}
        >
          All Providers ({doctors.length})
        </button>
        <button
          onClick={() => setActiveTab('pending')}
          className={`pb-3 px-2 text-sm font-extrabold border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'pending' ? 'border-amber-500 text-amber-600' : 'border-transparent text-slate-500 hover:text-slate-800'
          }`}
        >
          Pending Document Verification
          {pendingDoctors.length > 0 && (
            <span className="bg-amber-500 text-white text-xs px-2 py-0.5 rounded-full animate-bounce">
              {pendingDoctors.length}
            </span>
          )}
        </button>
      </div>

      {/* Search Bar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-3">
        <Search className="w-5 h-5 text-slate-400" />
        <input
          type="text"
          placeholder="Search doctor name, specialty, license number or clinic..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-transparent border-none text-sm focus:outline-none text-slate-800 placeholder-slate-400 font-medium"
        />
      </div>

      {/* Doctors Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
        {displayedDoctors.map((doc) => (
          <div key={doc.id} className="bg-white rounded-2xl p-5 border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-start gap-4">
              <img src={doc.imageUrl} alt="" className="w-16 h-16 rounded-2xl object-cover border border-slate-200 shadow-sm" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2">
                  <h3 className="font-extrabold text-slate-900 text-base truncate">{doc.name}</h3>
                  {doc.isVerified ? (
                    <CheckCircle className="w-4 h-4 text-emerald-500 shrink-0" />
                  ) : (
                    <span className="px-2 py-0.5 bg-amber-100 text-amber-800 text-[10px] font-extrabold rounded-md uppercase">Pending Review</span>
                  )}
                </div>
                <p className="text-xs font-bold text-blue-600 mt-0.5">{doc.specialty}</p>
                <p className="text-xs text-slate-500 mt-0.5">{doc.qualification} • {doc.experienceText}</p>
                <p className="text-[11px] font-medium text-slate-400 mt-0.5">License: {doc.medicalLicenseNo || 'MCI/2026/88412'}</p>
              </div>
              <button
                onClick={() => handleDelete(doc.id)}
                className="p-1.5 text-slate-400 hover:text-red-500 rounded-lg"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-2 bg-slate-50 p-3 rounded-xl text-xs font-semibold text-slate-600">
              <div>
                <span className="text-slate-400 font-normal">Fee:</span> ₹{doc.consultationFee}
              </div>
              <div>
                <span className="text-slate-400 font-normal">Council:</span> {doc.stateMedicalCouncil || 'Medical Council of India'}
              </div>
              <div className="col-span-2 truncate">
                <span className="text-slate-400 font-normal">Clinic:</span> {doc.clinicName} ({doc.clinicAddress})
              </div>
            </div>

            {/* Quick Admin Actions */}
            <div className="flex items-center justify-between pt-1 border-t border-slate-100 text-xs font-bold">
              <button
                onClick={() => handleToggleOnline(doc)}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg border transition-colors ${
                  doc.isOnline ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-slate-100 text-slate-500 border-slate-200'
                }`}
              >
                <CircleDot className={`w-3.5 h-3.5 ${doc.isOnline ? 'text-emerald-500 animate-pulse' : 'text-slate-400'}`} />
                {doc.isOnline ? 'Online Now' : 'Offline'}
              </button>

              <button
                onClick={() => setVerifyDoctorModal(doc)}
                className={`flex items-center gap-1 px-3 py-1.5 rounded-lg font-extrabold text-xs transition-colors ${
                  doc.isVerified
                    ? 'bg-emerald-100 text-emerald-800 hover:bg-emerald-200'
                    : 'bg-amber-500 hover:bg-amber-600 text-white shadow-md shadow-amber-500/20'
                }`}
              >
                <FileCheck className="w-3.5 h-3.5" />
                {doc.isVerified ? 'Verified Documentation' : 'Review & Verify License'}
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Doctor Document Review & Verification Modal */}
      {verifyDoctorModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-start justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-3">
                <img src={verifyDoctorModal.imageUrl} alt="" className="w-12 h-12 rounded-xl object-cover border border-slate-200" />
                <div>
                  <h2 className="text-lg font-extrabold text-slate-900">{verifyDoctorModal.name}</h2>
                  <p className="text-xs text-blue-600 font-bold">{verifyDoctorModal.specialty} • {verifyDoctorModal.qualification}</p>
                </div>
              </div>
              <button onClick={() => setVerifyDoctorModal(null)} className="text-slate-400 hover:text-slate-600 text-lg font-bold">×</button>
            </div>

            <div className="bg-blue-50/70 p-4 rounded-xl border border-blue-200/60 space-y-2 text-xs">
              <h4 className="font-extrabold text-blue-900 text-sm flex items-center gap-1.5">
                <FileCheck className="w-4 h-4 text-blue-600" /> Medical Licensing & Council Credentials
              </h4>
              <div className="grid grid-cols-2 gap-2 text-slate-700">
                <div><span className="font-bold">Medical License No:</span> {verifyDoctorModal.medicalLicenseNo || 'MCI/2026/88412'}</div>
                <div><span className="font-bold">State Council:</span> {verifyDoctorModal.stateMedicalCouncil || 'Rajasthan Medical Council'}</div>
                <div><span className="font-bold">Experience:</span> {verifyDoctorModal.experienceText}</div>
                <div><span className="font-bold">Clinic Address:</span> {verifyDoctorModal.clinicAddress}</div>
              </div>
            </div>

            {/* Uploaded Documents List */}
            <div className="space-y-2">
              <h4 className="text-xs font-bold text-slate-700 uppercase tracking-wider">Submitted Document Proofs</h4>
              <div className="grid grid-cols-3 gap-3">
                <a
                  href={verifyDoctorModal.qualificationCertUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600'}
                  target="_blank"
                  rel="noreferrer"
                  className="p-3 bg-slate-50 hover:bg-slate-100 rounded-xl border border-slate-200 flex flex-col items-center justify-center text-center space-y-1.5 group"
                >
                  <FileCheck className="w-6 h-6 text-blue-600 group-hover:scale-110 transition-transform" />
                  <span className="text-xs font-bold text-slate-800">Degree Certificate</span>
                  <span className="text-[10px] text-blue-600 font-semibold flex items-center gap-0.5">View Document <ExternalLink className="w-2.5 h-2.5" /></span>
                </a>

                <a
                  href={verifyDoctorModal.idProofUrl || 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600'}
                  target="_blank"
                  rel="noreferrer"
                  className="p-3 bg-slate-50 hover:bg-slate-100 rounded-xl border border-slate-200 flex flex-col items-center justify-center text-center space-y-1.5 group"
                >
                  <FileCheck className="w-6 h-6 text-blue-600 group-hover:scale-110 transition-transform" />
                  <span className="text-xs font-bold text-slate-800">Identity Proof (Aadhaar/Passport)</span>
                  <span className="text-[10px] text-blue-600 font-semibold flex items-center gap-0.5">View Document <ExternalLink className="w-2.5 h-2.5" /></span>
                </a>

                <a
                  href={verifyDoctorModal.clinicAddressProofUrl || 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600'}
                  target="_blank"
                  rel="noreferrer"
                  className="p-3 bg-slate-50 hover:bg-slate-100 rounded-xl border border-slate-200 flex flex-col items-center justify-center text-center space-y-1.5 group"
                >
                  <FileCheck className="w-6 h-6 text-blue-600 group-hover:scale-110 transition-transform" />
                  <span className="text-xs font-bold text-slate-800">Clinic Registration Proof</span>
                  <span className="text-[10px] text-blue-600 font-semibold flex items-center gap-0.5">View Document <ExternalLink className="w-2.5 h-2.5" /></span>
                </a>
              </div>
            </div>

            {/* Rejection Notes Input if rejecting */}
            <div className="pt-2">
              <label className="block text-xs font-bold text-slate-600 mb-1">Rejection Feedback Notes (Optional if approving)</label>
              <input
                type="text"
                placeholder="State reason if rejecting (e.g. License expired or unreadable degree scan)..."
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                className="w-full border border-slate-300 rounded-xl p-2.5 text-xs font-medium focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div className="flex gap-3 pt-3 border-t border-slate-100">
              <button
                onClick={() => handleRejectDoctor(verifyDoctorModal.id)}
                className="flex-1 py-3 bg-red-50 hover:bg-red-100 text-red-700 rounded-xl font-bold text-xs flex items-center justify-center gap-1.5 border border-red-200"
              >
                <XCircle className="w-4 h-4" /> Reject Application
              </button>
              <button
                onClick={() => handleApproveDoctor(verifyDoctorModal.id)}
                className="flex-1 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold text-xs flex items-center justify-center gap-1.5 shadow-md shadow-emerald-600/20"
              >
                <CheckCircle className="w-4 h-4" /> Approve & Verify Doctor
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add Doctor Manual Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4">
            <h2 className="text-lg font-bold text-slate-900">Add New Doctor Profile</h2>
            <form onSubmit={handleCreate} className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-slate-600 mb-1">Doctor Name</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium focus:ring-2 focus:ring-blue-500 focus:outline-none"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Specialty</label>
                  <input
                    type="text"
                    required
                    value={formData.specialty}
                    onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Fee (₹)</label>
                  <input
                    type="number"
                    required
                    value={formData.consultationFee}
                    onChange={(e) => setFormData({ ...formData, consultationFee: Number(e.target.value) })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">Medical License No</label>
                  <input
                    type="text"
                    required
                    value={formData.medicalLicenseNo}
                    onChange={(e) => setFormData({ ...formData, medicalLicenseNo: e.target.value })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-600 mb-1">State Medical Council</label>
                  <input
                    type="text"
                    required
                    value={formData.stateMedicalCouncil}
                    onChange={(e) => setFormData({ ...formData, stateMedicalCouncil: e.target.value })}
                    className="w-full border border-slate-300 rounded-xl p-2.5 text-sm font-medium"
                  />
                </div>
              </div>
              <div className="flex gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="flex-1 py-2.5 bg-slate-100 text-slate-700 rounded-xl font-bold text-sm"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 bg-blue-600 text-white rounded-xl font-bold text-sm"
                >
                  Save Profile
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
