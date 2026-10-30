<script setup lang="ts">
import CaseGallery from '../widgets/CaseGallery.vue';
import type { ActiveCase, PublicCase } from '../../../../../shared/features/case_reader/domain/case';
const props = defineProps<{ slug: string; initial: PublicCase | null; failed: boolean }>();
const model = useNuxtApp().$readerModel(props.initial, props.slug, props.failed);
const state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast');
const active = computed(() => state.value.value?.state === 'active' ? state.value.value as ActiveCase : null);
const title = computed(() => active.value?.name || (active.value?.kind === 'lost' ? 'Mascota perdida' : 'Mascota encontrada'));
const labels = { dog: 'Perro', cat: 'Gato', other: 'Otra especie', small: 'Pequeño', medium: 'Mediano', large: 'Grande', male: 'Macho', female: 'Hembra' };
const dateLabel = (value: string) => new Intl.DateTimeFormat('es-PE', { dateStyle: 'long', timeZone: 'America/Lima' }).format(new Date(value));
const shareBusy = ref(false); const copyBusy = ref(false);
const reporting = ref(false);
function closeReport() { reporting.value = false; refresh(); }
const refresh = () => model.load(props.slug);
function notifyFailure() {
  if (state.value.notice) toast.value?.show(state.value.notice === 'rate_limited' ? 'Espera un momento antes de volver a consultar.' : 'No pudimos actualizar el caso.', refresh);
}
watch(() => state.value.noticeId, notifyFailure);
function photoFailed(retry: () => void) { toast.value?.show('No se pudo mostrar la foto.', () => { retry(); refresh(); }); refresh(); }
const publicUrl = () => new URL(`/c/${props.slug}`, window.location.origin).href;
async function copy() {
  if (copyBusy.value) return; copyBusy.value = true;
  try { await navigator.clipboard.writeText(publicUrl()); toast.value?.show('Enlace copiado', null, false); }
  catch { toast.value?.show('No se pudo copiar. Puedes compartir el enlace desde tu navegador.'); }
  finally { copyBusy.value = false; }
}
async function share() {
  if (shareBusy.value) return;
  if (!navigator.share) { await copy(); return; }
  shareBusy.value = true;
  try { await navigator.share({ title: `${title.value} · Entre Huellas`, url: publicUrl() }); }
  catch (error) { if (!(error instanceof Error && error.name === 'AbortError')) toast.value?.show('No se pudo compartir. Intenta copiar el enlace.'); }
  finally { shareBusy.value = false; }
}
let timer: ReturnType<typeof setInterval> | undefined;
function visibleRefresh() { if (!document.hidden && !reporting.value) refresh(); }
function restore(event: PageTransitionEvent) { if (event.persisted) refresh(); }
onMounted(() => {
  notifyFailure(); timer = setInterval(visibleRefresh, 60000);
  document.addEventListener('visibilitychange', visibleRefresh); window.addEventListener('pageshow', restore);
});
onBeforeUnmount(() => {
  unsubscribe(); model.dispose(); clearInterval(timer);
  if (import.meta.client) { document.removeEventListener('visibilitychange', visibleRefresh); window.removeEventListener('pageshow', restore); }
});
</script>
<template>
  <WebShell :with-back="reporting">
    <main id="view" aria-label="Ficha pública del caso" :aria-busy="state.phase === 'loading' || state.refreshing" :class="{ refreshing: state.refreshing }">
      <slot v-if="reporting && active" name="sighting" :active-case="active" :close="closeReport" />
      <ContentSkeleton v-else-if="state.phase === 'loading'" />
      <StaggerReveal as="article" v-else-if="active" class="case">
        <div class="case-heading">
          <p class="eyebrow">{{ active.kind === 'lost' ? 'Ayudemos a que vuelva a casa' : 'Una mascota espera reencontrarse' }}</p>
          <h1>{{ title }}</h1>
          <div class="chips"><span class="chip active">Caso abierto</span><span class="chip">{{ active.species === 'other' && active.speciesDetail ? active.speciesDetail : labels[active.species] }}</span><span v-if="active.size" class="chip">{{ labels[active.size] }}</span><span v-if="active.sex" class="chip">{{ labels[active.sex] }}</span></div>
        </div>
        <CaseGallery :slug="slug" :title="title" :revision="active.revision" :count="active.photoCount" @failed="photoFailed" />
        <div class="details">
          <p class="eyebrow">Cada detalle ayuda</p><h2>Cómo reconocerle</h2><p class="traits">{{ active.traits }}</p>
          <section class="area">
            <h2>{{ active.kind === 'lost' ? 'Última ubicación conocida' : 'Área del encuentro' }}</h2>
            <p class="muted">{{ dateLabel(active.occurredAt) }} · Referencia aproximada</p>
            <p class="privacy">Esta referencia indica el área del caso. No muestra una dirección ni el punto exacto.</p>
            <a class="secondary area-link" :href="`https://www.google.com/maps/search/?api=1&query=${active.area.latitude},${active.area.longitude}`" target="_blank" rel="noopener noreferrer">Ver área aproximada</a>
          </section>
          <section class="collaborate"><h2>Ayuda a que alguien le reconozca</h2><p class="muted">Compartir esta ficha puede acercar el reencuentro.</p>
            <ActionButton variant="primary" @click="reporting = true">La vi · Reportar avistamiento</ActionButton>
            <div class="actions"><ActionButton variant="primary" :working="shareBusy" @click="share">Compartir caso</ActionButton><ActionButton :working="copyBusy" @click="copy">Copiar enlace</ActionButton></div>
          </section>
          <ActionButton variant="text-button" :working="state.refreshing" @click="refresh">Actualizar estado</ActionButton>
        </div>
      </StaggerReveal>
      <StaggerReveal as="section" v-else class="neutral">
        <p class="eyebrow">Entre Huellas</p>
        <template v-if="state.value?.state === 'closed'"><h1>Este caso ya fue cerrado</h1><p class="description">La búsqueda ya no está activa y no admite nuevos avistamientos.</p><p v-if="state.value.closedAt" class="muted">Cierre registrado el {{ dateLabel(state.value.closedAt) }}.</p></template>
        <template v-else-if="state.phase === 'error'"><h1>Consulta el caso</h1><ActionButton variant="primary" @click="refresh">Reintentar</ActionButton></template>
        <template v-else><h1>Este enlace no está disponible</h1><p class="description">No hay información del caso para mostrar desde este enlace.</p></template>
      </StaggerReveal>
    </main>
    <TopToast v-if="!reporting" ref="toast" />
  </WebShell>
</template>
