import paymentsHandler from '../payments.js';

export default function handler(req, res) {
  if (req.body) req.body.action = 'verify-success';
  return paymentsHandler(req, res);
}
