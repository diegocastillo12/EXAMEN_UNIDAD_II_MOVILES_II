<script setup lang="ts">
export type FieldOption = { value: string; label: string; keywords?: string };
const props = withDefaults(defineProps<{ modelValue: string; label: string; options: readonly FieldOption[]; placeholder?: string; disabled?: boolean; invalid?: boolean; searchable?: boolean }>(), { placeholder: 'Selecciona…', searchable: undefined });
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
const id = useId(), query = ref(''), active = ref(0), morph = useTemplateRef('morph');
const selected = computed(() => props.options.find(o => o.value === props.modelValue));
const hasSearch = computed(() => props.searchable ?? props.options.length > 8);
const normalize = (s: string) => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
const visible = computed(() => props.options.filter(o => normalize(`${o.label} ${o.keywords ?? ''}`).includes(normalize(query.value.trim()))));
function choose(value: string) { if (props.disabled) return; emit('update:modelValue', value); void morph.value?.close(); }
function start(toggle: () => unknown) { query.value = ''; active.value = Math.max(0, props.options.findIndex(o => o.value === props.modelValue)); toggle(); }
function key(event: KeyboardEvent, open: boolean, toggle: () => unknown) {
  if (props.disabled) return;
  if (!open) { if (['ArrowDown','ArrowUp','Enter',' '].includes(event.key)) { event.preventDefault(); start(toggle); } return; }
  if (['ArrowDown','ArrowUp','Home','End'].includes(event.key)) {
    event.preventDefault();
    active.value = event.key === 'Home' ? 0 : event.key === 'End' ? visible.value.length - 1 : Math.max(0, Math.min(visible.value.length - 1, active.value + (event.key === 'ArrowDown' ? 1 : -1)));
  } else if (event.key === 'Enter' || (event.key === ' ' && !hasSearch.value)) { event.preventDefault(); const o = visible.value[active.value]; if (o) choose(o.value); }
}
watch(active, async () => { await nextTick(); document.getElementById(`${id}-option-${active.value}`)?.scrollIntoView({ block: 'nearest' }); });
</script>
<template>
  <div class="sader-field" :class="{ 'sader-invalid': invalid }">
    <span :id="id + '-label'" class="sader-field-label">{{ label }}</span>
    <MorphPanel :id="id + '-list'" ref="morph" role="listbox" :label="label" :disabled="disabled">
      <template #trigger="{ open, toggle }">
        <button class="sader-control" type="button" role="combobox" aria-haspopup="listbox" :aria-labelledby="id + '-label'" :aria-expanded="open" :aria-controls="id + '-list'" :aria-activedescendant="open && visible[active] ? `${id}-option-${active}` : undefined" :aria-invalid="invalid" :disabled="disabled" @click="start(toggle)" @keydown="key($event, open, toggle)">
          <span :class="{ 'sader-placeholder': !selected }">{{ selected?.label ?? placeholder }}</span><FieldIcon name="chevron" />
        </button>
      </template>
      <div class="sader-select-options" :tabindex="hasSearch ? undefined : 0" :aria-activedescendant="visible[active] ? `${id}-option-${active}` : undefined" @keydown="key($event, true, () => {})">
        <div v-if="hasSearch" class="sader-search"><FieldIcon name="search" /><input v-model="query" :aria-label="'Buscar en ' + label" :aria-controls="id + '-list'" :aria-activedescendant="visible[active] ? `${id}-option-${active}` : undefined" placeholder="Buscar…" @input="active = 0" /></div>
        <div v-if="!visible.length" class="sader-no-results">No se encontraron resultados.</div>
        <div v-for="(option, i) in visible" :id="`${id}-option-${i}`" :key="option.value" role="option" :aria-selected="option.value === modelValue" class="sader-option" :class="{ selected: option.value === modelValue, active: i === active }" @mouseenter="active = i" @click="choose(option.value)">{{ option.label }}</div>
      </div>
    </MorphPanel>
  </div>
</template>
