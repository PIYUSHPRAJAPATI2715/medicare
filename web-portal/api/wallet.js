import { getWallet, topupWallet, payWithWallet } from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const { userId, amount, paymentMethod, referenceId, purpose, category } = req.body || req.query || {};
  const action = req.query.action || req.body?.action;
  const pathPart = (req.url || '').split('?')[0];

  const targetUserId = userId || req.query.id || 'u1';

  // 1. GET Wallet details
  if (req.method === 'GET' && !action) {
    const wallet = getWallet(targetUserId);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Wallet balance and transaction history retrieved',
      data: wallet,
    });
  }

  // 2. POST /topup
  if (action === 'topup' || pathPart.endsWith('/topup')) {
    const numAmount = Number(amount);
    if (!numAmount || numAmount <= 0) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'Valid top-up amount is required',
        data: null,
      });
    }

    const updatedWallet = topupWallet(targetUserId, numAmount, paymentMethod || 'UPI', referenceId);
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: `₹${numAmount} credited to MediCare+ HealthPay Wallet`,
      data: updatedWallet,
    });
  }

  // 3. POST /pay
  if (action === 'pay' || pathPart.endsWith('/pay') || (req.method === 'POST' && purpose)) {
    const numAmount = Number(amount);
    if (!numAmount || numAmount <= 0) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: 'Valid payment amount is required',
        data: null,
      });
    }

    const result = payWithWallet(targetUserId, numAmount, purpose || 'Doctor Consultation', category || 'consultation', referenceId);
    if (!result.success) {
      return res.status(400).json({
        status: 400,
        statusCode: 400,
        success: false,
        message: result.message || 'Insufficient wallet balance',
        data: null,
      });
    }

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Payment completed successfully via HealthPay',
      data: result.data,
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
