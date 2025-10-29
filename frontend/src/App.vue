<template>
  <div>
    <div v-if="isAuthenticated && !isLoginRoute" class="min-h-screen">
      <BaseHeader @toggleSidebar="sidebarOpen = !sidebarOpen" />
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex gap-6 py-6">
          <BaseSidebar :open="sidebarOpen" />
          <main class="flex-1 min-w-0">
            <RouterView />
          </main>
        </div>
      </div>
    </div>
    <div v-else>
      <RouterView />
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRoute } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useAuthStore } from './stores/auth';
import BaseHeader from './components/BaseHeader.vue';
import BaseSidebar from './components/BaseSidebar.vue';

const sidebarOpen = ref(false);
const route = useRoute();
const auth = useAuthStore();
const { isAuthenticated } = storeToRefs(auth);
const isLoginRoute = computed(() => route.name === 'login');
</script>
