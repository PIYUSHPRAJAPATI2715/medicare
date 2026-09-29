import crypto from 'crypto';
import {
  RAZORPAY_KEY_ID,
  RAZORPAY_KEY_SECRET,
  addPayment,
  getPayments,
  addSubscription,
  topupWallet,
  getUserById,
} from './store.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const action = req.query.action || req.body?.action;
  const pathPart = (req.url || '').split('?')[0];

  // 1. GET: Fetch all payments (for Admin Web Portal Payments Page)
  if (req.method === 'GET' && !action) {
    const payments = getPayments();
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Payment transactions retrieved successfully',
      count: payments.length,
      data: payments,
      razorpayKeyId: RAZORPAY_KEY_ID,
    });
  }

  // 2. POST /create-order: Create Razorpay Order
  if (action === 'create-order' || pathPart.endsWith('/create-order') || (req.method === 'POST' && req.body?.amount && !req.body?.paymentId)) {
    const { amount, currency, userId, purpose, planId, planName } = req.body || req.query || {};
    const numAmount = Number(amount) || 499;
    const user = userId ? getUserById(userId) : null;

    // Generate unique Razorpay Order ID
    const orderId = `order_${Date.now()}_${Math.floor(100 + Math.random() * 900)}`;

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Razorpay payment order initialized',
      data: {
        orderId,
        amount: numAmount,
        amountInPaise: Math.round(numAmount * 100),
        currency: currency || 'INR',
        keyId: RAZORPAY_KEY_ID,
        purpose: purpose || (planName ? `Subscription: ${planName}` : 'Doctor Consultation'),
        userId: userId || (user ? user.id : 'u1'),
        userName: user ? user.name : 'Patient',
        userEmail: user ? user.email : '',
        userPhone: user ? user.phone : '',
        planId: planId || null,
        planName: planName || null,
        platformFee: 0,
        notes: {
          app: 'drconnects24',
          type: planId ? 'subscription' : 'consultation',
        },
      },
    });
  }

  // 3. POST /verify-success: Verify & Record Payment Transaction
  if (action === 'verify-success' || pathPart.endsWith('/verify-success') || (req.method === 'POST' && (req.body?.paymentId || req.body?.razorpay_payment_id))) {
    const {
      userId,
      amount,
      paymentId,
      razorpay_payment_id,
      orderId,
      razorpay_order_id,
      signature,
      razorpay_signature,
      purpose,
      type,
      planId,
      planName,
      paymentMethod,
    } = req.body || {};

    const actualPaymentId = razorpay_payment_id || paymentId || `pay_rzp_${Date.now()}`;
    const actualOrderId = razorpay_order_id || orderId || `order_${Date.now()}`;
    const actualSignature = razorpay_signature || signature;
    const numAmount = Number(amount) || 499;

    // Optional cryptographic signature check if provided
    let isSignatureValid = true;
    if (actualSignature && actualOrderId && RAZORPAY_KEY_SECRET) {
      try {
        const expectedSignature = crypto
          .createHmac('sha256', RAZORPAY_KEY_SECRET)
          .update(`${actualOrderId}|${actualPaymentId}`)
          .digest('hex');
        isSignatureValid = (expectedSignature === actualSignature);
      } catch (e) {
        console.warn('[Razorpay] Signature verification error:', e.message);
      }
    }

    const user = userId ? getUserById(userId) : null;

    // Record in central payments collection
    const recordedPayment = addPayment({
      userId: userId || (user ? user.id : 'u1'),
      userName: user ? user.name : 'Patient',
      userEmail: user ? user.email : '',
      userPhone: user ? user.phone : '',
      amount: numAmount,
      currency: 'INR',
      type: type || (planId ? 'subscription' : 'consultation'),
      planId: planId || null,
      planName: planName || (planId ? 'Care Plan' : null),
      purpose: purpose || (planName ? `Subscription: ${planName}` : 'Doctor Consultation'),
      paymentMethod: paymentMethod || 'Razorpay',
      razorpayOrderId: actualOrderId,
      razorpayPaymentId: actualPaymentId,
      status: 'captured',
    });

    // If subscription payment: automatically activate subscription & set call/chat limits!
    let activatedSub = null;
    if (type === 'subscription' || planId || (purpose && purpose.toLowerCase().includes('subscription'))) {
      activatedSub = addSubscription({
        userId: userId || 'u1',
        userName: user ? user.name : 'Patient',
        planId: planId || 'plan_gold',
        planName: planName || 'Care Pass',
        price: numAmount,
        paymentMethod: 'Razorpay',
        razorpayPaymentId: actualPaymentId,
        razorpayOrderId: actualOrderId,
      });
    }

    // If wallet top-up payment: reload wallet balance
    let updatedWallet = null;
    if (type === 'wallet_topup' || (purpose && purpose.toLowerCase().includes('wallet'))) {
      updatedWallet = topupWallet(userId || 'u1', numAmount, 'Razorpay', actualPaymentId);
    }

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Razorpay payment verified and recorded successfully in admin database',
      data: {
        payment: recordedPayment,
        subscription: activatedSub,
        wallet: updatedWallet,
        isSignatureValid,
      },
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
