<script setup lang="ts">
const props = defineProps<{ actor: string }>();
const model = useNuxtApp().$statisticsModel(props.actor), state = shallowRef(model.state);
const unsubscribe = model.subscribe(value => { state.value = value; });
const toast = useTemplateRef('toast');
watch(() => state.value.notice, () => { if (state.value.failure === 'unavailable') toast.value?.show('No pudimos comprobar el acceso a estadísticas. Puedes reintentar.'); });
onMounted(() => model.checkAccess());
onBeforeUnmount(() => { unsubscribe(); model.dispose(); });
</script>
<template>
  <TopToast ref="toast" />
  <section v-if="state.allowed" class="account-management account-panel" aria-labelledby="statistics-entry-title">
    <div><h2 id="statistics-entry-title">Actividad de la comunidad</h2><p>Consulta las estadísticas agregadas por período.</p></div>
    <NavigationLink to="/administracion/estadisticas" origin class="secondary">Ver estadísticas</NavigationLink>
  </section>
  <ActionButton v-else-if="state.failure === 'unavailable'" :working="state.busy" @click="model.checkAccess()">Reintentar acceso a estadísticas</ActionButton>
</template>
