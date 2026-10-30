<script setup lang="ts">
const route = useRoute(),motion = useNuxtApp().$originTransition;
const sections = ['/inicio','/explorar','/mis-mascotas'];
const selected = ref(Math.max(0,sections.indexOf(route.path)));
const engaged = ref<number|null>(null);
const capsule = useTemplateRef('capsule');
let frame = 0;
let gesture: { id:number; x:number; y:number } | undefined;
let dragged = false;
let reducedMotion: MediaQueryList | undefined;
const selectionSurface = () => capsule.value?.querySelector<HTMLElement>('.user-navigation-indicator span');
function resetElastic() {
  selectionSurface()?.style.removeProperty('translate');
  gesture = undefined;
}
function startPush(event: PointerEvent) {
  if (!event.isPrimary || event.button !== 0) return;
  resetElastic();
  dragged = false;
  gesture = { id:event.pointerId,x:event.clientX,y:event.clientY };
}
function dragPush(event: PointerEvent) {
  if (!gesture || gesture.id !== event.pointerId) return;
  const dx = event.clientX-gesture.x,dy = event.clientY-gesture.y;
  if (!dragged && Math.abs(dy) > Math.abs(dx)) { resetElastic();return; }
  if (Math.abs(dx) > 10) dragged = true;
  if (!dragged || reducedMotion?.matches) return;
  const surface = selectionSurface();
  if (surface) surface.style.translate = `${Math.max(-8,Math.min(8,dx*.18))}px`;
}
function finishPush() { resetElastic();engaged.value = null; }
function preventDragNavigation(event: MouseEvent) {
  if (dragged && event.detail !== 0) { event.preventDefault();event.stopPropagation();dragged = false; }
}
onMounted(() => {
  // Custom links keep real anchors; prepare only code, never private payloads.
  for (const path of [...sections,'/reportar']) void preloadRouteComponents(path, useRouter()).catch(() => {});
  reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
  reducedMotion.addEventListener('change',resetElastic);
  window.addEventListener('pointerup',finishPush);
  window.addEventListener('pointercancel',finishPush);
});
function settleColors() { capsule.value?.querySelectorAll<HTMLElement>('.user-navigation-item').forEach(item => { item.style.removeProperty('color'); }); }
function trackColors() {
  const indicator = capsule.value?.querySelector<HTMLElement>('.user-navigation-indicator');
  if (!indicator) return;
  const width = indicator.getBoundingClientRect().width;
  const position = width ? Math.abs(new DOMMatrixReadOnly(getComputedStyle(indicator).transform).m41) / width : selected.value;
  capsule.value?.querySelectorAll<HTMLElement>('.user-navigation-item').forEach((item,index) => {
    const strength = Math.max(0,1-Math.abs(position-index));
    item.style.color = `rgb(${[110,110,115].map(channel => Math.round(channel+(255-channel)*strength)).join(',')})`;
  });
  if (indicator.getAnimations().some(a => a.playState === 'running')) frame = requestAnimationFrame(trackColors);
}
watch(selected,() => { cancelAnimationFrame(frame);frame = requestAnimationFrame(trackColors); },{flush:'post'});
onBeforeUnmount(() => {
  cancelAnimationFrame(frame);
  resetElastic();
  reducedMotion?.removeEventListener('change',resetElastic);
  window.removeEventListener('pointerup',finishPush);
  window.removeEventListener('pointercancel',finishPush);
});
watch(() => route.path,path => { resetElastic();const index = sections.indexOf(path); if (index >= 0) selected.value = index; });
</script>

<template>
  <nav class="user-navigation" aria-label="Navegación de usuario">
    <div ref="capsule" class="user-navigation-capsule" :data-section="selected" :class="{ 'user-navigation-engaged':engaged === selected }" :aria-busy="motion.busy.value" @pointerdown="startPush" @pointermove="dragPush" @pointerleave="finishPush" @click.capture="preventDragNavigation" @dragstart.prevent>
      <div class="user-navigation-indicator" aria-hidden="true" @transitionend="settleColors" @transitioncancel="settleColors"><span /></div>
      <NavigationLink to="/inicio" class="user-navigation-item" aria-label="Inicio" @pointerenter="engaged = 0" @focus="engaged = 0" @blur="engaged = null" @pointerdown="engaged = 0" @pointerup="engaged = null" @pointercancel="engaged = null">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="m3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1Z" stroke-linejoin="round" /></svg>
      </NavigationLink>
      <NavigationLink to="/explorar" class="user-navigation-item" aria-label="Explorar" @pointerenter="engaged = 1" @focus="engaged = 1" @blur="engaged = null" @pointerdown="engaged = 1" @pointerup="engaged = null" @pointercancel="engaged = null">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><circle cx="12" cy="12" r="9" /><path d="m16 8-3 5-5 3 3-5Z" stroke-linejoin="round" /></svg>
      </NavigationLink>
      <NavigationLink to="/mis-mascotas" class="user-navigation-item" aria-label="Mis mascotas" @pointerenter="engaged = 2" @focus="engaged = 2" @blur="engaged = null" @pointerdown="engaged = 2" @pointerup="engaged = null" @pointercancel="engaged = null">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><ellipse cx="6" cy="8" rx="2" ry="3" transform="rotate(-25 6 8)" /><ellipse cx="18" cy="8" rx="2" ry="3" transform="rotate(25 18 8)" /><ellipse cx="10" cy="5" rx="1.5" ry="2.5" /><ellipse cx="14" cy="5" rx="1.5" ry="2.5" /><path d="M12 12c-3 0-7 5-5 7 1 2 3 0 5 0s4 2 5 0c2-2-2-7-5-7Z" /></svg>
      </NavigationLink>
    </div>
    <NavigationLink to="/reportar" origin class="user-navigation-report" aria-label="Reportar">
      <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><circle v-for="n in 9" :key="n" :cx="4 + ((n - 1) % 3) * 8" :cy="4 + Math.floor((n - 1) / 3) * 8" r="2.2" /></svg>
    </NavigationLink>
  </nav>
</template>

<style scoped>
.user-navigation{position:fixed;z-index:10;inset-inline:16px;bottom:calc(16px + env(safe-area-inset-bottom,0px));width:min(304px,calc(100% - 32px));margin-inline:auto;display:flex;align-items:center;gap:12px}
.user-navigation-capsule{position:relative;display:flex;flex:1;min-width:0;padding:6px;border:1px solid #ffffffb3;border-radius:999px;background:#ffffffeb;box-shadow:inset 0 0 0 1px #ffffff50,inset 0 -1px 1px #24282a12,0 8px 24px #24282a24,0 1px 3px #1111110f;touch-action:pan-y;user-select:none}
.user-navigation-indicator{position:absolute;inset-block-start:6px;inset-inline-start:6px;width:calc((100% - 12px) / 3);height:52px;pointer-events:none;transition:transform 320ms cubic-bezier(.645,.045,.355,1)}
.user-navigation-indicator span{display:block;width:100%;height:100%;border-radius:999px;background:linear-gradient(180deg,#75bfff 0%,#459ff6 48%,#2887ef 100%);box-shadow:inset 0 1px 2px #ffffff80,0 7px 20px #2887ef40,0 2px 5px #2887ef1a;transition:filter 200ms ease,translate 480ms cubic-bezier(.22,1.4,.36,1)}
.user-navigation-capsule[data-section="1"] .user-navigation-indicator{transform:translateX(100%)}
.user-navigation-capsule[data-section="2"] .user-navigation-indicator{transform:translateX(200%)}
:dir(rtl) .user-navigation-capsule[data-section="1"] .user-navigation-indicator{transform:translateX(-100%)}
:dir(rtl) .user-navigation-capsule[data-section="2"] .user-navigation-indicator{transform:translateX(-200%)}
.user-navigation-engaged .user-navigation-indicator span{filter:brightness(.97)}
.user-navigation-item{position:relative;display:grid;place-items:center;flex:1;min-width:0;height:52px;border-radius:999px;text-decoration:none;color:#6e6e73}
.user-navigation-capsule[data-section="0"] .user-navigation-item:nth-of-type(1),.user-navigation-capsule[data-section="1"] .user-navigation-item:nth-of-type(2),.user-navigation-capsule[data-section="2"] .user-navigation-item:nth-of-type(3){color:#fff}
.user-navigation svg{display:block;width:24px;height:24px;flex-shrink:0}
.user-navigation-report{display:grid;place-items:center;flex-shrink:0;width:64px;height:64px;border-radius:50%;background:#111;color:#fff;text-decoration:none}
@supports(backdrop-filter:blur(16px)){.user-navigation-capsule{background:linear-gradient(135deg,#ffffff99 0%,#f5f5f733 35%,#ffffff18 65%,#e5e5ea42 100%);backdrop-filter:blur(22px)}}
@media(hover:hover) and (pointer:fine){.user-navigation-report:hover{filter:brightness(1.15)}}
@media(max-width:360px){.user-navigation{gap:8px}.user-navigation-report{width:56px;height:56px}}
@media(prefers-reduced-motion:reduce){.user-navigation-item,.user-navigation-indicator,.user-navigation-indicator span{transition:none}}
</style>
