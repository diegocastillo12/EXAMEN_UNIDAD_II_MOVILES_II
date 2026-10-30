<script setup lang="ts">
const motion = useNuxtApp().$originTransition;
// Capture this page's identity; Nuxt's reactive route can update before the old
// page unmounts. It must never hide/reveal the wrong page during that interval.
const path = useRoute().path;
</script>
<template>
  <main class="origin-page-surface" data-origin-content :data-origin-page="path" :class="{'origin-content-pending':motion.pending.value === path}" :inert="motion.pending.value === path">
    <div class="origin-page-body"><slot /></div>
  </main>
</template>
<style>
.origin-page-surface.origin-content-pending{visibility:hidden}
/* Copied from Sader globals.css: PrettyModal's fade/blur accompanies Flip.
   The outgoing route remains visible underneath throughout this phase. */
.origin-page-surface.pretty-modal-opening > .origin-page-body{animation:pretty-modal-opening 500ms cubic-bezier(0.56,0.27,0,1)}
@keyframes pretty-modal-opening{from{opacity:0;filter:blur(10px)}to{opacity:1;filter:blur(0)}}
.origin-page-surface.pretty-modal-closing{pointer-events:none}
.origin-page-surface.pretty-modal-closing > .origin-page-body{animation:pretty-modal-closing-blur 500ms cubic-bezier(0.37,0.35,0,1),pretty-modal-closing-fade 700ms cubic-bezier(0.56,0.27,0,1)}
@keyframes pretty-modal-closing-radius{to{border-radius:400px}}
@keyframes pretty-modal-closing-blur{from{filter:blur(0)}to{filter:blur(32px)}}
@keyframes pretty-modal-closing-fade{from{opacity:1}to{opacity:0}}
@media(prefers-reduced-motion:reduce){.origin-page-surface.pretty-modal-opening > .origin-page-body,.origin-page-surface.pretty-modal-closing > .origin-page-body{animation:none}}
</style>
