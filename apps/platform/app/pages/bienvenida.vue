<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
useHead({ title: 'Bienvenida · Entre Huellas', meta: [{ name: 'robots', content: 'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell intensity="strong"><AccountScreen onboarding /></AmbientPageShell></template>

