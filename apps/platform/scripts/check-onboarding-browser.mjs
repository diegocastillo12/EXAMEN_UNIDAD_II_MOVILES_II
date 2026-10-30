import assert from 'node:assert/strict';
import { mkdir, readFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { moderationFixture, ordinary } from '../tests/moderation_fixture.mjs';
const runtime = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href), { chromium } = runtime.default || runtime;
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await moderationFixture(), output = new URL('../../mobile/build/ui-preview/web-onboarding/', import.meta.url);
await mkdir(output, { recursive: true });
try {
 for (const name of ['dog_waving.png', 'dog_with_map.png', 'dog_and_cat.png']) {
  const mobile = await readFile(new URL('../../mobile/assets/onboarding/' + name, import.meta.url));
  const web = await readFile(new URL('../public/images/onboarding/' + name, import.meta.url));
  assert.ok(mobile.equals(web), name + ' differs from mobile');
 }
 server.setOnboarding(ordinary, false);
 const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, reducedMotion: 'no-preference' });
 const page = await context.newPage(), errors = [];
 page.on('pageerror', e => errors.push(e.message));
 page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
 await page.goto(server.origin + '/iniciar-sesion');
 await page.getByLabel('Correo', { exact: true }).fill('ordinario@example.test');
 await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password');
 await page.locator('.login-form button[type=submit]').click();
 await page.waitForURL('**/bienvenida');
 const heading = page.locator('.onboarding-step-title'), image = page.locator('.onboarding-illustration img');
 async function settled(title) {
  await page.getByRole('heading', { name: title, exact: true }).waitFor();
  await page.waitForFunction(() => [...document.querySelectorAll('.onboarding-flow .stagger-reveal-item')].every(el => getComputedStyle(el).opacity === '1'));
  await page.waitForFunction(() => document.querySelector('.onboarding-illustration img')?.naturalWidth > 0);
  await page.locator('.onboarding-next:not(:disabled)').waitFor();
 }
 await settled('Cada huella importa');
 await page.evaluate(() => document.fonts.ready);
 assert.equal(await page.locator('.onboarding-flow').evaluate(el => getComputedStyle(el).fontFamily.includes('Inter')), true);
 assert.equal(await page.evaluate(() => document.fonts.check('16px "Inter"')), true);
 assert.equal(await heading.evaluate(el => getComputedStyle(el).fontSize), '32px');
 assert.equal(await heading.evaluate(el => getComputedStyle(el).fontWeight), '400');
 assert.equal(await page.locator('.onboarding-step-description').evaluate(el => getComputedStyle(el).fontSize), '18px');
 assert.equal(await page.locator('.onboarding-next').evaluate(el => getComputedStyle(el).borderRadius), '18px');
 assert.equal(await page.locator('.onboarding-next').evaluate(el => getComputedStyle(el).height), '48px');
 assert.equal(await page.locator('.onboarding-flow').evaluate(el => getComputedStyle(el).maxWidth), '448px');
 assert.equal((await image.boundingBox()).width, 448, 'Illustration fills the desktop column');
 assert.equal(await page.locator('.onboarding-flow .reveal').count(), 0);
 const brandPosition = await page.locator('.onboarding-brand').boundingBox();
 assert.ok(brandPosition.y >= 0 && brandPosition.y <= 20, 'Desktop brand must be at page top');
 assert.ok(brandPosition.x < 100, 'Desktop brand must align with page edge, outside centered steps');
 assert.equal(await page.locator('.account-header,.account-footer').count(), 0);
 assert.equal(await page.getByRole('button', { name: 'Omitir', exact: true }).count(), 0);
 const entry = await heading.evaluate(el => { const c = getComputedStyle(el); return [c.transitionDuration, c.transitionDelay, c.willChange]; });
 assert.match(entry[0], /0.55s/); assert.equal(entry[1], '0.09s'); assert.equal(entry[2], 'opacity, filter, transform');
 await page.screenshot({ path: fileURLToPath(new URL('desktop-step-1.png', output)), fullPage: true });
 await page.getByRole('button', { name: 'Continuar', exact: true }).click();
 assert.equal(await page.getByRole('button', { name: 'Continuar', exact: true }).isDisabled(), true);
 await page.waitForFunction(() => getComputedStyle(document.querySelector('.onboarding-illustration')).transitionDelay === '0.27s');
 assert.equal((await heading.innerText()).replace(/\s+/g, ' '), 'Cada huella importa');
 assert.equal(await page.locator('.onboarding-step-actions').evaluate(el => getComputedStyle(el).transitionDelay), '0s');
 assert.equal(await page.locator('.onboarding-flow').evaluate(el => getComputedStyle(el, '::before').content), 'none');
 await page.getByRole('button', { name: 'Continuar', exact: true }).dispatchEvent('click');
 await page.screenshot({ path: fileURLToPath(new URL('during-exit.png', output)), fullPage: true });
 await settled('Volvamos a casa');
 assert.match(await image.getAttribute('src'), /dog_with_map.png$/);
 assert.equal(await page.getByRole('status', { name: 'Paso 2 de 3' }).count(), 1);
 assert.equal(await page.getByRole('button', { name: 'Anterior', exact: true }).count(), 0);
 assert.equal(await page.locator('.onboarding-indicators').count(), 0);
 assert.equal(await page.locator('.onboarding-brand').innerText(), 'entre huellas');
 assert.equal(await page.locator('.onboarding-brand img').getAttribute('src'), '/brand.png');
 assert.equal(await page.locator('.onboarding-brand').evaluate(el => el.getAnimations().length), 0);
 assert.equal((await page.locator('.onboarding-brand').boundingBox()).y, brandPosition.y);
 assert.equal(await page.locator('.onboarding-content .onboarding-brand').count(), 0);
 for (const [name, width, height, enlarged] of [['mobile', 390, 844, false], ['short', 320, 350, false], ['small-text', 320, 700, true]]) {
  await page.setViewportSize({ width, height }); await page.evaluate(v => { document.documentElement.style.fontSize = v ? '200%' : '100%'; }, enlarged);
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, name + ' overflow');
  assert.equal(Math.round((await image.boundingBox()).width), Math.round((await page.locator('.onboarding-flow').boundingBox()).width), name + ' illustration fills available width');
  const skip = page.locator('.skip-link');
  assert.ok(await skip.evaluate(el => el.getBoundingClientRect().bottom < 0), name + ' unfocused skip link must remain outside viewport');
  await skip.focus(); assert.ok(await skip.evaluate(el => el.getBoundingClientRect().top >= 0));
  await heading.focus();
  assert.ok(await skip.evaluate(el => el.getBoundingClientRect().bottom < 0));
  await page.getByRole('button', { name: 'Continuar', exact: true }).scrollIntoViewIfNeeded();
  // Capture from the page origin: Chrome full-page capture can retain a fixed
  // focus layer at the previous scroll offset after the keyboard-focus check.
  await page.evaluate(() => scrollTo(0, 0));
  const brand = await page.locator('.onboarding-brand').boundingBox();
  assert.ok(brand.y >= 0 && brand.y <= 20, name + ' brand must match the landing header');
  assert.ok(brand.x <= 24, name + ' brand must align with page edge');
  await page.screenshot({ path: fileURLToPath(new URL(name + '-step-2.png', output)), fullPage: true });
 }
 await page.evaluate(() => { document.documentElement.style.fontSize = '100%'; }); await page.setViewportSize({ width: 1440, height: 1000 });
 await page.getByRole('button', { name: 'Continuar', exact: true }).click(); await settled('Una nueva historia');
 assert.match(await image.getAttribute('src'), /dog_and_cat.png$/);
 let release; const responseReady = new Promise(resolve => { release = resolve; });
 await page.route('**/api/access/onboarding', async route => { await responseReady; await route.fulfill({ status: 503, contentType: 'application/json', body: '{"error":"unavailable"}' }); });
 await page.getByRole('button', { name: 'Comenzar', exact: true }).click();
 await page.waitForFunction(() => document.querySelector('.onboarding-next').getAttribute('aria-busy') === 'true');
 assert.equal(await heading.evaluate(el => getComputedStyle(el).opacity), '1');
 assert.equal(await page.locator('.onboarding-next.working').count(), 1);
 assert.equal(await page.getByRole('button', { name: 'Comenzar', exact: true }).isDisabled(), true);
 await page.screenshot({ path: fileURLToPath(new URL('saving-step-3.png', output)), fullPage: true });
 release(); await page.getByRole('alert').filter({ hasText: 'No pudimos completar' }).waitFor();
 await settled('Una nueva historia'); assert.equal(new URL(page.url()).pathname, '/bienvenida');
 await page.unroute('**/api/access/onboarding'); await page.getByRole('button', { name: 'Comenzar', exact: true }).click();
 await page.waitForURL('**/inicio'); assert.equal(server.completions(), 1);
 // Motion preference can change during an exit; settle immediately, without replay or stale timers.
 server.setOnboarding(ordinary, false); await page.goto(server.origin + '/bienvenida'); await settled('Cada huella importa');
 await page.getByRole('button', { name: 'Continuar', exact: true }).click();
 await page.waitForFunction(() => getComputedStyle(document.querySelector('.onboarding-illustration')).transitionDelay === '0.27s');
 await page.emulateMedia({ reducedMotion: 'reduce' }); await settled('Volvamos a casa');
 assert.equal(await heading.evaluate(el => getComputedStyle(el).transitionDuration), '0s');
 assert.equal(await heading.evaluate(el => getComputedStyle(el).transform), 'none');
 await page.reload(); await settled('Cada huella importa');
 await page.emulateMedia({ reducedMotion: 'no-preference' });
 await page.getByRole('button', { name: 'Continuar', exact: true }).click();
 await page.waitForFunction(() => getComputedStyle(document.querySelector('.onboarding-illustration')).transitionDelay === '0.27s');
 await page.goto(server.origin + '/'); await page.waitForTimeout(1300);
 assert.equal(new URL(page.url()).pathname, '/'); assert.deepEqual(errors, []);
 await context.close();
 console.log('Onboarding Chrome QA passed: Sader layout/Inter body/Poppins primary title/buttons, identical mobile PNGs, real 550ms/90ms stagger and reversed exit, no cream cover, forward-only steps, persistent official brand, no dots/back button, double-click lock, step3 visible save/error/retry, reduced motion (including mid-exit), teardown timers, desktop/mobile/320x350/text200%, no overflow/CSP/hydration errors. Fixture backend only.');
} finally { await browser.close(); await server.close(); }

