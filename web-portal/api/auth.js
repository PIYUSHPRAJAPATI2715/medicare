import { initialUsers, initialDoctors } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  // Determine action from query, url, or body
  const action = req.query.action || req.body?.action || (req.url.includes('login') ? 'login' : req.url.includes('doctor-status') ? 'doctor-status' : req.url.includes('doctor-register') ? 'doctor-register' : req.url.includes('register-patient') ? 'register-patient' : 'login');

  // 1. DOCTOR STATUS
  if (action === 'doctor-status' || req.method === 'GET') {
    const id = req.query.id || req.query.doctorId;
    if (!id) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'Doctor ID is required',
        data: null,
      });
    }
    const doc = initialDoctors.find(d => d.id === id);
    if (!doc) {
      return res.status(404).json({
        status: 404,
        success: false,
        message: 'Doctor not found',
        data: null,
      });
    }
    const status = doc.verificationStatus || (doc.isVerified ? 'approved' : 'pending');
    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Doctor verification status fetched successfully',
      data: {
        doctorId: doc.id,
        name: doc.name,
        status: status,
        isVerified: status === 'approved',
        rejectionReason: doc.rejectionReason || null,
        submittedAt: doc.createdAt || null,
      },
    });
  }

  // 2. REGISTER PATIENT / SIGNUP
  if (action === 'register-patient' || action === 'signup') {
    const { name, email, phone, password, gender, dob, currentCity } = req.body || {};
    if (!name || !phone) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'Full Name and Phone Number are required fields',
        data: null,
      });
    }

    const existing = initialUsers.find(
      u => (phone && u.phone && u.phone.replace(/[\s-]/g, '') === String(phone).replace(/[\s-]/g, ''))
    );
    if (existing) {
      return res.status(409).json({
        status: 409,
        success: false,
        message: 'An account with this phone number already exists. Please login.',
        data: null,
      });
    }

    const newUser = {
      id: `u_${Date.now()}`,
      name,
      email: email || '',
      phone,
      role: 'patient',
      status: 'active',
      gender: gender || 'Male',
      dob: dob || '1995-08-15',
      currentCity: currentCity || 'Jaipur',
      createdAt: new Date().toISOString(),
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    };
    initialUsers.unshift(newUser);

    return res.status(201).json({
      status: 201,
      success: true,
      message: 'Patient account created successfully',
      data: {
        token: `jwt_${newUser.id}_${Date.now()}`,
        user: newUser,
      },
    });
  }

  // 3. DOCTOR REGISTER
  if (action === 'doctor-register') {
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

  // 4. DELETE ACCOUNT
  if (action === 'delete-account' || req.method === 'DELETE') {
    const id = req.query.id || req.body?.userId || req.body?.id;
    if (!id) {
      return res.status(400).json({
        status: 400,
        success: false,
        message: 'User ID is required to delete account',
        data: null,
      });
    }
    const uIdx = initialUsers.findIndex(u => u.id === id);
    if (uIdx !== -1) initialUsers.splice(uIdx, 1);
    const dIdx = initialDoctors.findIndex(d => d.id === id);
    if (dIdx !== -1) initialDoctors.splice(dIdx, 1);

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Account deleted permanently from MediCare+ system',
      data: { id, deleted: true },
    });
  }

  // 5. UNIFIED LOGIN (default)
  const { emailOrPhone, password, role } = req.body || {};

  if (!emailOrPhone || !password) {
    return res.status(400).json({
      status: 400,
      success: false,
      message: 'Email/Phone and password are required',
      data: null,
    });
  }

  const cleanInput = String(emailOrPhone).trim().toLowerCase();
  const targetRole = role ? String(role).toLowerCase() : 'patient';

  // Doctor login
  if (targetRole === 'doctor') {
    const doctor = initialDoctors.find(
      d => (d.email && d.email.toLowerCase() === cleanInput) ||
           (d.phone && d.phone.replace(/[\s-]/g, '') === cleanInput.replace(/[\s-]/g, '')) ||
           d.name.toLowerCase().includes(cleanInput)
    );

    if (!doctor) {
      return res.status(404).json({
        status: 404,
        success: false,
        message: 'Doctor account not found with given credentials.',
        data: null,
      });
    }

    if (doctor.verificationStatus === 'pending' || !doctor.isVerified) {
      return res.status(403).json({
        status: 403,
        success: false,
        message: 'Your doctor profile is under verification. Credential review in progress.',
        data: {
          status: 'pending',
          isVerified: false,
          doctor,
        },
      });
    }

    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Doctor login successful',
      data: {
        token: `jwt_doc_${doctor.id}_${Date.now()}`,
        user: {
          id: doctor.id,
          name: doctor.name,
          email: doctor.email || `${doctor.id}@medicare.com`,
          phone: doctor.phone || '+91 98290 11223',
          role: 'doctor',
          avatarUrl: doctor.imageUrl,
          specialty: doctor.specialty,
          isVerified: doctor.isVerified,
          verificationStatus: doctor.verificationStatus,
        },
      },
    });
  }

  // Patient / Admin login
  let user = initialUsers.find(
    u => (u.email && u.email.toLowerCase() === cleanInput) ||
         (u.phone && u.phone.replace(/[\s-]/g, '') === cleanInput.replace(/[\s-]/g, ''))
  );

  if (!user && targetRole === 'patient') {
    user = initialUsers.find(u => u.role === 'patient');
  }

  if (!user) {
    return res.status(404).json({
      status: 404,
      success: false,
      message: 'Account not found. Please register first.',
      data: null,
    });
  }

  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Login successful',
    data: {
      token: `jwt_${user.id}_${Date.now()}`,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role || targetRole,
        status: user.status || 'active',
        avatarUrl: user.avatarUrl,
        currentCity: user.currentCity || 'Jaipur',
      },
    },
  });
}
