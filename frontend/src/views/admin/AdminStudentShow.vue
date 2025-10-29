<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-xl font-semibold text-slate-800">Fiche étudiant</h1>
        <p class="text-slate-500 text-sm">Informations et dernières notes</p>
      </div>
      <div class="flex gap-2">
        <a :href="bulletinUrl" target="_blank" class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50">Télécharger bulletin</a>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-1 rounded-xl border bg-white p-4">
        <div class="space-y-2" v-if="student">
          <div class="text-sm text-slate-500">Nom</div>
          <div class="font-medium">{{ displayLast(student.user) }}</div>
          <div class="text-sm text-slate-500">Prénom</div>
          <div class="font-medium">{{ displayFirst(student.user) }}</div>
          <div class="text-sm text-slate-500">Email</div>
          <div class="font-medium">{{ student.user?.email }}</div>
          <div class="text-sm text-slate-500">Matricule</div>
          <div class="font-medium">{{ student.matricule || '-' }}</div>
          <div class="text-sm text-slate-500">Filière</div>
          <div class="font-medium">{{ student.filiere || '-' }}</div>
        </div>
      </div>
      <div class="lg:col-span-2 rounded-xl border bg-white">
        <div class="flex items-center justify-between px-4 py-3 border-b">
          <div class="font-medium">Notes récentes</div>
          <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="loadGrades">Actualiser</button>
        </div>
        <div v-if="loadingG" class="p-6 text-center text-slate-500">Chargement…</div>
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
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import api from '../../lib/api';

const route = useRoute();
const id = Number(route.params.id);
const student = ref<any>(null);
const grades = ref<any[]>([]);
const loadingG = ref(false);

const bulletinUrl = computed(() => `/api/v1/admin/students/${id}/bulletin`);

function splitName(full?:string){
  if (!full) return { first:'', last:'' };
  const parts = String(full).trim().split(/\s+/);
  if (parts.length === 1) return { first: parts[0], last: '' };
  return { first: parts.slice(0,-1).join(' '), last: parts[parts.length-1] };
}
function displayFirst(u:any){ return u?.first_name || splitName(u?.name).first; }
function displayLast(u:any){ return u?.last_name || splitName(u?.name).last; }

const loadStudent = async () => { const r = await api.get(`/admin/students/${id}`); student.value = r.data; };
const loadGrades = async () => {
  loadingG.value = true;
  try {
    const r = await api.get('/admin/grades', { params: { user_id: student.value?.user_id || student.value?.user?.id } });
    grades.value = r.data.data || r.data;
  } finally { loadingG.value = false; }
};

onMounted(async () => { await loadStudent(); await loadGrades(); });
</script>
