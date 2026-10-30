<script setup lang="ts">
export type AnimalForm = { name: string; species: string; speciesDetail: string; size: string; sex: string; ageMonths: string | number | null; traits: string };
const model = defineModel<AnimalForm>({ required:true });
withDefaults(defineProps<{ pet?: boolean; disabled: boolean; invalid: readonly string[] }>(),{ pet:false });
</script>
<template>
  <div class="recovery-fields">
    <TextField v-if="pet" v-model="model.name" label="Nombre" :disabled="disabled" :maxlength="80" autocomplete="off" :invalid="invalid.includes('name')" />
    <FieldSelect v-model="model.species" label="Especie" :options="[{value:'',label:'Selecciona una especie'},{value:'dog',label:'Perro'},{value:'cat',label:'Gato'},{value:'other',label:'Otra especie'}]" :disabled="disabled" :invalid="invalid.includes('species')" />
    <TextField v-if="model.species === 'other'" v-model="model.speciesDetail" label="¿Qué especie?" :disabled="disabled" :maxlength="pet ? 60 : 40" :invalid="invalid.includes('speciesDetail') || invalid.includes('species')" />
    <FieldSelect v-model="model.size" label="Tamaño" :options="[{value:'',label:pet ? 'Selecciona un tamaño' : 'No lo sé'},{value:'small',label:'Pequeño'},{value:'medium',label:'Mediano'},{value:'large',label:'Grande'}]" :disabled="disabled" :invalid="invalid.includes('size')" />
    <FieldSelect v-model="model.sex" label="Sexo (opcional)" :options="[{value:'',label:'No lo sé'},{value:'male',label:'Macho'},{value:'female',label:'Hembra'}]" :disabled="disabled" />
    <TextField v-if="pet" v-model="model.ageMonths" label="Edad en meses" type="number" min="0" max="600" step="1" inputmode="numeric" :disabled="disabled" :invalid="invalid.includes('ageMonths')" />
    <TextField v-model="model.traits" class="recovery-full" label="Rasgos distintivos" multiline :maxlength="200" :disabled="disabled" :invalid="invalid.includes('traits')" />
  </div>
</template>
