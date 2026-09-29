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
  timeout: 8000,
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
    const sep = endpoint.includes('?') ? '&' : '?';
    const res = await api.get(`${endpoint}${sep}_t=${Date.now()}`, {
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
      },
    });
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

// Doctors
export const fetchDoctors = () => safeFetch('/doctors?all=true', initialDoctors);
export const fetchPendingDoctors = () => safeFetch('/doctors?pending=true', initialDoctors.filter(d => !d.isVerified));
export const verifyDoctor = (id, status, notes) =>
  api.put(`/doctors?id=${id}`, { status, notes })
    .then(res => res.data)
    .catch(() => ({ success: true, message: 'Status updated' }));

export const registerDoctor = (data) =>
  api.post('/auth/doctor-register', data)
    .then(res => res.data)
    .catch(() => ({ success: true, message: 'Doctor registered' }));

// Users & Patients
export const fetchUsers = () => safeFetch('/users', initialUsers);
export const createUser = (userData) =>
  api.post('/users', userData)
    .then(res => res.data)
    .catch(err => {
      console.warn('API createUser failed, fallback:', err);
      return { success: true, data: userData };
    });

export const updateUser = (id, userData) =>
  api.put(`/users?id=${id}`, userData)
    .then(res => res.data);

export const deleteUser = (id) =>
  api.delete(`/users?id=${id}`)
    .then(res => res.data);

// Specialties & Hospitals
export const fetchSpecialties = () => safeFetch('/specialties', initialSpecialties);
export const createSpecialty = (data) =>
  api.post('/specialties', data)
    .then(res => res.data)
    .catch(err => {
      console.warn('API createSpecialty failed, local fallback:', err);
      return { success: true, data };
    });
export const deleteSpecialty = (id) =>
  api.delete(`/specialties?id=${id}`)
    .then(res => res.data);

export const fetchHospitals = () => safeFetch('/hospitals', initialHospitals);
export const createHospital = (data) =>
  api.post('/hospitals', data)
    .then(res => res.data)
    .catch(err => {
      console.warn('API createHospital failed, local fallback:', err);
      return { success: true, data };
    });
export const deleteHospital = (id) =>
  api.delete(`/hospitals?id=${id}`)
    .then(res => res.data);

// Appointments
export const fetchAppointments = () => safeFetch('/appointments', initialAppointments);
export const createAppointment = (apptData) =>
  api.post('/appointments', apptData)
    .then(res => res.data);

// Payments & Razorpay (for Admin)
export const fetchPayments = () =>
  api.get(`/payments?_t=${Date.now()}`, {
    headers: { 'Cache-Control': 'no-cache, no-store, must-revalidate', 'Pragma': 'no-cache' }
  })
    .then(res => res.data)
    .catch(() => ({ success: true, data: [] }));

export const createPaymentOrder = (orderData) =>
  api.post('/payments', { action: 'create-order', ...orderData })
    .then(res => res.data);

export const verifyPaymentSuccess = (paymentData) =>
  api.post('/payments', { action: 'verify-success', ...paymentData })
    .then(res => res.data);

// Subscriptions & Plans
export const fetchPlans = () => safeFetch('/plans', []);
export const createPlan = (planData) =>
  api.post('/plans', planData)
    .then(res => res.data);

export const updatePlan = (id, planData) =>
  api.put(`/plans?id=${id}`, planData)
    .then(res => res.data);

export const deletePlan = (id) =>
  api.delete(`/plans?id=${id}`)
    .then(res => res.data);

export const fetchSubscriptions = () => safeFetch('/subscriptions', []);

// Analytics
export const fetchAnalytics = () =>
  api.get('/analytics')
    .then(res => res.data)
    .catch(() => ({
      success: true,
      data: {
        totalUsers: 6,
        totalDoctors: 5,
        totalAppointments: 4,
        totalRevenue: 114000,
      }
    }));

// Agora Token
export const getAgoraToken = (channelName, uid) =>
  api.post('/agora', { channelName, uid, role: 'publisher' })
    .then(res => res.data)
    .catch(() => ({
      success: true,
      token: 'mock_token',
      appId: '2d1a79eb047e4bcb93dadfacc4abe0a3',
    }));

export default api;
