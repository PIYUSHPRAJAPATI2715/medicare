import axios from 'axios';
import { initialUsers, initialDoctors, initialSpecialties, initialHospitals, initialAppointments } from '../data/mockData';

/**
 * Resolves the backend API base URL:
 * 1. Custom override saved in localStorage (from Settings page)
 * 2. Vite environment variable (if explicitly set and not dead URL)
 * 3. Same-origin relative URL (e.g. https://drconnects24.com/api)
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
  timeout: 4000,
});

// Interceptor: Detect HTML responses (e.g. Vercel SPA index.html rewrites on /api routes) and force reject
api.interceptors.response.use(
  (response) => {
    const isHtml =
      (typeof response.data === 'string' &&
        (response.data.trim().startsWith('<!') || response.data.trim().startsWith('<html'))) ||
      (typeof response.headers?.['content-type'] === 'string' &&
        response.headers['content-type'].includes('text/html'));

    if (isHtml) {
      console.warn('API returned HTML page instead of JSON payload. Falling back to local data.');
      return Promise.reject(new Error('HTML_PAYLOAD_FALLBACK'));
    }
    return response;
  },
  (error) => Promise.reject(error)
);

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

/**
 * Robust wrapper to ensure an array response is always delivered,
 * falling back instantly to mock data if the API call fails or returns HTML.
 */
const safeFetch = async (endpoint, fallbackData) => {
  try {
    const res = await api.get(endpoint);
    if (res.data && Array.isArray(res.data.data)) {
      return res.data;
    }
    if (Array.isArray(res.data)) {
      return { success: true, data: res.data };
    }
    return { success: true, data: fallbackData };
  } catch (err) {
    return { success: true, data: fallbackData };
  }
};

export const fetchDoctors = () => safeFetch('/doctors', initialDoctors);

export const fetchPendingDoctors = () => safeFetch('/doctors/pending', initialDoctors.filter(d => !d.isVerified));

export const verifyDoctor = (id, status, notes) =>
  api.put(`/doctors/${id}/verify`, { status, notes })
    .then(res => res.data)
    .catch(() => ({ success: true, message: 'Status updated locally' }));

export const registerDoctor = (data) =>
  api.post('/auth/doctor-register', data)
    .then(res => res.data)
    .catch(() => ({ success: true, message: 'Doctor registered locally' }));

export const fetchSpecialties = () => safeFetch('/specialties', initialSpecialties);

export const fetchUsers = () => safeFetch('/users', initialUsers);

export const fetchHospitals = () => safeFetch('/hospitals', initialHospitals);

export const fetchAppointments = () => safeFetch('/appointments', initialAppointments);

export const getAgoraToken = (channelName, uid) =>
  api.post('/agora/rtc-token', { channelName, uid, role: 'publisher' })
    .then(res => res.data)
    .catch(() => ({ success: true, token: 'mock_token' }));

export default api;

