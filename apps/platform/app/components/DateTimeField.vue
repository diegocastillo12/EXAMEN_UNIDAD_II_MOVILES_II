<script setup lang="ts">
const props = defineProps<{ modelValue: string; label: string; disabled?: boolean; invalid?: boolean }>();
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
// Preserve partial values while the user completes the other half, without
// manufacturing a date/time or changing the existing local datetime contract.
const day = ref(''), time = ref('');
watch(() => props.modelValue, value => { if (value) [day.value,time.value] = value.split('T') as [string,string]; else { day.value = ''; time.value = ''; } }, { immediate:true });
function update(part: 'day'|'time', value: string) {
  if (part === 'day') day.value = value; else time.value = value;
  if (day.value && time.value) emit('update:modelValue', `${day.value}T${time.value}`);
}
</script>
<template><div class="sader-datetime"><DateField :model-value="day" :label="label + ' · fecha'" :disabled="disabled" :invalid="invalid" @update:model-value="update('day',$event)" /><TimeField :model-value="time" :label="label + ' · hora'" :disabled="disabled" :invalid="invalid" @update:model-value="update('time',$event)" /></div></template>
