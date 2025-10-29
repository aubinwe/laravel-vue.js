import { defineStore } from 'pinia';

let nextId = 1;

export const useUiStore = defineStore('ui', {
  state: () => ({
    toasts: [] as Array<{ id:number; type:'info'|'success'|'error'; message:string }>,
  }),
  actions: {
    toast(message: string, type: 'info'|'success'|'error'='info', ms=3500) {
      const id = nextId++;
      this.toasts.push({ id, type, message });
      setTimeout(() => { this.toasts = this.toasts.filter(t => t.id !== id); }, ms);
    },
    success(msg:string){ this.toast(msg,'success'); },
    error(msg:string){ this.toast(msg,'error',5000); },
    info(msg:string){ this.toast(msg,'info'); },
  }
});
