import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000';

const client = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor: attach Bearer token to every request if available
client.interceptors.request.use((config) => {
  const token = localStorage.getItem('saferide_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const api = {
  // Stats (public for admin dashboard)
  getStats: async () => {
    try {
      const res = await client.get('/stats');
      return res.data;
    } catch (error) {
      console.error('API Error (getStats):', error);
      throw error;
    }
  },

  getLogs: async () => {
    const res = await client.get('/logs');
    return res.data;
  },

  // Auth
  register: async (data) => {
    const res = await client.post('/auth/register', data);
    if (res.data.access_token) {
      localStorage.setItem('saferide_token', res.data.access_token);
    }
    return res.data;
  },

  login: async (email, password) => {
    const res = await client.post('/auth/login', { email, password });
    if (res.data.access_token) {
      localStorage.setItem('saferide_token', res.data.access_token);
    }
    return res.data;
  },

  logout: () => {
    localStorage.removeItem('saferide_token');
  },

  getToken: () => localStorage.getItem('saferide_token'),

  // Users
  getUsers: async () => {
    const res = await client.get('/users');
    return res.data;
  },

  verifyUser: async (id) => {
    const res = await client.patch(`/users/${id}/verify`);
    return res.data;
  },

  setWomenSafe: async (id, value) => {
    const res = await client.patch(`/users/${id}/women-safe`, { value });
    return res.data;
  },

  // Rides
  getRides: async () => {
    const res = await client.get('/rides/active');
    return res.data;
  },

  createRide: async (data) => {
    const res = await client.post('/rides', data);
    return res.data;
  },

  updateRideStatus: async (id, status, driverId) => {
    const res = await client.patch(`/rides/${id}/status`, { status, driverId });
    return res.data;
  },
};
