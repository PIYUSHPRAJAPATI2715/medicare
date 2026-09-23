export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  return res.status(200).json({
    status: 'OK',
    message: 'drconnects24 API Live on Vercel',
    timestamp: new Date().toISOString(),
  });
}
