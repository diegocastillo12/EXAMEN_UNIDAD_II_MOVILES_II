import assert from'node:assert/strict';
import{mkdir,writeFile}from'node:fs/promises';
import{fileURLToPath,pathToFileURL}from'node:url';
import{matchingFixture}from'../tests/matching_fixture.mjs';
const{chromium}=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await matchingFixture();
const output=new URL('../../mobile/build/ui-preview/case-matching/web/',import.meta.url);await mkdir(output,{recursive:true});
const errors=[],frames=[];
try{
 const page=await browser.newPage({viewport:{width:1440,height:1000}});page.setDefaultTimeout(20000);
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 await page.goto(server.origin+'/iniciar-sesion');await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');await page.waitForURL('**/inicio');
 for(const width of[1440,390,320]){
  await page.setViewportSize({width,height:1000});
  const trigger=page.getByRole('link',{name:'Buscar coincidencias',exact:true});await trigger.waitFor();await trigger.scrollIntoViewIfNeeded();await page.waitForTimeout(350);const source=await trigger.boundingBox();
  await page.evaluate(()=>{window.matchObserver=new MutationObserver(()=>{const target=document.querySelector('[data-origin-animating]');if(target?._flip&&!target._flip.__qaPaused){target._flip.__qaPaused=true;target._flip.pause().progress(0);}});window.matchObserver.observe(document.documentElement,{subtree:true,attributes:true,attributeFilter:['data-origin-animating']});});
  await trigger.click();await page.waitForURL('**/coincidencias');await page.waitForFunction(()=>document.querySelector('main[data-origin-animating="opening"]')?._flip?.paused());
  const surface=page.locator('main[data-origin-content]:not([data-origin-underlay] *)');
  const initial=await surface.evaluate(node=>{const r=node.getBoundingClientRect();return{x:r.x,y:r.y,width:r.width,height:r.height,duration:node._flip.duration()};});
  for(const k of['x','y','width','height'])assert.ok(Math.abs(initial[k]-source[k])<1,`${width} starts at ${k}`);assert.equal(initial.duration,.7);
  for(const progress of[0,.15,.45,.99]){
   await surface.evaluate((node,p)=>{node._flip.progress(p);for(const a of node.getAnimations({subtree:true})){a.pause();a.currentTime=p*700;}},progress);
   const box=await surface.boundingBox();frames.push({width,opening:progress,box});if(progress===.99)assert.ok(Math.abs(box.width-width)<3&&Math.abs(box.height-1000)<3,'Fullscreen destination');
   await page.screenshot({path:fileURLToPath(new URL(`${width}-opening-${progress}.png`,output))});
  }
  await surface.evaluate(node=>{node._flip.progress(1);for(const a of node.getAnimations({subtree:true}))a.finish();});
  await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('Posible coincidencia',{exact:true}).waitFor();
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
  await page.screenshot({path:fileURLToPath(new URL(`${width}-results.png`,output)),fullPage:true});
  const close=page.getByRole('button',{name:'Volver a inicio',exact:true}).click();await page.waitForFunction(()=>document.querySelector('main[data-origin-animating="closing"]')?._flip?.paused());
  for(const progress of[.5,.95]){await surface.evaluate((node,p)=>{node._flip.progress(p);for(const a of node.getAnimations({subtree:true})){a.pause();a.currentTime=p*700;}},progress);frames.push({width,closing:progress,box:await surface.boundingBox()});await page.screenshot({path:fileURLToPath(new URL(`${width}-closing-${progress}.png`,output))});}
  await surface.evaluate(node=>{node._flip.progress(1);for(const a of node.getAnimations({subtree:true}))a.finish();});await close;await page.waitForURL('**/inicio');await page.evaluate(()=>window.matchObserver.disconnect());
 }
 await page.emulateMedia({reducedMotion:'reduce'});await page.getByRole('link',{name:'Buscar coincidencias',exact:true}).click();await page.waitForURL('**/coincidencias');await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('Posible coincidencia',{exact:true}).waitFor();
 await page.getByRole('button',{name:'Coincide',exact:true}).click();await page.getByText('Tu revisión: Coincidencia confirmada.').waitFor();
 await page.getByRole('link',{name:'Ver ficha',exact:true}).click();await page.waitForURL('**/casos/encontrados/*');await page.getByText('Orejas blancas y pelaje claro',{exact:true}).waitFor();assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
 await page.getByRole('button',{name:'Volver',exact:true}).click();await page.waitForURL('**/coincidencias');await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).waitFor();
 await page.evaluate(()=>{document.documentElement.style.fontSize='200%';});await page.screenshot({path:fileURLToPath(new URL('320-text-200.png',output)),fullPage:true});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
 await page.evaluate(()=>{document.documentElement.style.fontSize='';});
 await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).waitFor();server.fail(true);await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('No pudimos comparar las publicaciones. Puedes reintentar.',{exact:true}).waitFor();server.fail(false);await page.getByRole('button',{name:'Buscar coincidencias',exact:true}).click();await page.getByText('Posible coincidencia',{exact:true}).waitFor();
 assert.deepEqual(errors,[]);await writeFile(new URL('motion-frames.json',output),JSON.stringify({frames,errors},null,2));console.log('Matching Chrome: origin/fullscreen/return 1440/390/320, reduced motion, review, live detail, 200% text and retry PASS');
}finally{await browser.close();await server.close();}
