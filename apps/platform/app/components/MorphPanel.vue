<script setup lang="ts">
// Port of sader-panel's box morph: top layer, centered FLIP, quartic-out,
// 420ms opening / 300ms closing, 12px content blur and 32px final radius.
const props = withDefaults(defineProps<{ label: string; role?: 'listbox' | 'dialog'; panelWidth?: number; disabled?: boolean; id?: string }>(), { role: 'dialog' });
const anchor = useTemplateRef('anchor'), popover = useTemplateRef('popover'), panel = useTemplateRef('panel'), content = useTemplateRef('content');
const open = ref(false), closing = ref(false);
let frame = 0, observer: ResizeObserver | undefined, disposed = false, generation = 0;
const animations = new Set<Animation>();
const reduced = () => matchMedia('(prefers-reduced-motion: reduce)').matches;
const trigger = () => anchor.value?.querySelector('button');
function stop() { cancelAnimationFrame(frame); for (const a of animations) a.cancel(); animations.clear(); }
function geometry() {
  const button = trigger(), box = panel.value, list = content.value;
  if (!button || !box || !list) return;
  const tr = button.getBoundingClientRect(), viewport = window.visualViewport;
  const vw = viewport?.width ?? innerWidth, vh = viewport?.height ?? innerHeight;
  const ox = viewport?.offsetLeft ?? 0, oy = viewport?.offsetTop ?? 0;
  const width = Math.min(props.panelWidth ?? Math.max(tr.width, 220), vw - 16);
  const scroll = list.scrollTop;
  box.style.width = `${width}px`; box.style.height = 'auto';
  const height = Math.min(Math.ceil(list.scrollHeight) + 2, 560, vh - 16);
  list.scrollTop = scroll;
  return { tr, width, height, left: Math.max(ox + 8, Math.min(tr.left, ox + vw - width - 8)), top: Math.max(oy + 8, Math.min(tr.top + tr.height / 2 - height / 2, oy + vh - height - 8)), radius: Math.min(parseFloat(getComputedStyle(button).borderTopLeftRadius) || 8, tr.height / 2, tr.width / 2) };
}
function place(g: NonNullable<ReturnType<typeof geometry>>) {
  Object.assign(panel.value!.style, { left: `${g.left}px`, top: `${g.top}px`, width: `${g.width}px`, height: `${g.height}px` });
}
function animate(el: HTMLElement, keyframes: Keyframe[], duration: number, delay = 0, power = 4) {
  // Samples GSAP power3.out (1-(1-p)^4), rather than substituting a CSS ease.
  const easing = `linear(${Array.from({ length: 101 }, (_, i) => 1 - (1 - i / 100) ** power).join(',')})`;
  const a = el.animate(keyframes, { duration, delay, easing, fill: 'both' });
  animations.add(a); a.finished.catch(() => {});
  return a;
}
async function show() {
  if (props.disabled || open.value || disposed) return;
  const current = ++generation;
  open.value = true; await nextTick();
  if (disposed || current !== generation || !popover.value) return;
  popover.value.showPopover();
  const g = geometry(); if (!g) { dismiss(); return; }
  place(g);
  if (!reduced()) {
    const x = g.tr.left + g.tr.width / 2 - g.left - g.width / 2;
    const y = g.tr.top + g.tr.height / 2 - g.top - g.height / 2;
    animate(panel.value!, [
      { transform: `translate(${x}px,${y}px) scale(${g.tr.width / g.width},${g.tr.height / g.height})`, borderRadius: `${g.radius}px`, opacity: 1 },
      { transform: 'translate(0,0) scale(1,1)', borderRadius: '32px', opacity: 1 },
    ], 420);
    animate(content.value!, [{ opacity: 0, filter: 'blur(12px)' }, { opacity: 1, filter: 'blur(0px)' }], 300, 60, 3);
  }
  await nextTick();
  if (disposed || current !== generation) return;
  (content.value?.querySelector<HTMLElement>('input, [aria-pressed=true], [tabindex="0"]') ?? panel.value)?.focus({ preventScroll: true });
  content.value?.querySelector('[aria-selected=true]')?.scrollIntoView({ block: 'nearest' });
  for (const column of content.value?.querySelectorAll<HTMLElement>('.sader-time-scroll') ?? []) {
    const selected = column.querySelector<HTMLElement>('[aria-pressed=true]');
    if (selected) column.scrollTop = Math.max(0, selected.offsetTop - column.offsetTop - (column.clientHeight - selected.offsetHeight) / 2);
  }
  observer = new ResizeObserver(reflow);
  if (content.value?.firstElementChild) observer.observe(content.value.firstElementChild);
}
function dismiss(restore = true) {
  ++generation; stop(); observer?.disconnect(); observer = undefined;
  popover.value?.hidePopover(); open.value = false; closing.value = false;
  if (restore && !disposed) trigger()?.focus({ preventScroll: true });
}
async function close(restore = true) {
  if (!open.value || closing.value) return;
  closing.value = true;
  if (reduced() || !panel.value || !content.value) { dismiss(restore); return; }
  const box = panel.value, list = content.value, rect = box.getBoundingClientRect(), button = trigger();
  if (!button) { dismiss(false); return; }
  const tr = button.getBoundingClientRect(), radius = Math.min(parseFloat(getComputedStyle(button).borderTopLeftRadius) || 8, tr.height / 2);
  stop(); observer?.disconnect();
  Object.assign(box.style, { left: `${rect.left}px`, top: `${rect.top}px`, width: `${rect.width}px`, height: `${rect.height}px` });
  Object.assign(list.style, { position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%,-50%)', width: `${rect.width}px`, height: `${rect.height}px` });
  const a = animate(box, [
    { left: `${rect.left}px`, top: `${rect.top}px`, width: `${rect.width}px`, height: `${rect.height}px`, borderRadius: '32px' },
    { left: `${tr.left}px`, top: `${tr.top}px`, width: `${tr.width}px`, height: `${tr.height}px`, borderRadius: `${radius}px` },
  ], 300);
  animate(box, [{ opacity: 1 }, { opacity: 0 }], 160, 120, 3);
  animate(list, [{ filter: 'blur(0px)' }, { filter: 'blur(12px)' }], 240, 0, 3);
  try { await a.finished; } catch { return; }
  if (!disposed) dismiss(restore && !!anchor.value?.contains(document.activeElement));
}
function reflow() {
  if (!open.value || closing.value) return;
  cancelAnimationFrame(frame); frame = requestAnimationFrame(() => {
    if ([...animations].some(a => a.playState === 'running')) return;
    const old = panel.value?.getBoundingClientRect(); stop();
    const g = geometry(); if (!g || !old) return;
    place(g);
    if (!reduced() && Math.abs(old.height - g.height) > 2) animate(panel.value!, [{ height: `${old.height}px`, top: `${old.top}px` }, { height: `${g.height}px`, top: `${g.top}px` }], 350);
  });
}
function outside(event: Event) {
  if (open.value && !anchor.value?.contains(event.target as Node) && !popover.value?.contains(event.target as Node)) void close(false);
}
function key(event: KeyboardEvent) {
  if (event.key === 'Escape') { event.preventDefault(); event.stopPropagation(); void close(); }
}
watch(() => props.disabled, value => { if (value && open.value) dismiss(false); });
onMounted(() => {
  document.addEventListener('pointerdown', outside, true); document.addEventListener('focusin', outside);
  window.addEventListener('resize', reflow); window.addEventListener('scroll', reflow, true);
  window.visualViewport?.addEventListener('resize', reflow);
});
onBeforeUnmount(() => {
  disposed = true; dismiss(false);
  document.removeEventListener('pointerdown', outside, true); document.removeEventListener('focusin', outside);
  window.removeEventListener('resize', reflow); window.removeEventListener('scroll', reflow, true);
  window.visualViewport?.removeEventListener('resize', reflow);
});
defineExpose({ close, open });
</script>
<template>
  <div ref="anchor" class="sader-popover-anchor">
    <slot name="trigger" :open="open" :toggle="() => open ? close() : show()" />
    <div ref="popover" popover="manual" class="sader-popover-layer" @keydown="key">
      <div v-if="open" :id="id" ref="panel" class="sader-morph-panel" :role="role" :aria-label="label" tabindex="-1">
        <div ref="content" class="sader-morph-content"><slot :close="close" /></div>
      </div>
    </div>
  </div>
</template>
