<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <h4 class="mb-3">Réclamations</h4>

      <div class="card shadow-sm mb-4">
        <div class="card-body">
          <h6 class="mb-3">Soumettre une réclamation</h6>
          <form @submit.prevent="submit">
            <div class="row g-3 align-items-end">
              <div class="col-12 col-md-4">
                <label class="form-label">Note concernée</label>
                <select v-model="form.grade_id" class="form-select" required>
                  <option :value="null" disabled>Choisir…</option>
                  <option v-for="g in grades" :key="g.id" :value="g.id">{{ g.subject?.name }} ({{ Number(g.score).toFixed(2) }})</option>
                </select>
              </div>
              <div class="col-12 col-md-6">
                <label class="form-label">Message</label>
                <input v-model="form.message" class="form-control" placeholder="Expliquez votre réclamation" required />
              </div>
              <div class="col-12 col-md-2">
                <button class="btn btn-primary w-100" :disabled="submitting">
                  <span v-if="submitting" class="spinner-border spinner-border-sm me-2"></span>
                  Envoyer
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <div class="card shadow-sm">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Historique des réclamations</h6>
            <button class="btn btn-outline-primary" @click="fetchComplaints">Actualiser</button>
          </div>
          <div v-if="loading" class="text-center py-4"><div class="spinner-border"></div></div>
          <div v-else class="table-responsive">
            <table class="table table-striped align-middle">
              <thead>
                <tr>
                  <th>Matière</th>
                  <th>Note</th>
                  <th>Message</th>
                  <th>Statut</th>
                  <th>Date</th>
                  <th v-if="isAdmin">Action</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="c in complaints" :key="c.id">
                  <td>{{ c.grade?.subject?.name }}</td>
                  <td>{{ Number(c.grade?.score ?? 0).toFixed(2) }}</td>
                  <td>{{ c.message }}</td>
                  <td>
                    <span :class="statusClass(c.status)">{{ c.status }}</span>
                  </td>
                  <td>{{ new Date(c.created_at).toLocaleString() }}</td>
                  <td v-if="isAdmin" class="d-flex gap-2">
                    <button class="btn btn-sm btn-success" @click="updateStatus(c, 'resolved')">Valider</button>
                    <button class="btn btn-sm btn-danger" @click="updateStatus(c, 'rejected')">Rejeter</button>
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
import axios from 'axios';
import { useRoute } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import Navbar from '../components/Navbar.vue';

const route = useRoute();
const auth = useAuthStore();
const { token, isAdmin } = storeToRefs(auth);

const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((cfg) => { if (token.value) cfg.headers.Authorization = `Bearer ${token.value}`; return cfg; });

const grades = ref([]);
const complaints = ref([]);
const loading = ref(false);
const submitting = ref(false);
const form = ref({ grade_id: null, message: '' });

const statusClass = (s) => ({
  pending: 'badge text-bg-warning',
  resolved: 'badge text-bg-success',
  rejected: 'badge text-bg-danger',
}[s] || 'badge text-bg-secondary');

const fetchGrades = async () => {
  const res = await api.get('/grades');
  grades.value = res.data.data || res.data;
};

const fetchComplaints = async () => {
  loading.value = true;
  try {
    const res = await api.get('/complaints');
    complaints.value = res.data.data || res.data;
  } finally { loading.value = false; }
};

const submit = async () => {
  submitting.value = true;
  try {
    await api.post('/complaints', form.value);
    form.value = { grade_id: null, message: '' };
    await fetchComplaints();
  } finally { submitting.value = false; }
};

const updateStatus = async (c, status) => {
  await api.put(`/complaints/${c.id}`, { status });
  await fetchComplaints();
};

onMounted(async () => {
  await fetchGrades();
  await fetchComplaints();
  const gid = route.query.grade_id ? Number(route.query.grade_id) : null;
  const subj = route.query.subject || '';
  if (gid) form.value = { grade_id: gid, message: `Réclamation concernant ${subj}` };
});
</script>
