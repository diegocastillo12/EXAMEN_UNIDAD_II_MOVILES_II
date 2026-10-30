<script setup lang="ts">
defineProps<{ brandClass?: string }>();
</script>
<template>
  <header class="site-header"><SiteBrand :class="brandClass" /><slot /></header>
</template>
