import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH, headless: true });
const server = await recoveryFixture();
try {
  const page = await browser.newPage({ reducedMotion: 'reduce' });
  page.setDefaultTimeout(10000);
  const errors = [];
  page.on('pageerror',e=>errors.push(e.message));
  await page.route('https://basemaps.cartocdn.com/**',r=>r.fulfill({status:200,contentType:'image/jpeg',body:server.jpeg}));
  const bar = page.getByRole('progressbar',{name:'Cargando página'});
  async function idle() {
    await bar.waitFor({state:'hidden'});
    // A late header/account render must not restart a completed navigation.
    await page.waitForTimeout(150);
    assert.equal(await bar.count(),0,'No loader after page/header settled');
  }
  async function push(to) {
    await page.evaluate(to=>document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router.push(to),to);
    await idle();
  }
  await page.goto(server.origin+'/iniciar-sesion');
  await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');
  await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');
  await page.getByLabel('Contraseña',{exact:true}).press('Enter');
  await page.waitForURL('**/inicio');
  await page.getByRole('navigation',{name:'Navegación de usuario'}).waitFor();
  await idle();
  // Full reload hydrates the actor and mounts the persistent navigation again.
  await page.reload();
  await page.getByRole('navigation',{name:'Navegación de usuario'}).waitFor();
  await idle();
  for (const [name,path] of [['Explorar','explorar'],['Mis mascotas','mis-mascotas'],['Inicio','inicio']]) {
    await page.getByRole('navigation',{name:'Navegación de usuario'}).getByRole('link',{name,exact:true}).click();
    await page.waitForURL('**/'+path); await idle();
  }
  let release;
  const gate = new Promise(resolve=>{release=resolve;});
  const hold = async route=>{await gate;await route.continue();};
  await page.route('**/api/access/session',hold);
  await page.evaluate(()=>window.dispatchEvent(new Event('focus')));
  await page.getByRole('link',{name:'Explorar',exact:true}).click();
  try { await bar.waitFor(); assert.equal(await page.evaluate(()=>location.pathname),'/inicio','Loader covers the real access wait'); }
  finally { release(); }
  await page.waitForURL('**/explorar');
  await page.unroute('**/api/access/session',hold); await idle();
  await push('/explorar?prueba=1'); await push('/explorar?prueba=2');
  await push('/explorar?prueba=2#contenido'); await push('/explorar?prueba=2#contenido');
  // A real router guard aborts before commit; cancellation must clear the line.
  await page.evaluate(async()=>{
    const router=document.querySelector('#__nuxt').__vue_app__.config.globalProperties.$router;
    const remove=router.beforeEach(to=>to.path==='/terminos' ? false : undefined);
    try { await router.push('/terminos'); } finally { remove(); }
  });
  await idle();
  await push('/iniciar-sesion');
  assert.equal(new URL(page.url()).pathname,'/inicio','Session redirects settle');
  await push('/terminos'); await push('/privacidad');
  assert.deepEqual(errors,[]);
  const app = await readFile(new URL('../app/app.vue',import.meta.url),'utf8');
  assert.match(app, /:page-key="pageKey"/,'NuxtPage receives a stable function reference');
  console.log('Top loader Chrome QA passed: login/header mount, authenticated reload, account navigation, held access request, same-page query/hash/duplicate, aborted guard, session redirect, legal navigation; no stuck line or page errors.');
} finally { await browser.close(); await server.close(); }
