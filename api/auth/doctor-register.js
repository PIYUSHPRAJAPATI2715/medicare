import { initialDoctors } from '../data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({
      status: 405,
      success: false,
      message: 'Method not allowed. Use POST.',
      data: null,
    });
  }

  const data = req.body || {};

  if (!data.name || !data.medicalLicenseNo || !data.specialty) {
    return res.status(400).json({
      status: 400,
      success: false,
      message: 'Doctor name, medical license number, and specialty are required.',
      data: null,
    });
  }

  const newDoc = {
    id: `d_${Date.now()}`,
    name: data.name,
    specialty: data.specialty,
    subSpecialty: data.subSpecialty || '',
    qualification: data.qualification || 'MBBS',
    experienceYears: Number(data.experienceYears) || 5,
    experienceText: `${data.experienceYears || 5} yrs exp`,
    ratingPercentage: 100,
    patientStoriesCount: 0,
    consultationFee: Number(data.consultationFee) || 500,
    imageUrl: data.imageUrl || 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
    isOnline: false,
    allowsPhysical: true,
    allowsVideo: true,
    isVerified: false,
    verificationStatus: 'pending',
    phone: data.phone || '',
    email: data.email || '',
    medicalLicenseNo: data.medicalLicenseNo,
    stateMedicalCouncil: data.stateMedicalCouncil || '',
    registrationYear: data.registrationYear || '2020',
    clinicName: data.clinicName || '',
    clinicAddress: data.clinicAddress || '',
    city: data.city || 'Jaipur',
    pincode: data.pincode || '',
    medicalCouncilCertUrl: data.medicalCouncilCertUrl || '',
    primaryDegreeCertUrl: data.primaryDegreeCertUrl || '',
    postGradCertUrl: data.postGradCertUrl || '',
    idProofUrl: data.idProofUrl || '',
    clinicAddressProofUrl: data.clinicAddressProofUrl || '',
    doctorSignatureUrl: data.doctorSignatureUrl || '',
    bankName: data.bankName || '',
    accountHolder: data.accountHolder || '',
    accountNo: data.accountNo || '',
    ifscCode: data.ifscCode || '',
    upiId: data.upiId || '',
    panNumber: data.panNumber || '',
    languages: Array.isArray(data.languages) ? data.languages : ['English', 'Hindi'],
    aboutText: data.aboutText || '',
    services: Array.isArray(data.services) ? data.services : ['General Consultation'],
    createdAt: new Date().toISOString(),
  };

  initialDoctors.unshift(newDoc);

  return res.status(201).json({
    status: 201,
    success: true,
    message: 'Doctor registration submitted successfully! Profile is under verification.',
    data: {
      status: 'pending',
      isVerified: false,
      doctor: newDoc,
    },
  });
}
