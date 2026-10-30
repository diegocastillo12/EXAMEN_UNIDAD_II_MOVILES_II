import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
import { recoveryFixture } from '../tests/recovery_fixture.mjs';

const { chromium } = await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href);
const browser = await chromium.launch({ executablePath:process.env.CHROME_PATH, headless:true, ignoreDefaultArgs:['--hide-scrollbars'] });
const server = await recoveryFixture();
try {
  for (const width of [1440,390,320]) {
    const page = await browser.newPage({ viewport:{width,height:1000} });
    await page.route('https://basemaps.cartocdn.com/**',r => r.fulfill({status:200,contentType:'image/jpeg',body:server.jpeg}));
    await page.goto(server.origin+'/iniciar-sesion');
    await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');
    await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');
    await page.getByLabel('Contraseña',{exact:true}).press('Enter');
    const nav = page.getByRole('navigation',{name:'Navegación de usuario',exact:true});
    await nav.waitFor();
    await page.evaluate(() => {
      window.navigationBar = document.querySelector('.user-navigation');
      window.navigationFrames = [];
      function sample() {
        const node = document.querySelector('.user-navigation');
        if (node) {
          const {x,y,width,height} = node.getBoundingClientRect();
          window.navigationFrames.push({x,y,width,height,same:node === window.navigationBar});
        }
        window.navigationFrame = requestAnimationFrame(sample);
      }
      sample();
    });
    // Delayed reads cover both initial skeletons and the final long content.
    await page.route('**/api/recovery/**',async route => {
      await new Promise(resolve => setTimeout(resolve,250));
      await route.continue();
    });
    for (const name of ['Explorar','Mis mascotas','Inicio']) {
      await nav.getByRole('link',{name,exact:true}).click();
      await page.getByRole('heading',{name:name === 'Inicio' ? 'Su regreso empieza contigo' : name,exact:true}).waitFor();
      await page.waitForFunction(() => !document.querySelector('.skeleton'));
      await page.waitForTimeout(400);
    }
    // Ensure a classic scrollbar exists even with a short fixture dataset.
    await page.locator('main').evaluate(node => { node.style.minHeight = '200vh'; });
    await page.waitForTimeout(150);
    await page.getByRole('button',{name:'Abrir perfil',exact:true}).click();
    await page.getByRole('dialog',{name:'Tu cuenta',exact:true}).waitFor();
    await page.waitForTimeout(400);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(400);
    await page.locator('main').evaluate(node => { node.style.removeProperty('min-height'); });
    await page.waitForTimeout(150);
    const frames = await page.evaluate(() => { cancelAnimationFrame(window.navigationFrame);return window.navigationFrames; });
    const spread = Object.fromEntries(['x','y','width','height'].map(key => [key,Math.max(...frames.map(f=>f[key]))-Math.min(...frames.map(f=>f[key]))]));
    console.log(JSON.stringify({viewport:width,frames:frames.length,spread}));
    assert.ok(frames.every(f=>f.same),'Navigation must persist across section changes');
    for (const [key,value] of Object.entries(spread)) assert.ok(value < .5,`${width}px: navigation ${key} moved ${value}px`);
    await page.close();
  }
} finally { await browser.close();await server.close(); }
