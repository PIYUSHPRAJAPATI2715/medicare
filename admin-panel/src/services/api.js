const getApiBase = () => {
  if (typeof window !== 'undefined' && window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1') {
    return 'https://medicare-backend-api.onrender.com/api';
  }
  return import.meta.env?.VITE_API_URL || 'http://localhost:5050/api';
};

const API_BASE = getApiBase();

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

export const apiService = {
  getAnalytics: () => fetchApi('/analytics'),

  getUsers: () => fetchApi('/users'),
  createUser: (data) => fetchApi('/users', { method: 'POST', body: JSON.stringify(data) }),
  updateUser: (id, data) => fetchApi(`/users/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  deleteUser: (id) => fetchApi(`/users/${id}`, { method: 'DELETE' }),

  getDoctors: (all = true) => fetchApi(`/doctors?all=${all}`),
  getPendingDoctors: () => fetchApi('/doctors/pending'),
  verifyDoctor: (id, action, rejectionNotes) => fetchApi(`/doctors/${id}/verify`, {
    method: 'PUT',
    body: JSON.stringify({ action, rejectionNotes }),
  }),
  createDoctor: (data) => fetchApi('/doctors', { method: 'POST', body: JSON.stringify(data) }),
  registerDoctor: (data) => fetchApi('/auth/doctor-register', { method: 'POST', body: JSON.stringify(data) }),
  updateDoctor: (id, data) => fetchApi(`/doctors/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  deleteDoctor: (id) => fetchApi(`/doctors/${id}`, { method: 'DELETE' }),

  getSpecialties: () => fetchApi('/specialties'),
  createSpecialty: (data) => fetchApi('/specialties', { method: 'POST', body: JSON.stringify(data) }),
  updateSpecialty: (id, data) => fetchApi(`/specialties/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  deleteSpecialty: (id) => fetchApi(`/specialties/${id}`, { method: 'DELETE' }),

  getHospitals: () => fetchApi('/hospitals'),
  createHospital: (data) => fetchApi('/hospitals', { method: 'POST', body: JSON.stringify(data) }),
  updateHospital: (id, data) => fetchApi(`/hospitals/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
  deleteHospital: (id) => fetchApi(`/hospitals/${id}`, { method: 'DELETE' }),

  getAppointments: () => fetchApi('/appointments'),
  updateAppointment: (id, data) => fetchApi(`/appointments/${id}`, { method: 'PUT', body: JSON.stringify(data) }),

  getSettings: () => fetchApi('/settings'),
  updateSettings: (data) => fetchApi('/settings', { method: 'PUT', body: JSON.stringify(data) }),
  addCoupon: (data) => fetchApi('/coupons', { method: 'POST', body: JSON.stringify(data) }),
  deleteCoupon: (code) => fetchApi(`/coupons/${code}`, { method: 'DELETE' }),

  getAgoraConfig: () => fetchApi('/agora/config'),
  generateRtcToken: (data) => fetchApi('/agora/rtc-token', { method: 'POST', body: JSON.stringify(data) }),
};
