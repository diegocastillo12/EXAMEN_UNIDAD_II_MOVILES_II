import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {productionFixture} from '../tests/server_fixture.mjs';
import {slug} from '../tests/fixtures.mjs';
import sharp from 'sharp';
const runtime=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href),{chromium}=runtime.default||runtime;
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await productionFixture(await sharp({create:{width:40,height:40,channels:3,background:'#aaa'}}).jpeg().toBuffer());
const output=new URL('../../mobile/build/ui-preview/web-toast/',import.meta.url);await mkdir(output,{recursive:true});
try{
 const page=await browser.newPage({viewport:{width:1440,height:1000},hasTouch:true}),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 await page.goto(server.origin+'/iniciar-sesion',{waitUntil:'networkidle'});
 const submit=page.locator('.login-submit'),toast=page.locator('#notice');
 await submit.click();await toast.waitFor({state:'visible'});
 const entry=await toast.evaluate(el=>{
  const animation=el.getAnimations().find(a=>a.transitionProperty==='transform');
  if(!animation) return null;
  animation.pause();animation.currentTime=0;const start=el.getBoundingClientRect().bottom;
  animation.currentTime=140;const middle=el.getBoundingClientRect().top;
  animation.finish();return{start,middle};
 });
 assert.ok(entry&&entry.start<=0&&entry.middle<12,'Notice enters from above the viewport');
 await page.waitForTimeout(550);
 assert.equal(await toast.getAttribute('role'),'alert');
 const style=await toast.evaluate(el=>{const s=getComputedStyle(el),i=getComputedStyle(el.querySelector('.notice-icon')),svg=el.querySelector('svg');return{background:s.backgroundColor,radius:s.borderRadius,blur:s.backdropFilter,maxWidth:s.maxWidth,top:s.top,color:i.color,icon:i.width,svg:svg.getBoundingClientRect().width,text:el.textContent};});
 assert.match(style.background,/rgba\(245, 245, 247, 0\.9[0-9]*\)/);assert.equal(style.radius,'28px');assert.equal(style.blur,'blur(18px)');assert.equal(style.maxWidth,'360px');assert.equal(style.top,'12px');assert.equal(style.color,'rgb(181, 63, 72)');assert.equal(style.icon,'32px');assert.equal(style.svg,20);assert.ok(!style.text.includes('×'));
 await page.screenshot({path:fileURLToPath(new URL('desktop-error.png',output))});
 await page.locator('#notice-close').focus();await page.keyboard.press('Enter');await toast.waitFor({state:'hidden'});
 // Mouse drags follow the pointer, rebound if short/downward and suppress click-to-close.
 async function show(){await submit.click();await toast.waitFor({state:'visible'});await page.waitForTimeout(550);}
 async function mouseDrag(dy){const r=await toast.boundingBox(),x=r.x+24,y=r.y+r.height-6;await page.mouse.move(x,y);await page.mouse.down();await page.mouse.move(x,y+dy,{steps:6});return{r,x,y};}
 await show();let drag=await mouseDrag(-10);assert.ok((await toast.boundingBox()).y<drag.r.y-8);await page.mouse.up();await page.waitForTimeout(480);assert.ok(Math.abs((await toast.boundingBox()).y-12)<1);
 await mouseDrag(50);assert.ok((await toast.boundingBox()).y<=30);await page.mouse.up();await page.waitForTimeout(480);await toast.waitFor({state:'visible'});
 await mouseDrag(-44);await page.mouse.up();await toast.waitFor({state:'hidden'});
 await show();await mouseDrag(-14);await toast.dispatchEvent('pointercancel',{pointerId:1,isPrimary:true,pointerType:'mouse'});await page.mouse.up();await page.waitForTimeout(480);await toast.waitFor({state:'visible'});
 await page.locator('#notice-close').focus();await page.keyboard.press('Escape');await toast.waitFor({state:'hidden'});
 // Real browser touch events exercise pointer capture and touch-action, beyond synthetic handlers.
 await page.setViewportSize({width:390,height:700});await show();
 const cdp=await page.context().newCDPSession(page),r=await toast.boundingBox(),x=r.x+24,y=r.y+r.height-5;
 await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x,y}]});
 await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x,y:y-20}]});
 assert.ok((await toast.boundingBox()).y<0,'Touch drag tracks finger');
 await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x,y:y-44}]});
 await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});await toast.waitFor({state:'hidden'});await cdp.detach();
 for(const [width,enlarged]of [[1920,false],[1440,false],[731,false],[390,false],[320,true]]){
  await page.setViewportSize({width,height:700});await page.evaluate(v=>document.documentElement.style.fontSize=v?'200%':'100%',enlarged);
  await show();
  const rect=await toast.boundingBox();assert.ok(rect.x>=23&&rect.x+rect.width<=width-23);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
  await page.screenshot({path:fileURLToPath(new URL('error-'+width+'.png',output)),fullPage:true});
  await page.locator('#notice-close').click();
  await toast.waitFor({state:'hidden'});
 }
 // A swipe on Retry must never invoke the callback; an ordinary tap still does.
 await page.evaluate(()=>document.documentElement.style.fontSize='100%');
 await page.goto(server.origin+'/c/'+slug,{waitUntil:'networkidle'});server.fail(true);
 await page.getByRole('button',{name:'Actualizar estado'}).click();await toast.waitFor({state:'visible'});await page.waitForTimeout(550);
 await page.locator('#notice-retry').waitFor();let reads=server.reads();
 const retryBox=await page.locator('#notice-retry').boundingBox();await page.mouse.move(retryBox.x+10,retryBox.y+retryBox.height-4);await page.mouse.down();await page.mouse.move(retryBox.x+10,retryBox.y+retryBox.height-48,{steps:6});await page.mouse.up();await toast.waitFor({state:'hidden'});assert.equal(server.reads(),reads);
 await page.getByRole('button',{name:'Actualizar estado'}).click();await toast.waitFor({state:'visible'});await page.waitForTimeout(550);server.fail(false);reads=server.reads();
 await page.locator('#notice-retry').click();await toast.waitFor({state:'hidden'});await page.waitForTimeout(300);assert.ok(server.reads()>reads);
 await page.emulateMedia({reducedMotion:'reduce'});await page.goto(server.origin+'/iniciar-sesion?reason=signed-out',{waitUntil:'networkidle'});await toast.waitFor({state:'visible'});
 assert.equal(await toast.getAttribute('role'),'status');assert.equal(await toast.locator('.notice-icon').evaluate(el=>getComputedStyle(el).color),'rgb(17, 17, 17)');assert.equal(await toast.evaluate(el=>el.getAnimations().length),0);
 await page.screenshot({path:fileURLToPath(new URL('success-reduced-motion.png',output)),fullPage:true});
 await toast.waitFor({state:'hidden',timeout:8000});
 assert.deepEqual(errors,[]);console.log('Toast QA passed: top entry, mouse/touch swipe dismissal, short/downward/cancelled rebound, retry swipe/tap, tap/keyboard/Escape, expiry, reduced motion, 1920/1440/731/390/320/text200%, no overflow/CSP/hydration errors.');
}finally{await browser.close();await server.close();}
