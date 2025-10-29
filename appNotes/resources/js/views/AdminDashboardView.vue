<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <h4 class="mb-4">Tableau de bord Admin</h4>
      <div class="row g-3 mb-4">
        <div class="col-12 col-md-4">
          <div class="card text-bg-light shadow-sm">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <div class="text-muted">Etudiants</div>
                  <div class="fs-3 fw-bold">{{ summary?.students ?? '-' }}</div>
                </div>
                <i class="bi bi-people fs-1"></i>
              </div>
            </div>
          </div>
        </div>
        <div class="col-12 col-md-4">
          <div class="card text-bg-light shadow-sm">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <div class="text-muted">Moyenne globale</div>
                  <div class="fs-3 fw-bold">{{ summary?.global_average ?? '-' }}</div>
                </div>
                <i class="bi bi-graph-up fs-1"></i>
              </div>
            </div>
          </div>
        </div>
        <div class="col-12 col-md-4">
          <div class="card text-bg-light shadow-sm">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <div class="text-muted">Réclamations ouvertes</div>
                  <div class="fs-3 fw-bold">{{ summary?.open_complaints ?? '-' }}</div>
                </div>
                <i class="bi bi-bell fs-1"></i>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="d-flex gap-2 flex-wrap">
        <router-link class="btn btn-primary" to="/complaints"><i class="bi bi-inbox me-1"></i> Réclamations</router-link>
        <router-link class="btn btn-outline-secondary" to="/notes"><i class="bi bi-stickies me-1"></i> Post-it</router-link>
        <router-link class="btn btn-outline-primary" to="/grades"><i class="bi bi-list-ol me-1"></i> Notes</router-link>
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
api.interceptors.request.use((c)=>{ if(token.value) c.headers.Authorization = `Bearer ${token.value}`; return c;});

const summary = ref(null);
const load = async () => {
  const { data } = await api.get('/admin/dashboard');
  summary.value = data;
};
onMounted(load);
</script>
