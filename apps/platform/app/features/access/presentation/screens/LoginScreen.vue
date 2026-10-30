<script setup lang="ts">
import '../styles/login.css';
import '../styles/credentials.css';
import { useStaggerReveal, vStaggerReveal } from '~/composables/useStaggerReveal';
import LoginInput from '../widgets/LoginInput.vue';
import SocialSignInButton from '../widgets/SocialSignInButton.vue';
import type { SocialProvider } from '#shared/features/access/domain/access';
const { revealStyle } = useStaggerReveal({ count: 5 });
const model = useNuxtApp().$accessModel();
const state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const consumeNotice = useRouteNotice();
const route = useRoute();
const toast = useTemplateRef('toast');
const email = ref('');
const password = ref('');
const messages = {
  invalid: 'Revisa el correo y la contraseña.',
  unauthenticated: 'No pudimos iniciar sesión. Revisa el correo y la contraseña.',
  forbidden: 'Acceso denegado. No se pudo autorizar esta solicitud. Vuelve a intentarlo.',
  unavailable: 'No pudimos conectar. Puedes volver a intentarlo.',
  conflict: 'La sesión cambió. Vuelve a intentarlo.',
};
let channel: BroadcastChannel | undefined;
let leaving = false;
let noticesReady = false;
async function social(provider: SocialProvider) {
  password.value='';
  const url=await model.signInWithProvider(provider);
  if(url)await navigateTo(url,{external:true});
}
async function login() {
  await model.login(email.value, password.value);
  password.value = '';
  if (state.value.session) channel?.postMessage({ actor: state.value.session.actor });
}
watch(() => state.value.notice, () => { if (state.value.failure) toast.value?.show(messages[state.value.failure.kind]); });
watch(() => state.value.session, async session => {
  if (session && !leaving) { leaving = true; await navigateTo(session.profile.onboardingCompleted ? '/inicio' : '/bienvenida', { replace: true }); }
});
async function showRouteNotice() {
  if (!state.value.session && !state.value.failure) {
    const reason = await consumeNotice(['forbidden', 'expired', 'oauth-failed', 'oauth-cancelled', 'signed-out']);
    if (reason === 'forbidden') toast.value?.show(messages.forbidden);
    if (reason === 'expired') toast.value?.show('La sesión expiró. Vuelve a iniciar sesión.');
    if (reason === 'oauth-failed') toast.value?.show('No pudimos completar el acceso. Vuelve a intentarlo.');
    if (reason === 'oauth-cancelled') toast.value?.show('Inicio de sesión cancelado.', null, false);
    if (reason === 'signed-out') toast.value?.show('Sesión cerrada.', null, false);
  }
}
watch(() => route.query.reason, () => { if (noticesReady) void showRouteNotice(); });
onMounted(async () => {
  channel = new BroadcastChannel('eh-access');
  channel.onmessage = () => { password.value = ''; model.invalidate(); model.checkSession(); };
  await model.checkSession();
  noticesReady = true;
  await showRouteNotice();
});
onBeforeUnmount(() => { unsubscribe(); model.dispose(); password.value = ''; channel?.close(); });
</script>
<template>
  <div class="login-layout">
  <SiteHeader class="login-header" brand-class="login-brand" />
  <main id="view" class="login-screen">
    <header class="login-heading">
      <h1 class="stagger-reveal-item" v-stagger-reveal="revealStyle(0)">Inicia sesión</h1>
      <p class="stagger-reveal-item" v-stagger-reveal="revealStyle(1)">Más caminos de vuelta a casa.</p>
    </header>
    <TopToast ref="toast" />
    <form class="login-form stagger-reveal-item" v-stagger-reveal="revealStyle(2)" :aria-busy="state.checking || state.busy" novalidate @submit.prevent="login">
      <LoginInput v-model="email" label="Correo" :disabled="state.busy || state.checking || !!state.session" :invalid="state.failure?.kind==='invalid'" :notice="state.notice" />
      <LoginInput v-model="password" label="Contraseña" password :disabled="state.busy || state.checking || !!state.session" :invalid="state.failure?.kind==='invalid'" :notice="state.notice" />
      <NavigationLink class="login-recovery" to="/recuperar-contrasena">¿Olvidaste tu contraseña?</NavigationLink>
      <ActionButton class="login-submit" type="submit" variant="primary" :working="state.busy && !state.socialProvider" :disabled="state.checking || !!state.session || !!state.socialProvider">Iniciar Sesión</ActionButton>
      <div class="login-divider"><span>o continúa con</span></div>
      <SocialSignInButton provider="google" :working="state.busy && state.socialProvider==='google'" :disabled="state.busy || state.checking || !!state.session" @choose="social" />
      <SocialSignInButton provider="facebook" :working="state.busy && state.socialProvider==='facebook'" :disabled="state.busy || state.checking || !!state.session" @choose="social" />
    </form>
    <p class="login-register stagger-reveal-item" v-stagger-reveal="revealStyle(3)"><span>¿Aún no tienes cuenta?</span> <NavigationLink to="/crear-cuenta">Crear cuenta</NavigationLink></p>
    <p class="login-legal stagger-reveal-item" v-stagger-reveal="revealStyle(4)">Al iniciar sesión, aceptas nuestros <NavigationLink to="/terminos">Términos de servicio</NavigationLink> y reconoces haber leído nuestra <NavigationLink to="/privacidad">Política de privacidad</NavigationLink>.</p>
  </main>
  </div>
</template>
