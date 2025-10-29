<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-xl font-semibold text-slate-800">Notes (Professeur)</h1>
      <p class="text-slate-500 text-sm">Filtrer par matière/étudiant et gérer les notes</p>
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
          <label class="block text-sm text-slate-600 mb-1">Étudiant (optionnel)</label>
          <input v-model="filters.q" placeholder="Rechercher par nom/email" class="w-full rounded-md border px-3 py-2 text-sm" />
        </div>
        <div>
          <button class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50" @click="load">Filtrer</button>
        </div>
        <div></div>
      </div>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="font-medium mb-3">Ajouter / Modifier une note</div>
      <div class="grid grid-cols-1 md:grid-cols-5 gap-3 items-end">
        <select v-model.number="form.student_id" class="rounded-md border px-3 py-2 text-sm">
          <option :value="0" disabled>Étudiant</option>
          <option v-for="st in students" :key="st.id" :value="st.id">{{ displayStudent(st) }}</option>
        </select>
        <select v-model.number="form.subject_id" class="rounded-md border px-3 py-2 text-sm">
          <option :value="0" disabled>Matière</option>
          <option v-for="s in subjects" :key="s.id" :value="s.id">{{ s.name }}</option>
        </select>
        <input v-model.number="form.score" type="number" step="0.01" min="0" max="20" class="rounded-md border px-3 py-2 text-sm" placeholder="Note /20" />
        <button class="rounded-md bg-slate-900 px-3 py-2 text-sm text-white hover:bg-slate-800" :disabled="saving" @click="save">{{ saving ? '...' : (form.id? 'Mettre à jour' : 'Ajouter') }}</button>
        <button v-if="form.id" class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50" @click="reset">Annuler</button>
      </div>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="flex items-center justify-between mb-3">
        <div class="font-medium">Liste des notes</div>
        <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="load">Actualiser</button>
      </div>
      <div v-if="loading" class="p-6 text-center text-slate-500">Chargement…</div>
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Étudiant</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Matière</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Coef.</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Note</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Date</th>
              <th class="px-4 py-2"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-200 bg-white">
            <tr v-for="g in grades" :key="g.id">
              <td class="px-4 py-2">{{ g.user?.name }}</td>
              <td class="px-4 py-2">{{ g.subject?.name }}</td>
              <td class="px-4 py-2">{{ g.subject?.coefficient }}</td>
              <td class="px-4 py-2">{{ Number(g.score).toFixed(2) }}</td>
              <td class="px-4 py-2">{{ new Date(g.created_at).toLocaleString() }}</td>
              <td class="px-4 py-2 text-right">
                <button class="rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="editRow(g)">Éditer</button>
                <button class="rounded-md border px-3 py-1.5 text-sm text-rose-600 hover:bg-rose-50 ml-2" @click="removeRow(g)">Supprimer</button>
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

const subjects = ref<any[]>([]);
const students = ref<any[]>([]);
const grades = ref<any[]>([]);
const loading = ref(false);
const saving = ref(false);

const filters = ref<{subject_id:number,q:string}>({ subject_id: 0, q: '' });
const form = ref<{id:number|null,student_id:number,subject_id:number,score:number|null}>({ id:null, student_id:0, subject_id:0, score:null });

const displayStudent = (st:any) => {
  const u = st.user || st; // support API variants
  const name = u?.name || `${u?.last_name||''} ${u?.first_name||''}`.trim();
  return `${name} ${st.matricule? '('+st.matricule+')':''}`.trim();
};

const loadSubjects = async () => { const r = await api.get('/admin/subjects'); subjects.value = r.data.data || r.data; };
const loadStudents = async () => { const r = await api.get('/admin/students'); students.value = r.data.data || r.data; };

const load = async () => {
  loading.value = true;
  try {
    const params:any = {};
    if (filters.value.subject_id) params.subject_id = filters.value.subject_id;
    if (filters.value.q) params.q = filters.value.q;
    const r = await api.get('/teacher/grades', { params });
    grades.value = r.data.data || r.data;
  } finally { loading.value = false; }
};

const reset = () => { form.value = { id:null, student_id:0, subject_id:0, score:null }; };

const save = async () => {
  if (!form.value.student_id || !form.value.subject_id || form.value.score === null) return ui.error('Champs requis manquants');
  if (form.value.score! < 0 || form.value.score! > 20) return ui.error('La note doit être entre 0 et 20');
  saving.value = true;
  try {
    if (form.value.id) {
      await api.put(`/teacher/grades/${form.value.id}`, { user_id: form.value.student_id, subject_id: form.value.subject_id, score: form.value.score });
    } else {
      await api.post('/teacher/grades', { user_id: form.value.student_id, subject_id: form.value.subject_id, score: form.value.score });
    }
    reset();
    await load();
    ui.success('Enregistré');
  } finally { saving.value = false; }
};

const editRow = (g:any) => { form.value = { id:g.id, student_id: g.user_id, subject_id: g.subject_id, score: Number(g.score) } };
const removeRow = async (g:any) => { if (!confirm('Supprimer cette note ?')) return; await api.delete(`/teacher/grades/${g.id}`); await load(); ui.success('Supprimé'); };

onMounted(async () => { await Promise.all([loadSubjects(), loadStudents()]); await load(); });
</script>
