# Despliegue GitHub → Dokploy → entrehuellas.app

## Dominio público vigente —24/10/2026

Configurar en Environment `PUBLIC_WEB_ORIGIN=https://entrehuellas.app` y
`NUXT_PUBLIC_SITE_URL=https://entrehuellas.app`, guardar y redesplegar esta
revisión. Conservar SUPABASE_URL y los hosts de infraestructura existentes.
En Android, usar `PUBLIC_CASE_WEB_URL=https://entrehuellas.app` en la
configuración de compilación; las APK anteriores conservan sus valores.
Mantener operativo el host público anterior para QR distribuidos; preparar en
el proxy una redirección permanente de navegación que preserve ruta/parámetros,
sin reproducir POST. Comprobar login, recuperación, OAuth, /health, sitemap y QR.
No se han modificado remotamente Dokploy, Supabase ni redirecciones.

## Activación de moderación HU-14.3

No hay despliegue automático en este incremento. Tras validación/autorización,
publicar el código Nuxt y aplicar030 en el entorno correspondiente (029 ya
confirmado, no reaplicarlo). Añadir SUPABASE_PUBLISHABLE_KEY y un
MODERATION_SESSION_SECRET aleatorio de al menos32 caracteres, idéntico entre
réplicas; conservar SUPABASE_URL/SUPABASE_SERVER_KEY y PUBLIC_WEB_ORIGIN HTTPS.
No usar NUXT_PUBLIC. Rotar el secreto invalida cookies administrativas anteriores.
Asignar revisor explícito desde servidor según CONFIGURACION y verificar
/moderacion con revisor/cuenta ordinaria. La landing/QR siguen públicos; no se
despliega administración móvil ni se activa Firebase/FCM.


HU-10.1,18/10: la rama local `feature/public-web-sighting` incorpora POST de
avistamientos, sharp/Leaflet y migración024. No se ha publicado/desplegado.
Antes de activarlo: aplicar024 después de023 y añadir
`PUBLIC_WEB_ORIGIN=https://entrehuellas.app` sin slash final; mantener
SUPABASE_SERVER_KEY únicamente en Environment de servidor. Usar la rama/revisión
que se publique tras autorización, sin cambiar automáticamente el despliegue
operativo indicado en las instrucciones históricas siguientes.
Revisar cuerpos multipart hasta9MiB, timeout de recepción15s, IP del proxy
en TRUSTED_PROXY_IPS, TLS y límites compartidos SQL. Docker debe incluir la
dependencia nativa sharp para Linux; los checks locales Windows no certifican
esa imagen. SQL y web deben activarse juntos para confirmar envíos.

Landing integrada17/10/2026: / muestra la presentación institucional, sin consultas
Supabase; /c/<token> conserva las fichas y requiere backend configurado. Mismo
contexto/puerto/Environment; basta publicar esta revisión y redeploy. Raíz indexable,
robots/sitemap limitados a contenido institucional y QR noindex. No relajar CSP.

Movimiento17/10/2026: al publicar esta revisión, cambiar Dockerfile Path a
apps/platform/Dockerfile, Docker Context Path a apps/platform y Watch Paths a
apps/platform/**. Mantener dominio, stage runtime, puerto5173 y Environment.
Los campos de la tabla siguiente ya reflejan estas rutas nuevas.

Preparado el17 de octubre de2026. Dokploy construye la imagen del repositorio
y ejecuta el servidor; los secretos se añaden en su panel. No se necesita
registry, Docker Compose, volúmenes ni compilar Flutter.

Actualización Vue/Nuxt: el Dockerfile ahora construye Nuxt sobre Node24 y ejecuta
.output/server/index.mjs. Mantiene stage runtime/puerto5173/health y las mismas
variables SUPABASE_*, sin secretos de build. Contexto y dominio no cambian.
Seleccionar la rama que contenga esta migración: feature/vue-nuxt-web, una vez
publicada; la instancia actual seguirá con la versión anterior hasta redeploy.

## 1. Código disponible en GitHub

Repositorio: `https://github.com/srg-cp/entrehuellas`.
Rama preparada: `feature/vue-nuxt-web`. Estos cambios deben estar
confirmados y enviados a esa rama antes de que Dokploy pueda descargarlos.
Si luego se integra en main, cambiar la rama seleccionada en Dokploy.
Esta preparación local no realiza commit/push ni configura tu instancia.

## 2. Crear Application

En tu proyecto de Dokploy crear un servicio **Application** llamado
`entrehuellas-public-web`, conectar el proveedor GitHub y darle acceso al repo.
Guardar la configuración siguiente:

| Campo | Valor |
| --- | --- |
| Provider | GitHub |
| Repository | srg-cp/entrehuellas |
| Branch | feature/vue-nuxt-web, una vez publicada |
| Build Path | / |
| Build Type | Dockerfile |
| Dockerfile Path | apps/platform/Dockerfile |
| Docker Context Path | apps/platform |
| Docker Build Stage | runtime |
| Watch Paths, si se activa Auto Deploy | apps/platform/** |

Las rutas Dockerfile/contexto anteriores parten del checkout raíz (Build Path /).
No seleccionar Static ni Publish Directory. La imagen ya construye y arranca
la app; dejar sin comandos personalizados. No publicar5173 como puerto del host:
Traefik se conecta al puerto interno. Una réplica inicialmente; sin volúmenes.

[Campos Dockerfile oficiales](https://docs.dokploy.com/docs/core/applications/build-type),
[Watch Paths](https://docs.dokploy.com/docs/core/watch-paths).

## 3. Environment: pegar y completar

Son variables del contenedor en ejecución, **no Build Time Arguments ni secretos
de compilación**. No se necesita ninguna credencial para construir la imagen.

```dotenv
SUPABASE_URL=https://TU_PROYECTO.supabase.co
SUPABASE_SERVER_KEY=REEMPLAZAR_CON_SECRETO_SERVIDOR
HOST=0.0.0.0
PORT=5173
NODE_ENV=production
TRUSTED_PROXY_IPS=
```

Usar `sb_secret_...` o JWT service_role antiguo del mismo proyecto. No usar anon,
publishable ni el access token de una cuenta. No pegarlas en GitHub ni en el
Dockerfile. Guardar en Environment y redeploy al modificarlas.

TRUSTED_PROXY_IPS puede quedar vacío para el primer arranque: ignorará cabeceras
de IP y el límite será compartido por visitantes del mismo proxy. Para límite
por visitante, introducir únicamente la IP exacta del peer Traefik que conecta
a este servicio y comprobar que anexa/reemplaza X-Forwarded-For. No adivinar IPs
ni aceptar cualquier origen. Tras recrear la red, revisar si esa IP cambió.
La limitación no es distribuida; varias réplicas necesitan límite en el proxy.

## 4. Base de datos y dominio

Antes de probar casos reales, aplicar022 si falta y después
`database/patchs/023_patch_public_qr_case.sql` completo en desarrollo. Si se usan
migraciones Supabase, aplicar la equivalente20261016002300 una sola vez; no ambos
mecanismos y no todo run_all sobre producción. El contenedor no aplica SQL.

DNS: registro A del host `@` en la zona `entrehuellas.app`, apuntando a la IPv4 pública del VDS.
No dejar un AAAA apuntando a otro servidor. Luego, en Domains de la Application:

| Campo | Valor |
| --- | --- |
| Host | entrehuellas.app |
| Path | / |
| Internal Path | / (o vacío si la versión no lo requiere) |
| Strip Path | desactivado |
| Container Port | 5173 |
| HTTPS | activado |
| Certificate | Let's Encrypt |

No establecer /c como prefijo: también necesita /api/c y assets de la raíz.
Conservar no-store/CSP y excluir este host de caché CDN/proxy; no añadir logs de
URLs/analytics con tokens. HTTPS llega a Traefik; Node sirve HTTP internamente.
DNS y puertos80/443 deben permitir que Traefik obtenga el certificado.
[Dominios oficiales](https://docs.dokploy.com/docs/core/domains).

## 5. Deploy y comprobar

Pulsar Deploy; la imagen corre como usuario node e incluye healthcheck /health
cada30s, con espera inicial10s. Si Dokploy reemplaza el healthcheck en Advanced,
usar `node scripts/healthcheck.mjs`, timeout5s, retries3, intervalo30s.
No instalar curl ni cambiar el comando de arranque.

```powershell
curl.exe --fail --silent --show-error https://entrehuellas.app/health
curl.exe --head https://entrehuellas.app/c/no-existe
```

Esperado: health devuelve `{"status":"ok"}`; página /c/no-existe devuelve HTML200
y muestra el estado neutral al ejecutar JavaScript. API de token desconocido
devuelve404. /health confirma proceso/HTTP, **no** permisos SQL ni Storage:
probar además un token real, fotos y cierre/revocación desde otro teléfono.
Una página neutral no acredita que la conexión Supabase funcione.
No compartir el token real en logs, screenshots públicas o tickets.

Con la ficha real verificada, activar PUBLIC_CASE_WEB_READY en la configuración
Flutter cuando corresponda. No se cambia ahora. Formulario HU-10.1 aún pendiente.

## 6. Próximos cambios desde GitHub

Después del primer despliegue correcto se puede activar **Auto Deploy** en la
Application con Watch Paths apps/platform/**. El proveedor GitHub puede disparar
el despliegue con los push de la rama elegida, según la
[documentación de Dokploy](https://docs.dokploy.com/docs/core/auto-deploy).
No hace falta un token Dokploy en GitHub Actions para este recorrido. Auto Deploy
directo no espera necesariamente a CI: si se necesita esa condición, usar despliegue
manual de una revisión aprobada o integrar un flujo CI→deploy posteriormente.

El workflow public-web valida Node y construye/prueba el contenedor sin secretos
reales, sin desplegar. Las migraciones SQL siempre se activan aparte y antes del
cliente que las necesita. Ante una regresión usar Rollback en Dokploy; no revertir
SQL aplicado editando los archivos de migración.
