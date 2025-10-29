<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <h4 class="mb-3">Gestion des notes (Professeur)</h4>

      <div class="card mb-3">
        <div class="card-body">
          <div class="row g-2 align-items-end">
            <div class="col-md-3">
              <label class="form-label">Matière</label>
              <select class="form-select" v-model.number="filter.subject_id">
                <option :value="0">Toutes</option>
                <option v-for="s in subjects" :key="s.id" :value="s.id">{{ s.name }}</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">ID Étudiant</label>
              <input type="number" v-model.number="filter.user_id" class="form-control" placeholder="Optionnel" />
            </div>
            <div class="col-md-3">
              <button class="btn btn-outline-primary" @click="fetchGrades">Filtrer</button>
            </div>
          </div>
        </div>
      </div>

      <div class="card mb-3">
        <div class="card-body">
          <h6 class="mb-3">Ajouter une note</h6>
          <div class="row g-2">
            <div class="col-md-3">
              <label class="form-label">Matière</label>
              <select class="form-select" v-model.number="form.subject_id">
                <option v-for="s in subjects" :key="s.id" :value="s.id">{{ s.name }}</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">ID Étudiant</label>
              <input type="number" class="form-control" v-model.number="form.user_id" />
            </div>
            <div class="col-md-3">
              <label class="form-label">Note</label>
              <input type="number" step="0.01" min="0" max="20" class="form-control" v-model.number="form.score" />
            </div>
            <div class="col-md-3 d-flex align-items-end">
              <button class="btn btn-primary" :disabled="submitting" @click="createGrade">Enregistrer</button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center py-5"><div class="spinner-border"></div></div>

      <div v-else class="table-responsive">
        <table class="table table-striped align-middle">
          <thead>
          <tr>
            <th>#</th>
            <th>Étudiant</th>
            <th>Matière</th>
            <th>Note</th>
            <th>Date</th>
            <th></th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="g in grades" :key="g.id">
            <td>{{ g.id }}</td>
            <td>{{ g.user?.name }} ({{ g.user_id }})</td>
            <td>{{ g.subject?.name }}</td>
            <td>
              <input class="form-control form-control-sm" type="number" min="0" max="20" step="0.01" v-model.number="g._score" style="max-width: 120px;" />
            </td>
            <td>{{ new Date(g.created_at).toLocaleString() }}</td>
            <td class="text-nowrap">
              <button class="btn btn-sm btn-outline-success me-2" @click="saveGrade(g)">Sauvegarder</button>
              <button class="btn btn-sm btn-outline-danger" @click="removeGrade(g)">Supprimer</button>
            </td>
          </tr>
          </tbody>
        </table>
      </div>

      <nav>
        <ul class="pagination">
          <li class="page-item" :class="{ disabled: page<=1 }">
            <a class="page-link" href="#" @click.prevent="goto(page-1)">Précédent</a>
          </li>
          <li class="page-item disabled"><span class="page-link">Page {{ page }}</span></li>
          <li class="page-item" :class="{ disabled: !hasMore }">
            <a class="page-link" href="#" @click.prevent="goto(page+1)">Suivant</a>
          </li>
        </ul>
      </nav>

    </div>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted, watch } from 'vue';
import axios from 'axios';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import Navbar from '../components/Navbar.vue';

const auth = useAuthStore();
const { token } = storeToRefs(auth);
const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((cfg) => { if (token.value) cfg.headers.Authorization = `Bearer ${token.value}`; return cfg; });

const subjects = ref([]);
const grades = ref([]);
const loading = ref(false);
const submitting = ref(false);
const page = ref(1);
const hasMore = ref(false);

const filter = reactive({ subject_id: 0, user_id: null });
const form = reactive({ subject_id: null, user_id: null, score: null });

const fetchSubjects = async () => {
  // derive from grades endpoint quickly: fetch first page then map distinct subjects
  const res = await api.get('/teacher/grades');
  const arr = res.data.data || [];
  const map = new Map();
  for (const g of arr) { if (g.subject) map.set(g.subject.id, g.subject); }
  subjects.value = Array.from(map.values());
  if (!form.subject_id && subjects.value[0]) form.subject_id = subjects.value[0].id;
};

const fetchGrades = async () => {
  loading.value = true;
  try {
    const params = { page: page.value };
    if (filter.subject_id) params.subject_id = filter.subject_id;
    if (filter.user_id) params.user_id = filter.user_id;
    const res = await api.get('/teacher/grades', { params });
    const arr = res.data.data || res.data;
    grades.value = arr.map(g => ({ ...g, _score: Number(g.score) }));
    hasMore.value = !!res.data.next_page_url;
  } finally { loading.value = false; }
};

const createGrade = async () => {
  submitting.value = true;
  try {
    await api.post('/teacher/grades', form);
    await fetchGrades();
  } finally { submitting.value = false; }
};

const saveGrade = async (g) => {
  await api.put(`/teacher/grades/${g.id}`, { score: g._score });
};

const removeGrade = async (g) => {
  if (!confirm('Supprimer cette note ?')) return;
  await api.delete(`/teacher/grades/${g.id}`);
  await fetchGrades();
};

const goto = (p) => { if (p<1) return; page.value = p; fetchGrades(); };

onMounted(async () => { await Promise.all([fetchSubjects(), fetchGrades()]); });
watch(() => filter.subject_id, () => { page.value = 1; });
</script>
