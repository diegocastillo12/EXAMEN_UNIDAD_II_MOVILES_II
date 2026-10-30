<script setup lang="ts">
const props = defineProps<{ slug: string; title: string; revision: string; count: number }>();
const emit = defineEmits<{ failed: [retry: () => void] }>();
const index = ref(0); const attempt = ref(0); const failed = ref(false);
const source = computed(() => `/api/c/${props.slug}/photos/${index.value}?v=${props.revision}${attempt.value ? `&retry=${attempt.value}` : ''}`);
watch(() => props.revision, () => { index.value = 0; failed.value = false; });
function move(step: number) { index.value += step; failed.value = false; }
function retry() { failed.value = false; attempt.value++; }
function imageError() { failed.value = true; emit('failed', retry); }
</script>
<template>
  <section class="gallery" aria-label="Fotos de la mascota">
    <img class="pet-photo" :class="{ 'photo-failed': failed }" :src="source" width="720" height="720" decoding="async" :alt="`Foto de ${title}`" @error="imageError">
    <template v-if="count > 1">
      <button class="glass photo-previous" type="button" aria-label="Foto anterior" :disabled="index === 0" @click="move(-1)">‹</button>
      <button class="glass photo-next" type="button" aria-label="Foto siguiente" :disabled="index === count - 1" @click="move(1)">›</button>
      <span class="photo-count" aria-live="polite">{{ index + 1 }} / {{ count }}</span>
    </template>
  </section>
</template>
