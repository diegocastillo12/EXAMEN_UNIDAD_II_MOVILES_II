<script setup lang="ts">
import { materialSymbolPaths } from './material_symbol_paths';
import type { MaterialSymbolName } from './material_symbol_paths';
defineProps<{name:MaterialSymbolName}>();
</script>
<template><svg class="app-icon" :viewBox="name==='error-outline'||name==='check'?'0 0 24 24':'0 -960 960 960'" fill="currentColor" aria-hidden="true" focusable="false"><path :d="materialSymbolPaths[name]" /></svg></template>
