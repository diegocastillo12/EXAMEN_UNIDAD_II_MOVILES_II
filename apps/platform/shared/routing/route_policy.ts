export type RouteAccess = 'public' | 'guest' | 'account' | 'onboarding' | 'reviewer' | 'administrator' | 'recovery';

// Every page must be registered here; the architecture check compares this
// inventory with app/pages, including redirects and the public 404 fallback.
export const routePolicies: Readonly<Record<string, RouteAccess>> = Object.freeze({
  '/': 'public',
  '/iniciar-sesion': 'guest',
  '/crear-cuenta': 'guest',
  '/recuperar-contrasena': 'guest',
  '/restablecer-contrasena': 'recovery',
  '/inicio': 'account',
  '/explorar': 'account',
  '/mis-mascotas': 'account',
  '/reportar': 'account',
  '/coincidencias': 'account',
  '/casos/:source/:id': 'account',
  '/cuentas-bloqueadas': 'account',
  '/bienvenida': 'onboarding',
  '/moderacion': 'reviewer',
  '/administracion/estadisticas': 'administrator',
  '/apelaciones': 'account',
  '/moderacion/apelaciones': 'reviewer',
  '/terminos': 'public',
  '/privacidad': 'public',
  '/login': 'public',
  '/terms': 'public',
  '/privacy': 'public',
  '/c/:slug': 'public',
  '/:path(.*)*': 'public',
});

export function routeAccess(path: string, policies: Readonly<Record<string, RouteAccess>> = routePolicies): RouteAccess {
  const normalized = path.replace(/\/+$/, '').toLowerCase() || '/';
  if (Object.hasOwn(policies, normalized)) return policies[normalized]!;
  const segments = normalized.split('/');
  for (const [pattern, access] of Object.entries(policies)) {
    if (pattern === '/:path(.*)*' || !pattern.includes(':')) continue;
    const expected = pattern.toLowerCase().split('/');
    if (segments.length === expected.length && expected.every((part, index) => /^:\w+$/.test(part) ? !!segments[index] : part === segments[index])) return access;
  }
  return policies['/:path(.*)*']!;
}

export function sessionRedirect(access: RouteAccess, onboardingCompleted: boolean): string | null {
  if (access === 'public' || access === 'recovery') return null;
  if (!onboardingCompleted) return access === 'onboarding' ? null : '/bienvenida';
  return access === 'guest' || access === 'onboarding' ? '/inicio' : null;
}

// Only registered account destinations may survive the legacy-cookie bridge.
export function accountDestination(value: unknown): string | null {
  if (typeof value !== 'string' || !value.startsWith('/') || value.startsWith('//') || /[\s?#\\]/.test(value)) return null;
  return ['account', 'onboarding', 'reviewer', 'administrator'].includes(routeAccess(value)) ? value : null;
}
export function entryDestination(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  return ['/crear-cuenta', '/recuperar-contrasena', '/iniciar-sesion'].includes(value) ? value : accountDestination(value);
}

export function assertRegisteredRoutes(paths: readonly string[]): void {
  for (const path of paths) {
    if (!Object.hasOwn(routePolicies, path.replace(/\(\)/g, ''))) {
      throw new Error('Define the access policy before adding the page: ' + path);
    }
  }
}
