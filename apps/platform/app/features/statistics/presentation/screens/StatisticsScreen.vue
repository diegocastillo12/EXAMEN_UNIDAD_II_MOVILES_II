<script setup lang="ts">
import '../styles/statistics.css';
const props = defineProps<{ actor: string }>();
const model = useNuxtApp().$statisticsModel(props.actor), state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast');
const messages = { invalid: 'Selecciona fechas válidas y ordenadas, con un máximo de 366 días.', unauthenticated: 'Tu sesión terminó. Vuelve a iniciar sesión.', forbidden: 'Tu cuenta no tiene permiso para consultar estadísticas.', conflict: 'La cuenta cambió. Vuelve a iniciar sesión.', unavailable: 'No pudimos consultar las estadísticas. Puedes reintentar.' };
const cards = computed(() => state.value.data ? [
  ['Casos perdidos publicados', state.value.data.publishedLost], ['Avisos y búsquedas publicados', state.value.data.publishedFound],
  ['Avistamientos recibidos', state.value.data.sightings], ['Recuperaciones confirmadas', state.value.data.recovered],
  ['Casos cancelados', state.value.data.cancelled], ['Casos archivados', state.value.data.archived], ['Denuncias recibidas', state.value.data.reports],
] as const : []);
function date(value: string) { return new Intl.DateTimeFormat('es-PE', { timeZone: 'UTC', dateStyle: 'medium' }).format(new Date(value)); }
watch(() => state.value.notice, () => {
  const failure = state.value.failure;
  if (!failure) return;
  toast.value?.show(messages[failure]);
  if (failure === 'unauthenticated' || failure === 'conflict') navigateTo('/iniciar-sesion?reason=expired', { replace: true });
  else if (failure === 'forbidden') navigateTo('/inicio?reason=forbidden', { replace: true });
});
let channel: BroadcastChannel | undefined;
onMounted(() => {
  void model.load();
  channel = new BroadcastChannel('eh-access');
  channel.onmessage = () => { model.invalidate(); toast.value?.close(); };
});
onBeforeUnmount(() => { unsubscribe(); model.dispose(); channel?.close(); });
</script>
<template>
  <section class="statistics-screen" aria-labelledby="statistics-title">
    <TopToast ref="toast" />
    <header class="statistics-header"><GlassNavigationButton label="Volver a inicio" @navigate="navigateTo('/inicio')" /><div><h1 id="statistics-title">Estadísticas</h1><p>Actividad de la comunidad por período, sin datos personales.</p></div></header>
    <StaggerReveal as="form" class="statistics-filter" @submit.prevent="model.load()">
      <DateField :model-value="state.from" label="Desde" min="2000-01-01" max="2099-12-31" :disabled="state.busy" :invalid="state.failure === 'invalid'" :data-notice="state.notice" @update:model-value="model.edit('from', $event)" />
      <DateField :model-value="state.to" label="Hasta" min="2000-01-01" max="2099-12-31" :disabled="state.busy" :invalid="state.failure === 'invalid'" :data-notice="state.notice" @update:model-value="model.edit('to', $event)" />
      <ActionButton type="submit" :working="state.busy">Consultar</ActionButton>
      <p>Ambas fechas incluidas, según la hora de Lima. Hasta 366 días por consulta.</p>
    </StaggerReveal>
    <ContentSkeleton v-if="!state.data && state.busy" label="Consultando estadísticas" />
    <div v-else-if="state.data" class="statistics-results" :class="{ refreshing: state.busy }" :aria-busy="state.busy">
      <p class="statistics-period">Del {{ date(state.data.period.from) }} al {{ date(state.data.period.to) }} · Lima</p>
      <StaggerReveal as="div"><dl class="statistics-grid"><div v-for="[label, count] in cards" :key="label" class="statistics-card"><dt>{{ label }}</dt><dd>{{ count.toLocaleString('es-PE') }}</dd></div></dl></StaggerReveal>
      <p v-if="cards.every(([, count]) => count === 0)">No se registró actividad en este período.</p>
      <div class="statistics-notes"><h2>Cómo leer estos datos</h2><p>Cada conteo usa la fecha en que se publicó, recibió, recuperó o retiró el caso. Las publicaciones siguen contando aunque se retiren u oculten después; los borradores no se incluyen.</p><p>Una recuperación requiere confirmación registrada por el responsable. Estos datos no atribuyen la recuperación a Entre Huellas ni reconstruyen cierres antiguos sin confirmación.</p><p>Cancelados: casos retirados sin recuperación registrada. Archivados: casos retirados después de una recuperación registrada. Una recuperación y su archivo pueden aparecer en períodos distintos; no sumes estos conteos como casos únicos.</p><p>Los avisos publicados incluyen encontrados, búsquedas comunitarias y publicaciones anteriores. Las denuncias se cuentan al recibirse, independientemente de su resolución.</p></div>
    </div>
    <ActionButton v-else-if="state.failure" @click="model.load()">Reintentar consulta</ActionButton>
  </section>
</template>
