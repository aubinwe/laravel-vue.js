import axios from 'axios';
import { useAuthStore } from '../stores/auth';
import { useUiStore } from '../stores/ui';

const baseURL = import.meta.env.VITE_API_URL || '/api/v1';
const api = axios.create({ baseURL });

api.interceptors.request.use((config) => {
  try {
    const auth = useAuthStore();
    if (auth.token) config.headers.Authorization = `Bearer ${auth.token}`;
  } catch (_) {}
  return config;
});

api.interceptors.response.use(
  (r) => r,
  (e) => {
    try {
      const ui = useUiStore();
      const msg = e.response?.data?.message || e.message || 'Erreur serveur';
      ui.error(msg);
    } catch (_) {}
    if (e.response?.status === 401) {
      try {
        const auth = useAuthStore();
        auth.logout(true);
      } catch (_) {}
    }
    return Promise.reject(e);
  }
);

export default api;
