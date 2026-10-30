<script setup lang="ts">
defineProps<{ name: 'chevron' | 'calendar' | 'clock' | 'search' | 'left' | 'right' }>();
</script>
<template>
  <svg class="sader-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
    <path v-if="name === 'chevron'" d="m6 9 6 6 6-6" />
    <path v-else-if="name === 'left'" d="m15 18-6-6 6-6" />
    <path v-else-if="name === 'right'" d="m9 18 6-6-6-6" />
    <template v-else-if="name === 'calendar'"><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M16 3v4M8 3v4M3 11h18" /></template>
    <template v-else-if="name === 'clock'"><circle cx="12" cy="12" r="10" /><path d="M12 6v6l4 2" /></template>
    <template v-else><circle cx="11" cy="11" r="8" /><path d="m21 21-4.3-4.3" /></template>
  </svg>
</template>
