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

// --- AUTHENTICATION (PATIENT, DOCTOR, ADMIN) ---
exports.authLogin = (req, res) => {
  const { emailOrPhone, password, role } = req.body;
  const identifier = (emailOrPhone || '').trim().toLowerCase().replace(/[\s\-\(\)]/g, '');

  if (role === 'doctor') {
    // Find doctor by phone, email, or id
    const doc = db.doctors.find(d => {
      const p = (d.phone || '').replace(/[\s\-\(\)]/g, '');
      const altP = (d.altPhone || '').replace(/[\s\-\(\)]/g, '');
      const e = (d.email || '').toLowerCase();
      return p.includes(identifier) || altP.includes(identifier) || e === identifier || d.id === identifier;
    }) || db.doctors[0]; // Fallback to first doctor if demo match

    // Check verification status
    if (doc.verificationStatus === 'pending' || !doc.isVerified) {
      return res.status(403).json({
        success: false,
        status: 'pending',
        message: 'Your doctor profile is under verification. Credential review in progress.',
        data: { doctor: doc },
      });
    }

    if (doc.verificationStatus === 'rejected') {
      return res.status(403).json({
        success: false,
        status: 'rejected',
        message: `Doctor verification rejected: ${doc.rejectionNotes || 'Documentation verification failed.'}`,
        data: { doctor: doc },
      });
    }

    const matchedUser = db.users.find(u => u.doctorId === doc.id) || {
      id: `u_${doc.id}`,
      name: doc.name,
      email: doc.email || `${doc.id}@medicare.com`,
      phone: doc.phone || '+91 98290 11223',
      role: 'doctor',
      doctorId: doc.id,
      status: 'active',
      avatarUrl: doc.imageUrl,
    };

    return res.json({
      success: true,
      message: 'Doctor login successful',
      token: `medicare_jwt_${doc.id}`,
      data: { user: matchedUser, doctor: doc },
    });
  }

  // Patient Login
  const user = db.users.find(u => {
    const p = (u.phone || '').replace(/[\s\-\(\)]/g, '');
    const e = (u.email || '').toLowerCase();
    return p.includes(identifier) || e === identifier;
  }) || db.users[0]; // Fallback to default patient for smooth dev/demo

  return res.json({
    success: true,
    message: 'Patient login successful',
    token: `medicare_jwt_${user.id}`,
    data: { user },
  });
};

exports.registerPatient = (req, res) => {
  const { name, email, phone, gender, dob, currentCity, password } = req.body;
  const userId = `u${Date.now()}`;

  const newUser = {
    id: userId,
    name: name || 'New Patient',
    email: email || `user_${Date.now()}@example.com`,
    phone: phone || '+91 90000 00000',
    gender: gender || 'Male',
    dob: dob || '1995-08-15',
    role: 'patient',
    status: 'active',
    createdAt: new Date().toISOString(),
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    currentCity: currentCity || 'Jaipur',
  };

  db.users.push(newUser);

  // Initialize wallet for new user with ₹200 welcome credits
  db.wallets[userId] = {
    userId: userId,
    balance: 200.0,
    totalCashbackEarned: 20.0,
    transactions: [
      {
        id: `tx_${Date.now()}`,
        title: 'Welcome Bonus Credited',
        description: 'Free ₹200 HealthPay credits for joining MediCare+',
        amount: 200.0,
        isCredit: true,
        category: 'cashback',
        timestamp: new Date().toISOString(),
        referenceId: 'WELCOME-BONUS',
        status: 'completed',
      },
    ],
  };

  res.json({
    success: true,
    message: 'Patient registered successfully! Welcome bonus credited to HealthPay.',
    data: { user: newUser, wallet: db.wallets[userId] },
  });
};

exports.getDoctorStatus = (req, res) => {
  const { id } = req.params;
  const doc = db.doctors.find(d => d.id === id || d.medicalLicenseNo === id);
  if (!doc) {
    return res.status(404).json({ success: false, message: 'Doctor not found' });
  }
  res.json({
    success: true,
    data: {
      doctorId: doc.id,
      name: doc.name,
      status: doc.verificationStatus || (doc.isVerified ? 'approved' : 'pending'),
      isVerified: !!doc.isVerified,
      rejectionNotes: doc.rejectionNotes,
      doctor: doc,
    },
  });
};

exports.getDoctorById = (req, res) => {
  const { id } = req.params;
  const doc = db.doctors.find(d => d.id === id);
  if (!doc) return res.status(404).json({ success: false, message: 'Doctor not found' });
  res.json({ success: true, data: doc });
};

// --- USER PROFILE & DELETE ACCOUNT ---
exports.getUserProfile = (req, res) => {
  const { id } = req.params;
  const user = db.users.find(u => u.id === id);
  if (!user) return res.status(404).json({ success: false, message: 'User not found' });

  let doctor = null;
  if (user.doctorId) {
    doctor = db.doctors.find(d => d.id === user.doctorId);
  }

  const wallet = db.wallets[id] || { userId: id, balance: 0, transactions: [] };

  res.json({
    success: true,
    data: { user, doctor, wallet },
  });
};

// Override deleteUser to perform complete cleanup
exports.deleteUser = (req, res) => {
  const { id } = req.params;
  const user = db.users.find(u => u.id === id);

  if (user && user.doctorId) {
    db.doctors = db.doctors.filter(d => d.id !== user.doctorId);
  }

  db.users = db.users.filter(u => u.id !== id);
  delete db.wallets[id];
  db.appointments = db.appointments.filter(a => a.userId !== id);
  db.subscriptions = db.subscriptions.filter(s => s.userId !== id);

  res.json({ success: true, message: 'User account and all related records deleted permanently' });
};

// --- CARE PLANS & SUBSCRIPTIONS ---
exports.getPlans = (req, res) => {
  res.json({ success: true, count: db.plans.length, data: db.plans });
};

exports.createPlan = (req, res) => {
  const newPlan = {
    id: `plan_${Date.now()}`,
    name: req.body.name || 'New Care Plan',
    tagline: req.body.tagline || 'Healthcare benefits',
    price: Number(req.body.price) || 299,
    originalPrice: Number(req.body.originalPrice) || 599,
    durationDays: Number(req.body.durationDays) || 30,
    durationLabel: req.body.durationLabel || '1 Month',
    consultationLimit: Number(req.body.consultationLimit) || 3,
    isPopular: !!req.body.isPopular,
    badgeText: req.body.badgeText || '',
    isActive: true,
    features: req.body.features || ['Unlimited Chat', 'Prescriptions Included'],
  };
  db.plans.push(newPlan);
  res.json({ success: true, message: 'Care Plan created successfully', data: newPlan });
};

exports.updatePlan = (req, res) => {
  const { id } = req.params;
  const idx = db.plans.findIndex(p => p.id === id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'Plan not found' });
  db.plans[idx] = { ...db.plans[idx], ...req.body };
  res.json({ success: true, message: 'Care Plan updated successfully', data: db.plans[idx] });
};

exports.deletePlan = (req, res) => {
  const { id } = req.params;
  db.plans = db.plans.filter(p => p.id !== id);
  res.json({ success: true, message: 'Care Plan deleted successfully' });
};

exports.getUserSubscription = (req, res) => {
  const { userId } = req.params;
  const sub = db.subscriptions.find(s => s.userId === userId && s.status === 'active');
  res.json({ success: true, data: sub || null });
};

exports.purchaseSubscription = (req, res) => {
  const { userId, planId, paymentMethod, amount } = req.body;
  const plan = db.plans.find(p => p.id === planId) || db.plans[0];

  const now = new Date();
  const expiresAt = new Date(now.getTime() + (plan.durationDays * 24 * 60 * 60 * 1000));

  const newSub = {
    id: `sub_${Date.now()}`,
    userId: userId || 'u1',
    planId: plan.id,
    planName: plan.name,
    plan: plan,
    amount: amount || plan.price,
    paymentMethod: paymentMethod || 'wallet',
    status: 'active',
    remainingConsultations: plan.consultationLimit === -1 ? 9999 : plan.consultationLimit,
    subscribedAt: now.toISOString(),
    expiresAt: expiresAt.toISOString(),
  };

  // Deactivate any existing active subscription for this user
  db.subscriptions.forEach(s => {
    if (s.userId === (userId || 'u1')) s.status = 'expired';
  });

  db.subscriptions.push(newSub);

  // If paid by wallet, debit user wallet and give 5% cashback
  if (paymentMethod === 'wallet' && db.wallets[userId || 'u1']) {
    const w = db.wallets[userId || 'u1'];
    const cost = Number(amount || plan.price);
    w.balance = Math.max(0, w.balance - cost);

    w.transactions.unshift({
      id: `tx_${Date.now()}`,
      title: `${plan.name} Purchased`,
      description: 'Care Plan Subscription via HealthPay Wallet',
      amount: cost,
      isCredit: false,
      category: 'subscription',
      timestamp: now.toISOString(),
      referenceId: newSub.id,
      status: 'completed',
    });

    // 5% cashback
    const cb = Math.round(cost * 0.05);
    w.balance += cb;
    w.totalCashbackEarned = (w.totalCashbackEarned || 0) + cb;
    w.transactions.unshift({
      id: `tx_${Date.now() + 1}`,
      title: '5% Care Plan Cashback',
      description: 'Instant HealthCash rewarded',
      amount: cb,
      isCredit: true,
      category: 'cashback',
      timestamp: new Date().toISOString(),
      referenceId: `CB-${newSub.id}`,
      status: 'completed',
    });
  }

  // Update user hasActiveCarePlan
  const uIdx = db.users.findIndex(u => u.id === (userId || 'u1'));
  if (uIdx !== -1) {
    db.users[uIdx].hasActiveCarePlan = true;
  }

  res.json({
    success: true,
    message: `${plan.name} activated successfully!`,
    data: newSub,
  });
};

exports.cancelSubscription = (req, res) => {
  const { userId, subscriptionId } = req.body;
  const sub = db.subscriptions.find(s => s.id === subscriptionId || s.userId === userId);
  if (sub) {
    sub.status = 'cancelled';
  }
  const uIdx = db.users.findIndex(u => u.id === userId);
  if (uIdx !== -1) {
    db.users[uIdx].hasActiveCarePlan = false;
  }
  res.json({ success: true, message: 'Subscription cancelled successfully' });
};

// --- WALLET & HEALTHPAY ---
exports.getWallet = (req, res) => {
  const { userId } = req.params;
  if (!db.wallets[userId]) {
    db.wallets[userId] = {
      userId,
      balance: 1000.0,
      totalCashbackEarned: 150.0,
      transactions: [
        {
          id: `tx_${Date.now()}`,
          title: 'Opening Wallet Credits',
          description: 'MediCare+ Welcome Balance',
          amount: 1000.0,
          isCredit: true,
          category: 'topUp',
          timestamp: new Date().toISOString(),
          referenceId: 'INIT-TOPUP',
          status: 'completed',
        },
      ],
    };
  }
  res.json({ success: true, data: db.wallets[userId] });
};

exports.topupWallet = (req, res) => {
  const { userId, amount, paymentMethod, referenceId } = req.body;
  const numAmount = Number(amount);
  if (isNaN(numAmount) || numAmount <= 0) {
    return res.status(400).json({ success: false, message: 'Invalid top-up amount' });
  }

  const uId = userId || 'u1';
  if (!db.wallets[uId]) {
    db.wallets[uId] = { userId: uId, balance: 0.0, totalCashbackEarned: 0.0, transactions: [] };
  }

  const w = db.wallets[uId];
  w.balance += numAmount;

  const newTxn = {
    id: `tx_${Date.now()}`,
    title: `Wallet Loaded via ${paymentMethod || 'UPI'}`,
    description: 'Direct top-up into MediCare HealthPay',
    amount: numAmount,
    isCredit: true,
    category: 'topUp',
    timestamp: new Date().toISOString(),
    referenceId: referenceId || `PAY-${Date.now()}`,
    status: 'completed',
  };

  w.transactions.unshift(newTxn);

  res.json({
    success: true,
    message: `₹${numAmount} added to HealthPay wallet successfully!`,
    data: w,
  });
};

exports.payWithWallet = (req, res) => {
  const { userId, amount, purpose, category, referenceId } = req.body;
  const numAmount = Number(amount);
  const uId = userId || 'u1';

  if (!db.wallets[uId]) {
    db.wallets[uId] = { userId: uId, balance: 500.0, totalCashbackEarned: 0.0, transactions: [] };
  }

  const w = db.wallets[uId];
  if (w.balance < numAmount) {
    return res.status(400).json({ success: false, message: 'Insufficient HealthPay wallet balance' });
  }

  w.balance -= numAmount;

  const debitTxn = {
    id: `tx_${Date.now()}`,
    title: purpose || 'HealthPay Payment',
    description: 'Paid via MediCare+ HealthPay Wallet',
    amount: numAmount,
    isCredit: false,
    category: category || 'consultation',
    timestamp: new Date().toISOString(),
    referenceId: referenceId || `REF-${Date.now()}`,
    status: 'completed',
  };

  // 5% cashback
  const cb = Math.round(numAmount * 0.05);
  w.balance += cb;
  w.totalCashbackEarned = (w.totalCashbackEarned || 0) + cb;

  const cashbackTxn = {
    id: `tx_${Date.now() + 1}`,
    title: '5% Instant Health Cashback',
    description: `Rewarded for ${purpose || 'Payment'}`,
    amount: cb,
    isCredit: true,
    category: 'cashback',
    timestamp: new Date().toISOString(),
    referenceId: `CB-${referenceId || Date.now()}`,
    status: 'completed',
  };

  w.transactions.unshift(cashbackTxn);
  w.transactions.unshift(debitTxn);

  res.json({
    success: true,
    message: 'Payment completed successfully via HealthPay',
    data: w,
  });
};

// --- PAYMENTS & ORDERS ---
exports.createPaymentOrder = (req, res) => {
  const { userId, amount, purpose } = req.body;
  const numAmount = Number(amount) || 499;
  const orderId = `order_${Date.now()}`;

  res.json({
    success: true,
    data: {
      orderId,
      amount: numAmount,
      platformFee: db.settings.platformFee,
      gst: Math.round(numAmount * (db.settings.gstPercentage / 100)),
      totalAmount: numAmount + db.settings.platformFee + Math.round(numAmount * (db.settings.gstPercentage / 100)),
      currency: 'INR',
      purpose: purpose || 'Doctor Consultation',
      userId: userId || 'u1',
    },
  });
};

exports.verifyPaymentSuccess = (req, res) => {
  const { orderId, userId, amount, paymentId, paymentMethod, purpose } = req.body;
  const uId = userId || 'u1';

  if (db.wallets[uId]) {
    db.wallets[uId].transactions.unshift({
      id: `tx_${Date.now()}`,
      title: purpose || 'Payment Confirmed',
      description: `Payment via ${paymentMethod || 'Online'} (${paymentId || orderId})`,
      amount: Number(amount) || 0,
      isCredit: false,
      category: 'consultation',
      timestamp: new Date().toISOString(),
      referenceId: paymentId || orderId,
      status: 'completed',
    });
  }

  res.json({
    success: true,
    message: 'Payment verified and transaction recorded successfully!',
    data: {
      orderId,
      paymentId: paymentId || `pay_${Date.now()}`,
      status: 'captured',
      timestamp: new Date().toISOString(),
    },
  });
};

// --- DISEASES & SYMPTOMS ---
exports.getDiseases = (req, res) => {
  res.json({ success: true, count: db.diseases.length, data: db.diseases });
};

exports.createDisease = (req, res) => {
  const newDis = {
    id: `dis_${Date.now()}`,
    name: req.body.name || 'New Health Condition',
    specialty: req.body.specialty || 'General Physician',
    symptomCount: req.body.symptomCount || '5 Symptoms',
  };
  db.diseases.push(newDis);
  res.json({ success: true, message: 'Disease/Symptom condition added', data: newDis });
};

// --- PRESCRIPTIONS ---
exports.getPrescriptions = (req, res) => {
  const { userId, doctorId, consultationId } = req.query;
  let list = db.prescriptions;

  if (userId) list = list.filter(p => p.patientId === userId || !p.patientId);
  if (doctorId) list = list.filter(p => p.doctorId === doctorId);
  if (consultationId) list = list.filter(p => p.consultationId === consultationId);

  res.json({ success: true, count: list.length, data: list });
};

exports.getPrescriptionById = (req, res) => {
  const { id } = req.params;
  const rx = db.prescriptions.find(p => p.id === id);
  if (!rx) return res.status(404).json({ success: false, message: 'Prescription not found' });
  res.json({ success: true, data: rx });
};

exports.createPrescription = (req, res) => {
  const newRx = {
    id: `rx_${Date.now()}`,
    consultationId: req.body.consultationId || `apt-${Date.now()}`,
    doctorId: req.body.doctorId || 'd1',
    doctorName: req.body.doctorName || 'Dr. Specialist',
    doctorSpecialty: req.body.doctorSpecialty || 'General Physician',
    clinicName: req.body.clinicName || 'MediCare Clinic',
    doctorRegistrationNumber: req.body.doctorRegistrationNumber || 'RMC/2012/88741',
    patientId: req.body.patientId || 'u1',
    patientName: req.body.patientName || 'Piyush Prajapati',
    patientAgeGender: req.body.patientAgeGender || '30 / Male',
    diagnosis: req.body.diagnosis || 'Clinical Diagnosis',
    symptoms: req.body.symptoms || [],
    vitals: req.body.vitals || { BP: '120/80', Temp: '98.6 F' },
    clinicalNotes: req.body.clinicalNotes || '',
    adviceNotes: req.body.adviceNotes || '',
    medicines: req.body.medicines || [],
    issuedAt: new Date().toISOString(),
    status: 'issued',
    pharmacyStatus: 'none',
    fulfillmentType: 'none',
    digitalSignatureToken: `NMC-SIG-${Date.now().toString().substring(7)}`,
  };

  db.prescriptions.unshift(newRx);

  // Update appointment if matching
  const apt = db.appointments.find(a => a.id === newRx.consultationId);
  if (apt) {
    apt.status = 'completed';
    apt.prescription = newRx.clinicalNotes || 'Prescription issued';
    apt.prescriptionId = newRx.id;
  }

  res.json({
    success: true,
    message: 'Digital prescription issued and digitally signed by doctor',
    data: newRx,
  });
};

exports.orderPharmacyPrescription = (req, res) => {
  const { id } = req.params;
  const { address, paymentMethod } = req.body;

  const rx = db.prescriptions.find(p => p.id === id);
  if (!rx) return res.status(404).json({ success: false, message: 'Prescription not found' });

  rx.pharmacyStatus = 'placed';
  rx.fulfillmentType = 'orderedOnline';
  rx.deliveryAddress = address || 'Home Address, Jaipur';
  rx.orderPlacedAt = new Date().toISOString();

  res.json({
    success: true,
    message: 'Medicine order placed successfully! Doorstep delivery within 2 hours.',
    data: rx,
  });
};
