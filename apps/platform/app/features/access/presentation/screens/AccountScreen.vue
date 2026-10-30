<script setup lang="ts">
import '../styles/account.css';
import OnboardingFlow from '../widgets/OnboardingFlow.vue';
import HomeContent from '../widgets/HomeContent.vue';
import AccountProfile from '../widgets/AccountProfile.vue';
const props = withDefaults(defineProps<{ onboarding?: boolean; beforeLogout?: () => Promise<boolean> }>(), { onboarding: false });
const model = useNuxtApp().$accessModel();
const state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast');
const consumeNotice = useRouteNotice();
const route = useRoute();
const navigation = useNuxtApp().$navigationActor,motion = useNuxtApp().$originTransition;
watch(() => [state.value.session,state.value.checking] as const,([session,checking]) => {
  if (session?.profile.onboardingCompleted && !props.onboarding) navigation.value = session.actor;
  else if (!checking) { navigation.value = null; motion.clear(); }
},{ immediate:true });
const onboardingView = useTemplateRef('onboardingView');
const nextStep = () => model.nextStep();
useHead(() => props.onboarding ? { link: [
  { rel: 'preload', as: 'font', type: 'font/woff2', href: '/fonts/inter-latin.woff2', crossorigin: 'anonymous' },
  { rel: 'preload', as: 'image', href: '/images/onboarding/dog_waving.png' },
] } : {});
const messages = {
  invalid: 'Revisa la información e inténtalo de nuevo.',
  unauthenticated: 'La sesión terminó. Vuelve a iniciar sesión.',
  forbidden: 'No pudimos autorizar esta operación.',
  conflict: 'La cuenta cambió. Vuelve a iniciar sesión.',
  unavailable: 'No pudimos completar la operación. Puedes volver a intentarlo.',
};
let channel: BroadcastChannel | undefined;
let expiry: ReturnType<typeof setTimeout> | undefined;
let leaving = false;
let signingOut = false;
let noticesReady = false;
async function logout() {
  if (props.beforeLogout && !await props.beforeLogout()) return;
  signingOut = true;
  const done = await model.logout();
  channel?.postMessage('changed');
  signingOut = false;
  if (done) await navigateTo('/iniciar-sesion?reason=signed-out', { replace: true });
}
watch(() => state.value.notice, () => {
  if (state.value.failure) toast.value?.show(messages[state.value.failure.kind]);
});
watch(() => state.value.session, async (session, previous) => {
  clearTimeout(expiry);
  if (!session || leaving) return;
  expiry = setTimeout(() => { model.invalidate(); navigateTo('/iniciar-sesion?reason=expired', { replace: true }); }, Math.max(0, session.expiresAt - Date.now()));
  if (!session.profile.onboardingCompleted && !props.onboarding) { leaving = true; await navigateTo('/bienvenida', { replace: true }); }
  else if (session.profile.onboardingCompleted && props.onboarding) {
    if (previous?.actor === session.actor && !previous.profile.onboardingCompleted) {
      if (await onboardingView.value?.finish() === false) return;
      if (state.value.session?.actor !== session.actor) return;
    }
    leaving = true; channel?.postMessage({ actor: session.actor }); await navigateTo('/inicio', { replace: true });
  }
  else if (!props.onboarding && route.path === '/inicio') await model.loadManagementAccess();
}, { immediate:true });
watch(() => [state.value.checking, state.value.session] as const, async ([checking, session]) => {
  if (!session && !checking && !signingOut && !leaving && ['unauthenticated', 'conflict'].includes(state.value.failure?.kind || '')) {
    leaving = true; await navigateTo('/iniciar-sesion?reason=expired', { replace: true }); return;
  }
  if (!checking && !session && !state.value.failure && !signingOut && !state.value.busy && !leaving) {
    leaving = true; await navigateTo('/iniciar-sesion', { replace: true });
  }
});
async function showRouteNotice() {
  if (!props.onboarding && state.value.session && await consumeNotice(['forbidden']) === 'forbidden') toast.value?.show('Tu cuenta no tiene permiso para acceder a esa sección de gestión.');
}
watch(() => route.query.reason, () => { if (noticesReady) void showRouteNotice(); });
onMounted(async () => {
  if (props.onboarding) for (const name of ['dog_with_map.png', 'dog_and_cat.png']) { const image = new Image(); image.src = '/images/onboarding/' + name; }
  channel = new BroadcastChannel('eh-access');
  channel.onmessage = event => {
    if (event.data?.actor && event.data.actor === state.value.session?.actor) return;
    toast.value?.close(); model.invalidate(); model.checkSession();
  };
  // The global route policy already checked this identity. Reuse only the
  // transport's still-fresh browser snapshot; direct SSR loads still check.
  if (!state.value.session) await model.checkSession();
  // Only identity mutations broadcast. Announcing an ordinary page mount
  // invalidated this browser's own transport and defeated its short reuse.
  noticesReady = true;
  await showRouteNotice();
});
onBeforeUnmount(() => { unsubscribe(); model.dispose(); channel?.close(); channel = undefined; clearTimeout(expiry); });
</script>
<template>
  <div class="account-layout" :class="{ 'onboarding-layout': onboarding }">
    <SiteHeader v-if="onboarding" class="onboarding-header" brand-class="onboarding-brand" />
    <SiteHeader v-else class="account-header" brand-class="account-brand">
      <div v-if="state.session || state.busy" class="account-header-actions">
        <template v-if="state.session?.profile.onboardingCompleted"><slot name="alerts" :session="state.session" /><AccountProfile :key="state.session.actor" :session="state.session" /></template>
        <GlassSurface as="button" type="button" class="account-icon account-logout" :class="{working:state.busy}" :disabled="state.busy" :aria-busy="state.busy" aria-label="Cerrar sesión" title="Cerrar sesión" @click="logout"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 4H4v16h5M14 8l4 4-4 4M8 12h12" /></svg></GlassSurface>
      </div>
    </SiteHeader>
    <TopToast ref="toast" />
    <OriginPageSurface id="view" class="account-main">
      <ContentSkeleton v-if="state.checking" label="Consultando tu cuenta" />
      <template v-else-if="state.session">
        <OnboardingFlow v-if="onboarding" ref="onboardingView" :step="state.step" :busy="state.busy" :on-next="nextStep" />
        <template v-else-if="state.session.profile.onboardingCompleted">
          <slot :session="state.session">
          <StaggerReveal as="div" class="account-grid" :aria-busy="state.checkingManagement">
            <HomeContent />
            <NavigationLink to="/apelaciones" class="secondary">Mis apelaciones</NavigationLink>
            <slot name="management" :session="state.session" />
            <section v-if="state.canReview" class="account-management account-panel" aria-labelledby="management-title">
              <div><h2 id="management-title">Cuidamos la comunidad</h2><p>Revisa las denuncias y ayuda a mantener un espacio seguro.</p></div>
              <NavigationLink to="/moderacion" origin class="secondary">Revisar denuncias</NavigationLink>
            </section>
            <ActionButton v-else-if="state.managementFailed" class="account-management-retry" :working="state.checkingManagement" @click="model.loadManagementAccess()">Reintentar acceso a gestión</ActionButton>
          </StaggerReveal>
          </slot>
        </template>
      </template>
      <ActionButton v-else-if="state.failure" :working="state.busy" @click="model.checkSession()">Reintentar conexión</ActionButton>
      <ContentSkeleton v-else label="Abriendo inicio de sesión" />
    </OriginPageSurface>
  </div>
</template>

