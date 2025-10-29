<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <h4 class="mb-3">Mes notes</h4>
      <div class="row mb-3">
        <div class="col-auto">
          <button class="btn btn-outline-primary" @click="fetchGrades">
            Actualiser
          </button>
        </div>
        <div class="col-auto" v-if="avg !== null">
          <div class="alert alert-info py-2 px-3 mb-0">
            Moyenne: <strong>{{ avg.toFixed(2) }}</strong>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border"></div>
      </div>

      <div v-else class="table-responsive">
        <table class="table table-striped align-middle">
          <thead>
          <tr>
            <th>Matière</th>
            <th>Note</th>
            <th>Date</th>
            <th></th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="g in grades" :key="g.id">
            <td>{{ g.subject?.name }}</td>
            <td>{{ Number(g.score).toFixed(2) }}</td>
            <td>{{ new Date(g.created_at).toLocaleString() }}</td>
            <td>
              <router-link class="btn btn-sm btn-outline-secondary" :to="{ name: 'complaints', query: { grade_id: g.id, subject: g.subject?.name } }">Réclamer</router-link>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
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

const grades = ref([]);
const avg = ref(null);
const loading = ref(false);

const fetchGrades = async () => {
  loading.value = true;
  try {
    const [g, a] = await Promise.all([
      api.get('/grades'),
      api.get('/grades/average'),
    ]);
    grades.value = g.data.data || g.data;
    avg.value = a.data.average ?? null;
  } finally { loading.value = false; }
};

onMounted(fetchGrades);
</script>
