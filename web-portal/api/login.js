import { getUsers, getDoctors, getUserSubscription } from './store.js';

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

  const users = getUsers();
  const doctors = getDoctors({ all: 'true' });

  // 1. Doctor Login
  if (targetRole === 'doctor' || cleanInput.includes('rajesh') || cleanInput.includes('doctor')) {
    const doctor = doctors.find(d => {
      const dPhone = (d.phone || '').replace(/[\s-]/g, '').toLowerCase();
      const dEmail = (d.email || '').toLowerCase();
      const dName = (d.name || '').toLowerCase();
      return (dEmail && dEmail.includes(cleanInput)) ||
             (dPhone && dPhone.includes(cleanInput)) ||
             (dName && dName.includes(cleanInput));
    });

    if (doctor) {
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'Doctor authentication successful',
        data: {
          token: `jwt_doctor_${doctor.id}`,
          role: 'doctor',
          user: {
            id: doctor.id,
            name: doctor.name,
            email: doctor.email || 'dr.specialist@drconnects24.com',
            phone: doctor.phone || '+91 98290 11223',
            role: 'doctor',
            status: doctor.isVerified ? 'active' : 'pending_verification',
            doctorId: doctor.id,
            isVerified: doctor.isVerified,
            specialty: doctor.specialty,
            avatarUrl: doctor.imageUrl,
          },
        },
      });
    }
  }

  // 2. Admin Login
  if (targetRole === 'admin' || cleanInput.includes('admin')) {
    const adminUser = users.find(u => u.role === 'admin') || {
      id: 'u6',
      name: 'System Admin',
      email: 'admin@drconnects24.com',
      phone: '+91 99000 00000',
      role: 'admin',
      status: 'active',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    };

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Admin authentication successful',
      data: {
        token: `jwt_admin_${adminUser.id}`,
        role: 'admin',
        user: adminUser,
      },
    });
  }

  // 3. Patient Login (Check live users first)
  const user = users.find(u => {
    const uPhone = (u.phone || '').replace(/[\s-]/g, '').toLowerCase();
    const uEmail = (u.email || '').toLowerCase();
    const uName = (u.name || '').toLowerCase();
    return (uEmail && uEmail === cleanInput) ||
           (uPhone && uPhone === cleanInput) ||
           (cleanInput.length >= 6 && uPhone.includes(cleanInput)) ||
           (cleanInput.length >= 4 && uName.includes(cleanInput));
  });

  if (user) {
    const activeSub = getUserSubscription(user.id);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Patient login successful',
      data: {
        token: `jwt_live_${user.id}`,
        role: user.role || 'patient',
        user: {
          ...user,
          hasActiveCarePlan: !!activeSub,
          activePlanName: activeSub ? activeSub.planName : user.activePlanName,
          consultationsRemaining: activeSub ? activeSub.consultationsRemaining : user.consultationsRemaining,
        },
        subscription: activeSub,
      },
    });
  }

  // 4. Doctor matched as fallback
  const fallbackDoctor = doctors.find(d => {
    const dPhone = (d.phone || '').replace(/[\s-]/g, '').toLowerCase();
    const dEmail = (d.email || '').toLowerCase();
    return (dEmail && dEmail === cleanInput) || (dPhone && dPhone === cleanInput);
  });

  if (fallbackDoctor) {
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Doctor login successful',
      data: {
        token: `jwt_doctor_${fallbackDoctor.id}`,
        role: 'doctor',
        user: {
          id: fallbackDoctor.id,
          name: fallbackDoctor.name,
          email: fallbackDoctor.email || 'dr.specialist@drconnects24.com',
          phone: fallbackDoctor.phone || '+91 98290 11223',
          role: 'doctor',
          status: fallbackDoctor.isVerified ? 'active' : 'pending_verification',
          doctorId: fallbackDoctor.id,
          isVerified: fallbackDoctor.isVerified,
          specialty: fallbackDoctor.specialty,
          avatarUrl: fallbackDoctor.imageUrl,
        },
      },
    });
  }

  // Invalid Credentials
  return res.status(401).json({
    status: 401,
    statusCode: 401,
    success: false,
    message: 'Invalid credentials. User not found. Please register.',
    data: null,
  });
}
