import { chooseField, chooseDateTime } from './field-browser-helpers.mjs';
import assert from 'node:assert/strict';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath,pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';
const {chromium}=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await recoveryFixture();
const output=new URL('../../mobile/build/ui-preview/web-recovery/',import.meta.url);await mkdir(output,{recursive:true});
try{
 const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),page=await context.newPage(),errors=[];
 page.setDefaultTimeout(15000);page.setDefaultNavigationTimeout(15000);
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 page.on('response',r=>{if(r.url().includes('/api/recovery/')&&r.status()>=400)console.log('Recovery QA response:',r.status(),new URL(r.url()).pathname);});
 await page.route('https://basemaps.cartocdn.com/**',r=>r.fulfill({status:200,contentType:'image/jpeg',body:server.jpeg}));
 const nav=()=>page.getByRole('navigation',{name:'Navegación de usuario'});
 async function open(name,path){await nav().getByRole('link',{name,exact:true}).click();await page.waitForURL('**/'+path);await page.locator('.recovery-content').waitFor();}
 async function capture(name){for(const[width,height,enlarged,suffix]of[[1440,1000,false,'desktop'],[390,844,false,'mobile'],[320,640,false,'small'],[320,640,true,'text200']]){await page.setViewportSize({width,height});await page.evaluate(v=>document.documentElement.style.fontSize=v?'200%':'100%',enlarged);await page.evaluate(()=>window.scrollTo(0,0));await page.waitForTimeout(100);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,name+' '+suffix+' overflow');const box=await nav().boundingBox();assert.ok(box.x>=0&&box.x+box.width<=width+1&&box.y+box.height<=height,name+' navigation bounds');await page.screenshot({path:fileURLToPath(new URL(name+'-'+suffix+'.png',output)),fullPage:true});}await page.evaluate(()=>document.documentElement.style.fontSize='100%');await page.setViewportSize({width:1440,height:1000});}
 await page.goto(server.origin+'/iniciar-sesion');await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');await page.waitForURL('**/inicio');await nav().waitFor();
 for(const name of ['Inicio','Explorar','Mis mascotas','Reportar'])assert.equal(await nav().getByRole('link',{name,exact:true}).count(),1);
 assert.equal(await nav().getByRole('link',{name:'Inicio',exact:true}).getAttribute('aria-current'),'page');await capture('home');
 await open('Explorar','explorar');await page.getByRole('heading',{name:'Luna',exact:true}).waitFor();await capture('explore');
 await chooseField(page,'Especie','Gatos');await Promise.all([page.waitForResponse(r=>r.url().endsWith('/api/recovery/explore')),page.getByRole('button',{name:'Aplicar filtros'}).click()]);assert.equal(server.calls.filter(c=>c.rpc==='explore_cases').at(-1).body.p_species,'cat');
 await open('Mis mascotas','mis-mascotas');await page.getByRole('heading',{name:'Luna',exact:true}).waitFor();await capture('pets');
 await page.getByRole('button',{name:'Registrar mascota',exact:true}).click();await page.getByRole('button',{name:'Guardar mascota',exact:true}).click();await page.getByRole('alert').filter({hasText:'Revisa los campos'}).waitFor();assert.equal(await page.getByLabel('Nombre',{exact:true}).getAttribute('aria-invalid'),'true');
 await page.getByLabel('Nombre',{exact:true}).fill('Nube');await chooseField(page,'Especie','Gato');await chooseField(page,'Tamaño','Pequeño');await page.getByLabel('Edad en meses').fill('12');await page.getByLabel('Rasgos distintivos').fill('Gris, ojos verdes');await capture('pet-form');await page.getByRole('button',{name:'Guardar mascota',exact:true}).click();await page.getByRole('heading',{name:'Nube',exact:true}).waitFor();
 await page.getByLabel('Añadir foto de Nube',{exact:true}).setInputFiles({name:'nube.jpg',mimeType:'image/jpeg',buffer:server.jpeg});await page.getByText('Foto guardada.',{exact:true}).waitFor();
 await page.getByRole('article').filter({has:page.getByRole('heading',{name:'Nube',exact:true})}).getByRole('button',{name:'Editar',exact:true}).click();await page.getByLabel('Rasgos distintivos').fill('Gris, ojos verdes y collar azul');await page.getByRole('button',{name:'Guardar mascota',exact:true}).click();await page.getByText('Gris, ojos verdes y collar azul',{exact:true}).waitFor();
 await open('Reportar','reportar');await page.locator('.location-map').waitFor();await page.getByRole('button',{name:'Publicar reporte',exact:true}).click();await page.getByRole('alert').filter({hasText:'Revisa los campos'}).waitFor();
 await chooseField(page,'Tu mascota','Nube');await chooseDateTime(page,'2026-10-19T09:30');await page.getByLabel('Referencia del lugar (privada)',{exact:true}).fill('Parque del barrio');await page.locator('.location-map.leaflet-container').click();await capture('report-own');
 await page.getByRole('button',{name:'Guardar borrador',exact:true}).click();await page.getByText('Borrador guardado en este navegador para tu cuenta.',{exact:true}).waitFor();page.once('dialog',d=>d.accept());await page.reload();await page.waitForFunction(()=>[...document.querySelectorAll('input')].some(el=>el.value==='Parque del barrio'));assert.equal(await page.getByLabel('Referencia del lugar (privada)',{exact:true}).inputValue(),'Parque del barrio');
 server.ambiguous();await page.getByRole('button',{name:'Publicar reporte',exact:true}).click();await page.getByRole('button',{name:'Reintentar el mismo envío',exact:true}).waitFor();assert.equal(await page.getByLabel('Referencia del lugar (privada)',{exact:true}).isDisabled(),true);await page.getByRole('button',{name:'Reintentar el mismo envío',exact:true}).click();await page.getByRole('heading',{name:'Reporte publicado',exact:true}).waitFor();assert.equal(server.reports.size,1);
 await page.getByRole('link',{name:'Ir a Explorar',exact:true}).click();await page.waitForURL('**/explorar');await page.locator('.recovery-content').waitFor();
 for(const kind of ['possible_loss','sighting','with_reporter']){
  console.log('Checking report kind:',kind);
  await open('Reportar','reportar');await chooseField(page,'¿Cómo quieres ayudar?',({possible_loss:'Vi una mascota posiblemente perdida',sighting:'Vi una mascota que están buscando',with_reporter:'Tengo a una mascota que están buscando'})[kind]);
  if(kind==='possible_loss'){await chooseField(page,'Especie','Perro');await page.getByLabel('Rasgos distintivos').fill('Perro claro, collar rojo');await page.getByLabel('Fotos del reporte',{exact:true}).setInputFiles({name:'reporte.jpg',mimeType:'image/jpeg',buffer:server.jpeg});}
  else{await chooseField(page,'Búsqueda a la que ayudas','Luna');await page.getByLabel('¿Qué observaste?',{exact:true}).fill('Lo vi junto al parque');}
  await chooseDateTime(page,'2026-10-19T09:30');await page.getByLabel('Referencia del lugar (privada)',{exact:true}).fill('Parque del barrio');await page.locator('.location-map.leaflet-container').click();if(kind==='possible_loss')await capture('report-community');
  await page.getByRole('button',{name:'Publicar reporte',exact:true}).click();await page.getByRole('heading',{name:'Reporte publicado',exact:true}).waitFor();await page.getByRole('link',{name:'Ir a Explorar',exact:true}).click();await page.waitForURL('**/explorar');await page.locator('.recovery-content').waitFor();
 }
 assert.equal(server.reports.size,4);assert.deepEqual(errors,[]);await context.close();console.log('Recovery Chrome QA passed: four navigation entries, real fixture reads/writes, pet create/edit/photo, filters, four report kinds, local draft restore, ambiguous retry, 1440/390/320/text200%, no overflow/CSP/hydration errors.');
}finally{await browser.close();await server.close();}
