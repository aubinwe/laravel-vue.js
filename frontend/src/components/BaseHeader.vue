<template>
  <header class="sticky top-0 z-40 border-b bg-gradient-to-r from-slate-50 to-white/80 backdrop-blur supports-[backdrop-filter]:bg-white/60">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <button class="md:hidden inline-flex items-center justify-center rounded-md p-2 text-slate-600 hover:bg-slate-100" @click="$emit('toggleSidebar')">
          <i class="bi bi-list text-xl"></i>
        </button>
        <router-link to="/" class="font-semibold text-slate-800 tracking-tight">GestionNotes</router-link>
      </div>
      <div class="flex items-center gap-3">
        <div v-if="user" class="flex items-center gap-3">
          <div class="h-8 w-8 rounded-full bg-slate-800 text-white flex items-center justify-center text-xs font-semibold">
            {{ initials(user.name) }}
          </div>
          <div class="hidden sm:flex flex-col leading-tight">
            <span class="text-sm text-slate-700">{{ user.name }}</span>
          </div>
          <span :class="roleClass(user.role)" class="capitalize">{{ user.role }}</span>
          <button class="ml-1 inline-flex items-center rounded-md bg-slate-900 text-white px-3 py-1.5 text-sm hover:bg-slate-800" @click="onLogout">Déconnexion</button>
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
function initials(name?: string){
  if (!name) return '?';
  const parts = name.trim().split(/\s+/);
  const i1 = parts[0]?.charAt(0) || '';
  const i2 = parts.length>1 ? parts[parts.length-1].charAt(0) : '';
  return (i1 + i2).toUpperCase();
}
function roleClass(role?: string){
  if (role === 'admin') return 'px-2 py-0.5 text-xs rounded-full bg-indigo-100 text-indigo-700';
  if (role === 'teacher') return 'px-2 py-0.5 text-xs rounded-full bg-emerald-100 text-emerald-700';
  return 'px-2 py-0.5 text-xs rounded-full bg-slate-100 text-slate-700';
}
</script>
