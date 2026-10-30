import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { productionFixture } from '../tests/server_fixture.mjs';
const runtime = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const { chromium } = runtime.default || runtime;
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const output = new URL('../../mobile/build/ui-preview/landing-vue/', import.meta.url);
await mkdir(output, { recursive: true });
let server; const results = [];
try {
  server = await productionFixture();
  for (const [name, width, height] of [['desktop', 1440, 1000], ['reference', 731, 1000], ['mobile', 390, 844], ['small', 320, 700]]) {
    const page = await browser.newPage({ viewport: { width, height }, reducedMotion: 'reduce' });
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('console', msg => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(msg.text())) errors.push(msg.text()); });
    page.on('response', response => { if (response.status() >= 400 && !(response.status() === 401 && new URL(response.url()).pathname === '/api/access/session')) errors.push(`${response.status()} ${new URL(response.url()).pathname}`); });
    const response = await page.goto(server.origin, { waitUntil: 'networkidle' });
    assert.equal(response.status(), 200); assert.equal(await page.locator('h1').count(), 1);
    assert.equal(await page.locator('html').getAttribute('lang'), 'es');
    // Scroll the real page so lazy illustrations load as they do for a visitor.
    await page.evaluate(async () => {
      for (let y = 0; y < document.body.scrollHeight; y += innerHeight) {
        scrollTo(0, y); await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
      }
      scrollTo(0, 0);
      await Promise.all([...document.images].map(img => img.decode()));
    });
    const artwork = await page.locator('.art img').evaluateAll(images => images.map(img => ({ src: img.getAttribute('src'), currentSrc: img.currentSrc, width: img.naturalWidth, height: img.naturalHeight })));
    assert.ok(artwork.length >= 17);
    assert.ok(artwork.every(img => img.src.startsWith('/images/landing/') && img.width > 0 && img.height > 0), 'Independent artwork decodes everywhere');
    const heroImages = artwork.filter(img => /hero-(dog|cat)\.png$/.test(img.src));
    assert.ok(heroImages.every(img => /hero-(dog|cat)-(320|640)\.webp$/.test(img.currentSrc)), 'Hero selects a smaller responsive source at DPR 1');
    assert.ok(artwork.every(img => img.currentSrc.endsWith('.webp')), 'Browsers with WebP support select the lossless optimized artwork');
    assert.ok(await page.locator('.step-art, .art-home, .art-map').evaluateAll(nodes => nodes.every(node => {
      const frame = node.getBoundingClientRect();
      const image = node.querySelector('img').getBoundingClientRect();
      return image.height > 0 && image.top < frame.bottom && image.bottom > frame.top;
    })), 'Optimized illustrations remain inside their visible layout windows');
    assert.equal(new Set(artwork.map(img => img.src)).size, 12);
    assert.equal(await page.locator('.character-label').count(), 24);
    assert.equal(await page.locator('.character-group').first().locator('.character:not([aria-hidden="true"])').count(), 4, 'The four distinct messages remain exposed; visual repetitions are decorative');
    assert.equal(await page.locator('.brand img[src="/brand.png"], .site-brand img[src="/brand.png"]').count(), 2);
    // A gradient declaration alone does not generate or size the painted layer.
    for (const selector of ['.hero', '.closing']) {
      const layer = await page.locator(selector).evaluate(el => {
        const style = getComputedStyle(el, '::before');
        return {
          content: style.content, display: style.display,
          visibility: style.visibility, opacity: Number(style.opacity),
          width: parseFloat(style.width), height: parseFloat(style.height),
          expectedWidth: el.clientWidth, expectedHeight: el.clientHeight,
          background: style.backgroundImage,
        };
      });
      assert.ok(layer.content !== 'none' && layer.content !== 'normal', `${name}: ${selector} background must be generated`);
      assert.notEqual(layer.display, 'none');
      assert.notEqual(layer.visibility, 'hidden');
      assert.ok(layer.opacity > 0 && layer.width > 0 && layer.height > 0);
      assert.ok(Math.abs(layer.width - layer.expectedWidth) < 1 && Math.abs(layer.height - layer.expectedHeight) < 1, `${name}: ${selector} gradient must cover the section`);
      assert.ok(layer.background.includes('radial-gradient('));
    }
    assert.equal(await page.locator('img[src*="landing-reference"]').count(), 0);
    assert.equal(await page.locator('.bandana-layer, .art svg image').count(), 0, 'Emblems must be generated into the artwork, not overlaid');
    for (const breed of ['corgi','dalmatian','tabby']) assert.ok(artwork.some(img => img.src.includes(breed)), 'Diverse pets must be present');
    assert.equal(await page.locator('.hero').evaluate(el => getComputedStyle(el).animationName), 'none');
    assert.equal(await page.locator('.character-track').evaluate(el => getComputedStyle(el).animationName), 'none');
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, `${name}: overflow`);
    const broken = await page.locator('a[href^="#"]').evaluateAll(links => links.filter(a => !document.getElementById(a.getAttribute('href').slice(1))).map(a => a.getAttribute('href')));
    assert.deepEqual(broken, []);
    assert.equal(await page.locator('[style]').count(), 0, 'Native components must preserve strict CSP');
    assert.equal(await page.locator('details').count(), 4);
    await page.screenshot({ path: fileURLToPath(new URL(`${name}.png`, output)), fullPage: true });
    const privacy = page.locator('summary').filter({ hasText: '¿Cómo se cuida la privacidad?' });
    await privacy.focus(); await page.keyboard.press('Enter');
    assert.equal(await privacy.locator('..').getAttribute('open'), ''); assert.equal(await page.locator('details[open]').count(), 1);
    await page.getByRole('navigation').getByRole('link', { name: 'Comunidad', exact: true }).click();
    await page.waitForFunction(() => location.hash === '#comunidad');
    assert.equal(await page.locator('#comunidad').evaluate(el => Math.abs(el.getBoundingClientRect().top) < 100), true);
    assert.deepEqual(errors, []); assert.equal(server.reads(), 0);
    results.push(`${name}: HTML, native FAQ/keyboard, anchors, 12 independent illustrations with printed white emblems, official logo, native cards, image decode, no overflow, no inline styles/CSP/hydration errors`);
    await page.close();
  }
  const animated = await browser.newPage({ viewport: { width: 1440, height: 1000 } });
  await animated.goto(server.origin, { waitUntil: 'networkidle' });
  assert.equal(await animated.locator('.hero').evaluate(el => getComputedStyle(el).animationName), 'cover-reveal');
  assert.equal(await animated.locator('.hero-heading').evaluate(el => getComputedStyle(el).animationName), 'stagger-reveal');
  assert.equal(await animated.locator('.hero').evaluate(el => getComputedStyle(el).animationDuration), '0.7s');
  assert.equal(await animated.locator('.hero-heading').evaluate(el => getComputedStyle(el).animationDelay), '0.2s');
  await animated.waitForTimeout(1100);
  await animated.screenshot({ path: fileURLToPath(new URL('desktop-top.png', output)) });
  const track = animated.locator('.character-track');
  const start = await track.evaluate(el => getComputedStyle(el).transform);
  await animated.waitForTimeout(250);
  assert.notEqual(await track.evaluate(el => getComputedStyle(el).transform), start, 'Cards must move horizontally');
  const groups = await animated.locator('.character-group').evaluateAll(nodes => nodes.map(el => el.getBoundingClientRect().width));
  assert.ok(Math.abs(groups[0] - groups[1]) < 0.01, 'Loop copies must have identical widths within subpixel precision');
  assert.equal(await animated.locator('.character-motion').count(), 0);
  const card = animated.locator('.character').first();
  const waveStart = await card.evaluate(el => getComputedStyle(el).transform);
  await animated.waitForTimeout(300);
  assert.notEqual(await card.evaluate(el => getComputedStyle(el).transform), waveStart, 'Cards must change height smoothly');
  await animated.locator('.character-strip').hover();
  assert.equal(await track.evaluate(el => getComputedStyle(el).animationPlayState), 'running');
  assert.equal(await card.evaluate(el => getComputedStyle(el).animationPlayState), 'running');
  const phases = await animated.locator('.character-group').first().locator('.character').evaluateAll(nodes => nodes.map(el => getComputedStyle(el).animationDelay));
  assert.equal(new Set(phases).size, 12, 'A broad wave spans twelve progressively delayed cards');
  const frame = await card.evaluate(el => ({ width: el.offsetWidth, height: el.offsetHeight, artWidth: el.querySelector('.art').offsetWidth, artHeight: el.querySelector('.art').offsetHeight }));
  assert.ok(Math.abs(frame.artHeight - 288 * 1.31076) < 1, 'Portrait keeps its previous rendered height');
  assert.equal(frame.width, 325, 'Cards receive the small requested width increase');
  assert.ok(frame.height > frame.artHeight + 100, 'Cards keep their approved height');
  const control = await animated.locator('.character-horizontal-toggle').evaluate(el => ({ width: el.offsetWidth, height: el.offsetHeight, top: parseFloat(getComputedStyle(el).top) }));
  assert.equal(control.width, control.height, 'Pause control is circular');
  assert.equal(control.width, 60, 'Pause control uses the adjusted size');
  assert.equal(control.top, 12, 'Pause control belongs at the top');
  assert.ok(await animated.locator('.character').evaluateAll(nodes => nodes.every(el => {
    const frame = el.getBoundingClientRect();
    const art = el.querySelector('.art');
    const rect = art.getBoundingClientRect();
    const img = art.querySelector('img');
    return getComputedStyle(art).overflow === 'visible' && getComputedStyle(img).objectFit === 'contain' && Math.abs(img.getBoundingClientRect().width - rect.width) < 0.01;
  })), 'Inner artwork windows must not crop the image before the rounded card edges');
  const clearance = await animated.locator('.character-strip').evaluate(el => {
    const buttonBottom = el.querySelector('.character-horizontal-toggle').getBoundingClientRect().bottom;
    return Math.min(...[...el.querySelectorAll('.character')].map(card => card.getBoundingClientRect().top)) - buttonBottom;
  });
  assert.ok(clearance >= 16, 'Pause control must remain above the wave');
  await animated.getByRole('button', { name: 'Pausar desplazamiento horizontal' }).click();
  assert.equal(await track.evaluate(el => getComputedStyle(el).animationPlayState), 'paused');
  const pausedHorizontal = await track.evaluate(el => getComputedStyle(el).transform);
  const continuedWave = await card.evaluate(el => getComputedStyle(el).transform);
  await animated.waitForTimeout(300);
  assert.equal(await track.evaluate(el => getComputedStyle(el).transform), pausedHorizontal, 'Horizontal movement stays paused');
  assert.notEqual(await card.evaluate(el => getComputedStyle(el).transform), continuedWave, 'Wave continues while horizontal movement is paused');
  await animated.getByRole('button', { name: 'Reanudar desplazamiento horizontal' }).click();
  assert.equal(await track.evaluate(el => getComputedStyle(el).animationPlayState), 'running');
  await animated.locator('.character-strip').screenshot({ path: fileURLToPath(new URL('characters.png', output)) });
  await animated.close();
  const page = await browser.newPage({ viewport: { width: 320, height: 700 }, reducedMotion: 'reduce' });
  await page.goto(server.origin, { waitUntil: 'networkidle' });
  await page.evaluate(() => {
    const nodes = [...document.querySelectorAll('h1,h2,h3,p,a,summary,.character-label,.step-number,.small-number')];
    const sizes = nodes.map(node => parseFloat(getComputedStyle(node).fontSize));
    nodes.forEach((node, index) => { node.style.fontSize = `${sizes[index] * 2}px`; });
  });
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += innerHeight) {
      scrollTo(0, y); await new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    }
    scrollTo(0, 0); await Promise.all([...document.images].map(img => img.decode()));
  });
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, '200% text overflow');
  await page.screenshot({ path: fileURLToPath(new URL('small-text-200.png', output)), fullPage: true });
  await page.goto(server.origin, { waitUntil: 'networkidle' });
  await page.evaluate(() => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push('/c/unknown'));
  await page.getByRole('heading', { name: 'Este enlace no está disponible' }).waitFor();
  assert.equal(await page.locator('main').evaluate(el => getComputedStyle(el).maxWidth), '960px');
  assert.equal(await page.locator('.landing-page').count(), 0);
  await page.evaluate(() => document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push('/'));
  await page.getByRole('heading', { name: /Más huellas juntas/ }).waitFor();
  assert.equal(await page.locator('.reader-shell').count(), 0);
  await page.close();
  const noJs = await browser.newContext({ javaScriptEnabled: false, viewport: { width: 390, height: 844 } });
  const plain = await noJs.newPage(); await plain.goto(server.origin, { waitUntil: 'networkidle' });
  assert.match(await plain.locator('h1').innerText(), /Más huellas juntas/);
  const summary = plain.locator('summary').filter({ hasText: '¿Cómo se cuida la privacidad?' });
  await summary.click(); assert.equal(await summary.locator('..').getAttribute('open'), '');
  await noJs.close();
  results.push('320px/200% text, SPA landing→QR→landing style isolation, SSR and FAQ without JS passed');
  await writeFile(new URL('results.txt', output), results.join('\n') + '\n');
  console.log(results.join('\n'));
} finally { await browser.close(); if (server) await server.close(); }
