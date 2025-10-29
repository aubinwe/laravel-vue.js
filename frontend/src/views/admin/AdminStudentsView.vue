<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-xl font-semibold text-slate-800">Étudiants</h1>
        <p class="text-slate-500 text-sm">Liste des étudiants</p>
      </div>
      <div class="flex items-end gap-2">
        <input v-model="filters.q" placeholder="Recherche nom/email/matricule" class="rounded-md border px-3 py-2 text-sm" />
        <button @click="load" class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50">Filtrer</button>
      </div>
    </div>

    <div class="rounded-xl border bg-white overflow-x-auto">
      <table class="min-w-full divide-y divide-slate-200">
        <thead class="bg-slate-50">
          <tr>
            <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Nom</th>
            <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Prénom</th>
            <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Email</th>
            <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Matricule</th>
            <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Filière</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-200 bg-white">
          <tr v-for="s in students" :key="s.id">
            <td class="px-4 py-2">{{ displayLast(s) }}</td>
            <td class="px-4 py-2">{{ displayFirst(s) }}</td>
            <td class="px-4 py-2">{{ s.email }}</td>
            <td class="px-4 py-2">{{ s.matricule || '-' }}</td>
            <td class="px-4 py-2">{{ s.filiere || '-' }}</td>
          </tr>
        </tbody>
      </table>
      <div class="px-4 py-2 text-sm text-slate-500" v-if="meta">Page {{ meta.current_page }} / {{ meta.last_page }}</div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import api from '../../lib/api';

const students = ref<any[]>([]);
const meta = ref<any>(null);
const filters = ref<{q:string}>({ q:'' });

const load = async (page=1) => {
  const params:any = { page };
  if (filters.value.q) params.q = filters.value.q;
  const r = await api.get('/admin/students', { params });
  students.value = r.data.data || r.data;
  meta.value = r.data.meta || null;
};

function splitName(full?:string){
  if (!full) return { first:'', last:'' };
  const parts = String(full).trim().split(/\s+/);
  if (parts.length === 1) return { first: parts[0], last: '' };
  return { first: parts.slice(0,-1).join(' '), last: parts[parts.length-1] };
}
function displayFirst(s:any){ return s.first_name || splitName(s.name).first; }
function displayLast(s:any){ return s.last_name || splitName(s.name).last; }

onMounted(load);
</script>
