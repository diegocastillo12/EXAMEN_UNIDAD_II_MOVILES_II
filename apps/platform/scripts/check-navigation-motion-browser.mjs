import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath,pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath:process.env.CHROME_PATH,headless:true });
const server = await recoveryFixture();
const output = new URL('../../mobile/build/ui-preview/web-navigation-motion/',import.meta.url);
await mkdir(output,{ recursive:true });
try {
  const context = await browser.newContext({ viewport:{width:390,height:844},reducedMotion:'no-preference' });
  const page = await context.newPage(),errors = [];
  page.setDefaultTimeout(15000);
  page.on('pageerror',e => { errors.push(e.message);console.log('Page error:',e.message); });
  page.on('console',m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  await page.route('https://basemaps.cartocdn.com/**',r => r.fulfill({ status:200,contentType:'image/jpeg',body:server.jpeg }));
  const nav = page.getByRole('navigation',{ name:'Navegación de usuario' });
  const idle = () => page.waitForFunction(() => !document.querySelector('[data-origin-animating], main[inert], .user-navigation [aria-busy="true"]'));
  async function freeze(progress) {
    await page.waitForFunction(() => !!document.querySelector('[data-origin-animating]')?._flip);
    await page.evaluate(value => {
      document.querySelector('[data-origin-animating]')._flip.pause().progress(value);
    },progress);
  }
  async function finish() {
    await page.evaluate(() => { document.querySelector('[data-origin-animating]')?._flip.progress(1); });
    await idle();
    assert.equal(await page.locator('.origin-transition-previous > *').count(),0,'Transient previous content must be released');
  }
  const shot = name => page.screenshot({ path:fileURLToPath(new URL(name+'.png',output)) });
  await page.goto(server.origin+'/iniciar-sesion');
  assert.equal(await nav.count(),0);
  await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');
  await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');
  await page.getByLabel('Contraseña',{exact:true}).press('Enter');
  await page.waitForURL('**/inicio');await nav.waitFor();
  assert.equal((await nav.textContent()).trim(),'','Navigation must be icon-only at every width');
  const bar = await nav.elementHandle();
  const surface = page.locator('.user-navigation-indicator span');
  const elasticX = () => surface.evaluate(el => parseFloat(getComputedStyle(el).translate) || 0);
  for (const width of [1920,1440,731,390,320]) {
    await page.setViewportSize({width,height:844});
    const bounds = await nav.boundingBox();
    assert.ok(bounds.width <= 304 && bounds.x >= 0 && bounds.x+bounds.width <= width,'Compact navigation fits viewport');
    const item = await nav.getByRole('link',{name:'Inicio',exact:true}).boundingBox();
    assert.ok(item.width >= 48 && item.width <= 73 && item.height >= 48,'Rounded options retain touch area');
    await shot('compact-'+width);
  }
  await page.setViewportSize({width:390,height:844});
  await page.mouse.move(10,10);
  const restingY = (await surface.boundingBox()).y;
  await nav.getByRole('link',{name:'Inicio',exact:true}).hover();
  await page.waitForTimeout(250);
  assert.equal((await surface.boundingBox()).y,restingY,'Hover must not lift selected surface');
  await nav.getByRole('link',{name:'Explorar',exact:true}).hover();
  assert.equal(await surface.evaluate(el => el.getAnimations().some(a => a.effect.getKeyframes().some(k => k.translate))),false,'Hover must not start an elastic impulse');
  assert.equal(await elasticX(),0,'Hover keeps selection in place');
  const home = await nav.getByRole('link',{name:'Inicio',exact:true}).boundingBox();
  await page.mouse.move(home.x+home.width/2,home.y+home.height/2);
  await page.mouse.down();await page.mouse.move(home.x+home.width/2+22,home.y+home.height/2,{steps:4});
  await page.waitForTimeout(120);
  assert.ok(await elasticX() > 0,'Drag pushes selection slightly');
  await page.mouse.up();await page.waitForTimeout(550);
  assert.equal(await elasticX(),0,'Release restores selection');
  assert.ok(page.url().endsWith('/inicio'),'Dragging does not activate a destination');
  await page.emulateMedia({reducedMotion:'reduce'});
  await nav.getByRole('link',{name:'Explorar',exact:true}).hover();
  assert.equal(await elasticX(),0,'Reduced motion disables elastic impulse');
  await page.emulateMedia({reducedMotion:'no-preference'});
  await nav.getByRole('link',{name:'Explorar',exact:true}).click();
  await page.waitForURL('**/explorar');
  await page.locator('.user-navigation-capsule[data-section="1"]').waitFor();
  const progress = await page.locator('.user-navigation-indicator').evaluate(el => {
    const transition = el.getAnimations().find(a => a.transitionProperty === 'transform');
    if (!transition) return null;
    transition.pause();transition.currentTime = 160;
    return { x:new DOMMatrixReadOnly(getComputedStyle(el).transform).m41,width:el.getBoundingClientRect().width };
  });
  assert.ok(progress && progress.x > 0 && progress.x < progress.width,'Blue indicator must travel, not jump');
  assert.equal(await bar.evaluate(el => el === document.querySelector('.user-navigation')),true,'Bar must persist between pages');
  await shot('indicator-halfway');
  await page.locator('.user-navigation-indicator').evaluate(el => el.getAnimations().forEach(a => a.finish()));
  await nav.getByRole('link',{name:'Mis mascotas',exact:true}).click();
  await page.waitForURL('**/mis-mascotas');await page.getByRole('heading',{name:'Luna',exact:true}).waitFor();
  const brand = await page.locator('.account-brand:not([data-origin-underlay] *)').boundingBox(),source = await nav.getByRole('link',{name:'Reportar',exact:true}).boundingBox();
  await nav.getByRole('link',{name:'Reportar',exact:true}).click();await page.waitForURL('**/reportar');
  await freeze(.3);
  const expanded = await page.locator('main[data-origin-content]:not([data-origin-underlay] *)').boundingBox();
  assert.ok(expanded.width > source.width && expanded.width < 390);
  assert.equal(await page.locator('main[data-origin-content]:not([data-origin-underlay] *)').evaluate(el => el.inert),true);
  assert.equal(await page.locator('main[data-origin-content]:not([data-origin-underlay] *) > .origin-page-body').evaluate(el => getComputedStyle(el).visibility),'visible');
  const duringBrand = await page.locator('.account-brand:not([data-origin-underlay] *)').boundingBox();
  assert.deepEqual(duringBrand,brand,'Brand remains outside the transition');
  await shot('report-origin-30');
  await page.evaluate(() => { document.querySelector('[data-origin-animating]')._flip.progress(.85); });
  assert.equal(await page.locator('main[data-origin-content]:not([data-origin-underlay] *) > .origin-page-body').evaluate(el => getComputedStyle(el).visibility),'visible','Content scales within the expanding surface');
  await shot('report-origin-85');await finish();
  const back=page.goBack();await freeze(.5);await shot('report-return-halfway');await finish();await back;await page.waitForURL('**/mis-mascotas');
  await page.getByRole('button',{name:'Registrar mascota',exact:true}).click();await freeze(.35);await shot('pet-origin');await finish();
  await page.getByRole('button',{name:'Cancelar',exact:true}).click();await freeze(.5);await finish();
  // A cancelled dirty-form guard keeps the old route, content and focus usable.
  await page.getByRole('button',{name:'Registrar mascota',exact:true}).click();await idle();
  await page.getByLabel('Nombre',{exact:true}).fill('Borrador');
  await nav.getByRole('link',{name:'Reportar',exact:true}).click();
  await page.getByRole('dialog').getByRole('button',{name:'Cancelar',exact:true}).click();
  await idle();assert.ok(page.url().includes('/mis-mascotas'));assert.equal(await page.getByLabel('Nombre',{exact:true}).inputValue(),'Borrador');
  await page.getByRole('button',{name:'Cancelar',exact:true}).click();await page.getByRole('dialog').getByRole('button',{name:'Salir',exact:true}).click();await idle();
  // Resizing or changing reduced motion midway releases mask and inert state.
  await nav.getByRole('link',{name:'Reportar',exact:true}).click();await freeze(.2);await page.setViewportSize({width:320,height:640});await idle();
  await nav.getByRole('link',{name:'Mis mascotas',exact:true}).click();await page.waitForURL('**/mis-mascotas');await page.getByRole('button',{name:'Registrar mascota',exact:true}).waitFor();
  await page.getByRole('button',{name:'Registrar mascota',exact:true}).click();await freeze(.2);await page.emulateMedia({reducedMotion:'reduce'});await idle();
  await page.getByRole('button',{name:'Cancelar',exact:true}).click();await idle();
  await nav.getByRole('link',{name:'Reportar',exact:true}).click();await page.waitForURL('**/reportar');await idle();assert.equal(await page.locator('.origin-transition-active').count(),0);
  assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth),true);
  await page.emulateMedia({reducedMotion:'no-preference'});
  await nav.getByRole('link',{name:'Mis mascotas',exact:true}).click();await page.waitForURL('**/mis-mascotas');
  await page.getByRole('button',{name:'Registrar mascota',exact:true}).click();await freeze(.3);
  await page.evaluate(async () => {
    await fetch('/api/access/logout',{method:'POST',headers:{'Content-Type':'application/json'},body:'{}'});
    const channel = new BroadcastChannel('eh-access');channel.postMessage('changed');channel.close();
  });
  await page.waitForURL('**/iniciar-sesion*');await idle();assert.equal(await nav.count(),0);
  assert.equal(await page.getByText('Luna',{exact:true}).count(),0,'Identity change must remove previous-account content');
  assert.deepEqual(errors,[]);
  await context.close();
  console.log('Navigation motion Chrome QA passed: icon-only bar, persistent sliding indicator, origin expansion/content timing, reverse, brand stability, local editor reuse, cancelled navigation, resize, reduced motion, no overflow/CSP/hydration errors. Fixture only.');
} finally { await browser.close();await server.close(); }
