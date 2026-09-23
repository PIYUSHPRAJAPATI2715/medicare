import { initialUsers, initialDoctors, initialAppointments } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  return res.status(200).json({
    success: true,
    data: {
      totalUsers: initialUsers.length,
      totalDoctors: initialDoctors.length,
      pendingVerifications: initialDoctors.filter(d => !d.isVerified).length,
      totalAppointments: initialAppointments.length,
      revenueTotal: 124500,
    },
  });
}
