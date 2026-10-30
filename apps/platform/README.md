# Web Entre Huellas — Vue + Nuxt + TypeScript

## Acceso general e inicio de cuenta —19/10/2026

/iniciar-sesion admite cuentas existentes por correo/Google/Facebook sin rol
de revisión. /bienvenida aplica tres pasos por cuenta con RPC existente;
/inicio muestra perfil real/cierre y acceso a gestión según permiso.
/login, /terms y /privacy redirigen a /iniciar-sesion, /terminos y /privacidad.
Callback OAuth y /c/<token> conservados. Reutiliza SUPABASE_URL,
SUPABASE_PUBLISHABLE_KEY, MODERATION_SESSION_SECRET y PUBLIC_WEB_ORIGIN.
El secreto de nombre histórico cifra también la sesión general, solo servidor.
Máximo1h sin refresh token. Sin paridad web/móvil completa ni administración.
[Alcance y activación](../../docs/funcionalidades/acceso-web.md).
Esta actualización sustituye la ausencia de login descrita en la nota histórica
del17/10 siguiente; las fichas de funcionalidades registran el alcance vigente.

## Moderación de denuncias

/moderacion incorpora HU-14.3: acceso de revisores, cola, evidencia y decisiones
con motivo/auditoría. Exclusivamente web; móvil conserva denuncia del usuario.
Requiere patch030 (029 ya confirmado), cuenta existente con contraseña, rol
asignado en servidor, SUPABASE_PUBLISHABLE_KEY y MODERATION_SESSION_SECRET.
No exponer variables de servidor en NUXT_PUBLIC ni en el cliente. La landing/QR
siguen siendo públicos. [Configuración](../../docs/CONFIGURACION.md),
[ficha](../../docs/funcionalidades/moderacion-web.md).


Incremento17/10/2026 en feature/vue-nuxt-web. Migra HU-09/RF-09/#9 a Vue,
conservando diseño, /c/<token>, API, fotos privadas y SQL022/023. Esta base es
la aplicación web única acordada para público/usuarios/administración por roles.
La raíz / integra la landing de feature/landing-page, convertida a componentes
Vue y conservando su diseño. Las fichas siguen en /c/<token>. No hay todavía
login web ni administración; no se añaden rutas de producto ficticias.

Guía para empezar con Vue: **[DESARROLLO.md](DESARROLLO.md)**.

Despliegue en el VDS del usuario: **[guía Dokploy desde GitHub](DOKPLOY.md)**.
Dockerfile listo para contexto apps/platform, stage runtime y puerto5173;
variables solo en ejecución, healthcheck incorporado y CI de contenedor preparado.

Vue3, Nuxt4, TypeScript estricto y servidor Nitro. Node24.15+ recomendado
(local verificado24.18.0); Docker y CI usan Node24.
Ruta acordada: `https://entrehuellas.app/c/<token opaco de 64 hex>`.
Migración local: no acredita un nuevo despliegue ni cierra HU-09. El formulario y la
recepción de avistamientos corresponden a HU-10.1/#36 y aún no existen aquí.

## Ejecución

Requiere backend con migraciones001–023 y pipeline de fotos operativo.
Copiar `.env.example` a `.env` local (ignorado por Git) y completar las dos
variables Supabase. Desde esta carpeta:

```powershell
npm run build
npm start
```

Abrir `http://127.0.0.1:5173/` para la presentación y `/c/<token-real>` para
una ficha; un token inválido conserva el estado neutral. No se crea una sesión
ni se incluyen casos de demostración.
Ejecutar `npm ci` antes del primer build. Para desarrollar: `npm run dev`;
Nuxt carga .env local. Para validar: `npm run typecheck`, `npm test`,
`npm run build`, `npm run test:server`. Las pruebas usan un backend HTTP de prueba
y nunca Supabase real. El script de navegador requiere build previo.

Con .env.local: `npm run dev -- --dotenv .env.local`. QA de la landing con
`node scripts/check-landing-browser.mjs`, usando PLAYWRIGHT_MODULE y CHROME_PATH
como en el QA de QR; resultados en apps/mobile/build/ui-preview/landing-vue.

QA visual reproducible con Playwright1.62.1 instalado fuera de producción:

```powershell
$env:PLAYWRIGHT_MODULE='C:/ruta/node_modules/playwright/index.js'
$env:CHROME_PATH='C:/Program Files/Google/Chrome/Application/chrome.exe'
node scripts/check-browser.mjs
```

Usa fixtures solo de prueba y el asset aprobado de onboarding; guarda capturas
en `apps/mobile/build/ui-preview/public-web`. No acredita
un QR físico, iPhone/Safari ni Storage real.

## Configuración y publicación pendiente

`SUPABASE_SERVER_KEY` es un secreto exclusivamente del proceso servidor. Acepta
`sb_secret_...` y el JWT antiguo con rol `service_role`; rechaza claves del cliente.
Las primeras se envían únicamente en `apikey`; las JWT también en Authorization,
según [la documentación de Supabase](https://supabase.com/docs/guides/getting-started/api-keys).
El navegador solo recibe entidades con campos permitidos y fotos por índice;
no recibe credenciales, UUID de propietario, paths privados ni URLs firmadas.

El despliegue ejecuta `.output/server/index.mjs`, con assets de `.output/public`.
Nunca publicar el checkout ni .env como raíz estática. Se necesita un proceso Node:
subir solo assets a hosting estático no implementa SSR ni `/api/c/...`.
Dockerfile multietapa incluye solo fuentes necesarios y build público, corre sin
root e incluye healthcheck. .dockerignore excluye secretos/fixtures del contexto.
El workflow comprueba build/arranque del contenedor, sin desplegar. Ver DOKPLOY.md.

Publicar detrás de TLS en el dominio acordado, con todo `/` enviado a Node,
sin caché de CDN/proxy para HTML, API ni fotos. Mantener cabeceras CSP/no-store
y no registrar rutas `/c/` o `/api/c/` en logs/analytics: contienen tokens.
No añadir trackers. `HOST` predetermina loopback; para contenedor usar0.0.0.0.
`TRUSTED_PROXY_IPS` admite solo IPs exactas del peer que controla X-Forwarded-For;
el proxy debe reemplazarlo/anexar la IP real. Sin esa configuración, el límite
se aplica a la IP del proxy compartida, sin confiar en cabeceras del visitante.
Límite en memoria:60 peticiones/minuto/IP y64 operaciones concurrentes/proceso.
En múltiples réplicas se requiere un límite adicional en el proxy; no se añade Redis.

Activación en desarrollo antes de uso real:

1. Aplicar023 después de022 mediante el mecanismo SQL habitual, una sola vez.
2. Configurar el secreto en el servicio servidor y publicar Node/TLS.
3. Crear/obtener un enlace real autorizado con el contrato de carteles de022.
4. Desde otro teléfono sin app: probar caso activo y fotos, comparar zona pública,
   cerrar y comprobar retirada de fotos; revocar y comparar con token inexistente.
5. Verificar en red que no hay secretos, paths Storage ni referencias exactas;
   comprobar reintento offline, cabeceras y ausencia de caché del proxy.
6. Solo entonces habilitar `PUBLIC_CASE_WEB_READY=true` en Flutter. Permanece
   false en esta entrega. Integrar #36 antes de cerrar la historia completa.

La revocación es RPC autenticada `revoke_case_public_link(source,id)`, solo autor,
idempotente e irreversible para ese enlace. No se añade un botón nuevo a Flutter.
No revoca bytes ya descargados ni PDFs impresos; sí impide futuras lecturas.
Las pestañas visibles consultan de nuevo cada60s y al recuperar visibilidad;
también existe Actualizar estado. Sin canal en tiempo real.

## Límites de capas

`shared/features/case_reader/domain` valida entidades y declara contratos/casos
de uso sin Vue/Node/SDK. Data HTTP y ViewModel puros en shared; widgets/pantalla Vue
en app/features, composición por petición en app/plugins y páginas en app/pages.
`server/features` encapsula DTO/REST Supabase, `server/utils` compone casos de uso,
`server/api` transporta respuestas y middleware/plugins gestionan límites/CSP.
Credenciales existentes SUPABASE_* se leen solo en server, sin runtimeConfig.public.
El payload SSR solo contiene la entidad pública; no se cachea por token.
La RPC privada devuelve descriptores Storage solo al servidor; este los valida,
descarga JPEG procesado y vuelve a comprobar estado/revocación antes de responder.
Una lectura anónima no amplía grants de tablas ni permisos Storage.

El Node antiguo y su vista DOM manual se han retirado. HTML inicial SSR con
hidratación sin segunda consulta, nonce CSP por respuesta y eventos Vue;
no v-html para contenido de casos. .output contiene solo el runtime construido.
No activar prerender/ISR/cache de fichas o sesiones. La landing podrá tener
generación estática al integrarla, sin aplicar esa política a contenido privado.

## Auditoría de dependencias del17/10/2026

`npm audit --omit=dev` y auditoría independiente de las dependencias exactas del
package.json generado en .output/server:0 vulnerabilidades conocidas. Esto no
prueba ausencia de fallos en el código compilado. El árbol completo instalado
reporta11 altas, propagadas desde braces<=3.0.3 y node-forge<=1.4.0 a herramientas
de Nuxt/Nitro (glob/dev server). No había versiones corregidas publicadas para
esas dos dependencias al verificar; npm audit fix compatible no las resuelve.
No se aplicó downgrade forzado ni se suprimieron avisos. Esos paquetes no están
en los node_modules del runtime generado, comprobado por inventario. Nuxt es
dependencia de desarrollo/build; la imagen final solo copia .output. El servidor
dev no debe exponerse públicamente. Mantener seguimiento de upstream y repetir
audit completo/runtime antes de distribuir nuevas versiones.

## Recursos de la landing

Se retiró el atlas del mockup: `public/images/landing` contiene siete PNG RGBA independientes generados individualmente con imagegen. Componentes Vue y CSS dibujan la UI; el logo oficial sigue siendo `/brand.png`. Consultar [prompts y procedencia](LANDING_ASSETS.md). La animación aprobada del hero se conserva. Los PNG priorizan detalle y alfa; no se ha medido rendimiento de red móvil real ni Core Web Vitals. Los recursos se cargan de forma diferida salvo hero y se reutilizan por URL. El incremento no publica ni hace redeploy.

Actualización posterior de marca/diversidad17/10: diez ilustraciones con mascotas y pañuelos variados. El emblema blanco se genera dentro de la tela, usando only-black.svg como referencia; no hay capas de logos superpuestas. La marca usa /brand.png actualizado y el favicon /brand-icon.png; /brand.svg conserva el vector oficial disponible. Ver LANDING_ASSETS.md para prompts finales y procedencia. No se añaden dependencias ni se modifica el hero aprobado.
Cartografía global20/10, ADR-104: configurar `NUXT_PUBLIC_MAP_TILE_URL` con la
misma URL CARTO Positron de `MAP_TILE_URL` móvil. Es configuración visible del
proveedor de teselas; nunca usar tokens/secretos de Supabase en ella. El ejemplo
contiene `API_KEY`, sin credenciales reales. La URL local ya está en `.env`
ignorado; para producción añadir la variable del entorno y desplegar/reiniciar.
Todos los mapas web reutilizan `LocationMap` y el acabado intermedio común a
móvil. Sin variable válida se conserva el fallo/reintento, no un mapa simulado.
[Ficha compartida](../../docs/funcionalidades/cartografia-compartida.md).

## Bloqueos de cuentas —23/10/2026

`/cuentas-bloqueadas` usa la política global `account`; acceso desde Perfil y
contexto de Explorar. APIs `/api/user-blocks/*` enlazan sesión/actor, exigen origen
exacto en POST, cuerpo JSON acotado y RPC propias con credencial de usuario.
Requiere patch034 después de033,035 después de034 y Nuxt actualizado;
035 oculta contacto/foto entre cuentas bloqueadas, según confirmación del usuario,
conservando consentimiento y QR anónimo. Sin variables nuevas.
El adaptador de avistamientos y reportes traduce `interaction_blocked` a un
fallo específico, sin revelar quién mantiene la elección. [Ficha](../../docs/funcionalidades/bloqueos-usuarios.md).
`npm test`, `npm run test:server` y `scripts/check-user-blocks-browser.mjs`
incluyen la nueva funcionalidad. Activación/demo hosted pendientes.
