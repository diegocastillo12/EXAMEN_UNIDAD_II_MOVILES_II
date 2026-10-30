<script setup lang="ts">
import type { Pet, PetDraft, ReportDraft, ReportKind, ReportPhoto, Species } from '#shared/features/recovery/domain/recovery';
import AnimalFields from '../widgets/AnimalFields.vue';
import type { AnimalForm } from '../widgets/AnimalFields.vue';
import '../styles/recovery.css';
const props = defineProps<{ actor:string; section:'explore'|'pets'|'report' }>();
const model = useNuxtApp().$recoveryModel(props.actor), state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast');
const motion = useNuxtApp().$originTransition;
const router = useRouter();
const query = reactive({ kind:'all',species:'all',status:'active' });
const editor = ref(false), petId = ref(''), version = ref(0);
const blank = (): AnimalForm => ({ name:'',species:'',speciesDetail:'',size:'',sex:props.section === 'pets' ? 'male' : '',ageMonths:'',traits:'' });
const animal = ref(blank()), baseline = ref('');
const kind = ref<ReportKind>('own_loss'), selectedPet = ref(''), selectedTarget = ref(''), localDate = ref(''), place = ref('');
const custody = ref<''|'with_me'|'not_with_me'>('');
const point = ref<{ latitude:number;longitude:number }|null>(null), photos = shallowRef<readonly ReportPhoto[]>([]), fileNames = ref<string[]>([]);
const photoBusy = ref(false), uploadPetId = ref(''), reportId = ref('');
const savingDraft = ref(false), pendingPetPhoto = shallowRef<{ pet:string;photo:ReportPhoto }|null>(null);
const restoringDraft = ref(props.section === 'report'), restoredDraft = shallowRef<ReportDraft|null>(null);
let disposed = false;
const savedPet = computed(() => state.value.pets.find(p => p.id === selectedPet.value));
const invalid = computed(() => state.value.failure?.fields || []);
const frozen = shallowRef<{ draft:ReportDraft;photos:readonly ReportPhoto[] }|null>(null);
const blocked = computed(() => restoringDraft.value || state.value.busy || photoBusy.value || savingDraft.value || !!frozen.value || !!state.value.receipt);
const reportPrerequisitePending = computed(() => !frozen.value && (kind.value === 'own_loss' ? !state.value.petsReady || state.value.petsLoading : !['possible_loss','independent_found'].includes(kind.value) ? !state.value.targetsReady || state.value.targetsLoading : false));
const dirty = computed(() => props.section === 'pets' ? !!pendingPetPhoto.value || (editor.value && JSON.stringify(animal.value) !== baseline.value) : props.section === 'report' && !state.value.receipt && !!(kind.value !== 'own_loss' || selectedPet.value || selectedTarget.value || localDate.value || place.value || point.value || photos.value.length || animal.value.traits || animal.value.species));
const title = computed(() => props.section === 'explore' ? 'Explorar' : props.section === 'pets' ? editor.value ? version.value ? 'Editar mascota' : 'Registrar mascota' : 'Mis mascotas' : 'Reportar');
const messages = { blocked:'Un bloqueo entre estas cuentas impide enviar nuevos avisos. Revisa Cuentas bloqueadas desde tu perfil.',invalid:'Revisa los campos señalados. Completa la información y selecciona las fotos necesarias.',photo:'Elige imágenes JPEG, PNG o WebP de hasta 8 MB. Puedes usar hasta tres fotos.',unauthenticated:'Tu sesión terminó. Vuelve a iniciar sesión.',forbidden:'No tienes permiso para realizar esta operación.',conflict:'Los datos cambiaron. Actualiza la información antes de volver a enviarla.',unavailable:'No pudimos confirmar la operación. Conservamos tus datos para reintentar.' };
watch(() => state.value.notice, () => { if (state.value.failure) { toast.value?.show(messages[state.value.failure.kind]); if (state.value.failure.kind === 'unauthenticated') void navigateTo('/iniciar-sesion?reason=expired'); } });
watch(() => state.value.receipt, receipt => { if (receipt) { photos.value = []; frozen.value = null; fileNames.value = []; toast.value?.show('Reporte publicado. Gracias por ayudar.',null,false); } });
function load(more = false) { return model.load(props.section, { ...query },more); }
function editPet(p?: Pet) {
  editor.value = true; petId.value = p?.id || crypto.randomUUID(); version.value = p?.version || 0;
  animal.value = p ? { name:p.name,species:p.species,speciesDetail:p.speciesDetail || '',size:p.size || '',sex:p.sex || '',ageMonths:p.ageMonths ?? '',traits:p.traits } : blank();
  baseline.value = JSON.stringify(animal.value);
}
async function savePet() {
  const a = animal.value;
  const pet = await model.savePet({ id:petId.value,version:version.value,name:a.name,species:a.species as Species,speciesDetail:a.speciesDetail,size:a.size,sex:a.sex || null,ageMonths:a.ageMonths === '' || a.ageMonths === null ? null : Number(a.ageMonths),traits:a.traits } as PetDraft);
  if (pet) { editor.value = false; toast.value?.show('Mascota guardada.',null,false); }
}
async function selectFiles(event: Event, pet?: Pet) {
  const input = event.target as HTMLInputElement, files = [...(input.files || [])]; if (!files.length) return;
  photoBusy.value = true; uploadPetId.value = pet?.id || '';
  try {
    if (files.length > (pet ? 1 : 3) || files.some(f => !f.size || f.size > 8388608 || !['image/jpeg','image/png','image/webp'].includes(f.type))) { toast.value?.show(messages.photo); return; }
    const selected = []; for (const file of files) selected.push({ id:crypto.randomUUID(),bytes:new Uint8Array(await file.arrayBuffer()) });
    if (pet) { pendingPetPhoto.value = { pet:pet.id,photo:selected[0]! }; await retryPetPhoto(); }
    else { photos.value = selected; fileNames.value = files.map(f => f.name); }
  } catch { toast.value?.show(messages.photo); }
  finally { photoBusy.value = false; uploadPetId.value = ''; input.value = ''; }
}
async function retryPetPhoto() {
  const pending = pendingPetPhoto.value; if (!pending) return;
  uploadPetId.value = pending.pet;
  if (await model.uploadPetPhoto(pending.pet,pending.photo)) { pendingPetPhoto.value = null; toast.value?.show('Foto guardada.',null,false); }
  uploadPetId.value = '';
}
function snapshot() {
  const target = state.value.targets.find(c => c.source + ':' + c.id === selectedTarget.value), a = animal.value;
  // A restored reference remains part of the local draft while its remote
  // metadata is pending. Do not erase it when saving independently edited text.
  const previousPet = restoredDraft.value?.petId === selectedPet.value ? restoredDraft.value : null;
  const previousTarget = restoredDraft.value && selectedTarget.value === (restoredDraft.value.communityTarget ? 'found:' : 'lost:') + restoredDraft.value.targetId ? restoredDraft.value : null;
  const date = new Date(localDate.value);
  const draft: ReportDraft = { id:reportId.value,kind:kind.value,custody:kind.value === 'independent_found' ? custody.value || null : null,petId:savedPet.value?.id || previousPet?.petId || null,petVersion:savedPet.value?.version ?? previousPet?.petVersion ?? null,targetId:['sighting','with_reporter'].includes(kind.value) ? target?.id || previousTarget?.targetId || null : null,communityTarget:['sighting','with_reporter'].includes(kind.value) ? (target ? target.source === 'found' : previousTarget?.communityTarget ?? false) : false,occurredAt:Number.isFinite(date.getTime()) ? date.toISOString() : '',latitude:point.value?.latitude ?? null,longitude:point.value?.longitude ?? null,place:place.value,species:a.species,speciesDetail:a.speciesDetail,size:a.size,sex:a.sex,traits:a.traits,photoIds:kind.value === 'own_loss' ? savedPet.value?.photoIds.slice(0,3) || previousPet?.photoIds || [] : photos.value.map(p => p.id) };
  return { draft,photos:kind.value === 'own_loss' ? [] : photos.value };
}
async function send() {
  if (restoringDraft.value || reportPrerequisitePending.value) return;
  const value = frozen.value || snapshot();
  await model.send(value.draft,value.photos);
  if (state.value.failure && ['unavailable','conflict'].includes(state.value.failure.kind)) frozen.value = value;
}
async function remember() {
  if (restoringDraft.value || savingDraft.value || state.value.busy) return;
  savingDraft.value = true;
  const value = frozen.value || snapshot();
  try { if (await model.remember({ ...value,frozen:!!frozen.value })) toast.value?.show('Borrador guardado en este navegador para tu cuenta.',null,false); }
  finally { savingDraft.value = false; }
}
const confirm = shallowRef<{ resolve:(value:boolean)=>void }|null>(null);
function ask() { return new Promise<boolean>(resolve => { confirm.value = { resolve }; }); }
function answer(value:boolean) { const pending = confirm.value; confirm.value = null; pending?.resolve(value); }
async function cancelEditor() { if (state.value.busy || (dirty.value && !await ask())) return; await motion.closeLocal(() => { editor.value = false; }); }
function closeReport() {
  if (state.value.busy || photoBusy.value || savingDraft.value || confirm.value || motion.busy.value) return;
  const previous = router.options.history.state.back;
  if (typeof previous === 'string' && ['/inicio','/explorar','/mis-mascotas'].includes(previous.split('?')[0]!)) router.back();
  else void navigateTo('/inicio', { replace:true });
}
onBeforeRouteLeave(async () => !state.value.busy && !photoBusy.value && !savingDraft.value && (!dirty.value || await ask()));
const beforeUnload = (event: BeforeUnloadEvent) => { if (dirty.value || state.value.busy) event.preventDefault(); };
onMounted(async () => {
  reportId.value = crypto.randomUUID(); window.addEventListener('beforeunload',beforeUnload);
  // Start independent remote reads and map mounting before local draft I/O.
  void load();
  if (props.section === 'report') {
    const saved = await model.restoreDraft();
    if (disposed) return;
    if (saved) {
      const d = saved.draft; restoredDraft.value = d; reportId.value = d.id; kind.value = d.kind; custody.value = d.custody || ''; selectedPet.value = d.petId || ''; selectedTarget.value = (d.communityTarget ? 'found:' : 'lost:') + (d.targetId || ''); place.value = d.place;
      if (d.latitude !== null && d.longitude !== null) point.value = { latitude:d.latitude,longitude:d.longitude };
      if (d.occurredAt) { const date = new Date(d.occurredAt); if (Number.isFinite(date.getTime())) localDate.value = new Date(date.getTime()-date.getTimezoneOffset()*60000).toISOString().slice(0,16); }
      animal.value = { ...blank(),species:d.species,speciesDetail:d.speciesDetail,size:d.size,sex:d.sex,traits:d.traits }; photos.value = saved.photos; fileNames.value = saved.photos.map((_,i) => 'Foto ' + (i+1));
      if (saved.frozen) frozen.value = { draft:d,photos:saved.photos };
      toast.value?.show('Restauramos tu borrador de este navegador.',null,false);
    }
    restoringDraft.value = false;
  }
});
onBeforeUnmount(() => { disposed = true; unsubscribe(); model.dispose(); photos.value = []; restoredDraft.value = null; frozen.value = null; pendingPetPhoto.value = null; answer(false); window.removeEventListener('beforeunload',beforeUnload); });
const photoUrl = (source:string,id:string) => '/api/recovery/photo?source=' + source + '&id=' + id;
const speciesLabel = (v:string) => ({ dog:'Perro',cat:'Gato',other:'Otra especie' }[v] || v);
const kindLabel = (v:string) => ({ lost:'En búsqueda',found:'Encontrada',sighting:'Avistamiento' }[v] || v);
function imageFailed(event: Event) { (event.target as HTMLImageElement).hidden = true; }
</script>

<template>
  <section class="recovery-screen">
    <TopToast ref="toast" />
    <div v-if="section === 'report'" class="recovery-navigation"><GlassNavigationButton close label="Cerrar reporte" :disabled="state.busy || photoBusy || savingDraft || !!confirm || motion.busy.value" @navigate="closeReport" /></div>
    <header class="account-welcome"><h1>{{ title }}</h1><p v-if="section === 'explore'">Ayuda a encontrar su camino de vuelta a casa.</p><p v-else-if="section === 'pets' && !editor">Tus mascotas, contigo en web y móvil.</p></header>
    <ContentSkeleton v-if="state.loading && section !== 'report'" label="Consultando información" />
    <div v-else class="recovery-content" :class="{ refreshing:state.refreshing }" :aria-busy="state.refreshing">
      <template v-if="section === 'explore'">
        <form class="recovery-filters recovery-fields" @submit.prevent="load()">
          <FieldSelect label="Tipo" v-model="query.kind" :disabled="state.refreshing" :options="[{value:'all',label:'Todos'},{value:'lost',label:'En búsqueda'},{value:'found',label:'Encontradas'},{value:'sighting',label:'Avistamientos'}]" />
          <FieldSelect label="Especie" v-model="query.species" :disabled="state.refreshing" :options="[{value:'all',label:'Todas'},{value:'dog',label:'Perros'},{value:'cat',label:'Gatos'},{value:'other',label:'Otras especies'}]" />
          <FieldSelect label="Estado" v-model="query.status" :disabled="state.refreshing" :options="[{value:'active',label:'Activos'},{value:'resolved',label:'Resueltos visibles para ti'},{value:'all',label:'Todos los visibles'}]" />
          <ActionButton type="submit" variant="primary" :working="state.refreshing">Aplicar filtros</ActionButton>
        </form>
        <StaggerReveal v-if="state.items.length" as="div" class="recovery-cards">
          <article v-for="item in state.items" :key="item.source + item.id" class="recovery-card">
            <div class="recovery-photo"><img v-if="item.hasPhoto" :src="photoUrl(item.source,item.id)" alt="" loading="lazy" @error="imageFailed" /><span v-else>{{ speciesLabel(item.species) }}</span></div>
            <div class="recovery-card-body"><p class="eyebrow">{{ kindLabel(item.kind) }} · {{ item.status === 'active' ? 'Activo' : 'Resuelto' }}</p><h2>{{ item.name || speciesLabel(item.species) }}</h2><p class="recovery-traits">{{ item.traits }}</p><p v-if="item.occurredAt" class="privacy">{{ new Date(item.occurredAt).toLocaleDateString('es-PE',{timeZone:'America/Lima'}) }}</p><p v-if="Number.isFinite(item.latitude) && Number.isFinite(item.longitude)" class="privacy">Zona aproximada: {{ item.latitude.toFixed(3) }}, {{ item.longitude.toFixed(3) }}</p></div>
            <slot name="case-actions" :item="item" />
          </article>
        </StaggerReveal>
        <p v-else-if="!state.failure" class="recovery-empty">No hay casos que coincidan con estos filtros.</p>
        <ActionButton v-if="state.cursor" :working="state.refreshing" @click="load(true)">Ver más casos</ActionButton>
      </template>
      <template v-else-if="section === 'pets'">
        <form v-if="editor" class="recovery-form" novalidate @submit.prevent="savePet">
          <AnimalFields v-model="animal" pet :disabled="state.busy" :invalid="invalid" />
          <div class="recovery-actions"><ActionButton type="submit" variant="primary" :working="state.busy">Guardar mascota</ActionButton><ActionButton :disabled="state.busy" @click="cancelEditor">Cancelar</ActionButton></div>
        </form>
        <template v-else>
          <div class="recovery-actions"><OriginActionButton variant="primary" :disabled="blocked" :action="() => editPet()">Registrar mascota</OriginActionButton><ActionButton :working="state.refreshing" :disabled="blocked" @click="load()">Actualizar</ActionButton></div>
          <StaggerReveal v-if="state.pets.length" as="div" class="recovery-cards">
            <article v-for="p in state.pets" :key="p.id" class="recovery-card">
              <div class="recovery-photo"><img v-if="p.photoIds.length" :key="p.photoIds.join()" :src="photoUrl('pet',p.id)" alt="" loading="lazy" @error="imageFailed" /><span v-else>{{ speciesLabel(p.species) }}</span></div>
              <div class="recovery-card-body"><h2>{{ p.name }}</h2><p class="privacy">{{ speciesLabel(p.species) }}<template v-if="p.ageMonths !== null"> · {{ p.ageMonths }} meses</template></p><p class="recovery-traits">{{ p.traits }}</p><div class="recovery-actions"><OriginActionButton :disabled="blocked" :action="() => editPet(p)">Editar</OriginActionButton><label class="secondary recovery-file" :class="{ working:state.busy && uploadPetId === p.id }">Añadir foto<input type="file" accept="image/jpeg,image/png,image/webp" :disabled="blocked || !!pendingPetPhoto || p.photoIds.length >= 3" :aria-label="'Añadir foto de ' + p.name" @change="selectFiles($event,p)" /></label><ActionButton v-if="pendingPetPhoto?.pet === p.id" :working="state.busy" @click="retryPetPhoto">Reintentar foto</ActionButton></div><p v-if="p.photoIds.length" class="privacy">{{ p.photoIds.length }} de 3 fotos</p></div>
            </article>
          </StaggerReveal>
          <p v-else-if="!state.failure" class="recovery-empty">Todavía no has registrado mascotas.</p>
        </template>
      </template>
      <template v-else>
        <div v-if="state.receipt" class="recovery-success"><h2>Reporte publicado</h2><p>Tu información ya está guardada en Entre Huellas.</p><NavigationLink to="/explorar" class="primary">Ir a Explorar</NavigationLink></div>
        <StaggerReveal v-else as="form" class="recovery-form" novalidate @submit.prevent="send">
          <div class="recovery-fields">
            <FieldSelect class="recovery-full" label="¿Cómo quieres ayudar?" v-model="kind" :disabled="blocked" :options="[{value:'own_loss',label:'Se perdió mi mascota'},{value:'possible_loss',label:'Vi una mascota posiblemente perdida'},{value:'independent_found',label:'Encontré una mascota y no sé de quién es'},{value:'sighting',label:'Vi una mascota que están buscando'},{value:'with_reporter',label:'Tengo a una mascota que están buscando'}]" />
            <FieldSelect v-if="kind === 'independent_found'" class="recovery-full" label="¿Está bajo tu cuidado?" v-model="custody" :disabled="blocked" :options="[{value:'',label:'No indico'},{value:'with_me',label:'Sí, está conmigo'},{value:'not_with_me',label:'No está conmigo'}]" />
            <template v-if="kind === 'own_loss'">
              <FieldSkeleton v-if="!state.petsReady && !state.petsFailure" class="recovery-full" label="Tu mascota" />
              <FieldSelect v-else-if="state.petsReady" class="recovery-full" :class="{refreshing:state.petsLoading}" :aria-busy="state.petsLoading" label="Tu mascota" v-model="selectedPet" :disabled="blocked || state.petsLoading" :invalid="invalid.includes('pet') || invalid.includes('photos')" :options="[{value:'',label:'Selecciona tu mascota'},...state.pets.map(p => ({value:p.id,label:p.name}))]" />
              <div v-if="state.petsFailure" class="recovery-full"><ActionButton :working="state.petsLoading" :disabled="blocked" @click="model.loadReportSource('pets')">Reintentar mascotas</ActionButton></div>
              <p class="privacy recovery-full">Se publicarán hasta tres fotos verificadas de la mascota. Puedes añadirlas desde Mis mascotas.</p>
              <NavigationLink v-if="state.petsReady && (!state.pets.length || (savedPet && !savedPet.photoIds.length))" to="/mis-mascotas" class="text-button">Registrar mascota o añadir fotos</NavigationLink>
            </template>
            <template v-else-if="!['possible_loss','independent_found'].includes(kind)">
              <FieldSkeleton v-if="!state.targetsReady && !state.targetsFailure" class="recovery-full" label="Búsqueda a la que ayudas" />
              <FieldSelect v-else-if="state.targetsReady" class="recovery-full" :class="{refreshing:state.targetsLoading}" :aria-busy="state.targetsLoading" label="Búsqueda a la que ayudas" v-model="selectedTarget" :disabled="blocked || state.targetsLoading" :invalid="invalid.includes('target')" :options="[{value:'',label:'Selecciona una búsqueda activa'},...state.targets.map(target => ({value:target.source + ':' + target.id,label:target.name || speciesLabel(target.species)}))]" />
              <div v-if="state.targetsFailure" class="recovery-full"><ActionButton :working="state.targetsLoading" :disabled="blocked" @click="model.loadReportSource('targets')">Reintentar búsquedas</ActionButton></div>
            </template>
            <DateTimeField v-model="localDate" label="Fecha y hora" :disabled="blocked" :invalid="invalid.includes('occurredAt')" />
            <TextField v-model="place" label="Referencia del lugar (privada)" :maxlength="120" :disabled="blocked" :invalid="invalid.includes('place')" />
          </div>
          <div class="recovery-map"><h2>¿Dónde ocurrió?</h2><p class="privacy">Marca el lugar en el mapa. La ficha pública muestra una zona aproximada; la referencia exacta permanece privada.</p><LocationMap :center="{latitude:-12.0464,longitude:-77.0428}" :point="point" :radius-meters="kind === 'sighting' || kind === 'with_reporter' ? 200 : 0" :disabled="blocked" :invalid="invalid.includes('point')" @choose="point = $event" @failed="retry => toast?.show('No pudimos mostrar el mapa. Puedes reintentar.',retry)" /></div>
          <AnimalFields v-if="['possible_loss','independent_found'].includes(kind)" v-model="animal" :disabled="blocked" :invalid="invalid" />
          <div v-else-if="kind !== 'own_loss'" class="recovery-fields"><TextField v-model="animal.traits" class="recovery-full" label="¿Qué observaste?" multiline :maxlength="200" :disabled="blocked" :invalid="invalid.includes('traits')" /></div>
          <div v-if="kind !== 'own_loss'" class="recovery-upload"><label class="secondary recovery-file" :class="{ working:photoBusy,invalid:invalid.includes('photos') }">{{ ['possible_loss','independent_found'].includes(kind) ? 'Elegir fotos' : 'Añadir fotos (opcional)' }}<input type="file" accept="image/jpeg,image/png,image/webp" multiple :disabled="blocked" aria-label="Fotos del reporte" @change="selectFiles($event)" /></label><p class="privacy">Hasta 3 fotos JPEG, PNG o WebP, de 8 MB cada una. Se eliminan los metadatos antes de publicar.</p><ul v-if="fileNames.length"><li v-for="name in fileNames" :key="name">{{ name }}</li></ul></div>
          <div class="recovery-actions"><ActionButton type="submit" variant="primary" :working="state.busy" :disabled="restoringDraft || reportPrerequisitePending || photoBusy || savingDraft">{{ frozen ? 'Reintentar el mismo envío' : 'Publicar reporte' }}</ActionButton><ActionButton :working="savingDraft" :disabled="restoringDraft || state.busy || photoBusy" @click="remember">Guardar borrador</ActionButton></div>
        </StaggerReveal>
      </template>
      <ActionButton v-if="state.failure && !editor && !state.receipt && !frozen && (section !== 'report' || (!state.petsFailure && !state.targetsFailure))" :working="section === 'report' ? state.petsLoading || state.targetsLoading : state.refreshing" :disabled="state.busy" @click="load()">Actualizar información</ActionButton>
    </div>
    <ConfirmationDialog :open="!!confirm" title="¿Salir sin guardar?" description="Los cambios que todavía no guardaste se descartarán." action="Salir" @answer="answer" />
  </section>
</template>
