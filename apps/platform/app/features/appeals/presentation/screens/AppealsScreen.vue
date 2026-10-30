<script setup lang="ts">
import type { AppealEntry } from '#shared/features/appeals/domain/appeals';
import '../styles/appeals.css';
const props = defineProps<{ actor: string; review?: boolean }>();
const model = useNuxtApp().$appealsModel(props.actor, !!props.review), state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast'), heading = useTemplateRef('heading');
const confirmation = ref<((value: boolean) => void) | null>(null);
const messages = { invalid: 'Escribe un motivo de hasta 1000 caracteres.', unauthenticated: 'Tu sesión terminó. Vuelve a iniciar sesión.', forbidden: 'No tienes permiso para consultar o responder esta apelación.', conflict: 'El estado cambió. Actualiza la consulta antes de continuar.', unavailable: 'No pudimos confirmar la operación. Puedes reintentar.' };
const dirty = computed(() => !!state.value.reason || !!state.value.frozen);
const editable = computed(() => !!state.value.selected && !state.value.selected.appeal?.answer && (props.review ? !!state.value.selected.appeal : !state.value.selected.appeal));
function confirmLeave() { return new Promise<boolean>(resolve => { confirmation.value = resolve; }); }
function answer(value: boolean) { const resolve = confirmation.value; confirmation.value = null; resolve?.(value); }
async function canLeave() { return !state.value.busy && (!dirty.value || await confirmLeave()); }
defineExpose({ canLeave });
async function select(item: AppealEntry | null) { if (await canLeave()) { model.select(item); await nextTick(); heading.value?.focus(); } }
function date(value: string) { return new Intl.DateTimeFormat('es-PE', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(value)); }
function action(value: string) { return value === 'hide' ? 'Contenido oculto' : value === 'show' ? 'Visibilidad restaurada' : 'Denuncia resuelta sin cambiar visibilidad'; }
function kind(value: string) { return value === 'lost' ? 'Caso perdido' : value === 'found' ? 'Publicación o aviso' : 'Avistamiento'; }
function beforeUnload(event: BeforeUnloadEvent) { if (dirty.value || state.value.busy) { event.preventDefault(); event.returnValue = ''; } }
watch(() => state.value.notice, () => {
  if (state.value.failure) toast.value?.show(messages[state.value.failure]);
  else if (state.value.saved) toast.value?.show(props.review ? 'Respuesta guardada.' : 'Apelación enviada.', null, false);
  if (state.value.failure === 'unauthenticated') navigateTo('/iniciar-sesion?reason=expired', { replace: true });
});
onMounted(() => { model.load(); window.addEventListener('beforeunload', beforeUnload); });
onBeforeRouteLeave(canLeave);
onBeforeUnmount(() => { answer(false); unsubscribe(); model.dispose(); window.removeEventListener('beforeunload', beforeUnload); });
</script>
<template>
  <section class="appeals-screen">
    <TopToast ref="toast" />
    <header class="appeals-header"><h1 ref="heading" tabindex="-1">{{ review ? 'Revisar apelaciones' : 'Mis apelaciones' }}</h1><GlassNavigationButton label="Volver" @navigate="navigateTo(review ? '/moderacion' : '/inicio')" /></header>
    <ContentSkeleton v-if="!state.ready && state.busy" label="Consultando decisiones y apelaciones" />
    <ActionButton v-else-if="!state.ready" @click="model.load()">Reintentar consulta</ActionButton>
    <template v-else>
      <div class="appeals-tools"><ActionButton :working="state.busy" :disabled="!!state.frozen && !state.refreshRequired" @click="model.load()">Actualizar consulta</ActionButton><ActionButton v-if="state.selected" :disabled="state.busy || !!state.frozen" @click="select(null)">Volver a la lista</ActionButton></div>
      <div :class="{refreshing:state.busy}" :aria-busy="state.busy">
        <StaggerReveal v-if="!state.selected" as="div" class="appeals-list">
          <p v-if="!state.items.length">{{ review ? 'No hay apelaciones recibidas.' : 'No hay decisiones de moderación sobre tu contenido.' }}</p>
          <article v-for="item in state.items" :key="item.decision" class="appeals-card">
            <h2>{{ action(item.action) }}</h2><p>{{ kind(item.kind) }} · {{ date(item.decidedAt) }}</p><p>{{ item.reason }}</p>
            <p>{{ item.appeal?.answer ? 'Respondida' : item.appeal ? 'Pendiente de respuesta' : 'Puedes solicitar una revisión' }}</p>
            <ActionButton :disabled="state.busy" @click="select(item)">{{ item.appeal ? 'Consultar apelación' : 'Apelar decisión' }}</ActionButton>
          </article>
          <ActionButton v-if="state.next" :working="state.busy" @click="model.load(true)">Ver más</ActionButton>
        </StaggerReveal>
        <article v-else class="appeals-card">
          <h2>{{ action(state.selected.action) }}</h2><p>{{ kind(state.selected.kind) }} · {{ date(state.selected.decidedAt) }}</p><p>{{ state.selected.reason }}</p>
          <template v-if="state.selected.appeal"><h2>Apelación</h2><p>{{ state.selected.appeal.reason }}</p><p>Enviada el {{ date(state.selected.appeal.submittedAt) }}</p>
            <template v-if="state.selected.appeal.answer"><h2>Respuesta de moderación</h2><p>{{ state.selected.appeal.answer.reason }}</p><p>Respondida el {{ date(state.selected.appeal.answer.answeredAt) }}</p></template>
            <p v-else>Pendiente de respuesta</p>
          </template>
          <form v-if="editable" class="appeals-form" @submit.prevent="model.send()">
            <p>{{ review ? 'La respuesta quedará registrada. Para cambiar la visibilidad, registra una nueva decisión desde Revisar denuncias.' : 'Explica por qué solicitas revisar esta decisión. El motivo solo se comparte con los revisores autorizados.' }}</p>
            <TextField :model-value="state.reason" :label="review ? 'Respuesta y motivo' : 'Motivo de la apelación'" multiline unicode-limit :maxlength="1000" :invalid="state.failure === 'invalid'" :data-notice="state.notice" :disabled="state.busy || !!state.frozen" @update:model-value="model.edit($event)" />
            <ActionButton type="submit" :working="state.busy" :disabled="state.refreshRequired">{{ state.retrying ? 'Reintentar mismo envío' : review ? 'Guardar respuesta' : 'Enviar apelación' }}</ActionButton>
          </form>
        </article>
      </div>
    </template>
    <ConfirmationDialog :open="!!confirmation" title="¿Salir sin confirmar el envío?" description="El motivo se descartará. Si un envío no se confirmó, reintenta primero para conocer su resultado." action="Salir" @answer="answer" />
  </section>
</template>
