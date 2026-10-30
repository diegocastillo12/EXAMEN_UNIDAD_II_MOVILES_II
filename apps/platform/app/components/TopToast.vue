<script setup lang="ts">
import type { ObjectDirective } from 'vue';
// Long notices keep native vertical scrolling; the icon remains a drag handle.
function updateTouchAction(element: HTMLElement) {
  element.style.touchAction = element.scrollHeight > element.clientHeight ? 'pan-y' : 'pan-x';
}
const vToastScroll: ObjectDirective<HTMLElement> = { mounted: updateTouchAction, updated: updateTouchAction };
const message = ref(''); const visible = ref(false); const danger = ref(true);
const noticeId = ref(0);
const retry = shallowRef<(() => void) | null>(null);
let timer: ReturnType<typeof setTimeout> | undefined;
const dragging = ref(false);
let gesture: { id: number; x: number; y: number; time: number; element: HTMLElement; moved: boolean } | null = null;
let suppressClick = false;
function resetGesture() {
  if (gesture) {
    if (gesture.element.hasPointerCapture(gesture.id)) gesture.element.releasePointerCapture(gesture.id);
    gesture.element.style.removeProperty('--toast-drag');
  }
  gesture = null;
  dragging.value = false;
}
function close() { visible.value = false; clearTimeout(timer); resetGesture(); }
function scheduleClose() { clearTimeout(timer); timer = setTimeout(close, 6500); }
function show(text: string, action: (() => void) | null = null, error = true) {
  close(); suppressClick = false; message.value = text; retry.value = action; danger.value = error; noticeId.value++; visible.value = true;
  scheduleClose();
}
function pointerDown(event: PointerEvent) {
  if (!event.isPrimary || event.button !== 0 || gesture) return;
  const element = event.currentTarget as HTMLElement;
  if (event.pointerType === 'touch' && element.scrollHeight > element.clientHeight && !(event.target as HTMLElement).closest('.notice-icon')) return;
  suppressClick = false;
  clearTimeout(timer);
  gesture = { id: event.pointerId, x: event.clientX, y: event.clientY, time: event.timeStamp, element: event.currentTarget as HTMLElement, moved: false };
}
function pointerMove(event: PointerEvent) {
  if (!gesture || gesture.id !== event.pointerId) return;
  const dy = event.clientY - gesture.y;
  const dx = event.clientX - gesture.x;
  if (!gesture.moved && Math.hypot(dx, dy) < 8) return;
  suppressClick = true;
  if (!gesture.moved && Math.abs(dx) > Math.abs(dy)) return;
  gesture.moved = true;
  dragging.value = true;
  gesture.element.setPointerCapture(event.pointerId);
  gesture.element.style.setProperty('--toast-drag', `${dy < 0 ? dy : Math.min(18, dy * .15)}px`);
}
function pointerEnd(event: PointerEvent, cancelled = false) {
  if (!gesture || gesture.id !== event.pointerId) return;
  const up = gesture.y - event.clientY;
  const velocity = up / Math.max(1, event.timeStamp - gesture.time);
  const dismiss = !cancelled && gesture.moved && (up >= 40 || (up >= 12 && velocity > .45));
  if (dismiss) {
    // Keep the current offset until Vue starts the exit, avoiding a jump on release.
    visible.value = false;
    if (gesture.element.hasPointerCapture(gesture.id)) gesture.element.releasePointerCapture(gesture.id);
    gesture = null;
    dragging.value = false;
  } else {
    resetGesture();
    scheduleClose();
  }
}
function captureClick(event: MouseEvent) {
  if (!suppressClick || event.detail === 0) return;
  event.preventDefault(); event.stopPropagation(); suppressClick = false;
}
function retryAndClose() { const action = retry.value; close(); action?.(); }
onBeforeUnmount(close); defineExpose({ show, close });
</script>
<template>
  <Transition name="toast" mode="out-in">
  <aside v-if="visible" v-toast-scroll id="notice" :key="noticeId" class="notice" :class="{ 'notice-danger': danger, 'notice-dragging': dragging }" :role="danger ? 'alert' : 'status'" @click.capture="captureClick" @click="close" @keydown.esc="close" @pointerdown="pointerDown" @pointermove="pointerMove" @pointerup="pointerEnd($event)" @pointercancel="pointerEnd($event, true)" @lostpointercapture="pointerEnd($event, true)">
    <span class="notice-icon"><AppIcon :name="danger ? 'error-outline' : 'check'" /></span>
    <div class="notice-content">
      <button id="notice-close" type="button" aria-label="Cerrar aviso" @click.stop="close"><span id="notice-message">{{ message }}</span></button>
      <button v-if="retry" id="notice-retry" type="button" @click.stop="retryAndClose">Reintentar</button>
    </div>
  </aside>
  </Transition>
</template>
<style>
.reader-shell .notice{
  position:fixed;z-index:10;top:calc(env(safe-area-inset-top,0px) + 12px);left:50%;
  transform:translate(-50%,var(--toast-drag,0px));width:max-content;max-width:min(360px,calc(100vw - 48px));
  max-height:clamp(48px,30svh,220px);overflow:auto;overscroll-behavior:contain;
  display:flex;align-items:flex-start;gap:10px;min-height:48px;margin:0;padding:8px 16px;
  border-radius:28px;border:1px solid #ffffffb3;background:#f5f5f7e6;color:#111111;
  backdrop-filter:blur(18px);box-shadow:0 6px 20px #24282a1a;cursor:grab;
  touch-action:pan-x;user-select:none;
  transition:transform 420ms cubic-bezier(.22,1,.36,1);
}
.reader-shell .notice.notice-dragging{transition:none;cursor:grabbing}
.reader-shell .notice.toast-enter-active{transition:transform 480ms cubic-bezier(.16,1,.3,1)}
.reader-shell .notice.toast-leave-active{transition:transform 240ms cubic-bezier(.4,0,1,1);pointer-events:none}
.reader-shell .notice.toast-enter-from,.reader-shell .notice.toast-leave-to{
  transform:translate(-50%,calc(-100% - env(safe-area-inset-top,0px) - 24px));
}
.reader-shell .notice-icon{
  touch-action:none;
  display:grid;place-items:center;flex:0 0 32px;width:32px;height:32px;
  border-radius:50%;background:#24282a0d;color:#111111;
}
.reader-shell .notice-danger .notice-icon{color:#b53f48}
.reader-shell .notice-icon .app-icon{width:20px;height:20px;display:block}
.reader-shell .notice-content{min-width:0;flex:1}
.reader-shell .notice button{
  display:block;min-width:0;min-height:32px;width:100%;padding:0;border:0;
  border-radius:12px;background:transparent;color:#111111;text-align:left;
  font-family:inherit;font-size:.875rem;font-weight:400;line-height:1.4;overflow-wrap:anywhere;
}
.reader-shell .notice #notice-retry{min-height:44px;width:auto;padding:8px 0;text-decoration:underline;text-underline-offset:3px}
</style>
