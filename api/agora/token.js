export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const channelName = req.query.channelName || req.body?.channelName || 'medicare_room';
  const uid = req.query.uid || req.body?.uid || 0;

  return res.status(200).json({
    status: 200,
    success: true,
    message: 'Agora token generated successfully',
    data: {
      token: `agora_live_${Date.now()}_${channelName}_${uid}`,
      channelName,
      uid,
      appId: process.env.AGORA_APP_ID || 'medicare_demo_agora_app_id',
    },
  });
}
