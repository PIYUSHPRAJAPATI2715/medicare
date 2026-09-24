import { initialUsers, initialDoctors } from '../data.js';

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

  // 1. Doctor login flow
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

  // 2. Patient / Admin login flow
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
