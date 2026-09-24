import { initialWallets } from './data.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const userId = req.query.userId || req.query.id || req.body?.userId || 'u1';

  // Ensure user wallet exists
  if (!initialWallets[userId]) {
    initialWallets[userId] = {
      userId,
      balance: 1450.0,
      totalCashbackEarned: 185.0,
      transactions: [
        {
          id: `tx_${Date.now()}`,
          title: 'Welcome HealthPay Bonus',
          description: 'Promotional credit added',
          amount: 500.0,
          isCredit: true,
          category: 'welcome',
          timestamp: new Date().toISOString(),
          referenceId: 'WELCOME-HEALTH',
          status: 'completed',
        },
      ],
    };
  }

  const wallet = initialWallets[userId];

  // POST: topup, pay, or transfer
  if (req.method === 'POST') {
    const { action, amount, paymentMethod, description, recipientPhone } = req.body || {};
    const parsedAmount = Math.abs(Number(amount)) || 0;

    if (action === 'pay') {
      if (wallet.balance < parsedAmount) {
        return res.status(400).json({
          status: 400,
          success: false,
          message: 'Insufficient HealthPay balance for this transaction.',
          data: wallet,
        });
      }
      wallet.balance -= parsedAmount;
      const tx = {
        id: `tx_${Date.now()}`,
        title: 'Payment Completed',
        description: description || 'Health consultation fee',
        amount: parsedAmount,
        isCredit: false,
        category: 'payment',
        timestamp: new Date().toISOString(),
        referenceId: `PAY-${Date.now()}`,
        status: 'completed',
      };
      wallet.transactions.unshift(tx);

      return res.status(200).json({
        status: 200,
        success: true,
        message: 'Payment completed successfully with HealthPay',
        data: wallet,
      });
    }

    if (action === 'transfer') {
      if (wallet.balance < parsedAmount) {
        return res.status(400).json({
          status: 400,
          success: false,
          message: 'Insufficient HealthPay balance for transfer.',
          data: wallet,
        });
      }
      wallet.balance -= parsedAmount;
      const tx = {
        id: `tx_${Date.now()}`,
        title: `Transferred to ${recipientPhone || 'User'}`,
        description: 'P2P HealthPay Transfer',
        amount: parsedAmount,
        isCredit: false,
        category: 'transfer',
        timestamp: new Date().toISOString(),
        referenceId: `TRF-${Date.now()}`,
        status: 'completed',
      };
      wallet.transactions.unshift(tx);

      return res.status(200).json({
        status: 200,
        success: true,
        message: `₹${parsedAmount} transferred successfully`,
        data: wallet,
      });
    }

    // Default action: Top-up
    wallet.balance += parsedAmount;
    const tx = {
      id: `tx_${Date.now()}`,
      title: 'HealthPay Balance Added',
      description: `Top-up via ${paymentMethod || 'UPI'}`,
      amount: parsedAmount,
      isCredit: true,
      category: 'topUp',
      timestamp: new Date().toISOString(),
      referenceId: `UPI-${Date.now()}`,
      status: 'completed',
    };
    wallet.transactions.unshift(tx);

    return res.status(200).json({
      status: 200,
      success: true,
      message: `₹${parsedAmount} added to HealthPay wallet successfully`,
      data: wallet,
    });
  }

  // GET: return wallet details
  return res.status(200).json({
    status: 200,
    success: true,
    message: 'HealthPay wallet details retrieved',
    data: wallet,
  });
}
