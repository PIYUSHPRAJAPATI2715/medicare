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
      }
      return sendJson(res, 200, { success: true, message: 'Doctor status updated', data: doc });
    }

    if (pathname === '/api/auth/doctor-register' && req.method === 'POST') {
      const body = await parseBody(req);
      const newDoc = {
        id: `d_${Date.now()}`,
        name: body.name || 'Dr. Practitioner',
        specialty: body.specialty || 'General Physician',
        qualification: body.qualification || 'MBBS',
        experienceYears: Number(body.experienceYears) || 3,
        experienceText: `${body.experienceYears || 3} yrs exp`,
        ratingPercentage: 100,
        patientStoriesCount: 0,
        consultationFee: Number(body.consultationFee) || 500,
        imageUrl: body.imageUrl || 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
        isOnline: false,
        allowsPhysical: true,
        allowsVideo: true,
        isVerified: false,
        verificationStatus: 'pending',
        medicalLicenseNo: body.medicalLicenseNo || 'MCI/2026/PENDING',
        stateMedicalCouncil: body.stateMedicalCouncil || 'Medical Council of India',
        qualificationCertUrl: body.qualificationCertUrl || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
        idProofUrl: body.idProofUrl || 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600',
        clinicAddressProofUrl: body.clinicAddressProofUrl || 'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?w=600',
        clinicName: body.clinicName || 'Clinic',
        clinicAddress: body.clinicAddress || 'Jaipur',
        distanceKm: 2.5,
        languages: ['English', 'Hindi'],
        aboutText: `${body.name} registered medical professional.`,
        services: ['Consultation'],
      };
      db.doctors.unshift(newDoc);
      return sendJson(res, 200, { success: true, message: 'Registration submitted successfully', data: newDoc });
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
