<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h4 class="mb-0">Matières</h4>
        <button class="btn btn-primary" @click="openCreate">Nouvelle matière</button>
      </div>

      <div v-if="loading" class="text-center py-5"><div class="spinner-border"></div></div>
      <div v-else class="table-responsive">
        <table class="table table-striped align-middle">
          <thead>
          <tr>
            <th>Nom</th>
            <th>Coefficient</th>
            <th></th>
          </tr>
          </thead>
          <tbody>
          <tr v-for="s in subjects" :key="s.id">
            <td>{{ s.name }}</td>
            <td>{{ s.coefficient }}</td>
            <td class="text-end">
              <div class="btn-group">
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

      <div class="modal fade" id="subjectModal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">{{ editing ? 'Modifier' : 'Créer' }} une matière</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              <div class="row g-2">
                <div class="col-8"><input v-model="form.name" class="form-control" placeholder="Nom"/></div>
                <div class="col-4"><input v-model.number="form.coefficient" type="number" min="1" class="form-control" placeholder="Coef."/></div>
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
import axios from 'axios';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
import Navbar from '../components/Navbar.vue';
import * as bootstrap from 'bootstrap';

const auth = useAuthStore();
const { token } = storeToRefs(auth);
const api = axios.create({ baseURL: '/api/v1' });
api.interceptors.request.use((c)=>{ if(token.value) c.headers.Authorization = `Bearer ${token.value}`; return c;});

const subjects = ref([]);
const meta = ref(null);
const page = ref(1);
const loading = ref(false);
const saving = ref(false);

const form = ref({ id:null, name:'', coefficient:1 });
const editing = ref(false);
let modal;

const load = async () => {
  loading.value = true;
  try {
    const { data } = await api.get(`/admin/subjects?page=${page.value}`);
    subjects.value = data.data; meta.value = data.meta;
  } finally { loading.value = false; }
};
const goPage = (p) => { if (p>=1 && p<=meta.value.last_page){ page.value=p; load(); } };

const openCreate = () => { editing.value=false; form.value={id:null,name:'',coefficient:1}; showModal(); };
const openEdit = (s) => { editing.value=true; form.value={id:s.id,name:s.name,coefficient:s.coefficient}; showModal(); };

const save = async () => {
  saving.value = true;
  try {
    if (!form.value.name || !form.value.coefficient || form.value.coefficient < 1) {
      alert('Nom requis et coefficient >= 1');
      return;
    }
    if (editing.value) {
      const payload = { name: form.value.name, coefficient: form.value.coefficient };
      await api.put(`/admin/subjects/${form.value.id}`, payload);
    } else {
      await api.post('/admin/subjects', form.value);
    }
    hideModal(); await load();
  } catch (e) {
    alert('Erreur lors de l\'enregistrement');
  } finally { saving.value = false; }
};
const remove = async (s) => { if(!confirm('Supprimer cette matière ?')) return; await api.delete(`/admin/subjects/${s.id}`); await load(); };

function showModal(){ const m = new bootstrap.Modal(document.getElementById('subjectModal')); modal=m; m.show(); }
function hideModal(){ modal?.hide(); }

onMounted(load);
</script>
