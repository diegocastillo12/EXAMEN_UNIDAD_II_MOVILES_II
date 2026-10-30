import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';
import { chooseField } from './field-browser-helpers.mjs';
const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath:process.env.CHROME_PATH,headless:true });
const server = await recoveryFixture();
const output = new URL('../../mobile/build/ui-preview/web-text-field/',import.meta.url);
await mkdir(output,{recursive:true});
try {
  const page=await browser.newPage({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),errors=[];
  page.setDefaultTimeout(10000);
  page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
  await page.route('https://basemaps.cartocdn.com/**',r=>r.fulfill({status:200,contentType:'image/jpeg',body:server.jpeg}));
  await page.goto(server.origin+'/iniciar-sesion');
  await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');
  await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');
  await page.getByLabel('Contraseña',{exact:true}).press('Enter');await page.waitForURL('**/inicio');
  await page.getByRole('link',{name:'Reportar',exact:true}).click();await page.waitForURL('**/reportar');
  await chooseField(page,'¿Cómo quieres ayudar?','Vi una mascota posiblemente perdida');
  for(const [label,name] of [['Referencia del lugar (privada)','input'],['Rasgos distintivos','textarea']]) {
    const input=page.getByLabel(label,{exact:true}),shell=input.locator('..'),outline=shell.locator('.sader-text-outline'),caption=shell.locator('.sader-floating-label');
    await input.fill('');await input.press('Tab');
    await input.hover();
    assert.equal(await input.evaluate(el=>getComputedStyle(el).backgroundImage),'none','No legacy hover background');
    assert.equal(await input.evaluate(el=>getComputedStyle(el).boxShadow),'none','No double hover outline');
    assert.equal(await caption.evaluate(el=>getComputedStyle(el).backgroundColor),'rgba(0, 0, 0, 0)','No opaque label patch at rest');
    assert.ok(await outline.locator('legend').evaluate(el=>el.getBoundingClientRect().width)<1,'Closed outline while empty/unfocused');
    await page.screenshot({path:fileURLToPath(new URL(`${name}-empty.png`,output)),fullPage:true});
    await input.focus();
    assert.equal(await outline.evaluate(el=>getComputedStyle(el).borderTopWidth),'3px','Single focused outline');
    assert.equal(await input.evaluate(el=>getComputedStyle(el).boxShadow),'none','No second unbroken ring through the notch');
    const geometry=await shell.evaluate(el=>{const a=el.querySelector('label').getBoundingClientRect(),b=el.querySelector('legend').getBoundingClientRect();return {label:a.width,notch:b.width};});
    assert.ok(geometry.notch>=geometry.label-2,'Notch fits the floating label');
    await page.screenshot({path:fileURLToPath(new URL(`${name}-focused.png`,output)),fullPage:true});
    await input.fill('Texto conservado');await input.press('Tab');
    assert.ok(await outline.locator('legend').evaluate(el=>el.getBoundingClientRect().width)>1,'Notch stays open for filled fields after blur');
    assert.equal(await input.inputValue(),'Texto conservado');
    await page.screenshot({path:fileURLToPath(new URL(`${name}-filled.png`,output)),fullPage:true});
    await input.fill('');await input.press('Tab');
  }
  await page.getByRole('button',{name:'Publicar reporte',exact:true}).click();
  await page.getByRole('alert').filter({hasText:'Revisa los campos'}).waitFor();
  const traits=page.getByLabel('Rasgos distintivos',{exact:true});
  assert.equal(await traits.getAttribute('aria-invalid'),'true');
  assert.equal(await traits.locator('..').locator('.sader-text-outline').evaluate(el=>getComputedStyle(el).borderTopColor),'rgb(181, 63, 72)');
  for(const [width,enlarged] of [[390,false],[320,false],[320,true]]) {
    await page.setViewportSize({width,height:900});await page.evaluate(v=>document.documentElement.style.fontSize=v?'200%':'100%',enlarged);
    await traits.focus();
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
    await page.screenshot({path:fileURLToPath(new URL(`textarea-${width}-${enlarged?'text200':'normal'}.png`,output)),fullPage:true});
  }
  const place=page.getByLabel('Referencia del lugar (privada)',{exact:true});
  await place.fill('Parque del barrio');
  assert.ok(await place.locator('..').evaluate(el=>{const input=el.querySelector('input'),label=el.querySelector('label');return label.getBoundingClientRect().bottom<=input.getBoundingClientRect().top+parseFloat(getComputedStyle(input).paddingTop);}), 'Wrapped label does not overlap enlarged input text');
  await page.screenshot({path:fileURLToPath(new URL('input-320-text200.png',output)),fullPage:true});
  assert.deepEqual(errors,[]);
  console.log('TextField Chrome QA passed: transparent labels, true notch at rest/focus/filled blur, input and textarea, invalid state, 390/320/text200%, no overflow/CSP/hydration errors.');
} finally {await browser.close();await server.close();}
