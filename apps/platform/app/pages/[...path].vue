<script setup lang="ts">
import CaseReader from '../features/case_reader/presentation/screens/CaseReader.vue';
useSeoMeta({ robots: 'noindex,nofollow' });
</script>
<template><CaseReader slug="" :initial="{ state: 'unavailable' }" :failed="false" /></template>
