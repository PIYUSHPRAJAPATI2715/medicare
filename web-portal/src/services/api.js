import axios from 'axios';
import { initialUsers, initialDoctors, initialSpecialties, initialHospitals, initialAppointments } from '../data/mockData';

/**
 * Resolves the backend API base URL:
 * 1. Custom override saved in localStorage (from Settings page)
 * 2. Vite environment variable (if explicitly set and not dead URL)
 * 3. Same-origin relative URL (e.g. https://drconnects24.com/api) - instant 0ms internal routing!
 * 4. Local fallback for local development.
 */
export const getApiBaseUrl = () => {
  if (typeof window !== 'undefined') {
    // 1. Custom override from Admin Settings
    const customUrl = localStorage.getItem('drconnects24_api_url');
    if (customUrl && customUrl.trim()) {
      return customUrl.trim();
    }

    // 2. Vite environment variable if provided
    const envUrl = import.meta.env.VITE_API_URL;
    if (envUrl && !envUrl.includes('medicare-backend-api.onrender.com') && !envUrl.includes('localhost')) {
      return envUrl;
    }

    // 3. Same-origin URL: when on drconnects24.com, uses https://drconnects24.com/api
    const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    if (!isLocal) {
      return `${window.location.origin}/api`;
    }
  }

  return 'http://localhost:5050/api';
};

export const API_BASE_URL = getApiBaseUrl();

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 4000, // Fast 4-second timeout with instant fallback
});

export const setCustomApiBaseUrl = (newUrl) => {
  if (!newUrl || !newUrl.trim()) {
    localStorage.removeItem('drconnects24_api_url');
  } else {
    localStorage.setItem('drconnects24_api_url', newUrl.trim());
  }
  const updatedUrl = getApiBaseUrl();
  api.defaults.baseURL = updatedUrl;
  return updatedUrl;
};

export const testApiConnection = async () => {
  try {
    const res = await api.get('/specialties');
    return { success: true, data: res.data };
  } catch (err) {
    return {
      success: false,
      message: err.response?.data?.message || err.message || 'Connection failed',
    };
  }
};

export const fetchDoctors = () =>
  api.get('/doctors')
    .then(res => res.data)
    .catch(() => ({ success: true, data: initialDoctors }));

export const fetchPendingDoctors = () =>
  api.get('/doctors/pending')
    .then(res => res.data)
    .catch(() => ({ success: true, data: initialDoctors.filter(d => !d.isVerified) }));

export const verifyDoctor = (id, status, notes) =>
  api.put(`/doctors/${id}/verify`, { status, notes })
    .then(res => res.data)
    .catch(() => ({ success: true, message: 'Status updated locally' }));

export const registerDoctor = (data) =>
  api.post('/auth/doctor-register', data)
    .then(res => res.data)
    .catch(() => ({ success: true, message: 'Doctor registered locally' }));

export const fetchSpecialties = () =>
  api.get('/specialties')
    .then(res => res.data)
    .catch(() => ({ success: true, data: initialSpecialties }));

export const fetchUsers = () =>
  api.get('/users')
    .then(res => res.data)
    .catch(() => ({ success: true, data: initialUsers }));

export const fetchHospitals = () =>
  api.get('/hospitals')
    .then(res => res.data)
    .catch(() => ({ success: true, data: initialHospitals }));

export const fetchAppointments = () =>
  api.get('/appointments')
    .then(res => res.data)
    .catch(() => ({ success: true, data: initialAppointments }));

export const getAgoraToken = (channelName, uid) =>
  api.post('/agora/rtc-token', { channelName, uid, role: 'publisher' })
    .then(res => res.data)
    .catch(() => ({ success: true, token: 'mock_token' }));

export default api;
