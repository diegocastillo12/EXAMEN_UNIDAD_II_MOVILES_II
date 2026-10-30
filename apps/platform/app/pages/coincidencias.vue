<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
import MatchingScreen from '../features/matching/presentation/screens/MatchingScreen.vue';
useHead({title:'Posibles coincidencias · Entre Huellas',meta:[{name:'robots',content:'noindex, nofollow, noarchive'}]});
</script>
<template><AmbientPageShell intensity="soft"><AccountScreen><template #default="{session}"><MatchingScreen :key="session.actor" :actor="session.actor"><template #case-link="{candidate}"><NavigationLink :to="'/casos/'+(candidate.ref.source==='lost'?'perdidos':'encontrados')+'/'+candidate.ref.id" class="secondary" origin>Ver ficha</NavigationLink></template></MatchingScreen></template></AccountScreen></AmbientPageShell></template>
