import { siteOrigin } from '../../shared/seo/site_metadata';

export default defineEventHandler(event => {
  const origin = siteOrigin(useRuntimeConfig(event).public.siteUrl);
  setHeader(event, 'Content-Type', 'text/plain; charset=utf-8');
  // Other HTML routes remain crawlable so crawlers can see their noindex header.
  // Do not block Nuxt assets, fonts or landing illustrations needed for rendering.
  return `User-agent: *\nAllow: /$\nDisallow: /c/\nDisallow: /api/\nDisallow: /app/\nDisallow: /admin/\nSitemap: ${origin}/sitemap.xml\n`;
});
