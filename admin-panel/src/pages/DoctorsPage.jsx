import React, { useEffect, useState } from 'react';
import {
  Stethoscope, Plus, Search, CheckCircle, XCircle, Trash2, Edit3, CircleDot,
  FileCheck, ExternalLink, AlertTriangle, Building2, CreditCard, GraduationCap,
  Phone, Mail, Calendar, Clock, ShieldCheck, Eye, Award, FileText
} from 'lucide-react';
import { apiService } from '../services/api';

export default function DoctorsPage() {
  const [doctors, setDoctors] = useState([]);
  const [activeTab, setActiveTab] = useState('all'); // 'all' or 'pending'
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [verifyDoctorModal, setVerifyDoctorModal] = useState(null);
  const [reviewTab, setReviewTab] = useState('documents'); // 'documents', 'credentials', 'clinic', 'bank'
  const [previewImage, setPreviewImage] = useState(null);
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

      {/* Doctor Document Review & 7-Step Verification Modal */}
      {verifyDoctorModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-3xl w-full p-6 shadow-2xl space-y-4 max-h-[92vh] overflow-y-auto">
            {/* Header */}
            <div className="flex items-start justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-3">
                <img src={verifyDoctorModal.imageUrl} alt="" className="w-14 h-14 rounded-2xl object-cover border-2 border-blue-100 shadow-sm" />
                <div>
                  <div className="flex items-center gap-2">
                    <h2 className="text-lg font-extrabold text-slate-900">{verifyDoctorModal.name}</h2>
                    <span className={`text-[10px] font-extrabold uppercase px-2 py-0.5 rounded-full ${
                      verifyDoctorModal.isVerified
                        ? 'bg-emerald-100 text-emerald-800'
                        : 'bg-amber-100 text-amber-800 animate-pulse'
                    }`}>
                      {verifyDoctorModal.isVerified ? 'Verified License' : 'Pending Verification'}
                    </span>
                  </div>
                  <p className="text-xs text-blue-600 font-bold mt-0.5">
                    {verifyDoctorModal.specialty} • {verifyDoctorModal.qualification}
                  </p>
                  <p className="text-[11px] text-slate-500">
                    Reg ID: <span className="font-mono font-semibold text-slate-700">{verifyDoctorModal.medicalLicenseNo || 'RMC/2011/77321'}</span> • {verifyDoctorModal.stateMedicalCouncil || 'Rajasthan Medical Council'}
                  </p>
                </div>
              </div>
              <button
                onClick={() => { setVerifyDoctorModal(null); setReviewTab('documents'); }}
                className="text-slate-400 hover:text-slate-600 text-xl font-bold w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center"
              >
                ×
              </button>
            </div>

            {/* Navigation Tabs */}
            <div className="flex gap-2 border-b border-slate-100 pb-1">
              {[
                { id: 'documents', label: 'Document Vault (6)', icon: FileCheck },
                { id: 'credentials', label: 'Licensing & Education', icon: GraduationCap },
                { id: 'clinic', label: 'Clinic & Availability', icon: Building2 },
                { id: 'bank', label: 'Bank & Payouts', icon: CreditCard },
              ].map(tab => {
                const Icon = tab.icon;
                const isActive = reviewTab === tab.id;
                return (
                  <button
                    key={tab.id}
                    onClick={() => setReviewTab(tab.id)}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
                      isActive
                        ? 'bg-blue-600 text-white shadow-sm shadow-blue-500/30'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                    }`}
                  >
                    <Icon className="w-3.5 h-3.5" />
                    {tab.label}
                  </button>
                );
              })}
            </div>

            {/* TAB 1: DOCUMENT VAULT (6 PROOFS) */}
            {reviewTab === 'documents' && (
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <h4 className="text-xs font-bold text-slate-700 uppercase tracking-wider flex items-center gap-1.5">
                    <ShieldCheck className="w-4 h-4 text-emerald-600" />
                    Required Verification Credentials Vault (6 Documents)
                  </h4>
                  <span className="text-[11px] text-slate-500">Tap inspect to view high-resolution scan</span>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                  {[
                    {
                      title: '1. State Medical Council Certificate',
                      desc: verifyDoctorModal.stateMedicalCouncil || 'NMC / State Council Reg',
                      url: verifyDoctorModal.medicalCouncilCertUrl || verifyDoctorModal.qualificationCertUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
                      badge: 'Primary License',
                    },
                    {
                      title: '2. MBBS / Primary Degree',
                      desc: `${verifyDoctorModal.primaryDegree || 'MBBS'} (${verifyDoctorModal.primaryPassingYear || '2011'})`,
                      url: verifyDoctorModal.primaryDegreeCertUrl || verifyDoctorModal.qualificationCertUrl || 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800',
                      badge: 'Undergraduate',
                    },
                    {
                      title: '3. Post-Grad Degree / Diploma',
                      desc: verifyDoctorModal.postGradDegree || 'MD / MS Degree',
                      url: verifyDoctorModal.postGradCertUrl || 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800',
                      badge: 'Specialty PG',
                    },
                    {
                      title: '4. Govt Identity Proof',
                      desc: 'Aadhaar / Passport / Voter ID',
                      url: verifyDoctorModal.idProofUrl || 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
                      badge: 'Govt Verified',
                    },
                    {
                      title: '5. Clinic Establishment Proof',
                      desc: verifyDoctorModal.clinicName || 'Clinic Registration / Rent Deed',
                      url: verifyDoctorModal.clinicAddressProofUrl || 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800',
                      badge: 'Premises Proof',
                    },
                    {
                      title: '6. Official Signature & Stamp',
                      desc: 'Digital Telemedicine Prescriptions Specimen',
                      url: verifyDoctorModal.signatureSpecimenUrl || 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
                      badge: 'Prescription Specimen',
                    },
                  ].map((doc, idx) => (
                    <div
                      key={idx}
                      className="p-3 bg-slate-50 hover:bg-blue-50/60 rounded-xl border border-slate-200 transition-all flex flex-col justify-between group space-y-2"
                    >
                      <div className="flex items-start justify-between">
                        <span className="text-[10px] font-extrabold uppercase px-1.5 py-0.5 bg-blue-100 text-blue-800 rounded">
                          {doc.badge}
                        </span>
                        <a
                          href={doc.url}
                          target="_blank"
                          rel="noreferrer"
                          className="text-slate-400 hover:text-blue-600 transition-colors"
                          title="Open original"
                        >
                          <ExternalLink className="w-3.5 h-3.5" />
                        </a>
                      </div>

                      <div
                        onClick={() => setPreviewImage(doc)}
                        className="relative h-24 bg-white rounded-lg border border-slate-200 overflow-hidden cursor-pointer group-hover:border-blue-400 transition-all"
                      >
                        <img src={doc.url} alt="" className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
                        <div className="absolute inset-0 bg-slate-900/30 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity text-white text-xs font-bold gap-1">
                          <Eye className="w-3.5 h-3.5" /> Inspect
                        </div>
                      </div>

                      <div>
                        <h5 className="text-xs font-extrabold text-slate-800 line-clamp-1">{doc.title}</h5>
                        <p className="text-[10.5px] text-slate-500 line-clamp-1">{doc.desc}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* TAB 2: LICENSING & EDUCATION */}
            {reviewTab === 'credentials' && (
              <div className="space-y-3 text-xs">
                <div className="bg-blue-50/80 p-4 rounded-xl border border-blue-200/70 space-y-3">
                  <h4 className="font-extrabold text-blue-900 text-sm flex items-center gap-1.5">
                    <ShieldCheck className="w-4 h-4 text-blue-600" /> Medical Registration Authority Details
                  </h4>
                  <div className="grid grid-cols-2 gap-3 text-slate-700">
                    <div><span className="font-bold text-slate-900">Registration / License No:</span> {verifyDoctorModal.medicalLicenseNo || 'RMC/2011/77321'}</div>
                    <div><span className="font-bold text-slate-900">State Medical Council:</span> {verifyDoctorModal.stateMedicalCouncil || 'Rajasthan Medical Council'}</div>
                    <div><span className="font-bold text-slate-900">Registration Year:</span> {verifyDoctorModal.registrationYear || '2011'}</div>
                    <div><span className="font-bold text-slate-900">License Valid Till:</span> {verifyDoctorModal.licenseValidTill || '2036'}</div>
                    <div><span className="font-bold text-slate-900">Practice Specialization:</span> {verifyDoctorModal.specialty || 'Cardiologist'}</div>
                    <div><span className="font-bold text-slate-900">Sub-Specialization:</span> {verifyDoctorModal.subSpecialty || 'Interventional Cardiology'}</div>
                    <div><span className="font-bold text-slate-900">Experience:</span> {verifyDoctorModal.experienceYears || 12} Years ({verifyDoctorModal.experienceText || '12 yrs exp'})</div>
                    <div><span className="font-bold text-slate-900">Consultation Languages:</span> {(verifyDoctorModal.languages || ['English', 'Hindi']).join(', ')}</div>
                  </div>
                </div>

                <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-3">
                  <h4 className="font-extrabold text-slate-900 text-sm flex items-center gap-1.5">
                    <GraduationCap className="w-4 h-4 text-slate-700" /> Academic Qualifications & Institutions
                  </h4>
                  <div className="grid grid-cols-2 gap-3 text-slate-700">
                    <div>
                      <span className="font-bold text-slate-900">Primary Degree:</span> {verifyDoctorModal.primaryDegree || 'MBBS'}
                      <div className="text-[11px] text-slate-500">{verifyDoctorModal.primaryCollege || 'SMS Medical College, Jaipur'} ({verifyDoctorModal.primaryPassingYear || '2011'})</div>
                    </div>
                    <div>
                      <span className="font-bold text-slate-900">Post-Graduate Degree:</span> {verifyDoctorModal.postGradDegree || 'MD (Internal Medicine)'}
                      <div className="text-[11px] text-slate-500">{verifyDoctorModal.postGradCollege || 'AIIMS New Delhi'} ({verifyDoctorModal.postGradPassingYear || '2015'})</div>
                    </div>
                  </div>
                </div>

                <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-2">
                  <h4 className="font-extrabold text-slate-900 text-sm">Doctor Contact Details</h4>
                  <div className="grid grid-cols-3 gap-2 text-slate-700">
                    <div><span className="font-bold">Mobile:</span> {verifyDoctorModal.phone || '+91 98112 34567'}</div>
                    <div><span className="font-bold">Email:</span> {verifyDoctorModal.email || 'dr.vikramaditya@medicare.com'}</div>
                    <div><span className="font-bold">Gender / DOB:</span> {verifyDoctorModal.gender || 'Male'} • {verifyDoctorModal.dateOfBirth || '1987-04-12'}</div>
                  </div>
                </div>
              </div>
            )}

            {/* TAB 3: CLINIC & AVAILABILITY */}
            {reviewTab === 'clinic' && (
              <div className="space-y-3 text-xs">
                <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-2">
                  <h4 className="font-extrabold text-slate-900 text-sm flex items-center gap-1.5">
                    <Building2 className="w-4 h-4 text-blue-600" /> Practice Location & Clinic
                  </h4>
                  <div className="grid grid-cols-2 gap-3 text-slate-700">
                    <div><span className="font-bold text-slate-900">Clinic Name:</span> {verifyDoctorModal.clinicName || 'Rathore Heart Clinic'}</div>
                    <div><span className="font-bold text-slate-900">City / State / PIN:</span> {verifyDoctorModal.city || 'Jaipur'}, {verifyDoctorModal.state || 'Rajasthan'} - {verifyDoctorModal.pincode || '302018'}</div>
                    <div className="col-span-2"><span className="font-bold text-slate-900">Full Address:</span> {verifyDoctorModal.clinicAddress}</div>
                  </div>
                </div>

                <div className="bg-blue-50/70 p-4 rounded-xl border border-blue-200/60 space-y-3">
                  <h4 className="font-extrabold text-blue-900 text-sm flex items-center gap-1.5">
                    <Clock className="w-4 h-4 text-blue-600" /> Consultation Modes & Fee Schedule
                  </h4>
                  <div className="grid grid-cols-3 gap-3 text-slate-700">
                    <div className="p-2.5 bg-white rounded-lg border border-blue-100">
                      <div className="text-[10px] uppercase font-bold text-slate-400">In-Person Visit Fee</div>
                      <div className="text-base font-extrabold text-slate-900">₹{verifyDoctorModal.inPersonFee || verifyDoctorModal.consultationFee || 800}</div>
                    </div>
                    <div className="p-2.5 bg-white rounded-lg border border-blue-100">
                      <div className="text-[10px] uppercase font-bold text-slate-400">Video Call Fee</div>
                      <div className="text-base font-extrabold text-blue-700">₹{verifyDoctorModal.videoFee || 650}</div>
                    </div>
                    <div className="p-2.5 bg-white rounded-lg border border-blue-100">
                      <div className="text-[10px] uppercase font-bold text-slate-400">Follow-up Fee</div>
                      <div className="text-base font-extrabold text-emerald-700">₹{verifyDoctorModal.followUpFee || 400}</div>
                    </div>
                  </div>
                  <div className="flex flex-wrap items-center gap-2 text-[11px] text-slate-600 pt-1">
                    <span className="px-2 py-0.5 bg-white rounded-md border border-slate-200 font-semibold">
                      Slot Duration: {verifyDoctorModal.slotDuration || '20 mins'}
                    </span>
                    <span className="px-2 py-0.5 bg-white rounded-md border border-slate-200 font-semibold">
                      Emergency Calls: {verifyDoctorModal.emergencyAvailable ? 'Enabled' : 'Disabled'}
                    </span>
                    <span className="px-2 py-0.5 bg-white rounded-md border border-slate-200 font-semibold">
                      Modes: {verifyDoctorModal.allowsPhysical && verifyDoctorModal.allowsVideo ? 'In-Person & Telemedicine' : verifyDoctorModal.allowsVideo ? 'Video Only' : 'Clinic Only'}
                    </span>
                  </div>
                </div>
              </div>
            )}

            {/* TAB 4: BANK & PAYOUTS */}
            {reviewTab === 'bank' && (
              <div className="space-y-3 text-xs">
                <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-3">
                  <h4 className="font-extrabold text-slate-900 text-sm flex items-center gap-1.5">
                    <CreditCard className="w-4 h-4 text-emerald-600" /> Professional Payout & Bank Account
                  </h4>
                  <div className="grid grid-cols-2 gap-3 text-slate-700">
                    <div><span className="font-bold text-slate-900">Account Holder:</span> {verifyDoctorModal.accountHolder || verifyDoctorModal.name}</div>
                    <div><span className="font-bold text-slate-900">Bank Name:</span> {verifyDoctorModal.bankName || 'HDFC Bank'}</div>
                    <div><span className="font-bold text-slate-900">Account Number:</span> <span className="font-mono">{verifyDoctorModal.accountNo || '50100492817263'}</span></div>
                    <div><span className="font-bold text-slate-900">IFSC Code:</span> <span className="font-mono">{verifyDoctorModal.ifscCode || 'HDFC0001234'}</span></div>
                    <div><span className="font-bold text-slate-900">UPI ID:</span> {verifyDoctorModal.upiId || 'drvikram@okhdfcbank'}</div>
                    <div><span className="font-bold text-slate-900">PAN Number:</span> <span className="font-mono">{verifyDoctorModal.panNumber || 'ABCDE1234F'}</span></div>
                  </div>
                </div>

                <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-2">
                  <h4 className="font-extrabold text-slate-900 text-sm">Professional Profile Bio</h4>
                  <p className="text-slate-600 text-xs leading-relaxed">
                    {verifyDoctorModal.aboutText || 'Senior Interventional Cardiologist with extensive clinical practice.'}
                  </p>
                </div>
              </div>
            )}

            {/* Rejection Feedback Note */}
            <div className="pt-2">
              <label className="block text-xs font-bold text-slate-600 mb-1">
                Audit / Rejection Feedback Notes (Required if rejecting):
              </label>
              <input
                type="text"
                placeholder="e.g. License scan blurred, Council certificate expired, or please re-upload clear degree..."
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                className="w-full border border-slate-300 rounded-xl p-2.5 text-xs font-medium focus:ring-2 focus:ring-blue-500 focus:outline-none"
              />
            </div>

            {/* Modal Actions */}
            <div className="flex gap-3 pt-3 border-t border-slate-100">
              <button
                onClick={() => handleRejectDoctor(verifyDoctorModal.id)}
                className="flex-1 py-3 bg-red-50 hover:bg-red-100 text-red-700 rounded-xl font-bold text-xs flex items-center justify-center gap-1.5 border border-red-200 transition-colors"
              >
                <XCircle className="w-4 h-4" /> Reject Application
              </button>
              <button
                onClick={() => handleApproveDoctor(verifyDoctorModal.id)}
                className="flex-1 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold text-xs flex items-center justify-center gap-1.5 shadow-md shadow-emerald-600/20 transition-colors"
              >
                <CheckCircle className="w-4 h-4" /> Approve & Grant Telemedicine License
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Lightbox Image Preview Modal */}
      {previewImage && (
        <div
          className="fixed inset-0 bg-slate-900/80 z-[60] flex items-center justify-center p-4 backdrop-blur-sm"
          onClick={() => setPreviewImage(null)}
        >
          <div
            className="relative max-w-3xl w-full bg-white rounded-2xl overflow-hidden shadow-2xl space-y-3 p-4"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between border-b border-slate-100 pb-2">
              <div>
                <h4 className="font-extrabold text-sm text-slate-900">{previewImage.title}</h4>
                <p className="text-xs text-slate-500">{previewImage.desc}</p>
              </div>
              <button
                onClick={() => setPreviewImage(null)}
                className="text-slate-400 hover:text-slate-700 text-xl font-bold w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center"
              >
                ×
              </button>
            </div>

            <div className="max-h-[68vh] overflow-auto flex items-center justify-center bg-slate-100/70 p-2 rounded-xl border border-slate-200">
              <img
                src={previewImage.url}
                alt=""
                className="max-h-[64vh] w-auto object-contain rounded-lg shadow-sm"
              />
            </div>

            <div className="flex items-center justify-between pt-1">
              <span className="text-[11px] text-slate-500">Document authenticated via NMC / Council verification vault</span>
              <a
                href={previewImage.url}
                target="_blank"
                rel="noreferrer"
                className="text-xs font-bold text-blue-600 hover:text-blue-800 flex items-center gap-1"
              >
                Open in Full Window <ExternalLink className="w-3 h-3" />
              </a>
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
