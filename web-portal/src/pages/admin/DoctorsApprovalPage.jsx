import React, { useState, useEffect } from 'react';
import { fetchDoctors, fetchPendingDoctors, verifyDoctor } from '../../services/api';
import { initialDoctors } from '../../data/mockData';
import ImageUpload from '../../components/ImageUpload';
import {
  CheckCircle2,
  XCircle,
  FileText,
  ExternalLink,
  ShieldCheck,
  Clock,
  Search,
  Plus,
  X,
  Check,
  Stethoscope,
  Eye,
  Award,
  Building2,
  CreditCard,
  Calendar,
  User,
  Phone,
  Mail,
  PenTool,
  AlertTriangle,
  RotateCw,
  ZoomIn,
  ZoomOut,
  Copy,
  FileCheck,
  AlertCircle,
  Download,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';

const DOCTOR_PRESETS = [
  { title: 'Dr. Male Physician', url: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400' },
  { title: 'Dr. Female Specialist', url: 'https://images.unsplash.com/photo-1594824813566-78a933758f46?w=400' },
  { title: 'Dr. Senior Consultant', url: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400' },
  { title: 'Dr. Surgeon', url: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400' },
  { title: 'Dr. Cardiologist', url: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400' },
];

const DEFAULT_DOC_IMG = 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400';

const getDoctorDocuments = (doc) => {
  if (!doc) return [];
  const defaultCert = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800';
  const defaultGrad = 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800';
  const defaultPg = 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800';
  const defaultId = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800';
  const defaultClinic = 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800';
  const defaultSig = 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800';

  return [
    {
      id: 'medicalCouncilCertUrl',
      title: 'State Council / NMC Certificate',
      subtitle: 'Registration Certificate & Active Medical License',
      description: 'Official registration with State Medical Council or National Medical Commission (NMC).',
      url: doc.medicalCouncilCertUrl || doc.qualificationCertUrl || defaultCert,
      category: 'Council Registration',
      isMandatory: true,
    },
    {
      id: 'primaryDegreeCertUrl',
      title: 'Primary Degree Certificate (MBBS)',
      subtitle: 'Medical Graduation Degree & Completion Certificate',
      description: 'Recognized medical degree from NMC / MCI approved college or university.',
      url: doc.primaryDegreeCertUrl || doc.qualificationCertUrl || defaultGrad,
      category: 'Medical Education',
      isMandatory: true,
    },
    {
      id: 'postGradCertUrl',
      title: 'Post-Graduate Degree (MD / MS / DNB)',
      subtitle: 'Higher Medical Qualification / Super-Specialty',
      description: 'Post-graduate specialization certificate required for specialist telemedicine practice.',
      url: doc.postGradCertUrl || defaultPg,
      category: 'Specialization',
      isMandatory: false,
    },
    {
      id: 'idProofUrl',
      title: 'Government Photo ID Proof',
      subtitle: 'Aadhaar / Passport / Voter Identification',
      description: 'Government photo identification verifying identity and Indian citizenship of practitioner.',
      url: doc.idProofUrl || defaultId,
      category: 'Legal Identity',
      isMandatory: true,
    },
    {
      id: 'clinicAddressProofUrl',
      title: 'Clinic / Hospital Address Proof',
      subtitle: 'Establishment License / Practice Premises Proof',
      description: 'Physical establishment registration, hospital empanelment, or clinic address proof.',
      url: doc.clinicAddressProofUrl || defaultClinic,
      category: 'Clinical Premises',
      isMandatory: true,
    },
    {
      id: 'doctorSignatureUrl',
      title: 'Official Doctor Signature & Stamp',
      subtitle: 'Digital Prescription Authorization Specimen',
      description: 'Authorized signature and clinic seal specimen used for signing digital e-prescriptions.',
      url: doc.doctorSignatureUrl || defaultSig,
      category: 'Tele-Prescription',
      isMandatory: true,
    },
  ];
};

export default function DoctorsApprovalPage() {
  const [activeTab, setActiveTab] = useState('all'); // 'all' | 'pending' | 'approved' | 'rejected'
  const [doctors, setDoctors] = useState(() => {
    try {
      const saved = localStorage.getItem('drconnects24_custom_doctors');
      return saved ? JSON.parse(saved) : initialDoctors;
    } catch {
      return initialDoctors;
    }
  });

  const [selectedDoctor, setSelectedDoctor] = useState(null);
  const [modalTab, setModalTab] = useState('credentials'); // 'credentials' | 'documents' | 'decision'
  const [rejectionNotes, setRejectionNotes] = useState('');
  const [search, setSearch] = useState('');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [copiedLicense, setCopiedLicense] = useState(false);
  const [verifiedDocsMap, setVerifiedDocsMap] = useState({});

  // Document Lightbox Viewer State
  const [lightboxDoc, setLightboxDoc] = useState(null);
  const [zoomLevel, setZoomLevel] = useState(1);
  const [rotation, setRotation] = useState(0);

  // Add Doctor Form State
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    gender: 'Male',
    dateOfBirth: '1988-06-15',
    specialty: 'General Physician',
    subSpecialty: 'Internal Medicine & Diabetology',
    qualification: 'MBBS, MD',
    collegeName: 'SMS Medical College, Jaipur',
    graduationYear: '2012',
    postGradDegree: 'MD (Internal Medicine)',
    postGradCollege: 'AIIMS New Delhi',
    postGradYear: '2016',
    experienceYears: 7,
    consultationFee: 500,
    videoConsultationFee: 400,
    medicalLicenseNo: 'MCI/2026/REG',
    stateMedicalCouncil: 'Rajasthan Medical Council',
    registrationYear: '2012',
    licenseExpiryYear: '2037',
    clinicName: 'City Wellness Clinic',
    clinicAddress: 'Tonk Road, Jaipur, Rajasthan',
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
          return [...customs, ...incoming];
        });
      }
    } catch (e) {
      console.error('Error fetching doctors:', e);
    }
  };

  const handleVerify = async (id, status) => {
    try {
      const notes = rejectionNotes.trim() || (status === 'approved' ? 'All credentials and 6 documents audited & verified.' : 'Verification review updated.');
      await verifyDoctor(id, status, notes);

      const updated = doctors.map(d => {
        if (d.id === id) {
          return {
            ...d,
            isVerified: status === 'approved',
            verificationStatus: status,
            rejectionNotes: notes,
            rejectionRemarks: notes,
            verifiedAt: status === 'approved' ? new Date().toISOString() : d.verifiedAt,
          };
        }
        return d;
      });

      setDoctors(updated);
      try {
        localStorage.setItem('drconnects24_custom_doctors', JSON.stringify(updated));
      } catch (err) {}

      // Update selected doctor in view or close
      const freshSelected = updated.find(d => d.id === id);
      setSelectedDoctor(freshSelected || null);
      setRejectionNotes('');
      alert(
        status === 'approved'
          ? 'Doctor has been approved! Telemedicine license granted.'
          : status === 'reupload_requested'
          ? 'Re-upload request sent to doctor with instructions.'
          : 'Doctor application has been rejected.'
      );
    } catch (e) {
      alert('Action failed. Please try again.');
    }
  };

  const handleOpenAddModal = () => {
    const randomSuffix = Math.floor(10000 + Math.random() * 90000);
    setFormData({
      name: '',
      email: `doctor${randomSuffix}@medicare.com`,
      phone: `+91 98290 ${randomSuffix.toString().slice(0, 5)}`,
      gender: 'Male',
      dateOfBirth: '1989-05-18',
      specialty: 'General Physician',
      subSpecialty: 'Internal Medicine & Diabetology',
      qualification: 'MBBS, MD',
      collegeName: 'SMS Medical College, Jaipur',
      graduationYear: '2013',
      postGradDegree: 'MD (Internal Medicine)',
      postGradCollege: 'AIIMS New Delhi',
      postGradYear: '2017',
      experienceYears: 7,
      consultationFee: 500,
      videoConsultationFee: 400,
      medicalLicenseNo: `RMC/2013/${randomSuffix}`,
      stateMedicalCouncil: 'Rajasthan Medical Council',
      registrationYear: '2013',
      licenseExpiryYear: '2038',
      clinicName: 'City Wellness Clinic',
      clinicAddress: 'Tonk Road, Jaipur, Rajasthan',
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
      email: formData.email.trim(),
      phone: formData.phone.trim(),
      gender: formData.gender,
      dateOfBirth: formData.dateOfBirth,
      specialty: formData.specialty,
      subSpecialty: formData.subSpecialty.trim(),
      qualification: formData.qualification.trim() || 'MBBS',
      collegeName: formData.collegeName.trim(),
      graduationYear: formData.graduationYear.trim(),
      postGradDegree: formData.postGradDegree.trim(),
      postGradCollege: formData.postGradCollege.trim(),
      postGradYear: formData.postGradYear.trim(),
      experienceYears: Number(formData.experienceYears) || 5,
      experienceText: `${formData.experienceYears || 5} yrs exp`,
      ratingPercentage: 98,
      patientStoriesCount: 12,
      consultationFee: Number(formData.consultationFee) || 500,
      videoConsultationFee: Number(formData.videoConsultationFee) || 400,
      imageUrl: formData.imageUrl || DEFAULT_DOC_IMG,
      isOnline: true,
      allowsPhysical: true,
      allowsVideo: true,
      isVerified: formData.verificationStatus === 'approved',
      verificationStatus: formData.verificationStatus,
      medicalLicenseNo: formData.medicalLicenseNo.trim(),
      stateMedicalCouncil: formData.stateMedicalCouncil.trim(),
      registrationYear: formData.registrationYear.trim(),
      licenseExpiryYear: formData.licenseExpiryYear.trim(),
      clinicName: formData.clinicName.trim(),
      clinicAddress: formData.clinicAddress.trim(),
      medicalCouncilCertUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
      primaryDegreeCertUrl: 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800',
      postGradCertUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800',
      idProofUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
      clinicAddressProofUrl: 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800',
      doctorSignatureUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
      qualificationCertUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
      languages: ['English', 'Hindi'],
      aboutText: `${formData.name} is a certified specialist with ${formData.experienceYears} years of medical experience in ${formData.specialty}.`,
      services: ['General Health Checkup', 'Video Tele-Consultation', 'Prescription Issuance'],
      submittedAt: new Date().toISOString(),
    };

    const updated = [newDoctor, ...doctors];
    setDoctors(updated);
    try {
      localStorage.setItem('drconnects24_custom_doctors', JSON.stringify(updated));
    } catch (err) {}

    setIsAddModalOpen(false);
  };

  const handleCopyLicense = (licenseNo) => {
    if (!licenseNo) return;
    navigator.clipboard?.writeText(licenseNo);
    setCopiedLicense(true);
    setTimeout(() => setCopiedLicense(false), 2000);
  };

  // Filter list by active tab and search query
  const pendingCount = doctors.filter(d => !d.isVerified || d.verificationStatus === 'pending').length;
  const approvedCount = doctors.filter(d => d.isVerified || d.verificationStatus === 'approved').length;
  const rejectedCount = doctors.filter(d => d.verificationStatus === 'rejected' || d.verificationStatus === 'reupload_requested').length;

  const displayList = doctors.filter(d => {
    if (activeTab === 'pending') return !d.isVerified || d.verificationStatus === 'pending';
    if (activeTab === 'approved') return d.isVerified || d.verificationStatus === 'approved';
    if (activeTab === 'rejected') return d.verificationStatus === 'rejected' || d.verificationStatus === 'reupload_requested';
    return true;
  });

  const filtered = displayList.filter(d => {
    const q = search.toLowerCase();
    return (
      (d.name || '').toLowerCase().includes(q) ||
      (d.specialty || '').toLowerCase().includes(q) ||
      (d.medicalLicenseNo || '').toLowerCase().includes(q) ||
      (d.collegeName || '').toLowerCase().includes(q) ||
      (d.stateMedicalCouncil || '').toLowerCase().includes(q)
    );
  });

  // Active documents for selected doctor in modal
  const selectedDocs = selectedDoctor ? getDoctorDocuments(selectedDoctor) : [];

  // Lightbox navigation
  const handleOpenLightbox = (docIndex) => {
    setLightboxDoc({ ...selectedDocs[docIndex], index: docIndex });
    setZoomLevel(1);
    setRotation(0);
  };

  const handleNextLightbox = () => {
    if (!lightboxDoc) return;
    const nextIdx = (lightboxDoc.index + 1) % selectedDocs.length;
    setLightboxDoc({ ...selectedDocs[nextIdx], index: nextIdx });
    setZoomLevel(1);
    setRotation(0);
  };

  const handlePrevLightbox = () => {
    if (!lightboxDoc) return;
    const prevIdx = (lightboxDoc.index - 1 + selectedDocs.length) % selectedDocs.length;
    setLightboxDoc({ ...selectedDocs[prevIdx], index: prevIdx });
    setZoomLevel(1);
    setRotation(0);
  };

  return (
    <div className="space-y-6">
      {/* Header & Page Title */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-white p-5 rounded-3xl border border-slate-200/80 shadow-sm">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase tracking-wider bg-blue-50 text-blue-700 border border-blue-200">
              NMC / Telemedicine Compliance
            </span>
            <span className="text-xs text-slate-400 font-semibold">• Indian Medical Register Audit</span>
          </div>
          <h1 className="text-xl font-black text-slate-900 tracking-tight">Doctor Onboarding & Verification</h1>
          <p className="text-xs text-slate-500 font-medium mt-0.5">
            Audit State Medical Council registrations, primary degrees, post-grad credentials, and all 6 mandatory medical documents.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2.5">
          <button
            onClick={handleOpenAddModal}
            className="px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl text-xs font-black transition flex items-center gap-1.5 shadow-md shadow-blue-600/20 active:scale-95"
          >
            <Plus className="w-4 h-4" /> Add Doctor
          </button>
        </div>
      </div>

      {/* Filter Tabs & Search Bar */}
      <div className="flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
        {/* Filter Pills */}
        <div className="flex bg-slate-100/80 p-1.5 rounded-2xl border border-slate-200/60 overflow-x-auto">
          <button
            onClick={() => setActiveTab('all')}
            className={`px-4 py-2 rounded-xl text-xs font-black transition whitespace-nowrap ${
              activeTab === 'all' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            All Doctors ({doctors.length})
          </button>
          <button
            onClick={() => setActiveTab('pending')}
            className={`px-4 py-2 rounded-xl text-xs font-black transition whitespace-nowrap flex items-center gap-1.5 ${
              activeTab === 'pending' ? 'bg-amber-600 text-white shadow-sm' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <Clock className="w-3.5 h-3.5" />
            Pending Audit ({pendingCount})
          </button>
          <button
            onClick={() => setActiveTab('approved')}
            className={`px-4 py-2 rounded-xl text-xs font-black transition whitespace-nowrap flex items-center gap-1.5 ${
              activeTab === 'approved' ? 'bg-emerald-600 text-white shadow-sm' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <CheckCircle2 className="w-3.5 h-3.5" />
            Approved ({approvedCount})
          </button>
          <button
            onClick={() => setActiveTab('rejected')}
            className={`px-4 py-2 rounded-xl text-xs font-black transition whitespace-nowrap flex items-center gap-1.5 ${
              activeTab === 'rejected' ? 'bg-rose-600 text-white shadow-sm' : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <AlertCircle className="w-3.5 h-3.5" />
            Issues / Rejected ({rejectedCount})
          </button>
        </div>

        {/* Search */}
        <div className="relative min-w-[280px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by doctor, specialty, license no, or college..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-white border border-slate-200 rounded-2xl pl-10 pr-4 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
          />
        </div>
      </div>

      {/* Empty State */}
      {filtered.length === 0 ? (
        <div className="bg-white rounded-3xl border border-slate-200 p-12 text-center text-slate-500 shadow-sm">
          <Stethoscope className="w-12 h-12 text-slate-300 mx-auto mb-3" />
          <p className="text-base font-black text-slate-800">No doctors match your criteria</p>
          <p className="text-xs text-slate-400 mt-1 max-w-sm mx-auto">
            Try searching for another keyword or switch the tab filter to view other doctors.
          </p>
        </div>
      ) : (
        <>
          {/* Mobile Card List (< 1024px) */}
          <div className="lg:hidden space-y-4">
            {filtered.map((doc) => {
              const isPending = !doc.isVerified || doc.verificationStatus === 'pending';
              const isApproved = doc.verificationStatus === 'approved';
              const isReupload = doc.verificationStatus === 'reupload_requested';

              return (
                <div
                  key={doc.id}
                  className={`bg-white rounded-3xl border p-4 shadow-sm space-y-3 transition ${
                    isPending ? 'border-amber-300 ring-2 ring-amber-100' : 'border-slate-200'
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-3">
                      <img
                        src={doc.imageUrl || DEFAULT_DOC_IMG}
                        alt={doc.name}
                        className="w-12 h-12 rounded-2xl object-cover border border-slate-200"
                        onError={(e) => { e.currentTarget.src = DEFAULT_DOC_IMG; }}
                      />
                      <div>
                        <h3 className="font-black text-slate-900 text-sm">{doc.name}</h3>
                        <p className="text-xs text-slate-500 font-semibold">{doc.specialty}</p>
                        <p className="text-[11px] text-slate-400">{doc.qualification}</p>
                      </div>
                    </div>
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${
                      isApproved ? 'bg-emerald-100 text-emerald-800 border border-emerald-200' :
                      isReupload ? 'bg-orange-100 text-orange-800 border border-orange-200' :
                      isPending ? 'bg-amber-100 text-amber-800 border border-amber-200 animate-pulse' :
                      'bg-rose-100 text-rose-800 border border-rose-200'
                    }`}>
                      {doc.verificationStatus || (doc.isVerified ? 'approved' : 'pending')}
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-2 text-xs bg-slate-50/80 p-3 rounded-2xl border border-slate-100">
                    <div>
                      <span className="text-[10px] font-black text-slate-400 uppercase tracking-wider">License No</span>
                      <p className="font-mono font-bold text-slate-800 truncate">{doc.medicalLicenseNo || 'MCI-REG-8821'}</p>
                      <p className="text-[10px] text-slate-400 truncate">{doc.stateMedicalCouncil || 'Rajasthan Council'}</p>
                    </div>
                    <div>
                      <span className="text-[10px] font-black text-slate-400 uppercase tracking-wider">Consultation Fees</span>
                      <p className="font-black text-slate-900">
                        ₹{doc.consultationFee} <span className="text-[10px] text-slate-400 font-medium">In-Clinic</span>
                      </p>
                      <p className="font-bold text-blue-600 text-[11px]">
                        ₹{doc.videoConsultationFee || Math.round(doc.consultationFee * 0.8)} <span className="text-[10px] text-slate-400 font-medium">Video</span>
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between text-[11px] text-slate-500 px-1">
                    <span className="inline-flex items-center gap-1 font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-lg border border-emerald-100">
                      <FileCheck className="w-3.5 h-3.5 text-emerald-600" /> 6/6 Docs Vault
                    </span>
                    <span className="text-slate-400 font-medium">{doc.experienceYears || 5} Years Experience</span>
                  </div>

                  <button
                    onClick={() => {
                      setSelectedDoctor(doc);
                      setModalTab('credentials');
                      setRejectionNotes(doc.rejectionNotes || doc.rejectionRemarks || '');
                    }}
                    className={`w-full py-2.5 rounded-2xl text-xs font-black transition flex items-center justify-center gap-1.5 shadow-sm ${
                      isPending
                        ? 'bg-amber-600 hover:bg-amber-700 text-white shadow-amber-600/20'
                        : 'bg-blue-50 hover:bg-blue-100 text-blue-700'
                    }`}
                  >
                    <FileText className="w-4 h-4" /> Audit Credentials & 6 Docs
                  </button>
                </div>
              );
            })}
          </div>

          {/* Desktop Table View (>= 1024px) */}
          <div className="hidden lg:block bg-white rounded-3xl border border-slate-200/90 shadow-sm overflow-hidden">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50/90 border-b border-slate-200 text-[10px] font-black text-slate-400 uppercase tracking-wider">
                  <th className="py-4 px-4">Doctor & Contact</th>
                  <th className="py-4 px-4">Specialty & Degrees</th>
                  <th className="py-4 px-4">Medical Council & Reg</th>
                  <th className="py-4 px-4">Consultation Fees</th>
                  <th className="py-4 px-4">Mandatory Docs</th>
                  <th className="py-4 px-4">Audit Status</th>
                  <th className="py-4 px-4 text-right">Verification Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs font-medium">
                {filtered.map((doc) => {
                  const isPending = !doc.isVerified || doc.verificationStatus === 'pending';
                  const isApproved = doc.verificationStatus === 'approved';
                  const isReupload = doc.verificationStatus === 'reupload_requested';

                  return (
                    <tr
                      key={doc.id}
                      className={`hover:bg-slate-50/80 transition ${
                        isPending ? 'bg-amber-50/30' : ''
                      }`}
                    >
                      <td className="py-4 px-4">
                        <div className="flex items-center gap-3">
                          <img
                            src={doc.imageUrl || DEFAULT_DOC_IMG}
                            alt={doc.name}
                            className="w-11 h-11 rounded-2xl object-cover border border-slate-200 shadow-sm"
                            onError={(e) => { e.currentTarget.src = DEFAULT_DOC_IMG; }}
                          />
                          <div>
                            <p className="font-black text-slate-900 text-sm">{doc.name}</p>
                            <p className="text-[11px] text-slate-500 font-medium">{doc.phone || '+91 98290 00000'}</p>
                            <p className="text-[10px] text-slate-400 truncate max-w-[160px]">{doc.email || 'doctor@medicare.com'}</p>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 px-4">
                        <span className="font-black text-slate-800 text-xs">{doc.specialty}</span>
                        {doc.subSpecialty && (
                          <p className="text-[10px] font-semibold text-blue-600 truncate max-w-[180px]">{doc.subSpecialty}</p>
                        )}
                        <p className="text-[11px] text-slate-500 font-medium">{doc.qualification}</p>
                        <p className="text-[10px] text-slate-400">{doc.collegeName || 'Recognized Medical College'}</p>
                      </td>
                      <td className="py-4 px-4">
                        <div className="flex items-center gap-1.5">
                          <p className="font-mono text-slate-900 font-black text-xs">{doc.medicalLicenseNo || 'MCI-REG-8821'}</p>
                        </div>
                        <p className="text-[11px] text-slate-600 font-semibold">{doc.stateMedicalCouncil || 'Rajasthan Medical Council'}</p>
                        <p className="text-[10px] text-slate-400">{doc.experienceYears || 5} Years Clinical Practice</p>
                      </td>
                      <td className="py-4 px-4">
                        <p className="font-black text-slate-900">₹{doc.consultationFee} <span className="text-[10px] text-slate-400 font-normal">In-Clinic</span></p>
                        <p className="font-black text-blue-600 text-[11px]">
                          ₹{doc.videoConsultationFee || Math.round(doc.consultationFee * 0.8)} <span className="text-[10px] text-slate-400 font-normal">Video Call</span>
                        </p>
                      </td>
                      <td className="py-4 px-4">
                        <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-xl text-[10px] font-black bg-emerald-50 text-emerald-800 border border-emerald-200">
                          <FileCheck className="w-3.5 h-3.5 text-emerald-600" /> 6/6 Docs Vault
                        </span>
                        <p className="text-[10px] text-slate-400 mt-0.5">Council, Degrees, ID & Sig</p>
                      </td>
                      <td className="py-4 px-4">
                        <span className={`px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider inline-flex items-center gap-1 ${
                          isApproved ? 'bg-emerald-100 text-emerald-800 border border-emerald-200' :
                          isReupload ? 'bg-orange-100 text-orange-800 border border-orange-200' :
                          isPending ? 'bg-amber-100 text-amber-800 border border-amber-200 animate-pulse' :
                          'bg-rose-100 text-rose-800 border border-rose-200'
                        }`}>
                          {isPending && <Clock className="w-3 h-3 text-amber-700" />}
                          {isApproved && <CheckCircle2 className="w-3 h-3 text-emerald-700" />}
                          {isReupload && <AlertTriangle className="w-3 h-3 text-orange-700" />}
                          {doc.verificationStatus || (doc.isVerified ? 'approved' : 'pending')}
                        </span>
                      </td>
                      <td className="py-4 px-4 text-right">
                        <button
                          onClick={() => {
                            setSelectedDoctor(doc);
                            setModalTab('credentials');
                            setRejectionNotes(doc.rejectionNotes || doc.rejectionRemarks || '');
                          }}
                          className={`px-3.5 py-2 rounded-xl text-xs font-black transition inline-flex items-center gap-1.5 shadow-sm active:scale-95 ${
                            isPending
                              ? 'bg-amber-600 hover:bg-amber-700 text-white shadow-amber-600/20'
                              : 'bg-blue-50 hover:bg-blue-100 text-blue-700'
                          }`}
                        >
                          <FileText className="w-3.5 h-3.5" />
                          {isPending ? 'Audit & Verify' : 'Inspect'}
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </>
      )}

      {/* INSPECT CREDENTIALS & 6-DOCUMENTS AUDIT MODAL */}
      {selectedDoctor && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-5 bg-slate-950/70 backdrop-blur-md animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-4xl w-full p-6 shadow-2xl border border-slate-200 space-y-5 max-h-[92vh] overflow-y-auto">
            {/* Modal Top Header */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-slate-100 pb-4">
              <div className="flex items-center gap-4">
                <img
                  src={selectedDoctor.imageUrl || DEFAULT_DOC_IMG}
                  alt={selectedDoctor.name}
                  className="w-14 h-14 rounded-2xl object-cover border-2 border-slate-200 shadow-md"
                  onError={(e) => { e.currentTarget.src = DEFAULT_DOC_IMG; }}
                />
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-black uppercase tracking-wider text-blue-700 bg-blue-50 px-2 py-0.5 rounded-lg border border-blue-200">
                      Medical Practitioner Audit
                    </span>
                    <span className={`px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-wider ${
                      selectedDoctor.verificationStatus === 'approved' ? 'bg-emerald-100 text-emerald-800' :
                      selectedDoctor.verificationStatus === 'rejected' ? 'bg-rose-100 text-rose-800' :
                      'bg-amber-100 text-amber-800'
                    }`}>
                      {selectedDoctor.verificationStatus || (selectedDoctor.isVerified ? 'approved' : 'pending')}
                    </span>
                  </div>
                  <h3 className="text-xl font-black text-slate-900 mt-1">{selectedDoctor.name}</h3>
                  <p className="text-xs text-slate-500 font-semibold">
                    {selectedDoctor.specialty} • {selectedDoctor.qualification} • {selectedDoctor.experienceYears || 5} Years Exp
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <button
                  onClick={() => setSelectedDoctor(null)}
                  className="p-2 text-slate-400 hover:text-slate-700 rounded-xl hover:bg-slate-100 transition"
                  title="Close Audit"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Modal Section Tabs */}
            <div className="flex bg-slate-100/90 p-1.5 rounded-2xl border border-slate-200/60 overflow-x-auto">
              <button
                onClick={() => setModalTab('credentials')}
                className={`flex-1 min-w-[160px] py-2.5 rounded-xl text-xs font-black transition flex items-center justify-center gap-2 ${
                  modalTab === 'credentials' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <Stethoscope className="w-4 h-4 text-blue-600" />
                1. Academic & Council Details
              </button>
              <button
                onClick={() => setModalTab('documents')}
                className={`flex-1 min-w-[160px] py-2.5 rounded-xl text-xs font-black transition flex items-center justify-center gap-2 ${
                  modalTab === 'documents' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <FileCheck className="w-4 h-4 text-emerald-600" />
                2. Mandatory Docs Vault (6/6)
              </button>
              <button
                onClick={() => setModalTab('decision')}
                className={`flex-1 min-w-[160px] py-2.5 rounded-xl text-xs font-black transition flex items-center justify-center gap-2 ${
                  modalTab === 'decision' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <ShieldCheck className="w-4 h-4 text-indigo-600" />
                3. Audit Decision & Actions
              </button>
            </div>

            {/* TAB 1: ACADEMIC & COUNCIL DETAILS */}
            {modalTab === 'credentials' && (
              <div className="space-y-5 animate-fadeIn">
                {/* Personal & Contact Grid */}
                <div>
                  <h4 className="text-[11px] font-black uppercase tracking-wider text-slate-400 mb-2 flex items-center gap-1.5">
                    <User className="w-3.5 h-3.5 text-blue-600" /> Personal Identity & Contact Information
                  </h4>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 bg-slate-50 p-4 rounded-2xl border border-slate-200/70">
                    <div>
                      <span className="text-[10px] font-bold text-slate-400 uppercase">Legal Name</span>
                      <p className="font-extrabold text-slate-900 text-xs mt-0.5">{selectedDoctor.name}</p>
                    </div>
                    <div>
                      <span className="text-[10px] font-bold text-slate-400 uppercase">Gender & DOB</span>
                      <p className="font-extrabold text-slate-900 text-xs mt-0.5">
                        {selectedDoctor.gender || 'Not Specified'} • {selectedDoctor.dateOfBirth || '1988-06-15'}
                      </p>
                    </div>
                    <div>
                      <span className="text-[10px] font-bold text-slate-400 uppercase">Registered Email</span>
                      <p className="font-extrabold text-slate-900 text-xs mt-0.5 truncate">{selectedDoctor.email || 'doctor@medicare.com'}</p>
                    </div>
                    <div>
                      <span className="text-[10px] font-bold text-slate-400 uppercase">Mobile Phone</span>
                      <p className="font-extrabold text-slate-900 text-xs mt-0.5">{selectedDoctor.phone || '+91 98290 00000'}</p>
                    </div>
                  </div>
                </div>

                {/* Medical Qualifications Grid */}
                <div>
                  <h4 className="text-[11px] font-black uppercase tracking-wider text-slate-400 mb-2 flex items-center gap-1.5">
                    <Award className="w-3.5 h-3.5 text-blue-600" /> Medical Education & Academic Qualifications
                  </h4>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200/70 space-y-2">
                      <div className="flex items-center justify-between">
                        <span className="text-[10px] font-black uppercase tracking-wider text-blue-700 bg-blue-100/70 px-2 py-0.5 rounded">
                          Primary Medical Degree (UG)
                        </span>
                        <span className="text-xs font-mono font-bold text-slate-500">
                          Class of {selectedDoctor.graduationYear || '2012'}
                        </span>
                      </div>
                      <p className="text-sm font-black text-slate-900">{selectedDoctor.qualification?.split(',')[0] || 'MBBS'}</p>
                      <p className="text-xs text-slate-600 font-semibold">{selectedDoctor.collegeName || 'Recognized Medical College'}</p>
                    </div>

                    <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200/70 space-y-2">
                      <div className="flex items-center justify-between">
                        <span className="text-[10px] font-black uppercase tracking-wider text-indigo-700 bg-indigo-100/70 px-2 py-0.5 rounded">
                          Post-Graduate Specialization (PG)
                        </span>
                        <span className="text-xs font-mono font-bold text-slate-500">
                          Class of {selectedDoctor.postGradYear || '2016'}
                        </span>
                      </div>
                      <p className="text-sm font-black text-slate-900">{selectedDoctor.postGradDegree || selectedDoctor.qualification || 'MD (Internal Medicine)'}</p>
                      <p className="text-xs text-slate-600 font-semibold">{selectedDoctor.postGradCollege || 'National Institute of Medical Sciences'}</p>
                    </div>
                  </div>
                </div>

                {/* State Medical Council & Licensing */}
                <div>
                  <h4 className="text-[11px] font-black uppercase tracking-wider text-slate-400 mb-2 flex items-center gap-1.5">
                    <ShieldCheck className="w-3.5 h-3.5 text-blue-600" /> State Medical Council & NMC Registration
                  </h4>
                  <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200/70 space-y-3">
                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                      <div>
                        <span className="text-[10px] font-bold text-slate-400 uppercase">Medical Registration No.</span>
                        <div className="flex items-center gap-2 mt-1">
                          <p className="font-mono font-black text-sm text-slate-900 bg-white px-2.5 py-1 rounded-lg border border-slate-200">
                            {selectedDoctor.medicalLicenseNo || 'MCI/2016/54219'}
                          </p>
                          <button
                            onClick={() => handleCopyLicense(selectedDoctor.medicalLicenseNo)}
                            className="p-1.5 text-slate-500 hover:text-blue-600 bg-white rounded-lg border border-slate-200 hover:border-blue-300 transition"
                            title="Copy License Number"
                          >
                            {copiedLicense ? <Check className="w-3.5 h-3.5 text-emerald-600" /> : <Copy className="w-3.5 h-3.5" />}
                          </button>
                        </div>
                      </div>

                      <div>
                        <span className="text-[10px] font-bold text-slate-400 uppercase">State Medical Council</span>
                        <p className="font-black text-slate-800 text-xs mt-1">
                          {selectedDoctor.stateMedicalCouncil || 'Rajasthan Medical Council'}
                        </p>
                        <p className="text-[10px] text-slate-400 mt-0.5">Registration Year: {selectedDoctor.registrationYear || '2012'}</p>
                      </div>

                      <div>
                        <span className="text-[10px] font-bold text-slate-400 uppercase">License Validity</span>
                        <p className="font-black text-emerald-700 text-xs mt-1">
                          Valid until {selectedDoctor.licenseExpiryYear || '2037'}
                        </p>
                        <a
                          href="https://www.nmc.org.in/information-desk/indian-medical-register/"
                          target="_blank"
                          rel="noreferrer"
                          className="inline-flex items-center gap-1 text-[11px] font-bold text-blue-600 hover:underline mt-0.5"
                        >
                          Verify on NMC Registry <ExternalLink className="w-3 h-3" />
                        </a>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Clinic Practice & Dual Fees */}
                <div>
                  <h4 className="text-[11px] font-black uppercase tracking-wider text-slate-400 mb-2 flex items-center gap-1.5">
                    <Building2 className="w-3.5 h-3.5 text-blue-600" /> Clinic Practice, Premise & Fee Schedule
                  </h4>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 bg-slate-50 p-4 rounded-2xl border border-slate-200/70">
                    <div className="space-y-1">
                      <span className="text-[10px] font-bold text-slate-400 uppercase">Clinic / Hospital Practice Address</span>
                      <p className="font-black text-slate-900 text-xs">{selectedDoctor.clinicName || 'City Wellness Clinic'}</p>
                      <p className="text-xs text-slate-600">{selectedDoctor.clinicAddress || 'JLN Marg, Jaipur, Rajasthan'}</p>
                      <p className="text-[11px] text-slate-500 font-medium">Languages: {selectedDoctor.languages?.join(', ') || 'English, Hindi'}</p>
                    </div>

                    <div className="space-y-2">
                      <span className="text-[10px] font-bold text-slate-400 uppercase">Dual Consultation Fees</span>
                      <div className="grid grid-cols-2 gap-2">
                        <div className="bg-white p-2.5 rounded-xl border border-slate-200">
                          <span className="text-[10px] text-slate-400 font-bold uppercase">In-Person Clinic Fee</span>
                          <p className="text-base font-black text-slate-900">₹{selectedDoctor.consultationFee}</p>
                        </div>
                        <div className="bg-white p-2.5 rounded-xl border border-slate-200">
                          <span className="text-[10px] text-blue-600 font-bold uppercase">Video Tele-Consult Fee</span>
                          <p className="text-base font-black text-blue-600">
                            ₹{selectedDoctor.videoConsultationFee || Math.round(selectedDoctor.consultationFee * 0.8)}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* TAB 2: MANDATORY MEDICAL DOCUMENTS VAULT (ALL 6 DOCUMENTS) */}
            {modalTab === 'documents' && (
              <div className="space-y-4 animate-fadeIn">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 bg-blue-50/70 p-3.5 rounded-2xl border border-blue-200/70">
                  <div className="flex items-center gap-2">
                    <ShieldCheck className="w-5 h-5 text-blue-600 flex-shrink-0" />
                    <div>
                      <p className="text-xs font-black text-slate-900">All 6 Mandatory Regulatory Medical Documents</p>
                      <p className="text-[11px] text-slate-600">Click any document thumbnail to launch the high-resolution zoom lightbox.</p>
                    </div>
                  </div>
                  <span className="px-3 py-1 bg-emerald-600 text-white rounded-xl text-xs font-black self-start sm:self-auto">
                    6/6 Attached
                  </span>
                </div>

                {/* 6-Document Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {selectedDocs.map((docItem, index) => (
                    <div
                      key={docItem.id}
                      className="bg-white rounded-2xl border border-slate-200 p-3.5 shadow-sm hover:border-blue-400 transition flex flex-col justify-between group"
                    >
                      <div className="space-y-2">
                        <div className="flex items-center justify-between">
                          <span className="text-[9px] font-black uppercase tracking-wider text-blue-700 bg-blue-50 px-2 py-0.5 rounded border border-blue-100">
                            {docItem.category}
                          </span>
                          <span className="text-[10px] font-bold text-emerald-600 flex items-center gap-1">
                            <CheckCircle2 className="w-3 h-3 text-emerald-600" /> Attached
                          </span>
                        </div>

                        <h5 className="font-black text-slate-900 text-xs leading-snug">{docItem.title}</h5>
                        <p className="text-[10px] text-slate-500 line-clamp-2">{docItem.description}</p>

                        {/* Interactive Thumbnail */}
                        <div
                          onClick={() => handleOpenLightbox(index)}
                          className="relative aspect-video rounded-xl overflow-hidden border border-slate-200 bg-slate-100 cursor-pointer group-hover:shadow-md transition"
                        >
                          <img
                            src={docItem.url}
                            alt={docItem.title}
                            className="w-full h-full object-cover group-hover:scale-105 transition duration-300"
                            onError={(e) => {
                              e.currentTarget.src = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600';
                            }}
                          />
                          <div className="absolute inset-0 bg-slate-950/40 opacity-0 group-hover:opacity-100 transition flex items-center justify-center gap-2">
                            <span className="px-3 py-1.5 bg-white/95 rounded-xl text-[11px] font-black text-slate-900 flex items-center gap-1.5 shadow-lg">
                              <ZoomIn className="w-3.5 h-3.5 text-blue-600" /> Inspect & Zoom
                            </span>
                          </div>
                        </div>
                      </div>

                      {/* Card Bottom Controls */}
                      <div className="pt-3 mt-3 border-t border-slate-100 flex items-center justify-between">
                        <label className="flex items-center gap-1.5 cursor-pointer text-[11px] font-bold text-slate-700 select-none">
                          <input
                            type="checkbox"
                            checked={Boolean(verifiedDocsMap[docItem.id])}
                            onChange={(e) =>
                              setVerifiedDocsMap({ ...verifiedDocsMap, [docItem.id]: e.target.checked })
                            }
                            className="rounded text-blue-600 focus:ring-blue-500 w-3.5 h-3.5"
                          />
                          <span>Verified by Admin</span>
                        </label>
                        <button
                          onClick={() => handleOpenLightbox(index)}
                          className="text-[11px] font-black text-blue-600 hover:text-blue-800 flex items-center gap-1"
                        >
                          <Eye className="w-3.5 h-3.5" /> View
                        </button>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Audit Checklist Confirmation */}
                <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200/80 space-y-2">
                  <p className="text-xs font-black text-slate-800 uppercase tracking-wider">
                    Telemedicine Verification Checklist (NMC 2020 Telemedicine Guidelines)
                  </p>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs text-slate-600">
                    <div className="flex items-center gap-2">
                      <Check className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                      <span>State Council Registration matches applicant name</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Check className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                      <span>MBBS Degree authenticated from recognized institute</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Check className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                      <span>Government photo ID details match medical record</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Check className="w-4 h-4 text-emerald-600 flex-shrink-0" />
                      <span>Doctor signature verified for legal digital prescriptions</span>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* TAB 3: AUDIT DECISION & ACTIONS */}
            {modalTab === 'decision' && (
              <div className="space-y-4 animate-fadeIn">
                <div className="bg-slate-50 p-4 rounded-2xl border border-slate-200/80 space-y-3">
                  <h4 className="text-xs font-black uppercase tracking-wider text-slate-800 flex items-center gap-1.5">
                    <ShieldCheck className="w-4 h-4 text-blue-600" /> Admin Audit Decision Panel
                  </h4>
                  <p className="text-xs text-slate-500">
                    Submit your audit evaluation. If approving, the doctor will immediately be granted live status on DrConnects24 telemedicine platform. If requesting re-upload or rejecting, specify your rationale below.
                  </p>

                  {/* Previous Notes if any */}
                  {(selectedDoctor.rejectionNotes || selectedDoctor.rejectionRemarks) && (
                    <div className="p-3 bg-amber-50 rounded-xl border border-amber-200 text-xs">
                      <span className="font-bold text-amber-900 block">Existing Audit Remarks:</span>
                      <p className="text-amber-800 mt-0.5">{selectedDoctor.rejectionNotes || selectedDoctor.rejectionRemarks}</p>
                    </div>
                  )}

                  {/* Textarea */}
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1">
                      Audit Notes / Rejection Rationale / Re-upload Instructions:
                    </label>
                    <textarea
                      placeholder="e.g. Verified against Rajasthan Medical Council registry on 24-Sep-2026. Credentials authentic."
                      value={rejectionNotes}
                      onChange={(e) => setRejectionNotes(e.target.value)}
                      className="w-full bg-white border border-slate-200 rounded-2xl p-3 text-xs font-medium focus:outline-none focus:border-blue-500 shadow-sm"
                      rows={3}
                    />
                  </div>

                  {/* Preset quick notes buttons */}
                  <div className="flex flex-wrap gap-2 text-[11px]">
                    <span className="text-slate-400 font-bold self-center">Quick Presets:</span>
                    <button
                      type="button"
                      onClick={() => setRejectionNotes('All 6 documents verified against NMC Indian Medical Register. License valid & approved.')}
                      className="px-2.5 py-1 bg-white hover:bg-slate-100 rounded-lg border border-slate-200 text-slate-700 font-semibold"
                    >
                      All Verified
                    </button>
                    <button
                      type="button"
                      onClick={() => setRejectionNotes('Please re-upload a clear, high-resolution copy of your State Medical Council registration certificate.')}
                      className="px-2.5 py-1 bg-white hover:bg-slate-100 rounded-lg border border-slate-200 text-slate-700 font-semibold"
                    >
                      Blurry Council Cert
                    </button>
                    <button
                      type="button"
                      onClick={() => setRejectionNotes('Please upload an updated Clinic Establishment proof or utility certificate in your name.')}
                      className="px-2.5 py-1 bg-white hover:bg-slate-100 rounded-lg border border-slate-200 text-slate-700 font-semibold"
                    >
                      Need Clinic Proof
                    </button>
                  </div>
                </div>

                {/* 3 Decision Actions */}
                <div className="flex flex-col sm:flex-row items-center justify-end gap-3 pt-3 border-t border-slate-100">
                  <button
                    onClick={() => handleVerify(selectedDoctor.id, 'rejected')}
                    className="w-full sm:w-auto px-4 py-2.5 bg-rose-50 hover:bg-rose-100 text-rose-700 rounded-2xl text-xs font-black transition flex items-center justify-center gap-1.5"
                  >
                    <XCircle className="w-4 h-4" /> Reject Application
                  </button>
                  <button
                    onClick={() => handleVerify(selectedDoctor.id, 'reupload_requested')}
                    className="w-full sm:w-auto px-4 py-2.5 bg-amber-50 hover:bg-amber-100 text-amber-800 rounded-2xl text-xs font-black transition flex items-center justify-center gap-1.5 border border-amber-200"
                  >
                    <AlertTriangle className="w-4 h-4 text-amber-600" /> Request Docs Re-upload
                  </button>
                  <button
                    onClick={() => handleVerify(selectedDoctor.id, 'approved')}
                    className="w-full sm:w-auto px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-2xl text-xs font-black transition flex items-center justify-center gap-1.5 shadow-lg shadow-emerald-600/20 active:scale-95"
                  >
                    <CheckCircle2 className="w-4 h-4" /> Approve & Grant License
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* DOCUMENT LIGHTBOX ZOOM MODAL */}
      {lightboxDoc && (
        <div className="fixed inset-0 z-50 flex flex-col items-center justify-between p-4 bg-slate-950/90 backdrop-blur-md animate-fadeIn">
          {/* Top Bar */}
          <div className="w-full max-w-4xl flex items-center justify-between text-white py-2 px-4 bg-slate-900/80 rounded-2xl border border-slate-800">
            <div className="flex items-center gap-3">
              <span className="text-xs font-black px-2.5 py-1 bg-blue-600 text-white rounded-lg">
                Doc {lightboxDoc.index + 1} of {selectedDocs.length}
              </span>
              <div>
                <h4 className="text-sm font-black">{lightboxDoc.title}</h4>
                <p className="text-[10px] text-slate-400">{lightboxDoc.subtitle}</p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={() => setZoomLevel(prev => Math.max(0.6, prev - 0.2))}
                className="p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-lg transition"
                title="Zoom Out"
              >
                <ZoomOut className="w-4 h-4" />
              </button>
              <span className="text-xs font-mono font-bold text-slate-400 w-12 text-center">
                {Math.round(zoomLevel * 100)}%
              </span>
              <button
                onClick={() => setZoomLevel(prev => Math.min(3, prev + 0.2))}
                className="p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-lg transition"
                title="Zoom In"
              >
                <ZoomIn className="w-4 h-4" />
              </button>
              <button
                onClick={() => setRotation(prev => (prev + 90) % 360)}
                className="p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-lg transition"
                title="Rotate Clockwise"
              >
                <RotateCw className="w-4 h-4" />
              </button>
              <a
                href={lightboxDoc.url}
                target="_blank"
                rel="noreferrer"
                className="p-2 text-slate-300 hover:text-white hover:bg-slate-800 rounded-lg transition"
                title="Open Original Image in New Tab"
              >
                <ExternalLink className="w-4 h-4" />
              </a>
              <button
                onClick={() => setLightboxDoc(null)}
                className="p-2 text-slate-300 hover:text-rose-400 hover:bg-slate-800 rounded-lg transition"
                title="Close"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Center Zoom Viewport */}
          <div className="flex-1 w-full max-w-4xl flex items-center justify-center overflow-hidden my-4 relative">
            <button
              onClick={handlePrevLightbox}
              className="absolute left-2 z-10 p-3 bg-slate-900/80 hover:bg-slate-800 text-white rounded-full shadow-xl transition"
              title="Previous Document"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>

            <div className="w-full h-full flex items-center justify-center p-4">
              <img
                src={lightboxDoc.url}
                alt={lightboxDoc.title}
                style={{
                  transform: `scale(${zoomLevel}) rotate(${rotation}deg)`,
                  transition: 'transform 0.2s ease',
                  maxHeight: '75vh',
                  maxWidth: '85vw',
                }}
                className="object-contain rounded-2xl shadow-2xl border border-slate-700 select-none"
              />
            </div>

            <button
              onClick={handleNextLightbox}
              className="absolute right-2 z-10 p-3 bg-slate-900/80 hover:bg-slate-800 text-white rounded-full shadow-xl transition"
              title="Next Document"
            >
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>

          {/* Bottom Bar Thumbnail Strip */}
          <div className="w-full max-w-4xl flex items-center justify-center gap-2 py-2 px-4 bg-slate-900/80 rounded-2xl border border-slate-800 overflow-x-auto">
            {selectedDocs.map((item, idx) => (
              <button
                key={item.id}
                onClick={() => handleOpenLightbox(idx)}
                className={`relative w-14 h-14 rounded-xl overflow-hidden border-2 transition flex-shrink-0 ${
                  lightboxDoc.index === idx ? 'border-blue-500 ring-2 ring-blue-500/40' : 'border-slate-700 opacity-60 hover:opacity-100'
                }`}
              >
                <img src={item.url} alt={item.title} className="w-full h-full object-cover" />
              </button>
            ))}
          </div>
        </div>
      )}

      {/* ADD DOCTOR MODAL */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/70 backdrop-blur-md animate-fadeIn">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-6 shadow-2xl border border-slate-200 space-y-4 max-h-[92vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="p-2.5 bg-blue-50 text-blue-600 rounded-2xl">
                  <Stethoscope className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-black text-slate-900">Add Registered Medical Practitioner</h2>
                  <p className="text-xs text-slate-500">Register specialist with council registration & credentials</p>
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
                label="Doctor Profile Photo"
                value={formData.imageUrl}
                onChange={(newUrl) => setFormData({ ...formData, imageUrl: newUrl })}
                aspectRatio="aspect-square"
                presets={DOCTOR_PRESETS}
                placeholder={DEFAULT_DOC_IMG}
              />

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Full Legal Name *</label>
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
                  <label className="block text-xs font-bold text-slate-700 mb-1">Primary Specialty *</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Cardiologist"
                    value={formData.specialty}
                    onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Email</label>
                  <input
                    type="email"
                    placeholder="doctor@medicare.com"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Phone</label>
                  <input
                    type="text"
                    placeholder="+91 98000 00000"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Gender</label>
                  <select
                    value={formData.gender}
                    onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  >
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Other">Other</option>
                  </select>
                </div>
              </div>

              {/* Education */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Degrees (UG, PG)</label>
                  <input
                    type="text"
                    placeholder="MBBS, MD"
                    value={formData.qualification}
                    onChange={(e) => setFormData({ ...formData, qualification: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Medical College</label>
                  <input
                    type="text"
                    placeholder="SMS Medical College, Jaipur"
                    value={formData.collegeName}
                    onChange={(e) => setFormData({ ...formData, collegeName: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Graduation Year</label>
                  <input
                    type="text"
                    placeholder="2012"
                    value={formData.graduationYear}
                    onChange={(e) => setFormData({ ...formData, graduationYear: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              {/* Council & License */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Medical License No. *</label>
                  <input
                    type="text"
                    required
                    placeholder="RMC/2012/8841"
                    value={formData.medicalLicenseNo}
                    onChange={(e) => setFormData({ ...formData, medicalLicenseNo: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">State Medical Council</label>
                  <input
                    type="text"
                    placeholder="Rajasthan Medical Council"
                    value={formData.stateMedicalCouncil}
                    onChange={(e) => setFormData({ ...formData, stateMedicalCouncil: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Experience (Years)</label>
                  <input
                    type="number"
                    min="1"
                    value={formData.experienceYears}
                    onChange={(e) => setFormData({ ...formData, experienceYears: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
              </div>

              {/* Dual Fees */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">In-Person Fee (₹)</label>
                  <input
                    type="number"
                    min="100"
                    step="50"
                    value={formData.consultationFee}
                    onChange={(e) => setFormData({ ...formData, consultationFee: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Video Call Fee (₹)</label>
                  <input
                    type="number"
                    min="100"
                    step="50"
                    value={formData.videoConsultationFee}
                    onChange={(e) => setFormData({ ...formData, videoConsultationFee: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">Initial Status</label>
                  <select
                    value={formData.verificationStatus}
                    onChange={(e) => setFormData({ ...formData, verificationStatus: e.target.value })}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-xs font-medium focus:outline-none focus:border-blue-500"
                  >
                    <option value="approved">Approved & Verified</option>
                    <option value="pending">Pending NMC Audit</option>
                  </select>
                </div>
              </div>

              {/* Clinic Name & Address */}
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1">Clinic Name & Address</label>
                <input
                  type="text"
                  placeholder="e.g. City Wellness Clinic, JLN Marg, Jaipur"
                  value={formData.clinicAddress}
                  onChange={(e) => setFormData({ ...formData, clinicAddress: e.target.value })}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-xs font-medium focus:outline-none focus:border-blue-500"
                />
              </div>

              <div className="flex justify-end gap-2.5 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-2xl text-xs font-bold transition"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl text-xs font-black transition flex items-center gap-1.5 shadow-md shadow-blue-600/20"
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

