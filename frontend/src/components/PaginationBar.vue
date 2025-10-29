<template>
  <nav v-if="meta && (meta.prev_page_url || meta.next_page_url)" class="flex items-center justify-between px-2 py-2">
    <button :disabled="!meta.prev_page_url" @click="$emit('change', meta.current_page - 1)"
            class="inline-flex items-center rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed">
      Précédent
    </button>
    <div class="text-sm text-slate-600">Page {{ meta.current_page }} / {{ meta.last_page }}</div>
    <button :disabled="!meta.next_page_url" @click="$emit('change', meta.current_page + 1)"
            class="inline-flex items-center rounded-md border px-3 py-1.5 text-sm hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed">
      Suivant
    </button>
  </nav>
</template>
<script setup lang="ts">
// Props: Laravel pagination meta (current_page, last_page, prev_page_url, next_page_url)
defineProps<{ meta: any }>();
</script>
