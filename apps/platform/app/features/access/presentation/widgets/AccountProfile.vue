<script setup lang="ts">
import type { AccountSession } from '#shared/features/access/domain/access';
const props=defineProps<{ session:AccountSession }>();
const open=ref(false),photoFailed=ref(false),photoReady=ref(false);
const origin=shallowRef<HTMLElement|null>(null);
function show(event:MouseEvent){origin.value=event.currentTarget as HTMLElement;open.value=true;}
const initials=computed(() => {
  const words=(props.session.profile.displayName || '').trim().split(/\s+/).filter(Boolean);
  return words.length ? [words[0],...(words.length>1 ? [words.at(-1)!] : [])].map(word=>Array.from(word!)[0]).join('').toLocaleUpperCase('es') : '';
});
watch(() => props.session.actor,() => {open.value=false;photoFailed.value=false;photoReady.value=false;});
</script>
<template>
  <GlassSurface as="button" type="button" class="account-icon account-avatar" aria-label="Abrir perfil" title="Abrir perfil" aria-haspopup="dialog" :aria-expanded="open" @click="show">
    <img v-if="!photoFailed" :class="{'avatar-pending':!photoReady}" :src="'/api/access/avatar?actor=' + encodeURIComponent(session.actor)" alt="" @load="photoReady=true" @error="photoFailed=true;photoReady=false" />
    <span v-if="!photoReady && initials" aria-hidden="true">{{ initials }}</span>
    <svg v-else-if="!photoReady" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><circle cx="12" cy="8" r="4" /><path d="M4 22v-3a8 8 0 0 1 16 0v3" /></svg>
  </GlassSurface>
  <GlassDialog :open="open" :origin="origin" :source-icon="false" title="Tu cuenta" @close="open=false">
    <div class="account-profile-identity"><span class="account-profile-avatar" aria-hidden="true"><img v-if="!photoFailed" :src="'/api/access/avatar?actor=' + encodeURIComponent(session.actor)" alt="" @error="photoFailed=true" /><span v-else>{{ initials || '·' }}</span></span><p>{{ session.profile.displayName || 'Tu perfil' }}</p></div>
    <dl class="account-profile-data">
      <div><dt>Nombre</dt><dd>{{ session.profile.displayName || 'Sin registrar' }}</dd></div>
      <div><dt>Correo</dt><dd>{{ session.email || 'No disponible' }}</dd></div>
      <div><dt>Ciudad</dt><dd>{{ session.profile.city || 'Sin registrar' }}</dd></div>
    </dl>
    <p class="privacy">Tu cuenta y la bienvenida completada se comparten con la aplicación móvil.</p>
    <NavigationLink to="/cuentas-bloqueadas" class="secondary" @click="open=false">Cuentas bloqueadas</NavigationLink>
  </GlassDialog>
</template>
