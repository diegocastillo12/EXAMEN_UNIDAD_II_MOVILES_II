<script setup lang="ts">
import LandingPage from '../features/landing/presentation/screens/LandingPage.vue';
import { siteOrigin, landingTitle, landingDescription, landingImage, landingStructuredData } from '#shared/seo/site_metadata';
const origin = siteOrigin(useRuntimeConfig().public.siteUrl);
const image = `${origin}${landingImage}`;
useSeoMeta({
  title: landingTitle, description: landingDescription,
  robots: 'index, follow, max-image-preview:large', ogType: 'website', ogLocale: 'es_PE',
  ogSiteName: 'Entre Huellas', ogUrl: `${origin}/`,
  ogTitle: landingTitle, ogDescription: landingDescription,
  ogImage: image, ogImageType: 'image/jpeg', ogImageWidth: 1200, ogImageHeight: 630,
  ogImageAlt: 'Un perro y un gato juntos, ilustración de Entre Huellas',
  twitterCard: 'summary_large_image', twitterTitle: landingTitle, twitterDescription: landingDescription,
  twitterImage: image, twitterImageAlt: 'Un perro y un gato juntos, ilustración de Entre Huellas',
});
useHead({
  link: [{ rel: 'canonical', href: `${origin}/` }],
  script: [{ key: 'landing-structured-data', type: 'application/ld+json', textContent: JSON.stringify(landingStructuredData(origin)).replace(/</g, '\\u003c') }],
});
</script>
<template><LandingPage /></template>
