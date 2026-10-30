import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath:process.env.CHROME_PATH, headless:true });
const server = await recoveryFixture();
const output = new URL('../../mobile/build/ui-preview/web-home/', import.meta.url);
await mkdir(output,{ recursive:true });
try {
  const context = await browser.newContext({ viewport:{width:1440,height:1000}, reducedMotion:'reduce' });
  const page = await context.newPage(), errors = [];
  page.on('pageerror',e => errors.push(e.message));
  page.on('console',m => { if (/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text())) errors.push(m.text()); });
  await page.route('https://basemaps.cartocdn.com/**',r => r.fulfill({status:200,contentType:'image/jpeg',body:server.jpeg}));
  await page.goto(server.origin+'/inicio');
  await page.waitForURL('**/iniciar-sesion');
  async function login(email) {
    await page.getByLabel('Correo',{exact:true}).fill(email);
    await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');
    await page.getByLabel('Contraseña',{exact:true}).press('Enter');
    await page.waitForURL('**/inicio');
    await page.getByRole('heading',{name:'Su regreso empieza contigo',exact:true}).waitFor();
    await page.evaluate(() => document.fonts.ready);
  }
  await login('ordinario@example.test');
  await page.waitForFunction(() => document.querySelector('.account-grid')?.getAttribute('aria-busy') === 'false');
  assert.equal(await page.getByRole('link',{name:'Revisar denuncias',exact:true}).count(),0);
  assert.equal(await page.locator('a[href="/terminos"], a[href="/privacidad"]').count(),0);
  assert.equal(await page.locator('.account-grid > .eyebrow').count(),0);
  assert.equal(await page.locator('.home-reunion img').evaluate(img => img.complete && img.naturalWidth > 0),true);
  assert.equal(await page.locator('.home-title span').evaluate(el => getComputedStyle(el).fontWeight),'600');
  for (const [width,height,size,name] of [[1440,1000,'100%','desktop'],[390,844,'100%','mobile'],[320,640,'100%','small'],[320,640,'200%','text200']]) {
    await page.setViewportSize({width,height});
    await page.evaluate(size => {document.documentElement.style.fontSize=size;window.scrollTo(0,0);},size);
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth),true,name+' overflow');
    const title = await page.locator('.home-title').boundingBox(), image = await page.locator('.home-reunion').boundingBox();
    assert.ok(width > 850 ? image.x > title.x+title.width : image.y > title.y+title.height,name+' composition');
    await page.screenshot({path:fileURLToPath(new URL(name+'.png',output)),fullPage:true});
  }
  await page.getByRole('button',{name:'Abrir perfil',exact:true}).click();
  await page.getByText('ordinario@example.test',{exact:true}).waitFor();
  await page.keyboard.press('Escape');
  assert.equal(await page.getByRole('dialog',{name:'Tu cuenta',exact:true}).count(),0);
  await page.evaluate(() => document.documentElement.style.fontSize='100%');
  await page.setViewportSize({width:1440,height:1000});
  const shortcuts = page.getByRole('navigation',{name:'Accesos de Inicio',exact:true});
  for (const [name,path] of [['Explorar','explorar'],['Mis mascotas','mis-mascotas'],['Reportar','reportar']]) {
    await shortcuts.getByRole('link',{name,exact:true}).click();
    await page.waitForURL('**/'+path);
    await page.locator('.recovery-screen').waitFor();
    if (path === 'reportar') await page.getByRole('button',{name:'Cerrar reporte',exact:true}).click();
    else await page.getByRole('navigation',{name:'Navegación de usuario',exact:true}).getByRole('link',{name:'Inicio',exact:true}).click();
    await page.waitForURL('**/inicio');
    await page.getByRole('heading',{name:'Su regreso empieza contigo',exact:true}).waitFor();
  }
  await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();
  await page.waitForURL('**/iniciar-sesion*');
  await login('moderador@example.test');
  await page.getByRole('link',{name:'Revisar denuncias',exact:true}).waitFor();
  await page.screenshot({path:fileURLToPath(new URL('moderator.png',output)),fullPage:true});
  assert.deepEqual(errors,[]);
  await context.close();
  console.log('Home QA passed: desktop/mobile/320/text200, image/font, profile/Escape, shortcuts/return, legal footer removed, anonymous redirect and management permissions.');
} finally { await browser.close(); await server.close(); }
