import React, { useState, useEffect } from 'react';
import { fetchDoctors, fetchPendingDoctors, verifyDoctor } from '../../services/api';
import { initialDoctors } from '../../data/mockData';
import ImageUpload from '../../components/ImageUpload';
import { CheckCircle2, XCircle, FileText, ExternalLink, ShieldCheck, Clock, Search, Plus, X, Check, Stethoscope } from 'lucide-react';

const DOCTOR_PRESETS = [
  { title: 'Dr. Male Physician', url: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400' },
  { title: 'Dr. Female Specialist', url: 'https://images.unsplash.com/photo-1594824813566-78a933758f46?w=400' },
  { title: 'Dr. Senior Consultant', url: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400' },
  { title: 'Dr. Surgeon', url: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400' },
  { title: 'Dr. Cardiologist', url: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400' },
];

const DEFAULT_DOC_IMG = 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400';

export default function DoctorsApprovalPage() {
  const [activeTab, setActiveTab] = useState('all'); // 'all' | 'pending'
  const [doctors, setDoctors] = useState(() => {
    try {
      const saved = localStorage.getItem('drconnects24_custom_doctors');
      return saved ? JSON.parse(saved) : initialDoctors;
    } catch {
      return initialDoctors;
    }
  });

  const [pendingDoctors, setPendingDoctors] = useState(() => {
    try {
      const saved = localStorage.getItem('drconnects24_custom_doctors');
      const list = saved ? JSON.parse(saved) : initialDoctors;
      return list.filter(d => !d.isVerified || d.verificationStatus === 'pending');
    } catch {
      return initialDoctors.filter(d => !d.isVerified);
    }
  });

  const [selectedDoctor, setSelectedDoctor] = useState(null);
  const [rejectionNotes, setRejectionNotes] = useState('');
  const [search, setSearch] = useState('');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  // Add Doctor Form State
  const [formData, setFormData] = useState({
    name: '',
    specialty: 'General Physician',
    qualification: 'MBBS, MD',
    experienceYears: 5,
    consultationFee: 500,
    medicalLicenseNo: 'MCI/2026/REG',
    stateMedicalCouncil: 'Rajasthan Medical Council',
    clinicName: 'Healthcare Clinic',
    clinicAddress: 'Jaipur, Rajasthan',
    imageUrl: DOCTOR_PRESETS[0].url,
    verificationStatus: 'approved',
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const docRes = await fetchDoctors();
      if (docRes && docRes.data && Array.isArray(docRes.data) && docRes.data.length > 0) {
        setDoctors(prev => {
          const customIds = new Set(prev.filter(d => d.id.startsWith('custom_')).map(d => d.id));
          const customs = prev.filter(d => customIds.has(d.id));
          const existingIds = new Set(customs.map(d => d.id));
          const incoming = docRes.data.filter(d => !existingIds.has(d.id));
          const merged = [...customs, ...incoming];
          setPendingDoctors(merged.filter(d => !d.isVerified || d.verificationStatus === 'pending'));
          return merged;
        });
      }
    } catch (e) {
      console.error('Error fetching doctors:', e);
    }
  };

  const handleVerify = async (id, status) => {
    try {
      await verifyDoctor(id, status, status === 'rejected' ? rejectionNotes : 'Verified & Approved by Admin');
      const updated = doctors.map(d => {
        if (d.id === id) {
          return { ...d, isVerified: status === 'approved', verificationStatus: status };
        }
        return d;
      });
      setDoctors(updated);
      setPendingDoctors(updated.filter(d => !d.isVerified || d.verificationStatus === 'pending'));
      try {
        localStorage.setItem('drconnects24_custom_doctors', JSON.stringify(updated));
      } catch (err) {}
      setSelectedDoctor(null);
      setRejectionNotes('');
    } catch (e) {
      alert('Verification failed. Try again.');
    }
  };

  const handleOpenAddModal = () => {
    setFormData({
      name: '',
      specialty: 'General Physician',
      qualification: 'MBBS, MD',
      experienceYears: 6,
      consultationFee: 499,
      medicalLicenseNo: `MCI/2026/${Math.floor(10000 + Math.random() * 90000)}`,
      stateMedicalCouncil: 'Rajasthan Medical Council',
      clinicName: 'City Wellness Clinic',
      clinicAddress: 'Jaipur, Rajasthan',
      imageUrl: DOCTOR_PRESETS[Math.floor(Math.random() * DOCTOR_PRESETS.length)].url,
      verificationStatus: 'approved',
    });
    setIsAddModalOpen(true);
  };

  const handleSaveDoctor = (e) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      alert('Please enter doctor name.');
      return;
    }

    const newDoctor = {
      id: `custom_d_${Date.now()}`,
      name: formData.name.startsWith('Dr.') ? formData.name.trim() : `Dr. ${formData.name.trim()}`,
      specialty: formData.specialty,
      qualification: formData.qualification.trim() || 'MBBS',
      experienceYears: Number(formData.experienceYears) || 3,
      experienceText: `${formData.experienceYears || 3} yrs exp`,
      ratingPercentage: 98,
      patientStoriesCount: 15,
      consultationFee: Number(formData.consultationFee) || 500,
      imageUrl: formData.imageUrl || DEFAULT_DOC_IMG,
      isOnline: true,
      allowsPhysical: true,
      allowsVideo: true,
      isVerified: formData.verificationStatus === 'approved',
      verificationStatus: formData.verificationStatus,
      medicalLicenseNo: formData.medicalLicenseNo.trim(),
      stateMedicalCouncil: formData.stateMedicalCouncil.trim(),
      clinicName: formData.clinicName.trim(),
      clinicAddress: formData.clinicAddress.trim(),
      qualificationCertUrl: formData.imageUrl || DEFAULT_DOC_IMG,
      idProofUrl: formData.imageUrl || DEFAULT_DOC_IMG,
      clinicAddressProofUrl: formData.imageUrl || DEFAULT_DOC_IMG,
    };

    const updated = [newDoctor, ...doctors];
    setDoctors(updated);
    setPendingDoctors(updated.filter(d => !d.isVerified || d.verificationStatus === 'pending'));
    try {
      localStorage.setItem('drconnects24_custom_doctors', JSON.stringify(updated));
    } catch (err) {}

    setIsAddModalOpen(false);
  };

  const displayList = activeTab === 'all' ? doctors : pendingDoctors;
  const filtered = displayList.filter(d =>
    (d.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (d.specialty || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-xl font-extrabold text-slate-900 tracking-tight">Doctor Management & Medical Verification</h1>
          <p className="text-xs text-slate-500 font-medium">Verify MCI / State Council registrations, degree certificates, and clinic identity proofs.</p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
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
              Pending ({pendingDoctors.length})
            </button>
          </div>
          <button
            onClick={handleOpenAddModal}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-blue-600/20 active:scale-95"
          >
            <Plus className="w-4 h-4" /> Add Doctor
          </button>
        </div>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          placeholder="Search by doctor name, specialty, or license..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-white border border-slate-200 rounded-xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
        />
      </div>

      {/* Empty State */}
      {filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-slate-200 p-8 text-center text-slate-500 shadow-sm">
          <Stethoscope className="w-10 h-10 text-slate-300 mx-auto mb-2" />
          <p className="text-sm font-bold text-slate-700">No doctors found</p>
          <p className="text-xs text-slate-400 mt-1">Try searching for a different keyword or add a new doctor.</p>
        </div>
      ) : (
        <>
          {/* Mobile Card List (< 768px) */}
          <div className="md:hidden space-y-3">
            {filtered.map((doc) => (
              <div key={doc.id} className="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm space-y-3">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <img
                      src={doc.imageUrl || DEFAULT_DOC_IMG}
                      alt={doc.name}
                      className="w-11 h-11 rounded-full object-cover border border-slate-200"
                      onError={(e) => { e.currentTarget.src = DEFAULT_DOC_IMG; }}
                    />
                    <div>
                      <h3 className="font-extrabold text-slate-900 text-sm">{doc.name}</h3>
                      <p className="text-xs text-slate-500 font-medium">{doc.specialty} · {doc.qualification}</p>
                    </div>
                  </div>
                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-extrabold capitalize ${
                    doc.verificationStatus === 'approved' ? 'bg-emerald-100 text-emerald-800' :
                    doc.verificationStatus === 'rejected' ? 'bg-red-100 text-red-800' :
                    'bg-amber-100 text-amber-800'
                  }`}>
                    {doc.verificationStatus || 'approved'}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-2 text-xs bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                  <div>
                    <span className="text-[10px] font-bold text-slate-400 uppercase">License No</span>
                    <p className="font-mono font-bold text-slate-800">{doc.medicalLicenseNo || 'MCI-REG-8821'}</p>
                  </div>
                  <div>
                    <span className="text-[10px] font-bold text-slate-400 uppercase">Fee</span>
                    <p className="font-extrabold text-slate-900">₹{doc.consultationFee}</p>
                  </div>
                </div>

                <button
                  onClick={() => setSelectedDoctor(doc)}
                  className="w-full py-2.5 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-xl text-xs font-bold transition flex items-center justify-center gap-1.5"
                >
                  <FileText className="w-4 h-4" /> Inspect Credentials & Documents
                </button>
              </div>
            ))}
          </div>

          {/* Desktop Table View (>= 768px) */}
          <div className="hidden md:block bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
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
                        <img
                          src={doc.imageUrl || DEFAULT_DOC_IMG}
                          alt={doc.name}
                          className="w-10 h-10 rounded-full object-cover border border-slate-200"
                          onError={(e) => { e.currentTarget.src = DEFAULT_DOC_IMG; }}
                        />
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
                      <p className="text-[11px] text-slate-500">{doc.stateMedicalCouncil || 'Rajasthan Medical Council'}</p>
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900">₹{doc.consultationFee}</td>
                    <td className="py-3.5 px-4">
                      <span className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold capitalize ${
                        doc.verificationStatus === 'approved' ? 'bg-emerald-100 text-emerald-800' :
                        doc.verificationStatus === 'rejected' ? 'bg-red-100 text-red-800' :
                        'bg-amber-100 text-amber-800'
                      }`}>
                        {doc.verificationStatus || 'approved'}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <button
                        onClick={() => setSelectedDoctor(doc)}
                        className="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 rounded-lg text-xs font-bold transition inline-flex items-center gap-1 shadow-sm"
                      >
                        <FileText className="w-3.5 h-3.5" /> Inspect
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      {/* Inspect Credentials Modal */}
      {selectedDoctor && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 shadow-2xl space-y-5 max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-start border-b border-slate-100 pb-4">
              <div className="flex items-center gap-3">
                <img
                  src={selectedDoctor.imageUrl || DEFAULT_DOC_IMG}
                  alt={selectedDoctor.name}
                  className="w-12 h-12 rounded-full object-cover border border-slate-200"
                  onError={(e) => { e.currentTarget.src = DEFAULT_DOC_IMG; }}
                />
                <div>
                  <span className="text-[10px] font-bold uppercase tracking-wider text-blue-600 bg-blue-50 px-2 py-0.5 rounded">
                    Medical License Audit
                  </span>
                  <h3 className="text-lg font-black text-slate-900 mt-0.5">{selectedDoctor.name}</h3>
                  <p className="text-xs text-slate-500">{selectedDoctor.specialty} · {selectedDoctor.qualification}</p>
                </div>
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

      {/* Add Doctor Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
                  <Stethoscope className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-extrabold text-slate-900">Add Practitioner / Doctor</h2>
                  <p className="text-xs text-slate-500">Register new medical specialist with photo and license</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveDoctor} className="space-y-4">
              <ImageUpload
                label="Doctor Profile Picture (Upload from device or choose preset)"
                value={formData.imageUrl}
                onChange={(newUrl) => setFormData({ ...formData, imageUrl: newUrl })}
                aspectRatio="aspect-square"
                presets={DOCTOR_PRESETS}
                placeholder={DEFAULT_DOC_IMG}
              />

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Doctor Name *</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Dr. Anil Meena"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Specialty</label>
                  <input
                    type="text"
                    placeholder="e.g. Cardiologist"
                    value={formData.specialty}
                    onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Qualification</label>
                  <input
                    type="text"
                    placeholder="MBBS, MD"
                    value={formData.qualification}
                    onChange={(e) => setFormData({ ...formData, qualification: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Experience (Yrs)</label>
                  <input
                    type="number"
                    min="1"
                    value={formData.experienceYears}
                    onChange={(e) => setFormData({ ...formData, experienceYears: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Fee (₹)</label>
                  <input
                    type="number"
                    min="100"
                    step="50"
                    value={formData.consultationFee}
                    onChange={(e) => setFormData({ ...formData, consultationFee: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">MCI / License No</label>
                  <input
                    type="text"
                    placeholder="MCI/2026/8841"
                    value={formData.medicalLicenseNo}
                    onChange={(e) => setFormData({ ...formData, medicalLicenseNo: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Verification Status</label>
                  <select
                    value={formData.verificationStatus}
                    onChange={(e) => setFormData({ ...formData, verificationStatus: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  >
                    <option value="approved">Approved & Verified</option>
                    <option value="pending">Pending Verification</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Clinic Name & Location</label>
                <input
                  type="text"
                  placeholder="e.g. City Health Clinic, Jaipur"
                  value={formData.clinicName}
                  onChange={(e) => setFormData({ ...formData, clinicName: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold transition flex items-center gap-1.5 shadow-md shadow-blue-600/20"
                >
                  <Check className="w-4 h-4" /> Save Doctor
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
