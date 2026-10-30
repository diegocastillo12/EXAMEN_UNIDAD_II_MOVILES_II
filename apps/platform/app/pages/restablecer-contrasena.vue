<script setup lang="ts">
import CredentialScreen from '~/features/access/presentation/screens/CredentialScreen.vue';
useHead({ title: 'Nueva contraseña | Entre Huellas' });
</script>
<template><AmbientPageShell intensity="strong"><CredentialScreen kind="recovery" reset-page /></AmbientPageShell></template>
