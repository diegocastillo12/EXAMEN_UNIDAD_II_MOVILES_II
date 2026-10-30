import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {recoveryFixture} from '../tests/recovery_fixture.mjs';
const {chromium}=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true});
let server=await recoveryFixture();
const output=new URL('../../mobile/build/ui-preview/web-origin-sader/',import.meta.url);
await mkdir(output,{recursive:true});
try {
 for(const mode of ['nine','shortcut']) {
  if(mode==='shortcut'){await server.close();server=await recoveryFixture();}
  for(const width of (process.env.ORIGIN_WIDTHS?process.env.ORIGIN_WIDTHS.split(',').map(Number):[1852,1255,390,320])) {
   const origin=process.env.BROWSER_ORIGIN||server.origin;
   const page=await browser.newPage({viewport:{width,height:844},reducedMotion:'no-preference'});
   page.setDefaultTimeout(15000);
   const errors=[];page.on('pageerror',error=>{errors.push(error.message);console.log('Browser error',error.message);});
   if(origin!==server.origin)await page.route('**/api/**',async route=>{
    const url=new URL(route.request().url());
    const response=await route.fetch({url:server.origin+url.pathname+url.search,headers:{...route.request().headers(),origin:server.origin}});
      if(!page.isClosed())await route.fulfill({response}).catch(error=>{if(!page.isClosed())throw error;});
   });
   await page.route('https://basemaps.cartocdn.com/**',route=>route.fulfill({status:200,contentType:'image/jpeg',body:server.jpeg}));
   await page.goto(origin+'/iniciar-sesion');
   await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');
   await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');
   await page.getByLabel('Contraseña',{exact:true}).press('Enter');
   const nav=page.getByRole('navigation',{name:'Navegación de usuario'});
   await nav.waitFor();await page.waitForTimeout(500);
   if(process.env.ORIGIN_TEXT_SCALE)await page.evaluate(scale=>{document.documentElement.style.fontSize=scale;},process.env.ORIGIN_TEXT_SCALE);
   const trigger=mode==='nine'?nav.getByRole('link',{name:'Reportar',exact:true}):page.getByRole('navigation',{name:'Accesos de Inicio'}).getByRole('link',{name:'Reportar',exact:true});
   const source=await trigger.boundingBox();
   const sourceIcon=await trigger.locator('svg,img').first().boundingBox();
   const surface=page.locator('main[data-origin-content]:not([data-origin-underlay] *)');
   // Pause the actual GSAP Flip timeline at creation, not a substitute WAAPI
   // animation. _flip is GSAP's own timeline attached to the real target.
   await page.evaluate(()=>{
    window.originObserver=new MutationObserver(()=>{
     const target=document.querySelector('[data-origin-animating]');
     if(target?._flip&&!target._flip.__qaPaused){target._flip.__qaPaused=true;target._flip.pause().progress(0);}
    });
    window.originObserver.observe(document.documentElement,{subtree:true,attributes:true,attributeFilter:['data-origin-animating']});
   });
   await trigger.click();await page.waitForURL('**/reportar');
   await page.waitForFunction(()=>document.querySelector('main[data-origin-animating="opening"]')?._flip?.paused());
   const initial=await surface.evaluate(node=>{const r=node.getBoundingClientRect();return {x:r.x,y:r.y,width:r.width,height:r.height,duration:node._flip.duration(),fill:getComputedStyle(node).getPropertyValue('--origin-fill').trim()};});
   for(const key of ['x','y','width','height'])assert.ok(Math.abs(initial[key]-source[key])<1,`${mode}/${width}: real component ${key} starts at trigger: ${JSON.stringify({initial,source})}`);
   assert.equal(initial.duration,.7,'Uses Sader PrettyModal duration');
   const openingTiming=await surface.evaluate(node=>({duration:node.querySelector('.origin-page-body').getAnimations()[0].effect.getTiming().duration,easing:getComputedStyle(node.querySelector('.origin-page-body')).animationTimingFunction}));
   assert.equal(openingTiming.duration,500,'Sader opening CSS lasts 500ms');
   assert.equal(openingTiming.easing.replaceAll(' ',''),'cubic-bezier(0.56,0.27,0,1)','Sader opening CSS curve is copied unchanged');
   let nearFinalHeading;
   for(const progress of [0,.02,.05,.1,.15,.45,.65,.85,.99]) {
    await surface.evaluate((node,value)=>{node._flip.progress(value);for(const animation of node.getAnimations({subtree:true})){animation.pause();animation.currentTime=value*700;}},progress);
    const state=await surface.evaluate(node=>({body:getComputedStyle(node.querySelector('.origin-page-body')).visibility,inert:node.inert,fill:getComputedStyle(node).getPropertyValue('--origin-fill').trim(),opacity:Number(getComputedStyle(node.querySelector('.origin-page-body')).opacity),filter:getComputedStyle(node.querySelector('.origin-page-body')).filter}));
    assert.equal(state.body,'visible',`Form must scale within the surface from the start, including ${progress}`);assert.equal(state.inert,true);
    const identity=surface.locator('[data-origin-identity]');
    const icon=await identity.locator('svg,img').boundingBox();
    assert.ok(Math.abs(icon.width-sourceIcon.width)<.6&&Math.abs(icon.height-sourceIcon.height)<.6,'The source icon must retain its original size while the black surface expands');
    const identityOpacity=await identity.evaluate(node=>Number(getComputedStyle(node).opacity));
    if(progress===0){assert.equal(identityOpacity,1);assert.equal(await surface.evaluate(node=>Number(getComputedStyle(node).opacity)),1,'The source shell must be visible immediately');}
    if(progress>=.45)assert.equal(identityOpacity,0,'Mobile source identity disappears by 45%');
    if(progress===0){assert.equal(state.opacity,0,'Sader PrettyModal starts the destination fade at zero');assert.equal(state.filter,'blur(10px)','Sader starts with 10px blur');}
    if(progress>=.85){assert.equal(state.opacity,1,'Sader completes the 500ms fade before the 700ms morph');assert.ok(['none','blur(0px)'].includes(state.filter));}
    if(progress===.99){nearFinalHeading=await surface.locator('h1').boundingBox();const box=await surface.boundingBox();assert.ok(Math.abs(box.x)<3&&Math.abs(box.y)<3&&Math.abs(box.width-width)<3&&Math.abs(box.height-844)<3,'The morph must reach the entire viewport, not the content column');}
    assert.equal(await page.locator('.home-shortcuts:not([data-origin-underlay] *),.origin-transition-host,.origin-transition-hold,.origin-transition-previous').count(),0,'No Home shortcuts inside the destination or obsolete animation layers');
    assert.equal(await page.locator('[data-origin-underlay] .home-shortcuts').count(),1,'The real previous section must remain behind the growing destination');
    if(progress===.15){const heading=await surface.locator('h1').boundingBox();const layoutHeight=await surface.locator('h1').evaluate(node=>node.offsetHeight);const shell=await surface.boundingBox();assert.ok(heading.width<=shell.width&&heading.height<layoutHeight*.9,'The form heading must scale inside the origin, not appear at its final size');}
    if([0,.02,.05,.1,.15,.45,.99].includes(progress))await page.screenshot({path:fileURLToPath(new URL(`${mode}-${width}-${Math.round(progress*100)}.png`,output))});
   }
   await surface.evaluate(node=>{node._flip.progress(1);});
   const idle=async()=>{await page.waitForFunction(()=>!document.querySelector('[data-origin-animating],main[inert],.user-navigation [aria-busy="true"]'));await page.evaluate(()=>new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve))));};
   await idle();
   assert.equal(await page.locator('[data-origin-identity]').count(),0,'Temporary source identity must be removed after opening');
   const finalHeading=await surface.locator('h1').boundingBox();
   for(const axis of ['x','y'])assert.ok(Math.abs(finalHeading[axis]-nearFinalHeading[axis])<3,`No content jump at fullscreen completion: ${JSON.stringify({nearFinalHeading,finalHeading})}`);
   assert.equal(await surface.locator('.origin-page-body').evaluate(node=>getComputedStyle(node).visibility),'visible');
   assert.equal(await page.locator('.home-shortcuts').count(),0);
   assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,'The completed form must fit the viewport');
   await page.screenshot({path:fileURLToPath(new URL(`${mode}-${width}-100.png`,output))});
   // The outgoing component remains mounted for Flip.to; routing commits only
   // after the real Sader close has completed, rather than animating a clone.
   const back=page.goBack();
   await page.waitForFunction(()=>document.querySelector('main[data-origin-animating="closing"]')?._flip?.paused());
   assert.ok(await surface.textContent().then(text=>text.includes('Reportar')));
   for(const progress of [.5,.75,.95,.999]){
    await surface.evaluate((node,value)=>{node._flip.progress(value);for(const animation of node.getAnimations({subtree:true})){animation.pause();animation.currentTime=value*700;}},progress);
    const icon=await surface.locator('[data-origin-identity] svg,[data-origin-identity] img').boundingBox();
    assert.ok(Math.abs(icon.width-sourceIcon.width)<.6&&Math.abs(icon.height-sourceIcon.height)<.6,'The source icon must return at its original size');
    if(progress===.999&&mode==='nine'){
     const radii=await surface.evaluate(node=>{const r=node.getBoundingClientRect(),parts=getComputedStyle(node).borderTopLeftRadius.split(' ').map(parseFloat);return [parts[0]*r.width/node.offsetWidth,(parts[1]??parts[0])*r.height/node.offsetHeight];});
     for(const radius of radii)assert.ok(Math.abs(radius-source.width/2)<.6,'The closing surface must return to the original circle without a corner jump');
    }
    if(progress>=.95)assert.ok(await surface.locator('[data-origin-identity]').evaluate(node=>Number(getComputedStyle(node).opacity)>.9),'The nine-dot identity must return before the shell reaches the button');
    await page.screenshot({path:fileURLToPath(new URL(`${mode}-${width}-closing-${Math.round(progress*100)}.png`,output))});
   }
   const closedOpacity=await surface.evaluate(node=>{node._flip.progress(1);return getComputedStyle(node).opacity;});
   assert.equal(closedOpacity,'0','Completed closing must stay hidden until navigation commits');
   await back;await page.waitForURL('**/inicio');await idle();
   assert.equal(await trigger.isVisible(),true,'Original source control must be visible after return');
   assert.equal(await page.locator('[data-origin-identity]').count(),0,'Temporary source identity must be removed after closing');
   await page.evaluate(()=>window.originObserver.disconnect());
   // Also let the same actual GSAP component run in real time.
   const liveDurations=[];
   for(let round=0;round<2;round++){
    await page.evaluate(simulateRouteViewportEvent=>{
     const listeners=new AbortController();window.liveOriginCleanup=()=>listeners.abort();
     window.liveOriginFrames=[];
     window.liveOriginEvents=[];
     window.liveOriginObserver=new MutationObserver(()=>{
      const node=document.querySelector('main[data-origin-animating="opening"]');
      if(!node||window.liveOriginStarted)return;
      window.liveOriginStarted=true;
      const start=performance.now();
      const sample=()=>{
       const r=node.getBoundingClientRect();
       window.liveOriginFrames.push({time:performance.now()-start,opening:node.dataset.originAnimating==='opening',width:r.width,height:r.height,body:getComputedStyle(node.querySelector('.origin-page-body')).visibility});
       if(simulateRouteViewportEvent&&window.liveOriginFrames.length===2)visualViewport?.dispatchEvent(new Event('resize'));
       if(node.dataset.originAnimating==='opening')requestAnimationFrame(sample);
      };
      requestAnimationFrame(sample);
     });
     window.liveOriginStarted=false;
     window.liveOriginObserver.observe(document.documentElement,{subtree:true,attributes:true,attributeFilter:['data-origin-animating']});
     window.addEventListener('resize',()=>window.liveOriginEvents.push('window resize'),{signal:listeners.signal});
     visualViewport?.addEventListener('resize',()=>window.liveOriginEvents.push('visualViewport resize'),{signal:listeners.signal});
    },round===0);
    await trigger.click();await page.waitForURL('**/reportar');await idle();
    const live=await page.evaluate(()=>{window.liveOriginObserver.disconnect();window.liveOriginCleanup();return {frames:window.liveOriginFrames,events:window.liveOriginEvents};});
    assert.ok(live.frames.at(-1)?.time>=600,`Opening must actually run in real time: ${JSON.stringify(live)}`);
    assert.ok(live.frames.filter(frame=>frame.opening&&frame.body==='visible').length>=5,`Opening must paint multiple content frames: ${JSON.stringify(live)}`);
    assert.ok(live.frames.filter(frame=>frame.opening).every(frame=>frame.body==='visible'),'The route content must remain inside the expansion throughout the opening');
    assert.ok(Math.max(...live.frames.map(frame=>frame.width*frame.height))>live.frames[0].width*live.frames[0].height*2,`The real-time opening must visibly grow, including narrow layouts: ${JSON.stringify(live)}`);
    liveDurations.push(Math.round(live.frames.at(-1).time));
    assert.equal(await page.locator('.home-shortcuts').count(),0);
    await page.goBack();await page.waitForURL('**/inicio');await idle();
   }
   await page.emulateMedia({reducedMotion:'reduce'});
   await nav.getByRole('link',{name:'Reportar',exact:true}).click();await page.waitForURL('**/reportar');await idle();
   assert.equal(await page.locator('[data-origin-animating]').count(),0);assert.deepEqual(errors,[]);
   console.log(JSON.stringify({mode,width,engine:'Sader GSAP Flip',duration:initial.duration,liveDurations,fullscreen:true,entryMs:500,copies:0}));
   await page.unrouteAll({behavior:'wait'});await page.close();
  }
 }
} finally {for(const page of browser.contexts().flatMap(context=>context.pages()))await page.unrouteAll({behavior:'ignoreErrors'});await browser.close();await server.close();}

