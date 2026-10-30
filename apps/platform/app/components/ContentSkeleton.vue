<script setup lang="ts">
withDefaults(defineProps<{label?:string}>(),{label:'Consultando caso'});
</script>
<template><div class="skeleton" :aria-label="label" aria-busy="true"><div class="shape hero-shape" /><div class="shape title-shape" /><div class="shape line-shape" /><div class="shape line-shape short" /></div></template>
