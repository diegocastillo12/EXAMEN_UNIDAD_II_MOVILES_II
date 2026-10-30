<script setup lang="ts">
import SightingMap from '../widgets/SightingMap.vue';
import '../styles/sightings.css';
import type { ActiveCase } from '../../../../../shared/features/case_reader/domain/case';
const props = defineProps<{ slug: string; activeCase: ActiveCase }>();
const emit = defineEmits<{ close: []; sent: [] }>();
const model = useNuxtApp().$sightingModel(props.slug);
const state = shallowRef(model.state); const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast'); const heading = useTemplateRef('heading');
const day = ref(''); const time = ref(''); const comment = ref(''); const point = computed(() => state.value.point);
const photo = shallowRef<Uint8Array | null>(null); const photoName = ref(''); const photoBusy = ref(false);
const id = ref(''); const blocked = computed(() => state.value.working || state.value.locked || !!state.value.receipt || photoBusy.value);
const invalid = (name: string) => state.value.failure?.fields.includes(name) ?? false;
const messages = { invalid: 'Revisa la fecha y hora, el punto elegido y el comentario. La fecha no puede estar en el futuro.',
  location: 'No pudimos obtener tu ubicación. Marca el punto en el mapa.',
  blocked:'Un bloqueo entre estas cuentas impide enviar nuevos avistamientos.',
  photo: 'No pudimos preparar la foto. Elige una imagen JPEG, PNG o WebP de hasta 8 MB, o envía sin foto.',
  closed: 'Este caso ya no admite avistamientos. Vuelve a la ficha para actualizar su estado.',
  conflict: 'Este envío ya fue registrado con otros datos. Vuelve a la ficha.',
  rate_limited: 'Has alcanzado el límite de envíos. Espera unos minutos antes de reintentar.',
  unavailable: 'No pudimos confirmar el envío. Conservamos tus datos: reintenta para comprobarlo sin duplicarlo.' };
function send() {
  let observedAt = '';
  if (day.value && time.value) { const date = new Date(`${day.value}T${time.value}`); if (Number.isFinite(date.getTime())) observedAt = date.toISOString(); }
  model.send({ id: id.value, observedAt, point: point.value, comment: comment.value, photo: photo.value });
}
watch(() => state.value.noticeId, () => {
  const failure = state.value.failure;
  if (failure) toast.value?.show(messages[failure.kind], ['unavailable', 'rate_limited'].includes(failure.kind) ? send : null);
});
watch(() => state.value.receipt, receipt => {
  if (receipt) { photo.value = null; toast.value?.show('Avistamiento guardado. Gracias por ayudar.', null, false); emit('sent'); }
});
async function selectPhoto(event: Event) {
  const input = event.target as HTMLInputElement; const file = input.files?.[0]; if (!file) return;
  photoBusy.value = true;
  try {
    if (file.size > 8388608 || !file.size) { toast.value?.show(messages.photo); return; }
    photo.value = new Uint8Array(await file.arrayBuffer()); photoName.value = file.name;
  } catch { toast.value?.show(messages.photo); }
  finally { photoBusy.value = false; input.value = ''; }
}
onMounted(() => { id.value = crypto.randomUUID(); heading.value?.focus(); });
onBeforeUnmount(() => { unsubscribe(); model.dispose(); photo.value = null; });
</script>
<template>
  <section class="sighting-screen" aria-label="Reportar avistamiento">
    <button class="glass sighting-back" type="button" aria-label="Volver a la ficha" title="Volver a la ficha" :disabled="state.working" @click="emit('close')">‹</button>
    <header><p class="eyebrow">Una huella tuya puede ayudar</p><h1 ref="heading" tabindex="-1">{{ state.receipt ? 'Gracias por colaborar' : '¿Dónde le viste?' }}</h1></header>
    <StaggerReveal as="div" v-if="state.receipt" class="sighting-confirmation">
      <h2>Avistamiento guardado</h2><p>Tu información quedó vinculada a este caso.</p>
      <p v-if="state.receipt.late" class="muted">Se registró como avistamiento tardío, con la fecha y hora en que ocurrió.</p>
      <ActionButton variant="primary" @click="emit('close')">Volver al caso</ActionButton>
    </StaggerReveal>
    <StaggerReveal as="form" v-else class="sighting-form" novalidate @submit.prevent="send">
      <p class="muted">Ayuda a encontrar a {{ activeCase.name || 'esta mascota' }}. No necesitas crear una cuenta.</p>
      <fieldset :disabled="blocked"><legend>Cuándo le viste</legend>
        <div class="sighting-date-row">
          <DateField v-model="day" label="Fecha" min="2000-01-01" :disabled="blocked" :invalid="invalid('observedAt')" />
          <TimeField v-model="time" label="Hora" :disabled="blocked" :invalid="invalid('observedAt')" />
        </div><p class="privacy">Usa la fecha y hora locales en que ocurrió, aunque haya sido otro día.</p>
      </fieldset>
      <fieldset :disabled="blocked"><legend>Dónde le viste</legend>
        <p class="privacy">Toca el punto del mapa o muévelo y usa su centro. El área inicial es una referencia aproximada del caso; debes elegir el punto del avistamiento.</p>
        <ActionButton :working="state.locating" :disabled="blocked" @click="model.locate()">Usar mi ubicación actual</ActionButton>
        <ClientOnly><SightingMap :center="activeCase.area" :point="point" :disabled="blocked" :invalid="invalid('point')" @choose="model.choosePoint($event)" @failed="retry => toast?.show('No pudimos mostrar el mapa.', retry)" /><template #fallback><div class="shape map-placeholder" role="status" aria-label="Preparando mapa" /></template></ClientOnly>
        <p class="privacy">{{ point ? (point.source === 'gps' ? `Ubicación actual seleccionada · precisión aproximada ${Math.round(point.accuracy || 0)} m.` : 'Punto manual seleccionado.') : 'Elige el punto donde viste la mascota.' }} El punto exacto se conserva protegido y no se muestra en la ficha pública.</p>
      </fieldset>
      <fieldset :disabled="blocked"><legend>Detalles que pueden ayudar</legend>
        <TextField v-model="comment" label="Comentario (opcional)" multiline :maxlength="500" :disabled="blocked" :invalid="invalid('comment')" />
        <p class="privacy">Evita incluir teléfonos, direcciones de viviendas o datos personales.</p>
        <label class="secondary photo-choice" :class="{ working: photoBusy }">{{ photoName || 'Añadir foto (opcional)' }}<input type="file" accept="image/jpeg,image/png,image/webp" :disabled="blocked" @change="selectPhoto" /></label>
        <label class="secondary photo-choice">Tomar foto (opcional)<input type="file" accept="image/jpeg,image/png,image/webp" capture="environment" :disabled="blocked" @change="selectPhoto" /></label>
        <ActionButton v-if="photo" @click="photo = null; photoName = ''">Quitar foto</ActionButton>
        <p class="privacy">Puedes elegir una foto de tu galería. Si cancelas o no das permiso, puedes continuar sin foto. Se eliminan sus metadatos antes de guardarla.</p>
      </fieldset>
      <ActionButton variant="primary" :working="state.working" :disabled="photoBusy || state.locating || state.failure?.kind === 'closed' || state.failure?.kind === 'conflict'" @click="send">{{ state.locked ? 'Reintentar envío' : 'Enviar avistamiento' }}</ActionButton>
    </StaggerReveal>
    <TopToast ref="toast" />
  </section>
</template>
