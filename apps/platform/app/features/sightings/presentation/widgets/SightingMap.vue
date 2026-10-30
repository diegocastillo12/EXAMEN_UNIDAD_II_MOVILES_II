<script setup lang="ts">
import type { SightingPoint } from '../../../../../shared/features/sightings/domain/sighting';
defineProps<{ center: { latitude: number; longitude: number }; point: SightingPoint | null; disabled: boolean; invalid: boolean }>();
const emit = defineEmits<{ choose: [point: SightingPoint]; failed: [retry: () => void] }>();
</script>
<template>
  <LocationMap :center="center" :point="point" :disabled="disabled" :invalid="invalid" :radius-meters="200"
    @choose="emit('choose', { ...$event, source: 'manual', accuracy: null })"
    @failed="emit('failed', $event)" />
</template>
