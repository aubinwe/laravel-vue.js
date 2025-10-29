import { defineStore } from 'pinia';

export const useUiStore = defineStore('ui', {
  state: () => ({ toasts: [] }),
  actions: {
    notify(message, variant = 'info', timeout = 3500) {
      const id = Date.now() + Math.random();
      this.toasts.push({ id, message, variant });
      setTimeout(() => this.dismiss(id), timeout);
    },
    success(msg) { this.notify(msg, 'success'); },
    error(msg) { this.notify(msg, 'error', 6000); },
    dismiss(id) { this.toasts = this.toasts.filter(t => t.id !== id); },
  },
});
