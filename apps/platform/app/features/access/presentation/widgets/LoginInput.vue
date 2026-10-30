<script setup lang="ts">
withDefaults(defineProps<{
  modelValue: string; label: string; password?: boolean; disabled?: boolean;
  invalid?: boolean; notice?: number; field?: 'email' | 'name' | 'code'; newPassword?: boolean;
}>(), { password: false, disabled: false, invalid: false, notice: 0, field: 'email', newPassword: false });
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();
const visible = ref(false);
</script>
<template>
  <label class="login-field" :class="{ invalid, shake: invalid }" :data-notice="notice">
    <svg class="login-field-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <template v-if="password"><rect x="5" y="10" width="14" height="11" rx="3" /><path d="M8 10V7a4 4 0 0 1 8 0v3M12 14v3" /></template>
      <template v-else-if="field === 'name'"><circle cx="12" cy="8" r="4" /><path d="M4 21v-2a8 8 0 0 1 16 0v2" /></template>
      <template v-else-if="field === 'code'"><rect x="3" y="4" width="18" height="16" rx="3" /><path d="M8 9h8M8 15h2m4 0h2" /></template>
      <template v-else><rect x="3" y="5" width="18" height="14" rx="3" /><path d="m4 7 8 6 8-6" /></template>
    </svg>
    <input :value="modelValue" :type="password ? (visible ? 'text' : 'password') : field === 'email' ? 'email' : 'text'" :autocomplete="password ? (newPassword ? 'new-password' : 'current-password') : field === 'code' ? 'one-time-code' : field === 'name' ? 'name' : 'username'" :inputmode="password || field === 'name' ? undefined : field === 'code' ? 'numeric' : 'email'" placeholder=" " required :maxlength="password ? 1024 : field === 'code' ? 6 : field === 'name' ? 120 : 254" :disabled="disabled" :aria-invalid="invalid" :class="{ 'has-toggle': password }" @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)" />
    <span class="login-field-label">{{ label }}</span>
    <button v-if="password" class="login-password-toggle" type="button" :disabled="disabled" :aria-label="visible ? 'Ocultar contraseña' : 'Mostrar contraseña'" :title="visible ? 'Ocultar contraseña' : 'Mostrar contraseña'" :aria-pressed="visible" @click="visible = !visible">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" /><circle cx="12" cy="12" r="3" /><path v-if="visible" d="m3 3 18 18" /></svg>
    </button>
  </label>
</template>
