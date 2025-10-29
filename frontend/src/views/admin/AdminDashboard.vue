<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-xl font-semibold text-slate-800">Espace Admin</h1>
      <p class="text-slate-500 text-sm">Aperçu global et actions rapides</p>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="rounded-xl border bg-white p-4"><div class="text-xs text-slate-500">Étudiants</div><div class="text-2xl font-semibold">{{ summary.students ?? '-' }}</div></div>
      <div class="rounded-xl border bg-white p-4"><div class="text-xs text-slate-500">Réclamations ouvertes</div><div class="text-2xl font-semibold">{{ summary.open_complaints ?? '-' }}</div></div>
      <div class="rounded-xl border bg-white p-4"><div class="text-xs text-slate-500">Moyenne globale</div><div class="text-2xl font-semibold">{{ summary.global_average ?? '-' }}</div></div>
      <div class="rounded-xl border bg-white p-4"><div class="text-xs text-slate-500">Matières</div><div class="text-2xl font-semibold">—</div></div>
    </div>
    <div class="rounded-xl border bg-white p-4">
      <div class="flex items-center justify-between">
        <div class="font-medium">Actions rapides</div>
        <div class="flex gap-2">
          <router-link class="inline-flex items-center rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" to="/admin/students">Étudiants</router-link>
          <router-link class="inline-flex items-center rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" to="/admin/subjects">Matières</router-link>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import api from '../../lib/api';

const summary = ref<any>({});
const load = async () => { const r = await api.get('/admin/dashboard'); summary.value = r.data; };
onMounted(load);
</script>
