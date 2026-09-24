import walletHandler from '../wallet.js';

export default function handler(req, res) {
  if (req.body) req.body.action = 'topup';
  return walletHandler(req, res);
}
