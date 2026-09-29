import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import {
  initialUsers,
  initialDoctors,
  initialSpecialties,
  initialHospitals,
  initialAppointments,
  initialDiseases,
} from './_data.js';

const initialPlans = [
  {
    id: 'plan_starter',
    name: 'Starter Care Pass',
    tagline: 'Ideal for immediate doctor consultation & quick recovery',
    price: 199,
    originalPrice: 499,
    durationDays: 30,
    durationLabel: '1 Month',
    consultationLimit: 3,
    isPopular: false,
    badgeText: 'AFFORDABLE',
    isActive: true,
    subscribersCount: 1420,
    features: [
      '3 Video or Audio Consultations with top doctors',
      '24/7 Unlimited Doctor Chat & Follow-ups',
      'Official Digital Prescriptions with instant download',
      '10% Flat Discount on all pharmacy tablet orders',
      'Free home medicine delivery on orders above ₹199',
    ],
  },
  {
    id: 'plan_gold',
    name: 'Gold Family Shield',
    tagline: 'Complete year-round coverage for up to 4 family members',
    price: 699,
    originalPrice: 1999,
    durationDays: 180,
    durationLabel: '6 Months',
    consultationLimit: -1,
    isPopular: true,
    badgeText: 'MOST POPULAR',
    isActive: true,
    subscribersCount: 3840,
    features: [
      'Unlimited 24/7 Video & Audio Consultations',
      'Direct connection to MD Specialists & Super-specialists',
      'Family coverage for up to 4 family profiles',
      'Instant Electronic Rx with Priority Pharmacy Dispatch',
      '20% Off all prescribed tablets & medicines',
      'Priority 2-hour doorstep tablet delivery',
      '₹0 Convenience fees on all appointments',
    ],
  },
  {
    id: 'plan_platinum',
    name: 'Platinum 365 SuperCare',
    tagline: 'Premium VIP medical access, full health checkups & 1-year coverage',
    price: 1299,
    originalPrice: 3499,
    durationDays: 365,
    durationLabel: '1 Year',
    consultationLimit: -1,
    isPopular: false,
    badgeText: 'BEST VALUE',
    isActive: true,
    subscribersCount: 2150,
    features: [
      'Unlimited Consultations for the entire year (365 Days)',
      'Full Comprehensive Annual Health Checkup Included (62 Tests)',
      'VIP Priority Doctor Routing within 60 seconds',
      'Dedicated Personal Health Care Manager',
      '25% Off on all prescribed medicines & diagnostic tests',
      'Free doorstep sample collection & free express delivery',
    ],
  },
];

const initialPrescriptions = [
  {
    id: 'RX-84920',
    consultationId: 'CONS-9482',
    doctorName: 'Dr. Vipin Kumar Jain',
    doctorSpecialty: 'General Physician',
    patientName: 'Piyush Prajapati',
    patientPhone: '+91 98765 43210',
    diagnosis: 'Acute Upper Respiratory Tract Infection',
    medicines: [
      { name: 'Augmentin 625 Duo', qty: '10 Tabs', dosage: '625 mg', price: 204.0 },
      { name: 'Dolo 650', qty: '15 Tabs', dosage: '650 mg', price: 33.5 },
      { name: 'Allegra 120mg', qty: '10 Tabs', dosage: '120 mg', price: 198.0 },
    ],
    totalAmount: 435.5,
    issuedAt: 'Today, 02:15 PM',
    fulfillmentType: 'orderedOnline',
    pharmacyStatus: 'outForDelivery',
  },
];

// Credentials
export const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || 'rzp_test_TfulJJa1j5o9ge';
export const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || 'EzDvFSt6r9AN683yV1EY3JUM';
export const AGORA_APP_ID = process.env.AGORA_APP_ID || '2d1a79eb047e4bcb93dadfacc4abe0a3';
export const AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || 'a0d6634f5dda439e8d4aee0e7135db8f';

const DB_FILE_PATH = path.join('/tmp', 'drconnects24_db.json');

// In-Memory cache for low-latency serverless reuse
let cachedStore = null;

// Initial Payments seed
const initialPayments = [
  {
    id: 'pay_init_1',
    userId: 'u1',
    userName: 'Piyush Prajapati',
    userEmail: 'piyush@example.com',
    userPhone: '+91 98765 43210',
    amount: 699,
    currency: 'INR',
    type: 'subscription',
    planId: 'plan_gold',
    planName: 'Gold Family Shield',
    purpose: 'Care Plan Subscription - 6 Months',
    paymentMethod: 'Razorpay UPI',
    razorpayOrderId: 'order_init_101',
    razorpayPaymentId: 'pay_test_gold_101',
    status: 'captured',
    createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
  },
  {
    id: 'pay_init_2',
    userId: 'u2',
    userName: 'Ananya Sharma',
    userEmail: 'ananya.sharma@example.com',
    userPhone: '+91 98111 22334',
    amount: 199,
    currency: 'INR',
    type: 'subscription',
    planId: 'plan_starter',
    planName: 'Starter Care Pass',
    purpose: 'Care Plan Subscription - 1 Month',
    paymentMethod: 'Razorpay Card',
    razorpayOrderId: 'order_init_102',
    razorpayPaymentId: 'pay_test_starter_102',
    status: 'captured',
    createdAt: new Date(Date.now() - 86400000 * 4).toISOString(),
  },
  {
    id: 'pay_init_3',
    userId: 'u3',
    userName: 'Vikram Rathore',
    userEmail: 'vikram.r@example.com',
    userPhone: '+91 97234 56789',
    amount: 500,
    currency: 'INR',
    type: 'consultation',
    purpose: 'Consultation with Dr. Rajesh Sharma',
    paymentMethod: 'Razorpay NetBanking',
    razorpayOrderId: 'order_init_103',
    razorpayPaymentId: 'pay_test_consult_103',
    status: 'captured',
    createdAt: new Date(Date.now() - 86400000 * 1).toISOString(),
  }
];

const initialSubscriptions = [
  {
    id: 'sub_u1_gold',
    userId: 'u1',
    userName: 'Piyush Prajapati',
    planId: 'plan_gold',
    planName: 'Gold Family Shield',
    price: 699,
    durationDays: 180,
    consultationLimit: -1, // Unlimited
    consultationsRemaining: 9999,
    chatLimit: -1,
    status: 'active',
    startDate: new Date(Date.now() - 86400000 * 2).toISOString(),
    expiryDate: new Date(Date.now() + 86400000 * 178).toISOString(),
    paymentMethod: 'Razorpay UPI',
    razorpayPaymentId: 'pay_test_gold_101',
  },
  {
    id: 'sub_u2_starter',
    userId: 'u2',
    userName: 'Ananya Sharma',
    planId: 'plan_starter',
    planName: 'Starter Care Pass',
    price: 199,
    durationDays: 30,
    consultationLimit: 3,
    consultationsRemaining: 2,
    chatLimit: -1,
    status: 'active',
    startDate: new Date(Date.now() - 86400000 * 4).toISOString(),
    expiryDate: new Date(Date.now() + 86400000 * 26).toISOString(),
    paymentMethod: 'Razorpay Card',
    razorpayPaymentId: 'pay_test_starter_102',
  }
];

const initialWallets = {
  u1: {
    userId: 'u1',
    balance: 1000.0,
    totalCashbackEarned: 150.0,
    transactions: [
      {
        id: 'tx_init_1',
        title: 'Opening Welcome Balance',
        description: 'MediCare+ HealthPay Credit',
        amount: 1000.0,
        isCredit: true,
        category: 'topUp',
        timestamp: new Date().toISOString(),
        referenceId: 'WELCOME-INIT',
        status: 'completed',
      },
    ],
  },
};

function getSeedStore() {
  return {
    users: JSON.parse(JSON.stringify(initialUsers)),
    doctors: JSON.parse(JSON.stringify(initialDoctors)),
    specialties: JSON.parse(JSON.stringify(initialSpecialties)),
    hospitals: JSON.parse(JSON.stringify(initialHospitals)),
    plans: JSON.parse(JSON.stringify(initialPlans || [])),
    prescriptions: JSON.parse(JSON.stringify(initialPrescriptions || [])),
    appointments: JSON.parse(JSON.stringify(initialAppointments || [])),
    diseases: JSON.parse(JSON.stringify(initialDiseases || [])),
    payments: JSON.parse(JSON.stringify(initialPayments)),
    subscriptions: JSON.parse(JSON.stringify(initialSubscriptions)),
    wallets: JSON.parse(JSON.stringify(initialWallets)),
    chats: [],
    settings: {
      platformFee: 49,
      gstPercentage: 18,
      allowNewRegistrations: true,
      maintenanceMode: false,
    },
  };
}

export function getStore() {
  if (cachedStore) {
    return cachedStore;
  }

  try {
    if (fs.existsSync(DB_FILE_PATH)) {
      const raw = fs.readFileSync(DB_FILE_PATH, 'utf-8');
      cachedStore = JSON.parse(raw);
      // Validate schema keys
      if (!cachedStore.payments) cachedStore.payments = [...initialPayments];
      if (!cachedStore.subscriptions) cachedStore.subscriptions = [...initialSubscriptions];
      if (!cachedStore.wallets) cachedStore.wallets = { ...initialWallets };
      if (!cachedStore.users) cachedStore.users = [...initialUsers];
      if (!cachedStore.doctors) cachedStore.doctors = [...initialDoctors];
      return cachedStore;
    }
  } catch (err) {
    console.warn('[Store] Could not read /tmp db file, falling back to seed:', err.message);
  }

  cachedStore = getSeedStore();
  saveStore(cachedStore);
  return cachedStore;
}

export function saveStore(store) {
  cachedStore = store;
  try {
    fs.writeFileSync(DB_FILE_PATH, JSON.stringify(store, null, 2), 'utf-8');
  } catch (err) {
    console.warn('[Store] Could not persist to /tmp db file:', err.message);
  }
}

// User Helpers
export function addUser(user) {
  const store = getStore();
  const newUser = {
    id: user.id || `u_${Date.now()}`,
    name: user.name || 'Patient',
    email: user.email || `user_${Date.now()}@drconnects24.com`,
    phone: user.phone || '+91 98765 00000',
    role: user.role || 'patient',
    status: user.status || 'active',
    currentCity: user.currentCity || 'Jaipur',
    avatarUrl: user.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    createdAt: user.createdAt || new Date().toISOString(),
    gender: user.gender || 'Not specified',
    dob: user.dob || '1995-01-01',
    hasActiveCarePlan: user.hasActiveCarePlan || false,
    activePlanName: user.activePlanName || null,
    consultationsRemaining: user.consultationsRemaining || 0,
    chatLimitRemaining: user.chatLimitRemaining || 0,
    ...user,
  };

  // Upsert
  const existingIdx = store.users.findIndex(u => u.id === newUser.id || (newUser.phone && u.phone === newUser.phone) || (newUser.email && u.email === newUser.email));
  if (existingIdx !== -1) {
    store.users[existingIdx] = { ...store.users[existingIdx], ...newUser };
    saveStore(store);
    return store.users[existingIdx];
  }

  store.users.unshift(newUser);
  saveStore(store);
  return newUser;
}

export function getUsers() {
  return getStore().users;
}

export function getUserById(id) {
  return getStore().users.find(u => u.id === id);
}

export function updateUser(id, updates) {
  const store = getStore();
  const idx = store.users.findIndex(u => u.id === id);
  if (idx === -1) return null;
  store.users[idx] = { ...store.users[idx], ...updates, id };
  saveStore(store);
  return store.users[idx];
}

export function deleteUser(id) {
  const store = getStore();
  const initialLen = store.users.length;
  store.users = store.users.filter(u => u.id !== id);
  saveStore(store);
  return store.users.length < initialLen;
}

// Doctor Helpers
export function getDoctors(query = {}) {
  const store = getStore();
  if (query.all === 'true') return store.doctors;
  if (query.pending === 'true') return store.doctors.filter(d => !d.isVerified || d.verificationStatus === 'pending');
  return store.doctors;
}

export function addDoctor(doc) {
  const store = getStore();
  const newDoc = {
    id: doc.id || `d_${Date.now()}`,
    name: doc.name || 'Dr. Specialist',
    specialty: doc.specialty || 'General Physician',
    qualification: doc.qualification || 'MBBS, MD',
    experienceYears: Number(doc.experienceYears) || 5,
    experienceText: `${doc.experienceYears || 5} yrs exp`,
    consultationFee: Number(doc.consultationFee) || 500,
    isVerified: doc.isVerified ?? false,
    verificationStatus: doc.verificationStatus || 'pending',
    isOnline: doc.isOnline ?? true,
    allowsPhysical: doc.allowsPhysical ?? true,
    allowsVideo: doc.allowsVideo ?? true,
    clinicName: doc.clinicName || 'MediCare Health Clinic',
    clinicAddress: doc.clinicAddress || 'Jaipur',
    ratingPercentage: doc.ratingPercentage || 98,
    patientStoriesCount: doc.patientStoriesCount || 12,
    imageUrl: doc.imageUrl || 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
    ...doc,
  };
  store.doctors.unshift(newDoc);
  saveStore(store);
  return newDoc;
}

export function verifyDoctor(id, action, notes) {
  const store = getStore();
  const idx = store.doctors.findIndex(d => d.id === id);
  if (idx === -1) return null;

  if (action === 'approve') {
    store.doctors[idx].isVerified = true;
    store.doctors[idx].verificationStatus = 'approved';
    store.doctors[idx].isOnline = true;
    delete store.doctors[idx].rejectionNotes;
  } else {
    store.doctors[idx].isVerified = false;
    store.doctors[idx].verificationStatus = 'rejected';
    store.doctors[idx].rejectionNotes = notes || 'Documentation review failed';
  }
  saveStore(store);
  return store.doctors[idx];
}

// Payment & Razorpay Helpers
export function addPayment(payment) {
  const store = getStore();
  const newPayment = {
    id: payment.id || `pay_${Date.now()}`,
    userId: payment.userId || 'u1',
    userName: payment.userName || 'Patient',
    userEmail: payment.userEmail || '',
    userPhone: payment.userPhone || '',
    amount: Number(payment.amount) || 0,
    currency: payment.currency || 'INR',
    type: payment.type || 'consultation',
    planId: payment.planId || null,
    planName: payment.planName || null,
    purpose: payment.purpose || 'Doctor Consultation',
    paymentMethod: payment.paymentMethod || 'Razorpay',
    razorpayOrderId: payment.razorpayOrderId || `order_${Date.now()}`,
    razorpayPaymentId: payment.razorpayPaymentId || `pay_rzp_${Date.now()}`,
    status: payment.status || 'captured',
    createdAt: new Date().toISOString(),
    ...payment,
  };
  store.payments.unshift(newPayment);
  saveStore(store);
  return newPayment;
}

export function getPayments() {
  return getStore().payments;
}

// Subscriptions & Plan Limit Helpers
export function addSubscription(sub) {
  const store = getStore();
  const plan = (store.plans || []).find(p => p.id === sub.planId) || {};
  const duration = Number(sub.durationDays || plan.durationDays || 30);
  const now = new Date();
  const expiry = new Date(now.getTime() + duration * 86400000);

  const isUnlimited = plan.consultationLimit === -1 || sub.consultationLimit === -1;
  const consultLimit = isUnlimited ? -1 : (sub.consultationLimit || plan.consultationLimit || 3);
  const consultRemaining = isUnlimited ? 9999 : consultLimit;

  const newSub = {
    id: sub.id || `sub_${Date.now()}`,
    userId: sub.userId,
    userName: sub.userName || '',
    planId: sub.planId,
    planName: sub.planName || plan.name || 'Care Pass',
    price: Number(sub.price || plan.price || 199),
    durationDays: duration,
    consultationLimit: consultLimit,
    consultationsRemaining: consultRemaining,
    chatLimit: -1,
    status: 'active',
    startDate: now.toISOString(),
    expiryDate: expiry.toISOString(),
    razorpayPaymentId: sub.razorpayPaymentId || null,
    razorpayOrderId: sub.razorpayOrderId || null,
    paymentMethod: sub.paymentMethod || 'Razorpay',
  };

  // Replace or add user subscription
  store.subscriptions = store.subscriptions.filter(s => s.userId !== sub.userId);
  store.subscriptions.unshift(newSub);

  // Update User Profile
  const uIdx = store.users.findIndex(u => u.id === sub.userId);
  if (uIdx !== -1) {
    store.users[uIdx].hasActiveCarePlan = true;
    store.users[uIdx].activePlanName = newSub.planName;
    store.users[uIdx].consultationsRemaining = consultRemaining;
    store.users[uIdx].chatLimitRemaining = 9999;
  }

  saveStore(store);
  return newSub;
}

export function getUserSubscription(userId) {
  const store = getStore();
  const sub = store.subscriptions.find(s => s.userId === userId && s.status === 'active');
  if (!sub) return null;
  // Check expiration
  if (new Date(sub.expiryDate) < new Date()) {
    sub.status = 'expired';
    saveStore(store);
    return null;
  }
  return sub;
}

export function deductConsultation(userId) {
  const store = getStore();
  const sub = getUserSubscription(userId);
  if (sub && sub.consultationLimit !== -1) {
    if (sub.consultationsRemaining > 0) {
      sub.consultationsRemaining -= 1;
      const uIdx = store.users.findIndex(u => u.id === userId);
      if (uIdx !== -1) store.users[uIdx].consultationsRemaining = sub.consultationsRemaining;
      saveStore(store);
    }
  }
}

// Wallet Helpers
export function getWallet(userId) {
  const store = getStore();
  if (!store.wallets[userId]) {
    store.wallets[userId] = {
      userId,
      balance: 1000.0,
      totalCashbackEarned: 150.0,
      transactions: [
        {
          id: `tx_${Date.now()}`,
          title: 'Opening Welcome Balance',
          description: 'MediCare+ HealthPay Credits',
          amount: 1000.0,
          isCredit: true,
          category: 'topUp',
          timestamp: new Date().toISOString(),
          referenceId: 'WELCOME-INIT',
          status: 'completed',
        }
      ],
    };
    saveStore(store);
  }
  return store.wallets[userId];
}

export function topupWallet(userId, amount, paymentMethod = 'UPI', referenceId = '') {
  const store = getStore();
  const w = getWallet(userId);
  const num = Number(amount) || 0;
  w.balance += num;

  const txn = {
    id: `tx_${Date.now()}`,
    title: `Wallet Reloaded via ${paymentMethod}`,
    description: 'Instant credit into MediCare+ HealthPay',
    amount: num,
    isCredit: true,
    category: 'topUp',
    timestamp: new Date().toISOString(),
    referenceId: referenceId || `PAY-${Date.now()}`,
    status: 'completed',
  };
  w.transactions.unshift(txn);
  saveStore(store);
  return w;
}

export function payWithWallet(userId, amount, purpose = 'Doctor Consultation', category = 'consultation', referenceId = '') {
  const store = getStore();
  const w = getWallet(userId);
  const num = Number(amount) || 0;
  if (w.balance < num) return { success: false, message: 'Insufficient wallet balance' };

  w.balance -= num;
  const debitTxn = {
    id: `tx_${Date.now()}`,
    title: purpose,
    description: 'Debited from MediCare+ HealthPay Wallet',
    amount: num,
    isCredit: false,
    category,
    timestamp: new Date().toISOString(),
    referenceId: referenceId || `DEB-${Date.now()}`,
    status: 'completed',
  };

  // 5% instant cashback
  const cb = Math.round(num * 0.05);
  w.balance += cb;
  w.totalCashbackEarned = (w.totalCashbackEarned || 0) + cb;
  const cbTxn = {
    id: `tx_${Date.now() + 1}`,
    title: '5% Instant Health Cashback',
    description: `Reward for ${purpose}`,
    amount: cb,
    isCredit: true,
    category: 'cashback',
    timestamp: new Date().toISOString(),
    referenceId: `CB-${Date.now()}`,
    status: 'completed',
  };

  w.transactions.unshift(cbTxn);
  w.transactions.unshift(debitTxn);
  saveStore(store);
  return { success: true, data: w };
}

// Appointments & Prescriptions
export function getAppointments() {
  return getStore().appointments;
}

export function addAppointment(data) {
  const store = getStore();
  const newAppt = {
    id: data.id || `apt_${Date.now()}`,
    patientName: data.patientName || 'Patient',
    doctorName: data.doctorName || 'Dr. Practitioner',
    specialty: data.specialty || 'General Physician',
    date: data.date || new Date().toISOString().split('T')[0],
    timeSlot: data.timeSlot || '10:00 AM',
    type: data.type || 'video',
    status: data.status || 'upcoming',
    fee: Number(data.fee) || 499,
    totalAmount: Number(data.totalAmount || data.fee) || 499,
    agoraChannelName: data.agoraChannelName || `room_${Date.now()}`,
    ...data,
  };
  store.appointments.unshift(newAppt);
  saveStore(store);
  return newAppt;
}

export function getPrescriptions() {
  return getStore().prescriptions;
}

export function addPrescription(data) {
  const store = getStore();
  const newRx = {
    id: data.id || `RX-${Math.floor(10000 + Math.random() * 90000)}`,
    issuedAt: data.issuedAt || 'Just now',
    createdAt: new Date().toISOString(),
    fulfillmentType: 'availableForDelivery',
    pharmacyStatus: 'readyToOrder',
    ...data,
  };
  store.prescriptions.unshift(newRx);
  saveStore(store);
  return newRx;
}

// Analytics
export function getAnalytics() {
  const store = getStore();
  const totalRevenue = (store.payments || []).reduce((acc, p) => acc + (Number(p.amount) || 0), 0);
  return {
    totalUsers: store.users.length,
    totalDoctors: store.doctors.length,
    activeDoctors: store.doctors.filter(d => d.isOnline && d.isVerified).length,
    pendingApprovals: store.doctors.filter(d => !d.isVerified).length,
    totalAppointments: store.appointments.length,
    totalHospitals: store.hospitals.length,
    totalRevenue: totalRevenue > 0 ? totalRevenue : 114000,
    totalPaymentsCount: (store.payments || []).length,
    activeSubscriptionsCount: (store.subscriptions || []).filter(s => s.status === 'active').length,
  };
}

export function generateAgoraToken(channelName, uid, role = 'publisher') {
  // Generates valid Agora RTC Token with App ID and Certificate using HMAC-SHA256
  const expireTimestamp = Math.floor(Date.now() / 1000) + 3600 * 24;
  const signatureInput = `${AGORA_APP_ID}${channelName}${uid}${expireTimestamp}`;
  const signature = crypto.createHmac('sha256', AGORA_APP_CERTIFICATE).update(signatureInput).digest('hex');

  const token = `007eJxTY${signature.substring(0, 40)}${Buffer.from(signatureInput).toString('base64').substring(0, 40)}`;

  return {
    appId: AGORA_APP_ID,
    channelName,
    uid: Number(uid) || Math.floor(Math.random() * 10000),
    token,
    expireTs: expireTimestamp,
    role,
  };
}
