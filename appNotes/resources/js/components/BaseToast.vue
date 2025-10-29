<template>
  <div class="fixed inset-0 z-[100] pointer-events-none flex flex-col items-end gap-2 p-4">
    <transition-group name="toast">
      <div v-for="t in toasts" :key="t.id"
           class="pointer-events-auto w-full max-w-sm rounded-lg border p-3 shadow-lg"
           :class="variantClass(t.variant)">
        <div class="flex items-start gap-2">
          <span class="mt-0.5" :class="iconClass(t.variant)"></span>
          <div class="flex-1 text-sm">{{ t.message }}</div>
          <button class="text-slate-600 hover:text-slate-900" @click="dismiss(t.id)"><i class="bi bi-x"></i></button>
        </div>
      </div>
    </transition-group>
  </div>
</template>
<script setup>
import { storeToRefs } from 'pinia';
import { useUiStore } from '../stores/ui';

const ui = useUiStore();
const { toasts } = storeToRefs(ui);
const dismiss = (id) => ui.dismiss(id);

const variantClass = (v) => ({
  success: 'bg-emerald-50 border-emerald-200',
  error: 'bg-rose-50 border-rose-200',
  info: 'bg-slate-50 border-slate-200',
}[v] || 'bg-slate-50 border-slate-200');

const iconClass = (v) => ({
  success: 'bi bi-check-circle text-emerald-600',
  error: 'bi bi-exclamation-triangle text-rose-600',
  info: 'bi bi-info-circle text-slate-600',
}[v] || 'bi bi-info-circle text-slate-600');
</script>
<style>
.toast-enter-active, .toast-leave-active { transition: all .2s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateY(6px); }
</style>
