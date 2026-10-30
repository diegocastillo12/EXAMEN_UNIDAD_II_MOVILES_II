import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {inboxFixture} from '../tests/inbox_fixture.mjs';
const {chromium}=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await inboxFixture();
const output=new URL('../../mobile/build/ui-preview/web-dialog-motion/',import.meta.url);await mkdir(output,{recursive:true});
try{
  const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'no-preference'}),page=await context.newPage(),errors=[];
  page.setDefaultTimeout(15000);page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
  await page.addInitScript(()=>{
    window.dialogMotion=[];window.pauseDialogMotion=true;
    const original=Element.prototype.animate;
    Element.prototype.animate=function(...args){const animation=original.apply(this,args);if(this.matches('.glass-dialog,.glass-dialog-content,.glass-dialog-origin')){window.dialogMotion.push({animation,element:this});if(window.pauseDialogMotion){animation.pause();animation.currentTime=0;}}return animation;};
  });
  await page.goto(server.origin+'/iniciar-sesion');await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');await page.waitForURL('**/inicio');await page.getByRole('heading',{name:'Su regreso empieza contigo'}).waitFor();
  async function reset(){await page.evaluate(()=>window.dialogMotion=[]);}
  async function started(duration){await page.waitForFunction(()=>window.dialogMotion.length===3);assert.equal(await page.evaluate(()=>window.dialogMotion[0].animation.effect.getTiming().duration),duration);}
  async function seek(time){await page.evaluate(time=>{for(const r of window.dialogMotion)r.animation.currentTime=time;},time);}
  async function finish(){await page.evaluate(()=>{for(const r of window.dialogMotion)r.animation.finish();});}
  async function frame(){return page.evaluate(()=>{const node=document.querySelector('dialog[open]'),content=node.querySelector('.glass-dialog-content'),rect=node.getBoundingClientRect();return{x:rect.x,y:rect.y,width:rect.width,height:rect.height,opacity:Number(getComputedStyle(content).opacity),inert:content.inert,sourceCount:node.querySelector('.glass-dialog-origin').children.length};});}
  async function capture(name){await page.screenshot({path:fileURLToPath(new URL(name+'.png',output)),fullPage:false});}
  async function settled(){await page.waitForFunction(()=>document.querySelector('dialog[open] .glass-dialog-content')?.getAttribute('aria-busy')==='false');}
  for(const[width,height,size,layout]of[[1440,1000,'100%','desktop'],[390,844,'100%','mobile'],[320,640,'200%','text200']]){
    await page.setViewportSize({width,height});await page.evaluate(size=>document.documentElement.style.fontSize=size,size);
    for(const[name,title,slug]of[['Abrir perfil','Tu cuenta','profile'],['Alertas','Alertas','inbox']]){
      const button=page.getByRole('button',{name,exact:true});await button.scrollIntoViewIfNeeded();const source=await button.boundingBox();
      const brand=await page.locator('.account-header .site-brand').boundingBox();
      await reset();await button.click();await started(320);
      const start=await frame();assert.ok(Math.abs(start.x-source.x)<2&&Math.abs(start.y-source.y)<2&&Math.abs(start.width-source.width)<2,layout+' '+slug+' real origin');assert.equal(start.opacity,0);assert.equal(start.inert,true);assert.equal(start.sourceCount,slug==='inbox'?1:0);
      await seek(160);const middle=await frame();assert.ok(middle.width>source.width+15,layout+' '+slug+' expansion frame');assert.equal(middle.opacity,0);await capture(layout+'-'+slug+'-opening');
      await seek(208);assert.equal((await frame()).opacity,0,'Content starts after 65%');await seek(280);assert.ok((await frame()).opacity>0);await capture(layout+'-'+slug+'-content');
      await finish();await settled();const full=await frame();assert.equal(full.inert,false);assert.equal(full.opacity,1);assert.equal(await page.getByRole('dialog',{name:title,exact:true}).evaluate(el=>el.scrollWidth<=el.clientWidth),true);
      const stable=await page.locator('.account-header .site-brand').boundingBox();assert.deepEqual(stable,brand,'Brand stays fixed');
      await reset();await page.keyboard.press('Escape');await started(260);assert.equal(await page.getByRole('dialog',{name:title,exact:true}).count(),1,'Keep dialog mounted throughout closing');
      await seek(130);const returning=await frame();assert.ok(returning.width>source.width&&returning.width<full.width);await capture(layout+'-'+slug+'-closing');
      await seek(259);assert.ok(Math.abs((await frame()).width-source.width)<2,'Returns to same trigger');await finish();await page.getByRole('dialog',{name:title,exact:true}).waitFor({state:'hidden'});
      assert.equal(await page.evaluate(()=>document.body.style.overflow),'');assert.equal(await button.evaluate(el=>el===document.activeElement),true,'Focus returns to trigger');
    }
  }
  await page.evaluate(()=>document.documentElement.style.fontSize='100%');await page.setViewportSize({width:390,height:844});
  await reset();await page.getByRole('button',{name:'Abrir perfil',exact:true}).click();await started(320);await seek(100);await page.setViewportSize({width:400,height:820});await settled();assert.equal((await frame()).inert,false);await reset();await page.keyboard.press('Escape');await started(260);await finish();await page.getByRole('dialog',{name:'Tu cuenta',exact:true}).waitFor({state:'hidden'});
  await reset();await page.getByRole('button',{name:'Alertas',exact:true}).click();await started(320);await page.emulateMedia({reducedMotion:'reduce'});await settled();await page.keyboard.press('Escape');await page.getByRole('dialog',{name:'Alertas',exact:true}).waitFor({state:'hidden'});
  await reset();await page.getByRole('button',{name:'Abrir perfil',exact:true}).click();await settled();assert.equal(await page.evaluate(()=>window.dialogMotion.length),0,'Reduced motion skips geometry');await page.keyboard.press('Escape');await page.getByRole('dialog',{name:'Tu cuenta',exact:true}).waitFor({state:'hidden'});
  await page.emulateMedia({reducedMotion:'no-preference'});await reset();await page.getByRole('button',{name:'Alertas',exact:true}).click();await started(320);await reset();await page.keyboard.press('Escape');await started(260);await finish();await page.getByRole('dialog',{name:'Alertas',exact:true}).waitFor({state:'hidden'});assert.equal(await page.evaluate(()=>document.body.style.overflow),'');
  await reset();await page.getByRole('button',{name:'Abrir perfil',exact:true}).click();await started(320);await page.reload();await page.getByRole('button',{name:'Abrir perfil',exact:true}).waitFor();assert.equal(await page.locator('dialog[open]').count(),0);assert.equal(await page.evaluate(()=>document.body.style.overflow),'');
  // Also run in real time, without paused animation or reduced motion.
  await page.evaluate(()=>{window.pauseDialogMotion=false;window.dialogMotion=[];});await page.getByRole('button',{name:'Alertas',exact:true}).click();await settled();await page.keyboard.press('Escape');await page.getByRole('dialog',{name:'Alertas',exact:true}).waitFor({state:'hidden'});assert.equal(await page.evaluate(()=>window.dialogMotion.length),6);
  assert.deepEqual(errors,[]);await context.close();console.log('Dialog motion QA passed: mobile contract 320/260ms, real avatar/bell origin, opening/content/closing frames, focus/brand, desktop/mobile/text200, resize, live reduced motion, rapid close, reload/unmount and real-time playback.');
}finally{await browser.close();await server.close();}
