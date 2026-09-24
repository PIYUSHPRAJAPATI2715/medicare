import { initialUsers, initialDoctors } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const { emailOrPhone, password, role } = req.body || req.query || {};

  if (!emailOrPhone) {
    return res.status(400).json({
      status: 400,
      statusCode: 400,
      success: false,
      message: 'Email or phone number is required.',
      data: null,
    });
  }

  const cleanInput = String(emailOrPhone).trim().toLowerCase().replace(/[\s-]/g, '');
  const targetRole = role ? String(role).toLowerCase() : '';

  // 1. Doctor Login
  if (targetRole === 'doctor' || cleanInput.includes('rajesh') || cleanInput.includes('doctor')) {
    const doctor = initialDoctors.find(d => {
      const dPhone = (d.phone || '').replace(/[\s-]/g, '').toLowerCase();
      const dEmail = (d.email || '').toLowerCase();
      const dName = (d.name || '').toLowerCase();
      const dId = (d.id || '').toLowerCase();
      return (dPhone.length > 5 && (dPhone.includes(cleanInput) || cleanInput.includes(dPhone))) ||
             (dEmail.length > 3 && dEmail.includes(cleanInput)) ||
             dName.includes(cleanInput) ||
             dId === cleanInput;
    }) || (targetRole === 'doctor' ? initialDoctors[0] : null);

    if (!doctor) {
      return res.status(404).json({
        status: 404,
        statusCode: 404,
        success: false,
        message: `Doctor account not found with: ${emailOrPhone}`,
        data: null,
      });
    }

    if (doctor.verificationStatus === 'pending' || !doctor.isVerified) {
      return res.status(403).json({
        status: 403,
        statusCode: 403,
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
      statusCode: 200,
      success: true,
      message: 'Doctor login successful',
      data: {
        token: `jwt_live_doc_${doctor.id}`,
        user: {
          id: doctor.id,
          name: doctor.name,
          email: doctor.email || `${doctor.id}@drconnects24.com`,
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

  // 2. Patient / Admin Login
  const user = initialUsers.find(u => {
    const uPhone = (u.phone || '').replace(/[\s-]/g, '').toLowerCase();
    const uEmail = (u.email || '').toLowerCase();
    return (uPhone.length > 5 && (uPhone.includes(cleanInput) || cleanInput.includes(uPhone))) ||
           (uEmail.length > 3 && (uEmail === cleanInput || uEmail.includes(cleanInput)));
  });

  if (!user) {
    return res.status(404).json({
      status: 404,
      statusCode: 404,
      success: false,
      message: `Account not found with phone/email: ${emailOrPhone}. Please register.`,
      data: null,
    });
  }

  return res.status(200).json({
    status: 200,
    statusCode: 200,
    success: true,
    message: 'Login successful',
    data: {
      token: `jwt_live_${user.id}`,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role || targetRole || 'patient',
        status: user.status || 'active',
        avatarUrl: user.avatarUrl,
        currentCity: user.currentCity || 'Jaipur',
      },
    },
  });
}
