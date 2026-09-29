import { addUser, getUsers, addDoctor, getDoctors, deleteUser, getUserSubscription } from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  const { action, id } = req.query;
  const pathPart = (req.url || '').split('?')[0].replace('/api/auth/', '').replace('/api/auth', '');
  const resolvedAction = action || pathPart || req.body?.action || 'login';

  // 1. Patient Registration / Signup
  if (resolvedAction === 'register-patient' || resolvedAction === 'signup' || req.method === 'POST' && resolvedAction.includes('register-patient')) {
    const { name, email, phone, password, gender, dob, currentCity } = req.body || {};

    if (!name || (!email && !phone)) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'Name and email or phone number are required for registration.',
        data: null,
      });
    }

    const newUser = addUser({
      id: `u_${Date.now()}`,
      name: name.trim(),
      email: email ? email.trim() : `user_${Date.now()}@drconnects24.com`,
      phone: phone ? phone.trim() : '+91 98765 00000',
      role: 'patient',
      status: 'active',
      gender: gender || 'Not specified',
      dob: dob || '1995-01-01',
      currentCity: currentCity || 'Jaipur',
      createdAt: new Date().toISOString(),
      avatarUrl: req.body?.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      hasActiveCarePlan: false,
      consultationsRemaining: 0,
    });

    return res.status(201).json({
      status: 201,
      statusCode: 201,
      success: true,
      message: 'Patient account registered successfully on live drconnects24 network',
      data: {
        token: `jwt_live_${newUser.id}`,
        user: newUser,
      },
    });
  }

  // 2. Doctor Registration
  if (resolvedAction === 'doctor-register') {
    const {
      name,
      email,
      phone,
      specialty,
      qualification,
      experienceYears,
      consultationFee,
      clinicName,
      clinicAddress,
      medicalLicenseNo,
      stateMedicalCouncil,
      qualificationCertUrl,
      idProofUrl,
      clinicAddressProofUrl,
    } = req.body || {};

    const docId = `d_${Date.now()}`;
    const newDoctor = addDoctor({
      id: docId,
      name: name || 'Dr. Specialist',
      email: email || `dr.${docId}@drconnects24.com`,
      phone: phone || '+91 90000 00000',
      specialty: specialty || 'General Physician',
      qualification: qualification || 'MBBS',
      experienceYears: Number(experienceYears) || 3,
      consultationFee: Number(consultationFee) || 500,
      clinicName: clinicName || 'Health Clinic',
      clinicAddress: clinicAddress || 'Jaipur',
      medicalLicenseNo: medicalLicenseNo || 'MCI/2026/PENDING',
      stateMedicalCouncil: stateMedicalCouncil || 'Medical Council of India',
      qualificationCertUrl: qualificationCertUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      idProofUrl: idProofUrl || 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600',
      clinicAddressProofUrl: clinicAddressProofUrl || 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600',
      isVerified: false,
      verificationStatus: 'pending',
    });

    const newUser = addUser({
      id: `u_${Date.now()}`,
      name: name || 'Dr. Specialist',
      email: email || `dr.${docId}@drconnects24.com`,
      phone: phone || '+91 90000 00000',
      role: 'doctor',
      status: 'pending_verification',
      doctorId: docId,
      avatarUrl: newDoctor.imageUrl,
    });

    return res.status(201).json({
      status: 201,
      statusCode: 201,
      success: true,
      message: 'Doctor application submitted successfully! Under review by drconnects24 admin.',
      data: {
        doctor: newDoctor,
        user: newUser,
      },
    });
  }

  // 3. Doctor Verification Status Check
  if (resolvedAction === 'doctor-status' || resolvedAction.startsWith('doctor-status')) {
    const doctorId = id || req.query.doctorId || req.body?.doctorId;
    const doctors = getDoctors({ all: 'true' });
    const doctor = doctors.find(d => d.id === doctorId);

    if (!doctor) {
      return res.status(404).json({
        status: 404,
        statusCode: 404,
        success: false,
        message: 'Doctor record not found',
        data: null,
      });
    }

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Doctor status retrieved',
      data: {
        id: doctor.id,
        isVerified: doctor.isVerified,
        verificationStatus: doctor.verificationStatus || (doctor.isVerified ? 'approved' : 'pending'),
        rejectionNotes: doctor.rejectionNotes || null,
      },
    });
  }

  // 4. Delete Account
  if (resolvedAction === 'delete-account' || req.method === 'DELETE') {
    const userId = id || req.query.userId || req.body?.userId;
    if (!userId) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'User ID is required to delete account',
        data: null,
      });
    }

    deleteUser(userId);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'User account and profile deleted successfully',
      data: { id: userId, deleted: true },
    });
  }

  // 5. Login
  const { emailOrPhone, password, role } = req.body || req.query || {};
  if (!emailOrPhone) {
    return res.status(400).json({
      status: 400,
      statusCode: 400,
      success: false,
      message: 'Email or phone is required',
      data: null,
    });
  }

  const clean = String(emailOrPhone).trim().toLowerCase().replace(/[\s-]/g, '');
  const users = getUsers();
  const user = users.find(u => {
    const uPhone = (u.phone || '').replace(/[\s-]/g, '').toLowerCase();
    const uEmail = (u.email || '').toLowerCase();
    return uPhone === clean || uEmail === clean;
  });

  if (user) {
    const activeSub = getUserSubscription(user.id);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Authentication successful',
      data: {
        token: `jwt_live_${user.id}`,
        role: user.role || 'patient',
        user: {
          ...user,
          hasActiveCarePlan: !!activeSub,
          activePlanName: activeSub ? activeSub.planName : user.activePlanName,
        },
      },
    });
  }

  return res.status(401).json({
    status: 401,
    statusCode: 401,
    success: false,
    message: 'User not found. Please register.',
    data: null,
  });
}
