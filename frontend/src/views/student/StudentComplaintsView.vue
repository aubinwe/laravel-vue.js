<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-xl font-semibold text-slate-800">Mes réclamations</h1>
      <p class="text-slate-500 text-sm">Soumettre une nouvelle réclamation et consulter l'historique</p>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="font-medium mb-3">Nouvelle réclamation</div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-3 items-start">
        <div>
          <label class="block text-sm text-slate-600 mb-1">Note concernée</label>
          <select v-model.number="form.grade_id" class="w-full rounded-md border px-3 py-2 text-sm">
            <option :value="0" disabled>Choisir une note</option>
            <option v-for="g in grades" :key="g.id" :value="g.id">
              {{ g.subject?.name }} — {{ Number(g.score).toFixed(2) }}/20
            </option>
          </select>
        </div>
        <div class="md:col-span-2">
          <label class="block text-sm text-slate-600 mb-1">Message</label>
          <textarea v-model="form.message" rows="3" class="w-full rounded-md border px-3 py-2 text-sm" placeholder="Expliquez votre réclamation..."></textarea>
        </div>
      </div>
      <div class="mt-3">
        <button class="rounded-md bg-slate-900 px-3 py-2 text-sm text-white hover:bg-slate-800" :disabled="submitting" @click="submit">
          {{ submitting ? 'Envoi...' : 'Soumettre' }}
        </button>
      </div>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="flex items-center justify-between mb-3">
        <div class="font-medium">Historique des réclamations</div>
        <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="loadComplaints">Actualiser</button>
      </div>
      <div v-if="loadingC" class="p-6 text-center text-slate-500">Chargement…</div>
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Matière</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Note</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Message</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Statut</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Date</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-200 bg-white">
            <tr v-for="c in complaints" :key="c.id">
              <td class="px-4 py-2">{{ c.grade?.subject?.name }}</td>
              <td class="px-4 py-2">{{ Number(c.grade?.score ?? 0).toFixed(2) }}</td>
              <td class="px-4 py-2 max-w-[360px]">{{ c.message }}</td>
              <td class="px-4 py-2">
                <span :class="badgeClass(c.status)">{{ c.status }}</span>
              </td>
              <td class="px-4 py-2">{{ new Date(c.created_at).toLocaleString() }}</td>
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

const grades = ref<any[]>([]);
const complaints = ref<any[]>([]);
const loadingC = ref(false);
const submitting = ref(false);
const form = ref<{grade_id:number,message:string}>({ grade_id: 0, message: '' });

const badgeClass = (s:string) => s === 'resolved' ? 'px-2 py-0.5 text-xs rounded-full bg-emerald-100 text-emerald-700' : s === 'rejected' ? 'px-2 py-0.5 text-xs rounded-full bg-rose-100 text-rose-700' : 'px-2 py-0.5 text-xs rounded-full bg-amber-100 text-amber-700';

const loadGrades = async () => { const r = await api.get('/grades'); grades.value = r.data.data || r.data; };

const loadComplaints = async () => {
  loadingC.value = true;
  try {
    const r = await api.get('/complaints');
    complaints.value = r.data.data || r.data;
  } finally { loadingC.value = false; }
};

const submit = async () => {
  if (!form.value.grade_id || !form.value.message.trim()) return ui.error('Veuillez sélectionner une note et saisir un message.');
  submitting.value = true;
  try {
    await api.post('/complaints', { grade_id: form.value.grade_id, message: form.value.message });
    ui.success('Réclamation envoyée');
    form.value = { grade_id: 0, message: '' };
    await loadComplaints();
  } finally { submitting.value = false; }
};

onMounted(async () => { await loadGrades(); await loadComplaints(); });
</script>
