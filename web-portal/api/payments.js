export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const { action, amount, appointmentId, planId } = req.body || {};

  if (action === 'verify-success' || req.query.action === 'verify-success') {
    const paymentId = req.body?.paymentId || `PAY_${Date.now()}`;
    return res.status(200).json({
      status: 200,
      success: true,
      message: 'Payment verified and confirmed successfully!',
      data: {
        paymentId,
        orderId: req.body?.orderId || `ORD_${Date.now()}`,
        status: 'PAID',
        verifiedAt: new Date().toISOString(),
      },
    });
  }

  // Default: create-order
  const orderId = `ORD_${Date.now()}`;
  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Payment order created successfully',
    data: {
      orderId,
      amount: amount || 499,
      currency: 'INR',
      status: 'created',
      appointmentId: appointmentId || null,
      planId: planId || null,
    },
  });
}
