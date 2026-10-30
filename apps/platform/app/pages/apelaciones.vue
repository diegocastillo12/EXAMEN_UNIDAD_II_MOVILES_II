<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
import AppealsScreen from '../features/appeals/presentation/screens/AppealsScreen.vue';
const screen = useTemplateRef('screen');
const beforeLogout = () => screen.value?.canLeave() ?? Promise.resolve(true);
useHead({ title: 'Mis apelaciones · Entre Huellas', meta: [{ name: 'robots', content: 'noindex, nofollow, noarchive' }] });
</script>
<template><AmbientPageShell intensity="soft"><AccountScreen :before-logout="beforeLogout"><template #default="{ session }"><AppealsScreen ref="screen" :key="session.actor" :actor="session.actor" /></template></AccountScreen></AmbientPageShell></template>
