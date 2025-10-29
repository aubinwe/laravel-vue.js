<template>
  <div>
    <div v-if="isAuthenticated">
      <BaseHeader @toggleSidebar="sidebarOpen = !sidebarOpen" />
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex gap-6 py-6">
          <BaseSidebar :open="sidebarOpen" />
          <main class="flex-1 min-w-0">
            <router-view />
          </main>
        </div>
      </div>
    </div>
    <div v-else>
      <router-view />
    </div>
    <BaseToast />
  </div>
</template>
<script setup>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';
import { useAuthStore } from './stores/auth';
import BaseHeader from './components/BaseHeader.vue';
import BaseSidebar from './components/BaseSidebar.vue';
import BaseToast from './components/BaseToast.vue';

const sidebarOpen = ref(false);
const auth = useAuthStore();
const { isAuthenticated } = storeToRefs(auth);
</script>
