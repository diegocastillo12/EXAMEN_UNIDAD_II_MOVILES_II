<script setup lang="ts">
defineProps<{ footer?: boolean }>();
</script>
<template>
  <a :class="['brand', { 'brand-footer': footer }]" href="#inicio" aria-label="Entre Huellas, inicio">
    <img src="/brand.png" alt="" width="48" height="48" decoding="async">
    <span v-if="footer">entre<br>huellas</span><span v-else>entre huellas</span>
  </a>
</template>
