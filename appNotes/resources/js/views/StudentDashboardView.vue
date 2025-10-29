<template>
  <div class="space-y-6">
    <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
      <div>
        <h1 class="text-xl font-semibold text-slate-800">Espace Étudiant</h1>
        <p class="text-slate-500 text-sm">Consultez votre moyenne et vos dernières notes</p>
      </div>
      <div class="flex items-center gap-3">
        <button @click="downloadBulletin" class="inline-flex items-center rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-800">
          <i class="bi bi-download me-2"></i> Télécharger mon bulletin
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-1">
        <div class="rounded-xl border bg-white p-4">
          <div class="text-sm text-slate-500">Moyenne générale</div>
          <div class="mt-2 text-4xl font-semibold tracking-tight" v-if="avg !== null">{{ avg.toFixed(2) }}</div>
          <div v-else class="mt-2 text-slate-400">Indisponible</div>
          <div class="mt-4 grid grid-cols-2 gap-3 text-sm">
            <div>
              <div class="text-slate-500">Nom</div>
              <div class="font-medium">{{ profile?.last_name }} {{ profile?.first_name }}</div>
            </div>
            <div>
              <div class="text-slate-500">Matricule</div>
              <div class="font-medium">{{ profile?.matricule || '-' }}</div>
            </div>
            <div>
              <div class="text-slate-500">Email</div>
              <div class="font-medium break-all">{{ profile?.email }}</div>
            </div>
            <div>
              <div class="text-slate-500">Filière</div>
              <div class="font-medium">{{ profile?.filiere || '-' }}</div>
            </div>
          </div>
        </div>
      </div>
      <div class="lg:col-span-2">
        <div class="rounded-xl border bg-white">
          <div class="flex items-center justify-between px-4 py-3 border-b">
            <div class="font-medium">Mes notes par matière</div>
            <button @click="load" class="inline-flex items-center rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50">
              <i class="bi bi-arrow-clockwise me-1"></i> Actualiser
            </button>
          </div>
          <div v-if="loading" class="p-8 text-center text-slate-500">Chargement…</div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full divide-y divide-slate-200">
              <thead class="bg-slate-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-slate-600">Matière</th>
                <th class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-slate-600">Coef.</th>
                <th class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-slate-600">Note /20</th>
                <th class="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-slate-600">Date</th>
                <th class="px-4 py-3"></th>
              </tr>
              </thead>
              <tbody class="divide-y divide-slate-200 bg-white">
              <tr v-for="g in grades" :key="g.id">
                <td class="px-4 py-3">{{ g.subject?.name }}</td>
                <td class="px-4 py-3">{{ g.subject?.coefficient }}</td>
                <td class="px-4 py-3">{{ Number(g.score).toFixed(2) }}</td>
                <td class="px-4 py-3">{{ new Date(g.created_at).toLocaleString() }}</td>
                <td class="px-4 py-3 text-right">
                  <router-link class="inline-flex items-center rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" :to="{ name: 'complaints', query: { grade_id: g.id, subject: g.subject?.name } }">Réclamer</router-link>
                </td>
              </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import api from '../lib/api';

const auth = useAuthStore();
const { token } = storeToRefs(auth);

const profile = ref(null);
const grades = ref([]);
const loading = ref(false);
const avg = ref(null);

const load = async () => {
  loading.value = true;
  try {
    const [p, g, a] = await Promise.all([
      api.get('/student/profile'),
      api.get('/grades'),
      api.get('/grades/average'),
    ]);
    profile.value = p.data;
    grades.value = g.data.data || g.data;
    avg.value = a.data.average ?? null;
  } finally { loading.value = false; }
};

const downloadBulletin = () => {
  const url = '/api/v1/student/bulletin';
  window.open(url, '_blank');
};

onMounted(load);
</script>
