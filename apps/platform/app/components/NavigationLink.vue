<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router';
import { routeAccess } from '#shared/routing/route_policy';
defineOptions({ inheritAttrs: false });
const props = defineProps<{ to: RouteLocationRaw; origin?:boolean }>();
const app = useNuxtApp(),router = useRouter();
const working = ref(false);
let preparing: Promise<void> | undefined;
function prepare() {
  if (preparing || router.resolve(props.to).fullPath === router.currentRoute.value.fullPath) return;
  const path = router.resolve(props.to).path;
  preparing = (async () => {
    const code = preloadRouteComponents(props.to, router).catch(() => {});
    const policy = routeAccess(path);
    if (policy !== 'public' && policy !== 'recovery') {
      const model = app.$accessModel();
      try { await model.checkSession(); } finally { model.dispose(); }
    }
    await code;
  })().finally(() => { preparing = undefined; });
}
async function follow(event: MouseEvent, navigate: (event?: MouseEvent) => Promise<unknown>) {
  if (working.value || app.$originTransition.busy.value) { event.preventDefault(); return; }
  // Preserve browser conventions: new tab/window and modified clicks.
  if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey ||
      (event.currentTarget as HTMLAnchorElement).target === '_blank') return;
  if (router.resolve(props.to).fullPath === router.currentRoute.value.fullPath) { event.preventDefault(); return; }
  working.value = true;
  try {
    if (props.origin) {
      const source = event.currentTarget as HTMLElement;
      // Prevent default synchronously; router callbacks still run all guards.
      event.preventDefault();
      const to = router.resolve(props.to).path;
      await app.$originTransition.open(source,() => router.push(props.to),{from:router.currentRoute.value.path,to,current:() => router.currentRoute.value.path});
    } else await navigate(event);
  }
  finally { working.value = false; }
}
</script>
<template>
  <NuxtLink :to="to" custom v-slot="{ href, navigate, isExactActive }">
    <a :href="href ?? undefined" v-bind="$attrs" class="navigation-link" :class="{ working }" :aria-busy="working" :aria-disabled="working || undefined" :aria-current="isExactActive ? 'page' : undefined" @pointerenter="prepare" @focus="prepare" @pointerdown="prepare" @click="follow($event, navigate)"><slot /></a>
  </NuxtLink>
</template>
