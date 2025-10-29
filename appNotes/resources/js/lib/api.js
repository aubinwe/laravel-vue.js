import axios from 'axios';
import { useAuthStore } from '../stores/auth';

const apiBase = import.meta.env?.VITE_API_URL || '/api/v1';
const api = axios.create({ baseURL: apiBase });

api.interceptors.request.use((config) => {
  try {
    const auth = useAuthStore();
    if (auth.token) config.headers.Authorization = `Bearer ${auth.token}`;
  } catch (_) {}
  return config;
});

api.interceptors.response.use(
  (res) => res,
  (err) => {
    try {
      const auth = useAuthStore();
      if (err.response?.status === 401) {
        auth.logout();
        window.location.href = '/login';
      }
    } catch (_) {}
    return Promise.reject(err);
  }
);

export default api;
