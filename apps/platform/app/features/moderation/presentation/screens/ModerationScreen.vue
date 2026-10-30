<script setup lang="ts">
import '../styles/moderation.css';
import DecisionOptions from '../widgets/DecisionOptions.vue';
const emit=defineEmits<{detail:[visible:boolean]}>();
const model=useNuxtApp().$moderationModel(),state=shallowRef(model.state),unsubscribe=model.subscribe(value=>{state.value=value;});
const toast=useTemplateRef('toast'),heading=useTemplateRef('heading');
const accessProblem=ref(false);
const createAccount=useNuxtApp().$accessModel;
let accessCheck=0;
async function checkAccess(){
  const check=++accessCheck;
  accessProblem.value=false;
  const account=createAccount();
  try{
    await account.checkSession();
    if(check!==accessCheck)return;
    if(!account.state.session){
      if(account.state.failure){accessProblem.value=true;toast.value?.show('No pudimos comprobar tu cuenta. Puedes reintentar.');return;}
      await navigateTo('/iniciar-sesion',{replace:true});return;
    }
    if(!account.state.session.profile.onboardingCompleted){await navigateTo('/bienvenida',{replace:true});return;}
    await model.checkSession();
  }finally{account.dispose();}
}
const confirm=ref<{title:string;description:string;action:string;resolve:(answer:boolean)=>void}|null>(null);
const messages={invalid:'Revisa los campos. La decisión necesita un motivo de hasta 500 caracteres.',unauthenticated:'Inicia sesión con una cuenta autorizada para continuar.',forbidden:'Esta cuenta no tiene permiso para revisar denuncias.',conflict:'Hay una decisión más reciente. Consulta el estado actual antes de decidir.',unavailable:'No pudimos completar la operación. Puedes reintentar.'};
let channel:BroadcastChannel|undefined,expiry:ReturnType<typeof setTimeout>|undefined;
const dirty=computed(()=>state.value.stage==='detail'&&!state.value.receipt&&(!!state.value.reason||!!state.value.frozen));
const blocked=computed(()=>state.value.busy||!!state.value.frozen||!!state.value.receipt||state.value.failure?.kind==='conflict');
function ask(title:string,description:string,action:string){return new Promise<boolean>(resolve=>{confirm.value={title,description,action,resolve};});}
function answer(value:boolean){const pending=confirm.value;confirm.value=null;pending?.resolve(value);}
async function canLeave(){return !state.value.busy&&(!dirty.value||await ask('¿Salir de esta revisión?',state.value.frozen?'La decisión pudo haberse guardado. Reintenta el mismo envío antes de salir para confirmar el resultado.':'Se descartará el motivo que todavía no guardaste.','Salir'));}
let exitReason='';
async function logout(){if(!await canLeave())return;exitReason='signed-out';await model.logout();channel?.postMessage('changed');}
async function queue(){if(await canLeave())await model.load();}
async function decide(){if(state.value.frozen||await ask('¿Guardar esta decisión?',state.value.action==='hide'?'El contenido dejará de mostrarse en las consultas públicas. Su estado operativo e historial se conservarán.':'La decisión y su motivo quedarán registrados. La visibilidad de un recurso vinculado seguirá respetando la de su búsqueda.','Guardar decisión'))await model.decide();}
function date(value:string){return new Intl.DateTimeFormat('es-PE',{dateStyle:'medium',timeStyle:'short'}).format(new Date(value));}
function kind(value:string){return value==='lost'?'Caso perdido':value==='found'?'Publicación o aviso':'Avistamiento';}
function actionLabel(value:string){return value==='hide'?'Ocultar contenido':value==='show'?'Restaurar visibilidad':'Resolver sin cambiar visibilidad';}
function beforeUnload(event:BeforeUnloadEvent){if(dirty.value||state.value.busy){event.preventDefault();event.returnValue='';}}
watch(()=>state.value.notice,()=>{if(state.value.failure)toast.value?.show(messages[state.value.failure.kind]);else if(state.value.receipt)toast.value?.show('Decisión guardada.',null,false);});
watch(()=>[state.value.stage,state.value.busy] as const,([stage,busy])=>{if(stage==='login'&&!busy&&state.value.failure?.kind!=='unavailable'){answer(false);navigateTo(state.value.failure?.kind==='forbidden'?'/inicio?reason=forbidden':exitReason?'/iniciar-sesion?reason='+exitReason:'/iniciar-sesion',{replace:true});}});
watch(()=>state.value.stage,async stage=>{emit('detail',stage==='detail');await nextTick();heading.value?.focus();});
watch(()=>state.value.session,session=>{clearTimeout(expiry);if(session)expiry=setTimeout(()=>{exitReason='expired';model.clear();},Math.max(0,session.expiresAt-Date.now()));});
onMounted(()=>{checkAccess();window.addEventListener('beforeunload',beforeUnload);channel=new BroadcastChannel('eh-access');channel.onmessage=event=>{if(event.data?.actor&&event.data.actor===state.value.session?.actor)return;answer(false);model.invalidate();checkAccess();};});
onBeforeRouteLeave(async()=>await canLeave());
onBeforeUnmount(()=>{++accessCheck;unsubscribe();model.dispose();channel?.close();clearTimeout(expiry);window.removeEventListener('beforeunload',beforeUnload);answer(false);});
</script>
<template>
  <OriginPageSurface id="view" class="moderation-screen">
    <NavigationLink to="/moderacion/apelaciones" class="text-button">Revisar apelaciones</NavigationLink>
    <header class="moderation-header"><div><h1 ref="heading" tabindex="-1">{{state.stage==='detail'?'Revisar denuncia':'Denuncias'}}</h1></div><NavigationLink class="text-button" to="/inicio">Volver a Entre Huellas</NavigationLink><ActionButton v-if="state.session" :disabled="state.busy" @click="logout">Cerrar sesión</ActionButton></header>
    <TopToast ref="toast" />
    <section v-if="accessProblem"><ActionButton @click="checkAccess()">Reintentar conexión</ActionButton></section>
    <ContentSkeleton label="Consultando denuncias" v-else-if="state.stage==='checking'" />
    <section v-else-if="state.stage==='login'">
      <ActionButton v-if="state.failure?.kind==='unavailable'" @click="model.checkSession()">Reintentar conexión</ActionButton>
      <ContentSkeleton v-else label="Abriendo inicio de sesión" />
    </section>
    <section v-else-if="state.stage==='queue'" aria-label="Cola de denuncias">
      <div class="moderation-tools"><div class="moderation-tabs" role="group" aria-label="Estado de las denuncias"><ActionButton :disabled="state.busy" :aria-pressed="!state.resolved" @click="model.load(false)">Pendientes</ActionButton><ActionButton :disabled="state.busy" :aria-pressed="state.resolved" @click="model.load(true)">Resueltas</ActionButton></div><ActionButton :working="state.busy&&!!state.page" @click="model.load()">Actualizar</ActionButton></div>
      <ContentSkeleton label="Consultando denuncias" v-if="state.busy&&!state.page" />
      <StaggerReveal as="div" v-else-if="state.page" :class="{refreshing:state.busy}" :aria-busy="state.busy">
        <div v-if="!state.page.items.length" class="moderation-panel"><h2>{{state.resolved?'Sin denuncias resueltas':'No hay denuncias pendientes'}}</h2><p>La consulta se completó. Puedes actualizar para revisar nuevos envíos.</p></div>
        <ul v-else class="moderation-list"><li v-for="report in state.page.items" :key="report.id" class="moderation-panel"><div><span class="chip">{{kind(report.kind)}}</span><h2>Denuncia recibida</h2><p>{{date(report.submittedAt)}}</p><p class="privacy moderation-reference">Referencia: {{report.id}}</p></div><ActionButton :disabled="state.busy" @click="model.open(report.id)">Revisar denuncia</ActionButton></li></ul>
        <ActionButton v-if="state.page.next" :working="state.busy" @click="model.load(state.resolved,true)">Ver más denuncias</ActionButton>
      </StaggerReveal>
      <ActionButton v-else-if="state.failure" @click="model.load()">Reintentar consulta</ActionButton>
    </section>
    <section v-else-if="state.stage==='detail'" aria-label="Revisión de denuncia">
      <GlassNavigationButton label="Volver a denuncias" :disabled="state.busy" @navigate="queue" />
      <ContentSkeleton label="Consultando denuncias" v-if="state.busy&&!state.detail" />
      <StaggerReveal as="div" v-else-if="state.detail" class="moderation-detail" :class="{refreshing:state.busy}" :aria-busy="state.busy">
        <article class="moderation-panel"><p class="eyebrow">{{kind(state.detail.kind)}} · {{date(state.detail.submittedAt)}}</p><h2>Motivo de la denuncia</h2><p class="moderation-text">{{state.detail.reason}}</p><template v-if="state.detail.evidence"><h3>Evidencia aportada</h3><p class="moderation-text">{{state.detail.evidence}}</p></template><p class="privacy">Esta información es privada. La consulta queda registrada.</p></article>
        <article class="moderation-panel"><h2>Contenido denunciado</h2><template v-if="state.detail.resource"><h3>{{state.detail.resource.title}}</h3><p class="moderation-text">{{state.detail.resource.text||'Sin descripción escrita'}}</p><p class="chip">{{state.detail.effectiveHidden?'Oculto':'Visible según permisos del caso'}}</p><p v-if="state.detail.resource.removed" class="privacy">El autor retiró el contenido. El registro de la denuncia se conserva.</p><template v-if="state.detail.resource.hasPhoto"><ActionButton v-if="!state.photo" @click="model.requestPhoto()">Ver foto del contenido</ActionButton><img v-else class="moderation-photo" :src="`/api/moderation/reports/${state.detail.id}/evidence`" alt="Foto del contenido denunciado" @error="model.photoFailed()" /></template></template><p v-else>El recurso original ya no está disponible. La denuncia y sus decisiones se conservan.</p></article>
        <article class="moderation-panel moderation-decision">
          <h2>{{state.receipt?'Decisión registrada':'Decidir sobre el contenido'}}</h2>
          <StaggerReveal as="div" v-if="state.receipt"><p>{{actionLabel(state.receipt.action)}}</p><p class="moderation-text">{{state.receipt.reason}}</p><p>{{date(state.receipt.decidedAt)}}</p><p class="privacy">El estado operativo del caso se conserva.</p><ActionButton @click="model.refreshDetail()">Consultar estado actual</ActionButton></StaggerReveal>
          <form v-else novalidate @submit.prevent="decide">
            <DecisionOptions :value="state.action" :disabled="blocked" @choose="model.edit(state.reason,$event)" />
            <TextField :model-value="state.reason" label="Motivo de la decisión (obligatorio)" multiline :maxlength="500" :disabled="blocked" :invalid="state.failure?.kind==='invalid'" :data-notice="state.notice" @update:model-value="model.edit([...$event].slice(0,500).join(''))" />
            <p class="privacy">Se guardan tu cuenta, el motivo y la fecha. Ocultar no cierra ni elimina el caso; restaurar sigue respetando la visibilidad de la búsqueda vinculada.</p>
            <ActionButton v-if="state.failure?.kind==='conflict'" :working="state.busy" @click="model.refreshDetail()">Consultar estado actual</ActionButton>
            <ActionButton v-else type="submit" variant="primary" :working="state.busy">{{state.frozen&&(!state.busy||state.retrying)?'Reintentar decisión':'Guardar decisión'}}</ActionButton>
          </form>
        </article>
        <article class="moderation-panel"><h2>Últimas decisiones</h2><p v-if="!state.detail.history.length">Sin decisiones anteriores.</p><ol v-else class="moderation-history"><li v-for="item in state.detail.history" :key="item.id"><h3>{{actionLabel(item.action)}}</h3><p class="moderation-text">{{item.reason}}</p><p>{{date(item.decidedAt)}}</p><p class="privacy moderation-reference">Cuenta revisora: {{item.actor}}</p></li></ol><p class="privacy">Se muestran las últimas 20 decisiones. El servidor conserva el historial completo.</p></article>
      </StaggerReveal>
      <ActionButton v-else-if="state.failure" @click="model.refreshDetail()">Reintentar consulta</ActionButton>
    </section>
    <ConfirmationDialog :open="!!confirm" :title="confirm?.title||''" :description="confirm?.description||''" :action="confirm?.action||''" @answer="answer" />
  </OriginPageSurface>
</template>
