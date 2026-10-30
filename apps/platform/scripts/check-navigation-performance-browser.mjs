import assert from 'node:assert/strict';
import { mkdir, writeFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';

const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath:process.env.CHROME_PATH, headless:true });
const server = await recoveryFixture();
const baseline = process.env.NAVIGATION_BASELINE === '1';
const output = new URL('../../mobile/build/ui-preview/web-navigation-performance/', import.meta.url);
await mkdir(output, { recursive:true });
try {
 const context = await browser.newContext({ viewport:{ width:390, height:844 }, reducedMotion:'no-preference' });
 const page = await context.newPage(), errors = [], requests = [];
 page.on('pageerror', error => errors.push(error.message));
 page.on('console', message => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(message.text())) errors.push(message.text()); });
 page.on('request', request => { const path = new URL(request.url()).pathname; if (path.startsWith('/api/')) requests.push(path); });
 // Make redundant session network reads observable on a stable local fixture.
 await page.route('**/api/access/session', async route => { await new Promise(resolve => setTimeout(resolve,250)); await route.continue(); });
 await page.goto(server.origin + '/iniciar-sesion');
 await page.getByLabel('Correo',{ exact:true }).fill('ordinario@example.test');
 await page.getByLabel('Contraseña',{ exact:true }).fill('test-fixture-password');
 await page.getByLabel('Contraseña',{ exact:true }).press('Enter');
 await page.waitForURL('**/inicio');
 const nav = page.getByRole('navigation',{ name:'Navegación de usuario' });
 await nav.waitFor(); await page.getByRole('heading',{ name:'Su regreso empieza contigo' }).waitFor();
 await page.waitForTimeout(150);
 requests.length = 0;
 const metrics = [];
 for (const name of ['Explorar','Mis mascotas','Inicio','Explorar','Mis mascotas','Inicio']) {
  const start = performance.now();
  await nav.getByRole('link',{ name, exact:true }).click();
  await page.getByRole('heading',{ name:name === 'Inicio' ? 'Su regreso empieza contigo' : name, exact:true }).waitFor();
  const headingMs = Math.round(performance.now()-start);
  await page.waitForFunction(() => !document.querySelector('.skeleton') && !document.querySelector('.origin-transition-active'));
  metrics.push({ section:name, headingMs, contentMs:Math.round(performance.now()-start) });
 }
 const sessionReads = requests.filter(path => path === '/api/access/session').length;
 const result = { artificialSessionLatencyMs:250, sessionReads, metrics, errors };
 console.log(JSON.stringify(result,null,2));
 await writeFile(new URL(baseline ? 'before.json' : 'after.json',output),JSON.stringify(result,null,2));
 if (!baseline) {
  assert.equal(sessionReads,0,'Warm navigation must reuse the identity checked by the global policy');
  assert.deepEqual(errors,[]);
  // Clicking the active section must neither fetch nor replay the entrance.
  const count = requests.length;
  await nav.getByRole('link',{ name:'Inicio',exact:true }).click();
  await page.waitForTimeout(100); assert.equal(requests.length,count);
  const entrance = await page.locator('.stagger-reveal-ready').first().evaluate(element => [...element.children].map(child => ({ duration:parseFloat(getComputedStyle(child).transitionDuration), delay:parseFloat(getComputedStyle(child).transitionDelay) })));
  assert.ok(entrance.every(item => item.duration + item.delay <= .381),'General entrance must settle within 380ms, including long lists');
  await page.screenshot({ path:fileURLToPath(new URL('navigation-390.png',output)) });
  // Reuse must stop at the original 15-second deadline, even without a focus
  // event or a broadcast. Keep the tab focused and let the real TTL expire.
  await page.waitForTimeout(15100);
  await nav.getByRole('link',{ name:'Explorar',exact:true }).click();
  await page.getByRole('heading',{ name:'Explorar',exact:true }).waitFor();
  assert.equal(requests.filter(path => path === '/api/access/session').length,1,'Expired preparation must revalidate before mounting');
  await page.reload();
  await page.getByRole('heading',{ name:'Explorar',exact:true }).waitFor();
  assert.deepEqual(errors,[],'A direct reload must hydrate the same initial state as SSR');
  // A real identity invalidation must still fail closed and clear account UI.
  await page.unroute('**/api/access/session');
  await page.route('**/api/access/session', route => route.fulfill({ status:401,contentType:'application/json',body:'{}' }));
  await page.evaluate(() => { const channel = new BroadcastChannel('eh-access'); channel.postMessage('changed'); channel.close(); });
  await page.waitForURL('**/iniciar-sesion*');
  await nav.waitFor({ state:'detached' });
  assert.deepEqual(errors,[]);
 }
} finally { await browser.close(); await server.close(); }
