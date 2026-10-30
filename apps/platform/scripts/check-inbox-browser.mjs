import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {inboxFixture} from '../tests/inbox_fixture.mjs';
const {chromium}=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await inboxFixture();
const output=new URL('../../mobile/build/ui-preview/web-inbox/',import.meta.url);await mkdir(output,{recursive:true});
let releaseList;
try {
  const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),page=await context.newPage(),errors=[];
  page.setDefaultTimeout(15000);page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
  async function login(email) {await page.getByLabel('Correo',{exact:true}).fill(email);await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');await page.waitForURL('**/inicio');await page.getByRole('heading',{name:'Su regreso empieza contigo',exact:true}).waitFor();await page.evaluate(()=>document.fonts.ready);}
  await page.goto(server.origin+'/iniciar-sesion');await login('ordinario@example.test');
  await page.waitForFunction(()=>document.querySelector('.account-avatar img')?.complete);
  assert.equal(await page.locator('.account-avatar img').evaluate(img=>img.naturalWidth>0),true);
  assert.equal(await page.locator('.home-reunion').evaluate(el=>getComputedStyle(el).backdropFilter),'blur(22px)');
  assert.equal(await page.getByRole('button',{name:'Alertas',exact:true}).count(),1);
  assert.equal(server.calls.filter(c=>c.kind==='list').length,0,'Inbox only reads after opening');
  async function capture(name) {await page.screenshot({path:fileURLToPath(new URL(name+'.png',output)),fullPage:true});}
  for(const[width,height,size,name]of[[1440,1000,'100%','desktop'],[390,844,'100%','mobile'],[320,640,'100%','small'],[320,640,'200%','text200']]){
    await page.setViewportSize({width,height});await page.evaluate(size=>{document.documentElement.style.fontSize=size;window.scrollTo(0,0);},size);
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,name+' overflow');
    const brand=await page.locator('.account-header .site-brand').boundingBox(),actions=await page.locator('.account-header-actions').boundingBox();
    assert.ok(actions.x>=0&&actions.x+actions.width<=width,name+' header bounds');
    assert.ok(brand.x+brand.width<=actions.x||brand.y+brand.height<=actions.y,name+' header overlap');await capture(name);
    await page.getByRole('button',{name:'Abrir perfil',exact:true}).click();
    const profile=page.getByRole('dialog',{name:'Tu cuenta',exact:true});await profile.getByText('ordinario@example.test',{exact:true}).waitFor();
    assert.equal(await profile.evaluate(el=>el.scrollWidth<=el.clientWidth),true,name+' profile overflow');await capture(name+'-profile');
    await page.keyboard.press('Escape');await profile.waitFor({state:'hidden'});assert.equal(await page.evaluate(()=>document.body.style.overflow),'');
  }
  await page.evaluate(()=>document.documentElement.style.fontSize='100%');await page.setViewportSize({width:390,height:844});
  const gate=new Promise(resolve=>{releaseList=resolve;});await page.route('**/api/notifications/inbox',async route=>{await gate;await route.continue();});
  await page.getByRole('button',{name:'Alertas',exact:true}).click();const inbox=page.getByRole('dialog',{name:'Alertas',exact:true});
  await inbox.locator('.skeleton').waitFor();assert.equal(await inbox.getByText('Aún no tienes alertas.').count(),0);await capture('loading');
  releaseList();await inbox.getByRole('heading',{name:'Hay novedades en un caso que sigues',exact:true}).waitFor();await page.unroute('**/api/notifications/inbox');
  assert.equal(await inbox.locator('.inbox-item').count(),2);assert.equal((await inbox.innerText()).includes('PRIVATE'),false);await capture('mobile-inbox');
  server.failMark(true);await inbox.getByRole('button',{name:'Marcar leída',exact:true}).click();await inbox.getByRole('alert').waitFor();assert.equal(await inbox.getByText('Sin leer',{exact:true}).count(),1);
  server.failMark(false);await inbox.getByRole('button',{name:'Marcar leída',exact:true}).click();await inbox.getByRole('button',{name:'Marcar leída',exact:true}).waitFor({state:'hidden'});
  server.failList(true);await inbox.getByRole('button',{name:'Ver más alertas',exact:true}).click();await inbox.getByRole('button',{name:'Reintentar',exact:true}).waitFor();assert.equal(await inbox.locator('.inbox-item').count(),2);
  server.failList(false);await inbox.getByRole('button',{name:'Ver más alertas',exact:true}).click();await inbox.getByRole('heading',{name:'Nuevo caso cerca de tu ubicación',exact:true}).waitFor();assert.equal(await inbox.locator('.inbox-item').count(),3);
  await page.keyboard.press('Escape');await page.reload();await page.getByRole('button',{name:'Alertas',exact:true}).click();await inbox.getByRole('heading',{name:'Hay novedades en un caso que sigues',exact:true}).waitFor();assert.equal(await inbox.getByText('Sin leer',{exact:true}).count(),0,'Read state survives reload');
  await page.setViewportSize({width:320,height:640});await page.evaluate(()=>document.documentElement.style.fontSize='200%');assert.equal(await inbox.evaluate(el=>el.scrollWidth<=el.clientWidth),true);await capture('text200-inbox');
  await page.keyboard.press('Escape');await page.evaluate(()=>document.documentElement.style.fontSize='100%');
  server.avatar(false);await page.reload();await page.locator('.account-avatar span').waitFor();assert.equal(await page.locator('.account-avatar span').innerText(),'UP');await capture('avatar-fallback');
  await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();await page.waitForURL('**/iniciar-sesion*');await login('moderador@example.test');
  await page.getByRole('button',{name:'Alertas',exact:true}).click();await inbox.getByText('Aún no tienes alertas.',{exact:true}).waitFor();assert.equal(await inbox.locator('.inbox-item').count(),0);await capture('other-account-empty');
  assert.deepEqual(errors,[]);await context.close();
  console.log('Inbox/header QA passed: real stored avatar/fallback, shared glass, responsive/text200, profile keyboard/Escape/scroll cleanup, lazy inbox/skeleton/error/retry/pagination, persistent read and account separation. Fixture backend only.');
} finally {releaseList?.();await browser.close();await server.close();}
