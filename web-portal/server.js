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

    // 6. Analytics
    if (pathname === '/api/analytics' && req.method === 'GET') {
      return sendJson(res, 200, {
        success: true,
        data: {
          totalUsers: db.users.length,
          totalDoctors: db.doctors.length,
          pendingVerifications: db.doctors.filter(d => !d.isVerified).length,
          totalAppointments: db.appointments.length,
          revenueTotal: 124500,
        },
      });
    }

    // 7. Agora RTC Token Mock
    if (pathname === '/api/agora/rtc-token' && req.method === 'POST') {
      const body = await parseBody(req);
      return sendJson(res, 200, {
        success: true,
        token: `mock_rtc_token_${Date.now()}`,
        channelName: body.channelName || 'consult-live',
        uid: body.uid || 12345,
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
