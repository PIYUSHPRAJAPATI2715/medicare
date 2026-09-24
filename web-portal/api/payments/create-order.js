import paymentsHandler from '../payments.js';

export default function handler(req, res) {
  if (req.body) req.body.action = 'create-order';
  return paymentsHandler(req, res);
}
