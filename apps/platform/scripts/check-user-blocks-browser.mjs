import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {userBlocksFixture,blockResource} from '../tests/user_blocks_fixture.mjs';
const {chromium}=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await userBlocksFixture();
const output=new URL('../../mobile/build/ui-preview/web-user-blocks/',import.meta.url);await mkdir(output,{recursive:true});
try {
 const context=await browser.newContext({viewport:{width:1440,height:1000}}),page=await context.newPage(),errors=[];
 page.setDefaultTimeout(15000);page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 await page.goto(server.origin+'/cuentas-bloqueadas');await page.waitForURL('**/iniciar-sesion*');
 await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');await page.waitForURL('**/inicio');
 await page.getByRole('button',{name:'Abrir perfil',exact:true}).click();await page.getByRole('link',{name:'Cuentas bloqueadas',exact:true}).click();await page.waitForURL('**/cuentas-bloqueadas');await page.getByText('No tienes cuentas bloqueadas.',{exact:true}).waitFor();
 await page.goto(server.origin+'/cuentas-bloqueadas?tipo=lost&contenido='+blockResource);await page.getByText('Reportante de Luna',{exact:true}).waitFor();await page.evaluate(()=>document.fonts.ready);
 await page.getByRole('button',{name:'Bloquear cuenta del reportante',exact:true}).click();await page.getByRole('dialog').waitFor();await page.getByRole('button',{name:'Cancelar',exact:true}).click();assert.equal(server.writes(),0);
 server.ambiguousBlock();await page.getByRole('button',{name:'Bloquear cuenta del reportante',exact:true}).click();await Promise.all([page.waitForResponse(r=>r.url().endsWith('/api/user-blocks/set') && r.status()===503),page.getByRole('dialog').getByRole('button',{name:'Bloquear',exact:true}).click()]);await page.getByRole('button',{name:'Reintentar cambio',exact:true}).waitFor();assert.equal(server.writes(),1);
 await page.getByRole('button',{name:'Reintentar cambio',exact:true}).click();await page.getByRole('button',{name:'Desbloquear cuenta',exact:true}).waitFor();assert.equal(server.writes(),1);assert.equal((await page.locator('.block-screen').innerText()).includes('PRIVATE'),false);
 for(const [width,height,size,name] of [[1440,1000,'100%','desktop'],[390,844,'100%','mobile'],[320,640,'200%','text200']]){
  await page.setViewportSize({width,height});await page.evaluate(size=>{document.documentElement.style.fontSize=size;window.scrollTo(0,0);},size);await page.getByRole('button',{name:'Desbloquear cuenta',exact:true}).scrollIntoViewIfNeeded();
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,name+' overflow');await page.screenshot({path:fileURLToPath(new URL(name+'-list.png',output)),fullPage:true});
  await page.getByRole('button',{name:'Desbloquear cuenta',exact:true}).click();await page.getByRole('dialog').waitFor();assert.equal(await page.getByRole('dialog').evaluate(el=>el.scrollWidth<=el.clientWidth),true,name+' dialog overflow');
  await page.screenshot({path:fileURLToPath(new URL(name+'-dialog.png',output))});await page.getByRole('dialog').getByRole('button',{name:'Desbloquear',exact:true}).scrollIntoViewIfNeeded();await page.screenshot({path:fileURLToPath(new URL(name+'-dialog-action.png',output))});await page.keyboard.press('Escape');await page.getByRole('dialog').waitFor({state:'hidden'});
 }
 await page.evaluate(()=>document.documentElement.style.fontSize='100%');await page.setViewportSize({width:390,height:844});await page.reload();await page.getByRole('button',{name:'Desbloquear cuenta',exact:true}).waitFor();assert.equal(server.entry().enabled,true);
 server.failList(true);await page.getByRole('button',{name:'Consultar bloqueos',exact:true}).click();await page.getByRole('alert').waitFor();assert.equal(await page.getByText('Reportante de Luna',{exact:true}).count(),1);
 server.failList(false);await page.getByRole('button',{name:'Consultar bloqueos',exact:true}).click();await page.getByRole('button',{name:'Desbloquear cuenta',exact:true}).click();await page.getByRole('dialog').getByRole('button',{name:'Desbloquear',exact:true}).click();await page.getByRole('button',{name:'Bloquear cuenta del reportante',exact:true}).waitFor();assert.equal(server.entry().enabled,false);
 await page.emulateMedia({reducedMotion:'reduce'});await page.goto(server.origin+'/cuentas-bloqueadas');await page.getByText('No tienes cuentas bloqueadas.',{exact:true}).waitFor();assert.deepEqual(errors,[]);
 console.log(JSON.stringify({pass:true,checks:['global access','profile entry','normal and reduced motion','cancel','ambiguous replay','reload persistence','retained refresh failure','unblock','1440/390/320 text200','safe payload','no CSP/hydration errors'],writes:server.writes(),screenshots:fileURLToPath(output)}));
 await context.close();
} finally {await browser.close();await server.close();}
