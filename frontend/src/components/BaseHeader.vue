<template>
  <header class="sticky top-0 z-40 border-b bg-white/70 backdrop-blur supports-[backdrop-filter]:bg-white/60">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <button class="md:hidden inline-flex items-center justify-center rounded-md p-2 text-slate-600 hover:bg-slate-100" @click="$emit('toggleSidebar')">
          <i class="bi bi-list text-xl"></i>
        </button>
        <router-link to="/" class="font-semibold text-slate-800 tracking-tight">GestionNotes</router-link>
      </div>
      <div class="flex items-center gap-3">
        <div v-if="user" class="flex items-center gap-2">
          <span class="text-sm text-slate-600">{{ user.name }}</span>
          <span class="px-2 py-0.5 text-xs rounded-full bg-slate-100 text-slate-700 capitalize">{{ user.role }}</span>
          <button class="ml-2 inline-flex items-center rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50" @click="onLogout">Déconnexion</button>
        </div>
      </div>
    </div>
  </header>
</template>
<script setup lang="ts">
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
const auth = useAuthStore();
const { user } = storeToRefs(auth);
const onLogout = async () => { await auth.logout(); };
</script>
