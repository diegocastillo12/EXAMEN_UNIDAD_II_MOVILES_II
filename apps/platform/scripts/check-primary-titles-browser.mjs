// Local fixture QA. No production data or accounts.
import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { moderationFixture, ordinary, moderator } from '../tests/moderation_fixture.mjs';
import { slug } from '../tests/fixtures.mjs';

const runtime = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const { chromium } = runtime.default || runtime;
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await moderationFixture();
const output = new URL('../../mobile/build/ui-preview/primary-titles/web/', import.meta.url);
await mkdir(output, { recursive: true });
const errors = [];
let checked = 0;
try {
  const context = await browser.newContext({ reducedMotion: 'reduce' });
  const page = await context.newPage();
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => {
    if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(message.text())) errors.push(message.text());
  });
  async function check(name) {
    const heading = page.locator('h1').first();
    await heading.waitFor();
    for (const [suffix, width, height, enlarged] of [
      ['desktop', 1440, 1000, false], ['mobile', 390, 844, false], ['small-text', 320, 700, true],
    ]) {
      await page.setViewportSize({ width, height });
      await page.evaluate(value => { document.documentElement.style.fontSize = value ? '200%' : '100%'; }, enlarged);
      await page.evaluate(() => document.fonts.ready);
      const style = await heading.evaluate(el => {
        const css = getComputedStyle(el);
        return { family: css.fontFamily, weight: css.fontWeight, size: css.fontSize, color: css.color, height: css.lineHeight };
      });
      assert.match(style.family, /Poppins/, name);
      assert.equal(style.weight, '400', name);
      assert.equal(style.size, enlarged ? '64px' : '32px', name);
      assert.equal(style.color, 'rgb(69, 71, 70)', name);
      assert.equal(style.height, enlarged ? '80px' : '40px', name);
      assert.equal(await page.evaluate(() => document.fonts.check('400 32px Poppins')), true, name);
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, name + ' overflow');
      await heading.scrollIntoViewIfNeeded();
      await page.screenshot({ path: fileURLToPath(new URL(name + '-' + suffix + '.png', output)) });
      checked++;
    }
    await page.evaluate(() => { document.documentElement.style.fontSize = '100%'; });
  }
  for (const [name, path] of [
    ['landing', '/'], ['login', '/iniciar-sesion'], ['register', '/crear-cuenta'],
    ['recover', '/recuperar-contrasena'], ['terms', '/terminos'], ['privacy', '/privacidad'], ['qr', '/c/' + slug],
  ]) {
    await page.goto(server.origin + path, { waitUntil: 'networkidle' });
    await check(name);
  }
  async function login(email, destination) {
    await page.goto(server.origin + '/iniciar-sesion');
    await page.getByLabel('Correo', { exact: true }).fill(email);
    await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password');
    await page.locator('.login-form button[type=submit]').click();
    await page.waitForURL('**/' + destination);
  }
  server.setOnboarding(ordinary, false);
  await login('usuario@example.test', 'bienvenida');
  await check('onboarding');
  server.setOnboarding(ordinary, true);
  await page.goto(server.origin + '/inicio', { waitUntil: 'networkidle' });
  await check('account');
  await context.clearCookies();
  server.setOnboarding(moderator, true);
  await login('moderador@example.test', 'inicio');
  await page.goto(server.origin + '/moderacion', { waitUntil: 'networkidle' });
  await check('moderation');
  const noScript = await browser.newContext({ javaScriptEnabled: false, viewport: { width: 390, height: 844 } });
  const ssr = await noScript.newPage();
  await ssr.goto(server.origin + '/c/' + slug, { waitUntil: 'networkidle' });
  assert.equal(await ssr.locator('h1').evaluate(el => getComputedStyle(el).fontFamily.includes('Poppins')), true);
  assert.equal(await ssr.locator('h1').evaluate(el => getComputedStyle(el).fontSize), '32px');
  await noScript.close();
  assert.deepEqual(errors, []);
  console.log(`Primary title QA passed: ${checked} layouts; local Poppins400/32/#454746, text200%, QR without JS, no overflow/CSP/hydration errors.`);
} finally {
  await browser.close();
  await server.close();
}
