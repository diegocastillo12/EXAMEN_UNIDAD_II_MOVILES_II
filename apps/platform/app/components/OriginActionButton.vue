<script setup lang="ts">
withDefaults(defineProps<{ action:()=>unknown|Promise<unknown>;working?:boolean;disabled?:boolean;variant?:string }>(),{ working:false,disabled:false,variant:'secondary' });
const motion = useNuxtApp().$originTransition,route = useRoute();
</script>
<template><ActionButton :variant="variant" :working="working" :disabled="disabled || motion.busy.value" @click="motion.open($event.currentTarget,action,{from:route.path,to:route.path})"><slot /></ActionButton></template>
