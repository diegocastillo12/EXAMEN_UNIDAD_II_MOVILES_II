<script setup lang="ts">
defineProps<{ name: 'paw' | 'report' | 'share' | 'heart' | 'people' | 'shield' }>();
</script>
<template>
  <svg v-if="name === 'paw'" viewBox="0 0 32 32" fill="currentColor" aria-hidden="true">
    <ellipse cx="7" cy="10" rx="3.4" ry="4.6" transform="rotate(-28 7 10)" /><ellipse cx="14" cy="6" rx="3.3" ry="4.5" /><ellipse cx="22" cy="7" rx="3.3" ry="4.5" transform="rotate(18 22 7)" /><ellipse cx="27" cy="14" rx="3.2" ry="4.3" transform="rotate(35 27 14)" /><path d="M6 24c0-4 4-5 6-9 2-4 6-4 8 0 2 3 6 5 6 9 0 6-6 4-10 3-4 1-10 3-10-3Z" />
  </svg>
  <svg v-else viewBox="0 0 24 24" :fill="name === 'heart' ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
    <template v-if="name === 'report'"><rect x="6" y="3" width="13" height="18" rx="2" /><path d="M10 8h5m-5 4h5m-5 4h5M3 7v13a3 3 0 0 0 3 3" /></template>
    <template v-else-if="name === 'share'"><circle cx="18" cy="5" r="3" /><circle cx="5" cy="12" r="3" /><circle cx="18" cy="19" r="3" /><path d="m8 11 7-4M8 13l7 4" /></template>
    <path v-else-if="name === 'heart'" d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8Z" />
    <template v-else-if="name === 'people'"><circle cx="12" cy="7" r="4" /><circle cx="21" cy="9" r="3" /><circle cx="3" cy="9" r="3" /><path d="M5 22v-4a7 7 0 0 1 14 0v4M20 14a5 5 0 0 1 4 5v3M4 14a5 5 0 0 0-4 5v3" /></template>
    <path v-else d="m12 2 9 4v6c0 5-4 8-9 10-5-2-9-5-9-10V6l9-4Z" />
  </svg>
</template>
