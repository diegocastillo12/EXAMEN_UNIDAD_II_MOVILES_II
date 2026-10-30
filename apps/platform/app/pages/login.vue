<script setup lang="ts">
const route = useRoute();
await navigateTo({ path: '/iniciar-sesion', query: route.query, hash: route.hash }, { redirectCode: 308, replace: true });
</script>
<template><span /></template>
