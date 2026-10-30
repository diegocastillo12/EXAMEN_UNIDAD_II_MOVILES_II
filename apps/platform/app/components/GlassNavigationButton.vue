<script setup lang="ts">
withDefaults(defineProps<{label:string;disabled?:boolean;close?:boolean}>(),{disabled:false,close:false});
const emit=defineEmits<{navigate:[]}>();
</script>
<template><button class="glass glass-navigation" type="button" :disabled="disabled" :title="label" :aria-label="label" @click="emit('navigate')"><svg v-if="close" class="app-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18" /></svg><AppIcon v-else name="chevron-left" /></button></template>
<style>
.reader-shell .glass-navigation{position:fixed;top:max(16px,env(safe-area-inset-top));left:max(16px,env(safe-area-inset-left));z-index:5;display:grid;place-items:center;padding:0;font-size:0;line-height:0;color:#111111;border:1px solid #ffffffb3;background:linear-gradient(135deg,#ffffff99 0%,#f5f5f733 35%,#ffffff18 65%,#e5e5ea42 100%);backdrop-filter:blur(22px);box-shadow:inset 0 0 0 1px #ffffff50,inset 0 -1px 1px #24282a12,0 6px 16px #11111114,0 1px 3px #1111110a}
.reader-shell .glass-navigation .app-icon{display:block;width:28px;height:28px;pointer-events:none}
</style>
