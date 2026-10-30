import { assertRegisteredRoutes } from './shared/routing/route_policy';
import { packageNativeImages } from './scripts/package-native-images.mjs';

export default defineNuxtConfig({
  hooks: {
    'pages:extend'(pages) {
      const visit = (items: typeof pages, parent = '') => {
        for (const page of items) {
          const path = page.path.startsWith('/') ? page.path : parent + '/' + page.path;
          assertRegisteredRoutes([path]);
          if (page.alias) assertRegisteredRoutes(Array.isArray(page.alias) ? page.alias : [page.alias]);
          if (page.children) visit(page.children, path);
        }
      };
      visit(pages);
    },
  },
  compatibilityDate: '2026-10-17',
  devtools: { enabled: false },
  buildDir: process.env.NUXT_BUILD_DIR || '.nuxt',
  ssr: true,
  css: ['~/assets/main.css', '~/assets/typography.css', '~/assets/maps.css', '~/assets/fields.css'],
  runtimeConfig: { public: { mapTileUrl: '', siteUrl: 'https://entrehuellas.app' } },
  typescript: { strict: true },
  sourcemap: { server: false, client: false },
  nitro: {
    preset: 'node-server', compressPublicAssets: true,
    hooks: {
      async compiled(nitro) {
        await packageNativeImages(nitro.options.rootDir, nitro.options.output.serverDir);
      },
    },
  },
  app: {
    head: {
      htmlAttrs: { lang: 'es' },
      title: 'Entre Huellas',
      meta: [{ name: 'referrer', content: 'no-referrer' }],
      link: [
        { rel: 'icon', href: '/brand-icon.png', type: 'image/png' },
        { rel: 'preload', as: 'font', type: 'font/ttf', href: '/fonts/poppins/Poppins-Regular.ttf', crossorigin: 'anonymous' },
      ],
    },
  },
});
