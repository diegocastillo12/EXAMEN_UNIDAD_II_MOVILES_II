<script setup lang="ts">
import AccountScreen from '../../../features/access/presentation/screens/AccountScreen.vue';
import PublicationScreen from '../../../features/recovery/presentation/screens/PublicationScreen.vue';
const route=useRoute();
const source=({perdidos:'lost',encontrados:'found'} as Record<string,'lost'|'found'>)[String(route.params.source)] || 'invalid' as 'lost'|'found',id=String(route.params.id);
useHead({title:'Ficha del caso · Entre Huellas',meta:[{name:'robots',content:'noindex, nofollow, noarchive'}]});
</script>
<template><AmbientPageShell><AccountScreen><template #default="{session}"><PublicationScreen :key="session.actor+source+id" :actor="session.actor" :source="source" :id="id" /></template></AccountScreen></AmbientPageShell></template>
