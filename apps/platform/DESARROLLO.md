# Tu primera ejecución en Vue/Nuxt

HU-16.1: `/administracion/estadisticas` usa permiso administrador independiente
de moderación y RPC de plan039. Aplicar039 y asignar una cuenta explícita en
desarrollo antes de comprobar permisos reales; no se autoasigna desde web.
`node scripts/check-statistics-browser.mjs` con PLAYWRIGHT_MODULE/CHROME_PATH
y build vigente verifica origen/retorno, fechas por teclado, responsive/texto200%,
refresh/fallo, vacío y revocación con backend fixture. No certifica Supabase alojado.
Ver [ficha de activación](../../docs/funcionalidades/estadisticas-piloto.md).

## Paridad de animaciones Perfil/Alertas —21/10/2026

`node scripts/check-dialog-motion-browser.mjs` requiere build vigente y las
mismas PLAYWRIGHT_MODULE/CHROME_PATH. Ejecuta con movimiento normal y controla
la línea temporal WAAPI para medir origen,320/260ms y fases, guardar fotogramas
de entrada/contenido/salida y verificar retorno/foco/marca. Cubre1440/390/320
con texto200%, resize, preferencia reducida en vivo, cierre rápido, recarga y
reproducción real. Capturas de viewport en `apps/mobile/build/ui-preview/web-dialog-motion`;
fullPage puede redimensionar temporalmente el navegador e interrumpir el efecto.
`npm test` contrasta el contrato web con rutas e intervalos Flutter. ADR-124
exige esta paridad; probar solo movimiento reducido no acredita una animación.

## Cabecera, perfil de consulta y alertas —21/10/2026

`node scripts/check-inbox-browser.mjs` usa PLAYWRIGHT_MODULE/CHROME_PATH y el
build vigente como los demás QA. Comprueba avatar/fallback, glass, cabecera y
paneles1440/390/320/texto200%, teclado/Escape/scroll, skeleton frente a vacío,
errores/reintentos/paginación, lectura persistida y cambio de cuenta. Capturas
en `apps/mobile/build/ui-preview/web-inbox`. Backend fixture, sin push real.

`npm test` incorpora dominio/DTO/repositorios/ViewModel de notificaciones y
avatar; `npm run test:server` incorpora el aislamiento de las APIs nuevas,
Origin/onboarding, confirmación de leído, avatar privado y errores seguros.
Se usan las RPC existentes de plan027 y el bucket opcional profile-avatars;
no hay SQL nuevo ni configuración de push. Ver `docs/funcionalidades/notificaciones-web.md`.

## Inicio con diseño móvil —21/10/2026

Con build vigente y PLAYWRIGHT_MODULE/CHROME_PATH configurados como en los
demás scripts, ejecutar `node scripts/check-home-browser.mjs`. Levanta backend
fixture y valida escritorio/móvil/320/texto200%, imagen/fuente, cuenta con
teclado, accesos/retorno y permisos. Capturas en
`apps/mobile/build/ui-preview/web-home`. Si el dev server ocupa `.nuxt`, usar
`$env:NUXT_BUILD_DIR='.nuxt-home-review'; npm run build` para construir aparte.

## Carga progresiva de Reportar —21/10/2026

`node scripts/check-report-loading-browser.mjs`, con las mismas variables
PLAYWRIGHT_MODULE/CHROME_PATH y build actual, retiene peticiones de mascotas,
búsquedas y el módulo Leaflet. Verifica campos utilizables antes de completarlas,
selectores independientes, retry solo del recurso fallido y borrador restaurado
con IDs/version/fotos conservados antes de recibir las listas. Backend fixture,
sin cuentas ni datos remotos. Capturas en apps/mobile/build/ui-preview/web-report-loading.

## Controles compartidos de Sader —21/10/2026

`node scripts/check-text-field-browser.mjs` valida la etiqueta transparente y la
muesca real de input/textarea (vacío, hover, foco, texto conservado tras blur,
error y320px/texto200%). Usa las mismas variables/fixture; evidencia revisable
en apps/mobile/build/ui-preview/web-text-field. Comprueba también que una etiqueta
larga con texto ampliado no se superponga al valor del input.

`node scripts/check-top-loading-browser.mjs` reproduce el ciclo de navegación
del loader con fixture: login, recarga autenticada, cambios de sección, consulta
retenida, query/hash, duplicado, guard abortado y redirección. Requiere las mismas
variables de Playwright/Chrome y build actual; no usa cuentas ni backend remoto.

Con build actual, `node scripts/check-fields-browser.mjs` usa PLAYWRIGHT_MODULE
y CHROME_PATH como los otros scripts. Levanta un backend fixture local; revisa
fotogramas del morph, búsqueda sin tildes, teclado/retorno de foco, línea superior
durante consulta de sesión, calendario/hora24h y responsive/texto200%/movimiento
reducido. Evidencia en apps/mobile/build/ui-preview/web-fields.
Los scripts de recovery y sightings usan field-browser-helpers.mjs para operar
los controles visibles. No ejecutar un build mientras los fixtures están
abiertos: Windows mantiene cargada la DLL de sharp. Un dev server existente
se conserva; usar NUXT_BUILD_DIR=.nuxt-fields-validation para compilar aparte.

## SEO de landing —20/10/2026

El mismo script de optimización genera hero-*-320/640.webp para srcset/sizes y
social-reunion.jpg1200×630 para Open Graph/JSON-LD. Versionar estos derivados
al sustituir originales. Hero completo/PNG siguen disponibles; CSS y título
original conservados. El JPEG social no sustituye ilustraciones visibles.

NUXT_PUBLIC_SITE_URL define el origen HTTPS público para canonical, tarjetas
sociales, JSON-LD, robots y sitemap; predeterminado https://entrehuellas.app.
Se puede sustituir al arrancar producción sin recompilar. PUBLIC_WEB_ORIGIN
conserva su responsabilidad independiente de origen permitido para operaciones.
No usar Host para deducir la identidad SEO ni apuntar al dominio futuro antes
de activarlo. [Migración y validación](../../docs/funcionalidades/landing-page.md).

Tras sustituir PNG de landing, ejecutar `node scripts/optimize-landing-images.mjs`
y versionar sus WebP; el script verifica píxeles visibles y alfa sin pérdida.
Picture conserva los PNG originales como respaldo. Docker no necesita regenerar
imágenes ni incorporar scripts adicionales en runtime.

## Registro y recuperación por código —19/10/2026

El login incorpora /crear-cuenta y /recuperar-contrasena; el código verificado
de recuperación habilita /restablecer-contrasena sin sesión normal. Misma cuenta
Supabase que móvil; sin variables nuevas ni migraciones. Las notas siguientes
que excluyen registro web son históricas. eh_access vigente usa path /.

Requiere Auth con signup/correo habilitados, OTP6, contraseña>=8, SMTP y plantillas
Confirm signup/Reset password con {{ .Token }}. Fuentes existentes en
supabase/auth/templates; seguir su README sin reemplazar URLs/callbacks móviles.
No se modificó ni verificó configuración remota. No hay callback nuevo: se ingresa
el código en la web. Conservar PUBLIC_WEB_ORIGIN y cookies HTTPS seguras.

Comprobaciones: npm run typecheck; npm test; npm run build; npm run test:server.
scripts/check-credentials-browser.mjs usa PLAYWRIGHT_MODULE/CHROME_PATH y build
vigente con fixture, sin correos reales. Capturas en apps/mobile/build/ui-preview/
web-credentials. Login previo conserva scripts/check-access-browser.mjs.
Detalles, TTL y límites de evidencia en ADR-087 y docs/ESTADO.md.

## Acceso general —19/10/2026

Abrir /iniciar-sesion: cuenta válida → /bienvenida o /inicio sin exigir rol.
Perfil y complete_onboarding usan datos/permisos compartidos con móvil.
Gestión aparece al confirmar permiso y se valida de nuevo en cada operación.
Sin registro web ni administración todavía. URLs antiguas de login/legal
redirigen308. MODERATION_SESSION_SECRET cifra también eh_access
(HttpOnly/path /api, máximo1h sin refresh token), siempre en servidor.
Secretos de Google/Facebook pertenecen a Supabase Auth; mantener callback web
en su allowlist. Origen exacto del navegador según configuración siguiente.

QA fixture: node scripts/check-login-browser.mjs incluye bienvenida/inicio,
roles/OAuth/cierre entre pestañas. Los scripts de moderación, legales y stagger
siguen disponibles; requieren build y Playwright/Chrome como indica README.
No usan cuentas reales ni hacen despliegues.

## Incremento HU-14.3: administración solo web

/moderacion utiliza acceso real y roles de servidor, sin equivalente Flutter.
Añadir las variables nuevas de .env.example a tu entorno local existente, sin
sobrescribirlo: SUPABASE_PUBLISHABLE_KEY y MODERATION_SESSION_SECRET aleatorio
(mínimo32 caracteres). PUBLIC_WEB_ORIGIN debe coincidir exactamente con el
origen del navegador. Aplicar030 completo y asignar cuenta revisora explícita
según CONFIGURACION;029 ya está confirmado y no se reaplica. No guardar claves
reales en archivos versionados. Cookie Secure con HTTPS, HttpOnly/SameSite Strict;
expira como máximo en una hora, sin refresh token.

QA: npm test incluye moderación/arquitectura; npm run test:server incluye acceso,
CSRF/cookie/SSR/proxy/reintentos con fixture. scripts/check-moderation-browser.mjs
requiere PLAYWRIGHT_MODULE/CHROME_PATH y build actual. No realiza cambios remotos.


Antes de implementar o revisar UI web, leer
[REGLAS_UI_UX_WEB](../../docs/REGLAS_UI_UX_WEB.md): la landing final aprobada el
18/10/2026 es la base visual común para público, usuarios y administración.
Conservar fronteras arquitectónicas y adaptar componentes con uso real;
la adopción documental no significa que el QR ya esté migrado visualmente.

No instalar Vue/Nuxt globalmente. Sus versiones y las dependencias están fijadas
en package.json/package-lock.json. Node24.15+ recomendado; ver engines para rangos
admitidos. Node24.18.0 y npm11.16.0 ya están instalados en el equipo del proyecto.
En VS Code, la extensión opcional **Vue - Official** proporciona ayuda con .vue;
evitar activar simultáneamente Vetur sobre estos archivos.

Desde apps/platform:

```powershell
npm ci
Copy-Item .env.example .env
npm run dev
```

Copiar el ejemplo solo si no tienes .env; no sobrescribir credenciales existentes.
Completar SUPABASE_URL y SUPABASE_SERVER_KEY con las mismas variables del servidor
Dokploy. No usar las claves de supabase.local.json del cliente Flutter como clave
de servidor. Nuxt dev muestra http://127.0.0.1:5173. Abrir /c/<token-real> para ficha;
/ muestra la landing y /c/<token> inválido conserva neutral. No se registran
tokens ni se incluyen casos demo. La landing no necesita credenciales para leerse.

Si utilizas .env.local, iniciar con `npm run dev -- --dotenv .env.local` para
seleccionarlo explícitamente. No renombrar ni sobrescribir ese archivo. En Dokploy
siguen usándose las variables del contenedor; .env.local no entra en la imagen.

Para este servidor local, configurar `PUBLIC_WEB_ORIGIN=http://127.0.0.1:5173`
y abrir ese mismo origen (localhost es un origen distinto). No copiar aquí el
dominio HTTPS de producción: los POST se rechazarían por origen y las cookies
se configurarían para HTTPS. Reiniciar el proceso después de cambiar el entorno.

Si el acceso muestra «No pudimos conectar», revisar el estado HTTP de
`/api/moderation/oauth/start`: un 403 con `invalid_request` puede indicar origen
incorrecto. Un 503 con `unavailable`, enviando JSON válido y un proveedor admitido,
apunta a configuración del acceso ausente o inválida en ese proceso servidor;
esta ruta genera la URL sin contactar a Google/Facebook ni a Supabase.
Comprobar `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` (publicable/anon),
`MODERATION_SESSION_SECRET` (mínimo32 caracteres) y `PUBLIC_WEB_ORIGIN`.
En producción se configuran en el servicio Dokploy y requieren reiniciar o
redesplegar con autorización; tenerlas en .env.local no configura el contenedor.
No mostrar valores secretos en capturas, logs o documentación.

## Qué estás programando

Un archivo .vue puede contener `<script setup lang="ts">` para estado/acciones,
`<template>` para HTML y `<style>` para CSS. El estilo común está en app/assets.
Vue actualiza la pantalla al cambiar su estado reactivo. TypeScript ayuda a detectar
datos/operaciones incompatibles antes de ejecutar; no reemplaza validación servidor.

Nuxt sigue siendo Vue, con rutas y servidor integrados. app/pages/c/[slug].vue
corresponde a /c/<slug>. app/features contiene componentes y pantallas reales;
app/components comparte marca, botones, skeleton y toast. Los componentes consumen
ViewModel; no consultan Supabase directamente. App/plugins compone dependencias
por petición para que SSR no comparta estado de visitantes.

SSR entrega el contenido inicial del caso como HTML; Vue lo hidrata para acciones
sin volver a consultar al arrancar. Mapas/herramientas privadas podrán renderizar
en cliente cuando se implementen. Nuxt no exige SSR en todas las rutas.

Con Vue+Vite también sería posible; tendríamos que integrar por separado el
servidor de lectura y renderizado público. Elegimos Nuxt para una web con contenido
público, QR y zonas privadas futuras. No cambia Flutter ni las políticas SQL.

## Validación y producción

ADR-082: los dos endpoints logout confirman el borrado local de cookies y usan
event.waitUntil de Nitro para el intento remoto (timeout existente5s). El fixture
moderationFixture.pauseLogout retiene Supabase hasta liberarlo explícitamente;
access-production y check-session-entry-browser exigen respuesta/login antes de
liberarlo, con cookies y datos retirados. No es una cola duradera ni confirmación
de revocación remota; una caída del servidor puede interrumpir ese intento.

ADR-080: landing prepara sesión/destino en cliente y precarga su página.
AccountSessionTransport reutiliza GET de sesión máximo15s/expiración (4015s),
deduplica lecturas e invalida por mutaciones, broadcasts, foco y visibilidad.
No cachea permisos ni operaciones. check-session-entry-browser verifica que
el clic preparado y la llegada no consultan otra vez sesión, bloqueando esa API;
el clic temprano comparte la consulta pendiente. Pruebas de TTL/carreras en
access.test.mjs. SSR de landing permanece público y sin datos de cuenta.

ADR-079: todas las páginas usan shared/routing/route_policy.ts y el middleware
global de acceso. Registrar allí cualquier página o alias nuevo: pages:extend
rechaza omisiones en preparación/build y architecture.test.mjs compara el
inventario real. No seleccionar middleware de acceso desde una página.
check-session-entry-browser.mjs recorre todo el inventario SSR/SPA, incluidas
públicas, QR, aliases y moderación con/sin permiso; observa montajes privados.

Entrada sin login intermedio (ADR-078): `scripts/check-session-entry-browser.mjs`
usa PLAYWRIGHT_MODULE/CHROME_PATH y build vigente con backend fixture. Comprueba
SSR/SPA, onboarding, migración real de cookie /api a /, ausencia de montaje del
login con sesión, redirección sin JavaScript y cierre/recarga. eh_access ahora
usa path / para la validación SSR; el cierre limpia también el alcance anterior.

HU-10.1: aplicar024 en desarrollo después de023 antes de probar envíos reales.
PUBLIC_WEB_ORIGIN limita POST al origen exacto: `https://entrehuellas.app`
en producción, o el origen local del dev server si no se configura. No terminar
con slash. Navegador no recibe clave de servidor ni rutas/evidencia privada.
Ver [avistamientos web](../../docs/funcionalidades/avistamientos-web.md).

`scripts/check-sightings-browser.mjs` ejecuta navegador con backend/teselas
fixture. Requiere PLAYWRIGHT_MODULE (ruta absoluta al módulo) y CHROME_PATH.
Produce capturas en apps/mobile/build/ui-preview/public-sightings y no realiza
escrituras remotas. El build aislado acepta NUXT_BUILD_DIR; por ejemplo
`.nuxt-hu10-qa` con NUXT_IGNORE_LOCK=1 evita compartir artefactos con el dev server.
Se excluyen estos directorios de Git. No detener el servidor del usuario para QA.

```powershell
npm run typecheck
npm test
npm run build
npm run test:server
npm start
```

Las pruebas no usan datos ni secretos reales. Para revisión visual con fixtures,
ver check-browser.mjs/README; Playwright solo es herramienta de QA local.
No copiar .env a public, no usar NUXT_PUBLIC para secretos y no añadir datos de
usuario a variables de módulo del servidor. La autorización futura se comprobará
en backend además de los guards de navegación.

Dokploy conserva contexto, puerto y variables; necesita los nuevos archivos y
package-lock publicados en la rama elegida. [Pasos](DOKPLOY.md). Esta migración
no realiza push ni redeploy automático sobre la web ya operativa.

## Login separado

/login es el acceso para cuentas revisoras existentes. /moderacion sin sesión
redirige después de hidratar; cookie API/permiso servidor conservados. No existe
registro web ni asignación automática de rol. check-login-browser.mjs valida
redirecciones, roles, caducidad, pestañas, reintento y responsive con fixtures;
requiere PLAYWRIGHT_MODULE/CHROME_PATH y build vigente, igual que moderación.

Google/Facebook: POST /api/moderation/oauth/start y GET callback PKCE en servidor.
Misma configuración de moderación, más allowlist web en Supabase según
docs/CONFIGURACION. check-login-browser.mjs recorre ambos proveedores mediante
fixture, sin contactar Google/Facebook reales. Formulario estable, sin skeleton
inicial ni texto de cuentas autorizadas.

## Navegación y recuperación web —20/10/2026

`node scripts/check-origin-continuity-browser.mjs` usa PLAYWRIGHT_MODULE y
CHROME_PATH con build vigente y backend fixture. BROWSER_ORIGIN permite probar
el dev existente (por ejemplo http://127.0.0.1:5173); todas sus APIs se interceptan
hacia el fixture para no usar sesiones/datos ni backend reales. Cubre nueve puntos
y acceso negro Reportar de Inicio. Usa la timeline real de GSAP Flip de Sader
para comprobar rect inicial,0.7s, cuerpo oculto incluso99% y visible al100%.
Verifica que no se clona Inicio ni se crean capas paralelas, y que el cierre
anima el componente antes de desmontar. Dos reaperturas a tiempo real y modo
reducido por caso,1852/1255/390/320. ORIGIN_WIDTHS=320 y ORIGIN_TEXT_SCALE=200%
permiten comprobar texto ampliado. Reinicia fixture entre disparadores para
respetar el límite de login. Capturas0/45/99/100% y cierre en
apps/mobile/build/ui-preview/web-origin-sader. Sin operaciones remotas.

Animaciones: `node scripts/check-navigation-motion-browser.mjs` usa las mismas
variables PLAYWRIGHT_MODULE/CHROME_PATH y backend fixture. Comprueba fotogramas
del indicador, expansión/retorno, continuidad de cabecera, editor compartido,
descarte cancelado, resize, movimiento reducido y cierre de sesión durante el
efecto. Capturas en apps/mobile/build/ui-preview/web-navigation-motion.
Si hay un dev server activo, verificar con NUXT_BUILD_DIR separado (por ejemplo
../mobile/build/platform-motion-nuxt) y NUXT_IGNORE_LOCK=1; no limpiar su .nuxt ni
detener el proceso. Los enlaces con origin y OriginActionButton reutilizan el
controlador del plugin navigation_motion, sin cambiar lógica de las features.

`node scripts/check-recovery-browser.mjs` requiere build vigente,
PLAYWRIGHT_MODULE y CHROME_PATH como las demás comprobaciones. Levanta backend
fixture local: barra, filtros, alta/edición/foto de mascotas, cuatro reportes,
borrador/reintento y renders 1440/390/320/texto200%. No modifica Supabase real.
`npm test` incluye dominio/ViewModel de recovery y `npm run test:server` sus
contratos de sesión/onboarding, origen, actor, proyección y deduplicación.
Ver docs/funcionalidades/navegacion-web.md para alcance e integración pendiente.

## Apelaciones HU-14.4 —23/10/2026

`npm test` incluye dominio/DTO/transporte/ViewModel y `npm run test:server`
incluye apelaciones con cookie, Origin, actor, permisos, respuesta y reintentos.
Con build vigente, `scripts/check-appeals-browser.mjs` usa PLAYWRIGHT_MODULE
y CHROME_PATH como los demás scripts y genera capturas locales en
apps/mobile/build/ui-preview/appeals-web. Solo backend fixture, sin escrituras
remotas. Políticas globales: /apelaciones account y /moderacion/apelaciones
reviewer. /moderacion vive en pages/moderacion/index.vue para que la ruta
de apelaciones se monte como página independiente. Activación SQL035 pendiente.
