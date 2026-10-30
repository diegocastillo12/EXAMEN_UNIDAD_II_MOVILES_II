import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {fileURLToPath,pathToFileURL} from 'node:url';
import sharp from 'sharp';
import {moderationFixture} from '../tests/moderation_fixture.mjs';
const runtime=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href),{chromium}=runtime.default||runtime;
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true});
const jpeg=await sharp({create:{width:400,height:300,channels:3,background:'#b5d5e9'}}).jpeg().toBuffer();
const server=await moderationFixture(jpeg),output=new URL('../../mobile/build/ui-preview/moderation-web/',import.meta.url);await mkdir(output,{recursive:true});
try{
 const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),page=await context.newPage(),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',msg=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(msg.text()))errors.push(msg.text());});
 await page.goto(server.origin+'/moderacion',{waitUntil:'networkidle'});await page.getByRole('heading',{name:'Inicia sesión'}).waitFor();
 assert.equal(new URL(page.url()).pathname,'/iniciar-sesion');
 await page.screenshot({path:fileURLToPath(new URL('desktop-login.png',output)),fullPage:true});
 await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.locator('.login-form button[type=submit]').click();await page.waitForURL('**/inicio');await page.goto(server.origin+'/moderacion');await page.waitForURL('**/inicio');await page.getByRole('alert').filter({hasText:'no tiene permiso'}).waitFor();
 assert.equal(await page.getByText('PRIVATE_REPORT_REASON').count(),0);
 await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();await page.waitForURL('**/iniciar-sesion');await page.getByLabel('Correo',{exact:true}).fill('moderador@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');
 await page.waitForURL('**/inicio');await page.getByRole('link',{name:'Revisar denuncias',exact:true}).click();await page.getByRole('heading',{name:'Denuncias',exact:true}).waitFor();assert.equal(new URL(page.url()).pathname,'/moderacion');await page.getByRole('button',{name:'Revisar denuncia',exact:true}).click();
 await page.getByText('PRIVATE_REPORT_REASON',{exact:true}).waitFor();await page.getByRole('button',{name:'Ver foto del contenido'}).click();
 await page.locator('img.moderation-photo').waitFor();await page.waitForFunction(()=>document.querySelector('.moderation-photo')?.naturalWidth>0);
 await page.getByRole('radio',{name:'Ocultar contenido',exact:true}).check();await page.getByLabel('Motivo de la decisión (obligatorio)').fill('Ocultar mientras se revisa el contenido.');
 server.ambiguousDecision();await page.getByRole('button',{name:'Guardar decisión',exact:true}).click();await page.getByRole('dialog').getByRole('button',{name:'Guardar decisión',exact:true}).click();
 await page.getByRole('button',{name:'Reintentar decisión',exact:true}).waitFor();assert.equal(server.decisions(),1);assert.equal(await page.getByLabel('Motivo de la decisión (obligatorio)').isDisabled(),true);
 await page.getByRole('button',{name:'Reintentar decisión',exact:true}).click();await page.getByRole('heading',{name:'Decisión registrada'}).waitFor();assert.equal(server.decisions(),1);
 await page.getByRole('button',{name:'Consultar estado actual',exact:true}).click();await page.getByText('Oculto',{exact:true}).waitFor();
 if(await page.locator('#notice-close').isVisible())await page.locator('#notice-close').click();
 await page.locator('h1').focus();await page.evaluate(()=>scrollTo(0,0));
 for(const [name,width,height,enlarged]of [['desktop',1440,1000,false],['reference',731,1000,false],['mobile',390,844,false],['small',320,700,false],['wide',1920,1000,false],['small-text',320,700,true]]){
  await page.setViewportSize({width,height});await page.evaluate(enlarged=>{document.documentElement.style.fontSize=enlarged?'200%':'100%';},enlarged);
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,name+' has horizontal overflow');
  await page.screenshot({path:fileURLToPath(new URL(name+'-detail.png',output)),fullPage:true});
 }
 await page.evaluate(()=>{document.documentElement.style.fontSize='100%';});await page.setViewportSize({width:1440,height:1000});
 await page.getByRole('radio',{name:'Restaurar visibilidad',exact:true}).check();await page.getByLabel('Motivo de la decisión (obligatorio)').fill('Contenido revisado y permitido.');
 await page.getByRole('button',{name:'Guardar decisión',exact:true}).click();await page.getByRole('dialog').getByRole('button',{name:'Guardar decisión',exact:true}).click();await page.getByRole('heading',{name:'Decisión registrada'}).waitFor();assert.equal(server.hidden(),false);
 await page.getByRole('button',{name:'Volver a denuncias'}).click();await page.getByRole('heading',{name:'No hay denuncias pendientes'}).waitFor();
 await page.getByRole('button',{name:'Resueltas',exact:true}).click();await page.getByRole('button',{name:'Revisar denuncia',exact:true}).waitFor();
 await page.screenshot({path:fileURLToPath(new URL('desktop-queue.png',output)),fullPage:true});
 await page.getByRole('button',{name:'Revisar denuncia',exact:true}).click();await page.getByText('PRIVATE_REPORT_REASON',{exact:true}).waitFor();
 await page.getByLabel('Motivo de la decisión (obligatorio)').fill('Borrador que se conserva al cancelar.');await page.getByRole('button',{name:'Volver a denuncias'}).click();await page.getByRole('dialog').getByRole('button',{name:'Cancelar',exact:true}).click();assert.equal(await page.getByLabel('Motivo de la decisión (obligatorio)').inputValue(),'Borrador que se conserva al cancelar.');
 await page.getByLabel('Motivo de la decisión (obligatorio)').fill('');server.revoke(true);await page.getByRole('button',{name:'Volver a denuncias'}).click();await page.waitForURL('**/inicio');await page.getByRole('heading',{name:'Su regreso empieza contigo',exact:true}).waitFor();assert.equal(await page.getByText('PRIVATE_REPORT_REASON').count(),0);
 await page.keyboard.press('Tab');assert.equal(await page.evaluate(()=>document.activeElement!==document.body),true);
 await page.goto(server.origin);assert.equal(await page.locator('h1').count(),1);await page.goto(server.origin+'/c/'+ 'a'.repeat(64));await page.locator('h1').waitFor();
 assert.deepEqual(errors,[]);await context.close();
 console.log('Moderation Chrome QA passed: role denial, password Enter, queue/detail/evidence, ambiguous retry once, restoration, discard cancellation, revocation, keyboard, reduced motion, CSP/hydration, 1440/731/390/320/1920 and 200% text, landing/QR return. Fixture backend only.');
}finally{await browser.close();await server.close();}
