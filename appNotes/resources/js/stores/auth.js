import { defineStore } from 'pinia';
import axios from 'axios';

const api = axios.create({
  baseURL: '/api/v1',
});

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token') || null,
    loading: false,
    error: null,
  }),
  getters: {
    isAuthenticated: (s) => !!s.token,
    isAdmin: (s) => s.user?.role === 'admin',
    isTeacher: (s) => s.user?.role === 'teacher',
  },
  actions: {
    setAuth(token, user) {
      this.token = token;
      this.user = user;
      localStorage.setItem('token', token);
    },
    clearAuth() {
      this.token = null;
      this.user = null;
      localStorage.removeItem('token');
    },
    async login(email, password) {
      this.loading = true; this.error = null;
      try {
        const { data } = await api.post('/login', { email, password });
        this.setAuth(data.token, data.user);
        return true;
      } catch (e) {
        this.error = e.response?.data?.message || 'Erreur de connexion';
        return false;
      } finally { this.loading = false; }
    },
    async register(payload) {
      this.loading = true; this.error = null;
      try {
        await api.post('/register', payload);
        return true;
      } catch (e) {
        this.error = e.response?.data?.message || 'Erreur inscription';
        return false;
      } finally { this.loading = false; }
    },
    async logout() {
      try {
        await api.post('/logout', {}, { headers: { Authorization: `Bearer ${this.token}` } });
      } catch (_) {}
      this.clearAuth();
      // Redirect to login after logout
      try { window.location.href = '/login'; } catch (_) {}
    },
  },
});
