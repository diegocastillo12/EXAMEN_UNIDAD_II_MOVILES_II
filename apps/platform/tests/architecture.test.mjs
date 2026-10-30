import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { test } from 'node:test';
import { posix } from 'node:path';
import { RateLimit, clientAddress } from '../server/infrastructure/rate_limit.ts';
import { configuration } from '../server/infrastructure/config.ts';
import { routePolicies, routeAccess, sessionRedirect, accountDestination, assertRegisteredRoutes } from '../shared/routing/route_policy.ts';
import { siteOrigin } from '../shared/seo/site_metadata.ts';
import { ORIGIN_ENTER_MS,ORIGIN_EXIT_MS,ORIGIN_SOURCE_END,ORIGIN_CONTENT_START,originMotionFrame } from '../app/utils/origin_motion_contract.ts';

test('Mobile and web profile/dialog origin transitions share timing, curves and source/content phases',async()=>{
  const mobile=await readFile(new URL('../../mobile/lib/core/presentation/widgets/origin_page_transition.dart',import.meta.url),'utf8');
  const router=await readFile(new URL('../../mobile/lib/app/router.dart',import.meta.url),'utf8');
  const entity=await readFile(new URL('../../mobile/lib/app/navigation/entity_editor_page.dart',import.meta.url),'utf8');
  for(const source of [router.slice(router.indexOf("path: 'profile'")),entity]){
    assert.match(source,new RegExp(`transitionDuration:[\\s\\S]*?milliseconds: ${ORIGIN_ENTER_MS}`));
    assert.match(source,new RegExp(`reverseTransitionDuration:[\\s\\S]*?milliseconds: ${ORIGIN_EXIT_MS}`));
  }
  assert.match(mobile,/Curves\.easeInOutCubic/);assert.match(mobile,/Interval\(\.65, 1, curve: Curves\.easeOutCubic\)/);
  assert.match(mobile,/Interval\(\s*0,\s*\.45,/);
  assert.equal(ORIGIN_SOURCE_END,.45);assert.equal(ORIGIN_CONTENT_START,.65);
  assert.deepEqual(originMotionFrame(0),{shape:0,source:1,content:0});
  assert.equal(originMotionFrame(.45).source,0);assert.equal(originMotionFrame(.65).content,0);
  assert.ok(Math.abs(originMotionFrame(.5).shape-.516875)<.002);
  assert.deepEqual(originMotionFrame(1),{shape:1,source:0,content:1});
});

test('SEO identity accepts only a configured HTTPS origin, never arbitrary URL content', () => {
  assert.equal(siteOrigin('https://entrehuellas.app/'), 'https://entrehuellas.app');
  for (const value of ['http://entrehuellas.app', 'https://user:password@entrehuellas.app', 'https://entrehuellas.app/path', 'https://entrehuellas.app/?redirect=evil', 'https://entrehuellas.app/#fragment', '//attacker.example', 'javascript:alert(1)']) {
    assert.throws(() => siteOrigin(value));
  }
});
async function sources(path) {
  const files = [];
  for (const item of await readdir(path, { withFileTypes: true })) {
    const url = new URL(item.name, path);
    if (item.isDirectory()) files.push(...await sources(new URL(`${item.name}/`, path)));
    else if (/\.(vue|ts)$/.test(item.name)) files.push([url.pathname, await readFile(url, 'utf8')]);
  }
  return files;
}

test('Primary titles share the mobile/web typography and local font', async () => {
  const mobile = await readFile(new URL('../../mobile/lib/core/theme/app_typography.dart', import.meta.url), 'utf8');
  const web = await readFile(new URL('../app/assets/typography.css', import.meta.url), 'utf8');
  const size = Number(mobile.match(/fontSize: (\d+)/)[1]);
  const weight = mobile.match(/fontWeight: FontWeight\.w(\d+)/)[1];
  const color = mobile.match(/Color\(0xFF([\dA-Fa-f]{6})\)/)[1].toLowerCase();
  assert.match(mobile, /fontFamily: 'Poppins'/);
  assert.ok(web.includes(`--primary-title-size: ${size / 16}rem`));
  assert.ok(web.includes(`--primary-title-weight: ${weight}`));
  assert.ok(web.includes(`--primary-title-color: #${color}`));
  assert.match(web, /:is\(\.reader-shell, \.landing-page\) h1/);
  const mobileFont = await readFile(new URL('../../mobile/assets/fonts/Poppins-Regular.ttf', import.meta.url));
  const webFont = await readFile(new URL('../public/fonts/poppins/Poppins-Regular.ttf', import.meta.url));
  assert.ok(mobileFont.equals(webFont), 'Both platforms must ship the same font');
  const config = await readFile(new URL('../nuxt.config.ts', import.meta.url), 'utf8');
  assert.match(config, /~\/assets\/typography\.css/);
  for (const file of ['collection_header', 'entity_screen_shell', 'app_page_layout']) {
    const source = await readFile(new URL('../../mobile/lib/core/presentation/widgets/' + file + '.dart', import.meta.url), 'utf8');
    assert.match(source, /AppTypography\.primaryTitle/, file);
  }
});

test('All maps use shared adapters and the same mobile/web tile palette', async () => {
  for (const [path, source] of await sources(new URL('../app/', import.meta.url))) {
    if (path.endsWith('/components/LocationMap.vue')) continue;
    assert.doesNotMatch(source, /from ['"]leaflet['"]|import\(['"]leaflet['"]\)|\bL\.map\(/, path);
  }
  const adapter = await readFile(new URL('../app/components/LocationMap.vue', import.meta.url), 'utf8');
  assert.match(adapter, /config\.public\.mapTileUrl/);
  assert.match(adapter, /map-attribution/);
  const dart = await readFile(new URL('../../mobile/lib/core/presentation/widgets/map_style.dart', import.meta.url), 'utf8');
  const svg = await readFile(new URL('../public/map-style.svg', import.meta.url), 'utf8');
  const mobile = dart.match(/ColorFilter\.matrix\(\[([\s\S]*?)\]\)/)[1].split(',').map(s => s.trim()).filter(Boolean).map(Number);
  const web = svg.match(/values="([\s\S]*?)"/)[1].trim().split(/\s+/).map(Number);
  assert.equal(mobile.length, 20); assert.equal(web.length, 20);
  for (let i = 0; i < mobile.length; i++) assert.ok(Math.abs(mobile[i] / (i % 5 === 4 ? 255 : 1) - web[i]) < 1e-10, `Matrix differs at ${i}`);
  assert.match(svg, /color-interpolation-filters="sRGB"/);
  const css = await readFile(new URL('../app/assets/maps.css', import.meta.url), 'utf8');
  assert.match(css, /\.leaflet-tile-pane\s*\{\s*filter: url\('\/map-style\.svg#cartography'\)/);
});

test('All pages share the global access policy; new pages cannot bypass registration', async () => {
  const pages = await sources(new URL('../app/pages/', import.meta.url));
  const patterns = pages.map(([path, source]) => {
    assert.doesNotMatch(source, /middleware\s*:/, 'Page must use the global access guard: ' + path);
    return '/' + path.split('/app/pages/')[1].replace(/\.vue$/, '').replace(/\[\.\.\.(\w+)\]/g, ':$1(.*)*').replace(/\[(\w+)\]/g, ':$1').replace(/(^|\/)index$/, '');
  });
  assert.deepEqual(patterns.sort(), Object.keys(routePolicies).sort());
  assertRegisteredRoutes(patterns);
  assert.throws(() => assertRegisteredRoutes(['/nueva-pagina']), /Define the access policy/);
  assertRegisteredRoutes(['/c/:slug()', '/:path(.*)*']);
  assert.equal(routeAccess('/moderacion/'), 'reviewer');
  assert.equal(routeAccess('/c/token'), 'public');
  assert.equal(routeAccess('/no-existe'), 'public');
  const extended = { ...routePolicies, '/mascotas/:id': 'account', '/revision/:id': 'reviewer' };
  assert.equal(routeAccess('/mascotas/123', extended), 'account');
  assert.equal(routeAccess('/revision/123/', extended), 'reviewer');
  assert.equal(routeAccess('/mascotas/123/otra', extended), 'public');
  assert.equal(sessionRedirect('reviewer', false), '/bienvenida');
  assert.equal(sessionRedirect('reviewer', true), null);
  assert.equal(sessionRedirect('public', false), null);
  for (const value of ['https://untrusted.example', '//untrusted.example', '/no-existe', '/terminos', '/moderacion?next=x']) assert.equal(accountDestination(value), null);
  assert.equal(accountDestination('/moderacion'), '/moderacion');
  const global = await readFile(new URL('../app/middleware/access.global.ts', import.meta.url), 'utf8');
  assert.match(global, /routeAccess/);
  const config = await readFile(new URL('../nuxt.config.ts', import.meta.url), 'utf8');
  assert.match(config, /pages:extend/); assert.match(config, /assertRegisteredRoutes/);
});

test('Web reveal has no legacy painted cover utility or per-screen reveal classes', async () => {
  const css = await readFile(new URL('../app/assets/main.css', import.meta.url), 'utf8');
  assert.doesNotMatch(css, /\.reveal\b|@keyframes\s+(?:cover|arrive)\s*\{/);
  for (const [path, source] of await sources(new URL('../app/features/', import.meta.url))) {
    assert.doesNotMatch(source, /class="[^"]*(?<![\w-])reveal(?![\w-])/, path);
  }
});
test('Domain and presentation boundaries keep credentials, infrastructure and SDK out of Vue/client', async () => {
  for (const [path, source] of await sources(new URL('../shared/features/', import.meta.url))) {
    if (path.includes('/domain/')) assert.doesNotMatch(source, /node:|supabase|from ['"].*(data|presentation|vue|nuxt)|fetch\(/);
    if (path.includes('/presentation/')) assert.doesNotMatch(source, /from ['"].*(\/data\/|\/server\/)|navigator\.|fetch\(/);
  }
  for (const [, source] of await sources(new URL('../app/features/', import.meta.url))) assert.doesNotMatch(source, /from ['"].*(\/data\/|\/server\/)|SUPABASE_|process\.env|\.rpc\(/);
  for (const [, source] of await sources(new URL('../app/', import.meta.url))) assert.doesNotMatch(source, /SUPABASE_SERVER_KEY|service_role|supabase_case_data_source/);
});
test('Rate limiting is bounded and trusts only explicitly configured peers', () => {
  let time = 10000; const limiter = new RateLimit({ limit: 2, maxClients: 2, windowMs: 1000, now: () => time });
  assert.equal(limiter.allow('a'), true); assert.equal(limiter.allow('a'), true); assert.equal(limiter.allow('a'), false);
  assert.equal(limiter.allow('b'), true); assert.equal(limiter.allow('c'), false); time += 1001; assert.equal(limiter.allow('c'), true);
  const req = { socket: { remoteAddress: '::ffff:127.0.0.1' }, headers: { 'x-forwarded-for': '8.8.8.8, 1.1.1.1' } };
  assert.equal(clientAddress(req, []), '127.0.0.1'); assert.equal(clientAddress(req, ['127.0.0.1']), '1.1.1.1');
});
test('Server-only configuration accepts existing Dokploy names and rejects browser keys/unsafe URLs', () => {
  assert.equal(configuration({ SUPABASE_URL: 'https://backend.example.test', SUPABASE_SERVER_KEY: 'sb_secret_test-placeholder-key' }).url, 'https://backend.example.test');
  for (const env of [{}, { SUPABASE_URL: 'http://public.example.test', SUPABASE_SERVER_KEY: 'sb_secret_test-placeholder-key' }, { SUPABASE_URL: 'https://backend.example.test', SUPABASE_SERVER_KEY: 'sb_publishable_not-server-key' }]) assert.throws(() => configuration(env));
});

test('Administrative UI remains exclusive to platform, with no Flutter administrative route', async () => {
  const mobileRouter = await readFile(new URL('../../mobile/lib/app/router.dart', import.meta.url), 'utf8');
  assert.doesNotMatch(mobileRouter, /path:\s*['"](?:admin|moderacion|moderation)(?:\/|['"])/);
  const page = await readFile(new URL('../app/pages/moderacion/index.vue', import.meta.url), 'utf8');
  assert.match(page, /ModerationScreen/);
  for (const [path, source] of await sources(new URL('../server/features/moderation/', import.meta.url))) {
    assert.doesNotMatch(source, /\/presentation\/|from ['"].*(?:vue|nuxt)/, path);
  }
});

test('Features collaborate through domain contracts without importing another feature data or presentation', async () => {
  for (const root of ['../shared/features/', '../app/features/', '../server/features/']) {
    for (const [path, source] of await sources(new URL(root, import.meta.url))) {
      const feature = path.match(/\/features\/([^/]+)\//)?.[1];
      for (const [, specifier] of source.matchAll(/(?:from\s+|import\s*)['"]([^'"]+)['"]/g)) {
        const target = specifier.startsWith('.') ? posix.normalize(posix.dirname(path) + '/' + specifier) : specifier;
        const dependency = target.match(/(?:^|\/)features\/([^/]+)\/(data|presentation)\//);
        if (dependency) assert.equal(dependency[1], feature, path + ' imports ' + specifier);
      }
    }
  }
  for (const [path, source] of await sources(new URL('../app/components/', import.meta.url))) {
    assert.doesNotMatch(source, /from\s+['"][^'"]*features\//, path);
  }
});
