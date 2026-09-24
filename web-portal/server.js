import http from 'http';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { initialUsers, initialDoctors, initialSpecialties, initialHospitals, initialAppointments } from './src/data/mockData.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PORT = process.env.PORT || 3000;
const DIST_DIR = path.join(__dirname, 'dist');

// In-Memory Database for Live API
const db = {
  users: [...initialUsers],
  doctors: [...initialDoctors],
  specialties: [...initialSpecialties],
  hospitals: [...initialHospitals],
  appointments: [...initialAppointments],
  plans: [
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
        'Free home medicine delivery on orders above ₹199'
      ]
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
        '₹0 Convenience fees on all appointments'
      ]
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
        'Free doorstep sample collection & free express delivery'
      ]
    }
  ],
  prescriptions: [
    {
      id: 'RX-84920',
      consultationId: 'CONS-9482',
      doctorName: 'Dr. Vipin Kumar Jain',
      doctorSpecialty: 'General Physician',
      patientName: 'Piyush Prajapati',
      patientPhone: '+91 98765 43210',
      patientAddress: 'Flat 402, Sunshine Heights, Malviya Nagar, Jaipur - 302017',
      diagnosis: 'Acute Upper Respiratory Tract Infection & Mild Bronchial Congestion',
      medicines: [
        { name: 'Augmentin 625 Duo', qty: '10 Tabs', dosage: '625 mg', price: 204.0 },
        { name: 'Dolo 650', qty: '15 Tabs', dosage: '650 mg', price: 33.5 },
        { name: 'Allegra 120mg', qty: '10 Tabs', dosage: '120 mg', price: 198.0 },
        { name: 'Alex Cough Syrup', qty: '1 Bottle', dosage: '100 ml', price: 145.0 }
      ],
      totalAmount: 495.5,
      issuedAt: 'Today, 02:15 PM',
      fulfillmentType: 'orderedOnline',
      pharmacyStatus: 'outForDelivery'
    }
  ]
};

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(data));
}

function parseBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch {
        resolve({});
      }
    });
  });
}

const server = http.createServer(async (req, res) => {
  const urlParts = req.url.split('?');
  const pathname = urlParts[0];

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    res.end();
    return;
  }

  // --- API ROUTING ---
  if (pathname === '/health' || pathname === '/api/health') {
    return sendJson(res, 200, { status: 'OK', message: 'drconnects24 API Live', timestamp: new Date() });
  }

  if (pathname.startsWith('/api/')) {
    // 0. Auth - Login
    if (pathname === '/api/auth/login' && req.method === 'POST') {
      const body = await parseBody(req);
      const { emailOrPhone, password, role } = body || {};

      if (!emailOrPhone || !password) {
        return sendJson(res, 400, {
          status: 400,
          success: false,
          message: 'Email/Phone and password are required',
          data: null,
        });
      }

      const cleanInput = String(emailOrPhone).trim().toLowerCase();
      const targetRole = role ? String(role).toLowerCase() : 'patient';

      if (targetRole === 'doctor') {
        const doctor = db.doctors.find(
          d => (d.email && d.email.toLowerCase() === cleanInput) ||
               (d.phone && d.phone.replace(/[\s-]/g, '') === cleanInput.replace(/[\s-]/g, '')) ||
               d.name.toLowerCase().includes(cleanInput)
        );

        if (!doctor) {
          return sendJson(res, 404, {
            status: 404,
            success: false,
            message: 'Doctor account not found with given credentials.',
            data: null,
          });
        }

        if (doctor.verificationStatus === 'pending' || !doctor.isVerified) {
          return sendJson(res, 403, {
            status: 403,
            success: false,
            message: 'Your doctor profile is under verification. Credential review in progress.',
            data: { status: 'pending', isVerified: false, doctor },
          });
        }

        return sendJson(res, 200, {
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
      let user = db.users.find(
        u => (u.email && u.email.toLowerCase() === cleanInput) ||
             (u.phone && u.phone.replace(/[\s-]/g, '') === cleanInput.replace(/[\s-]/g, ''))
      );

      if (!user && targetRole === 'patient') {
        user = db.users.find(u => u.role === 'patient');
      }

      if (!user) {
        return sendJson(res, 404, {
          status: 404,
          success: false,
          message: 'Account not found. Please register first.',
          data: null,
        });
      }

      return sendJson(res, 200, {
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

    // 0. Auth - Register Patient
    if ((pathname === '/api/auth/register-patient' || pathname === '/api/auth/signup') && req.method === 'POST') {
      const body = await parseBody(req);
      const { name, email, phone, gender, dob, currentCity } = body || {};

      if (!name || !phone) {
        return sendJson(res, 400, {
          status: 400,
          success: false,
          message: 'Full Name and Phone Number are required fields',
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
      db.users.unshift(newUser);

      return sendJson(res, 201, {
        status: 201,
        success: true,
        message: 'Patient account created successfully',
        data: { token: `jwt_${newUser.id}_${Date.now()}`, user: newUser },
      });
    }

    // 0. Auth - Doctor Verification Status
    if (pathname.startsWith('/api/auth/doctor-status') && req.method === 'GET') {
      const parts = pathname.split('/');
      const queryId = urlParts[1] ? new URLSearchParams(urlParts[1]).get('id') : null;
      const id = parts[4] || queryId;
      const doc = db.doctors.find(d => d.id === id);

      if (!doc) {
        return sendJson(res, 404, { status: 404, success: false, message: 'Doctor not found', data: null });
      }

      const status = doc.verificationStatus || (doc.isVerified ? 'approved' : 'pending');
      return sendJson(res, 200, {
        status: 200,
        success: true,
        message: 'Doctor status fetched',
        data: {
          doctorId: doc.id,
          name: doc.name,
          status,
          isVerified: status === 'approved',
          rejectionReason: doc.rejectionNotes || null,
        },
      });
    }

    // 1. Users
    if (pathname === '/api/users' && req.method === 'GET') {
      return sendJson(res, 200, { success: true, count: db.users.length, data: db.users });
    }

    // 2. Doctors
    if (pathname === '/api/doctors' && req.method === 'GET') {
      return sendJson(res, 200, { success: true, count: db.doctors.length, data: db.doctors });
    }

    if (pathname === '/api/doctors/pending' && req.method === 'GET') {
      const pending = db.doctors.filter(d => !d.isVerified || d.verificationStatus === 'pending');
      return sendJson(res, 200, { success: true, count: pending.length, data: pending });
    }

    if (pathname.startsWith('/api/doctors/') && pathname.endsWith('/verify') && req.method === 'PUT') {
      const parts = pathname.split('/');
      const id = parts[3];
      const body = await parseBody(req);
      const doc = db.doctors.find(d => d.id === id);
      if (doc) {
        doc.verificationStatus = body.status || 'approved';
        doc.isVerified = body.status === 'approved';
        doc.rejectionNotes = body.notes || '';
        doc.rejectionRemarks = body.notes || '';
        doc.verifiedAt = body.status === 'approved' ? new Date().toISOString() : null;
      }
      return sendJson(res, 200, { success: true, message: 'Doctor status updated', data: doc });
    }

    if (pathname === '/api/auth/doctor-register' && req.method === 'POST') {
      const body = await parseBody(req);
      const newDoc = {
        id: `d_${Date.now()}`,
        name: body.name || 'Dr. Practitioner',
        email: body.email || 'doctor@medicare.com',
        phone: body.phone || '+91 98000 00000',
        gender: body.gender || 'Male',
        dateOfBirth: body.dateOfBirth || '1988-06-15',
        specialty: body.specialty || 'General Physician',
        subSpecialty: body.subSpecialty || '',
        qualification: body.qualification || 'MBBS',
        collegeName: body.collegeName || 'Recognized Medical College',
        graduationYear: body.graduationYear || '2015',
        postGradDegree: body.postGradDegree || '',
        postGradCollege: body.postGradCollege || '',
        postGradYear: body.postGradYear || '',
        experienceYears: Number(body.experienceYears) || 5,
        experienceText: `${body.experienceYears || 5} yrs exp`,
        ratingPercentage: 100,
        patientStoriesCount: 0,
        consultationFee: Number(body.consultationFee) || 600,
        videoConsultationFee: Number(body.videoConsultationFee) || 499,
        imageUrl: body.imageUrl || 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
        isOnline: false,
        allowsPhysical: true,
        allowsVideo: true,
        isVerified: false,
        verificationStatus: 'pending',
        medicalLicenseNo: body.medicalLicenseNo || 'MCI/2026/PENDING',
        stateMedicalCouncil: body.stateMedicalCouncil || 'Medical Council of India',
        registrationYear: body.registrationYear || '2015',
        licenseExpiryYear: body.licenseExpiryYear || '2035',
        medicalCouncilCertUrl: body.medicalCouncilCertUrl || body.qualificationCertUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
        primaryDegreeCertUrl: body.primaryDegreeCertUrl || body.qualificationCertUrl || 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800',
        postGradCertUrl: body.postGradCertUrl || 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800',
        idProofUrl: body.idProofUrl || 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
        clinicAddressProofUrl: body.clinicAddressProofUrl || 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=800',
        doctorSignatureUrl: body.doctorSignatureUrl || 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
        qualificationCertUrl: body.medicalCouncilCertUrl || body.qualificationCertUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
        clinicName: body.clinicName || 'City Health Clinic',
        clinicAddress: body.clinicAddress || 'Jaipur, Rajasthan',
        city: body.city || 'Jaipur',
        pincode: body.pincode || '302017',
        distanceKm: 2.5,
        languages: body.languages && Array.isArray(body.languages) ? body.languages : ['English', 'Hindi'],
        aboutText: body.aboutText || `${body.name} registered medical professional.`,
        services: ['Consultation', 'Routine Examination'],
        submittedAt: new Date().toISOString(),
      };
      db.doctors.unshift(newDoc);
      return sendJson(res, 200, { success: true, message: 'Registration submitted successfully with all 6 medical documents', data: newDoc });
    }

    // 3. Specialties
    if (pathname === '/api/specialties' && req.method === 'GET') {
      return sendJson(res, 200, { success: true, count: db.specialties.length, data: db.specialties });
    }

    // 4. Hospitals
    if (pathname === '/api/hospitals' && req.method === 'GET') {
      return sendJson(res, 200, { success: true, count: db.hospitals.length, data: db.hospitals });
    }

    // 5. Appointments
    if (pathname === '/api/appointments' && req.method === 'GET') {
      return sendJson(res, 200, { success: true, count: db.appointments.length, data: db.appointments });
    }

    // 6. Subscription Plans
    if (pathname === '/api/plans' && req.method === 'GET') {
      return sendJson(res, 200, { success: true, count: db.plans.length, data: db.plans });
    }

    if (pathname === '/api/plans' && req.method === 'POST') {
      const body = await parseBody(req);
      const newPlan = { id: `plan_${Date.now()}`, ...body };
      db.plans.push(newPlan);
      return sendJson(res, 201, { success: true, data: newPlan });
    }

    // 7. Prescriptions & Pharmacy Orders
    if (pathname === '/api/prescriptions' && req.method === 'GET') {
      return sendJson(res, 200, { success: true, count: db.prescriptions.length, data: db.prescriptions });
    }

    if (pathname === '/api/prescriptions' && req.method === 'POST') {
      const body = await parseBody(req);
      const newRx = { id: `RX-${Date.now().toString().slice(-5)}`, ...body };
      db.prescriptions.unshift(newRx);
      return sendJson(res, 201, { success: true, data: newRx });
    }

    // 8. Analytics
    if (pathname === '/api/analytics' && req.method === 'GET') {
      return sendJson(res, 200, {
        success: true,
        data: {
          totalUsers: db.users.length,
          totalDoctors: db.doctors.length,
          pendingVerifications: db.doctors.filter(d => !d.isVerified).length,
          totalAppointments: db.appointments.length,
          totalPlans: db.plans.length,
          totalPrescriptions: db.prescriptions.length,
          revenueTotal: 124500,
        },
      });
    }

    // 9. Agora Real-Time Communication Endpoint with User Credentials
    if (pathname === '/api/agora/rtc-token' && req.method === 'POST') {
      const body = await parseBody(req);
      const appId = '2d1a79eb047e4bcb93dadfacc4abe0a3';
      const appCertificate = 'a0d6634f5dda439e8d4aee0e7135db8f';
      const channelName = body.channelName || 'appbuilder-18d042b8a93f08e894cf';
      const uid = body.uid || 12345;
      const token = `006${appId}IAC${uid}T${Math.floor(Date.now() / 1000) + 3600}X${appCertificate.substring(0, 8)}`;

      return sendJson(res, 200, {
        success: true,
        appId,
        channelName,
        uid,
        token,
      });
    }

    // 10. Diseases
    if (pathname === '/api/diseases' && req.method === 'GET') {
      const diseases = [
        { id: 'dis_1', name: 'Fever & Chills', specialty: 'General Physician', symptomCount: '12 Symptoms' },
        { id: 'dis_2', name: 'Cough, Cold & Flu', specialty: 'General Physician', symptomCount: '8 Symptoms' },
        { id: 'dis_3', name: 'Skin Acne & Pimples', specialty: 'Dermatologist', symptomCount: '6 Symptoms' },
        { id: 'dis_4', name: 'Hair Fall & Dandruff', specialty: 'Dermatologist', symptomCount: '5 Symptoms' },
        { id: 'dis_5', name: 'Child Fever & Vomiting', specialty: 'Pediatrician', symptomCount: '10 Symptoms' },
        { id: 'dis_6', name: 'Pregnancy & Periods', specialty: 'Gynecologist', symptomCount: '14 Symptoms' },
        { id: 'dis_7', name: 'Chest Pain & BP', specialty: 'Cardiologist', symptomCount: '7 Symptoms' },
        { id: 'dis_8', name: 'Anxiety & Depression', specialty: 'Psychiatrist', symptomCount: '9 Symptoms' },
        { id: 'dis_9', name: 'Diabetes Management', specialty: 'General Physician', symptomCount: '11 Symptoms' },
        { id: 'dis_10', name: 'Knee & Joint Pain', specialty: 'Orthopedic', symptomCount: '8 Symptoms' },
      ];
      return sendJson(res, 200, { status: 200, success: true, count: diseases.length, data: diseases });
    }

    // 11. Wallet
    if (pathname.startsWith('/api/wallet')) {
      const parts = pathname.split('/');
      const queryId = urlParts[1] ? new URLSearchParams(urlParts[1]).get('userId') : null;
      const userId = parts[3] || queryId || 'u1';

      if (!db.wallets) db.wallets = {};
      if (!db.wallets[userId]) {
        db.wallets[userId] = {
          userId,
          balance: 1450.0,
          totalCashbackEarned: 185.0,
          transactions: [
            {
              id: 'tx_101',
              title: 'HealthPay Balance Added',
              description: 'Top-up via UPI (Google Pay)',
              amount: 1000.0,
              isCredit: true,
              category: 'topUp',
              timestamp: '2026-09-22T09:14:00Z',
              referenceId: 'UPI-9841278129',
              status: 'completed',
            },
            {
              id: 'tx_102',
              title: 'Consultation Fee Paid',
              description: 'Paid to Dr. Rajesh Sharma',
              amount: 499.0,
              isCredit: false,
              category: 'consultation',
              timestamp: '2026-09-22T10:30:00Z',
              referenceId: 'MED-CONS-88219',
              status: 'completed',
            },
          ],
        };
      }

      if (req.method === 'POST') {
        const body = await parseBody(req);
        const { action, amount, paymentMethod } = body || {};
        const pAmt = Math.abs(Number(amount)) || 0;

        if (action === 'pay' || pathname.endsWith('/pay')) {
          db.wallets[userId].balance -= pAmt;
          return sendJson(res, 200, { status: 200, success: true, message: 'Payment completed', data: db.wallets[userId] });
        }

        db.wallets[userId].balance += pAmt;
        return sendJson(res, 200, { status: 200, success: true, message: `₹${pAmt} added`, data: db.wallets[userId] });
      }

      return sendJson(res, 200, { status: 200, success: true, data: db.wallets[userId] });
    }

    // 12. Subscriptions
    if (pathname.startsWith('/api/subscriptions')) {
      const parts = pathname.split('/');
      const queryId = urlParts[1] ? new URLSearchParams(urlParts[1]).get('userId') : null;
      const userId = parts[3] || queryId || 'u1';

      if (!db.subscriptions) {
        db.subscriptions = [
          {
            id: 'sub_101',
            userId: 'u1',
            planId: 'plan_gold',
            planName: 'Gold Family Shield',
            status: 'active',
            startDate: '2026-08-01T00:00:00Z',
            expiryDate: '2027-02-01T00:00:00Z',
            price: 699,
            consultationsRemaining: -1,
            features: ['Unlimited 24/7 Consultations', 'Family coverage for 4'],
          },
        ];
      }

      if (req.method === 'POST') {
        const body = await parseBody(req);
        if (pathname.endsWith('/cancel') || body.action === 'cancel') {
          return sendJson(res, 200, { status: 200, success: true, message: 'Subscription cancelled', data: { status: 'cancelled' } });
        }
        const newSub = { id: `sub_${Date.now()}`, userId, planId: body.planId || 'plan_gold', planName: body.planName || 'Gold Shield', status: 'active' };
        db.subscriptions.unshift(newSub);
        return sendJson(res, 201, { status: 201, success: true, message: 'Subscription activated', data: newSub });
      }

      const sub = db.subscriptions.find(s => s.userId === userId && s.status === 'active') || null;
      return sendJson(res, 200, { status: 200, success: true, data: sub });
    }

    // 13. Payments
    if (pathname.startsWith('/api/payments')) {
      const body = await parseBody(req);
      if (pathname.endsWith('/verify-success') || body.action === 'verify-success') {
        return sendJson(res, 200, { status: 200, success: true, message: 'Payment confirmed', data: { status: 'PAID' } });
      }
      return sendJson(res, 200, { status: 200, success: true, message: 'Order created', data: { orderId: `ORD_${Date.now()}` } });
    }

    // Unknown API endpoint fallback
    return sendJson(res, 404, { success: false, message: `Endpoint ${pathname} not found` });
  }

  // --- STATIC FRONTEND SPA ROUTING ---
  let filePath = path.join(DIST_DIR, pathname);

  if (pathname === '/' || (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory())) {
    filePath = path.join(DIST_DIR, 'index.html');
  }

  if (!fs.existsSync(filePath)) {
    filePath = path.join(DIST_DIR, 'index.html');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      res.end('500 - Internal Server Error');
    } else {
      res.writeHead(200, {
        'Content-Type': contentType,
        'Cache-Control': ext === '.html' ? 'no-cache' : 'public, max-age=31536000, immutable',
      });
      res.end(content);
    }
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 drconnects24 Full-Stack Web Portal & API running on port ${PORT}`);
});
