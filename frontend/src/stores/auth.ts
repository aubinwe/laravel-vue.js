import { defineStore } from 'pinia';
import api from '../lib/api';
import router from '../router';

export const useAuthStore = defineStore('auth', {
  state: () => ({ token: localStorage.getItem('token') as string|null, user: null as any, loading: false, error: '' }),
  getters: { isAuthenticated: (s) => !!s.token, isAdmin: (s)=>s.user?.role==='admin', isTeacher:(s)=>s.user?.role==='teacher' },
  actions: {
    setAuth(token: string, user: any) { this.token = token; this.user = user; localStorage.setItem('token', token); },
    clearAuth() { this.token = null; this.user = null; localStorage.removeItem('token'); },
    async login(email: string, password: string) {
      this.loading = true; this.error = '';
      try {
        const { data } = await api.post('/login', { email, password });
        this.setAuth(data.token, data.user);
        const role = data.user?.role;
        if (role === 'admin') router.push({ name: 'admin' });
        else if (role === 'teacher') router.push({ name: 'teacher' });
        else router.push({ name: 'student' });
        return true;
      } catch (e:any) {
        this.error = e.response?.data?.message || 'Erreur de connexion';
        return false;
      } finally { this.loading = false; }
    },
    async logout(silent=false) {
      try { await api.post('/logout'); } catch (_) {}
      this.clearAuth();
      if (!silent) router.replace({ name: 'login' }); else router.replace({ name: 'login' });
    },
    async me() {
      if (!this.token) return;
      try { const { data } = await api.get('/me'); this.user = data; } catch (_) {}
    }
  }
});
