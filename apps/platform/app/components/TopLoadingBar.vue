<script setup lang="ts">
// Nuxt starts before access middleware. Settle on route commit too: a reused
// page or a same-page URL change need not create another Suspense resolution.
const router = useRouter(), app = useNuxtApp(), visible = ref(false);
const start = app.hook('page:loading:start', () => { visible.value = true; });
const end = app.hook('page:loading:end', () => { visible.value = false; });
const finish = app.hook('page:finish', () => { visible.value = false; });
const after = router.afterEach(() => { visible.value = false; });
const error = router.onError(() => { visible.value = false; });
onBeforeUnmount(() => { start(); end(); finish(); after(); error(); });
</script>
<template><div v-if="visible" class="sader-top-loader" role="progressbar" aria-label="Cargando página" aria-busy="true" /></template>

