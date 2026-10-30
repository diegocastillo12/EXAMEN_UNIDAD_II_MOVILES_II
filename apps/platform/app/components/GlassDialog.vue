<script setup lang="ts">
import {playOriginDialog} from '~/utils/origin_dialog_motion';
const props = withDefaults(defineProps<{ open:boolean; title:string; origin?:HTMLElement|null; sourceIcon?:boolean }>(),{sourceIcon:true});
const emit = defineEmits<{ close:[] }>();
const dialog = useTemplateRef('dialog');
const content=useTemplateRef('content'),identity=useTemplateRef('identity');
const rendered=ref(false),animating=ref(false);
let generation=0,stop:(()=>void)|undefined;
let preference:MediaQueryList|undefined;
let previousOverflow: string | undefined;
function unlock() { if (previousOverflow !== undefined) { document.body.style.overflow=previousOverflow;previousOverflow=undefined; } }
function cancelMotion(){stop?.();stop=undefined;animating.value=false;}
async function transition(reverse:boolean){
  const node=dialog.value,body=content.value,icon=identity.value;
  if(!node||!body||!icon)return;
  cancelMotion();animating.value=true;body.inert=true;
  const player=playOriginDialog(node,body,icon,props.origin,reverse,props.sourceIcon);
  stop=player.cancel;await player.finished;
  if(stop===player.cancel){cancelMotion();body.inert=false;}
}
watch(() => props.open,async open => {
  const current=++generation;cancelMotion();
  if(open)rendered.value=true;
  await nextTick();
  if(current!==generation)return;
  if (open && props.open && dialog.value) {
    if(!dialog.value.open){previousOverflow=document.body.style.overflow;document.body.style.overflow='hidden';dialog.value.showModal();}
    await transition(false);
    if(current===generation)content.value?.querySelector<HTMLElement>('button,a,input,[tabindex="0"]')?.focus({preventScroll:true});
  } else if (!props.open) {
    if(dialog.value?.open)await transition(true);
    if(current===generation){dialog.value?.close();rendered.value=false;unlock();}
  }
},{immediate:true});
function finishInterrupted(){cancelMotion();if(content.value)content.value.inert=false;}
onMounted(()=>{window.addEventListener('resize',finishInterrupted);window.visualViewport?.addEventListener('resize',finishInterrupted);preference=matchMedia('(prefers-reduced-motion: reduce)');preference.addEventListener('change',finishInterrupted);});
onBeforeUnmount(() => {generation++;cancelMotion();window.removeEventListener('resize',finishInterrupted);window.visualViewport?.removeEventListener('resize',finishInterrupted);preference?.removeEventListener('change',finishInterrupted);dialog.value?.close();unlock();});
</script>
<template>
  <dialog ref="dialog" class="glass-dialog glass-surface" :aria-label="title" @cancel.prevent="emit('close')" @click="event => { if (event.target === dialog) { const box=dialog?.getBoundingClientRect(); if (box && (event.clientX<box.left || event.clientX>box.right || event.clientY<box.top || event.clientY>box.bottom)) emit('close'); } }">
    <div ref="content" class="glass-dialog-content" :aria-busy="animating">
      <header class="glass-dialog-header"><h2>{{ title }}</h2><GlassNavigationButton close :label="'Cerrar ' + title.toLowerCase()" @navigate="emit('close')" /></header>
      <div class="glass-dialog-body"><slot v-if="rendered" /></div>
    </div>
    <div ref="identity" class="glass-dialog-origin" aria-hidden="true" inert />
  </dialog>
</template>
<style>
.reader-shell .glass-dialog{position:fixed;width:min(560px,calc(100% - 32px));max-width:none;max-height:calc(100svh - 32px);padding:0;color:#171918;overflow:auto;border-radius:32px;background:linear-gradient(135deg,#fffffff2,#edf4ffeb 60%,#e5e5eae8);box-shadow:inset 0 0 0 1px #ffffff80,0 24px 80px #24282a30}
.reader-shell .glass-dialog::backdrop{background:#24334638;backdrop-filter:blur(8px)}
.reader-shell .glass-dialog-content{min-width:0}
.reader-shell .glass-dialog-origin{position:absolute;inset:0;display:grid;place-items:center;pointer-events:none}
.reader-shell .glass-dialog-origin :is(svg,img){width:24px;height:24px;display:block;color:#6e6e73}
.reader-shell .glass-dialog-header{display:flex;align-items:flex-start;justify-content:space-between;gap:16px;padding:24px 24px 16px}
.reader-shell .glass-dialog-header h2{font-family:var(--primary-title-family);font-size:var(--primary-title-size);font-weight:400;line-height:1.25;letter-spacing:0;color:var(--primary-title-color);margin:4px 0 0;overflow-wrap:anywhere;min-width:0}
.reader-shell .glass-dialog-header .glass-navigation{position:static;width:48px;height:48px;flex-shrink:0}
.reader-shell .glass-dialog-body{padding:0 24px 24px}
@media(max-width:360px){.reader-shell .glass-dialog-header{padding:20px 16px 16px;gap:8px}.reader-shell .glass-dialog-body{padding-inline:16px}}
</style>
