<template>
  <div class="min-h-screen flex items-center justify-center px-4">
    <div class="w-full max-w-md rounded-xl border bg-white p-6 shadow">
      <h1 class="text-xl font-semibold text-slate-800 mb-4">Connexion</h1>
      <div v-if="error" class="mb-3 rounded-md bg-rose-50 border border-rose-200 px-3 py-2 text-rose-700 text-sm">{{ error }}</div>
      <form @submit.prevent="onSubmit" class="space-y-3">
        <div>
          <label class="block text-sm text-slate-600 mb-1">Email</label>
          <input v-model="email" type="email" required class="w-full rounded-md border px-3 py-2 text-sm" />
        </div>
        <div>
          <label class="block text-sm text-slate-600 mb-1">Mot de passe</label>
          <input v-model="password" type="password" required class="w-full rounded-md border px-3 py-2 text-sm" />
        </div>
        <div>
          <label class="block text-sm text-slate-600 mb-1">Rôle (indicatif)</label>
          <select v-model="roleHint" class="w-full rounded-md border px-3 py-2 text-sm">
            <option value="">Automatique</option>
            <option value="admin">Admin</option>
            <option value="teacher">Professeur</option>
            <option value="user">Étudiant</option>
          </select>
          <p class="text-xs text-slate-500 mt-1">La redirection suit toujours le rôle défini côté serveur.</p>
        </div>
        <button class="w-full inline-flex items-center justify-center rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-800" :disabled="loading">
          <span v-if="loading" class="me-2">...</span>
          Se connecter
        </button>
      </form>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref } from 'vue';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';

const auth = useAuthStore();
const { loading, error } = storeToRefs(auth);

const email = ref('');
const password = ref('');
const roleHint = ref('');

const onSubmit = async () => { await auth.login(email.value, password.value); };
</script>
