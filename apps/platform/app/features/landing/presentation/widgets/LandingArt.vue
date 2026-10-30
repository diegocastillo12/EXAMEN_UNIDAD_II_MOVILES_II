<script setup lang="ts">
import { landingArtwork, type LandingArtworkName } from './landing_artwork';
const props = defineProps<{ name: LandingArtworkName; label?: string; eager?: boolean }>();
const artwork = computed(() => landingArtwork[props.name]);
const hero = computed(() => props.name.startsWith('hero-'));
const sourceSet = computed(() => {
  const source = artwork.value.src.replace(/\.png$/, '');
  return hero.value ? `${source}-320.webp 320w, ${source}-640.webp 640w, ${source}.webp ${artwork.value.width}w` : `${source}.webp`;
});
</script>
<template>
  <div :class="['art', `art-${name}`]" :role="label ? 'img' : undefined" :aria-label="label" :aria-hidden="label ? undefined : true">
    <picture>
      <source :srcset="sourceSet" :sizes="hero ? '(max-width: 600px) 54px, (max-width: 1480px) 15vw, 222px' : undefined" type="image/webp">
      <img :src="artwork.src" alt="" :width="artwork.width" :height="artwork.height" :loading="eager || name.startsWith('hero-') ? 'eager' : 'lazy'" decoding="async" draggable="false">
    </picture>
  </div>
</template>
