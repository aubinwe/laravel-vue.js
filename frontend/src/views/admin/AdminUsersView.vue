<template>
  <div class="space-y-6">
    <div class="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
      <div>
        <h1 class="text-xl font-semibold text-slate-800">Utilisateurs</h1>
        <p class="text-slate-500 text-sm">Créer des comptes et filtrer par rôle</p>
      </div>
      <div class="flex items-end gap-2">
        <select v-model="filters.role" class="rounded-md border px-3 py-2 text-sm">
          <option value="">Tous les rôles</option>
          <option value="admin">Admin</option>
          <option value="teacher">Professeur</option>
          <option value="user">Étudiant</option>
        </select>
        <input v-model="filters.q" placeholder="Recherche nom/email" class="rounded-md border px-3 py-2 text-sm" />
        <button @click="load" class="rounded-md border px-3 py-2 text-sm hover:bg-slate-50">Filtrer</button>
      </div>
    </div>

    <div class="rounded-xl border bg-white p-4">
      <div class="font-medium mb-3">Créer un utilisateur</div>
      <div class="grid grid-cols-1 md:grid-cols-5 gap-3">
        <input v-model="form.name" placeholder="Nom complet" class="rounded-md border px-3 py-2 text-sm" />
        <input v-model="form.email" type="email" placeholder="Email" class="rounded-md border px-3 py-2 text-sm" />
        <input v-model="form.password" type="password" placeholder="Mot de passe" class="rounded-md border px-3 py-2 text-sm" />
        <select v-model="form.role" class="rounded-md border px-3 py-2 text-sm">
          <option value="user">Étudiant</option>
          <option value="teacher">Professeur</option>
          <option value="admin">Admin</option>
        </select>
        <button @click="createUser" class="rounded-md bg-slate-900 px-3 py-2 text-sm text-white hover:bg-slate-800" :disabled="saving">{{ saving?'...':'Créer' }}</button>
      </div>
    </div>

    <div class="rounded-xl border bg-white overflow-hidden">
      <div class="px-4 py-3 border-b font-medium">Liste des utilisateurs</div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-200">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Nom</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Email</th>
              <th class="px-4 py-2 text-left text-xs font-medium uppercase text-slate-600">Rôle</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-200 bg-white">
            <tr v-for="u in users" :key="u.id">
              <td class="px-4 py-2">{{ u.name }}</td>
              <td class="px-4 py-2">{{ u.email }}</td>
              <td class="px-4 py-2 capitalize">{{ u.role }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="px-4 py-2 text-sm text-slate-500" v-if="meta">Page {{ meta.current_page }} / {{ meta.last_page }}</div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import api from '../../lib/api';

const users = ref<any[]>([]);
const meta = ref<any>(null);
const saving = ref(false);
const filters = ref({ role: '', q: '' });
const form = ref({ name: '', email: '', password: '', role: 'user' });

const load = async () => {
  const params: any = {};
  if (filters.value.role) params.role = filters.value.role;
  if (filters.value.q) params.q = filters.value.q;
  const r = await api.get('/admin/users', { params });
  users.value = r.data.data || r.data;
  meta.value = r.data.meta || null;
};

const createUser = async () => {
  if (!form.value.name || !form.value.email || !form.value.password) return;
  saving.value = true;
  try {
    await api.post('/admin/users', form.value);
    form.value = { name: '', email: '', password: '', role: form.value.role };
    await load();
  } finally { saving.value = false; }
};

onMounted(load);
</script>
