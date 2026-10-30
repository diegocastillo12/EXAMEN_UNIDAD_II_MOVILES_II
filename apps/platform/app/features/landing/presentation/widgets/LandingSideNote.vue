<template>
  <div class="landing-side-note" aria-hidden="true">
    <svg class="side-note-shapes" viewBox="0 0 300 440" fill="none">
      <defs><linearGradient id="side-note-wash" x1="260" y1="20" x2="80" y2="350" gradientUnits="userSpaceOnUse"><stop stop-color="#e8efd2" /><stop offset="0.6" stop-color="#fff8e7" /><stop offset="1" stop-color="#fff1d9" /></linearGradient><linearGradient id="side-note-peach" x1="280" y1="330" x2="10" y2="410" gradientUnits="userSpaceOnUse"><stop stop-color="#ffdfb4" /><stop offset="1" stop-color="#fff0d5" stop-opacity="0.75" /></linearGradient></defs>
      <path d="M44 13C112 39 167 5 224 25C282 45 309 111 294 172C282 222 314 278 296 342C282 397 231 426 168 405C113 387 59 416 10 394C41 349 90 326 91 294C93 262 56 250 77 230C99 207 135 224 173 222C126 206 78 205 41 216C11 187 34 163 21 124C5 78-3-5 44 13Z" fill="url(#side-note-wash)" />
      <path d="M98 258C133 235 170 283 232 273C269 268 289 254 301 271L304 393C279 420 238 430 185 412C111 386 60 414 10 394C35 360 64 347 85 325C122 289 66 282 98 258Z" fill="url(#side-note-peach)" />
      <path d="M211 249C189 235 198 222 208 234C215 215 234 231 211 249ZM211 249C241 253 267 248 299 279" stroke="#6d8a96" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
      <path d="M43 202C21 186 32 173 42 185C49 168 63 183 43 202ZM43 202L29 206" stroke="#efac90" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" />
    </svg>
    <LandingPawTrail />
    <span class="side-note-message">Pequeñas<br>acciones,<br>grandes<br>reencuentros.</span>
  </div>
</template>

<script setup lang="ts">
import LandingPawTrail from './LandingPawTrail.vue';
</script>
