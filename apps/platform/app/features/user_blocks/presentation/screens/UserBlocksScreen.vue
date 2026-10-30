<script setup lang="ts">
import type { BlockEntry,BlockTarget } from '#shared/features/user_blocks/domain/user_blocks';
const props=defineProps<{actor:string;target:BlockTarget|null}>();
const model=useNuxtApp().$userBlockModel(props.actor,props.target),state=shallowRef(model.state);
const unsubscribe=model.subscribe(value=>{state.value=value;});
const toast=useTemplateRef('toast'),confirmation=shallowRef<{entry:BlockEntry;enabled:boolean}|null>(null);
const messages={invalid:'No pudimos identificar esta cuenta desde el contenido.',unauthenticated:'Tu sesión terminó. Vuelve a iniciar sesión.',forbidden:'No pudimos autorizar esta operación. Consulta de nuevo.',conflict:'El bloqueo cambió. Consulta de nuevo antes de continuar.',unavailable:'No pudimos confirmar el cambio. Reintenta la misma operación.'};
watch(()=>state.value.notice,()=>{
  if(state.value.failure)toast.value?.show(messages[state.value.failure.kind]);
  else if(state.value.confirmed)toast.value?.show('Cambio de bloqueo guardado.',null,false);
});
function ask(entry:BlockEntry,enabled:boolean){if(!state.value.busy && !state.value.pending && !state.value.refreshing && !state.value.failure)confirmation.value={entry,enabled};}
async function answer(confirmed:boolean){const pending=confirmation.value;confirmation.value=null;if(confirmed && pending)await model.change(pending.entry,pending.enabled);}
onMounted(()=>model.load());
onBeforeUnmount(()=>{confirmation.value=null;toast.value?.close();unsubscribe();model.dispose();});
onBeforeRouteLeave(()=>!state.value.busy);
const locked=computed(()=>state.value.busy || state.value.refreshing || !!state.value.pending || !!state.value.failure);
</script>
<template>
  <section class="block-screen">
    <TopToast ref="toast" />
    <div class="block-navigation"><GlassNavigationButton label="Volver a Inicio" :disabled="state.busy" @navigate="navigateTo('/inicio')" /></div>
    <h1>Cuentas bloqueadas</h1>
    <p class="privacy">Impide nuevos avisos y avistamientos entre ambas cuentas con sesión y oculta el contacto y su foto entre ellas. Las fichas, denuncias, historial y avistamientos anónimos por QR siguen disponibles.</p>
    <ContentSkeleton v-if="state.loading" label="Consultando bloqueos" />
    <div v-else :aria-busy="state.refreshing" :class="{refreshing:state.refreshing}">
      <StaggerReveal as="div" class="block-list">
        <GlassSurface v-if="state.target" class="block-entry">
          <p>{{state.target.label}}</p>
          <ActionButton :disabled="locked" :working="state.busy && state.pending?.entry.id===state.target.id" @click="ask(state.target,!state.target.enabled)">{{state.target.enabled?'Desbloquear cuenta':'Bloquear cuenta del reportante'}}</ActionButton>
        </GlassSurface>
        <p v-if="target && !state.target && !state.failure" class="privacy">Este contenido no corresponde a otra cuenta que puedas bloquear.</p>
        <GlassSurface v-for="entry in state.items.filter(e=>e.id!==state.target?.id)" :key="entry.id" class="block-entry">
          <p>{{entry.label}}</p><ActionButton :disabled="locked" :working="state.busy && state.pending?.entry.id===entry.id" @click="ask(entry,false)">Desbloquear cuenta</ActionButton>
        </GlassSurface>
        <p v-if="!state.items.length && !state.target?.enabled && !state.failure">No tienes cuentas bloqueadas.</p>
      </StaggerReveal>
      <div class="block-actions">
        <ActionButton v-if="state.pending" :working="state.busy" @click="model.change(state.pending.entry,state.pending.enabled)">Reintentar cambio</ActionButton>
        <ActionButton v-if="state.next" :disabled="locked" @click="model.load(true)">Ver más</ActionButton>
        <ActionButton :disabled="state.busy || !!state.pending" :working="state.refreshing" @click="model.load()">Consultar bloqueos</ActionButton>
      </div>
    </div>
    <ConfirmationDialog :open="!!confirmation" :title="confirmation?.enabled?'¿Bloquear cuenta?':'¿Desbloquear cuenta?'" :description="confirmation?.enabled?'Impide nuevos avisos y avistamientos con sesión y oculta el contacto y su foto entre ambas cuentas. Las fichas, denuncias, historial y el QR anónimo siguen disponibles.':'Se retirará tu bloqueo. La otra cuenta puede conservar un bloqueo propio.'" :action="confirmation?.enabled?'Bloquear':'Desbloquear'" @answer="answer" />
  </section>
</template>
<style>
.block-screen{display:grid;gap:24px;min-width:0}.block-screen>button{justify-self:start}.block-list{display:grid;gap:16px}.block-entry{padding:24px;display:grid;gap:16px;min-width:0;overflow-wrap:anywhere}.block-entry p{margin:0}.block-entry button{justify-self:start;white-space:normal;text-align:start;max-width:100%}.block-actions{display:flex;flex-wrap:wrap;gap:12px;margin-top:24px}
.reader-shell .block-navigation{position:sticky;top:max(16px,env(safe-area-inset-top));z-index:5;display:flex;justify-content:flex-end;pointer-events:none}.reader-shell .block-navigation .glass-navigation{position:static;width:52px;height:52px;pointer-events:auto}
</style>
