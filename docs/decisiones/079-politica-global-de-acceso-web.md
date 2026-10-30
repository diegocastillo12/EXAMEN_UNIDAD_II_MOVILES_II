# ADR-079: política global de acceso y navegación web

Fecha:19/10/2026. Autoridad: el usuario exige que la comprobación previa aplique
a todas las rutas de platform, sin correcciones o guards por pantalla.
Estado: implementada y validada localmente con backend fixture.
Trazabilidad: HU-01/RF-01,34 y HU-14.3/RF-22,33 / issue #45; sin nuevas historias.
Sustituye los middleware de ruta individuales de ADR-078 y la excepción inicial
de moderación que esperaba a montar antes de validar acceso.

## Decisión

shared/routing/route_policy.ts es el registro único de políticas para todas las
páginas: públicas, solo acceso, cuenta, onboarding y revisión con permiso.
El registro admite rutas exactas y segmentos dinámicos parametrizados, con la
misma resolución en servidor y cliente; el fallback público queda explícito.
sessionRedirect aplica la misma regla de etapa en servidor y cliente. Una cuenta
válida puede permanecer en cualquier ruta autorizada para su etapa, sin enviarla
siempre a /inicio. La autorización por operación sigue en API/SQL.

session-entry evalúa la política antes de renderizar HTML y access.global antes
de montar en cada navegación cliente, incluida la hidratación. Se eliminan
guest-access, account-access y moderation-access y las selecciones de middleware
de las páginas. La comprobación cliente utiliza el ViewModel/casos de uso;
el servidor compone los mismos contratos de cuenta por petición, sin singleton,
perfiles/tokens en HTML ni acceso a data entre funcionalidades.

Sin sesión no se monta ninguna pantalla protegida ni su skeleton antes del login.
En moderación también se verifica el permiso mediante ReadManagementAccess antes
de renderizar/montar: denegado dirige a /inicio?reason=forbidden; onboarding
pendiente dirige a /bienvenida. No se supone herencia de administrador a moderador.
Las pantallas conservan la comprobación de identidad/caducidad mientras están
abiertas; el guard global no sustituye ni esas comprobaciones ni las de servidor.

Landing, legales, QR y el fallback público mantienen acceso anónimo. /login,
/terms y /privacy conservan sus redirecciones308 y parámetros. APIs, OAuth,
estáticos y endpoints operativos conservan sus controles propios. No se exige
sesión para leer un QR ni se confunde una ruta desconocida con una cuenta.

## Rutas futuras y compatibilidad

Toda página nueva debe registrar su política. El hook pages:extend valida las
rutas y alias en la preparación/build de Nuxt; una ruta sin declaración falla
con un mensaje explícito. La prueba arquitectónica compara el inventario real
de app/pages con el registro y prohíbe volver a elegir middleware por pantalla.
No basta recordar añadir un guard: se ejecuta globalmente y la clasificación
se exige al incorporar la página. Nuevos tipos de permisos requieren su propia
implementación de servidor, sin crear roles o pantallas ficticios.

El puente de cookies /api anteriores admite únicamente destinos de cuenta
registrados (incluida moderación), descarta destinos externos y vuelve a aplicar
etapa/permisos al entrar. Cifrado, HttpOnly, SameSite, vencimiento y limpieza de
ambos paths de ADR-078 se conservan. Los fallos de backend mantienen reintento
y no se convierten en sesión ausente; los marcadores entry solo controlan la
navegación del shell sin datos, nunca conceden identidad o autorización.

## Validación y límites

Corrección posterior del19/10 por captura del usuario: una navegación iniciada
desde otro sitio conserva Sec-Fetch-Site: cross-site durante las redirecciones.
El filtro API bloqueaba /api/access/entry y mostraba JSON forbidden en lugar del
login. Se permite exclusivamente GET/HEAD a ese puente cuando Fetch Metadata
indica navigate/document. El endpoint solo devuelve destinos internos validados,
sin HTML de cuenta ni JSON privado. Fetch/XHR, iframe, escrituras y otras APIs
conservan el rechazo cross-site; cookies SameSite Strict no se relajan.
Se incorpora regresión de servidor con esos headers y enlace externo real en
Chrome; las pruebas anteriores no cubrían esta procedencia de navegación.

Pruebas arquitectónicas verifican inventario/registro y rechazo de rutas nuevas
sin política. Servidor recorre todas las rutas registradas, QR/aliases/fallback,
anonimato, onboarding, cuentas ordinarias, revisores, revocación y puente seguro.
Chrome recorre el mismo inventario con apertura directa y SPA; observa montajes
para impedir pantallas privadas/skeleton tras logout o moderación sin permiso.
Suites completas de acceso y moderación conservan caducidad, pestañas, OAuth,
reintentos, operaciones reales y responsive. Resultados en ESTADO.

No cambia SQL, Flutter, configuración remota ni alcance del MVP. Sin despliegue,
publicación o cierre de historias. La confirmación con cuentas reales permanece
pendiente; el backend fixture no acredita el entorno remoto.
