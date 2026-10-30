import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {productionFixture} from '../tests/server_fixture.mjs';
const runtime=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href),{chromium}=runtime.default||runtime;
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await productionFixture();
const output=new URL('../../mobile/build/ui-preview/login-reload/',import.meta.url);await mkdir(output,{recursive:true});
const selectors=['.login-heading h1','.login-heading>p','.login-form','.login-legal'];
try{
 const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'no-preference'}),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 await page.addInitScript(selectors=>{
  window.revealFrames=[];
  let start;
  function frame(time){
   const elements=selectors.map(s=>document.querySelector(s));
   if(elements.every(Boolean)){
    start??=time;
    window.revealFrames.push({time:time-start,items:elements.map(el=>{const s=getComputedStyle(el),r=el.getBoundingClientRect();return{y:r.y,x:r.x,opacity:+s.opacity,filter:s.filter,transform:s.transform,font:s.fontFamily,willChange:s.willChange,transition:s.transitionProperty,duration:s.transitionDuration,delay:s.transitionDelay,animations:el.getAnimations().map(a=>a.constructor.name)};})});
   }
   if(start===undefined||time-start<2000)requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
 },selectors);
 for(let attempt=0;attempt<2;attempt++){
  if(attempt)await page.reload({waitUntil:'networkidle'});else await page.goto(server.origin+'/iniciar-sesion',{waitUntil:'networkidle'});
  await page.waitForFunction(()=>window.revealFrames.at(-1)?.time>1900);
  const frames=await page.evaluate(()=>window.revealFrames);
  assert.ok(frames.some(f=>f.items.some(i=>i.animations.includes('CSSTransition'))),'real CSS transitions must run after hydration');
  assert.ok(frames.some(f=>f.items[1].opacity>0&&f.items[1].opacity<1),'content must reveal gradually');
  const last=frames.at(-1);
  assert.ok(last.items.every(i=>i.opacity===1&&i.filter==='blur(0px)'&&i.transform==='matrix(1, 0, 0, 1, 0, 0)'));
  assert.ok(last.items.every(i=>i.willChange==='opacity, filter, transform'&&i.duration==='0.85s, 0.85s, 0.85s'));
  assert.deepEqual(last.items.map(i=>i.delay),['0s','0.09s','0.18s','0.27s']);
  assert.ok(frames.filter(f=>f.time>1500).every(f=>f.items[1].y===last.items[1].y&&f.items[1].x===last.items[1].x),'brand stays in place after reveal');
  assert.equal(last.items[1].font,'Arial, Helvetica, sans-serif');
  assert.equal(await page.locator('.login-form').evaluate(el=>getComputedStyle(el,'::before').content),'none');
  const before=await page.locator('.site-brand').boundingBox();
  await page.getByLabel('Correo',{exact:true}).fill('animation@example.test');
  assert.deepEqual(await page.locator('.site-brand').boundingBox(),before);
  assert.equal(await page.locator('.site-brand').evaluate(el=>el.getAnimations().length),0);
  await page.mouse.move(1400,950);
  await page.screenshot({path:fileURLToPath(new URL('reload-settled-'+attempt+'.png',output))});
 }
 await page.emulateMedia({reducedMotion:'reduce'});await page.reload({waitUntil:'networkidle'});
 for(const s of selectors){const v=await page.locator(s).evaluate(el=>{const s=getComputedStyle(el);return{opacity:s.opacity,filter:s.filter,transform:s.transform,animations:el.getAnimations().length};});assert.deepEqual(v,{opacity:'1',filter:'none',transform:'none',animations:0});}
 for(const [width,enlarged]of [[390,false],[320,true]]){await page.setViewportSize({width,height:700});await page.evaluate(enlarged=>document.documentElement.style.fontSize=enlarged?'200%':'100%',enlarged);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);await page.screenshot({path:fileURLToPath(new URL('small-'+width+'.png',output)),fullPage:true});}
 assert.deepEqual(errors,[]);console.log('Login reload QA passed: real sader-panel CSS transitions, four 850ms/90ms groups, permanent will-change, stable final brand, persistent shared header, no restart on editing, reduced motion, 390/320/text200%, no overflow/CSP/hydration errors.');
}finally{await browser.close();await server.close();}
