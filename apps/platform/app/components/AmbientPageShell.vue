<script setup lang="ts">
withDefaults(defineProps<{ intensity?: 'soft' | 'medium' | 'strong' }>(), { intensity: 'soft' });
</script>
<template>
  <WebShell minimal class="ambient-page-shell">
    <BackgroundGlowOrb :intensity="intensity" />
    <slot />
  </WebShell>
</template>
<style scoped>
.ambient-page-shell {
  --glow-color: #83b4ee;
  --glow-secondary: #c8e0ff;
  display: flex;
  align-items: center;
  min-height: 100svh;
  position: relative;
  isolation: isolate;
}
.ambient-page-shell :deep(.background-glow) { z-index: -1; mask-image: linear-gradient(#000 0% 72%, transparent 100%); }
</style>
