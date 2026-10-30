<script setup lang="ts">
defineProps<{name:'schedule'|'campaign'|'arrow-right'}>();
</script>
<template>
  <AppIcon v-if="name!=='arrow-right'" :name="name" />
  <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14m-6-6 6 6-6 6" /></svg>
</template>
