// Public deployment identity only; never infer it from Host or forwarded headers.
export function siteOrigin(value: string): string {
  const url = new URL(value);
  if (url.protocol !== 'https:' || url.username || url.password || url.pathname !== '/' || url.search || url.hash) {
    throw new Error('NUXT_PUBLIC_SITE_URL must be an HTTPS origin without credentials, path, query or fragment');
  }
  return url.origin;
}

export const landingTitle = 'Entre Huellas | Mascotas perdidas y encontradas';
export const landingDescription = 'Colabora en la búsqueda de mascotas perdidas y encontradas. Conoce Entre Huellas y cómo reportar, compartir avisos y ayudar a que vuelvan a casa.';
export const landingImage = '/images/landing/social-reunion.jpg';

export function landingStructuredData(origin: string) {
  return {
    '@context': 'https://schema.org',
    '@graph': [
      { '@type': 'Organization', '@id': `${origin}/#organization`, name: 'Entre Huellas', url: `${origin}/`, logo: { '@type': 'ImageObject', url: `${origin}/brand.png`, width: 1024, height: 1024 } },
      { '@type': 'WebSite', '@id': `${origin}/#website`, name: 'Entre Huellas', url: `${origin}/`, inLanguage: 'es-PE', publisher: { '@id': `${origin}/#organization` } },
      { '@type': 'WebPage', '@id': `${origin}/#webpage`, url: `${origin}/`, name: landingTitle, description: landingDescription, inLanguage: 'es-PE', isPartOf: { '@id': `${origin}/#website` }, about: { '@id': `${origin}/#organization` }, primaryImageOfPage: { '@type': 'ImageObject', url: `${origin}${landingImage}`, width: 1200, height: 630 } },
    ],
  };
}
