import walletHandler from '../wallet.js';

export default function handler(req, res) {
  if (req.body) req.body.action = 'pay';
  return walletHandler(req, res);
}
