<script setup lang="ts">
import AccountScreen from '../../features/access/presentation/screens/AccountScreen.vue';
import StatisticsScreen from '../../features/statistics/presentation/screens/StatisticsScreen.vue';
useHead({ title: 'Estadísticas · Entre Huellas', meta: [{ name: 'robots', content: 'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell intensity="soft"><AccountScreen><template #default="{session}"><StatisticsScreen :key="session.actor" :actor="session.actor" /></template></AccountScreen></AmbientPageShell></template>
