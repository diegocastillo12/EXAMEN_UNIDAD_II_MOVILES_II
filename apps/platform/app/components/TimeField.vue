<script setup lang="ts">
// Display follows Sader; the model stays HH:mm and covers the full day for sightings.
const props = defineProps<{ modelValue: string; label: string; disabled?: boolean; invalid?: boolean }>();
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
const id = useId(), morph = useTemplateRef('morph');
const time = computed(() => /^(\d{2}):(\d{2})$/.test(props.modelValue) ? props.modelValue.split(':').map(Number) : null);
const hourLabel = (h: number) => `${((h+11)%12)+1} ${h < 12 ? 'AM' : 'PM'}`;
const display = computed(() => time.value ? `${((time.value[0]!+11)%12)+1}:${String(time.value[1]).padStart(2,'0')} ${time.value[0]! < 12 ? 'AM' : 'PM'}` : 'Selecciona…');
function pick(hour: number, minute: number, finish = false) {
  if (props.disabled) return;
  emit('update:modelValue',`${String(hour).padStart(2,'0')}:${String(minute).padStart(2,'0')}`);
  if (finish) void morph.value?.close();
}
function move(event: KeyboardEvent) {
  if (!['ArrowUp','ArrowDown','Home','End'].includes(event.key)) return;
  event.preventDefault(); const button = event.target as HTMLElement, items = [...button.parentElement!.querySelectorAll<HTMLButtonElement>('button')];
  const index = items.indexOf(button as HTMLButtonElement);
  items[event.key === 'Home' ? 0 : event.key === 'End' ? items.length-1 : Math.max(0,Math.min(items.length-1,index+(event.key === 'ArrowDown' ? 1 : -1)))]?.focus();
}
</script>
<template>
  <div class="sader-field" :class="{'sader-invalid':invalid}">
    <span :id="id + '-label'" class="sader-field-label">{{ label }}</span>
    <MorphPanel :id="id + '-dialog'" ref="morph" :label="label" :disabled="disabled">
      <template #trigger="{open,toggle}"><button class="sader-control" type="button" aria-haspopup="dialog" :aria-labelledby="id + '-label'" :aria-controls="id + '-dialog'" :aria-expanded="open" :aria-invalid="invalid" :disabled="disabled" @click="toggle" @keydown.down.prevent="toggle"><span :class="{'sader-placeholder':!time}">{{ display }}</span><FieldIcon name="clock" /></button></template>
      <div class="sader-time-columns">
        <div><span class="sader-time-title">Hora</span><div class="sader-time-scroll" @keydown="move"><button v-for="h in 24" :key="h" class="sader-time-option" :class="{selected: time?.[0] === h-1}" type="button" :aria-pressed="time?.[0] === h-1" @click="pick(h-1,time?.[1] ?? 0)">{{ hourLabel(h-1) }}</button></div></div>
        <div><span class="sader-time-title">Minutos</span><div class="sader-time-scroll" @keydown="move"><button v-for="m in 60" :key="m" class="sader-time-option" :class="{selected:time?.[1] === m-1}" type="button" :aria-pressed="time?.[1] === m-1" @click="pick(time?.[0] ?? 0,m-1,true)">{{ String(m-1).padStart(2,'0') }}</button></div></div>
      </div>
    </MorphPanel>
  </div>
</template>
