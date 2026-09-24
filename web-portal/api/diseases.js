import { initialDiseases } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  if (req.method === 'POST') {
    const newDisease = { id: `dis_${Date.now()}`, ...req.body };
    initialDiseases.push(newDisease);
    return res.status(201).json({
      status: 201,
      success: true,
      message: 'Disease created successfully',
      data: newDisease,
    });
  }

  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Diseases catalog fetched successfully',
    count: initialDiseases.length,
    data: initialDiseases,
  });
}
