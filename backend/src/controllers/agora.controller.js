// Agora RTC & RTM Token Controller for MediCare+ Video Consultation & Chat

const AGORA_APP_ID = process.env.AGORA_APP_ID || 'medicare_agora_app_id_demo_2026';
const AGORA_APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || 'medicare_agora_cert_demo_2026';

exports.getAgoraConfig = (req, res) => {
  res.json({
    success: true,
    appId: AGORA_APP_ID,
    isDemo: true,
    message: 'Agora SDK credentials generated for video consultation',
  });
};

exports.generateRtcToken = (req, res) => {
  const { channelName, uid, role } = req.body;
  const channel = channelName || `medicare_room_${Date.now()}`;
  const userId = uid || Math.floor(Math.random() * 10000);

  // In demo / staging environment, return valid token payload structure
  const expireSeconds = 3600 * 24; // 24 hours
  const privilegeExpiredTs = Math.floor(Date.now() / 1000) + expireSeconds;
  
  // Dummy valid RTC token string for local/testing environment
  const rtcToken = `007eJxTYGDiFpI48/T8/u3vV/F232w+/Onj+Z5/lze/W7+z62rF1R+/zxRlMTA0S0xNNEwzSDJNSjRITbNIMktOSk5ONrBIMkg0TTZNS0xNMQACBgZ2BgaGhhZmBhbGBiZmRkYGBmZGEQCbhyF1`;

  res.json({
    success: true,
    appId: AGORA_APP_ID,
    channelName: channel,
    uid: userId,
    token: rtcToken,
    expireTs: privilegeExpiredTs,
    role: role || 'publisher',
  });
};

exports.generateRtmToken = (req, res) => {
  const { userId } = req.body;
  const uid = userId || `user_${Math.floor(Math.random() * 1000)}`;

  const rtmToken = `007eJxTYEjy8/m++u2/5wfv/l+/s+tqxdUfv88UZTEwNEtMTTRMM0gyTUo0SE2zSDJLTkpOTjawSDJIMk02TUtMTTEAAgYGdgYGhoYWZgYWxgYmZkZGBgZmRhEAhLghaw==`;

  res.json({
    success: true,
    appId: AGORA_APP_ID,
    userId: uid,
    rtmToken: rtmToken,
  });
};
