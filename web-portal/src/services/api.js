import axios from 'axios';

/**
 * Resolves the backend API base URL:
 * 1. User-configured override saved in localStorage (from Settings page)
 * 2. Vite environment variable passed at build time (VITE_API_URL)
 * 3. Smart Production Auto-Detection:
 *    If running in a browser on any domain other than localhost/127.0.0.1 (e.g. Render, Vercel, drconnects24.com),
 *    never connect to the visitor's localhost. Connect to the deployed Render backend API.
 * 4. Local fallback for local development on localhost:5050.
 */
export const getApiBaseUrl = () => {
  // 1. Check custom override from Admin Settings
  if (typeof window !== 'undefined') {
    const customUrl = localStorage.getItem('drconnects24_api_url');
    if (customUrl && customUrl.trim()) {
      return customUrl.trim();
    }
  }

  // 2. Check Vite environment variable
  const envUrl = import.meta.env.VITE_API_URL;
  if (envUrl && typeof window !== 'undefined') {
    const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    if (!envUrl.includes('localhost') || isLocal) {
      return envUrl;
    }
  }

  // 3. Smart production fallback for live deployed domains
  if (typeof window !== 'undefined') {
    const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    if (!isLocal) {
      return 'https://medicare-backend-api.onrender.com/api';
    }
  }

  // 4. Default for local development
  return 'http://localhost:5050/api';
};

export const API_BASE_URL = getApiBaseUrl();

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 15000,
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
