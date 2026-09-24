import { initialDoctors } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  if (req.method === 'DELETE') {
    const { id } = req.query;
    if (id) {
      const idx = initialDoctors.findIndex(d => d.id === id);
      if (idx !== -1) {
        initialDoctors.splice(idx, 1);
      }
    }
    return res.status(200).json({
      success: true,
      message: 'Doctor deleted successfully',
      data: initialDoctors,
    });
  }

  return res.status(200).json({
    success: true,
    count: initialDoctors.length,
    data: initialDoctors,
  });
}
