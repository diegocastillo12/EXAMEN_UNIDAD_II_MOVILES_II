# Ficha pública QR

24/10/2026: dominio público actualizado a `https://entrehuellas.app`. Los
endpoints de Supabase y la infraestructura se conservan. Código/configuración
local actualizados; despliegue, retorno OAuth, envío de correo y escaneo de QR
en producción pendientes de comprobación. Los QR/PDF ya distribuidos con el
subdominio anterior necesitan mantener ese host o una redirección de navegación
a la misma ruta y parámetros; el código no regenera documentos existentes.


Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión en dispositivos reales pendiente.

## Marca compartida con landing —19/10/2026

Cabecera usa SiteBrand/SiteHeader con la misma posición, color, fuente y tamaños
adaptables de landing, también en responsive y fuera del stagger. Sin cambios
de negocio, permisos o persistencia. Validación local en ESTADO; sin despliegue.
[ADR-077](../decisiones/077-marca-web-compartida-referencia-landing.md).

## Reveal compartido —19/10/2026

Sustituida la utilidad .reveal por StaggerReveal/useStaggerReveal sin capa crema.
Conserva HTML/acciones, no repite entrada por edición/refresh; movimiento reducido
inmediato. QR conserva lectura SSR sin JS. Sin cambios de datos/permisos.
[ADR-075](../decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md); evidencia local en ESTADO,
sin despliegue ni nuevo cierre de historia.

**Auditoría de seguimiento18/10:** HU-09/#9 en Done:022/023 y generación/lectura QR confirmadas; migración Vue integrada y avistamientos web posteriores aceptados. El lector pendiente de desplegar es una nota histórica. Impresión/escaneo físicos y exportación nativa conservan sus criterios en HU-08/#34/#35.

Incremento18/10/2026: ficha activa integra el [formulario de avistamientos web](avistamientos-web.md)
HU-10.1/#36 mediante slot compuesto en la página. WebShell/ActionButton y QR
adoptan la referencia web ADR-063; sin import de UI de landing. Conserva lectura,
estado/fotos compartidos y no publica la ubicación/evidencia de avistamientos.
Nueva escritura requiere024 y redeploy; cierre/revocación se validan en servidor.
Las notas históricas «no hay formulario/HU-10 pendiente» se sustituyen por esta
implementación local, sin certificar activación remota.022/023 ya confirmados
por el usuario, como consta arriba; no vuelven a solicitarse por notas antiguas.

Migración17/10/2026 en feature/vue-nuxt-web: Vue/Nuxt/TypeScript sustituye
la vista DOM y HTTP manual, manteniendo proyección, /c/<token>, API y fotos.
Primera lectura SSR con entidad permitida e hidratación sin segunda consulta;
componentes Vue compartidos, nonce CSP y estado por petición. Sin SQL nuevo.
Usuario confirma022/023 aplicados y recorrido QR funcionando en versión previa;
la migración Vue sigue local hasta publicación/redeploy. [ADR-058](../decisiones/058-web-unica-vue-nuxt-y-roles.md),
[guía Vue](../../apps/platform/DESARROLLO.md). Landing, login/admin web e integración
HU-10 siguen fuera de este incremento.

HU-09 / RF-09 / issue #9. Incremento local del16 de octubre de2026 en
`feature/public-qr-case-web`. Consulta implementada; historia abierta por
integración HU-10.1 y validación/activación remota pendientes.

## Recorrido y campos

El QR de HU-08 abre `https://entrehuellas.app/c/<token>` sin instalar
la app ni iniciar sesión. Activo:1–3 fotos procesadas seleccionadas, nombre
cuando existe, especie/detalle/tamaño/sexo disponibles, rasgos, fecha,
zona pública aproximada y estado. Galería glass, compartir/copia real y
actualización manual; consulta cada60s visible/al volver a la pestaña.
El enlace externo de área usa solo coordenadas públicas redondeadas.

Cerrado: mensaje y fecha real del evento cuando existe, sin fotos/ficha privada
ni motivo inventado. Revocado, inexistente y eliminado: mismo estado neutral.
No hay formulario ni CTA ficticia: HU-10.1/#36 lo incorporará.

## Persistencia y permisos

Reutiliza tokens opacos64hex de022. No modifica casos. Fuentes080–082/plan023:
lector solo service_role y revocación solo autor autenticado; tablas/Storage
siguen privados. El navegador consulta al servidor Node, que filtra DTO y
sirve fotos por índice tras comprobar vigencia dos veces. No devuelve claves,
propietario/contacto, referencia privada, coordenadas exactas ni paths Storage.
Revocar es idempotente y no reactiva enlaces; actualmente es RPC sin nueva UI.

## Errores y reintentos

Skeleton inicial; shimmer sobre contenido conservado al actualizar. Fallos y
resultados en toast superior con reintento real, cierre/temporizador; compartir
cancelado es silencioso. Consultas repetidas se deduplican y se descartan
respuestas de rutas anteriores. Un fallo de red conserva ficha; cierre/revocación
confirmados la retiran. Copias descargadas/impresas no se revocan retroactivamente.

## Dependencias y activación

Preparación Dokploy17/10/2026: [guía GitHub→VDS](../../apps/platform/DOKPLOY.md),
Dockerfile multietapa/runtime no root, contexto permitido por .dockerignore,
healthcheck y CI de build/arranque sin secretos reales. El usuario completará
Environment. No configura automáticamente su panel, DNS, SQL ni publica la rama.

Node22+, Supabase001–023 y pipeline de rendiciones; secreto solo servidor,
HTTPS en el dominio elegido y proxy sin caché ni logs de tokens. Límites por
IP/concurrencia por proceso. [README](../../apps/platform/README.md),
[ADR-057](../decisiones/057-ficha-qr-web-y-proxy-privado.md).
PUBLIC_CASE_WEB_READY sigue false hasta comprobar hosting/lectura real.

## Validación pendiente

Resultados locales de Node, SQL/PostGIS y revisión Chrome en [ESTADO](../ESTADO.md).
Pendientes: aplicar023, Supabase/Storage real, DNS/TLS/proxy, segundo teléfono
sin app/Safari, QR impreso, cierre/revocación reales y límites con varias réplicas.
No se publica ni habilita generación de PDFs en este incremento.
