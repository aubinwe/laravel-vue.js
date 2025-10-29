<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <div v-if="!isAuthenticated" class="alert alert-warning">
        Vous devez vous connecter. <router-link to="/login">Connexion</router-link>
      </div>

      <div v-else class="row g-4">
        <div class="col-12 col-lg-4">
          <div class="card shadow-sm">
            <div class="card-body">
              <h5 class="card-title">Nouvelle note</h5>
              <form @submit.prevent="save">
                <div class="mb-3">
                  <label class="form-label">Titre</label>
                  <input v-model="form.title" class="form-control" required />
                </div>
                <div class="mb-3">
                  <label class="form-label">Contenu</label>
                  <textarea v-model="form.content" class="form-control" rows="5"></textarea>
                </div>
                <button class="btn btn-primary" :disabled="saving">
                  <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                  Enregistrer
                </button>
                <button v-if="form.id" type="button" class="btn btn-outline-secondary ms-2" @click="reset">Annuler</button>
              </form>
            </div>
          </div>
        </div>
        <div class="col-12 col-lg-8">
          <div class="card shadow-sm">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="card-title mb-0">Mes notes <small v-if="isAdmin" class="text-muted">(Admin: toutes les notes)</small></h5>
                <button class="btn btn-outline-primary" @click="fetchNotes">
                  Actualiser
                </button>
              </div>

              <div v-if="loading" class="text-center py-4">
                <div class="spinner-border"></div>
              </div>

              <div v-else>
                <div v-if="notes.length === 0" class="text-muted">Aucune note.</div>
                <div class="list-group">
                  <a v-for="n in notes" :key="n.id" class="list-group-item list-group-item-action">
                    <div class="d-flex w-100 justify-content-between">
                      <h6 class="mb-1">{{ n.title }}</h6>
                      <small class="text-muted">{{ new Date(n.created_at).toLocaleString() }}</small>
                    </div>
                    <p class="mb-1">{{ n.content }}</p>
                    <small v-if="n.user" class="text-muted">par {{ n.user.name }}</small>
                    <div class="mt-2 d-flex gap-2">
                      <button class="btn btn-sm btn-outline-secondary" @click="edit(n)">Modifier</button>
                      <button class="btn btn-sm btn-outline-danger" @click="remove(n)">Supprimer</button>
                    </div>
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { useAuthStore } from '../stores/auth';
import { storeToRefs } from 'pinia';
import Navbar from '../components/Navbar.vue';

const auth = useAuthStore();
const { token, isAuthenticated, isAdmin } = storeToRefs(auth);

const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((config) => {
  if (token.value) config.headers.Authorization = `Bearer ${token.value}`;
  return config;
});

const notes = ref([]);
const loading = ref(false);
const saving = ref(false);
const form = ref({ id: null, title: '', content: '' });

const reset = () => { form.value = { id: null, title: '', content: '' }; };

const fetchNotes = async () => {
  if (!isAuthenticated.value) return;
  loading.value = true;
  try {
    const { data } = await api.get('/notes');
    notes.value = data.data || data; // paginate or array
  } finally { loading.value = false; }
};

const save = async () => {
  saving.value = true;
  try {
    if (form.value.id) {
      const { data } = await api.put(`/notes/${form.value.id}`, { title: form.value.title, content: form.value.content });
      const idx = notes.value.findIndex(x => x.id === form.value.id);
      if (idx >= 0) notes.value[idx] = data;
    } else {
      const { data } = await api.post('/notes', { title: form.value.title, content: form.value.content });
      notes.value.unshift(data);
    }
    reset();
  } finally { saving.value = false; }
};

const edit = (n) => { form.value = { id: n.id, title: n.title, content: n.content }; };

const remove = async (n) => {
  if (!confirm('Supprimer cette note ?')) return;
  await api.delete(`/notes/${n.id}`);
  notes.value = notes.value.filter(x => x.id !== n.id);
};

onMounted(fetchNotes);
</script>
