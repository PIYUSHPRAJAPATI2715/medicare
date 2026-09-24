import { initialDoctors } from '../data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const id = req.query.id || req.query.doctorId;
  if (!id) {
    return res.status(400).json({
      status: 400,
      success: false,
      message: 'Doctor ID is required as query param ?id=...',
      data: null,
    });
  }

  const doc = initialDoctors.find(d => d.id === id);
  if (!doc) {
    return res.status(404).json({
      status: 404,
      success: false,
      message: 'Doctor not found with given ID.',
      data: null,
    });
  }

  const status = doc.verificationStatus || (doc.isVerified ? 'approved' : 'pending');

  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Doctor verification status fetched successfully',
    data: {
      doctorId: doc.id,
      name: doc.name,
      status: status,
      isVerified: status === 'approved',
      rejectionReason: doc.rejectionReason || null,
      submittedAt: doc.createdAt || null,
    },
  });
}
