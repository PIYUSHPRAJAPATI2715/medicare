import { initialSpecialties } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  if (req.method === 'POST') {
    const newSpecialty = { id: `s_${Date.now()}`, ...req.body };
    initialSpecialties.push(newSpecialty);
    return res.status(201).json({
      status: 201,
      success: true,
      message: 'Specialty created successfully',
      data: newSpecialty,
    });
  }

  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Medical specialties retrieved successfully',
    count: initialSpecialties.length,
    data: initialSpecialties,
  });
}
