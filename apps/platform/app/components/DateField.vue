<script setup lang="ts">
const props = defineProps<{ modelValue: string; label: string; min?: string; max?: string; disabled?: boolean; invalid?: boolean }>();
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
const id = useId(), morph = useTemplateRef('morph');
const month = ref(new Date(2000, 0, 1));
const parse = (value: string) => { const [y,m,d] = value.split('-').map(Number); return y && m && d ? new Date(y,m-1,d) : null; };
const iso = (d: Date) => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
const title = computed(() => { const s = month.value.toLocaleDateString('es-PE', { month:'long',year:'numeric' }); return s[0]!.toUpperCase()+s.slice(1); });
const display = computed(() => parse(props.modelValue)?.toLocaleDateString('es-PE', { day:'2-digit',month:'short',year:'numeric' }).replace('.',''));
const cells = computed(() => {
  const y = month.value.getFullYear(), m = month.value.getMonth(), lead = (new Date(y,m,1).getDay()+6)%7;
  return Array.from({ length:Math.ceil((lead+new Date(y,m+1,0).getDate())/7)*7 },(_,i) => {
    const date = new Date(y,m,1-lead+i), value = iso(date);
    return { date,value,today:value === iso(new Date()),off:date.getMonth()!==m || !!(props.min && value < props.min) || !!(props.max && value > props.max) };
  });
});
function start(toggle: () => unknown) { month.value = parse(props.modelValue) ?? new Date(); toggle(); }
function shift(n: number) { month.value = new Date(month.value.getFullYear(),month.value.getMonth()+n,1); }
function pick(value: string) { if (!props.disabled) { emit('update:modelValue',value); void morph.value?.close(); } }
function move(event: KeyboardEvent, date: Date) {
  const delta = { ArrowLeft:-1,ArrowRight:1,ArrowUp:-7,ArrowDown:7 }[event.key];
  if (!delta) return; event.preventDefault();
  const next = new Date(date.getFullYear(),date.getMonth(),date.getDate()+delta), value = iso(next);
  if ((props.min && value < props.min) || (props.max && value > props.max)) return;
  month.value = next;
  void nextTick(() => document.getElementById(`${id}-${value}`)?.focus());
}
</script>
<template>
  <div class="sader-field" :class="{ 'sader-invalid': invalid }">
    <span :id="id + '-label'" class="sader-field-label">{{ label }}</span>
    <MorphPanel :id="id + '-dialog'" ref="morph" :label="label" :panel-width="360" :disabled="disabled">
      <template #trigger="{open,toggle}"><button type="button" class="sader-control" aria-haspopup="dialog" :aria-labelledby="id + '-label'" :aria-controls="id + '-dialog'" :aria-expanded="open" :aria-invalid="invalid" :disabled="disabled" @click="start(toggle)" @keydown.down.prevent="start(toggle)"><span :class="{'sader-placeholder': !display}">{{ display || 'Selecciona…' }}</span><FieldIcon name="calendar" /></button></template>
      <div class="sader-calendar">
        <div class="sader-calendar-header"><span aria-live="polite">{{ title }}</span><div><button type="button" aria-label="Mes anterior" @click="shift(-1)"><FieldIcon name="left" /></button><button type="button" aria-label="Mes siguiente" @click="shift(1)"><FieldIcon name="right" /></button></div></div>
        <div class="sader-calendar-grid sader-weekdays"><span v-for="day in ['Lu','Ma','Mi','Ju','Vi','Sa','Do']" :key="day">{{ day }}</span></div>
        <div class="sader-calendar-grid"><button v-for="cell in cells" :id="`${id}-${cell.value}`" :key="cell.value" type="button" :disabled="cell.off || disabled" :aria-label="cell.date.toLocaleDateString('es-PE',{day:'numeric',month:'long',year:'numeric'})" :aria-pressed="cell.value === modelValue" :aria-current="cell.today ? 'date' : undefined" :class="{selected:cell.value === modelValue}" @click="pick(cell.value)" @keydown="move($event,cell.date)">{{ cell.date.getDate() }}</button></div>
      </div>
    </MorphPanel>
  </div>
</template>
