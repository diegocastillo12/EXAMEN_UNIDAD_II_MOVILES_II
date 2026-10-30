<script setup lang="ts">
import CaseReader from '../../features/case_reader/presentation/screens/CaseReader.vue';
import SightingForm from '../../features/sightings/presentation/screens/SightingForm.vue';
const route = useRoute(); const slug = String(route.params.slug || '');
const { $readPublicCase } = useNuxtApp();
const { data } = await useAsyncData(`public-case:${slug}`, async () => {
  try { return { value: await $readPublicCase(slug), failed: false }; }
  catch { return { value: null, failed: true }; }
}, { deep: false });
useSeoMeta({ title: 'Ficha del caso · Entre Huellas', robots: 'noindex,nofollow,noarchive,nosnippet' });
</script>
<template><CaseReader :slug="slug" :initial="data?.value || null" :failed="data?.failed || false"><template #sighting="{ activeCase, close }"><SightingForm :slug="slug" :active-case="activeCase" @close="close" /></template></CaseReader></template>
