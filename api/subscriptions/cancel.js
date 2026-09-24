import subscriptionHandler from '../subscriptions.js';

export default function handler(req, res) {
  if (req.body) req.body.action = 'cancel';
  return subscriptionHandler(req, res);
}
