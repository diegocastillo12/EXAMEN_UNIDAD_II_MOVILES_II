<script setup lang="ts">
withDefaults(defineProps<{ working?: boolean; disabled?: boolean; variant?: string; type?: 'button' | 'submit' }>(), { working: false, disabled: false, variant: 'secondary', type: 'button' });
</script>
<template><button :type="type" :class="[variant, { working }]" :disabled="working || disabled" :aria-busy="working"><slot /></button></template>
