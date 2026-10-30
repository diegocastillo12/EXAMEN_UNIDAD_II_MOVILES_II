<script setup lang="ts">
import type { SocialProvider } from '#shared/features/access/domain/access';
defineProps<{provider:SocialProvider;working:boolean;disabled:boolean}>();
const emit=defineEmits<{choose:[provider:SocialProvider]}>();
</script>
<template>
  <ActionButton class="login-social-button" :working="working" :disabled="disabled" @click="emit('choose',provider)">
    <img v-if="provider==='google'" src="/images/auth/google-g.png" width="22" height="22" alt="" />
    <svg v-else viewBox="0 0 24 24" width="24" height="24" aria-hidden="true"><circle cx="12" cy="12" r="12" fill="#0866ff" /><path fill="#fff" d="M13.5 24v-9h3l.5-3.5h-3.5V9.3c0-1 .5-1.8 1.9-1.8h1.8V4.4s-1.3-.2-2.6-.2c-2.7 0-4.4 1.6-4.4 4.6v2.7H7.3V15h2.9v9Z" /></svg>
    <span>Continúa con {{provider==='google'?'Google':'Facebook'}}</span>
  </ActionButton>
</template>
