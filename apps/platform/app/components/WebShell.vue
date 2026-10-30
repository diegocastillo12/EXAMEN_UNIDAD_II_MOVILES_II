<script setup lang="ts">
withDefaults(defineProps<{ withBack?: boolean; wide?: boolean; minimal?: boolean }>(), { withBack: false, wide: false, minimal: false });
</script>
<template>
  <div class="reader-shell" :class="{ 'with-back': withBack, wide }">
  <a class="skip-link" href="#view">Saltar al contenido</a>
  <SiteHeader v-if="!minimal" />
  <slot />
  <footer v-if="!minimal">Un encuentro puede cambiarlo todo.<br><strong>Entre Huellas</strong></footer>
  </div>
</template>
