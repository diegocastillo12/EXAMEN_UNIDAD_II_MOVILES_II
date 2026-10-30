import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {appealsFixture} from '../tests/appeals_fixture.mjs';
const runtime=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href),{chromium}=runtime.default||runtime;
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true});
const server=await appealsFixture(),output=new URL('../../mobile/build/ui-preview/appeals-web/',import.meta.url);await mkdir(output,{recursive:true});
try{
 const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'no-preference'}),page=await context.newPage(),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',msg=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch|Failed to resolve component/.test(msg.text()))errors.push(msg.text());});
 const login=async email=>{await page.getByLabel('Correo',{exact:true}).fill(email);await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.locator('.login-form button[type=submit]').click();await page.waitForURL('**/inicio');};
 await page.goto(server.origin+'/apelaciones');await page.waitForURL('**/iniciar-sesion');await login('ordinario@example.test');
 await page.getByRole('link',{name:'Mis apelaciones',exact:true}).click();await page.getByRole('button',{name:'Apelar decisión',exact:true}).click();
 await page.getByRole('button',{name:'Enviar apelación',exact:true}).click();await page.getByRole('alert').filter({hasText:'Escribe un motivo'}).waitFor();
 await page.getByLabel('Motivo de la apelación').fill('🐾'.repeat(1001));assert.equal([...await page.getByLabel('Motivo de la apelación').inputValue()].length,1000);await page.getByText('1000/1000',{exact:true}).waitFor();
 await page.getByLabel('Motivo de la apelación').fill('Solicito revisar esta decisión sobre mi publicación.');
 await page.getByRole('button',{name:'Volver',exact:true}).click();await page.getByRole('dialog').getByRole('button',{name:'Cancelar',exact:true}).click();assert.equal(await page.getByLabel('Motivo de la apelación').inputValue(),'Solicito revisar esta decisión sobre mi publicación.');
 await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();await page.getByRole('dialog').getByRole('button',{name:'Cancelar',exact:true}).click();assert.equal(new URL(page.url()).pathname,'/apelaciones');
 for(const [name,width,height,enlarged]of [['desktop',1440,1000,false],['reference',731,1000,false],['mobile',390,844,false],['small',320,700,false],['wide',1920,1000,false],['small-text',320,700,true]]){
  await page.setViewportSize({width,height});await page.evaluate(enlarged=>{document.documentElement.style.fontSize=enlarged?'200%':'100%';},enlarged);await page.waitForTimeout(100);
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,name+' has overflow');
  await page.screenshot({path:fileURLToPath(new URL(name+'-form.png',output)),fullPage:true});
 }
 await page.evaluate(()=>{document.documentElement.style.fontSize='100%';});await page.setViewportSize({width:1440,height:1000});
 server.ambiguousAppeal();await page.getByRole('button',{name:'Enviar apelación',exact:true}).click();await page.getByRole('alert').filter({hasText:'No pudimos confirmar'}).waitFor();assert.equal(server.submissions(),1);assert.equal(await page.getByLabel('Motivo de la apelación').isDisabled(),true);
 await page.getByRole('button',{name:'Reintentar mismo envío',exact:true}).click();await page.getByText('Pendiente de respuesta',{exact:true}).waitFor();assert.equal(server.submissions(),1);
 await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();await page.waitForURL('**/iniciar-sesion');await login('moderador@example.test');
 await page.getByRole('link',{name:'Revisar denuncias',exact:true}).click();await page.getByRole('link',{name:'Revisar apelaciones',exact:true}).click();await page.getByRole('button',{name:'Consultar apelación',exact:true}).click();
 await page.getByLabel('Respuesta y motivo').fill('La apelación se revisó. Se mantiene la decisión por el motivo indicado.');
 await page.getByRole('button',{name:'Guardar respuesta',exact:true}).click();await page.getByRole('heading',{name:'Respuesta de moderación'}).waitFor();assert.equal(server.answers(),1);
 await page.screenshot({path:fileURLToPath(new URL('desktop-answer.png',output)),fullPage:true});
 await page.emulateMedia({reducedMotion:'reduce'});await page.keyboard.press('Tab');assert.equal(await page.evaluate(()=>document.activeElement!==document.body),true);
 server.revokeAppeals(true);await page.getByRole('button',{name:'Actualizar consulta',exact:true}).click();await page.getByRole('alert').filter({hasText:'No tienes permiso'}).waitFor();assert.equal(await page.getByText('Solicito revisar esta decisión sobre mi publicación.',{exact:true}).count(),0);
 server.revokeAppeals(false);await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();await page.waitForURL('**/iniciar-sesion');await login('ordinario@example.test');
 await page.getByRole('link',{name:'Mis apelaciones',exact:true}).click();await page.getByRole('button',{name:'Consultar apelación',exact:true}).click();await page.getByText('La apelación se revisó. Se mantiene la decisión por el motivo indicado.',{exact:true}).waitFor();
 assert.deepEqual(errors,[]);await context.close();
 console.log('Appeals Chrome QA passed: own submission, validation, discard cancellation, frozen retry once, reviewer answer, owner response, revocation cleanup, keyboard, normal/reduced motion, CSP/hydration and 1440/731/390/320/1920 + 200% text. Local fixture only.');
}finally{await browser.close();await server.close();}
