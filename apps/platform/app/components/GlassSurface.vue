<script setup lang="ts">
withDefaults(defineProps<{ as?: 'div' | 'section' | 'article' | 'button' }>(), { as:'div' });
</script>
<template><component :is="as" class="glass-surface"><slot /></component></template>
<style>
.reader-shell .glass-surface{border:1px solid #ffffffb3;background:linear-gradient(135deg,#ffffff99 0%,#f5f5f733 35%,#ffffff18 65%,#e5e5ea42 100%);backdrop-filter:blur(22px);box-shadow:inset 0 0 0 1px #ffffff50,inset 0 -1px 1px #24282a12,0 8px 24px #24282a24,0 1px 3px #24282a0f;border-radius:26px}
</style>
