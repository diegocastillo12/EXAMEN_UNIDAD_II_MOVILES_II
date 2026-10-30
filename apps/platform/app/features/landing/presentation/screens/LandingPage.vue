<script setup lang="ts">
import BackgroundGlowOrb from '~/components/BackgroundGlowOrb.vue';
import LandingArt from '../widgets/LandingArt.vue';
import LandingCharacterCard from '../widgets/LandingCharacterCard.vue';
import LandingIcon from '../widgets/LandingIcon.vue';
import LandingBrand from '../widgets/LandingBrand.vue';
import LandingActions from '../widgets/LandingActions.vue';
import LandingPawTrail from '../widgets/LandingPawTrail.vue';
import LandingSideNote from '../widgets/LandingSideNote.vue';
import '../styles/landing.css';
const horizontalPaused = ref(false);
const accessModel = useNuxtApp().$accessModel();
const router = useRouter();
const accessState = shallowRef(accessModel.state);
const stopAccess = accessModel.subscribe(value => { accessState.value = value; });
const accessTarget = computed(() => {
  const session = accessState.value.session;
  return session ? (session.profile.onboardingCompleted ? '/inicio' : '/bienvenida') : '/iniciar-sesion';
});
let accessChannel: BroadcastChannel | undefined;
let accessTimer: ReturnType<typeof setInterval> | undefined;
async function prepareAccess() {
  if (document.visibilityState === 'hidden') return;
  await accessModel.checkSession();
  if (!accessState.value.failure) await preloadRouteComponents(accessTarget.value, router).catch(() => {});
}
onMounted(() => {
  void prepareAccess();
  accessTimer = setInterval(() => { void prepareAccess(); }, 10000);
  window.addEventListener('focus', prepareAccess);
  document.addEventListener('visibilitychange', prepareAccess);
  accessChannel = new BroadcastChannel('eh-access');
  accessChannel.onmessage = () => { accessModel.invalidate(); void prepareAccess(); };
});
onBeforeUnmount(() => {
  clearInterval(accessTimer); accessChannel?.close();
  window.removeEventListener('focus', prepareAccess);
  document.removeEventListener('visibilitychange', prepareAccess);
  stopAccess(); accessModel.dispose();
});
const characters = [
  { title: 'Volvemos', art: 'return' }, { title: 'Busco', art: 'search-corgi' },
  { title: 'Encontré', art: 'found-tabby' }, { title: 'Ayudo', art: 'help-dalmatian' },
  { title: 'Volvemos', art: 'return' }, { title: 'Busco', art: 'search' },
] as const;
// A full wave spans twelve cards so neighboring portraits follow a broad curve.
const waveCharacters = [...characters, ...characters];
const benefits = [
  { icon: 'report', title: 'Información útil', text: 'Avisos claros y organizados para una búsqueda más efectiva.' },
  { icon: 'people', title: 'Comunidad cercana', text: 'Personas de tu zona unidas por la misma causa.' },
  { icon: 'shield', title: 'Privacidad cuidada', text: 'Cuidamos los datos de las personas y de sus mascotas.' },
] as const;
const questions = [
  ['¿Qué es Entre Huellas?', 'Un proyecto para colaborar en la búsqueda de mascotas perdidas y encontradas, conectando a quienes buscan, encuentran y quieren ayudar.'],
  ['¿Puedo reportar un hallazgo?', 'Sí. La aplicación contempla publicar avisos de mascotas encontradas con su información y una zona aproximada. Esta landing presenta el proyecto; no recibe reportes.'],
  ['¿Cómo se cuida la privacidad?', 'Las fichas públicas muestran solo la información autorizada. Las coordenadas exactas, las referencias privadas y los documentos no forman parte de la información pública.'],
  ['¿En qué etapa está el proyecto?', 'Entre Huellas está en desarrollo, con Android como primera plataforma. La disponibilidad pública y las descargas se comunicarán cuando estén listas.'],
] as const;
</script>
<template>
  <div class="landing-page">
    <BackgroundGlowOrb class="landing-ambient-glow" intensity="soft" />
    <a class="skip-link" href="#contenido">Saltar al contenido</a>
    <SiteHeader class="header wrap">
      <nav aria-label="Navegación principal"><a href="#proyecto">Proyecto</a><a href="#como-funciona">Cómo funciona</a><a href="#comunidad">Comunidad</a><a href="#preguntas">Preguntas</a></nav>
      <NavigationLink class="button button-primary header-cta" :to="accessTarget">Iniciar sesión</NavigationLink>
    </SiteHeader>
    <main id="contenido">
      <section id="inicio" class="hero wrap aurora" aria-labelledby="hero-title">
        <LandingPawTrail />
        <p class="eyebrow">Recuperación colaborativa</p>
        <div class="hero-heading"><LandingArt name="hero-dog" class="hero-dog" /><h1 id="hero-title">Más huellas juntas.<br>Más caminos<br>de vuelta a casa.</h1><LandingArt name="hero-cat" class="hero-cat" /></div>
        <p class="hero-description">Conectamos a quienes buscan mascotas perdidas, encuentran una y quieren ayudar.</p>
        <LandingActions />
        <ul class="hero-values"><li><LandingIcon name="report" />Reporta</li><li><LandingIcon name="share" />Comparte</li><li><LandingIcon name="heart" />Colabora</li></ul>
      </section>
      <section :class="['character-strip', { 'horizontal-paused': horizontalPaused }]" aria-label="Busco, encontré, ayudo y volvemos">
        <button class="character-horizontal-toggle" type="button" :aria-pressed="horizontalPaused" :aria-label="horizontalPaused ? 'Reanudar desplazamiento horizontal' : 'Pausar desplazamiento horizontal'" :title="horizontalPaused ? 'Reanudar desplazamiento horizontal' : 'Pausar desplazamiento horizontal'" @click="horizontalPaused = !horizontalPaused">
          <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path v-if="horizontalPaused" d="m9 6 9 6-9 6Z" fill="currentColor" /><path v-else d="M9 6v12M15 6v12" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" /></svg>
        </button>
        <div class="character-track">
          <div v-for="copy in 2" :key="copy" class="character-group" :aria-hidden="copy === 2 ? true : undefined">
            <LandingCharacterCard v-for="(card, index) in waveCharacters" :key="`${card.art}-${index}`" :title="card.title" :art="card.art" :decorative="copy === 2 || index >= characters.length || index === 0 || index === 5" />
          </div>
      </div></section>
      <section id="proyecto" class="purpose panel wrap" aria-labelledby="purpose-title">
        <div class="purpose-heading"><h2 id="purpose-title">Una comunidad<br>con un propósito.</h2><p>Entre Huellas es un proyecto colaborativo para conectar a personas que han perdido una mascota, a quienes la han encontrado y a quienes quieren ayudar.</p></div>
        <div id="como-funciona" class="steps">
          <div class="step-copy align-right"><span class="step-number">01</span><h3>Reporta una pérdida</h3><p>Cuenta qué mascota buscas y<br class="desktop-break"> comparte la información clave.</p></div>
          <LandingArt name="step-search" label="Perrito con avisos de búsqueda" class="step-art" />
          <LandingArt name="step-found" label="Gatito junto a un marcador de ubicación" class="step-art" />
          <div class="step-copy"><span class="step-number">02</span><h3>Comparte un hallazgo</h3><p>Si encontraste una mascota,<br class="desktop-break"> publica un aviso con sus detalles.</p></div>
          <div class="step-copy align-right"><span class="step-number">03</span><h3>Ayuda cerca de ti</h3><p>Comparte en tu comunidad<br class="desktop-break"> y mantente atento a los avisos.</p></div>
          <LandingArt name="step-help" label="Perrito saludando junto a una ubicación" class="step-art" />
          <LandingArt name="step-return" label="Un perro y un gato felices juntos" class="step-art" />
          <div class="step-copy"><span class="step-number">04</span><h3>Celebra el reencuentro</h3><p>Cada aviso puede ser el inicio<br class="desktop-break"> de un gran final.</p></div>
        </div>
      </section>
      <section class="opportunity wrap" aria-labelledby="opportunity-title"><LandingPawTrail /><div class="opportunity-copy"><h2 id="opportunity-title">Un pequeño aviso.<br>Una gran oportunidad.</h2><LandingActions /></div><LandingArt name="home" label="Perrito y gatito delante de una casita" /></section>
      <section id="comunidad" class="nearby wrap" aria-labelledby="nearby-title"><div><h2 id="nearby-title">La ayuda puede<br>estar cerca.</h2><p>Cada reporte compartido<br>puede sumar a la búsqueda.</p><a href="#colaborar" class="button button-primary">Conoce la comunidad</a></div><LandingArt name="map" label="Un perro y un gato buscan juntos en un mapa" /></section>
      <section id="colaborar" class="collaborate panel wrap" aria-labelledby="collaborate-title">
        <h2 id="collaborate-title">Ayudar empieza<br>con un aviso.</h2>
        <svg class="connection" viewBox="0 0 600 50" fill="none" aria-hidden="true"><path d="M60 5Q300 65 540 5" stroke="#a7effb" stroke-width="1.5" /><path d="m291 28 9 15 9-15" fill="#63e1f6" /></svg>
        <ol class="collaborate-grid"><li><LandingArt name="report" /><span class="small-number">01</span><h3>Reporta</h3><p>Publica la información<br>de tu mascota.</p></li><li><LandingArt name="share" /><span class="small-number">02</span><h3>Comparte</h3><p>Difunde el aviso<br>en tu comunidad.</p></li><li><LandingArt name="collaborate" /><span class="small-number">03</span><h3>Colabora</h3><p>Entre todos podemos<br>lograr que vuelvan.</p></li></ol>
      </section>
      <section class="benefits wrap" aria-labelledby="benefits-title"><h2 id="benefits-title">Todos podemos<br>ayudar a que vuelvan.</h2><div class="benefits-grid"><article v-for="benefit in benefits" :key="benefit.title"><span class="benefit-icon"><LandingIcon :name="benefit.icon" /></span><div><h3>{{ benefit.title }}</h3><p>{{ benefit.text }}</p></div></article></div></section>
      <section id="preguntas" class="faq panel wrap" aria-labelledby="faq-title"><h2 id="faq-title">Entre Huellas<br>responde.</h2><div class="faq-list"><details v-for="([question, answer], index) in questions" :key="question" name="preguntas" :open="index === 0"><summary>{{ question }}<svg viewBox="0 0 20 20" aria-hidden="true"><path d="m6 8 4 4 4-4" /></svg></summary><p>{{ answer }}</p></details></div></section>
      <section class="closing-scene" aria-labelledby="closing-title"><LandingPawTrail /><span class="closing-extra-paws" aria-hidden="true"><span class="paw-mark paw-mark-extra-1" /><span class="paw-mark paw-mark-extra-2" /><span class="paw-mark paw-mark-extra-3" /><span class="paw-mark paw-mark-extra-4" /><span class="paw-mark paw-mark-extra-5" /><span class="paw-mark paw-mark-extra-6" /></span><div class="closing aurora wrap"><h2 id="closing-title">Una huella tuya <span class="inline-pet"><LandingArt name="hero-dog" /></span><br>puede acercarlos a casa.</h2><LandingActions /></div></section>
    </main>
    <footer class="footer wrap"><LandingSideNote /><LandingArt name="footer-dog" class="footer-dog" /><div class="footer-content"><LandingBrand footer /><p class="development">Proyecto Android en desarrollo.</p><div class="footer-links"><div><h3>Proyecto</h3><a href="#proyecto">Qué es</a><a href="#como-funciona">Cómo funciona</a><a href="#preguntas">Preguntas</a></div><div><h3>Información</h3><NavigationLink to="/privacidad">Privacidad</NavigationLink><NavigationLink to="/terminos">Términos de servicio</NavigationLink><a href="#proyecto">Nuestra iniciativa</a><a href="#preguntas">Etapa del proyecto</a></div><div><h3>Comunidad</h3><a href="#comunidad">Colabora</a><a href="#colaborar">Difunde</a><a href="#como-funciona">Deja tu huella</a></div></div><p class="copyright">Entre Huellas · Más caminos de vuelta a casa.</p></div><LandingArt name="footer-cat" class="footer-cat" /></footer>
  </div>
</template>
