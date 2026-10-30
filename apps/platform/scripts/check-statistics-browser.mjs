import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { statisticsFixture } from '../tests/statistics_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true }), server = await statisticsFixture();
const output = new URL('../../mobile/build/ui-preview/web-statistics/', import.meta.url); await mkdir(output, { recursive: true });
try {
 const context = await browser.newContext({ viewport: { width: 1440, height: 1000 } }), page = await context.newPage(), errors = [];
 page.setDefaultTimeout(15000); page.on('pageerror', e => errors.push(e.message));
 page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
 await page.goto(server.origin + '/administracion/estadisticas'); await page.waitForURL('**/iniciar-sesion*');
 await page.getByLabel('Correo', { exact: true }).fill('administrador@example.test'); await page.getByLabel('Contraseña', { exact: true }).fill('test-fixture-password'); await page.getByLabel('Contraseña', { exact: true }).press('Enter'); await page.waitForURL('**/inicio');
 for (const motionWidth of [1440, 390, 320]) {
 await page.setViewportSize({ width: motionWidth, height: 1000 });
 const trigger = page.getByRole('link', { name: 'Ver estadísticas', exact: true }); await trigger.waitFor(); await trigger.scrollIntoViewIfNeeded(); await page.waitForTimeout(350);
 const source = await trigger.boundingBox();
 await page.evaluate(() => {
  window.statisticsMotionObserver = new MutationObserver(() => {
   const target = document.querySelector('[data-origin-animating]');
   if (target?._flip && !target._flip.__qaPaused) { target._flip.__qaPaused = true; target._flip.pause().progress(0); }
  });
  window.statisticsMotionObserver.observe(document.documentElement, { subtree: true, attributes: true, attributeFilter: ['data-origin-animating'] });
 });
 await trigger.click(); await page.waitForURL('**/administracion/estadisticas');
 await page.waitForFunction(() => document.querySelector('main[data-origin-animating="opening"]')?._flip?.paused());
 const surface = page.locator('main[data-origin-content]:not([data-origin-underlay] *)');
 const initial = await surface.evaluate(node => { const r = node.getBoundingClientRect(); return { x: r.x, y: r.y, width: r.width, height: r.height, duration: node._flip.duration() }; });
 for (const key of ['x', 'y', 'width', 'height']) assert.ok(Math.abs(initial[key] - source[key]) < 1, key + ' starts at the control');
 assert.equal(initial.duration, .7);
 const frames = [];
 for (const progress of [0, .05, .15, .45, .99]) {
  await surface.evaluate((node, value) => { node._flip.progress(value); for (const a of node.getAnimations({ subtree: true })) { a.pause(); a.currentTime = value * 700; } }, progress);
  frames.push(await surface.evaluate(node => { const r = node.getBoundingClientRect(); return { phase: node.dataset.originAnimating, x: r.x, y: r.y, width: r.width, height: r.height, inert: node.inert }; }));
  if (progress === .99) { const box = await surface.boundingBox(); assert.ok(Math.abs(box.x) < 3 && Math.abs(box.y) < 3 && Math.abs(box.width - motionWidth) < 3 && Math.abs(box.height - 1000) < 3, 'The morph reaches the entire viewport'); }
  await page.screenshot({ path: fileURLToPath(new URL(`${motionWidth}-opening-${progress}.png`, output)) });
 }
 await surface.evaluate(node => { node._flip.progress(1); for (const a of node.getAnimations({ subtree: true })) a.finish(); });
 await page.getByRole('heading', { name: 'Cómo leer estos datos' }).waitFor(); await page.waitForTimeout(350);
 const full = await surface.boundingBox();
 await page.screenshot({ path: fileURLToPath(new URL(`${motionWidth}-opening-1.png`, output)) });
 // Close the mounted surface before the route changes, preserving the source.
 const closing = page.getByRole('button', { name: 'Volver a inicio', exact: true }).click();
 await page.waitForFunction(() => document.querySelector('main[data-origin-animating="closing"]')?._flip?.paused());
 for (const progress of [.5, .75, .95]) {
  await surface.evaluate((node, value) => { node._flip.progress(value); for (const a of node.getAnimations({ subtree: true })) { a.pause(); a.currentTime = value * 700; } }, progress);
  await page.screenshot({ path: fileURLToPath(new URL(`${motionWidth}-closing-${progress}.png`, output)) });
 }
 await surface.evaluate(node => { node._flip.progress(1); for (const a of node.getAnimations({ subtree: true })) a.finish(); });
 await closing; await page.waitForURL('**/inicio'); await page.getByRole('link', { name: 'Ver estadísticas', exact: true }).waitFor();
 await page.evaluate(() => window.statisticsMotionObserver.disconnect());
 await writeFile(new URL(`${motionWidth}-motion-frames.json`, output), JSON.stringify({ initial, frames, full }, null, 2));
 }
 await page.goto(server.origin + '/administracion/estadisticas'); await page.getByRole('heading', { name: 'Cómo leer estos datos' }).waitFor();
 for (const [width, scale] of [[1920, '100%'], [1440, '100%'], [731, '100%'], [390, '100%'], [320, '100%'], [320, '200%']]) {
  await page.setViewportSize({ width, height: 1000 }); await page.evaluate(s => document.documentElement.style.fontSize = s, scale); await page.evaluate(() => document.fonts.ready); await page.waitForTimeout(150);
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= document.documentElement.clientWidth), true, `overflow at ${width}/${scale}`);
  await page.screenshot({ path: fileURLToPath(new URL(`${width}-${scale.replace('%', '')}.png`, output)), fullPage: true });
 }
 await page.evaluate(() => document.documentElement.style.fontSize = '100%'); await page.setViewportSize({ width: 390, height: 844 });
 await page.getByRole('button', { name: 'Desde', exact: true }).focus(); await page.keyboard.press('ArrowDown'); await page.getByRole('dialog', { name: 'Desde', exact: true }).waitFor(); await page.keyboard.press('Escape'); await page.getByRole('dialog').waitFor({ state: 'hidden' });
 assert.equal(await page.getByRole('button', { name: 'Desde', exact: true }).evaluate(node => node === document.activeElement), true);
 const release = server.pause(); const before = server.calls(); await page.getByRole('button', { name: 'Consultar', exact: true }).click(); await page.waitForTimeout(100);
 assert.equal(await page.locator('.statistics-card').count(), 7); assert.equal(await page.getByRole('button', { name: 'Consultar', exact: true }).isDisabled(), true); release(); await page.waitForFunction(() => !document.querySelector('.statistics-results')?.getAttribute('aria-busy')?.includes('true')); assert.equal(server.calls(), before + 1);
 server.fail(true); await page.getByRole('button', { name: 'Consultar', exact: true }).click(); await page.getByRole('alert').waitFor(); assert.equal(await page.locator('.statistics-card').count(), 7);
 server.fail(false); server.empty(true); await page.getByRole('button', { name: 'Consultar', exact: true }).click(); await page.getByText('No se registró actividad en este período.', { exact: true }).waitFor();
 await page.emulateMedia({ reducedMotion: 'reduce' }); await page.goto(server.origin + '/inicio'); await page.getByRole('link', { name: 'Ver estadísticas', exact: true }).click(); await page.getByRole('heading', { name: 'Cómo leer estos datos' }).waitFor();
 assert.equal(await page.locator('[data-origin-animating]').count(), 0);
 server.revokeStatistics(true); await page.getByRole('button', { name: 'Consultar', exact: true }).click(); await page.waitForURL('**/inicio?reason=forbidden'); assert.equal(await page.locator('.statistics-card').count(), 0);
 assert.deepEqual(errors, []);
 console.log(JSON.stringify({ pass: true, checks: ['admin entry', 'normal origin open/close frames', 'reduced motion', '1920/1440/731/390/320 and text200', 'retained refresh/failure', 'empty', 'revoked access', 'no CSP/hydration errors'], screenshots: fileURLToPath(output) }));
 await context.close();
} finally { await browser.close(); await server.close(); }
