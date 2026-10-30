<script setup lang="ts">
withDefaults(defineProps<{
  intensity?: 'soft' | 'medium' | 'strong';
}>(), { intensity: 'medium' });
</script>

<template>
  <div class="background-glow" :class="'background-glow--' + intensity" aria-hidden="true">
    <div class="background-glow__viewport">
      <div class="background-glow__light background-glow__halo" />
      <div class="background-glow__light background-glow__primary" />
      <div class="background-glow__light background-glow__secondary" />
      <div class="background-glow__grain" />
    </div>
  </div>
</template>

<style scoped>
/* Parent supplies position: relative and content stacking. Override the
   --glow-color / --glow-secondary CSS tokens in the consuming stylesheet. */
.background-glow {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: clip;
}
.background-glow--soft { --glow-intensity: 0.42; }
.background-glow--medium { --glow-intensity: 0.5; }
.background-glow--strong { --glow-intensity: 0.62; }
.background-glow__viewport {
  position: sticky;
  top: 0;
  height: 100svh;
  overflow: hidden;
  opacity: var(--glow-intensity);
  animation: glow-appear 1.3s ease-out 300ms both;
}
.background-glow__light {
  position: absolute;
  top: 45%;
  left: 50%;
  border-radius: 50%;
  background: var(--glow-color, #9bc6f5);
  transform: translate(-50%, -50%);
}
.background-glow__halo {
  width: clamp(400px, 65vw, 900px);
  aspect-ratio: 1;
  filter: blur(110px);
  opacity: 0.5;
  animation: glow-halo 16s ease-in-out infinite;
}
.background-glow__primary {
  width: clamp(240px, 35vw, 480px);
  aspect-ratio: 1;
  filter: blur(80px);
  animation: glow-drift 17s ease-in-out infinite;
}
.background-glow__secondary {
  width: clamp(200px, 28vw, 380px);
  aspect-ratio: 1;
  background: var(--glow-secondary, #d6e8ff);
  filter: blur(80px);
  opacity: 0.85;
  animation: glow-drift-secondary 11s ease-in-out infinite;
}
.background-glow__grain {
  position: absolute;
  inset: 0;
  background: url('/images/glow-grain.svg') repeat;
  mix-blend-mode: overlay;
  opacity: 0.12;
  mask-image: radial-gradient(circle at center, transparent 30%, #000 70%);
}
@keyframes glow-appear {
  from { opacity: 0; }
  to { opacity: var(--glow-intensity); }
}
@keyframes glow-drift {
  0%, 100% { transform: translate(-50%, -50%) translate(0, 0) scale(1.06); }
  25% { transform: translate(-50%, -50%) translate(-12vw, -8vh) scale(1); }
  50% { transform: translate(-50%, -50%) translate(6vw, 9vh) scale(1.14); }
  75% { transform: translate(-50%, -50%) translate(11vw, -6vh) scale(1.02); }
}
@keyframes glow-drift-secondary {
  0%, 100% { transform: translate(-50%, -50%) translate(0, 0) scale(1.08); }
  25% { transform: translate(-50%, -50%) translate(11vw, 9vh) scale(0.95); }
  50% { transform: translate(-50%, -50%) translate(-10vw, -7vh) scale(1.12); }
  75% { transform: translate(-50%, -50%) translate(-12vw, 8vh) scale(0.98); }
}
@keyframes glow-halo {
  0%, 100% { transform: translate(-50%, -50%) scale(1.05); }
  50% { transform: translate(-50%, -50%) translate(5vw, 6vh) scale(1.14); }
}
@media (prefers-reduced-motion: reduce) {
  .background-glow__viewport,
  .background-glow__light { animation: none; }
}
</style>
