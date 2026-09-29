import {
  getUserSubscription,
  addSubscription,
  deductConsultation,
  getStore,
  saveStore,
  getUserById,
  addPayment,
} from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const { userId, planId, paymentMethod, amount, subscriptionId } = req.body || req.query || {};
  const action = req.query.action || req.body?.action;
  const pathPart = (req.url || '').split('?')[0];

  // 1. GET: Get user subscription
  if (req.method === 'GET') {
    const uId = userId || req.query.id;
    if (!uId) {
      // Return all subscriptions (for admin)
      const allSubs = getStore().subscriptions || [];
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'Subscriptions retrieved',
        data: allSubs,
      });
    }

    const sub = getUserSubscription(uId);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: sub ? 'Active subscription retrieved' : 'No active subscription found',
      data: sub ? { subscription: sub } : null,
    });
  }

  // 2. POST /purchase: Activate or Buy Subscription
  if (action === 'purchase' || pathPart.endsWith('/purchase') || (req.method === 'POST' && planId)) {
    if (!userId || !planId) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'User ID and Plan ID are required to purchase subscription',
        data: null,
      });
    }

    const user = getUserById(userId);
    const store = getStore();
    const plan = (store.plans || []).find(p => p.id === planId) || {
      id: planId,
      name: 'Care Pass',
      price: Number(amount) || 199,
      durationDays: 30,
      consultationLimit: 3,
    };

    const newSub = addSubscription({
      userId,
      userName: user ? user.name : 'Patient',
      planId,
      planName: plan.name,
      price: Number(amount || plan.price || 199),
      durationDays: plan.durationDays || 30,
      consultationLimit: plan.consultationLimit ?? 3,
      paymentMethod: paymentMethod || 'Razorpay',
    });

    // Also record in payments table for admin view!
    addPayment({
      userId,
      userName: user ? user.name : 'Patient',
      userEmail: user ? user.email : '',
      userPhone: user ? user.phone : '',
      amount: newSub.price,
      currency: 'INR',
      type: 'subscription',
      planId,
      planName: plan.name,
      purpose: `Subscription: ${plan.name} (${plan.durationLabel || '1 Month'})`,
      paymentMethod: paymentMethod || 'Razorpay',
      status: 'captured',
    });

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: `${plan.name} activated successfully for ${user ? user.name : 'user'}!`,
      data: {
        subscription: newSub,
      },
    });
  }

  // 3. POST /use-credit: Deduct 1 consultation credit
  if (action === 'use-credit' || pathPart.endsWith('/use-credit')) {
    if (userId) {
      deductConsultation(userId);
      const updatedSub = getUserSubscription(userId);
      return res.status(200).json({
        status: 200,
        statusCode: 200,
        success: true,
        message: 'Consultation credit deducted',
        data: updatedSub,
      });
    }
  }

  // 4. POST /cancel: Cancel subscription
  if (action === 'cancel' || pathPart.endsWith('/cancel')) {
    const store = getStore();
    const sub = (store.subscriptions || []).find(s => s.userId === userId || s.id === subscriptionId);
    if (sub) {
      sub.status = 'cancelled';
      const uIdx = store.users.findIndex(u => u.id === sub.userId);
      if (uIdx !== -1) {
        store.users[uIdx].hasActiveCarePlan = false;
      }
      saveStore(store);
    }

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Subscription cancelled successfully',
      data: null,
    });
  }

  return res.status(405).json({
    status: 405,
    statusCode: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
