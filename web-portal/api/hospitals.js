import { initialHospitals } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  if (req.method === 'POST') {
    const newHospital = { id: `h_${Date.now()}`, ...req.body };
    initialHospitals.push(newHospital);
    return res.status(201).json({
      status: 201,
      success: true,
      message: 'Hospital added successfully',
      data: newHospital,
    });
  }

  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Partner hospitals retrieved successfully',
    count: initialHospitals.length,
    data: initialHospitals,
  });
}
