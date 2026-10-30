import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { moderationFixture, ordinary } from '../tests/moderation_fixture.mjs';
const runtime = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href), { chromium } = runtime.default || runtime;
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await moderationFixture(), output = new URL('../../mobile/build/ui-preview/web-access/', import.meta.url);
await mkdir(output, { recursive: true });
try {
 const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, reducedMotion: 'reduce' }), page = await context.newPage(), errors = [];
 function observe(p) {
  p.on('pageerror', e => errors.push(e.message));
  p.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
 }
 observe(page);
 const html = await (await fetch(server.origin + '/iniciar-sesion')).text();
 assert.match(html, /Inicia sesión/); assert.match(html, /Continúa con Google/); assert.match(html, /Continúa con Facebook/);
 assert.doesNotMatch(html, /PRIVATE_REPORT_REASON|test-fixture-password|Comprobando acceso/);
 await page.goto(server.origin + '/'); await page.getByRole('link', { name: 'Iniciar sesión', exact: true }).click(); await page.waitForURL('**/iniciar-sesion');
 assert.match(await page.locator('.login-screen').evaluate(el => getComputedStyle(el).fontFamily), /Arial/);
 await page.getByLabel('Contraseña', { exact: true }).fill('visibility-check');
 await page.getByRole('button', { name: 'Mostrar contraseña', exact: true }).click(); assert.equal(await page.getByLabel('Contraseña', { exact: true }).getAttribute('type'), 'text');
 await page.getByRole('button', { name: 'Ocultar contraseña', exact: true }).click(); assert.equal(await page.getByLabel('Contraseña', { exact: true }).getAttribute('type'), 'password');
 await page.getByLabel('Contraseña', { exact: true }).fill('');
 await page.locator('.login-form button[type=submit]').click(); await page.getByRole('alert').filter({ hasText: 'Revisa el correo' }).waitFor();
 assert.equal(await page.getByLabel('Correo', { exact: true }).getAttribute('aria-invalid'), 'true');
 async function captures(name) {
  for (const [suffix, width, height, enlarged] of [['desktop', 1440, 1000, false], ['wide', 1920, 1000, false], ['reference', 731, 1000, false], ['mobile', 390, 844, false], ['small-text', 320, 700, true]]) {
   await page.setViewportSize({ width, height }); await page.evaluate(v => { document.documentElement.style.fontSize = v ? '200%' : '100%'; }, enlarged);
   assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, name + '-' + suffix + ' overflow');
   await page.screenshot({ path: fileURLToPath(new URL(name + '-' + suffix + '.png', output)), fullPage: true });
  }
  await page.evaluate(() => { document.documentElement.style.fontSize = '100%'; }); await page.setViewportSize({ width: 1440, height: 1000 });
 }
 async function login(email) {
  await page.getByLabel('Correo', { exact: true }).fill(email); await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password'); await page.getByLabel('Contraseña', { exact: true }).press('Enter');
 }
 async function signout() {
  await page.getByRole('button', { name: 'Cerrar sesión', exact: true }).click(); await page.waitForURL('**/iniciar-sesion');
 }
 await captures('login');
 server.setOnboarding(ordinary, false);
 await login('ordinario@example.test'); await page.waitForURL('**/bienvenida'); await page.getByRole('heading', { name: 'Cada huella importa' }).waitFor();
 assert.equal(await page.getByRole('button', { name: 'Omitir', exact: true }).count(), 0);
 await captures('onboarding');
 await page.getByRole('button', { name: 'Continuar', exact: true }).click(); await page.getByRole('heading', { name: 'Volvamos a casa' }).waitFor();
 assert.equal(await page.getByRole('button', { name: 'Anterior', exact: true }).count(), 0);
 assert.equal(await page.locator('.onboarding-indicators').count(), 0);
 await page.getByRole('button', { name: 'Continuar', exact: true }).click();
 await page.route('**/api/access/onboarding', r => r.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"unavailable"}' }));
 await page.getByRole('button', { name: 'Comenzar', exact: true }).click(); await page.getByRole('alert').filter({ hasText: 'No pudimos completar' }).waitFor();
 assert.equal(new URL(page.url()).pathname, '/bienvenida'); await page.getByRole('heading', { name: 'Una nueva historia' }).waitFor();
 await page.unroute('**/api/access/onboarding'); await page.getByRole('button', { name: 'Comenzar', exact: true }).click(); await page.waitForURL('**/inicio');
 await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor(); assert.equal(server.completions(), 1);
 assert.equal(await page.getByRole('link', { name: 'Revisar denuncias', exact: true }).count(), 0);
 await captures('ordinary-home');
 await page.goto(server.origin + '/moderacion'); await page.waitForURL('**/inicio'); await page.getByRole('alert').filter({ hasText: 'no tiene permiso' }).waitFor();
 await page.goto(server.origin + '/login?next=https://untrusted.example'); await page.waitForURL('**/inicio'); // Fixed destination, not an open redirect.
 const other = await context.newPage(); observe(other); await other.goto(server.origin + '/inicio'); await other.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
 await signout(); await other.waitForURL('**/iniciar-sesion'); assert.equal(await other.getByText('ordinario@example.test', { exact: true }).count(), 0);
 await page.goto(server.origin + '/moderacion'); await page.waitForURL('**/iniciar-sesion');
 await login('moderador@example.test'); await page.waitForURL('**/inicio'); await page.getByRole('link', { name: 'Revisar denuncias', exact: true }).waitFor();
 await captures('reviewer-home');
 await page.route('**/api/access/management', r => r.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"unavailable"}' }));
 await page.reload(); await page.getByRole('button', { name: 'Reintentar acceso a gestión', exact: true }).waitFor();
 await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
 await page.unroute('**/api/access/management'); await page.getByRole('button', { name: 'Reintentar acceso a gestión', exact: true }).click();
 await page.getByRole('link', { name: 'Revisar denuncias', exact: true }).click(); await page.waitForURL('**/moderacion'); await page.getByRole('button', { name: 'Revisar denuncia', exact: true }).waitFor();
 server.revoke(true); await page.reload(); await page.waitForURL('**/inicio'); await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
 assert.equal(await page.getByRole('link', { name: 'Revisar denuncias', exact: true }).count(), 0); server.revoke(false);
 await page.route('**/api/access/session', r => r.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"unavailable"}' }));
 await page.reload(); await page.getByRole('button', { name: 'Reintentar conexión', exact: true }).waitFor(); assert.equal(await page.getByText('moderador@example.test', { exact: true }).count(), 0);
 await page.unroute('**/api/access/session'); await page.getByRole('button', { name: 'Reintentar conexión', exact: true }).click(); await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
 let expiresAt;
 await page.route('**/api/access/session', async route => {
  expiresAt ??= Date.now() + 1000;
  if (Date.now() >= expiresAt) return route.fulfill({ status: 401, contentType: 'application/json', body: '{"error":"unauthenticated"}' });
  const response = await route.fetch(), body = await response.json(); await route.fulfill({ response, json: { ...body, expiresAt } });
 });
 await page.reload(); await page.waitForURL('**/iniciar-sesion'); await page.getByRole('alert').filter({ hasText: 'La sesión expiró' }).waitFor();
 await page.unroute('**/api/access/session'); await context.clearCookies(); await other.close();
 for (const provider of ['Google', 'Facebook']) {
  server.oauthDenied(provider === 'Facebook');
  await page.goto(server.origin + '/iniciar-sesion'); await page.getByRole('button', { name: 'Continúa con ' + provider, exact: true }).click(); await page.waitForURL('**/inicio');
  await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor(); await signout();
 }
 assert.deepEqual(errors, []); await context.close();
 console.log('General access Chrome QA passed: landing/login/legal routes, validation/password visibility, ordinary/reviewer accounts, three-step persistent onboarding/retry, role revocation, cross-tab logout, expiry, connection/permission retry, fixed redirects, Google/Facebook PKCE fixtures, 1920/1440/731/390/320/text200%, no overflow/CSP/hydration errors. Fixture backend only.');
} finally { await browser.close(); await server.close(); }

