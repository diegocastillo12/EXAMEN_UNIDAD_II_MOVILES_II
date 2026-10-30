<script setup lang="ts">
import '../styles/login.css';
import '../styles/credentials.css';
import LoginInput from '../widgets/LoginInput.vue';
import type { CredentialKind, CredentialIssue } from '#shared/features/access/domain/credentials';
const props = withDefaults(defineProps<{ kind: CredentialKind; resetPage?: boolean }>(), { resetPage: false });
const model = useNuxtApp().$credentialModel();
const state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast');
const consumeNotice = useRouteNotice();
const name = ref(''), email = ref(''), password = ref(''), confirmation = ref(''), code = ref('');
const messages: Record<CredentialIssue, string> = {
  invalid_request: 'Revisa la información e inténtalo de nuevo.',
  invalid_name: 'Ingresa tu nombre (máximo 120 caracteres).', invalid_email: 'Ingresa un correo válido.',
  weak_password: 'Usa una contraseña de al menos 8 caracteres.', password_mismatch: 'Las contraseñas no coinciden.',
  invalid_code: 'El código no es válido o ha caducado. Revísalo o solicita otro.', expired: 'Esta solicitud ha caducado. Comienza de nuevo.',
  same_password: 'Elige una contraseña diferente a la anterior.', rate_limited: 'Espera un minuto antes de volver a intentarlo.',
  unavailable: 'No pudimos completar la solicitud. Puedes volver a intentarlo.', conflict: 'El acceso cambió en otra ventana. Vuelve a iniciar sesión.',
};
const stage = computed(() => state.value.completed ? 'complete' : props.resetPage ? 'reset' : state.value.progress?.stage === 'code' ? 'code' : props.kind === 'registration' ? 'register' : 'recover');
const title = computed(() => ({ register: 'Crea tu cuenta', recover: 'Recupera tu contraseña', code: 'Revisa tu correo', reset: 'Nueva contraseña', complete: 'Contraseña actualizada' })[stage.value]);
const description = computed(() => stage.value === 'code' ? (props.kind === 'registration' ? `Si tu correo necesita confirmación, recibirás un código de 6 dígitos en ${state.value.progress?.email}.` : `Si hay una cuenta asociada a ${state.value.progress?.email}, recibirás un código de 6 dígitos.`) : ({ register: 'Más caminos de vuelta a casa.', recover: 'Te enviaremos un código para recuperar tu acceso.', reset: 'Elige una nueva contraseña de al menos 8 caracteres.', complete: 'Ya puedes iniciar sesión con tu nueva contraseña.' })[stage.value as 'register' | 'recover' | 'reset' | 'complete']);
const invalid = (field: string) => {
  const issue = state.value.failure?.kind;
  return field === 'name' ? issue === 'invalid_name' : field === 'email' ? issue === 'invalid_email' : field === 'code' ? issue === 'invalid_code' : field === 'confirmation' ? issue === 'password_mismatch' : issue === 'weak_password' || issue === 'same_password';
};
let timer: ReturnType<typeof setInterval> | undefined;
let channel: BroadcastChannel | undefined;
let leaving = false;
async function initialize() { await model.initialize(props.kind, props.resetPage); }
watch(() => state.value.notice, () => {
  if (state.value.failure) toast.value?.show(messages[state.value.failure.kind], !state.value.ready ? initialize : null);
  else if (state.value.completed) toast.value?.show('Contraseña actualizada.', null, false);
  else if (state.value.resent) toast.value?.show('Código solicitado. Revisa también la carpeta de spam.', null, false);
});
watch(() => state.value.session, async session => {
  if (!session || leaving) return;
  leaving = true; password.value = ''; confirmation.value = ''; code.value = '';
  channel?.postMessage({ actor: session.actor });
  await navigateTo(session.profile.onboardingCompleted ? '/inicio' : '/bienvenida', { replace: true });
});
watch(() => state.value.progress, async progress => {
  if (progress) { password.value = ''; confirmation.value = ''; code.value = ''; }
  if (progress?.stage === 'reset' && !props.resetPage && !leaving) { leaving = true; await navigateTo('/restablecer-contrasena', { replace: true }); }
});
watch([name, email, password, confirmation, code], () => model.edited());
async function submit() {
  if (stage.value === 'register') await model.register(name.value, email.value, password.value, confirmation.value);
  else if (stage.value === 'recover') await model.recover(email.value);
  else if (stage.value === 'code') await model.verify(code.value);
  else if (stage.value === 'reset') { await model.reset(password.value, confirmation.value); if (state.value.completed) { password.value = ''; confirmation.value = ''; channel?.postMessage({ signedOut: true }); } }
}
async function changeEmail() { await model.cancel(); if (!state.value.failure) { code.value = ''; if (props.resetPage) await navigateTo('/recuperar-contrasena', { replace: true }); } }
async function back() {
  if (state.value.busy) return;
  // Returning to login clears the capability on the server; failure keeps retry available.
  if (state.value.progress) { await model.cancel(); if (state.value.failure) return; }
  await navigateTo('/iniciar-sesion');
}
onMounted(async () => {
  channel = new BroadcastChannel('eh-access');
  channel.onmessage = () => { password.value = ''; confirmation.value = ''; code.value = ''; void navigateTo('/iniciar-sesion', { replace: true }); };
  timer = setInterval(() => model.tick(), 1000);
  await initialize();
  if (await consumeNotice(['expired']) === 'expired') toast.value?.show(messages.expired);
});
onBeforeUnmount(() => { clearInterval(timer); unsubscribe(); model.dispose(); channel?.close(); password.value = ''; confirmation.value = ''; code.value = ''; });
</script>
<template>
  <div class="login-layout credential-layout">
    <SiteHeader class="login-header" brand-class="login-brand" />
    <main id="view" class="login-screen credential-screen">
      <GlassNavigationButton label="Volver a iniciar sesión" :disabled="state.busy" :class="{ working: state.action === 'cancel' }" :aria-busy="state.action === 'cancel'" @navigate="back" />
      <TopToast ref="toast" />
      <div v-if="state.checking" class="credential-skeleton" aria-label="Comprobando solicitud" aria-busy="true"><div class="shape title-shape" /><div class="shape line-shape" /><div class="shape credential-field-shape" /><div class="shape credential-field-shape" /></div>
      <div v-else-if="!state.ready"><ActionButton :working="state.checking" @click="initialize">Reintentar conexión</ActionButton><NavigationLink class="credential-link" to="/recuperar-contrasena" v-if="resetPage">Solicitar otro código</NavigationLink></div>
      <StaggerReveal v-else :key="stage">
        <header class="login-heading"><h1>{{ title }}</h1><p>{{ description }}</p></header>
        <template v-if="stage === 'complete'"><NavigationLink class="primary credential-login" to="/iniciar-sesion">Iniciar sesión</NavigationLink></template>
        <template v-else-if="state.failure?.kind === 'expired' || state.failure?.kind === 'conflict'"><ActionButton :working="state.action === 'cancel'" @click="changeEmail">Comenzar de nuevo</ActionButton></template>
        <form v-else class="login-form" :aria-busy="state.busy" novalidate @submit.prevent="submit">
          <template v-if="stage === 'register'"><LoginInput v-model="name" label="Nombre" field="name" :disabled="state.busy" :invalid="invalid('name')" :notice="state.notice" /></template>
          <LoginInput v-if="stage === 'register' || stage === 'recover'" v-model="email" label="Correo" :disabled="state.busy" :invalid="invalid('email')" :notice="state.notice" />
          <LoginInput v-if="stage === 'code'" v-model="code" label="Código de verificación" field="code" :disabled="state.busy" :invalid="invalid('code')" :notice="state.notice" />
          <template v-if="stage === 'register' || stage === 'reset'">
            <LoginInput v-model="password" :label="stage === 'reset' ? 'Nueva contraseña' : 'Contraseña'" password new-password :disabled="state.busy" :invalid="invalid('password')" :notice="state.notice" />
            <LoginInput v-model="confirmation" label="Confirmar contraseña" password new-password :disabled="state.busy" :invalid="invalid('confirmation')" :notice="state.notice" />
          </template>
          <ActionButton class="login-submit" variant="primary" type="submit" :working="state.busy && state.action !== 'resend' && state.action !== 'cancel'" :disabled="state.busy || (state.failure?.kind === 'rate_limited' && state.seconds > 0)">{{ stage === 'register' ? 'Crear cuenta' : stage === 'recover' ? 'Enviar código' : stage === 'code' ? 'Verificar código' : 'Guardar contraseña' }}</ActionButton>
          <template v-if="stage === 'code'">
            <ActionButton :working="state.action === 'resend'" :disabled="state.busy || state.seconds > 0" @click="model.resend()">Reenviar código<span v-if="state.seconds > 0"> ({{ state.seconds }} s)</span></ActionButton>
            <ActionButton variant="text-button" :working="state.action === 'cancel'" :disabled="state.busy" @click="changeEmail">Usar otro correo</ActionButton>
          </template>
        </form>
        <p v-if="stage === 'register'" class="login-legal">Al crear tu cuenta, aceptas nuestros <NavigationLink to="/terminos">Términos de servicio</NavigationLink> y reconoces haber leído nuestra <NavigationLink to="/privacidad">Política de privacidad</NavigationLink>.</p>
      </StaggerReveal>
    </main>
  </div>
</template>
