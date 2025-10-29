<template>
  <div class="space-y-6">
    <div class="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
      <div>
        <h1 class="text-xl font-semibold text-slate-800">Matières</h1>
        <p class="text-slate-500 text-sm">Gérer les matières et l'affectation des professeurs</p>
      </div>
      <div class="flex items-end gap-2">
        <input v-model="form.name" placeholder="Nom" class="rounded-md border px-3 py-2 text-sm" />
        <input v-model.number="form.coefficient" type="number" min="1" placeholder="Coef." class="w-28 rounded-md border px-3 py-2 text-sm" />
        <button @click="save" class="rounded-md bg-slate-900 px-3 py-2 text-sm text-white hover:bg-slate-800" :disabled="saving">{{ saving ? '...' : (form.id? 'Mettre à jour' : 'Créer') }}</button>
        <button v-if="form.id" @click="reset" class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50">Annuler</button>
      </div>
    </div>

    <div class="rounded-xl border bg-white overflow-hidden">
      <div class="px-4 py-3 border-b font-medium">Liste des matières</div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Nom</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Coef.</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Professeurs</th>
              <th class="px-4 py-2"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-200 bg-white">
            <tr v-for="s in subjects" :key="s.id">
              <td class="px-4 py-2">{{ s.name }}</td>
              <td class="px-4 py-2">{{ s.coefficient }}</td>
              <td class="px-4 py-2">
                <div class="flex flex-wrap gap-2">
                  <span v-for="t in s._teachers" :key="t.id" class="px-2 py-0.5 text-xs rounded-full bg-slate-100 text-slate-700">{{ t.name }}</span>
                  <span v-if="!s._teachers || s._teachers.length===0" class="text-sm text-slate-400">—</span>
                </div>
              </td>
              <td class="px-4 py-2 text-right">
                <div class="inline-flex gap-2">
                  <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="editRow(s)">Éditer</button>
                  <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="openAssign(s)">Affecter</button>
                  <button class="rounded-md border px-3 py-1.5 text-sm text-rose-600 hover:bg-rose-50" @click="remove(s)">Supprimer</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="px-4 py-2 text-sm text-slate-500" v-if="meta">Page {{ meta.current_page }} / {{ meta.last_page }}</div>
    </div>

    <!-- Modal Affectation -->
    <div v-if="assignOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div class="w-full max-w-lg rounded-xl border bg-white shadow">
        <div class="px-4 py-3 border-b font-medium">Affecter des professeurs — {{ currentSubject?.name }}</div>
        <div class="p-4 space-y-3">
          <div>
            <label class="block text-sm text-slate-600 mb-1">Professeurs</label>
            <select multiple v-model="selectedTeachers" class="w-full rounded-md border px-3 py-2 text-sm min-h-[160px]">
              <option v-for="t in teachers" :key="t.id" :value="t.id">{{ t.name }} ({{ t.email }})</option>
            </select>
            <p class="text-xs text-slate-500 mt-1">Maintenez Ctrl/Cmd pour sélectionner plusieurs professeurs.</p>
          </div>
        </div>
        <div class="px-4 py-3 border-t flex justify-end gap-2">
          <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="assignOpen=false">Fermer</button>
          <button class="rounded-md bg-slate-900 px-3 py-1.5 text-sm text-white hover:bg-slate-800" @click="saveAssign">Enregistrer</button>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import api from '../../lib/api';

const subjects = ref<any[]>([]);
const meta = ref<any>(null);
const teachers = ref<any[]>([]);
const form = ref<{id:number|null,name:string, coefficient:number|undefined}>({ id:null, name:'', coefficient:1 });
const saving = ref(false);

const assignOpen = ref(false);
const currentSubject = ref<any>(null);
const selectedTeachers = ref<number[]>([]);

const load = async (page=1) => {
  const r = await api.get(`/admin/subjects`, { params: { page } });
  const list = r.data.data || r.data;
  subjects.value = list.map((s:any) => ({ ...s, _teachers: [] }));
  meta.value = r.data.meta || null;
  // prefetch teachers assigned for first page subjects
  for (const s of subjects.value) {
    const tr = await api.get(`/admin/subjects/${s.id}/teachers`);
    s._teachers = tr.data || [];
  }
};

const loadTeachers = async () => {
  const r = await api.get('/admin/users', { params: { role: 'teacher' } });
  teachers.value = r.data.data || r.data;
};

const save = async () => {
  if (!form.value.name || !form.value.coefficient || form.value.coefficient < 1) return;
  saving.value = true;
  try {
    if (form.value.id) {
      await api.put(`/admin/subjects/${form.value.id}`, { name: form.value.name, coefficient: form.value.coefficient });
    } else {
      await api.post(`/admin/subjects`, { name: form.value.name, coefficient: form.value.coefficient });
    }
    reset();
    await load();
  } finally { saving.value = false; }
};

const editRow = (s:any) => { form.value = { id: s.id, name: s.name, coefficient: s.coefficient }; };
const reset = () => { form.value = { id:null, name:'', coefficient:1 }; };
const remove = async (s:any) => { if (!confirm('Supprimer cette matière ?')) return; await api.delete(`/admin/subjects/${s.id}`); await load(); };

const openAssign = async (s:any) => {
  currentSubject.value = s;
  await loadTeachers();
  const tr = await api.get(`/admin/subjects/${s.id}/teachers`);
  const assigned:number[] = (tr.data || []).map((x:any)=>x.id);
  selectedTeachers.value = assigned;
  assignOpen.value = true;
};

const saveAssign = async () => {
  await api.post(`/admin/subjects/${currentSubject.value.id}/teachers`, { teacher_ids: selectedTeachers.value });
  assignOpen.value = false;
  await load();
};

onMounted(() => { load(); });
</script>
