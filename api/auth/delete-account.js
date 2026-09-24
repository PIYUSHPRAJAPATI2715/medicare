import { initialUsers, initialDoctors } from '../data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const id = req.query.id || req.body?.userId || req.body?.id;
  if (!id) {
    return res.status(400).json({
      status: 400,
      success: false,
      message: 'User ID is required to delete account',
      data: null,
    });
  }

  const userIdx = initialUsers.findIndex(u => u.id === id);
  if (userIdx !== -1) {
    initialUsers.splice(userIdx, 1);
  }

  const docIdx = initialDoctors.findIndex(d => d.id === id);
  if (docIdx !== -1) {
    initialDoctors.splice(docIdx, 1);
  }

  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Account deleted permanently from MediCare+ system',
    data: { id, deleted: true },
  });
}
