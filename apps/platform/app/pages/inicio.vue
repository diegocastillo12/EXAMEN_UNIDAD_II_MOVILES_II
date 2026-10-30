<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
import NotificationBell from '../features/notifications/presentation/widgets/NotificationBell.vue';
import StatisticsEntry from '../features/statistics/presentation/widgets/StatisticsEntry.vue';
useHead({ title: 'Inicio · Entre Huellas', meta: [{ name: 'robots', content: 'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell intensity="soft"><AccountScreen><template #alerts="{session}"><NotificationBell :key="session.actor" :actor="session.actor" /></template><template #management="{session}"><NavigationLink to="/coincidencias" class="secondary" origin>Buscar coincidencias</NavigationLink><StatisticsEntry :key="session.actor" :actor="session.actor" /></template></AccountScreen></AmbientPageShell></template>

