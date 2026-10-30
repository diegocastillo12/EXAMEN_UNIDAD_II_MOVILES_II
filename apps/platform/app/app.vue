<script setup lang="ts">
const route = useRoute(),app = useNuxtApp();
// Nuxt watches this function's identity and starts page loading when it changes.
// Keep it stable when navigationActor or the persistent navigation rerenders.
const pageKey = (pageRoute: { path: string }) => pageRoute.path;
const accountRoute = computed(() => ['/inicio','/explorar','/mis-mascotas','/reportar'].includes(route.path));
const originPageTransition={css:false,onBeforeEnter:app.$originTransition.preparePage,onLeave:app.$originTransition.retainPage};
</script>
<template>
  <TopLoadingBar />
  <NuxtPage :page-key="pageKey" :transition="originPageTransition" />
  <div v-if="app.$navigationActor.value" v-show="accountRoute" class="reader-shell user-navigation-host"><UserNavigation /></div>
  <OriginTransitionHost />
</template>
<style>
.reader-shell.user-navigation-host{min-height:0;background:none}
.reader-shell.origin-route-entering{background:transparent;position:relative;z-index:1}
.origin-route-entering > .background-glow{visibility:hidden}
</style>
