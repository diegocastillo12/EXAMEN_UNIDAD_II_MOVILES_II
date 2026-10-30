<script setup lang="ts">
defineProps<{title:string;backLabel:string;titleId?:string}>();
const emit=defineEmits<{back:[]}>();
</script>
<template><header class="entity-page-header"><GlassNavigationButton :label="backLabel" @navigate="emit('back')" /><h1 :id="titleId">{{title}}</h1></header></template>
<style scoped>
.entity-page-header{display:flex;align-items:flex-start;gap:1rem;margin-bottom:1.5rem}.entity-page-header h1{margin:0;min-width:0;max-width:100%;overflow-wrap:anywhere}.entity-page-header :deep(.glass-navigation){position:static;flex:0 0 auto}@media(max-width:600px){.entity-page-header{flex-direction:column}}
</style>
