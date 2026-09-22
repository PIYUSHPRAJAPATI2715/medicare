import axios from 'axios';

// Detect whether running in production on Render or locally
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5050/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const fetchDoctors = () => api.get('/doctors').then(res => res.data);
export const fetchPendingDoctors = () => api.get('/doctors/pending').then(res => res.data);
export const verifyDoctor = (id, status, notes) => api.put(`/doctors/${id}/verify`, { status, notes }).then(res => res.data);
export const registerDoctor = (data) => api.post('/auth/doctor-register', data).then(res => res.data);

export const fetchSpecialties = () => api.get('/specialties').then(res => res.data);
export const fetchUsers = () => api.get('/users').then(res => res.data);
export const fetchHospitals = () => api.get('/hospitals').then(res => res.data);
export const fetchAppointments = () => api.get('/appointments').then(res => res.data);
export const getAgoraToken = (channelName, uid) => api.post('/agora/rtc-token', { channelName, uid, role: 'publisher' }).then(res => res.data);

export default api;
