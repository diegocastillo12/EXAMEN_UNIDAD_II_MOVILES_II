import { siteOrigin } from '../../shared/seo/site_metadata';

export default defineEventHandler(event => {
  const origin = siteOrigin(useRuntimeConfig(event).public.siteUrl);
  setHeader(event, 'Content-Type', 'application/xml; charset=utf-8');
  const location = `${origin}/`.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
  return `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>${location}</loc></url></urlset>`;
});
