<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-xl font-semibold text-slate-800">Réclamations (Professeur)</h1>
      <p class="text-slate-500 text-sm">Filtrer par statut et mettre à jour</p>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
        <div>
          <label class="block text-sm text-slate-600 mb-1">Statut</label>
          <select v-model="filters.status" class="w-full rounded-md border px-3 py-2 text-sm">
            <option value="">Tous</option>
            <option value="pending">En attente</option>
            <option value="resolved">Résolue</option>
            <option value="rejected">Rejetée</option>
          </select>
        </div>
        <div>
          <button class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50" @click="load">Filtrer</button>
        </div>
        <div class="md:col-span-2"></div>
      </div>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="flex items-center justify-between mb-3">
        <div class="font-medium">Liste des réclamations</div>
        <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="load">Actualiser</button>
      </div>
      <div v-if="loading" class="p-6 text-center text-slate-500">Chargement…</div>
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Étudiant</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Matière</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Note</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Message</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Statut</th>
              <th class="px-4 py-2"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-200 bg-white">
            <tr v-for="c in complaints" :key="c.id">
              <td class="px-4 py-2">{{ c.user?.name || c.student?.user?.name }}</td>
              <td class="px-4 py-2">{{ c.grade?.subject?.name }}</td>
              <td class="px-4 py-2">{{ Number(c.grade?.score ?? 0).toFixed(2) }}</td>
              <td class="px-4 py-2 max-w-[360px]">{{ c.message }}</td>
              <td class="px-4 py-2">
                <select v-model="c._status" class="rounded-md border px-3 py-1.5 text-sm">
                  <option value="pending">En attente</option>
                  <option value="resolved">Résolue</option>
                  <option value="rejected">Rejetée</option>
                </select>
              </td>
              <td class="px-4 py-2 text-right">
                <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="updateStatus(c)">Enregistrer</button>
              </td>
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
import { useUiStore } from '../../stores/ui';

const ui = useUiStore();

const complaints = ref<any[]>([]);
const loading = ref(false);
const filters = ref<{status:string|''}>({ status: '' });

const load = async () => {
  loading.value = true;
  try {
    const params:any = {};
    if (filters.value.status) params.status = filters.value.status;
    const r = await api.get('/teacher/complaints', { params });
    const arr = r.data.data || r.data;
    complaints.value = arr.map((c:any) => ({ ...c, _status: c.status }));
  } finally { loading.value = false; }
};

const updateStatus = async (c:any) => {
  await api.put(`/teacher/complaints/${c.id}`, { status: c._status });
  ui.success('Statut mis à jour');
};

onMounted(load);
</script>
