<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-xl font-semibold text-slate-800">Espace Professeur</h1>
      <p class="text-slate-500 text-sm">Réclamations en attente et notes récentes</p>
    </div>
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="rounded-xl border bg-white">
        <div class="px-4 py-3 border-b font-medium">Réclamations (en attente)</div>
        <div v-if="loadingC" class="p-6 text-center text-slate-500">Chargement…</div>
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-slate-200">
            <thead class="bg-slate-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-slate-600 uppercase">Matière</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-slate-600 uppercase">Étudiant</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-slate-600 uppercase">Statut</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200 bg-white">
              <tr v-for="c in complaints" :key="c.id">
                <td class="px-4 py-3">{{ c.grade?.subject?.name }}</td>
                <td class="px-4 py-3">{{ c.user?.name }}</td>
                <td class="px-4 py-3"><span class="px-2 py-0.5 text-xs rounded-full bg-amber-100 text-amber-700">{{ c.status }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="rounded-xl border bg-white">
        <div class="px-4 py-3 border-b font-medium">Dernières notes</div>
        <div v-if="loadingG" class="p-6 text-center text-slate-500">Chargement…</div>
        <div v-else class="overflow-x-auto">
          <table class="min-w-full divide-y divide-slate-200">
            <thead class="bg-slate-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-slate-600 uppercase">Matière</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-slate-600 uppercase">Étudiant</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-slate-600 uppercase">Note</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200 bg-white">
              <tr v-for="g in grades" :key="g.id">
                <td class="px-4 py-3">{{ g.subject?.name }}</td>
                <td class="px-4 py-3">{{ g.user?.name }}</td>
                <td class="px-4 py-3">{{ Number(g.score).toFixed(2) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import api from '../../lib/api';

const complaints = ref<any[]>([]);
const grades = ref<any[]>([]);
const loadingC = ref(false);
const loadingG = ref(false);

const loadComplaints = async () => { loadingC.value=true; try { const r = await api.get('/teacher/complaints'); complaints.value = r.data.data || r.data; } finally { loadingC.value=false; } };
const loadGrades = async () => { loadingG.value=true; try { const r = await api.get('/teacher/grades'); grades.value = r.data.data || r.data; } finally { loadingG.value=false; } };

onMounted(async () => { await Promise.all([loadComplaints(), loadGrades()]); });
</script>
