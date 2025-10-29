<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-xl font-semibold text-slate-800">Mes notes</h1>
      <p class="text-slate-500 text-sm">Filtrer par matière et consulter mes résultats</p>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
        <div>
          <label class="block text-sm text-slate-600 mb-1">Matière</label>
          <select v-model.number="filters.subject_id" class="w-full rounded-md border px-3 py-2 text-sm">
            <option :value="0">Toutes</option>
            <option v-for="s in subjects" :key="s.id" :value="s.id">{{ s.name }}</option>
          </select>
        </div>
        <div>
          <button class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50" @click="load">Filtrer</button>
        </div>
        <div class="md:col-span-2 text-sm text-slate-600" v-if="avg !== null">
          Moyenne pondérée: <span class="font-semibold">{{ avg.toFixed(2) }}</span>
        </div>
      </div>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="flex items-center justify-between mb-3">
        <div class="font-medium">Mes notes</div>
        <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="load">Actualiser</button>
      </div>
      <div v-if="loading" class="p-6 text-center text-slate-500">Chargement…</div>
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Matière</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Coef.</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Note</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Date</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-200 bg-white">
            <tr v-for="g in grades" :key="g.id">
              <td class="px-4 py-2">{{ g.subject?.name }}</td>
              <td class="px-4 py-2">{{ g.subject?.coefficient }}</td>
              <td class="px-4 py-2">{{ Number(g.score).toFixed(2) }}</td>
              <td class="px-4 py-2">{{ new Date(g.created_at).toLocaleString() }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import api from '../../lib/api';

const loading = ref(false);
const grades = ref<any[]>([]);
const subjects = ref<any[]>([]);
const filters = ref<{subject_id:number}>({ subject_id: 0 });
const avg = ref<number|null>(null);

const loadSubjects = async () => { const r = await api.get('/admin/subjects'); subjects.value = r.data.data || r.data; };

const load = async () => {
  loading.value = true;
  try {
    const params:any = {};
    if (filters.value.subject_id) params.subject_id = filters.value.subject_id;
    const r = await api.get('/grades', { params });
    grades.value = r.data.data || r.data;
    const a = await api.get('/grades/average');
    avg.value = a.data?.average ?? null;
  } finally { loading.value = false; }
};

onMounted(async () => { await loadSubjects(); await load(); });
</script>
