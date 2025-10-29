<template>
  <div class="fixed inset-x-0 top-2 z-[100] flex flex-col items-center gap-2 pointer-events-none">
    <div v-for="t in toasts" :key="t.id" :class="['pointer-events-auto rounded-lg border px-4 py-2 shadow bg-white', t.type==='error'?'border-rose-200 text-rose-800 bg-rose-50': t.type==='success'?'border-emerald-200 text-emerald-800 bg-emerald-50':'border-slate-200 text-slate-800']">
      {{ t.message }}
    </div>
  </div>
</template>
<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { useUiStore } from '../stores/ui';
const ui = useUiStore();
const { toasts } = storeToRefs(ui);
</script>
