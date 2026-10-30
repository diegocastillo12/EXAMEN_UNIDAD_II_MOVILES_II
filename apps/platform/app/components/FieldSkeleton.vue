<script setup lang="ts">
defineProps<{ label: string }>();
</script>
<template>
  <div class="sader-field" role="status" :aria-label="'Consultando ' + label" aria-busy="true">
    <span class="sader-field-label" aria-hidden="true">{{ label }}</span>
    <div class="shape sader-field-placeholder" />
  </div>
</template>
<style>
.reader-shell .sader-field-placeholder{min-height:3rem;border-radius:calc(.625rem - 2px);background:var(--sf-accent)}
</style>
