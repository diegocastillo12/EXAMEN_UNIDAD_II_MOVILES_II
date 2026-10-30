// Check first SSR paint through hydration: final-state screenshots missed this regression.
import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
import { productionFixture } from '../tests/server_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH });
const server = await productionFixture();
try {
  const page = await browser.newPage({ reducedMotion: 'no-preference' });
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  await page.addInitScript(() => {
    window.headerFrames = [];
    function sample(time) {
      const header = document.querySelector('.site-header'), brand = header?.querySelector('.site-brand');
      if (brand && window.headerFrames.length < 1500) {
        const h = header.getBoundingClientRect(), b = brand.getBoundingClientRect(), c = getComputedStyle(header);
        window.headerFrames.push({ time, x: b.x, y: b.y, width: b.width, height: b.height, headerHeight: h.height, align: c.alignItems, heroTop: document.querySelector('.hero')?.getBoundingClientRect().y });
      }
      requestAnimationFrame(sample);
    }
    requestAnimationFrame(sample);
  });
  const origins = [server.origin, ...(process.env.DEV_ORIGIN ? [process.env.DEV_ORIGIN] : [])];
  for (const origin of origins) {
    for (const width of [1440, 731, 390, 320]) {
      await page.setViewportSize({ width, height: 1000 });
      for (let attempt = 0; attempt < 2; attempt++) {
        if (attempt) await page.reload({ waitUntil: 'networkidle' });
        else await page.goto(origin, { waitUntil: 'networkidle' });
        await page.waitForFunction(() => !!document.querySelector('#__nuxt')?.__vue_app__);
        await page.waitForTimeout(250);
        const frames = await page.evaluate(() => window.headerFrames);
        assert.ok(frames.length > 5, 'Must capture SSR and hydration frames');
        const first = frames[0];
        for (const key of ['x', 'y', 'width', 'height', 'headerHeight', 'heroTop']) {
          assert.ok(frames.every(f => Math.abs(f[key] - first[key]) < 0.5), `${origin} ${width} reload=${attempt}: ${key} changes: ${JSON.stringify(frames.filter((f, i) => !i || f[key] !== frames[i - 1][key]))}`);
        }
        assert.ok(frames.every(f => f.align === 'center'), 'Landing header stays centered from SSR through hydration');
      }
    }
  }
  assert.deepEqual(errors, []);
  console.log('Header reload passed: stable first SSR paint through hydration and full reload at 1440/731/390/320, production' + (process.env.DEV_ORIGIN ? ' and dev' : '') + ', no CSP/hydration errors.');
} finally { await browser.close(); await server.close(); }
