import { createOriginTransition } from '~/utils/origin_transition';
export default defineNuxtPlugin(app => {
  const navigationActor = shallowRef<string|null>(null);
  const originTransition = createOriginTransition(() => navigationActor.value);
  const removeBefore = app.$router.beforeEach((to,from) => originTransition.beforeRouteChange(to.path,from.path));
  const remove = app.$router.afterEach((to,from,failure) => { void originTransition.routeChanged(to.path,from.path,!!failure); });
  app.vueApp.onUnmount(() => { removeBefore(); remove(); originTransition.clear(); });
  return { provide:{ originTransition,navigationActor } };
});
