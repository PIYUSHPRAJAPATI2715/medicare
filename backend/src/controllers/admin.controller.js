const db = require('../models/data_store');

// --- DOCTOR REGISTRATION & ADMIN VERIFICATION ---
exports.registerDoctor = (req, res) => {
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
  } = req.body;

  const docId = `d${Date.now()}`;
  const userId = `u${Date.now()}`;

  const newDoctor = {
    id: docId,
    name: name || 'Dr. Practitioner',
    specialty: specialty || 'General Physician',
    qualification: qualification || 'MBBS',
    experienceYears: Number(experienceYears) || 3,
    experienceText: `${experienceYears || 3} yrs exp`,
    ratingPercentage: 100,
    patientStoriesCount: 0,
    consultationFee: Number(consultationFee) || 500,
    imageUrl: req.body.imageUrl || 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
    isOnline: false,
    allowsPhysical: true,
    allowsVideo: true,
    isVerified: false,
    verificationStatus: 'pending',
    medicalLicenseNo: medicalLicenseNo || 'MCI/2026/PENDING',
    stateMedicalCouncil: stateMedicalCouncil || 'Medical Council of India',
    qualificationCertUrl: qualificationCertUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
    idProofUrl: idProofUrl || 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600',
    clinicAddressProofUrl: clinicAddressProofUrl || 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600',
    clinicName: clinicName || 'Health Clinic',
    clinicAddress: clinicAddress || 'Jaipur',
    distanceKm: 2.0,
    languages: ['English', 'Hindi'],
    aboutText: `${name} is a medical specialist registered with ${stateMedicalCouncil}.`,
    services: ['General Consultation', 'Telehealth Care'],
  };

  const newUser = {
    id: userId,
    name: name || 'Doctor',
    email: email || `dr.${docId}@medicare.com`,
    phone: phone || '+91 90000 00000',
    role: 'doctor',
    status: 'pending_verification',
    doctorId: docId,
    createdAt: new Date().toISOString(),
    avatarUrl: newDoctor.imageUrl,
  };

  db.doctors.push(newDoctor);
  db.users.push(newUser);

  res.json({
    success: true,
    message: 'Doctor registration submitted successfully! Under review by MediCare+ Admin.',
    data: { doctor: newDoctor, user: newUser },
  });
};

exports.getPendingDoctors = (req, res) => {
  const pending = db.doctors.filter(d => d.verificationStatus === 'pending' || !d.isVerified);
  res.json({ success: true, count: pending.length, data: pending });
};

exports.verifyDoctor = (req, res) => {
  const { id } = req.params;
  const { action, rejectionNotes } = req.body; // 'approve' or 'reject'

  const idx = db.doctors.findIndex(d => d.id === id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'Doctor not found' });

  if (action === 'approve') {
    db.doctors[idx].isVerified = true;
    db.doctors[idx].verificationStatus = 'approved';
    db.doctors[idx].isOnline = true;
    delete db.doctors[idx].rejectionNotes;

    // Update associated user status
    const uIdx = db.users.findIndex(u => u.doctorId === id);
    if (uIdx !== -1) db.users[uIdx].status = 'active';

    return res.json({
      success: true,
      message: `Doctor ${db.doctors[idx].name} verified and approved successfully!`,
      data: db.doctors[idx],
    });
  } else if (action === 'reject') {
    db.doctors[idx].isVerified = false;
    db.doctors[idx].verificationStatus = 'rejected';
    db.doctors[idx].rejectionNotes = rejectionNotes || 'License documentation verification failed.';

    return res.json({
      success: true,
      message: `Doctor application rejected with feedback notes.`,
      data: db.doctors[idx],
    });
  }

  res.status(400).json({ success: false, message: 'Invalid verification action. Use approve or reject.' });
};

// --- ANALYTICS ---
exports.getAnalytics = (req, res) => {
  const totalUsers = db.users.length;
  const totalDoctors = db.doctors.length;
  const totalHospitals = db.hospitals.length;
  const totalAppointments = db.appointments.length;
  const completedAppointments = db.appointments.filter(a => a.status === 'completed').length;
  const totalRevenue = db.appointments.reduce((sum, a) => sum + (a.totalAmount || 0), 0);
  const activeDoctors = db.doctors.filter(d => d.isOnline && d.isVerified).length;
  const pendingApprovals = db.doctors.filter(d => d.verificationStatus === 'pending').length;

  res.json({
    success: true,
    data: {
      totalUsers,
      totalDoctors,
      totalHospitals,
      totalAppointments,
      completedAppointments,
      totalRevenue: Math.round(totalRevenue),
      activeDoctors,
      pendingApprovals,
      revenueMonthly: [
        { month: 'May', revenue: 45000, appointments: 68 },
        { month: 'Jun', revenue: 58000, appointments: 84 },
        { month: 'Jul', revenue: 72000, appointments: 110 },
        { month: 'Aug', revenue: 89000, appointments: 135 },
        { month: 'Sep', revenue: 114000, appointments: 168 },
      ],
      specialtyDistribution: db.specialties.map(s => ({
        name: s.name,
        doctors: s.doctorCount,
      })),
    },
  });
};

// --- USERS ---
exports.getUsers = (req, res) => {
  res.json({ success: true, count: db.users.length, data: db.users });
};

exports.createUser = (req, res) => {
  const newUser = {
    id: `u${Date.now()}`,
    name: req.body.name || 'New User',
    email: req.body.email || 'user@example.com',
    phone: req.body.phone || '+91 90000 00000',
    role: req.body.role || 'patient',
    status: 'active',
    createdAt: new Date().toISOString(),
    avatarUrl: req.body.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    currentCity: req.body.currentCity || 'Jaipur',
  };
  db.users.push(newUser);
  res.json({ success: true, message: 'User created successfully', data: newUser });
};

exports.updateUser = (req, res) => {
  const { id } = req.params;
  const idx = db.users.findIndex(u => u.id === id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'User not found' });

  db.users[idx] = { ...db.users[idx], ...req.body };
  res.json({ success: true, message: 'User updated successfully', data: db.users[idx] });
};

exports.deleteUser = (req, res) => {
  const { id } = req.params;
  db.users = db.users.filter(u => u.id !== id);
  res.json({ success: true, message: 'User deleted successfully' });
};

// --- DOCTORS ---
exports.getDoctors = (req, res) => {
  // By default, return verified doctors for public listing unless admin query param is passed
  if (req.query.all === 'true') {
    return res.json({ success: true, count: db.doctors.length, data: db.doctors });
  }
  const verifiedOnly = db.doctors.filter(d => d.isVerified);
  res.json({ success: true, count: verifiedOnly.length, data: verifiedOnly });
};

exports.createDoctor = (req, res) => {
  const newDoctor = {
    id: `d${Date.now()}`,
    name: req.body.name || 'Dr. New Specialist',
    specialty: req.body.specialty || 'General Physician',
    qualification: req.body.qualification || 'MBBS, MD',
    experienceYears: req.body.experienceYears || 5,
    experienceText: `${req.body.experienceYears || 5} yrs exp`,
    ratingPercentage: req.body.ratingPercentage || 95,
    patientStoriesCount: req.body.patientStoriesCount || 10,
    consultationFee: req.body.consultationFee || 500,
    imageUrl: req.body.imageUrl || 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
    isOnline: req.body.isOnline ?? true,
    allowsPhysical: req.body.allowsPhysical ?? true,
    allowsVideo: req.body.allowsVideo ?? true,
    isVerified: req.body.isVerified ?? true,
    verificationStatus: req.body.isVerified ? 'approved' : 'pending',
    clinicName: req.body.clinicName || 'MediCare Clinic',
    clinicAddress: req.body.clinicAddress || 'Jaipur',
    distanceKm: req.body.distanceKm || 1.5,
    languages: req.body.languages || ['English', 'Hindi'],
    aboutText: req.body.aboutText || 'Experienced medical professional.',
    services: req.body.services || ['General Consultation'],
  };
  db.doctors.push(newDoctor);
  res.json({ success: true, message: 'Doctor added successfully', data: newDoctor });
};

exports.updateDoctor = (req, res) => {
  const { id } = req.params;
  const idx = db.doctors.findIndex(d => d.id === id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'Doctor not found' });

  db.doctors[idx] = { ...db.doctors[idx], ...req.body };
  res.json({ success: true, message: 'Doctor updated successfully', data: db.doctors[idx] });
};

exports.deleteDoctor = (req, res) => {
  const { id } = req.params;
  db.doctors = db.doctors.filter(d => d.id !== id);
  res.json({ success: true, message: 'Doctor deleted successfully' });
};

// --- SPECIALTIES ---
exports.getSpecialties = (req, res) => {
  res.json({ success: true, count: db.specialties.length, data: db.specialties });
};

exports.createSpecialty = (req, res) => {
  const newSpec = {
    id: `s${Date.now()}`,
    name: req.body.name || 'New Specialty',
    icon: req.body.icon || 'medical_services_rounded',
    bgColorHex: req.body.bgColorHex || '#EBF5FF',
    iconColorHex: req.body.iconColorHex || '#1A56DB',
    doctorCount: req.body.doctorCount || 0,
    description: req.body.description || 'Specialty consultation care',
  };
  db.specialties.push(newSpec);
  res.json({ success: true, message: 'Specialty created successfully', data: newSpec });
};

exports.updateSpecialty = (req, res) => {
  const { id } = req.params;
  const idx = db.specialties.findIndex(s => s.id === id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'Specialty not found' });

  db.specialties[idx] = { ...db.specialties[idx], ...req.body };
  res.json({ success: true, message: 'Specialty updated successfully', data: db.specialties[idx] });
};

exports.deleteSpecialty = (req, res) => {
  const { id } = req.params;
  db.specialties = db.specialties.filter(s => s.id !== id);
  res.json({ success: true, message: 'Specialty deleted successfully' });
};

// --- HOSPITALS ---
exports.getHospitals = (req, res) => {
  res.json({ success: true, count: db.hospitals.length, data: db.hospitals });
};

exports.createHospital = (req, res) => {
  const newHosp = {
    id: `h${Date.now()}`,
    name: req.body.name || 'New Hospital',
    address: req.body.address || 'Jaipur',
    phone: req.body.phone || '+91 141 0000000',
    rating: req.body.rating || 4.5,
    reviewsCount: req.body.reviewsCount || 10,
    totalBeds: req.body.totalBeds || 100,
    icuBeds: req.body.icuBeds || 10,
    verified: req.body.verified ?? true,
    imageUrl: req.body.imageUrl || 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600',
    facilities: req.body.facilities || ['Emergency Care', 'Pharmacy'],
  };
  db.hospitals.push(newHosp);
  res.json({ success: true, message: 'Hospital added successfully', data: newHosp });
};

exports.updateHospital = (req, res) => {
  const { id } = req.params;
  const idx = db.hospitals.findIndex(h => h.id === id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'Hospital not found' });

  db.hospitals[idx] = { ...db.hospitals[idx], ...req.body };
  res.json({ success: true, message: 'Hospital updated successfully', data: db.hospitals[idx] });
};

exports.deleteHospital = (req, res) => {
  const { id } = req.params;
  db.hospitals = db.hospitals.filter(h => h.id !== id);
  res.json({ success: true, message: 'Hospital deleted successfully' });
};

// --- APPOINTMENTS ---
exports.getAppointments = (req, res) => {
  res.json({ success: true, count: db.appointments.length, data: db.appointments });
};

exports.createAppointment = (req, res) => {
  const newApt = {
    id: `apt-${Date.now()}`,
    userId: req.body.userId || 'u1',
    doctorId: req.body.doctorId || 'd1',
    doctor: db.doctors.find(d => d.id === req.body.doctorId) || db.doctors[0],
    type: req.body.type || 'video',
    date: req.body.date || new Date().toISOString(),
    timeSlot: req.body.timeSlot || '11:00 AM',
    status: 'upcoming',
    fee: req.body.fee || 499,
    platformFee: db.settings.platformFee,
    taxes: (req.body.fee || 499) * (db.settings.gstPercentage / 100),
    totalAmount: (req.body.fee || 499) + db.settings.platformFee + ((req.body.fee || 499) * (db.settings.gstPercentage / 100)),
    selectedLanguage: req.body.selectedLanguage || 'English',
    createdAt: new Date().toISOString(),
    agoraChannelName: `medicare_call_${Date.now()}`,
  };
  db.appointments.push(newApt);
  res.json({ success: true, message: 'Appointment booked successfully', data: newApt });
};

exports.updateAppointment = (req, res) => {
  const { id } = req.params;
  const idx = db.appointments.findIndex(a => a.id === id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'Appointment not found' });

  db.appointments[idx] = { ...db.appointments[idx], ...req.body };
  res.json({ success: true, message: 'Appointment updated successfully', data: db.appointments[idx] });
};

// --- CHATS ---
exports.getChats = (req, res) => {
  const { appointmentId } = req.query;
  let list = db.chats;
  if (appointmentId) {
    list = list.filter(c => c.appointmentId === appointmentId);
  }
  res.json({ success: true, count: list.length, data: list });
};

exports.sendChatMessage = (req, res) => {
  const newMsg = {
    id: `c${Date.now()}`,
    appointmentId: req.body.appointmentId || 'apt-101',
    senderId: req.body.senderId || 'u1',
    senderName: req.body.senderName || 'User',
    receiverId: req.body.receiverId || 'u2',
    text: req.body.text || '',
    timestamp: new Date().toISOString(),
  };
  db.chats.push(newMsg);
  res.json({ success: true, message: 'Message sent', data: newMsg });
};

// --- DYNAMIC SETTINGS & COUPONS ---
exports.getSettings = (req, res) => {
  res.json({ success: true, data: db.settings, coupons: db.coupons });
};

exports.updateSettings = (req, res) => {
  db.settings = { ...db.settings, ...req.body };
  res.json({ success: true, message: 'App settings updated successfully', data: db.settings });
};

exports.addCoupon = (req, res) => {
  const newCoupon = {
    code: (req.body.code || 'COUPON').toUpperCase(),
    discount: req.body.discount || 50,
    minAmount: req.body.minAmount || 100,
    isActive: req.body.isActive ?? true,
  };
  db.coupons.push(newCoupon);
  res.json({ success: true, message: 'Coupon added successfully', data: newCoupon });
};

exports.deleteCoupon = (req, res) => {
  const { code } = req.params;
  db.coupons = db.coupons.filter(c => c.code.toUpperCase() !== code.toUpperCase());
  res.json({ success: true, message: 'Coupon deleted successfully' });
};
