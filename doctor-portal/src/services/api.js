const API_BASE = 'http://localhost:5050/api';

export async function fetchApi(endpoint, options = {}) {
  try {
    const res = await fetch(`${API_BASE}${endpoint}`, {
      headers: { 'Content-Type': 'application/json', ...options.headers },
      ...options,
    });
    return await res.json();
  } catch (err) {
    console.error(`API Fetch Error [${endpoint}]:`, err);
    return { success: false, message: err.message };
  }
}

export const doctorApiService = {
  getDoctorProfile: (id = 'd1') => fetchApi('/doctors').then(res => ({
    success: true,
    data: res.data?.find(d => d.id === id) || res.data?.[0],
  })),

  updateDoctorStatus: (id, isOnline) => fetchApi(`/doctors/${id}`, {
    method: 'PUT',
    body: JSON.stringify({ isOnline }),
  }),

  getDoctorAppointments: (doctorId = 'd1') => fetchApi('/appointments').then(res => ({
    success: true,
    data: res.data?.filter(a => a.doctorId === doctorId || a.doctor?.id === doctorId) || [],
  })),

  updateAppointmentStatus: (id, status, prescription) => fetchApi(`/appointments/${id}`, {
    method: 'PUT',
    body: JSON.stringify({ status, prescription }),
  }),

  generateAgoraRtcToken: (channelName, uid) => fetchApi('/agora/rtc-token', {
    method: 'POST',
    body: JSON.stringify({ channelName, uid, role: 'publisher' }),
  }),

  getChats: (appointmentId) => fetchApi(`/chats?appointmentId=${appointmentId}`),
  sendChatMessage: (data) => fetchApi('/chats', { method: 'POST', body: JSON.stringify(data) }),
};
