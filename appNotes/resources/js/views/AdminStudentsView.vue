<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="mb-0">Gestion des étudiants</h4>
      </div>

      <div v-if="loading" class="text-center py-5"><div class="spinner-border"></div></div>
      <div v-else class="table-responsive">
        <table class="table table-striped align-middle">
          <thead>
          <tr>
            <th>Nom</th>
            <th>Prénom</th>
            <th>Email</th>
            <th>Matricule</th>
            <th>Filière</th>
            <th></th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="s in students" :key="s.id">
            <td><a href="#" @click.prevent="goShow(s)">{{ displayLast(s) }}</a></td>
            <td><a href="#" @click.prevent="goShow(s)">{{ displayFirst(s) }}</a></td>
            <td>{{ s.email }}</td>
            <td>{{ s.matricule }}</td>
            <td>{{ s.filiere }}</td>
            <td class="text-end">
              <div class="btn-group">
                <button class="btn btn-sm btn-outline-primary" @click="goShow(s)">Voir</button>
                <button class="btn btn-sm btn-outline-secondary" @click="openEdit(s)">Éditer</button>
                <button class="btn btn-sm btn-outline-danger" @click="remove(s)">Supprimer</button>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>

      <nav class="mt-3" v-if="meta">
        <ul class="pagination">
          <li class="page-item" :class="{disabled: meta.current_page===1}">
            <button class="page-link" @click="goPage(meta.current_page-1)">Préc.</button>
          </li>
          <li class="page-item disabled"><span class="page-link">Page {{ meta.current_page }} / {{ meta.last_page }}</span></li>
          <li class="page-item" :class="{disabled: meta.current_page===meta.last_page}">
            <button class="page-link" @click="goPage(meta.current_page+1)">Suiv.</button>
          </li>
        </ul>
      </nav>

      <div class="modal fade" id="studentModal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">{{ editing ? 'Modifier' : 'Créer' }} un étudiant</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              <div class="row g-2">
                <div class="col-6"><input v-model="form.last_name" class="form-control" placeholder="Nom"/></div>
                <div class="col-6"><input v-model="form.first_name" class="form-control" placeholder="Prénom"/></div>
                <div class="col-12"><input v-model="form.email" type="email" class="form-control" placeholder="Email"/></div>
                <div class="col-6"><input v-model="form.matricule" class="form-control" placeholder="Matricule"/></div>
                <div class="col-6"><input v-model="form.filiere" class="form-control" placeholder="Filière"/></div>
                <div class="col-12" v-if="!editing"><input v-model="form.password" type="password" class="form-control" placeholder="Mot de passe"/></div>
              </div>
            </div>
            <div class="modal-footer">
              <button class="btn btn-secondary" data-bs-dismiss="modal">Fermer</button>
              <button class="btn btn-primary" :disabled="saving" @click="save">{{ saving ? '...' : 'Enregistrer' }}</button>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import Navbar from '../components/Navbar.vue';
import * as bootstrap from 'bootstrap';

const auth = useAuthStore();
const router = useRouter();
const { token } = storeToRefs(auth);
const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((c)=>{ if(token.value) c.headers.Authorization = `Bearer ${token.value}`; return c;});

const students = ref([]);
const meta = ref(null);
const page = ref(1);
const loading = ref(false);
const saving = ref(false);

const form = ref({ id:null, first_name:'', last_name:'', email:'', matricule:'', filiere:'', password:'' });
const editing = ref(false);
let modal;

const load = async () => {
  loading.value = true;
  try {
    const { data } = await api.get(`/admin/students?page=${page.value}`);
    students.value = data.data; meta.value = data.meta;
  } finally { loading.value = false; }
};
const goPage = (p) => { if (p>=1 && p<=meta.value.last_page){ page.value=p; load(); } };

const openCreate = () => {
  editing.value = false; form.value = { id:null, first_name:'', last_name:'', email:'', matricule:'', filiere:'', password:'' };
  showModal();
};
const openEdit = (s) => {
  editing.value = true; form.value = { id:s.id, first_name:s.first_name, last_name:s.last_name, email:s.email, matricule:s.matricule, filiere:s.filiere, password:'' };
  showModal();
};
const save = async () => {
  saving.value = true;
  try {
    if (!form.value.last_name || !form.value.first_name || !form.value.email || !form.value.matricule) {
      alert('Veuillez remplir Nom, Prénom, Email et Matricule.');
      return;
    }
    if (editing.value) {
      const payload = { ...form.value }; delete payload.id; if (!payload.password) delete payload.password;
      await api.put(`/admin/students/${form.value.id}`, payload);
    } else {
      if (!form.value.password || form.value.password.length < 8) { alert('Mot de passe minimum 8 caractères'); return; }
      await api.post('/admin/students', form.value);
    }
    hideModal(); await load();
  } catch (e) {
    alert('Erreur lors de l\'enregistrement');
  } finally { saving.value = false; }
};
const remove = async (s) => {
  if (!confirm('Supprimer cet étudiant ?')) return;
  await api.delete(`/admin/students/${s.id}`);
  await load();
};

function showModal(){ const m = new bootstrap.Modal(document.getElementById('studentModal')); modal=m; m.show(); }
function hideModal(){ modal?.hide(); }

function goShow(s){ router.push({ name: 'admin-student-show', params: { id: s.id } }); }

function splitName(full) {
  if (!full) return { first: '', last: '' };
  const parts = String(full).trim().split(/\s+/);
  if (parts.length === 1) return { first: parts[0], last: '' };
  const first = parts.slice(0, -1).join(' ');
  const last = parts[parts.length - 1];
  return { first, last };
}
function displayFirst(s){
  if (s.first_name) return s.first_name;
  const { first } = splitName(s.name);
  return first;
}
function displayLast(s){
  if (s.last_name) return s.last_name;
  const { last } = splitName(s.name);
  return last;
}

onMounted(load);
</script>
