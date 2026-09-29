import { getStore, saveStore } from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const store = getStore();
  const id = req.query.id || req.body?.id;

  if (req.method === 'POST') {
    const newPlan = {
      id: req.body?.id || `plan_${Date.now()}`,
      name: req.body?.name || 'New Care Plan',
      tagline: req.body?.tagline || 'Comprehensive medical coverage',
      price: Number(req.body?.price) || 199,
      originalPrice: Number(req.body?.originalPrice) || 499,
      durationDays: Number(req.body?.durationDays) || 30,
      durationLabel: req.body?.durationLabel || '1 Month',
      consultationLimit: Number(req.body?.consultationLimit) || 3,
      isPopular: !!req.body?.isPopular,
      badgeText: req.body?.badgeText || 'POPULAR',
      isActive: req.body?.isActive ?? true,
      subscribersCount: 0,
      features: req.body?.features || [
        'Video or Audio Consultations with specialists',
        '24/7 Unlimited Doctor Chat',
        'Digital Prescriptions',
      ],
    };

    store.plans.push(newPlan);
    saveStore(store);

    return res.status(201).json({
      status: 201,
      statusCode: 201,
      success: true,
      message: 'Care plan created successfully',
      data: newPlan,
    });
  }

  if (req.method === 'PUT' && id) {
    const idx = store.plans.findIndex(p => p.id === id);
    if (idx !== -1) {
      store.plans[idx] = { ...store.plans[idx], ...req.body, id };
      saveStore(store);
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'Care plan updated',
        data: store.plans[idx],
      });
    }
  }

  if (req.method === 'DELETE' && id) {
    store.plans = store.plans.filter(p => p.id !== id);
    saveStore(store);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Care plan deleted',
      data: { id, deleted: true },
    });
  }

  return res.status(200).json({
    status: 200,
    statusCode: 200,
    success: true,
    message: 'Care plans retrieved successfully',
    count: store.plans.length,
    data: store.plans,
  });
}
