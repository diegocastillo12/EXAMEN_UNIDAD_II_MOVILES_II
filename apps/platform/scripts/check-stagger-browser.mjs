// Regression for the shared entrance: inspect real animation frames, not only its final state.
import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { moderationFixture, ordinary } from '../tests/moderation_fixture.mjs';
import { productionFixture } from '../tests/server_fixture.mjs';
import { slug } from '../tests/fixtures.mjs';
const runtime = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href), { chromium } = runtime.default || runtime;
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await moderationFixture(), qr = await productionFixture();
const output = new URL('../../mobile/build/ui-preview/shared-stagger/', import.meta.url);
await mkdir(output, { recursive: true });
let releaseManagement;
let managementGate = new Promise(resolve => { releaseManagement = resolve; });
try {
  server.setOnboarding(ordinary, true);
  const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, reducedMotion: 'no-preference' });
  const page = await context.newPage(), errors = [];
  await page.route('**/api/access/management', async route => { await managementGate; await route.continue(); });
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  await page.addInitScript(() => {
    window.revealFrames = [];
    const frame = () => {
      const group = document.querySelector('.account-grid.stagger-reveal-group');
      if (group && window.revealFrames.length < 1500) {
        window.revealFrames.push({
          before: getComputedStyle(group, '::before').content,
          opacity: [...group.children].map(e => Number(getComputedStyle(e).opacity)),
          delay: [...group.children].map(e => getComputedStyle(e).transitionDelay),
          placeholders: document.querySelectorAll('.account-main .skeleton, .account-grid .shape, .account-management-skeleton').length,
        });
      }
      requestAnimationFrame(frame);
    };
    requestAnimationFrame(frame);
  });
  await page.goto(server.origin + '/iniciar-sesion');
  await page.getByLabel('Correo', { exact: true }).fill('ordinario@example.test');
  await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password');
  await page.locator('.login-form button[type=submit]').click();
  await page.waitForURL('**/inicio');
  try { await page.waitForFunction(() => window.revealFrames.some(f => f.opacity.length && f.opacity.every(v => v === 1))); }
  catch (error) { console.error(JSON.stringify(await page.locator('.account-grid').evaluate(el => ({ html: el.outerHTML.slice(0, 1800), frames: window.revealFrames.slice(-3), count: window.revealFrames.length, actual: [...el.children].map(e => getComputedStyle(e).opacity) }))), errors); throw error; }
  const frames = await page.evaluate(() => window.revealFrames);
  assert.ok(frames.some(f => f.opacity.some(v => v > 0 && v < 1)), 'Must observe actual transition frames');
  assert.ok(frames.every(f => ['none', 'normal'].includes(f.before)), 'No opaque pseudo-element at any entrance frame');
  assert.ok(frames.every(f => f.placeholders === 0), 'No grey permission placeholder at any entrance frame');
  assert.ok(frames.some(f => f.delay[0].split(',')[0].trim() === '0s' && f.delay[1].split(',')[0].trim() === '0.035s'), 'Fast shared stagger ordering');
  assert.equal(await page.locator('.reveal').count(), 0);
  async function noPermissionPlaceholder() {
    assert.equal(await page.locator('.account-main .skeleton, .account-grid .shape, .account-management-skeleton').count(), 0, 'No grey permission placeholder while the real account is visible');
    assert.equal(await page.locator('.account-grid').getAttribute('aria-busy'), 'true');
    assert.equal(await page.locator('.account-grid > *').count(), 4, 'Home content remains visible while permissions are pending');
    assert.equal(await page.getByRole('link', { name: 'Revisar denuncias', exact: true }).count(), 0, 'No permission assumed during lookup');
  }
  await noPermissionPlaceholder();
  await page.screenshot({ path: fileURLToPath(new URL('management-pending.png', output)), fullPage: true });
  releaseManagement();
  await page.waitForFunction(() => document.querySelector('.account-grid')?.getAttribute('aria-busy') === 'false');
  managementGate = new Promise(resolve => { releaseManagement = resolve; });
  await page.reload();
  await page.waitForFunction(() => document.querySelector('.account-grid')?.getAttribute('aria-busy') === 'true');
  await noPermissionPlaceholder();
  await page.waitForFunction(() => [...document.querySelector('.account-grid').children].every(e => getComputedStyle(e).opacity === '1'));
  assert.equal(await page.evaluate(() => window.revealFrames.every(f => f.placeholders === 0)), true, 'Hard reload never mounts a grey permission panel');
  await page.screenshot({ path: fileURLToPath(new URL('reload-management-pending.png', output)), fullPage: true });
  await page.setViewportSize({ width: 320, height: 700 });
  await page.evaluate(() => { document.documentElement.style.fontSize = '200%'; });
  await noPermissionPlaceholder();
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
  await page.evaluate(() => { document.documentElement.style.fontSize = '100%'; });
  await page.setViewportSize({ width: 1440, height: 1000 });
  releaseManagement();
  await page.waitForFunction(() => document.querySelector('.account-grid')?.getAttribute('aria-busy') === 'false');
  assert.equal(await page.locator('.account-grid').evaluate(el => [...el.children].every(e => getComputedStyle(e).opacity === '1')), true, 'Permission completion never hides the existing cards');
  await page.screenshot({ path: fileURLToPath(new URL('home.png', output)), fullPage: true });
  await page.setViewportSize({ width: 320, height: 700 });
  await page.evaluate(() => { document.documentElement.style.fontSize = '200%'; });
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
  assert.equal(await page.locator('.account-grid').evaluate(el => [...el.children].every(e => getComputedStyle(e).opacity === '1')), true, 'Resize does not replay entrance');
  await page.emulateMedia({ reducedMotion: 'reduce' });
  await page.reload();
  await page.getByRole('heading', { name: 'Su regreso empieza contigo', exact: true }).waitFor();
  assert.equal(await page.locator('.account-grid').evaluate(el => [...el.children].every(e => getComputedStyle(e).opacity === '1' && getComputedStyle(e).transitionDuration === '0s')), true);
  await context.close();
  const noJs = await browser.newContext({ javaScriptEnabled: false });
  const plain = await noJs.newPage();
  for (const state of ['active', 'unavailable']) {
    if (state === 'unavailable') qr.set({ state });
    await plain.goto(qr.origin + '/c/' + slug);
    const content = plain.locator('.stagger-reveal-group');
    await content.waitFor();
    assert.equal(await content.evaluate(el => [...el.children].every(e => getComputedStyle(e).opacity === '1' && getComputedStyle(e).filter === 'none')), true, 'Public QR readable without JavaScript: ' + state);
    assert.equal(await plain.locator('h1').isVisible(), true);
  }
  await noJs.close();
  assert.deepEqual(errors, []);
  console.log('Shared reveal passed: real home animation frames, no cover, stagger timing, login and hard reload with delayed permissions and no grey placeholder, resize/text200%, reduced motion, QR SSR without JS.');
} finally { releaseManagement(); await browser.close(); await server.close(); await qr.close(); }
