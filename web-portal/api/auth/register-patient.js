import { initialUsers } from '../data.js';

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
    u => (phone && u.phone.replace(/[\s-]/g, '') === phone.replace(/[\s-]/g, ''))
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
