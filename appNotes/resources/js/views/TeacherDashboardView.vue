<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <h4 class="mb-3">Espace Professeur</h4>
      <div class="row g-3">
        <div class="col-md-6">
          <div class="card">
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <h5 class="card-title mb-0">Réclamations récentes</h5>
                <router-link class="btn btn-sm btn-outline-primary" to="/teacher/complaints">Voir tout</router-link>
              </div>
              <ul class="list-group list-group-flush" v-if="complaints.length">
                <li v-for="c in complaints" :key="c.id" class="list-group-item px-0">
                  <div class="d-flex justify-content-between">
                    <div>
                      <div class="fw-semibold">{{ c.user?.name }} • {{ c.grade?.subject?.name }}</div>
                      <div class="text-muted small">Note: {{ c.grade?.score }} • {{ new Date(c.created_at).toLocaleString() }}</div>
                    </div>
                    <span class="badge" :class="badge(c.status)">{{ c.status }}</span>
                  </div>
                </li>
              </ul>
              <div v-else class="text-muted">Aucune réclamation</div>
            </div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card">
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <h5 class="card-title mb-0">Dernières notes saisies</h5>
                <router-link class="btn btn-sm btn-outline-primary" to="/teacher/grades">Gérer</router-link>
              </div>
              <ul class="list-group list-group-flush" v-if="grades.length">
                <li v-for="g in grades" :key="g.id" class="list-group-item px-0">
                  <div class="d-flex justify-content-between">
                    <div>
                      <div class="fw-semibold">{{ g.user?.name }} • {{ g.subject?.name }}</div>
                      <div class="text-muted small">Note: {{ Number(g.score).toFixed(2) }}</div>
                    </div>
                    <div class="text-muted small">{{ new Date(g.created_at).toLocaleString() }}</div>
                  </div>
                </li>
              </ul>
              <div v-else class="text-muted">Aucune note</div>
            </div>
          </div>
        </div>
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

const complaints = ref([]);
const grades = ref([]);

const badge = (s) => ({ pending: 'bg-secondary', resolved: 'bg-success', rejected: 'bg-danger' }[s] || 'bg-secondary');

const fetchData = async () => {
  const [c, g] = await Promise.all([
    api.get('/teacher/complaints', { params: { status: 'pending' } }),
    api.get('/teacher/grades'),
  ]);
  complaints.value = c.data.data?.slice(0, 5) || [];
  grades.value = g.data.data?.slice(0, 5) || [];
};

onMounted(fetchData);
</script>
