<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <h4 class="mb-3">Réclamations (Professeur)</h4>

      <div class="card mb-3">
        <div class="card-body">
          <div class="row g-2 align-items-end">
            <div class="col-md-3">
              <label class="form-label">Statut</label>
              <select class="form-select" v-model="status">
                <option value="">Tous</option>
                <option value="pending">En attente</option>
                <option value="resolved">Résolue</option>
                <option value="rejected">Rejetée</option>
              </select>
            </div>
            <div class="col-md-3">
              <button class="btn btn-outline-primary" @click="fetchComplaints">Filtrer</button>
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
            <th>Message</th>
            <th>Statut</th>
            <th>Date</th>
            <th></th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="c in complaints" :key="c.id">
            <td>{{ c.id }}</td>
            <td>{{ c.user?.name }}</td>
            <td>{{ c.grade?.subject?.name }}</td>
            <td>{{ c.grade?.score }}</td>
            <td style="max-width: 300px">{{ c.message }}</td>
            <td>
              <select class="form-select form-select-sm" v-model="c._status" style="max-width: 140px">
                <option value="pending">En attente</option>
                <option value="resolved">Résolue</option>
                <option value="rejected">Rejetée</option>
              </select>
            </td>
            <td>{{ new Date(c.created_at).toLocaleString() }}</td>
            <td class="text-nowrap">
              <button class="btn btn-sm btn-outline-success" @click="saveComplaint(c)">Mettre à jour</button>
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
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import Navbar from '../components/Navbar.vue';

const auth = useAuthStore();
const { token } = storeToRefs(auth);
const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((cfg) => { if (token.value) cfg.headers.Authorization = `Bearer ${token.value}`; return cfg; });

const complaints = ref([]);
const status = ref('');
const loading = ref(false);
const page = ref(1);
const hasMore = ref(false);

const fetchComplaints = async () => {
  loading.value = true;
  try {
    const params = { page: page.value };
    if (status.value) params.status = status.value;
    const res = await api.get('/teacher/complaints', { params });
    const arr = res.data.data || res.data;
    complaints.value = arr.map(c => ({ ...c, _status: c.status }));
    hasMore.value = !!res.data.next_page_url;
  } finally { loading.value = false; }
};

const saveComplaint = async (c) => {
  await api.put(`/teacher/complaints/${c.id}`, { status: c._status });
};

const goto = (p) => { if (p<1) return; page.value = p; fetchComplaints(); };

onMounted(fetchComplaints);
</script>
