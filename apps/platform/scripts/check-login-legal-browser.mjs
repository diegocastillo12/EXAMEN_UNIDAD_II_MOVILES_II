import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {productionFixture} from '../tests/server_fixture.mjs';
const runtime=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href),{chromium}=runtime.default||runtime;
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await productionFixture();
const output=new URL('../../mobile/build/ui-preview/login-legal/',import.meta.url);await mkdir(output,{recursive:true});
try{
 const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'no-preference'}),page=await context.newPage(),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 await page.goto(server.origin+'/iniciar-sesion',{waitUntil:'networkidle'});await page.getByRole('heading',{name:'Inicia sesión'}).waitFor();
 assert.equal(await page.locator('.background-glow--strong').count(),1);
 const motion=await page.locator('.background-glow__primary').evaluate(el=>{const a=el.getAnimations()[0];a.pause();a.currentTime=0;const initial=getComputedStyle(el).transform;a.currentTime=4250;return[initial,getComputedStyle(el).transform];});assert.notEqual(motion[0],motion[1]);
 const icon=page.locator('.site-brand');assert.equal(await icon.evaluate(el=>el.getAnimations().length),0);
 await page.getByLabel('Correo',{exact:true}).fill('reveal-check@example.test');
 await page.emulateMedia({reducedMotion:'reduce'});assert.equal(await page.locator('.background-glow').evaluate(el=>el.getAnimations({subtree:true}).length),0);
 await page.getByRole('link',{name:'Términos de servicio',exact:true}).click();await page.waitForURL('**/terminos');await page.getByRole('heading',{name:'Términos de servicio',exact:true}).waitFor();
 for(const kind of ['terminos','privacidad']){
  const response=await fetch(server.origin+'/'+kind),html=await response.text();assert.equal(response.status,200);assert.match(html,/sergiotlv51@gmail.com/);assert.doesNotMatch(html,/MVP|borrador|pendiente de aprobaci/);
  await page.goto(server.origin+'/'+kind,{waitUntil:'networkidle'});assert.equal(await page.locator('h1').count(),1);assert.equal(await page.locator('.legal-content section').count(),kind==='terminos'?8:9);
  assert.equal(await page.getByRole('link',{name:'Contactar',exact:true}).getAttribute('href'),'mailto:sergiotlv51@gmail.com');
  await page.evaluate(()=>document.fonts.ready);
  assert.equal(await page.locator('.legal-scroll').evaluate(el=>getComputedStyle(el).fontFamily.includes('DM Sans')),true);
  assert.equal(await page.evaluate(()=>document.fonts.check('16px "DM Sans"')),true);
  assert.equal(await page.locator('.legal-metadata .app-icon').count(),2);
  const backIcon=page.getByRole('button',{name:'Volver al inicio de sesión',exact:true});
  assert.equal(await backIcon.locator('svg.app-icon').count(),1);assert.equal(await backIcon.innerText(),'');
  assert.equal(await backIcon.locator('svg').evaluate(el=>getComputedStyle(el).width),'16px');
  assert.equal(await backIcon.evaluate(el=>getComputedStyle(el).backdropFilter),'blur(22px)');
  assert.equal(await page.locator('.legal-index').count(),0);
  assert.equal(await page.locator('h1').evaluate(el=>getComputedStyle(el).fontSize),'45px');
  assert.equal(await page.locator('.legal-content h2').first().evaluate(el=>getComputedStyle(el).fontSize),'32px');
  assert.equal(await page.locator('.legal-content p').first().evaluate(el=>getComputedStyle(el).fontSize),'16px');
  assert.equal(await page.locator('.background-glow').evaluate(el=>getComputedStyle(el).position),'fixed');
  assert.equal(await page.locator('.background-glow').evaluate(el=>getComputedStyle(el).maskImage),'none');
  const toolbar=await page.locator('.legal-toolbar').boundingBox(),back=await page.getByRole('button',{name:'Volver al inicio de sesión',exact:true}).boundingBox();
  assert.ok(back.x>=toolbar.x&&back.y>=toolbar.y);assert.ok(back.x>16&&back.y>16);
  assert.equal(await page.locator('.legal-metadata svg').count(),2);
  assert.equal(await page.locator('.legal-switch svg').count(),1);
  assert.equal(await page.getByRole('button',{name:'Volver al inicio de sesión',exact:true}).evaluate(el=>getComputedStyle(el).position),'static');
  await page.emulateMedia({reducedMotion:'no-preference'});
  const legalMotion=await page.locator('.background-glow__primary').evaluate(el=>{const animation=el.getAnimations()[0];animation.pause();animation.currentTime=0;const first=getComputedStyle(el).transform;animation.currentTime=4250;return[first,getComputedStyle(el).transform];});assert.notEqual(legalMotion[0],legalMotion[1]);
  await page.locator('.background-glow__viewport').evaluate(el=>el.getAnimations()[0].finish());assert.equal(await page.locator('.background-glow__viewport').evaluate(el=>getComputedStyle(el).opacity),'0.5');
  const orbTop=await page.locator('.background-glow').evaluate(el=>el.getBoundingClientRect().top);
  await page.locator('.legal-content section').last().scrollIntoViewIfNeeded();
  assert.equal(await page.locator('.background-glow').evaluate(el=>el.getBoundingClientRect().top),orbTop);
  assert.ok(await page.locator('.legal-scroll').evaluate(el=>el.scrollTop>0));
  await page.emulateMedia({reducedMotion:'reduce'});
  await page.screenshot({path:fileURLToPath(new URL(kind+'-scrolled.png',output))});
  await page.getByRole('button',{name:'Volver al inicio de sesión',exact:true}).click();await page.waitForURL('**/iniciar-sesion');await page.getByRole('link',{name:kind==='terminos'?'Política de privacidad':'Términos de servicio',exact:true}).click();
 }
 for(const [name,width,height,enlarged]of[['desktop',1440,1000,false],['mobile',390,844,false],['small-text',320,700,true]]){
  await page.setViewportSize({width,height});await page.evaluate(enlarged=>{document.documentElement.style.fontSize=enlarged?'200%':'100%';},enlarged);
  for(const route of ['iniciar-sesion','terminos','privacidad']){
   await page.goto(server.origin+'/'+route,{waitUntil:'networkidle'});await page.evaluate(enlarged=>{document.documentElement.style.fontSize=enlarged?'200%':'100%';},enlarged);
   assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,name+' '+route+' overflow');
   await page.screenshot({path:fileURLToPath(new URL(name+'-'+route+'.png',output)),fullPage:true});
  }
 }
 const noJs=await browser.newContext({javaScriptEnabled:false,viewport:{width:390,height:844}}),plain=await noJs.newPage();await plain.goto(server.origin+'/iniciar-sesion');await plain.getByRole('link',{name:'Política de privacidad',exact:true}).click();await plain.getByRole('heading',{name:'Política de privacidad',exact:true}).waitFor();assert.equal(await plain.locator('.legal-content section').count(),9);await noJs.close();
 assert.deepEqual(errors,[]);await context.close();console.log('Login/legal Chrome QA passed: strong moving orb, persistent shared brand, legal fixed orb during scroll, toolbar return, metadata icons, sader-panel typography, local DM Sans only in legal pages, official filled Material icons and vector glass chevron, no replay on edit, reduced motion static, links/return/anchors/mail contact, terms/privacy SSR and no-JS, no draft/MVP copy, 1440/390/320/text200%, no overflow/CSP/hydration errors.');
}finally{await browser.close();await server.close();}
