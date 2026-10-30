<script setup lang="ts">
const props=defineProps<{actor:string}>();
const model=useNuxtApp().$matchingModel(props.actor),state=shallowRef(model.state);
const unsubscribe=model.subscribe(s=>{state.value=s;});
const toast=useTemplateRef('toast');
const species=(s:string)=>({dog:'Perro',cat:'Gato',other:'Mascota'}[s]||'Mascota');
const messages={invalid:'Revisa la búsqueda seleccionada.',unauthenticated:'Vuelve a iniciar sesión.',forbidden:'Esta búsqueda ya no está disponible para tu cuenta.',conflict:'El caso cambió. Vuelve a consultar sus coincidencias.',unavailable:'No pudimos comparar las publicaciones. Puedes reintentar.',busy:'La comparación está ocupada o hay demasiadas publicaciones. Reintenta en unos momentos.'};
watch(()=>state.value.notice,()=>{if(state.value.failure)toast.value?.show(messages[state.value.failure]);});
watch(()=>state.value.saved,()=>toast.value?.show('Revisión guardada. La recuperación se confirma por separado.',null,false));
let channel:BroadcastChannel|undefined;
onMounted(()=>{void model.load();channel=new BroadcastChannel('eh-access');channel.onmessage=()=>{model.invalidate();toast.value?.close();};});
onBeforeUnmount(()=>{unsubscribe();model.dispose();channel?.close();});
const decide=(id:string,decision:'confirmed'|'dismissed')=>model.decide(id,decision,crypto.randomUUID());
</script>
<template>
  <section class="matching-screen" aria-labelledby="matching-title">
    <TopToast ref="toast" />
    <EntityPageHeader title="Posibles coincidencias" title-id="matching-title" back-label="Volver a inicio" @back="navigateTo('/inicio')" />
    <p>Compara las fotos de tu búsqueda con publicaciones de mascotas encontradas. Revisa cada sugerencia antes de sacar conclusiones.</p>
    <ContentSkeleton v-if="state.loading" label="Consultando tus búsquedas" />
    <StaggerReveal v-else as="div">
      <template v-if="state.searches.length">
        <FieldSelect label="Tu búsqueda" :model-value="state.selected" :disabled="state.busy" :options="state.searches.map(s=>({value:s.ref.source+':'+s.ref.id,label:s.name||species(s.species)}))" @update:model-value="model.select($event)" />
        <ActionButton :working="state.busy" @click="model.search()">{{ state.result && !state.result.complete ? 'Continuar comparación' : 'Buscar coincidencias' }}</ActionButton>
      </template>
      <template v-else-if="!state.failure"><p>No tienes búsquedas activas con fotografías disponibles.</p><NavigationLink to="/reportar" class="primary" origin>Publicar una búsqueda</NavigationLink></template>
      <ActionButton v-if="state.failure && !state.searches.length" :working="state.busy" @click="model.load()">Reintentar</ActionButton>
      <ContentSkeleton v-if="state.busy && !state.result" label="Comparando fotografías" />
      <div v-if="state.result" class="matching-results" :class="{refreshing:state.busy}" :aria-busy="state.busy">
        <p v-if="!state.result.complete">Aún quedan fotografías por comparar. Continúa para completar los resultados.</p>
        <p v-else-if="!state.result.candidates.length">No hay publicaciones compatibles disponibles por ahora.</p>
        <article v-for="candidate in state.result.candidates" :key="candidate.ref.source+candidate.ref.id" class="matching-card">
          <img :src="'/api/recovery/photo?source='+candidate.ref.source+'&id='+candidate.ref.id+'&index=0'" alt="Mascota de la publicación sugerida" loading="lazy" />
          <div><p class="eyebrow">Posible coincidencia</p><h2>{{candidate.name || 'Mascota encontrada'}}</h2>
            <p>Comparación visual de la misma especie · zonas públicas a unos {{(candidate.distanceMeters/1000).toLocaleString('es-PE',{maximumFractionDigits:1})}} km · {{candidate.daysApart}} días entre los sucesos.</p>
            <p>La sugerencia puede ser incorrecta. Confirma los rasgos y la información del caso.</p>
            <p v-if="candidate.review">Tu revisión: {{candidate.review==='confirmed'?'Coincidencia confirmada':'Descartada'}}.</p>
            <slot name="case-link" :candidate="candidate" />
            <div class="matching-actions"><ActionButton :disabled="state.busy || candidate.review==='confirmed'" @click="decide(candidate.ref.id,'confirmed')">Coincide</ActionButton><ActionButton variant="secondary" :disabled="state.busy || candidate.review==='dismissed'" @click="decide(candidate.ref.id,'dismissed')">Descartar</ActionButton></div>
          </div>
        </article>
      </div>
    </StaggerReveal>
  </section>
</template>
<style scoped>
.matching-screen{width:min(100%,56rem);margin:auto;padding:1rem 0 3rem}.matching-heading{display:flex;gap:1rem;align-items:center}.matching-heading h1{min-width:0}.matching-screen p{line-height:1.6;color:#454746}.matching-screen :deep(.field-select),.matching-screen :deep(button){margin-block:.5rem}.matching-card{display:grid;grid-template-columns:minmax(0,12rem) minmax(0,1fr);gap:1.25rem;background:#fff;border-radius:1.5rem;padding:1rem;margin-block:1.25rem}.matching-card img{width:100%;aspect-ratio:1;object-fit:cover;border-radius:1rem}.matching-actions{display:flex;gap:.75rem;flex-wrap:wrap}@media(max-width:540px){.matching-card{grid-template-columns:minmax(0,1fr)}}
</style>
