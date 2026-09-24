import subscriptionHandler from '../subscriptions.js';

export default function handler(req, res) {
  if (req.body) req.body.action = 'purchase';
  return subscriptionHandler(req, res);
}
