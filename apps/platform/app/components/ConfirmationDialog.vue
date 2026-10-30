<script setup lang="ts">
const props=defineProps<{open:boolean;title:string;description:string;action:string}>();
const emit=defineEmits<{answer:[confirmed:boolean]}>();
const dialog=useTemplateRef('dialog');
watch(()=>props.open,async open=>{await nextTick();if(open)dialog.value?.showModal();else dialog.value?.close();});
onBeforeUnmount(()=>dialog.value?.close());
</script>
<template>
  <dialog ref="dialog" class="confirmation-dialog" aria-labelledby="confirm-title" aria-describedby="confirm-description" @cancel.prevent="emit('answer',false)">
    <h2 id="confirm-title">{{title}}</h2><p id="confirm-description">{{description}}</p>
    <div class="confirmation-actions"><ActionButton @click="emit('answer',false)">Cancelar</ActionButton><ActionButton variant="primary" @click="emit('answer',true)">{{action}}</ActionButton></div>
  </dialog>
</template>
<style>
.reader-shell .confirmation-dialog{border:0;border-radius:28px;padding:28px;max-width:min(520px,calc(100% - 32px));max-height:calc(100svh - 32px);overflow:auto;overflow-wrap:anywhere;color:#171918;background:#fff;box-shadow:0 20px 80px #17191830}
.reader-shell .confirmation-dialog::backdrop{background:#17191855;backdrop-filter:blur(8px)}
.reader-shell .confirmation-actions{display:flex;flex-wrap:wrap;gap:12px;margin-top:24px}.reader-shell .confirmation-actions>*{flex:1 1 10rem;min-width:0;max-width:100%;white-space:normal}
</style>
