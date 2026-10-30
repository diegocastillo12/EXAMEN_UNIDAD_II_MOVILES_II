<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
import NotificationBell from '../features/notifications/presentation/widgets/NotificationBell.vue';
import RecoveryScreen from '../features/recovery/presentation/screens/RecoveryScreen.vue';
useHead({ title:'Reportar · Entre Huellas',meta:[{ name:'robots',content:'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell><AccountScreen><template #alerts="{session}"><NotificationBell :key="session.actor" :actor="session.actor" /></template><template #default="{session}"><RecoveryScreen :key="session.actor" :actor="session.actor" section="report" /></template></AccountScreen></AmbientPageShell></template>
