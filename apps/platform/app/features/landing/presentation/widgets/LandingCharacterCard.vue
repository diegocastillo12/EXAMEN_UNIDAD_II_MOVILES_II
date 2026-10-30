<script setup lang="ts">
import LandingArt from './LandingArt.vue';
defineProps<{ title: string; art: 'search' | 'found' | 'help' | 'return' | 'search-corgi' | 'found-tabby' | 'help-dalmatian'; decorative?: boolean }>();
</script>
<template>
  <figure :class="['character', { 'character-return': art === 'return' }]" :aria-hidden="decorative ? true : undefined">
    <figcaption class="character-label">{{ title }}</figcaption>
    <LandingArt :name="art" eager />
    <svg class="character-spark" viewBox="0 0 40 40" fill="none" aria-hidden="true"><path d="m10 4 4 10M27 5l-3 9M35 21l-10 2" stroke="currentColor" stroke-width="3" stroke-linecap="round" /></svg>
  </figure>
</template>
