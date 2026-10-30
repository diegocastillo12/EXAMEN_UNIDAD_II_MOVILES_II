<script setup lang="ts">
const props=defineProps<{actor:string}>();
const open=ref(false),toast=useTemplateRef('toast');
const origin=shallowRef<HTMLElement|null>(null);
const model=useNuxtApp().$inboxModel(props.actor),state=shallowRef(model.state);
const unsubscribe=model.subscribe(value=>{state.value=value;});
const working=computed(()=>state.value.loading||state.value.refreshing||state.value.appending||!!state.value.busy);
const unread=computed(()=>state.value.items.some(item=>!item.read));
watch(()=>state.value.notice,()=>{if(state.value.failure)toast.value?.show(state.value.failure.kind==='unauthenticated'?'La sesión terminó. Vuelve a iniciar sesión.':'No pudimos consultar o actualizar tus alertas. Puedes reintentar.');});
async function show(event:MouseEvent) {origin.value=event.currentTarget as HTMLElement;open.value=true;await model.load();}
onBeforeUnmount(()=>{unsubscribe();model.dispose();});
</script>
<template>
  <GlassSurface as="button" class="account-icon account-notifications" type="button" aria-label="Alertas" title="Alertas" aria-haspopup="dialog" :aria-expanded="open" @click="show">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4" /></svg>
    <span v-if="unread" class="account-unread" aria-label="Hay alertas sin leer" />
  </GlassSurface>
  <GlassDialog :open="open" :origin="origin" title="Alertas" @close="open=false">
    <TopToast ref="toast" />
    <div class="inbox-toolbar"><ActionButton :working="state.refreshing" :disabled="working" @click="model.load()">Actualizar</ActionButton></div>
    <ContentSkeleton v-if="state.loading" label="Consultando alertas" />
    <div v-else class="inbox-content" :class="{refreshing:state.refreshing}" :aria-busy="working">
      <p v-if="state.loaded && !state.items.length" class="inbox-empty">Aún no tienes alertas.</p>
      <ul v-if="state.items.length" class="inbox-list" aria-label="Tus alertas">
        <li v-for="item in state.items" :key="item.id">
          <GlassSurface as="article" class="inbox-item" :class="{'inbox-unread':!item.read}">
            <h3>{{item.title}}</h3><time :datetime="item.createdAt">{{new Date(item.createdAt).toLocaleString('es-PE',{timeZone:'America/Lima',dateStyle:'medium',timeStyle:'short'})}}</time>
            <p v-if="!item.read" class="inbox-status">Sin leer</p>
            <ActionButton v-if="!item.read" :working="state.busy===item.id" :disabled="working" @click="model.markRead(item.id)">Marcar leída</ActionButton>
          </GlassSurface>
        </li>
      </ul>
      <ActionButton v-if="state.failure" :disabled="working" @click="model.load()">Reintentar</ActionButton>
      <ActionButton v-if="state.cursor" :working="state.appending" :disabled="working" @click="model.load(true)">Ver más alertas</ActionButton>
    </div>
  </GlassDialog>
</template>
<style>
.reader-shell .inbox-toolbar{display:flex;justify-content:flex-end;margin-bottom:20px}
.reader-shell .inbox-toolbar .secondary,.reader-shell .inbox-content .secondary{min-height:48px;font-size:1rem;padding:12px 20px}
.reader-shell .inbox-content{position:relative;isolation:isolate;overflow:hidden;border-radius:26px}
.reader-shell .inbox-list{list-style:none;padding:0;margin:0;display:grid;gap:16px}
.reader-shell .inbox-item{padding:20px;overflow-wrap:anywhere}
.reader-shell .inbox-item h3{font-size:1.125rem;line-height:1.4;font-weight:400;margin:0 0 8px}
.reader-shell .inbox-unread h3{font-weight:600}
.reader-shell .inbox-item time{display:block;font-size:.875rem;line-height:1.5;color:#656861}
.reader-shell .inbox-status{font-size:.875rem;color:#3c537b;font-weight:600;margin:12px 0}
.reader-shell .inbox-item .secondary{margin-top:8px}
.reader-shell .inbox-content>.secondary{margin-top:16px}
.reader-shell .inbox-empty{padding:24px 0;text-align:center;color:#656861}
</style>
