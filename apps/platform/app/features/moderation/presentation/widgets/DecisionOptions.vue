<script setup lang="ts">
import type {ModerationAction} from '../../../../../shared/features/moderation/domain/moderation';
defineProps<{value:ModerationAction;disabled:boolean}>();
const emit=defineEmits<{choose:[action:ModerationAction]}>();
const options:ReadonlyArray<{value:ModerationAction;label:string}>=[{value:'dismiss',label:'Resolver sin cambiar visibilidad'},{value:'hide',label:'Ocultar contenido'},{value:'show',label:'Restaurar visibilidad'}];
</script>
<template><fieldset class="moderation-options" :disabled="disabled"><legend>Decisión</legend><label v-for="option in options" :key="option.value" class="moderation-option" :class="{selected:value===option.value}"><input type="radio" name="moderation-action" :value="option.value" :checked="value===option.value" @change="emit('choose',option.value)" /><span>{{option.label}}</span></label></fieldset></template>
