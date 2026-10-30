<script setup lang="ts">
import { useStaggerReveal, vStaggerReveal } from '~/composables/useStaggerReveal';
import '../styles/onboarding.css';
const props = defineProps<{ step: number; busy: boolean; onNext: () => Promise<void> }>();
const steps = [
  { title: 'Cada huella\nimporta', text: 'Encuentra, ayuda y cuida\na las mascotas cerca de ti.', image: 'dog_waving.png' },
  { title: 'Volvamos\na casa', text: 'Con tu ayuda, más mascotas\npueden reencontrarse\ncon su familia.', image: 'dog_with_map.png' },
  { title: 'Una nueva\nhistoria', text: 'Pequeñas acciones generan\ngrandes finales.', image: 'dog_and_cat.png' },
] as const;
const current = computed(() => steps[props.step]!);
const show = ref(true), transitioning = ref(false), pressed = ref(false);
const heading = useTemplateRef('heading');
const reduced = ref(false);
const { revealStyle, exitMs } = useStaggerReveal({
  active: show, count: 4, reveal: 'bottom', revealOrder: 'top',
  cover: 'bottom', coverOrder: 'bottom', offset: 56, duration: 550,
});
let alive = true, timer: ReturnType<typeof setTimeout> | undefined;
let settle: ((active: boolean) => void) | undefined;
let media: MediaQueryList | undefined;
function waitMotion(ms: number) {
  if (!alive || reduced.value) return Promise.resolve(alive);
  return new Promise<boolean>(resolve => {
    settle = resolve;
    timer = setTimeout(() => { settle = undefined; timer = undefined; resolve(alive); }, ms);
  });
}
function motionChanged() {
  reduced.value = media?.matches ?? false;
  if (reduced.value) { clearTimeout(timer); timer = undefined; const resolve = settle; settle = undefined; resolve?.(alive); }
}
async function finish() {
  transitioning.value = true; show.value = false;
  await nextTick();
  return waitMotion(exitMs);
}
async function advance() {
  if (transitioning.value || props.busy || !alive) return;
  transitioning.value = true;
  pressed.value = true;
  // Same full press cycle as sader's afterPress (200ms down + 200ms up).
  if (!await waitMotion(400)) return;
  pressed.value = false;
  if (props.step === 2) {
    // Keep the actual save/shimmer visible; the parent requests exit after confirmation.
    await props.onNext();
    if (alive && show.value) transitioning.value = false;
    return;
  }
  show.value = false;
  await nextTick();
  if (!await waitMotion(exitMs)) return;
  await props.onNext();
  if (!alive) return;
  await nextTick();
  show.value = true;
  await nextTick();
  heading.value?.focus({ preventScroll: true });
  // A transition owns both exit and entry; repeated clicks cannot skip a step.
  if (await waitMotion(exitMs)) transitioning.value = false;
}
onMounted(() => {
  media = window.matchMedia('(prefers-reduced-motion: reduce)');
  motionChanged(); media.addEventListener('change', motionChanged);
});
onBeforeUnmount(() => {
  alive = false; clearTimeout(timer); const resolve = settle; settle = undefined; resolve?.(false);
  media?.removeEventListener('change', motionChanged);
});
defineExpose({ finish });
</script>
<template>
  <div class="onboarding-content">
  <section class="onboarding-flow" aria-label="Bienvenida a Entre Huellas" :aria-busy="busy">
    <div class="onboarding-illustration stagger-reveal-item" v-stagger-reveal="revealStyle(0)">
      <img :src="'/images/onboarding/' + current.image" width="1254" height="1254" alt="" decoding="async" />
    </div>
    <h1 ref="heading" tabindex="-1" class="onboarding-step-title stagger-reveal-item" v-stagger-reveal="revealStyle(1)">{{ current.title }}</h1>
    <p class="onboarding-step-description stagger-reveal-item" v-stagger-reveal="revealStyle(2)">{{ current.text }}</p>
    <div class="onboarding-step-actions stagger-reveal-item" v-stagger-reveal="revealStyle(3)">
        <ActionButton variant="primary" class="onboarding-button onboarding-next" :class="{ 'onboarding-pressed': pressed }" :working="busy" :disabled="transitioning" @click="advance()"><span>{{ step === 2 ? 'Comenzar' : 'Continuar' }}</span><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14m-6-6 6 6-6 6" /></svg></ActionButton>
    </div>
    <span class="onboarding-progress" role="status" :aria-label="'Paso ' + (step + 1) + ' de 3'" />
  </section>
  </div>
</template>

