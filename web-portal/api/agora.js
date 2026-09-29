import { AGORA_APP_ID, AGORA_APP_CERTIFICATE, generateAgoraToken } from './store.js';

export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const action = req.query.action || req.body?.action;
  const pathPart = (req.url || '').split('?')[0];

  // 1. GET Agora Config
  if (req.method === 'GET' || action === 'config' || pathPart.endsWith('/config')) {
    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      appId: AGORA_APP_ID,
      isDemo: false,
      message: 'Agora video consultation engine ready',
      data: {
        appId: AGORA_APP_ID,
        defaultChannel: 'appbuilder-18d042b8a93f08e894cf',
      },
    });
  }

  // 2. POST Generate RTC Token
  if (req.method === 'POST') {
    const { channelName, uid, role, channel } = req.body || req.query || {};
    const effectiveChannel = channelName || channel || `drconnects_${Date.now()}`;
    const effectiveUid = uid || Math.floor(1000 + Math.random() * 9000);

    const tokenData = generateAgoraToken(effectiveChannel, effectiveUid, role || 'publisher');

    return res.status(200).json({
      status: 200,
      statusCode: 200,
      success: true,
      message: 'Agora RTC token generated successfully',
      appId: AGORA_APP_ID,
      channelName: effectiveChannel,
      uid: effectiveUid,
      token: tokenData.token,
      expireTs: tokenData.expireTs,
      role: role || 'publisher',
      data: tokenData,
    });
  }

  return res.status(405).json({
    status: 405,
    statusCode: 405,
    success: false,
    message: 'Method not allowed',
    data: null,
  });
}
