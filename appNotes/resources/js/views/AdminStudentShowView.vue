<template>
  <div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h4 class="mb-0">Fiche Étudiant</h4>
      <router-link class="btn btn-outline-secondary" :to="{ name: 'admin-students' }">Retour</router-link>
    </div>

    <div v-if="loading" class="text-center py-5"><div class="spinner-border"></div></div>
    <div v-else-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-else class="row g-3">
      <div class="col-12 col-lg-6">
        <div class="card shadow-sm">
          <div class="card-body">
            <h6 class="text-muted mb-3">Informations personnelles</h6>
            <div class="row g-2">
              <div class="col-6"><strong>Nom:</strong> {{ student.last_name }}</div>
              <div class="col-6"><strong>Prénom:</strong> {{ student.first_name }}</div>
              <div class="col-12"><strong>Email:</strong> {{ student.email }}</div>
              <div class="col-6"><strong>Matricule:</strong> {{ student.matricule || '-' }}</div>
              <div class="col-6"><strong>Filière:</strong> {{ student.filiere || '-' }}</div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 col-lg-6">
        <div class="card shadow-sm">
          <div class="card-body">
            <h6 class="text-muted mb-3">Dernières notes</h6>
            <div v-if="gradesLoading" class="text-center py-3"><div class="spinner-border spinner-border-sm"></div></div>
            <div v-else class="table-responsive">
              <table class="table table-sm table-striped align-middle mb-0">
                <thead>
                  <tr>
                    <th>Matière</th>
                    <th>Coef.</th>
                    <th>Note</th>
                    <th>Date</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="g in grades" :key="g.id">
                    <td>{{ g.subject?.name }}</td>
                    <td>{{ g.subject?.coefficient }}</td>
                    <td>{{ Number(g.score).toFixed(2) }}</td>
                    <td>{{ new Date(g.created_at).toLocaleDateString() }}</td>
                  </tr>
                  <tr v-if="!grades || grades.length===0">
                    <td colspan="4" class="text-muted">Aucune note.</td>
                  </tr>
                </tbody>
              </table>
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

const props = defineProps({ id: { type: String, required: true } });

const auth = useAuthStore();
const { token } = storeToRefs(auth);
const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((c)=>{ if(token.value) c.headers.Authorization = `Bearer ${token.value}`; return c;});

const student = ref(null);
const loading = ref(false);
const error = ref('');

const grades = ref([]);
const gradesLoading = ref(false);

const loadStudent = async () => {
  loading.value = true; error.value='';
  try {
    const { data } = await api.get(`/admin/students/${props.id}`);
    student.value = data;
  } catch (e) {
    error.value = e.response?.data?.message || 'Erreur chargement étudiant';
  } finally { loading.value = false; }
};

const loadGrades = async () => {
  gradesLoading.value = true;
  try {
    const { data } = await api.get(`/grades`, { params: { user_id: props.id } });
    grades.value = data?.data ?? data ?? [];
  } finally { gradesLoading.value = false; }
};

onMounted(async () => {
  await loadStudent();
  await loadGrades();
});
</script>
