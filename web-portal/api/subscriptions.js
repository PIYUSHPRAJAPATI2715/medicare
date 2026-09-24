import { initialSubscriptions } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const userId = req.query.userId || req.query.id || req.body?.userId || 'u1';

  if (req.method === 'POST') {
    const { action, planId, planName, price, features } = req.body || {};

    if (action === 'cancel') {
      const subIdx = initialSubscriptions.findIndex(s => s.userId === userId && s.status === 'active');
      if (subIdx !== -1) {
        initialSubscriptions[subIdx].status = 'cancelled';
      }
      return res.status(200).json({
        status: 200,
        success: true,
        message: 'Care plan subscription cancelled successfully.',
        data: { status: 'cancelled', userId },
      });
    }

    // Default: Purchase
    const newSub = {
      id: `sub_${Date.now()}`,
      userId,
      planId: planId || 'plan_gold',
      planName: planName || 'Gold Family Shield',
      status: 'active',
      startDate: new Date().toISOString(),
      expiryDate: new Date(Date.now() + 180 * 86400000).toISOString(),
      price: price || 699,
      consultationsRemaining: -1,
      features: features || [
        'Unlimited 24/7 Video & Audio Consultations',
        'Direct connection to MD Specialists',
        'Family coverage for up to 4 members',
        '20% Off all prescribed medicines',
      ],
    };

    initialSubscriptions.unshift(newSub);

    return res.status(201).json({
      status: 201,
      success: true,
      message: `${newSub.planName} activated successfully!`,
      data: newSub,
    });
  }

  // GET: fetch active subscription for user
  const sub = initialSubscriptions.find(s => s.userId === userId && s.status === 'active') || null;

  return res.status(200).json({
    status: 200,
    success: true,
    message: sub ? 'Active subscription retrieved' : 'No active subscription found',
    data: sub,
  });
}
