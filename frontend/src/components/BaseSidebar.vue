<template>
  <aside :class="['border-r bg-white md:block', open ? 'block' : 'hidden']" class="w-64 h-full fixed md:static z-30">
    <nav class="p-4 space-y-2">
      <div class="text-xs font-semibold text-slate-500 uppercase px-2">Navigation</div>
      <RouterLink v-for="item in items" :key="item.to" :to="item.to"
                  class="flex items-center gap-2 rounded-md px-3 py-2 text-slate-700 hover:bg-slate-100"
                  active-class="bg-slate-100 font-semibold">
        <i :class="['bi', item.icon]"></i>
        <span>{{ item.label }}</span>
      </RouterLink>
    </nav>
  </aside>
</template>
<script setup lang="ts">
import { computed } from 'vue';
import { RouterLink } from 'vue-router';
import { storeToRefs } from 'pinia';
import { useAuthStore } from '../stores/auth';
const props = defineProps({ open: { type: Boolean, default: false } });
const auth = useAuthStore();
const { isAdmin, isTeacher } = storeToRefs(auth);
const items = computed(() => {
  if (isAdmin.value) return [
    { to: '/admin', label: 'Dashboard', icon: 'bi-speedometer2' },
  ];
  if (isTeacher.value) return [
    { to: '/teacher', label: 'Dashboard', icon: 'bi-speedometer2' },
  ];
  return [
    { to: '/student', label: 'Dashboard', icon: 'bi-speedometer2' },
  ];
});
</script>
<style scoped>
@media (min-width: 768px) { aside { display: block !important; } }
</style>
