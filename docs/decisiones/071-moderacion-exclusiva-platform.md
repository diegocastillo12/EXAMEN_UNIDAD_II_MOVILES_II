# ADR-071: moderación exclusiva de la plataforma web

Fecha:18/10/2026. Estado: implementada localmente; activación030/demo pendientes.
Trazabilidad: HU-14.3 / RF-22,33; issue #45. Complementa ADR-058/063/070.

## Autoridad y alcance

El usuario autoriza continuar la revisión/moderación y dispone expresamente
que móvil no tendrá administración: todas sus pantallas y acciones estarán en
`apps/platform`. Se actualizan AGENTS y reglas de arquitectura/UI. No cambia la
arquitectura por funcionalidad ni se crea otro proyecto por rol. Flutter conserva
HU-14.1, denuncia de contenido por usuarios, sin controles administrativos nuevos.

Se entrega `/moderacion`: acceso, cola paginada de pendientes/resueltas, revisión
privada, foto primaria procesada bajo petición, decisión con motivo y últimas20
decisiones. Ocultar/restaurar cambia visibilidad; resolver sin cambiar visibilidad
atiende una denuncia sin alterar ese control. No se suspende una cuenta ni se
implementan bloqueo de usuarios, apelaciones o métricas de historias posteriores.

## Acceso web y fronteras

La plataforma no tenía acceso web. Se incorpora acceso de correo/contraseña para
cuentas ya existentes, exclusivamente para este recorrido autorizado. No crea
cuentas ni roles, ni finge registro/OAuth/panel de usuarios. Auth valida la cuenta;
cada operación comprueba usuario y pertenencia a `content_report_reviewers` en
servidor y en SQL. La asignación/revocación es una operación privilegiada de
servidor documentada, sin autoasignación ni revisores predefinidos.

Dominio TypeScript independiente: contratos, entidades y casos de uso de acceso,
revisión y decisión. Datos HTTP del navegador y fuentes/repositorios de servidor
separados; DTO entrega solo los campos necesarios. ViewModel gobierna estado,
casos de uso y errores; Vue renderiza y compone componentes compartidos.
Plugins crean dependencias por instancia/petición; no hay estado privado global.

El HTML SSR solo contiene shell/skeleton. Los datos privados se consultan tras
montar y autenticar; no entran en HTML, payload SSR ni SEO. API same-origin con
no-store, noindex, límites de cuerpo/tiempo, comprobación de Origin en POST y
rechazo de peticiones cross-site. La identidad esperada liga las peticiones de
datos/decisión a la sesión mostrada. Cambios de sesión entre pestañas limpian
datos; expiración, error de acceso, logout y disposición descartan respuestas
tardías. No se relaja CSP ni se exponen secretos en app/shared/public.

## Sesión y configuración

Auth se consume desde servidor con clave publicable y JWT del usuario, no con
service_role para ejecutar decisiones. Token en cookie HttpOnly, SameSite Strict,
Secure en origen HTTPS, limitada a `/api/moderation`; contenido cifrado/autenticado
AES-256-GCM con secreto del servidor. No hay token en localStorage ni JS cliente.
La cookie dura como máximo una hora o la vigencia menor del access token. No se
conserva refresh token; al expirar se vuelve a iniciar sesión. Cerrar sesión
retira la cookie y solicita logout de esta sesión, sin cerrar sesiones Android.
Como en Auth, un JWT ya emitido conserva su vencimiento; retirar el rol impide
nuevas operaciones incluso con una sesión criptográficamente válida.

Variables nuevas, solo servidor: `SUPABASE_PUBLISHABLE_KEY` y
`MODERATION_SESSION_SECRET` (aleatorio, mínimo32 caracteres, compartido entre
réplicas). `SUPABASE_SERVER_KEY` existente solo sirve para QR/proxy de foto
procesada tras autorización auditada. Rotar el secreto invalida cookies previas.
La landing y el QR siguen operando aunque falte configuración de moderación.

## Persistencia, visibilidad y auditoría

Plan030/fuentes102–105 después de029 confirmado por usuario. Tablas privadas sin
grants directos: visibilidad por clase/UUID/version, resoluciones, decisiones
append-only y accesos. Cola, detalle, evidencia y decisión registran actor/fecha;
lectura privilegiada por la RPC anterior de029 también se audita. Una RPC interna
autoriza y bloquea la asignación de rol durante la transacción.

Cada decisión usa UUID estable, versión esperada de denuncia y versión esperada
del recurso. Denuncias distintas del mismo recurso se serializan; conflictos no
borran decisiones. Repetir la misma orden devuelve el recibo original, incluso
si otra decisión posterior cambió la visibilidad. Sin éxito optimista. Respuesta
ambigua congela contenido/UUID; conflicto exige consulta explícita actualizada.
Fallo de esa consulta conserva borrador y orden; cancelar salida conserva campos.

Visibilidad es independiente del estado operativo: no cierra casos, no cambia
contador de mascotas ni borra historial/evidencia. Lecturas públicas, Explorar,
guardados, QR y permisos de fotos excluyen contenido oculto; avisos vinculados y
avistamientos heredan ocultamiento de su búsqueda. La revisión ordinaria no
expone avistamientos ocultos. Nuevos avisos/avistamientos se rechazan en búsquedas
ocultas; reintentos ya confirmados conservan recibo. Las lecturas privadas propias
de gestión y los registros de ciclo de vida se mantienen. Restaurar no revierte
eliminación del autor, cierre del caso ni ocultamiento de la búsqueda vinculada.
Bytes descargados o URLs firmadas ya emitidas conservan sus límites previos de
vigencia; no se afirma revocación de material que un tercero ya recibió.

La evidencia web solo muestra texto y foto primaria procesada, no coordenadas,
referencias de vivienda ni originales. El proxy autoriza/audita antes de leer
bytes; no acepta bucket/path del navegador. Historial íntegro permanece en SQL;
la pantalla presenta las últimas20 decisiones para esta cola mínima.

## Generación y validación

SQL aplicado001–029 permanece inmutable. Build-RunAll valida migraciones previas
y genera bundle y patch030; deja de reescribir innecesariamente patches anteriores
idénticos, evitando bloqueos de archivos observados en Windows. Cada generador
Build-*Patch sigue disponible para generar/comprobar su artefacto específico.
Se prueba repetición con las migraciones previas y permisos vigentes.

Pruebas SQL de roles/auditoría/CAS/replay/visibilidad/QR/fotos/avistamientos y
regresión, pruebas TypeScript, producción Nuxt y Chrome con fixtures. Resultados
finales en ESTADO. PGlite encola una conexión: no acredita contención hosted
multiconexión. Pendientes030, variables/rol y demo real/despliegue autorizado.
Firebase/FCM está fuera del alcance, sin depender de su activación.

## Acceso separado por solicitud del usuario — 18/10/2026

/login contiene el formulario; /moderacion conserva únicamente la revisión.
AccessViewModel consume el caso de uso AccessModeration existente y se compone
en plugin, sin cargar cola ni compartir estado privado entre instancias.
El middleware cliente valida por caso de uso; en primera visita SSR el shell
se hidrata antes de comprobar sesión/redirigir para evitar mismatch. La cookie
permanece limitada a /api/moderation; no se amplía para leerla desde la página.
La autorización sigue en servidor por operación. Destino posterior fijo
/moderacion, sin redirects externos;403 denegado y503 recuperable. Login, logout,
caducidad/cambios entre pestañas y descarte de respuestas tardías comprobados
con fixtures; detalle en ficha acceso-web y ESTADO. Sin SQL nuevo/despliegue.

## Referencia visual del login — 18/10/2026

El usuario pide adaptar diseño móvil y composición de sader-panel conservando
la tipografía web actual. /login usa Arial, marca grande, columna sin tarjeta
exterior, campos neutros con iconos, visibilidad de contraseña y botón carbón.
WebShell minimal permite la composición sin duplicar navegación institucional.
LoginInput reutilizado, etiquetas persistentes/foco, toast/skeleton/shimmer y
movimiento reducido conservados. Es una variante visual autorizada del acceso;
no añade autenticación social/registro/recuperación ni modifica permisos.
Validación responsive/Chrome/27 pruebas/tipos/build en ESTADO y ficha acceso-web.

## Google/Facebook en acceso web —18/10/2026

Por solicitud del usuario, se añaden proveedores web con PKCE de Supabase.
StartSocialSignIn/CompleteSocialSignIn separan operaciones del dominio; acceso
a proveedores/token encapsulado en data/fuente servidor. Estado/verifier aleatorios
en cookie cifrada HttpOnly Lax600s, validación de callback y código de un uso;
Auth y rol preceden a la sesión de moderación Strict. Solo callback GET exceptúa
bloqueo cross-site, protegido por state/PKCE; inicio POST exige origen exacto y
límites. Fallos/cancelaciones vuelven a rutas fijas y toast. Sin credenciales de
proveedor en Nuxt cliente; Google/Facebook se configuran en Supabase.
Formulario estático ya visible mientras comprueba sesión, sin skeleton de datos,
para evitar sustitución/reveal repetido. Retirado texto de cuentas autorizadas.
Validación30 pruebas/8 producción/tipos/build/Chrome fixture en ESTADO.
Activación remota/allowlist/demo real pendientes. No altera autorización por rol.

## Icono, fondo compartido y documentos legales —18/10/2026

Por petición del usuario, AmbientPageShell reutiliza WebShell minimal/orbe/fondo
en login y documentos legales. Icono con entrada/hover de sader-panel y movimiento
reducido respetado. /terms y /privacy son presentación estática pública SSR
con LegalPage compartido; no requieren dominio o ViewModels sin operaciones.
Correo y korMind provistos por usuario; redacción permanente del servicio.
No añade captura de consentimiento ni cambia autorización/cookies/SQL.
Reglas web, fichas e índice actualizados; validación en ESTADO.

## Recarga y entrada del login —18/10/2026

Por instrucción explícita se adopta la entrada sader-panel850ms/90ms/blur18/
translateY(-28), sin cover pintado en /login. La cobertura global crema causaba
el destello amarillo; se retira .reveal solo del formulario de login, sin tocar
el efecto global ni otras páginas. Seis grupos estables, sin repetir por estado
o edición; cabecera entra una vez por la nueva referencia. Hover/orbe/Arial y
movimiento reducido conservados. Reglas y validación actualizadas en ESTADO.

## Presentación legal igualada a sader-panel —18/10/2026

Por corrección del usuario, barra/retorno dentro del documento, título/escala
CSS de sader-panel y metadatos con iconos locales. Arial y diseño glass
conservados; posición del retorno sobreescrita localmente sin alterar el
componente. Orbe medium fijo al viewport y scroll propio sin máscara vertical.
Se retira reveal/cover del artículo para seguir referencia estática; no cambian
login/landing, autorización ni contenido legal. Resultados en ESTADO/ficha legal.

## Fuente legal e iconos —18/10/2026

El usuario pide DM Sans exclusivamente para /terms y /privacy, sustituyendo la
indicación anterior de mantener Arial en ese recorrido. WOFF2 variable local,
preload y licencia OFL; no afecta login/landing/moderación ni relaja CSP.
Material Symbols oficiales SVG: chevron_left Rounded para retorno28px y
schedule/campaign Outlined FILL1/óptica20 a16px en metadatos. AppIcon compartido
resuelve usos reales, sin fuente de iconos externa. Glass sigue referencia móvil
con blur22px/transparencia/reflejos. Fuente, licencias y QA en ESTADO/ficha legal.

### Corrección del stagger de acceso —18/10/2026

Por instrucción explícita, el login porta useStaggerReveal de sader-panel a Vue
como composable compartido: transiciones y opciones originales, doble rAF,
will-change persistente y limpieza. Sustituye la aproximación con arrive del
ajuste anterior. Wrapper de entrada independiente del hover del icono.
CSP se conserva: directiva CSSOM, estado inicial SSR mediante clase compartida,
sin style inline en HTML. Movimiento reducido estático, sin alterar autenticación.
Ficha acceso-web y ESTADO registran implementación y validación local.

### Toast del acceso alineado con móvil —18/10/2026

Por solicitud expresa, TopToast compartido adopta la cápsula glass clara e
iconos de ConfirmationToastHost móvil, cierre al tocar sin X y entrada180ms.
Conservar acción de reintento, alert/status, semántica de botón, movimiento
reducido, expiración y limpieza. Detalle en REGLAS_UI_UX_WEB y acceso-web.
