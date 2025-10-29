<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="mb-0">Gestion des notes</h4>
      </div>

      <div class="card shadow-sm mb-4">
        <div class="card-body">
          <div class="row g-3 align-items-end">
            <div class="col-12 col-md-4">
              <label class="form-label">Étudiant</label>
              <select v-model.number="filters.user_id" class="form-select">
                <option :value="null">-- Tous --</option>
                <option v-for="u in users" :key="u.id" :value="u.id">{{ u.last_name }} {{ u.first_name }} ({{ u.matricule || u.email }})</option>
              </select>
            </div>
            <div class="col-12 col-md-3">
              <label class="form-label">Matière</label>
              <select v-model.number="filters.subject_id" class="form-select">
                <option :value="null">-- Toutes --</option>
                <option v-for="s in subjects" :key="s.id" :value="s.id">{{ s.name }} ({{ s.coefficient }})</option>
              </select>
            </div>
            <div class="col-12 col-md-2">
              <button class="btn btn-outline-primary w-100" @click="load">Filtrer</button>
            </div>
            <div class="col-12 col-md-3" v-if="avg !== null && filters.user_id">
              <div class="alert alert-info py-2 mb-0">Moyenne: <strong>{{ avg.toFixed(2) }}</strong></div>
            </div>
          </div>
        </div>
      </div>

      <div class="card shadow-sm mb-4">
        <div class="card-body">
          <h6 class="mb-3">Saisir toutes les notes d'un étudiant (en une fois)</h6>
          <div class="row g-3 align-items-end mb-3">
            <div class="col-12 col-md-5">
              <label class="form-label">Étudiant</label>
              <select v-model.number="bulkUserId" class="form-select">
                <option :value="null" disabled>Choisir étudiant</option>
                <option v-for="u in users" :key="u.id" :value="u.id">{{ u.last_name }} {{ u.first_name }} ({{ u.matricule || u.email }})</option>
              </select>
            </div>
            <div class="col-12 col-md-3">
              <button class="btn btn-outline-secondary w-100" @click="prefillFromExisting" :disabled="!bulkUserId">Préremplir</button>
            </div>
            <div class="col-12 col-md-4">
              <button class="btn btn-success w-100" @click="bulkSave" :disabled="!bulkUserId || bulkSaving">{{ bulkSaving ? '...' : 'Enregistrer toutes les notes' }}</button>
            </div>
          </div>
          <div class="table-responsive">
            <table class="table table-sm align-middle">
              <thead>
              <tr>
                <th style="width:40%">Matière</th>
                <th style="width:15%">Coef.</th>
                <th style="width:20%">Note /20</th>
                <th></th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="s in subjects" :key="s.id">
                <td>{{ s.name }}</td>
                <td>{{ s.coefficient }}</td>
                <td><input v-model.number="bulkScores[s.id]" type="number" min="0" max="20" step="0.01" class="form-control form-control-sm" placeholder="Ex: 12.5"></td>
                <td></td>
              </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="card shadow-sm mb-4">
        <div class="card-body">
          <h6 class="mb-3">Ajouter / Modifier une note</h6>
          <div class="row g-2">
            <div class="col-12 col-md-4">
              <select v-model.number="form.user_id" class="form-select">
                <option :value="null" disabled>Choisir étudiant</option>
                <option v-for="u in users" :key="u.id" :value="u.id">{{ u.last_name }} {{ u.first_name }}</option>
              </select>
            </div>
            <div class="col-12 col-md-4">
              <select v-model.number="form.subject_id" class="form-select">
                <option :value="null" disabled>Choisir matière</option>
                <option v-for="s in subjects" :key="s.id" :value="s.id">{{ s.name }}</option>
              </select>
            </div>
            <div class="col-12 col-md-2">
              <input v-model.number="form.score" type="number" min="0" max="20" step="0.01" class="form-control" placeholder="Note /20" />
            </div>
            <div class="col-12 col-md-2">
              <button class="btn btn-primary w-100" :disabled="saving" @click="save">{{ saving ? '...' : (form.id ? 'Mettre à jour' : 'Ajouter') }}</button>
            </div>
          </div>
        </div>
      </div>

      <div class="card shadow-sm">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Liste des notes</h6>
          </div>

          <div v-if="loading" class="text-center py-4"><div class="spinner-border"></div></div>
          <div v-else class="table-responsive">
            <table class="table table-striped align-middle">
              <thead>
                <tr>
                  <th>Étudiant</th>
                  <th>Matière</th>
                  <th>Coef.</th>
                  <th>Note</th>
                  <th>Date</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="g in grades" :key="g.id">
                  <td>{{ g.user?.name }}</td>
                  <td>{{ g.subject?.name }}</td>
                  <td>{{ g.subject?.coefficient }}</td>
                  <td>{{ Number(g.score).toFixed(2) }}</td>
                  <td>{{ new Date(g.created_at).toLocaleString() }}</td>
                  <td class="text-end">
                    <div class="btn-group">
                      <button class="btn btn-sm btn-outline-secondary" @click="editRow(g)">Éditer</button>
                      <button class="btn btn-sm btn-outline-danger" @click="remove(g)">Supprimer</button>
                    </div>
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
import { ref, onMounted, watch } from 'vue';
import axios from 'axios';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import Navbar from '../components/Navbar.vue';

const auth = useAuthStore();
const { token } = storeToRefs(auth);
const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((c)=>{ if(token.value) c.headers.Authorization = `Bearer ${token.value}`; return c;});

const users = ref([]);
const subjects = ref([]);
const grades = ref([]);
const loading = ref(false);
const saving = ref(false);
const avg = ref(null);
const filters = ref({ user_id: null, subject_id: null });

const form = ref({ id:null, user_id: null, subject_id: null, score: null });

// Bulk entry state
const bulkUserId = ref(null);
const bulkScores = ref({});
const bulkSaving = ref(false);

const loadUsers = async () => {
  const { data } = await api.get('/admin/students');
  users.value = data.data || data;
};
const loadSubjects = async () => {
  const { data } = await api.get('/admin/subjects');
  subjects.value = data.data || data;
};

const load = async () => {
  loading.value = true;
  try {
    const query = [];
    if (filters.value.user_id) query.push(`user_id=${filters.value.user_id}`);
    if (filters.value.subject_id) query.push(`subject_id=${filters.value.subject_id}`);
    const qs = query.length ? `?${query.join('&')}` : '';
    const { data } = await api.get(`/admin/grades${qs}`);
    grades.value = data.data || data;
    if (filters.value.user_id) {
      const a = await api.get(`/grades/average?user_id=${filters.value.user_id}`);
      avg.value = a.data.average ?? null;
    } else {
      avg.value = null;
    }
  } finally { loading.value = false; }
};

const save = async () => {
  saving.value = true;
  try {
    if (!form.value.user_id || !form.value.subject_id || form.value.score === null || form.value.score === undefined) {
      alert('Veuillez sélectionner un étudiant, une matière et saisir une note.');
      return;
    }
    if (Number(form.value.score) < 0 || Number(form.value.score) > 20) {
      alert('La note doit être comprise entre 0 et 20.');
      return;
    }
    if (form.value.id) {
      const payload = { user_id: form.value.user_id, subject_id: form.value.subject_id, score: form.value.score };
      await api.put(`/admin/grades/${form.value.id}`, payload);
    } else {
      await api.post('/admin/grades', form.value);
    }
    form.value = { id:null, user_id: null, subject_id: null, score: null };
    await load();
  } catch (e) {
    alert('Erreur lors de l\'enregistrement');
  } finally { saving.value = false; }
};
const editRow = (g) => {
  form.value = { id:g.id, user_id:g.user_id, subject_id:g.subject_id, score:Number(g.score) };
};
const remove = async (g) => { if(!confirm('Supprimer cette note ?')) return; await api.delete(`/admin/grades/${g.id}`); await load(); };

watch(() => filters.value.user_id, load);

const prefillFromExisting = async () => {
  if (!bulkUserId.value) return;
  // Reset
  bulkScores.value = {};
  const { data } = await api.get(`/admin/grades?user_id=${bulkUserId.value}`);
  const list = data.data || data;
  for (const g of list) {
    bulkScores.value[g.subject_id] = Number(g.score);
  }
};

const bulkSave = async () => {
  bulkSaving.value = true;
  try {
    const items = subjects.value.map(s => ({ subject_id: s.id, score: bulkScores.value[s.id] ?? null }));
    await api.post('/admin/grades/bulk', { user_id: bulkUserId.value, items });
    await load();
  } finally { bulkSaving.value = false; }
};

onMounted(async () => {
  await Promise.all([loadUsers(), loadSubjects()]);
  await load();
});
</script>
