import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { credentialFixture } from '../tests/credential_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await credentialFixture(), output = new URL('../../mobile/build/ui-preview/web-credentials/', import.meta.url);
await mkdir(output, { recursive: true });
try {
  const errors = [];
  const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, reducedMotion: 'reduce' });
  const page = await context.newPage();
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  async function captures(name) {
    for (const [width, height, large] of [[1440, 1000, false], [390, 844, false], [320, 700, true]]) {
      await page.setViewportSize({ width, height }); await page.evaluate(v => { document.documentElement.style.fontSize = v ? '200%' : '100%'; }, large);
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, name + ' overflow ' + width);
      await page.screenshot({ path: fileURLToPath(new URL(`${name}-${width}${large ? '-enlarged' : ''}.png`, output)), fullPage: true });
    }
    await page.evaluate(() => { document.documentElement.style.fontSize = '100%'; }); await page.setViewportSize({ width: 1440, height: 1000 });
  }
  await page.goto(server.origin + '/iniciar-sesion');
  await page.getByRole('link', { name: 'Crear cuenta', exact: true }).click(); await page.waitForURL('**/crear-cuenta');
  await page.getByLabel('Nombre', { exact: true }).waitFor(); await captures('registration');
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click(); await page.getByRole('alert').filter({ hasText: 'Ingresa tu nombre' }).waitFor();
  assert.equal(await page.getByLabel('Nombre', { exact: true }).getAttribute('aria-invalid'), 'true');
  await page.getByLabel('Nombre', { exact: true }).fill('Cuenta web'); await page.getByLabel('Correo', { exact: true }).fill('nuevo@example.test');
  await page.getByLabel('Contraseña', { exact: true }).fill('original-password'); await page.getByLabel('Confirmar contraseña', { exact: true }).fill('different-password');
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click(); await page.getByRole('alert').filter({ hasText: 'no coinciden' }).waitFor();
  await page.getByLabel('Confirmar contraseña', { exact: true }).fill('original-password'); await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click();
  await page.getByLabel('Código de verificación', { exact: true }).waitFor(); assert.equal(await page.getByLabel('Contraseña', { exact: true }).count(), 0);
  assert.equal(await page.getByRole('button', { name: /Reenviar código/ }).isDisabled(), true); await captures('registration-code');
  await page.reload(); await page.getByLabel('Código de verificación', { exact: true }).waitFor();
  await page.getByLabel('Código de verificación', { exact: true }).fill('000000'); await page.getByRole('button', { name: 'Verificar código', exact: true }).click();
  await page.getByRole('alert').filter({ hasText: 'no es válido' }).waitFor(); assert.equal(new URL(page.url()).pathname, '/crear-cuenta');
  await page.getByLabel('Código de verificación', { exact: true }).fill('123456'); await page.getByRole('button', { name: 'Verificar código', exact: true }).click();
  await page.waitForURL('**/bienvenida'); await page.getByRole('heading', { name: 'Cada huella importa' }).waitFor();
  assert.equal(await page.getByRole('button', { name: 'Omitir', exact: true }).count(), 0);
  await context.clearCookies(); await page.goto(server.origin + '/iniciar-sesion');
  await page.getByRole('link', { name: '¿Olvidaste tu contraseña?', exact: true }).click(); await page.waitForURL('**/recuperar-contrasena');
  await page.getByLabel('Correo', { exact: true }).waitFor(); await captures('recovery');
  await page.getByLabel('Correo', { exact: true }).fill('existente@example.test'); await page.getByRole('button', { name: 'Enviar código', exact: true }).click();
  await page.getByLabel('Código de verificación', { exact: true }).waitFor(); await captures('recovery-code');
  await page.getByLabel('Código de verificación', { exact: true }).fill('123456'); await page.getByRole('button', { name: 'Verificar código', exact: true }).click();
  await page.waitForURL('**/restablecer-contrasena'); await page.getByLabel('Nueva contraseña', { exact: true }).waitFor(); await captures('reset');
  assert.equal((await context.cookies()).some(c => c.name === 'eh_access'), false);
  assert.equal((await page.request.get(server.origin + '/api/access/session')).status(), 401);
  assert.equal((await page.request.get(server.origin + '/api/moderation/session')).status(), 401);
  await page.reload(); await page.getByLabel('Nueva contraseña', { exact: true }).waitFor();
  await page.getByLabel('Nueva contraseña', { exact: true }).fill('updated-password'); await page.getByLabel('Confirmar contraseña', { exact: true }).fill('updated-password');
  server.fail('/auth/v1/user'); await page.getByRole('button', { name: 'Guardar contraseña', exact: true }).click(); await page.getByRole('alert').filter({ hasText: 'No pudimos completar' }).waitFor();
  assert.equal(await page.getByLabel('Nueva contraseña', { exact: true }).inputValue(), 'updated-password'); server.fail('');
  await page.getByRole('button', { name: 'Guardar contraseña', exact: true }).click(); await page.getByRole('heading', { name: 'Contraseña actualizada', exact: true }).waitFor(); await captures('reset-complete');
  assert.equal((await context.cookies()).some(c => c.name === 'eh_credentials'), false);
  await page.getByRole('link', { name: 'Iniciar sesión', exact: true }).click(); await page.waitForURL('**/iniciar-sesion');
  await page.getByLabel('Correo', { exact: true }).fill('existente@example.test'); await page.getByLabel('Contraseña', { exact: true }).fill('updated-password');
  await page.getByLabel('Contraseña', { exact: true }).press('Enter'); await page.waitForURL('**/inicio'); await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
  await context.clearCookies(); await page.goto(server.origin + '/restablecer-contrasena'); await page.waitForURL(/\/recuperar-contrasena/); assert.equal(await page.getByLabel('Nueva contraseña', { exact: true }).count(), 0);
  await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
  await page.evaluate(() => {
    window.resetFieldsMounted = false;
    new MutationObserver(() => { if ([...document.querySelectorAll('.login-field-label')].some(e => e.textContent === 'Nueva contraseña')) window.resetFieldsMounted = true; }).observe(document.body, { childList: true, subtree: true });
    return document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push('/restablecer-contrasena');
  });
  assert.equal(new URL(page.url()).pathname, '/recuperar-contrasena'); assert.equal(await page.evaluate(() => window.resetFieldsMounted), false);
  await page.goto(server.origin + '/crear-cuenta'); await page.getByLabel('Nombre', { exact: true }).waitFor();
  let release; await page.route('**/api/access/credentials/register', async route => { await new Promise(r => { release = r; }); await route.continue(); });
  await page.getByLabel('Nombre', { exact: true }).fill('Cuenta en espera'); await page.getByLabel('Correo', { exact: true }).fill('otro@example.test');
  await page.getByLabel('Contraseña', { exact: true }).fill('original-password'); await page.getByLabel('Confirmar contraseña', { exact: true }).fill('original-password');
  await page.getByRole('button', { name: 'Crear cuenta', exact: true }).click(); await page.waitForFunction(() => document.querySelector('.login-submit')?.getAttribute('aria-busy') === 'true');
  assert.equal(await page.locator('.login-submit').isDisabled(), true); assert.match(await page.locator('.login-submit').getAttribute('class'), /working/);
  release(); await page.getByLabel('Código de verificación', { exact: true }).waitFor(); await page.unroute('**/api/access/credentials/register');
  await page.getByRole('button', { name: 'Usar otro correo', exact: true }).click(); await page.getByLabel('Nombre', { exact: true }).waitFor();
  assert.equal((await context.cookies()).some(c => c.name === 'eh_credentials'), false);
  assert.deepEqual(errors, []);
  console.log('Credentials Chrome QA passed: registration/code/reload/onboarding, recovery/reset/retry/new login, no normal recovery access, protected direct reset, cancellation, double-submit lock/shimmer, 1440/390/320/text200%, no overflow/CSP/hydration errors. Fixture only.');
} finally { await browser.close(); await server.close(); }
