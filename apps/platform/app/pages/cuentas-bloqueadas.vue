<script setup lang="ts">
import AccountScreen from '../features/access/presentation/screens/AccountScreen.vue';
import NotificationBell from '../features/notifications/presentation/widgets/NotificationBell.vue';
import UserBlocksScreen from '../features/user_blocks/presentation/screens/UserBlocksScreen.vue';
import { blockId } from '#shared/features/user_blocks/domain/user_blocks';
import type { BlockTarget } from '#shared/features/user_blocks/domain/user_blocks';
const route=useRoute();
const target=computed<BlockTarget|null>(()=>['lost','found','sighting'].includes(String(route.query.tipo)) && blockId(route.query.contenido)?{kind:route.query.tipo as BlockTarget['kind'],id:route.query.contenido}:null);
useHead({title:'Cuentas bloqueadas · Entre Huellas',meta:[{name:'robots',content:'noindex, nofollow, noarchive'}]});
</script>
<template><AmbientPageShell><AccountScreen><template #alerts="{session}"><NotificationBell :key="session.actor" :actor="session.actor" /></template><template #default="{session}"><UserBlocksScreen :key="session.actor+':'+target?.kind+':'+target?.id" :actor="session.actor" :target="target" /></template></AccountScreen></AmbientPageShell></template>
