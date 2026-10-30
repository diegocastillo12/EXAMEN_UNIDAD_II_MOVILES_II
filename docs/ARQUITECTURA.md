# Arquitectura de Entre Huellas

30/10: punto3 U2, SecureRouteSurface en composición de Guardados (lease antes
de montar datos, limpieza al salir); acción de borrado de listas inyectada en
Perfil por slot. Fuente serializa persistencia y eliminación de archivos/claves.
Respaldo desactivado en manifest/reglas. [ADR140](decisiones/140-proteccion-y-borrado-local-examen-u2.md).

30/10: lista offline del examen U2 punto2 cifra en Android Keystore por cuenta;
fuente de archivo recibe interfaz SavedListCipher, puente de transporte en app y
adaptador nativo AES-GCM separado. No cambia dominio ni servidor. [ADR139](decisiones/139-cifrado-lista-offline-android-keystore.md).

25/10: HU-25/#71 y HU-26/#72 implementadas localmente en `feature/case-matching`.
Hallazgos independientes aprobados expresamente, sin retirar avisos vinculados
ni reclasificar históricos. Encoder visual CLIP CPU local en Nuxt existente,
índices/revisiones privadas (plan040), ranking exploratorio de hasta cinco casos,
revisión humana y recorridos Android/web. Sin worker, inferencia externa ni FCM.
[ADR-138](decisiones/138-motor-visual-local-y-hallazgos-independientes.md) y
[ficha](funcionalidades/coincidencias-de-casos.md). Activación040/demo alojada,
dataset/evaluación, aceptación e integración pendientes; no se cierra el MVP.

25/10, [ADR-137](decisiones/137-coincidencias-visuales-en-el-mvp.md): HU-25/HU-26,
RF-19/RF-20 se incorporan al MVP por instrucción explícita. Alcance aprobado,
sin motor implementado. Selección de modelo/ejecución y candidatos elegibles
pendiente; no introduce workers de IA ni cambia las fronteras existentes.

24/10, ADR-136: `statistics` en Nuxt separa dominio/casos de uso, DTO/repositorios,
fuentes HTTP/RPC y ViewModel. Inicio compone el acceso por slot; política global
SSR/cliente `administrator` y RPC con permiso `platform_administrators` independiente
de moderación. Plan039 devuelve únicamente conteos por período inclusivo en Lima,
con clasificación cancelado/archivado confirmada por el usuario. Sin lectura
privada adicional de casos, autoasignación ni controles de HU-16.2.
[Contrato, activación y validación](funcionalidades/estadisticas-piloto.md).

24/10, ADR-135: `offline_cases` aporta contrato/casos de uso de consulta y caché,
SQLite privado separado y DTO con lista de campos públicos. ViewModels existentes
consumen el caso de uso; main inyecta y router compone Consultados mediante slot
de Guardados. Fallback solo por indisponibilidad, invalidación por respuesta del
servidor y separación por cuenta; fotos locales sin URLs/permisos/contactos.
[Ficha y validación](funcionalidades/fichas-sin-conexion.md).

23/10, ADR-134: conflictos deterministas de las tres RPC de cola usan PT409
en lugar de40001 para evitar reintentos de serialización de PostgREST. Plan037
actualiza por firma sin alterar ajustes/permisos; adaptadores de perdido y
encontrado aceptan ambos códigos. Sin migración global de SQLSTATE ni nuevas
fronteras.038 completa el helper publish_found_case sin ampliar permisos.
037/038 aplicados por el usuario y6/6 remotas estrictas aprobadas en desarrollo.

23/10, ADR-133: GlassNavigationBar comparte geometría entre los shells de
entidades y ficha pública. Router compone acciones de guardado, seguimiento y
bloqueo por slots del panel Compartir ficha, sin imports de UI/data entre features.
Cada acción conserva su ViewModel y autorización existente; no cambia dominio/SQL.

23/10, ADR-132: `offline_drafts` incorpora cola local esquema2 con dominio/casos
de uso, transporte por las operaciones existentes, CAS y recibos persistentes.
App compone lifecycle y cuenta autorizada para sincronización activa; sin imports
cruzados de data/presentation. [Ficha](funcionalidades/envios-pendientes.md).

23/10, ADR-131: `offline_drafts` conserva formularios Android mediante dominio/casos de uso,
repositorio y Drift/SQLite privado. Los editores convierten su estado dentro de su
presentación y colaboran mediante dominio/providers; bootstrap/main inyectan fuentes.
Comando exacto antes de enviar, contexto/cuenta, lista desde Perfil y exclusión de
backup. El adaptador de onboarding recuerda solo bienvenida confirmada por cuenta
para transporte caído; sesión/autorización remotas conservadas. [Ficha](funcionalidades/borradores-locales.md).

23/10, HU-14.2/RF-23/#44: `user_blocks` concentra elecciones privadas por cuenta,
con dominio/repositorios/casos de uso, ViewModels y fuentes Supabase/HTTP en
móvil/web. Bootstrap/router/páginas componen integraciones mediante slots.
RPC propias y triggers SQL rechazan nuevas contribuciones autenticadas en ambos
sentidos, con lock por pareja y versión esperada; no amplían perfiles públicos.
036 añade ocultamiento de contacto/foto por `case_contact_visible`, compartido
por RPC/Storage, sin cambiar el consentimiento. App compone la invalidación de
contactos tras mutaciones sin imports de presentación entre funcionalidades.
Ruta web registrada globalmente como `account`. Planes034/036 y límites de QR:
[ADR-130](decisiones/130-bloqueos-de-interacciones-entre-cuentas.md).

23/10, HU-14.4: moderation_appeals en Flutter y appeals en Nuxt mantienen
dominio/casos de uso, repositorios, fuentes/DTO y ViewModels por funcionalidad.
Bootstrap/plugins/Nitro componen la inyección. Perfil/Inicio enlazan al usuario;
revisión solo web mediante la política global reviewer. Plan035/fuentes119–121
separa envíos/respuestas append-only y auditoría de lectura; valida autoría o
rol por operación y deduplica comandos sin alterar decisiones ni visibilidad.
[Ficha y límites de validación](funcionalidades/apelaciones-moderacion.md).

Contrato vigente21/10, ADR-128: combinar fullscreen/GSAP Sader con identidad
móvil al abrir y cerrar. La superficie negra y su radio se transforman; icono
y nueve puntos mantienen tamaño, centrados dentro del contorno, con fase fuente
hasta45% invertida al regresar. Fade/blur de Sader solo al cuerpo de destino.
Control original oculto temporalmente para evitar duplicado y restaurado junto
a la limpieza de identidad, estilos y referencias. Se mantienen0.7s/CustomEase,
ruta anterior detrás, marca/barra, acceso/guards y reducido. Perfil/Alertas y
Flutter intactos. [ADR-128](decisiones/128-identidad-mobile-en-origen-web-fullscreen.md).
Los apuntes anteriores que contradigan esa fase se conservan como historial.

Origen web21/10, ADR-125: OriginPageSurface conserva el cuerpo vivo oculto durante
apertura y OriginTransitionHost ejecuta GSAP Flip/CustomEase de PrettyModal de
Sader. Eliminados snapshots/hold/previous/WAAPI de navegación. El controlador
retiene únicamente rect/control y coordina Flip.to antes de desmontar mediante
hook visual compartido (sin política/guard de acceso nuevo). Solo presentación;
estado/casos de uso/permisos intactos. [Decisión y excepción a ADR-124](decisiones/125-origen-web-reemplazado-por-sader-gsap-flip.md).

Movimiento21/10, ADR-124: origin_motion_contract centraliza320/260ms y fases
móviles; origin_dialog_motion reproduce las curvas/progresión de Flutter para
GlassDialog. AccountProfile/NotificationBell entregan el control real sin
infraestructura; el diálogo mantiene contenido hasta finalizar retorno y
cancela WAAPI/estilos/nodos en resize/preferencia/desmontaje. Host de navegación
consume las mismas constantes. Prueba de paridad contra Dart y QA de fotogramas.
[Decisión global](decisiones/124-paridad-animaciones-mobile-web.md).

Cabecera/alertas web21/10: páginas de cuenta componen NotificationBell por slot
de AccountScreen, sin imports de presentación entre funcionalidades. Notifications
separa ReadInbox/MarkNotificationRead/contrato, DTO/repositorios HTTP y servidor,
InboxSource y ViewModel. Plugin inyecta por actor; Nitro revalida cuenta/onboarding
y actor antes de RPC existentes con JWT privado. AccountProfile usa proyección
de sesión existente; ReadAccountAvatar/ServerAccountRepository/AccountSource
protegen proxy privado de foto con ruta del actor y tamaño acotado. Sin foto,
iniciales. GlassSurface/GlassDialog son presentación compartida sin negocio.
Sin rutas nuevas ni cambios de SQL; [ficha](funcionalidades/notificaciones-web.md).

Reportar web21/10, ADR-123: RecoveryViewModel entrega mascotas/búsquedas por
fuente, con readiness/fallo/carga independientes, casos de uso existentes y
descarte de respuestas tardías. RecoveryScreen inicia estas lecturas junto al
borrador y monta el mapa sin esperar; FieldSkeleton limita el placeholder al
selector pendiente. Metadatos de borrador conservados hasta lectura confirmada;
sin caché/SQL/guard adicional. [Decisión](decisiones/123-carga-progresiva-reportar-web.md).

Tema de controles21/10, refinamiento ADR-122: roles CSS locales --sf-* en
fields.css comparten paleta celeste entre campos, selectores, panel y loader.
Sin estado/persistencia de tema, lógica nueva ni dependencias entre features.

Controles web21/10: FieldSelect/TextField/DateField/TimeField/DateTimeField en
app/components y fields.css, adaptados de Sader por petición explícita.
MorphPanel comparte top layer/FLIP y lifecycle con WAAPI, sin infraestructura
ni negocio. TopLoadingBar observa navegación real; excepción local a ADR-027.
[ADR-122](decisiones/122-controles-web-reutilizables-desde-sader.md).

Navegación web20/10, ADR-121: AccountSessionTransport expone su proyección vigente
solo a composición; bootstrap inicializa ViewModel/repositorio ligados al actor
después de hidratar. Sin nueva caché, perfil en SSR ni cambios de política global.
Montajes no emiten avisos de identidad. Preload de código/intención en componentes
compartidos; lecturas independientes en paralelo. [Decisión](decisiones/121-navegacion-web-sin-esperas-repetidas.md).

Hero landing20/10, ADR-120: typography.css excluye #hero-title de Poppins global;
landing.css recupera sus valores y mascotas previos a1fc1bd1. Solo presentación,
sin cambios SEO/dominio/data/permisos. Excepción explícita pedida por el usuario.

Movimiento web20/10, ADR-119: plugin navigation_motion compone estado visual por
aplicación, sin payload SSR. UserNavigation persiste fuera de NuxtPage; AccountScreen
la habilita tras sesión/bienvenida, sin alterar política de acceso. Controlador
origin_transition + OriginTransitionHost/OriginActionButton colaboran mediante
callbacks de presentación y NavigationLink origin; sin negocio, repositorios o
imports entre features. DOM decorativo temporal sin campos/formularios, liberado
al terminar o cambiar identidad. [Ficha](funcionalidades/transiciones-web.md).

Web20/10, ADR-118: páginas componen AccountScreen por slot y RecoveryScreen,
sin imports de presentación entre funcionalidades. UserNavigation compartido
contiene cuatro rutas account de la política global. RecoveryViewModel consume
casos de uso concretos; HTTP/IndexedDB y fuentes RPC/Edge/Storage quedan en data,
compuestas por plugin/utilidades Nitro. Revalidación por operación con JWT privado,
proyecciones explícitas y fotografías en proxy de mismo origen. Sin SQL nuevo.
[Alcance y validación](funcionalidades/navegacion-web.md).

Selector telefónico20/10, ADR-117: InternationalPhoneField en core/presentation se reutiliza en profile y case_contacts. Catálogo country_picker y banderas circle_flags encapsulados en presentación; controller externo conserva número completo, sin cambios de dominio/data/SQL ni imports entre funcionalidades.

Celular20/10, ADR-116: profile transporta contactPhone mediante entidad/DTO, contratos, UpdateProfile y ViewModel. read_case_contact sugiere el valor privado solo al autor mediante su propia proyección; sin imports de otra presentación/data ni publicación automática. Plan033/fuentes112–114 después de032.

Compartir ficha20/10, ADR-115: case_posters añade SharePublicCase/CaseShareRepository/ViewModel y fuentes RPC/plataforma. Reutiliza DTO y generador PDF público; Clipboard se inyecta desde bootstrap como callback, sin Flutter en data. Router compone CaseShareButton por builder y callback de denuncia, sin imports entre presentaciones. RPC prepare_case_share/plan032 autoriza lectores de búsquedas activas, con dueño real, enlace estable y sin reactivar revocaciones.

Refinamiento de presentación20/10, ADR-113: GlassSurface incorpora GlassSurfaceFinish.frosted, reutilizado por CasePublicGlassCard y controles de contacto. El valor polished por defecto mantiene los consumidores anteriores. CasePublicCards separa caption adaptable (nombre/estado en fila y paginación centrada) sin cambiar dominio, datos, mapas o acciones.

Ficha pública20/10, ADR-113/114: CasePublicCards y CasePublicScreenShell componen tarjetas glass y navegación compartida; ImmersivePhotoSheet se conserva en vistas previas. case_contacts separa dominio/casos de uso/repositorio/DTO/fuente/ViewModel; router inyecta su panel por slot y bootstrap/main sus dependencias. Plan031 protege consentimiento y foto por caso; no amplía QR ni perfiles privados.

Diseño conservado20/10, ADR-112: `ImmersivePhotoSheet` sustituye el nombre `CasePublicationPreview`; geometría `ImmersivePhotoSheetGeometry`. Sigue activo sin cambios visuales en perdidos/encontrados. Contrato en [Ficha fotográfica inmersiva](funcionalidades/ficha-fotografica-inmersiva.md). Las referencias anteriores al nombre antiguo son históricas.

Tipografía20/10, ADR-111: AppTypography.primaryTitle en core/theme es el contrato
de títulos principales móvil (Poppins400/32/#454746/1.25/tracking0), consumido por
tema, shells y cabeceras específicas. Nuxt registra typography.css global con
tokens equivalentes y Poppins Regular local idéntico; h1 hereda sin overrides por
recorrido. Marca/cuerpo y fronteras de dominio/data conservados. Prueba de paridad
de tokens/fuente, revisión de layouts normales/ampliados y normas UI compartidas.

Explorar20/10, ADR-106: preview reporta altura real del resumen tras layout;
ExploreCaseMap calcula mínimo adaptable y compone atribución junto al borde
del panel mediante sus controladores. ZoneMapPicker.showAttribution permite
esta composición externa, sin cambio de paleta/global ni operaciones. Créditos
compactos reutilizan componente/lifecycle existentes. Sin dominio/data nuevos.

Cartografía global20/10, ADR-104: MapStyle obligatorio en ZoneMapPicker, sin
override desde Explorar. Web extrae LocationMap de SightingMap a componentes
compartidos; wrapper adapta coordenadas a SightingPoint. CSS/SVG locales solo
filtran teselas, con matriz equivalente probada. Configuración pública de
teselas separada de secretos de backend; CSP restringe host CARTO. Mismos
dominio/casos de uso y coordenadas. Sustituye notas previas de filtro opcional.

Mapa20/10, ADR-103: NavigationAccentSurface se extrae a core/presentation y se
comparte entre navegación y flecha del resumen, sin imports entre features.
ExploreMapPreviewContent compone resumen/acciones/detalles; pantalla conserva
navegación y bloquea aperturas duplicadas. ZoneMapPicker recibe showRadius=false
y attributionTopInset solo para resultados; valores por defecto conservados.
Sin cambios de dominio/data/SQL; rasgos de la proyección pública existente.
Refinamiento20/10: ZoneMapPicker recibe tileColorFilter opcional solo para
teselas. Explorar aplica paleta neutra clara y acerca cámara al seleccionar;
cabecera reutiliza GlassSurface. Otros consumidores conservan sus valores.

Corrección19/10/2026: el fondo móvil conserva las luces del tercio superior y atenúa progresivamente el celeste hasta casi blanco junto a la navegación. El velo se pinta dentro de AppPageBackground antes del contenido; conserva movimiento, glass, viewport y accesibilidad. Véase docs/decisiones/102-fondo-mobile-atenuado-hacia-navegacion.md.

Mapa flotante19/10: router inyecta ExploreMapButton en exploreFloatingAction de
HomeScreen. Home posiciona el slot fuera del scroll solo en Explorar; widget
explore observa su ViewModel y abre ruta existente con OriginPageSource real.
Sin imports de presentación entre features ni nuevos dominio/data. ADR-101.

## Mapa: selección por caso y separación visual de pines —19/10/2026

ExploreCaseMap selecciona por identidad de caso, sin grupo por coordenadas.
ExploreMapPins consume entidades públicas y cámara de flutter_map para colocar
objetivos independientes en píxeles, sin editar datos. ZoneMapPicker compone
markerLayer opcional como slot visual, conservando markers/mapas de edición.
Preview reutiliza especie de ExploreCase y foto4:3; pantalla retira estado/conteo
redundantes. Mismos ViewModels/casos de uso, sin cambios de dominio/data/SQL.
[ADR-099](decisiones/099-mapa-pines-individuales-y-resumen-fotografico.md).

## Explorar: filtro único y resumen inferior —19/10/2026

ExploreSection conserva el editor; ExploreMapScreen observa ExploreViewModel
sin acciones de filtrado ni slot de places. ExploreCaseMap mantiene selección,
cámara y panel visual, renderiza ExploreMapCasePreview con scroll exterior y
Ver ficha. El preview consume el mismo ViewModel/caso de uso de lectura pública.
Paginación/refresh y query siguen compartidos con la lista; sin dominio/data/SQL
nuevos. ADR-097 sustituye el editor inferior y callout de ADR-056/062.

Corrección ADR-095: preserveBackdrop reutiliza fade/desplazamiento de stagger
sin ImageFiltered de entrada. GlassSurface parametriza mezcla del backdrop;
Inicio usa src bajo opacidad, los demás consumidores conservan srcOver.

## Entrada única de secciones móviles —19/10/2026

Inicio y Explorar usan un solo stagger sin cover previo. Home no anima por
segunda vez el contenido de las funcionalidades reales. preserveBackdrop de
StaggerRevealItem revela glass/contenido juntos por recorte y conserva composición
de BackdropFilter. Estado de consultas y ViewModels intactos; ADR-094.

## Lettering móvil de marca —19/10/2026

BrandName de core/presentation renderiza contornos SVG de Arial de la marca web,
sin fuente remota/SDK ni cambios al tema de texto general. BrandWordmark y arranque
lo reutilizan. Recurso estático registrado en pubspec; símbolo oficial conservado.
Generador local sin dependencias runtime nuevas. ADR-092.

## Registro y recuperación web por código —19/10/2026

CredentialScreen → CredentialViewModel → casos de uso concretos de credentials.ts
→ CredentialRepository. Bootstrap inyecta HttpCredentialRepository; Nitro compone
ServerCredentialRepository/CredentialSource/AccountSource por petición. Cifrado
del flujo en infraestructura y cookies/HTTP en utilidades de composición.
Registro confirmado establece sesión general revalidada, con onboarding por cuenta.
Recovery permanece en cookie temporal aislada; política única SSR/cliente protege
restablecer contraseña sin permitir cuenta/moderación. Sin SQL, SDK cliente o
tokens en payload SSR. [ADR-087](decisiones/087-registro-y-recuperacion-web.md).

## Fondo de presentación móvil —19/10/2026

AppPageBackground pinta un fondo blanco con nubes radiales azules animadas a
distintas alturas (ADR-091 sustituye distribución estática de ADR-088). Controlador
local con pausa accesible/TickerMode, repintado aislado y liberación al desmontar.
HomeContent reutiliza GlassSurface en su tarjeta principal, sin nuevo material.
AppScaffold de core/presentation lo compone detrás del Scaffold transparente,
fuera del ajuste de teclado. Pantallas existentes y EntityScreenShell lo reutilizan;
CoverReveal y OriginPageTransition comparten el mismo fondo. No cambia contratos,
dominio, data, providers ni bootstrap; sin dependencia de presentación web. ADR-086.

## Cartografía móvil configurable —19/10/2026

ZoneMapPicker mantiene flutter_map y recibe la URL pública de cartografía desde
MapConfig/MAP_TILE_URL. La configuración local selecciona CARTO Positron raster
light_all; sin define permanece el valor OSM de desarrollo. MapAttribution es
presentación compartida con enlaces/feedback, activada solo para el host CARTO,
sin dependencias de SDK de negocio o cambios de dominio/data. Clave en JSON local
ignorado, sin copia versionada. Pines, coordenadas y contratos conservados; ADR-084.

## Ciclo de vida del cierre web —19/10/2026

Los handlers logout de access/moderation confirman el borrado de cookies sin
esperar la red de Supabase. Componen el caso de uso existente por petición y
registran su promesa con event.waitUntil de Nitro; sin promesa suelta, worker
o caché nueva. Dominio/repositorios/fuentes conservan logout remoto scope local
con timeout5s. El éxito HTTP acredita cierre local, incluso con configuración
remota ausente; no equivale a revocación de JWT ni entrega duradera.
[ADR-082](decisiones/082-cierre-web-sin-esperar-supabase.md).

## Preparación y reutilización breve de sesión —19/10/2026

Landing prepara destino con AccountViewModel/AccessAccount y precarga componentes.
Bootstrap inyecta AccountSessionTransport a repositorios HTTP de la aplicación:
deduplica GET de sesión y reutiliza máximo15s/vencimiento (401 máximo5s), sin
persistir, serializar ni compartir entre peticiones SSR. Data mantiene esta
responsabilidad; ViewModels siguen independientes. Mutaciones, mensajes, foco,
visibilidad y401/409 invalidan; permisos/API no se cachean. Una respuesta anterior
invalidada se descarta y el guard comprueba identidad una vez más. ADR-080 detalla
límites y limpieza; sustituye notas previas sin reutilización de sesión.

## Política global de navegación y acceso —19/10/2026

route_policy.ts registra todas las páginas y comparte clasificación/regla de
etapa entre session-entry (previo al HTML) y access.global (previo al montaje).
Reemplaza account-access/guest-access/moderation-access y sus referencias por
página. ReadManagementAccess valida el permiso de moderación también antes de
renderizar/montar. Landing/QR/legales y fallback conservan acceso público.
pages:extend rechaza rutas/alias sin política y el test arquitectónico contrasta
el inventario de páginas. Puente antiguo conserva destinos internos registrados;
APIs mantienen autorización independiente, sin datos privados SSR ni singleton.
[ADR-079](decisiones/079-politica-global-de-acceso-web.md) sustituye la selección
de guards por ruta descrita en las notas históricas siguientes.

## Redirección del acceso antes de renderizar —19/10/2026

Corrección posterior del mismo19/10: session-entry también intercepta /inicio
y /bienvenida para que una cuenta sin sesión no renderice su shell/skeleton.
account-access comprueba antes del montaje en navegación cliente. Las cuentas
válidas redirigen según onboarding; los errores de backend conservan reintento.
El puente puede usar entry=unavailable para renderizar únicamente el shell de
reintento sin bucles, siempre sin datos privados y sin conceder autorización.

session-entry valida eh_access mediante AccessAccount/Auth/perfil y responde302
a /inicio o /bienvenida antes del HTML de login. Cookie cifrada HttpOnly/path /
sustituye path /api; /api/access/entry recupera sesiones anteriores y termina
el salto anónimo mediante un marcador sin autoridad. guest-access valida antes
de montar en navegación cliente. Sin datos privados SSR ni singleton de cuenta;
cierre limpia ambos paths y las APIs conservan autorización. Fallos de backend
mantienen sesión y reintento en /inicio. [ADR-078](decisiones/078-acceso-web-redireccion-servidor-sin-login-intermedio.md)
sustituye los detalles anteriores de path/comprobación al montar de ADR-073.

## Implementación de marca web común —19/10/2026

SiteBrand/SiteHeader en componentes compartidos, CSS único site-brand.css.
Landing y funcionalidades los componen sin importar UI de otras features.
Fuente/color/medidas explícitas, cabecera fuera de contenido/animaciones,
retorno glass debajo de la marca. Sin cambios de dominio o móvil.
[ADR-077](decisiones/077-marca-web-compartida-referencia-landing.md).


## Marca web en cabecera —19/10/2026

Norma de presentación ADR-076: logo/texto arriba a la izquierda como landing
y onboarding, en todos los recorridos web y responsive, fuera del cuerpo y
sus animaciones/cargas. Reutilizar cabecera/marca; sin cambios de dominio,
permisos o móvil. [Decisión](decisiones/076-posicion-unificada-marca-web.md).


## Entrada web sin cobertura opaca —19/10/2026

StaggerReveal compone el composable compartido, aplica estilos mediante CSSOM
y conserva div/article/section/form originales. Sustituye ocho grupos legados
de inicio/moderación/QR/avistamientos; se elimina .reveal del CSS global.
Solo anima hijos de la entrada, sin replay por edición/refresh. Hoja noscript
externa mantiene QR legible sin JavaScript con CSP vigente.
[ADR-075](decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md).

## Presentación de bienvenida web —19/10/2026

[ADR-074](decisiones/074-onboarding-web-referencia-sader-y-mobile.md) registra
OnboardingFlow como widget de access, separado del inicio de cuenta.
Adapta composición/Inter/botones y salida→entrada de sader-panel con PNG/textos
idénticos a onboarding móvil. Sin .reveal ni cobertura crema; cuatro grupos
del stagger compartido, timers cancelables y movimiento reducido. La confirmación
de guardado precede a la salida final. ViewModel/RPC/sesión/permisos sin cambios.

## Acceso general web e inicio de cuenta —19/10/2026

[ADR-073](decisiones/073-acceso-general-web-y-gestion-por-permisos.md) separa
access de moderation. /iniciar-sesion admite cuentas válidas, /bienvenida aplica
los tres pasos hasta completar la RPC por cuenta y /inicio consulta datos reales
del perfil con JWT/RLS. El permiso de revisión se consulta aparte y se vuelve a
comprobar en cada API de moderación. Sin él, la cuenta conserva uso normal.
Gestión exclusiva web; sin rol administrativo nuevo ni paridad completa todavía.
Sesión general HttpOnly/cifrada/path /api, secreto servidor existente y
vencimiento máximo1h sin refresh token. SSR sin datos privados.
/login, /terms y /privacy redirigen308 a sus equivalentes españoles; callback
OAuth/API/QR conservados. Sin cambios SQL ni Flutter.

## Convención de rutas web —19/10/2026

La navegación visible usa español, minúsculas y guiones, sin tildes ni ñ.
[ADR-072](decisiones/072-rutas-web-en-espanol.md) fija nombres objetivo y
transición compatible: /login→/iniciar-sesion, /terms→/terminos y
/privacy→/privacidad, con redirecciones y parámetros necesarios al migrar.
La raíz / y QR /c/:token se conservan; código, SQL y endpoints internos pueden
seguir en inglés. Callbacks OAuth/deep links no se renombran por esta regla.
Login y legales migrados por ADR-073; las rutas anteriores conservan redirecciones.

## Acceso web separado —18/10

/login separa el formulario de /moderacion. AccessViewModel de presentación
consume AccessModeration; plugin compone repositorio/caso de uso por instancia.
Middleware cliente y pantalla inicial consultan sesión sin exponer cookie ni
serializar datos privados en SSR; permisos por operación en servidor vigentes.
[Ficha de acceso](funcionalidades/acceso-web.md), ADR-071 actualizado.

## Moderación exclusiva de platform — HU-14.3,18/10

Por instrucción expresa, administración solo en apps/platform; sin pantallas,
menús, guards o acciones administrativas Flutter. /moderacion ofrece acceso,
cola, evidencia y decisión real. Dominio/contratos/casos de uso TypeScript,
repositorios HTTP/servidor y DTO separados; ViewModel y componentes compartidos.
Sesión web HttpOnly cifrada, rol comprobado en Auth/RPC por operación, SSR sin
contenido privado y operaciones same-origin. SQL102–105/plan030 conserva
visibilidad separada del ciclo de vida, decisiones append-only/CAS y accesos
auditados; proyecciones públicas/QR/fotos excluyen ocultos.029 confirmado.
[ADR-071](decisiones/071-moderacion-exclusiva-platform.md),
[ficha](funcionalidades/moderacion-web.md).030/configuración/demo pendientes.


HU-14.1/#43 (18/10): content_reports separa dominio/caso de uso/contrato,
DTO/fuente/repositorio, providers declarativos y presentación autoDispose. App
compone accesos desde fichas/revisión mediante slots. SQL099–101/plan029 persiste
denuncias privadas con UUID estable y autorización por recurso; lectura solo
denunciante/revisor asignado en servidor, sin autoasignación ni cambios operativos
automáticos. [ADR-070](decisiones/070-denuncias-privadas-idempotentes.md).028
confirmado aplicado por usuario. Firebase/FCM fuera del alcance.


HU-13 (18/10): case_closure añade dominio/casos de uso/repositorio, DTO/fuente
Supabase, providers declarativos y ViewModel autoDispose. App compone ruta desde
fichas y actualiza consultas; sin imports de presentation/data entre módulos.
SQL096–098/plan028 guarda recibo privado y cierra con historial/contador/outbox
en transacción, RPC autorizadas y UUID estable. QR conserva proyección neutra.
Compatibilidad con resolución anterior sin backfill. [ADR-069](decisiones/069-cierre-recuperacion-auditado.md).
FCM/Firebase siguen pospuestos por ADR-068.

## Alcance activo de alertas — 18/10/2026, ADR-068

Por instrucción del usuario se pospone HU-12.3/#42 y la implementación Firebase.
Cliente sin firebase_core/firebase_messaging, adaptador Firebase ni plugin Google
Services; bootstrap conserva PushRepository no disponible y main no observa push.
La campana abre InboxScreen sin registro de teléfono. HU-12.1/12.2 siguen con
Supabase;027 aplicado se conserva sin reescribir SQL. Contratos genéricos/emisor
preparado quedan inactivos y fuera de entrega; config.toml no declara el emisor.
Las notas de integración FCM inferiores describen el trabajo anterior, sustituido
por [ADR-068](decisiones/068-posponer-fcm-firebase.md). Sin nuevo proveedor o servidor.

## Seguimiento, bandeja y push — 18/10/2026

HU-12.1/#40,12.2/#41,12.3/#42: módulo notifications de apps/mobile con dominio,
casos de uso concretos, providers declarativos, ViewModels/estado/widgets y
fuentes Supabase/Firebase detrás de repositorios. App compone slots de fichas,
zonas y campana; main activa el observador de push con servicios de bootstrap.
Sin imports de presentation/data entre funcionalidades. Login/onboarding
preceden apertura de bandeja desde push; nunca autorización por payload.
Plan027/fuentes091–095: suscripciones CAS/órdenes, notificaciones privadas,
outbox/leases y triggers atómicos. RPC de cliente autenticadas; claim/finish
solo service_role. Edge notification-delivery usa HTTP v1/OAuth y secreto
de planificador, con payload neutro, tag estable, TTL60s y fallos seguros.
Sin Redis, servidor nuevo o cambio en Nuxt. Activación remota, Firebase y cron
pendientes; [ADR-067](decisiones/067-seguimiento-bandeja-y-push.md).

## Cronología y revisión privada — 18/10/2026

HU-11.1/#38 y HU-11.2/#39: `features/case_timeline` contiene dominio/casos de
uso, contrato, providers, ViewModels autoDispose, estado, pantallas, DTO y data.
Bootstrap inyecta Supabase encapsulado; router compone slots en fichas y páginas
de historial/revisión, sin imports de presentation entre funcionalidades.
Plan026/fuentes088–090 añade RPC de autoridad por propietario, lectura paginada,
foto privada y decisiones append-only con actor/motivo/fecha, UUID y CAS.
Orden observado/recepción separado; revisiones no sustituyen evidencia ni cierran
el caso. Lectura permitida tras cierre, nueva revisión solo abierto. No cambia
el QR público ni añade panel web/roles ficticios. [ADR-066](decisiones/066-cronologia-y-revision-privada.md),
[ficha](funcionalidades/cronologia-y-revision.md). Activación026/Android real
pendientes;025 confirmado por el usuario, sin inspección remota independiente.

## Avistamientos Android — 18/10/2026

HU-10.2/#37 incorpora `apps/mobile/lib/features/sightings` con dominio sin SDK,
providers declarativos, ViewModel autoDispose, estado, pantalla y data con DTO.
Bootstrap inyecta HTTP/Supabase Auth, cámara/galería y GPS; router fija caso/origen.
La ruta autenticada Nuxt verifica la sesión con Auth y reutiliza SubmitSighting,
parser multipart, sharp y repositorio servidor. Plan025/fuentes086–087 extrae
persist_sighting para compartir validación, bloqueos, presupuestos y escritura
atómica con web; wrapper web conserva vigencia/revocación QR. Evidencia privada,
reporter_id verificado y reintento ligado a actor, sin QR obligatorio en Android.
Sin lectura anticipada de HU-11 ni cambios en avisos públicos/custodia existentes.
[ADR-065](decisiones/065-avistamientos-android-y-persistencia-compartida.md),
[ficha](funcionalidades/avistamientos-android.md). Activación025/servidor y demo
Android pendientes; no se declara cierre remoto.

## Avistamientos web públicos — 18/10/2026

HU-10.1/#36 en `sightings`: dominio compartido independiente con SubmitSighting/
LocateSighting y contratos, ViewModel con generación de GPS y payload estable,
adaptadores HTTP/navegador y servidor Supabase/sharp separados. Plugins y
server/utils componen dependencias por petición. La página Nuxt enlaza lector
y formulario mediante slot, sin imports de presentation entre funcionalidades.
Plan024 permite únicamente RPC de servidor; tabla/evidencia/punto exacto privados,
confirmación atómica e idempotente, límites persistentes y bloqueos de vigencia.
Bytea de hasta1MiB evita cargas huérfanas en este incremento; coste/escala y
migración futura a Storage explícitos en [ADR-064](decisiones/064-avistamientos-publicos-idempotentes.md).
No implementa revisión HU-11 ni cambia propietario/autorización de found_cases.

Referencia visual web — 18/10/2026: por aprobación explícita del usuario,
[REGLAS_UI_UX_WEB](REGLAS_UI_UX_WEB.md) establece la identidad de landing para
toda apps/platform. [ADR-063](decisiones/063-landing-como-referencia-ui-ux-web.md)
extiende el alcance visual de ADR-060. Compartir componentes al existir uso real,
sin imports de presentation entre funcionalidades ni cambios de dominio/permisos.
La adaptación del QR queda para incrementos de sus recorridos; móvil conserva
su referencia. Este cambio es documental.

Mapa18/10: ReadExploreCasePreview colabora mediante contratos públicos de
lost_cases/found_cases; providers declarativos consumen repositorios ya
inyectados. ViewModel autoDispose por caso observa identidad; widgets consumen
su AsyncValue y no leen SDK/repositorios. Pin SVG en presentación, foto/superficie/
toast/shimmer/fecha reutilizados de core. Sin SQL nuevo. ADR-062.

Vacíos18/10: CollectionEmptyState en core contiene exclusivamente composición
visual (icono, título, descripción, acción opcional). PetsSection y ExploreSection
lo consumen con textos/acciones propios y sus estados confirmados; sin imports
entre presentaciones, consultas ni reglas de producto dentro del componente.

Mapa18/10: extensión42–90% y resistencia visual quedan en ExploreCaseMap;
ExploreMapScreen observa notificaciones de extensión para pintar/ocultar el
retorno compartido. AnimationController/ValueNotifier se liberan con su dueño;
sin cambios de dominio, datos, consulta o permisos.
[ADR-061](decisiones/061-mapa-altura-minima-y-retorno-progresivo.md).

Identidad17/10: diez ilustraciones con estampados blancos generados dentro del
tejido, sin overlays; marca /brand.svg oficial actualizada y fallback PNG.
Recursos Flutter/launchers/splash regenerados desde logo/. Sin cambios de capas,
permisos o soporte funcional de plataformas futuras. Ver ficha identidad-visual.

Recursos de landing17/10: LandingArt consume siete ilustraciones independientes
imagegen, sin atlas del mockup; LandingCharacterCard compone figura/caption/SVG,
CSS dibuja superficies y decoración y LandingBrand usa /brand.png oficial.
No hay cambios de dominio/datos, stack, permisos ni SSR. Se conserva la animación
principal aprobada. Corrección documentada en ADR-060 y ficha de landing.

Landing17/10/2026: / compone LandingPage Vue en apps/platform; HTML SSR sin
consultas de producto ni estado de usuario. app/features/landing separa pantalla,
widgets y estilos de presentación reales; no añade dominio/repositorio vacíos.
CSS .landing-page y lector .reader-shell aíslan ambas composiciones. Raíz indexable
y QR/API noindex; nonce CSP conservado. [ADR-060](decisiones/060-landing-integrada-en-platform-vue.md).

Web17/10/2026: decisión vigente Vue3/Nuxt4/TypeScript en apps/platform,
una sola aplicación por módulos y permisos. Este incremento migra QR a SSR+Vue;
landing de su rama, login web y administración aún por integrar/implementar.
shared/features contiene dominio/casos de uso, data HTTP y ViewModel puros;
app contiene componentes/páginas y composición por petición; server encapsula
REST/DTO Supabase, transporte y seguridad. Nitro sustituye el HTTP manual,
sin cambiar SQL/URLs/variables del usuario. [ADR-058](decisiones/058-web-unica-vue-nuxt-y-roles.md)
sustituye la implementación de la siguiente nota histórica.

Web QR16 de octubre: apps/platform separa dominio/casos de uso/contrato,
data REST/mapeo, presentación DOM/ViewModel y bootstrap HTTP Node22. Solo el
servidor consume RPC080 con secreto; cliente recibe proyección pública y fotos
por índice revalidadas. SQL080–082/plan023 sin permisos anónimos nuevos.
Supabase conserva reglas y persistencia. [ADR-057](decisiones/057-ficha-qr-web-y-proxy-privado.md).

Revisión del mapa,16 octubre: ExploreFilterEditor/ExploreFilterSelection compartidos por lista y panel del mapa; presentation mantiene borrador, metadatos de lugar y acción GPS sin consulta automática. ExploreMapScreen consume applySelection/locateForFilter del ViewModel, que invoca casos de uso existentes y protege identidad/generación. ExploreCaseMap solo coordina cámara/pins/etiqueta y panel; ZoneMapPicker admite controlador visual externo sin conocer features o repositorios. Router compone places mediante slot también en mapa. Sin cambios de dominio/datos/SQL; [ADR-056](decisiones/056-mapa-filtros-inferiores-y-acceso-en-pin.md) sustituye el contenido inferior de ADR-055.

Mapa inmersivo,16 octubre: ExploreMapScreen comparte ExploreViewModel/consulta/páginas con la lista; router protege `/home/explore-map` y compone entityEditorPage/OriginPageSource desde la opción Mapa. La vista deja de ser estado del ViewModel (`mapSelected` retirado). ExploreCaseMap conserva agrupación pública, pero usa panel deslizable de una ficha y grilla compartida de una columna. No cambian dominio/datos/SQL ni se importan pantallas desde providers. [ADR-055](decisiones/055-explorar-mapa-inmersivo-y-panel-deslizable.md) sustituye la composición integrada de ADR-052.

Carteles16 de octubre: case_posters separa entidades/contrato/casos de uso, DTO/Supabase, plantilla binaria PDF y exportación nativa, estado/ViewModel/pantalla y providers declarativos. Bootstrap/main inyectan las implementaciones; router compone accesos por slots en fichas propias. SQL077–079/plan022 protege enlaces opacos estables y proyección imprimible; sin nuevo permiso anónimo. PUBLIC_CASE_WEB_READY evita generar un QR sin ficha web habilitada. [ADR-053](decisiones/053-carteles-pdf-y-enlaces-qr.md).

Mapa de Explorar16 de octubre: HU-07.2 comparte ExploreState/SearchCases/RPC019 con la lista, sin capas o SQL nuevos. Vista elegida en ViewModel; ExploreCaseMap dibuja proyecciones públicas y agrupa coincidencias de coordenadas solo para selección visual. ZoneMapPicker recibe marcadores y navegación de solo lectura opcionales, sin habilitar edición del centro. Tarjetas y apertura de fichas comparten implementación. [ADR-052](decisiones/052-explorar-mapa-de-resultados.md).

Reutilización16 octubre: places extrae de explore el buscador público (dominio/fallos/data/providers/ViewModel/widget), con modos ciudad/dirección y caché/estado separados. Router lo compone por slots en Explore/Profile, sin dependencia entre presentaciones; GPS consume solo entidad de dominio. PublicCaseCard/Kind/Status, DTO y grilla se comparten en core, con alias de Explore. saved_cases agrega ListSavedCases/ViewModel/lista y RPC021 paginada por cuenta, sin radio. UpdateProfile recibe citySelected explícito para rechazar texto nuevo sin selección. [ADR-051](decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

Casos guardados (16 octubre): saved_cases separa referencia/contrato/casos de uso, DTO/fuente Supabase/repositorios y estado/ViewModel/botón. Providers declarativos e inyección bootstrap/main. Router compone botón en slots de fichas; core solo expone trailingAction, sin imports entre presentaciones. RPC020/RLS privadas, CAS/reintentos; no cambia visibilidad ni implica seguimiento/offline. [ADR-050](decisiones/050-casos-guardados-por-cuenta.md).

Actualización por gesto: PullToRefresh/PullToRefreshTarget en core comparten solo callbacks de presentación. HomeScreen posee el scroll y cada funcionalidad registra su operación de ViewModel, sin imports entre presentaciones ni core→features. Ubicaciones utiliza callback directo en su scroll. No cambian casos de uso/repositorios/SQL; [ADR-048](decisiones/048-actualizar-listas-al-jalar.md).

Actualización de Explorar,15 de octubre: CurrentLocationRepository/GetCurrentExploreLocation en dominio, DeviceLocationSource (geolocator14.0.2) y repositorio en data, inyección bootstrap/main y coordinación en ExploreViewModel. Primera consulta solo con ubicación/radio15km; fallo de ubicación deja selección manual. SDK protegido por comprobación de fronteras. Sin SQL nuevo, stream de ubicación ni persistencia del dispositivo. [ADR-047](decisiones/047-ubicacion-actual-y-radio-inicial.md). No se han ejecutado pruebas nativas por instrucción del usuario.

**Regla vigente — 11 de octubre de 2026:** feedback de errores, validación y resultados en el toast superior compartido en todas las funcionalidades. Sin texto bajo inputs, errorText/helperText ni indicadores circulares/lineales. Skeleton y LoadingShimmer para carga inicial/acciones; ContentRefresh con shimmer conserva contenido durante refresh. Se mantienen invalid/ShakeField, semántica, reintentos, etiquetas/datos e instrucciones de privacidad. [ADR-027](decisiones/027-feedback-global-toast-shimmer.md) sustituye las restricciones anteriores de feedback; las notas fechadas anteriores son historia de las decisiones.

El comportamiento de cada módulo, sus recorridos y límites actuales se documentan
en [Funcionalidades](funcionalidades/README.md). Esta arquitectura describe su
organización; ESTADO conserva la evidencia de validación y las decisiones van en ADR.

Norma obligatoria: [REGLAS_ARQUITECTURA.md](REGLAS_ARQUITECTURA.md). Define patrones, responsabilidades, dependencias, SOLID y criterios de revisión. Este documento conserva la descripción y las decisiones concretas de implementación.

Norma visual obligatoria: [REGLAS_UI_UX.md](REGLAS_UI_UX.md), basada en las pantallas de acceso aprobadas. AppPageLayout y primaryActionButtonStyle se comparten en core; los nombres de Auth delegan en ellos y mantienen compatibilidad. Inicio reutiliza core sin importar presentación de Auth. Su UI anterior queda retirada; sesión y casos de uso se conservan.

La aplicación utiliza **Clean Architecture por funcionalidad**, MVVM, Riverpod y Supabase. La elección responde a la necesidad de separar las reglas de recuperación, el estado de las pantallas y la coordinación de fuentes remotas/locales. La justificación, las alternativas y los costos están registrados en [ADR-001: arquitectura de la aplicación](decisiones/001-arquitectura-aplicacion.md).

La decisión del 4 de octubre de 2026 estableció Flutter + Supabase como base técnica y pospuso una API ASP.NET Core. La organización de capas y contratos quedó definida el 7 de octubre de 2026.

## Organización

La presentación inicial usa StartupReveal compartido desde el builder de MaterialApp.router. Monta el Router visual después de la secuencia de marca; las suscripciones y reglas de sesión siguen en sus ViewModels/casos de uso. No altera destinos ni concede acceso durante el arranque. Recursos Android versionados armonizan splash nativo y Flutter; texto animado pertenece a Flutter, no al SDK de autenticación.

Una sola base de código versionada, con carpetas simples. No se requiere una herramienta de monorepo.

```text
entreHuellas/
  AGENTS.md
  README.md
  docs/
  .github/
  apps/
    mobile/                 # App Flutter existente; Android primero
    platform/               # Plataforma web Vue/Nuxt; QR y futuros módulos
  database/                 # Fuentes SQL numeradas por tipo de objeto
    tables/
    functions/
    policies/
    grants/
    tests/                  # Pruebas SQL; resto del árbol en database/README.md
  supabase/
    migrations/             # Paquetes de cambios generados desde database
    functions/              # Integraciones y operaciones server-side necesarias
```

Por decisión del usuario del17 de octubre de2026, Flutter se ubica en
`apps/mobile` y la web Vue/Nuxt en `apps/platform`, sustituyendo la conservación
de Flutter en la raíz acordada el6 de octubre. Los proyectos se trasladan sin
recrearlos ni cambiar sus identidades. Véase [ADR-059](decisiones/059-directorios-apps-platform-mobile.md).

`database` guarda las fuentes SQL en carpetas por objeto, con secuencia global `001_...sql`. Las migraciones agrupan cambios en orden de dependencia; sus fuentes y su historial no se modifican después de aplicarlos. La estructura inicial y la separación entre SQL y Edge Functions se describen en [database/README.md](../database/README.md) y [ADR-002](decisiones/002-organizacion-database.md). El incremento de perfiles 001–007 y el generador PowerShell están preparados. La migración y sus pruebas de permisos deben ejecutarse en Supabase de desarrollo; no se han desplegado.

En `apps/mobile/lib`:

```text
app/                        # App, router y bootstrap de implementaciones
core/                       # Configuración, errores, base local y tema
features/
  auth/
    presentation/
      screens/              # AccessScreen: renderiza el estado del ViewModel
      view_models/          # AuthViewModel y LoginViewModel: sesión y acciones
      state/                # AuthViewState y LoginViewState: estado de presentación
      widgets/              # Formulario de credenciales, botones sociales y marca
    domain/
      entities/             # AuthSession, identidad sin tokens
      repositories/         # Contratos AuthRepository y AccessRepository
      use_cases/            # WatchAuthSession, SignIn y SignOut
      failures/             # AuthFailure, independiente del SDK
    data/
      data_sources/         # Contrato remoto y adaptador de Supabase Auth
      models/               # AuthSessionDto: proyección externa sin tokens
      repositories/         # AuthRepositoryImpl y UnavailableAuthRepository
    providers/              # Declaraciones DI basadas solo en contratos
  home/
    presentation/screens/   # Base autenticada; acciones mediante ViewModels
  onboarding/              # presentation/domain/data/providers; entrada y tres etapas
  pets/
  cases/
  sightings/
  map/
  notifications/
  moderation/
```

`presentation` contiene pantallas, ViewModels y estado; `domain/entities` contiene los conceptos del producto, `domain/repositories` sus contratos de acceso a datos y `domain/use_cases` las operaciones que consume el ViewModel. `data` implementa los contratos y transforma tipos externos en entidades. El dominio depende solo de Dart y otros componentes de dominio, sin Flutter, Riverpod ni SDKs. Esta estructura se mantiene durante la entrega del MVP y en los incrementos posteriores.

Un caso de uso recibe los contratos que necesita por constructor, expresa una operación y contiene sus reglas. La presentación decide cómo mostrar carga/error/datos; no decide permisos ni transiciones críticas. Al incorporar nuevas operaciones se implementan sus casos de uso y pruebas. En `data`, el adaptador consulta el SDK y proyecta DTO sin tokens, y el repositorio los convierte en entidades; esta frontera permite sustituir el adaptador y comprobar el repositorio sin Supabase. Un DTO representa el formato/proyección de una fuente, una entidad representa un concepto del producto. No crear carpetas vacías, clases base genéricas ni duplicar todos los objetos por defecto. Las funcionalidades futuras del árbol se incorporan al implementar su sprint.

Ejemplo implementado: `WatchAuthSession` observa la identidad y elimina eventos consecutivos equivalentes, incluyendo renovación de tokens para el mismo usuario. Conserva cambio de usuario, cierre y nuevo acceso. Tras un error acepta el siguiente valor aunque coincida con el anterior, para recuperar la UI; cada suscripción tiene su propio historial y transmite cancelación/pausa/reanudación al origen. `AuthSession` es inmutable y compara por `userId`; no representa el perfil ni las credenciales. Los fallos de observación se propagan como error, sin convertirlos en cierre de sesión.

`app/bootstrap.dart` y `main.dart` componen la app: validan configuración, inicializan Supabase una vez, construyen adaptador/repositorio e inyectan los contratos con overrides de Riverpod. `features/auth/providers` declara el repositorio y el caso de uso sin importar implementaciones; requiere que se inyecte el repositorio al arrancar. El arranque no configurado inyecta explícitamente `UnavailableAuthRepository` y `UnavailableAccessRepository`. `core/config/startup_state_provider.dart` expone el estado de arranque. Los providers pueden sustituirse en pruebas sin un servidor real. Presentación ya no depende del módulo de composición `app`.

## Presentation y data: reglas concretas

La norma de transiciones/carga está en [ADR-006](decisiones/006-transiciones-y-carga-con-shimmer.md). LoadingShimmer usa un CustomPainter con controlador local a presentación: mantiene la etiqueta y el tamaño del botón, anuncia progreso real por semántica, bloquea interacción y detiene/libera el ticker al finalizar/desmontar. Sin dependencias nuevas ni estados SDK en UI; movimiento reducido mantiene un brillo estático. El estado de registro/recuperación distingue verificación de OTP para iluminar únicamente el control correspondiente. Nuevas claves de etapa para éxito/error activan cover → stagger sin cambiar reglas de Auth ni repetir efectos en la misma etapa.

### Recuperación de contraseña (HU-01 / RF-01,34)

PasswordRecoveryRepository declara solicitud, verificación de código, actualización, fin del flujo y observación de RecoveryAccess. RequestPasswordRecovery valida/normaliza correo; VerifyRecoveryCode valida seis dígitos y delega verificación con OtpType.recovery; ResetPassword valida longitud y confirmación sin recortar la contraseña. WatchRecoveryAccess y EndPasswordRecovery expresan observación/cierre. PasswordRecoveryRepositoryImpl transforma DTO y fallos; SupabasePasswordRecoveryDataSource encapsula resetPasswordForEmail, verifyOTP, updateUser, signOut y eventos del SDK. Bootstrap inyecta la implementación y su alternativa no configurada, sin nuevos objetos SQL.

RecoveryAccessViewModel observa el propósito de recuperación separado de AuthSession (que sigue siendo identidad). El router prioriza ready/invalid sobre el destino de onboarding; el evento passwordRecovery del SDK habilita el cambio y se conserva durante tokenRefreshed/userUpdated. signedOut, signedIn o cambio de cuenta lo limpian. El adaptador rechaza actualización sin contexto de recuperación para el mismo usuario; Auth verifica sesión y política en el servidor. La escucha se cancela con autoDispose; se desactiva el reintento automático de Riverpod para mantener errores y aceptar el siguiente evento. Los fallos de observación de login/OAuth normales permanecen en el flujo de Auth.

PasswordRecoveryViewModel coordina petición, verificación, reenvío con espera, validación/fallos y actualización. Libera temporizador al desmontar/entrar al reset/cerrar; descarta respuestas tardías de solicitud/verificación cuando cambia el contexto. PasswordRecoveryScreen y ResetPasswordScreen reutilizan AuthPageLayout, StaggerReveal, decoración, ShakeField y estilos de botón; EmailCodeConfirmation comparte la ilustración y layout con registro. EmailCodeInput usa una sola entrada real para pegado/autofill/retroceso y seis casillas visuales excluidas de semántica. Los widgets consumen estado/acciones del ViewModel. El resultado confirmado se muestra antes de cerrar sesión local y volver al login; un fallo de cierre permite reintentar.

El propósito de recuperación vive en la instancia de la fuente de datos y el evento del SDK, sin preferencias globales por instalación. La app avanza a reset solo tras recibir sesión válida al verificar OTP: se puede leer el correo en una PC y escribir el código en el móvil, sin compartir el verificador PKCE de la solicitud. Los callbacks existentes siguen siendo compatibles. Si se reinicia después de consumir el código y antes de actualizar contraseña, solicitar uno nuevo. No se cambia el modelo de sesión ni se afirma que los renders prueben correo remoto.

Para registro, RegistrationRepository/DataSource añaden verifyCode y VerifyRegistrationCode valida seis dígitos antes de red. SupabaseRegistrationDataSource usa OtpType.email, sin el tipo signup obsoleto para verificación. Reenvío continúa con resend(type: signup), que es una operación distinta. RegistrationViewModel conserva correo y error contextual si el código falla; solo sesión válida permite el acceso. Ningún OTP se genera, guarda o compara localmente como autorización. El servidor controla caducidad, uso y límites. Fuentes de plantillas con Token en supabase/auth/templates, independientes de SQL.

La transición visual entre etapas pertenece a AuthStageTransition/CoverReveal en core/presentation/widgets, sin cambiar ViewModels ni reglas de Auth. AuthPageLayout permite envolver únicamente título/contenido, conservando la marca fuera de los efectos. CoverReveal usa un clip vertical de una cortina blanca plana; no depende de OriginPageTransition ni captura geometría de botones. Una clave de etapa conserva el contenido anterior durante 320 ms y bloquea interacción/semántica; al completar activa el StaggerReveal del nuevo contenido mediante play. Errores/contador/reenvío mantienen la clave/timeline y no repiten los efectos; controladores se liberan al desmontar y respetan disableAnimations.

PasswordRecoveryScreen comparte solicitud, OTP y reset bajo la misma cabecera; ResetPasswordScreen delega la entrada de callbacks externos con resetMode. El router mantiene la página de recuperación visible al llegar RecoveryAccess.ready/invalid y sigue redirigiendo intentos de salir hacia destinos autenticados al reset. Al refrescar una página añadida con push, GoRouter puede reconstruir el URI del login de base: se comprueban la restauración, el URI de base y el último match visible para conservar la cabecera, sin autorizar una navegación nueva a Inicio. Los tests verifican identidad de render del logo y secuencia cover → stagger, junto a las restricciones de navegación existentes.

El tema, los componentes visuales compartidos y la composición de las pantallas se describen en [DISENO_UI.md](DISENO_UI.md). Los cambios de estilo conservan el mismo recorrido de casos de uso y estado; no añaden dependencias de infraestructura a los widgets.

- **MVVM y flujo de datos en una dirección:** `AccessScreen` observa un único `AuthViewState` de `AuthViewModel`. El ViewModel combina arranque y sesión. Las futuras acciones de producto se invocan en el ViewModel mediante casos de uso; navegación simple, estilos y visibilidad corresponden a la pantalla.
- **Estado inmutable:** `AuthViewState` contiene `StartupState` y `AsyncValue<AuthSession?>`. AsyncValue ya representa carga/dato/error; no se introduce otra máquina de estados equivalente. Los mensajes de pantalla pertenecen a presentación. Home, sin reglas ni datos, puede ser un widget simple sin un ViewModel vacío.
- **Ciclo de vida:** ViewModel y stream de sesión usan `autoDispose`. Al dejar de observar la pantalla se liberan sus suscripciones. El stream de sesión no reintenta automáticamente ante errores; puede recuperarse con un evento posterior de la misma fuente. Los reintentos futuros de operaciones se diseñarán según idempotencia.
- **Repository y Adapter:** `SupabaseAuthDataSource` es el adaptador del SDK. `AuthRemoteDataSource` permite sustituir esa fuente. `AuthRepositoryImpl` conoce ese contrato, mapea DTO a entidades y transforma errores síncronos o de stream en `AuthFailure`. No captura secretos en el fallo de dominio; el error no se transforma en sesión nula. El stream puede continuar tras un error.
- **Widgets pequeños y acceso adaptable:** `LoginCredentialsForm`, `SocialSignInButton` y `BrandWordmark` componen el acceso sin obtener datos de infraestructura. La pantalla observa los ViewModels para carga/sesión/error y permite scroll en superficies pequeñas con texto ampliado. Los componentes compartidos se extraen cuando tengan uso real.
- **Pruebas de fronteras:** `test/architecture_test.dart` revisa directivas import/export/part, incluidas alternativas condicionales: dominio sin paquetes/plataformas; presentación sin data, app, repositorios directos ni SDKs; data sin presentación/providers/app; providers sin implementaciones. Los SDKs de datos se permiten en `data_sources` y bootstrap. Esta comprobación de directivas complementa análisis y revisión; no es un análisis completo de todos los símbolos.

Se adopta esta organización como convención del proyecto, no como una estructura universal obligatoria en Flutter. Los patrones usados son MVVM, Repository, Adapter, inyección por constructor/providers y estado inmutable. [Las recomendaciones oficiales](https://docs.flutter.dev/app-architecture/recommendations) respaldan separar vistas/ViewModels, repositorios/servicios, inyectar dependencias y probarlos por separado. No se añadió un contenedor DI adicional, herencia base ni generadores para esta sesión sencilla.

`go_router` gestiona `/` (preparación), `/access`, `/onboarding` y `/home`; las rutas se protegen según sesión y finalización. Una ruta desconocida lleva al destino autorizado. El deep link `entrehuellas://login-callback/` pertenece a Supabase/app_links; el manejador nativo de Flutter está desactivado para evitar que el router procese el mismo callback. El SDK usa PKCE y el repositorio transforma sus eventos en identidad de sesión sin exponer tokens. El estado `ready` confirma inicialización local, no conectividad ni validez remota de la clave. La allowlist remota y las pruebas reales se documentan en [CONFIGURACION.md](CONFIGURACION.md).

## Responsabilidades

| Pieza | Uso |
| --- | --- |
| Flutter / MVVM | UI y acciones del usuario separadas del estado de la pantalla. |
| Riverpod | Estado e inyección; Notifier/AsyncNotifier según el flujo. |
| Entidades | Conceptos del producto independientes del formato de persistencia. |
| Casos de uso | Operaciones del producto y sus reglas, usando contratos de repositorios. |
| Repositorios | Contratos en dominio; implementaciones en data coordinan acceso remoto/local y mapeo. |
| Supabase Auth | Cuenta y sesión. |
| PostgreSQL + PostGIS | Persistencia e invariantes; consultas geográficas en servidor. |
| Storage | Medios privados y derivados públicos controlados. |
| Funciones PostgreSQL / RPC | Operaciones atómicas con comprobaciones de actor y transiciones. |
| Edge Functions | Integraciones, secretos y endpoints públicos controlados. |
| SQLite / Drift | Borradores, caché y cola local de envíos. |
| FCM | Push; la bandeja de notificaciones es persistente. |

Flujo habitual: pantalla -> ViewModel -> caso de uso -> contrato de repositorio -> implementación -> fuente de datos -> SDK/backend. Los DTO se transforman en entidades antes de devolverlos al dominio. Las implementaciones dependen del dominio; el dominio no conoce su backend. Una validación cliente ayuda a la experiencia, pero permisos e invariantes deben seguir validados en servidor.

Esta elección concreta adapta los principios de [la guía oficial de arquitectura Flutter](https://docs.flutter.dev/app-architecture/guide): separación de responsabilidades, inyección y capa de dominio. Flutter no impone una única estructura de carpetas; este proyecto adopta los casos de uso como punto de entrada a las operaciones de dominio.

## Reglas del servidor

- Grants y RLS delimitan las operaciones y filas accesibles para visitantes, usuarios y moderadores. Storage también tiene políticas.
- La ficha pública tiene un contrato propio; no se devuelve la tabla privada completa. Las vistas se revisan para que no eludan políticas.
- Una restricción impide dos casos perdidos activos de una mascota. Cambios de estado y auditoría se realizan en una operación autorizada.
- Las funciones RPC que cambian estados verifican permisos y transición. Los privilegios de ejecución y cualquier uso de SECURITY DEFINER se revisan explícitamente.
- Casos y avistamientos usan claves de envío estables y deduplicación del servidor. Un reintento con datos incompatibles debe producir conflicto.
- `observed_at` describe el evento, `created_at` su recepción. Fechas almacenadas en UTC; UI en America/Lima.
- El QR contiene un token opaco revocable. El formulario de visitante valida límites y abuso en servidor.
- Validar fotografías en servidor, eliminar EXIF y controlar qué bytes son públicos. Elegir en S2 una solución compatible con los límites del runtime; procesos pesados necesitan otro mecanismo.
- Las alertas tienen registro persistente y estado de entrega/reintento. Ejecutar una Edge Function una vez no garantiza entrega.
- Las credenciales privilegiadas permanecen fuera de Flutter y la web pública.

## Evolución

Chat, adopciones, refugios, servicios e IA quedan después del MVP. Supabase Realtime puede evaluarse cuando exista un flujo que lo necesite. Una API propia se reconsidera por necesidades medidas, sin rehacer las pantallas si los repositorios conservan sus contratos.

## Referencias

- [Separación de vistas, ViewModels y datos en Flutter](https://docs.flutter.dev/app-architecture/guide).
- [Providers de Riverpod](https://riverpod.dev/docs/concepts2/providers).
- [Autorización con RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).
- [Funciones PostgreSQL llamadas por RPC](https://supabase.com/docs/guides/database/functions).
- [Edge Functions e integraciones](https://supabase.com/docs/guides/functions).
- [Control de acceso de Storage](https://supabase.com/docs/guides/storage/security/access-control).

## Ingreso y sesión

`RegisterScreen` observa `RegistrationViewModel`, que consume `RegisterAccount` y `ResendRegistrationConfirmation`. El dominio valida nombre/correo, longitud mínima y coincidencia de contraseñas sin depender del SDK ni alterar los espacios de contraseña. `RegistrationRepository` es un contrato específico; su implementación mapea `RegistrationResultDto` a `RegistrationOutcome`, diferenciando confirmación pendiente de sesión autenticada. `SupabaseRegistrationDataSource` encapsula signup/resend, metadata y callback. Bootstrap/main inyectan este contrato también en arranque no configurado.

La ruta pública `/register` se permite solo cuando el destino autorizado es login. Una sesión nueva sigue pasando por `EntryViewModel`; la respuesta del formulario no autoriza saltar onboarding. Errores tipados se presentan por campo, con decoración compartida entre login/registro y ShakeField; los fallos de servicio usan texto breve contextual, sin mensajes del SDK. La confirmación permanece dentro de la pantalla de registro y usa enlace, no una simulación OTP. El ViewModel conserva solo email de confirmación/estado, no contraseñas; bloquea duplicados y libera el contador de reenvío con autoDispose.

`LoginViewModel` consume `SignIn` y `SignOut`, bloquea envíos duplicados y publica carga/mensajes seguros. `SignIn` valida correo y presencia de contraseña sin alterar sus espacios. `AccessRepositoryImpl` transforma fallos de `AuthAccessDataSource` a fallos de dominio; `SupabaseAuthDataSource` encapsula ingreso por contraseña, OAuth y salida local. Bootstrap inyecta el repositorio de comandos junto con el repositorio de observación de sesión.

Abrir Google no equivale a estar autenticado. El SDK inicia OAuth con PKCE y el callback móvil; `AuthViewModel` confirma la identidad mediante eventos de sesión. El formulario no guarda contraseñas en providers ni muestra errores internos del SDK. La opción Apple está retirada de esta interfaz por instrucción del usuario; registro por correo está implementado; recuperar contraseña y editar perfil siguen pendientes de HU-01.

### Entrada SQL y nombres

`database/run_all.sql` se genera desde las fuentes del incremento de perfiles para ejecución manual repetible; conserva la migración anterior y evita duplicados. Su generación y límites se registran en [ADR-003](decisiones/003-ejecucion-sql-idempotente.md). El SQL usa identificadores en inglés con `snake_case`; los DTO los mapean a propiedades Dart en `camelCase`. El procedimiento y las pruebas están en [database/README.md](../database/README.md).

### Flujo de entrada y onboarding por cuenta

`EntryViewModel` combina la sesión observada con `CheckOnboarding`. El router escucha su estado para proteger `/home` y `/onboarding`: sin sesión muestra `/access`, con onboarding pendiente muestra `/onboarding`, y con finalización persistida muestra `/home`. La consulta fallida no autoriza omitir el flujo. No se reconstruye el router en cada cambio de sesión.

`OnboardingViewModel` coordina páginas y consume `CompleteOnboarding`; data consulta el perfil y llama a la RPC protegida mediante una fuente Supabase. Bootstrap inyecta el contrato. `BrandWordmark` pasó a core porque lo comparten login y onboarding. La persistencia y los criterios de reentrada se registran en [ADR-004](decisiones/004-onboarding-por-cuenta.md).

Los errores de ingreso se mapean a LoginFieldIssue en LoginViewModel. LoginCredentialsForm consume el estado y delega edición/reintento; ShakeField es un componente visual compartido, sin reglas de autenticación. Se mantiene emailNotConfirmed separado del rechazo genérico en las fronteras de data y dominio.

La UI utiliza feedback contextual y prohíbe SnackBar por [ADR-005](decisiones/005-feedback-sin-snackbar.md). La comprobación en architecture_test.dart protege esta regla junto con los límites de capas.

RegisterScreen compone una única StaggerReveal compartida entre cabecera y RegistrationForm. Cada componente usa StaggerRevealItem con su orden de entrada; el timeline se conserva durante reconstrucciones del ViewModel y respeta movimiento reducido. La animación reside en presentación y no altera casos de uso, estado de autenticación ni persistencia.

AccessScreen y RegisterScreen reutilizan AuthPageLayout para conservar dimensiones y anclaje de marca/título, sin centrar cada formulario por su propia altura. La X de cierre del registro no reserva un AppBar. El router compone OriginPageTransition con el rectángulo visual del control de entrada. Registro retorna mediante pop para completar la animación inversa y conservar el login anterior; solo usa go sin historial. La transición se desactiva con movimiento reducido y no participa de autorización ni lógica de cuenta.

## Perfil de cuenta — HU-01.7 / RF-01

Perfil se implementa en `features/profile`: entidades/fallos/repositorio y ReadProfile/UpdateProfile en dominio; DTO, fuente Supabase y repositorio en data; AsyncNotifier autoDispose, estado y formulario en presentación. Providers declaran contratos/casos de uso y observación de identidad mediante WatchAuthSession. Bootstrap inyecta el repositorio; router compone ProfileEditor dentro del shell Home mediante un parámetro Widget, sin importaciones entre las presentaciones de ambas funcionalidades.

La lectura selecciona únicamente id/display_name/city de la cuenta activa. La escritura reemplaza solamente display_name/city y obtiene la fila confirmada; nunca envía identidad, rol, timestamps u onboarding. Campos opcionales, vacíos normalizados a null, longitud máxima 120 puntos de código acorde a PostgreSQL. La fuente comprueba identidad antes/después de cada respuesta; ViewModel descarta resultados tardíos por generación al cambiar de cuenta y no escribe tras desmontaje. Fallos de fuente se normalizan y el editor conserva cambios durante error/reintento. Lectura fallida permite retry explícito, sin reintentos automáticos ocultos.

El esquema 001–009 ya contempla este contrato: no se modifica SQL aplicado ni se genera una migración sin cambio de esquema. Tests 001 y 003 verifican políticas/grants y edición en PostgreSQL local; ejecución con dos cuentas autenticadas en Supabase sigue siendo verificación separada.

## Perfil como ruta desde avatar

ProfileAvatarButton se compone desde app/router en el parámetro profileAvatar de Home, sin imports de presentación entre funcionalidades. HomeViewModel solo controla tres destinos; la salida de cuenta pasa a ProfileExitViewModel autoDispose y mantiene SignOut de dominio. /home/profile está anidada en /home y protegida por EntryDestination; la ruta superpuesta conserva estado de Inicio al regresar.

ProfileAvatar observa ProfileViewModel, también utilizado por editor: la suscripción de cabecera mantiene perfil vigente mientras vive Home; los resultados de identidad/carga/error no muestran datos de otra cuenta. SupabaseProfileDataSource agrega solamente la URL HTTPS de avatar_url/picture de metadatos propios al DTO; repositorio mapea avatarUri a entidad. Los metadatos no autorizan operaciones ni se exponen íntegros. Escritura de nombre/ciudad y grants/RLS conservan su contrato. No se añade esquema/Storage para carga de fotos en este ajuste.

## Foto de cuenta y correo

ProfilePhotoRepository/ChangeProfilePhoto declaran selección, recuperación y subida concreta. GalleryProfilePhotoSource encapsula image_picker, procesamiento image y marcador de propietario shared_preferences; ProfilePhotoRepositoryImpl normaliza fallos. SupabaseProfileDataSource proyecta email desde Auth y usa Storage privado con ruta estable/URL firmada. ProfilePhotoViewModel autoDispose controla carga/reintento y generaciones por identidad; applyAvatar actualiza solo imagen/correo, conservando el borrador del editor.

Sin email editable ni nueva columna de perfil. Selecciones recuperadas se vinculan a la cuenta original y requieren confirmación explícita. Arquitectura/privacidad/límites en ADR-008; inyección en bootstrap/main. Test de capas amplía SDKs protegidos a image_picker/image/shared_preferences/cross_file.

## Mis mascotas: registro y edición de metadatos

HU-03.1 / RF-03, issue #28, y parte de HU-03.2 / #29: Home recibe PetsSection desde app/router. PetListViewModel/PetDetailViewModel/PetEditorViewModel autoDispose consumen ListMyPets/ReadPet/CreatePet/UpdatePet; data encapsula consultas y RPC mediante SupabasePetDataSource y DTO. Bootstrap inyecta PetRepositoryImpl; sin imports de presentación entre funcionalidades.

Tabla privada pets con RLS/consulta por dueño y escrituras únicamente RPC autorizadas; UUID por borrador, deduplicación de creación y versionado para edición/reintento. Generaciones por identidad y keepAlive limitado a escritura protegen cambios de sesión/cierre. No implementar fotos o QR como parte de este incremento. ADR-010 documenta reglas, contratos y límites.

## Ampliación de ficha y galería privada

[ADR-012](decisiones/012-ficha-y-galeria-privada-mascotas.md) añade tipo/tamaño y galería privada. PetPhotoRepository/ManagePetPhotos y PetPhotosViewModel coordinan selección/consulta/subida/retirada mediante fuentes NativePetGallerySource y SupabasePetPhotoSource; bootstrap inyecta implementaciones. DTO separa metadata/URL de entidades. Metadata confirmada antes de fotos, IDs estables y respuesta confirmada para éxito; actor/generación/keepAlive protegen estados tardíos. Fotos públicas del QR y procesamiento servidor continúan fuera de este incremento.

### Coordinación de carga inicial de ficha y fotos

Los ViewModels de ficha/editor coordinan sus casos de uso existentes de metadatos y fotos en paralelo. La pantalla observa una única carga inicial hasta finalizar ambas consultas. La inicialización de PetPhotosViewModel se comparte por Future dentro de su ciclo de cuenta/mascota y se reinicia al reconstruirse por sesión; la galería reutiliza el resultado y conserva reintento explícito de sus errores. No cambia contratos de dominio ni acceso a SDK desde presentación. ADR-011 documenta la continuidad visual y sus pruebas.

## Archivo reversible de mascotas — contrato backend

ADR-014 establece archive_pet/restore_pet y borrado definitivo sin historia de casos. SQL030–033 aporta estado de archivo e indicadores protegidos del ciclo de casos; las RPC validan dueño, bloqueo de fila, versión y reintentos. El módulo de casos S3 debe mantener los indicadores de forma atómica. No se añadieron casos/adopciones. La integración Flutter añade campos de ciclo de vida a entidad/DTO, ArchivePet/RestorePet, consultas separadas activas/archivadas y PetLifecycleViewModel autoDispose por mascota. Ficha compone confirmación de archivo/restauración, shimmer de trabajo real, errores contextuales y éxito superior confirmado. Ambas listas se invalidan tras edición, archivo/restauración y eliminación; identidad/generación/keepAlive limitado protegen respuestas tardías. Dominio y servidor bloquean archivo con caso activo y borrado con historial. Véase ADR-014 para límites de validación remota.

ADR-015 establece GlassNavigationButton en core como control visual común de retorno/cierre de pantallas; PetScreenShell, AppPageLayout y ProfileScreen lo componen sin modificar ViewModels, dominio o datos.

## Campos requeridos de mascotas y feedback del editor

ADR-016 actualiza el contrato de guardado: tamaño/edad/rasgos pasan a obligatorios, rasgos máximo200. petValidationIssues en dominio devuelve todos los campos inválidos; CreatePet/UpdatePet comparten validatePet. ViewModel prepara edad textual y guarda invalidFields/errorId para presentación, sin escribir ante error. Campos compartidos admiten invalid sin errorText; editor usa shake danger/toast superior conforme a la nueva autorización.

Fuentes034–035/plan009 instalan trigger sobre insert/update de metadatos: mantiene las RPC/RLS/grants e idempotencia, exige datos nuevos completos y conserva filas anteriores sin inventar valores. Operaciones de archivo/restauración/eliminación no modifican esas columnas y siguen disponibles en datos antiguos. No cambia contratos de lectura ni SDKs en widgets.

## Borrador de fotos del editor

[ADR-017](decisiones/017-borrador-fotos-mascotas.md) conserva fotos confirmadas y separa selecciones/retiradas locales. PetPhotosViewModel ejecuta los casos de uso remotos solo después de validación y confirmación de metadatos por PetEditorViewModel. Descartar no escribe; retiradas cuentan para guardado/salida. Reintentos conservan IDs y el servidor mantiene límite/propiedad. Guardar no constituye una transacción distribuida entre metadatos y Storage. Sin nuevo SQL.

## Zonas privadas y selección manual — HU-02.1

Incremento en `features/interest_zones`, según [ADR-018](decisiones/018-zonas-manuales-privadas.md). InterestZonesScreen consume InterestZonesViewModel/ZoneViewState; ListInterestZones, SaveInterestZone y DeleteInterestZone expresan operaciones de dominio. Providers declaran contratos/casos de uso; bootstrap inyecta InterestZoneRepositoryImpl y SupabaseInterestZoneDataSource. Fuente encapsula SDK, repositorio mapea DTO/fallos seguros; dominio no importa plataforma. ZonePoint valida coordenadas textuales y numéricas sin reglas de negocio en widgets.

RLS/proyección propia, RPC autorizadas con UUID estable/versión/bloqueos y marca de eliminación evitan duplicados y resurrecciones por reintento. Fuentes036–039/plan010 generan migración y patch. Refresco conserva contenido/borrador; cambio/error de cuenta desmonta contenido anterior y descarta respuestas tardías. AutoDispose libera observación y keepAlive se limita a escritura.

flutter_map es el adaptador visual de teselas en presentación: conserva su fuente por instancia, atribución y caché; emite punto al ViewModel. No accede a repositorios ni Supabase. No hay GPS, PostGIS, preferencias/push ni publicación de casos en este incremento. Patch010 aplicado según confirmación del usuario del 10 de octubre; demo Android pendiente.

## Preferencias privadas de alertas — HU-02.2

[ADR-019](decisiones/019-preferencias-alertas-por-cuenta.md): AlertPreferencesScreen/PreferenceOptions consumen AlertPreferencesViewModel/PreferenceViewState. Dominio contiene AlertPreferences, ReadAlertPreferences, SaveAlertPreferences y contrato AlertPreferenceRepository; data aporta DTO, fuente SDK y repositorio. Providers declaran sesión/casos/contrato; bootstrap inyecta implementaciones y main sus overrides. Ruta privada desde Perfil, sin comunicación por infraestructura entre funcionalidades.

SQL040–043/plan011: agregado por owner_id, RLS/grants por cuenta y guardado RPC versionado con reintento idéntico/no-op. Recepción general prevalece y conserva tres tipos y canales bandeja/push. Defaults pausados solo tras ausencia confirmada; sin envío, permisos ni token. Generación/identidad protege respuestas tardías; autoDispose y keepAlive limitado a guardado. Refresh conserva contenido con progreso fino y error contextual; descartar/salir reemplaza borrador con confirmación. Modal compartido de descarte en core, reutilizado por zonas. HU-12 consumirá preferencias y validará entrega; S2 no acredita push.

## Fotos: cámara, procesamiento y principal — HU-04, 10 de octubre de 2026

ADR-020 amplía el circuito de fotos existente: PetPhotoOrigin independiente de ImagePicker, selección de principal como borrador y contrato con versión de selección. Presentation sigue consumiendo ViewModels/casos de uso; data encapsula selector, SDK y Edge. pet-photo-process autentica, autoriza, decodifica y recodifica bytes en servidor con WASM; SQL044–047 protege confirmación y escritura de derivados. Hash/tombstones quedan fuera de la proyección cliente. Buckets de derivados/miniaturas privados; S3 solo puede publicar derivados verificados, nunca originales antiguos. Lectura no ejecuta procesamiento ni publicación automática. Activación conjunta SQL/Edge y validación hosted pendientes; detalles en [ADR-020](decisiones/020-procesamiento-y-principal-fotos.md).

## Publicación de casos perdidos — HU-05

features/lost_cases sigue Clean Architecture/MVVM: entidades/contrato, PublishLostCase, ReadPublicLostCase y ListMyLostCases; DTO/fuente Supabase/repositorio con normalización de fallos; providers declarativos y composición bootstrap/main. ViewModels autoDispose por edición/consulta y estado por cuenta, cancelación lógica de resultados antiguos y recuperación. El mapa visual se comparte desde core con export compatible en interest_zones; no hay imports entre presentaciones. SQL048–051/plan013 mantiene versión/historial/contador de mascota atómicamente, protege fuente privada y proyecta campos/derivados permitidos. [ADR-021](decisiones/021-publicacion-casos-perdidos.md) y [ficha](funcionalidades/casos-perdidos.md).

## Casos encontrados — HU-06

found_cases implementa dominio/casos de uso/contrato independientes del SDK, data source con DTO/repositorio, providers declarativos y ViewModels autoDispose inyectados por bootstrap/main. Reportero no es dueño de mascota; pet_id nulo. Galería/normalización de fotos y CaseScreenShell compartidos pasan a core conservando wrappers/imports previos. Preparación/fotos/publicación se orquestan detrás del repositorio; nunca desde widgets. SQL/RLS/grants y hash de fotos controlan autorización, deduplicación y proyección segura. ADR-022 registra borradores/limpieza, buckets propios y extensión de pet-photo-process; sin importar presentación/data de otras funcionalidades. Véase la [ficha](funcionalidades/casos-encontrados.md).


## Feedback de reportes: corrección del 10 de octubre de 2026

Por instrucción explícita del usuario, los mensajes de error, validación y resultado se muestran en el toast superior compartido, sin texto contextual dentro de la pantalla ni debajo de campos/acciones. Esta instrucción sustituye las restricciones anteriores que reservaban el toast a excepciones y exigían feedback contextual. Etiquetas, datos, estados e instrucciones de privacidad se mantienen. El incremento adapta los flujos de reportes perdidos/encontrados; conserva invalid/ShakeField, acciones de reintento y ciclo de vida del aviso. Las demás funcionalidades existentes se adaptarán al intervenir sus flujos; no se afirma una migración global completada. Véase [ADR-023](decisiones/023-feedback-reportes-toast-superior.md).


## Vista previa de publicación inmersiva — 10 de octubre de 2026

Por referencia e instrucción explícita del usuario, perdidos/encontrados comparten CasePublicationPreview: fotografías protagonistas deslizables a ancho completo, indicador de foto, nombre/especie destacado y panel inferior GlassSurface con datos y acciones reales. CaseScreenShell conserva retorno glass, cabecera fuera de la transición, scroll y cover→stagger por etapa; se eliminan márgenes/cabecera de formulario solo en vista previa. La galería del formulario sigue usando PhotoGalleryStrip/PhotoGalleryTile; la vista previa sustituye sus tiles por el pager protagonista. primaryActionButtonStyle, LoadingShimmer y toast mantienen implementación única.

ExpandableDescription comparte contracción a dos líneas y expansión/contracción al tocar el texto, con AnimatedSize320ms/easeInOutCubic. Movimiento reducido presenta contenido inmediatamente. No reproduce el reveal ni cambia foto, borrador o envío al expandir. Se permite scroll y crecimiento con texto ampliado. Datos privados/funcionalidades de venta de la referencia no se añaden. Decisión y revisión en [ADR-024](decisiones/024-vista-previa-publicacion-inmersiva.md).


## Scroll continuo hasta el área del gesto — 10 de octubre de 2026

Por captura e instrucción del usuario, las páginas con scroll usan ScrollSafeArea de core: el viewport llega al borde inferior y no reserva una banda blanca fija con SafeArea(bottom:true). El espacio del gesto se suma al padding final del contenido y a los controles flotantes mediante bottomPadding; con teclado abierto se usa el inset efectivo, sin sumar una segunda franja. Mantener protegidos el último campo/botón y los márgenes laterales/superiores. La barra de navegación del sistema se solicita transparente, sin divisor ni contraste opaco; iconos oscuros sobre formularios y claros sobre vista previa fotográfica. Modales/onboarding mantienen sus áreas seguras específicas. Véase [ADR-025](decisiones/025-scroll-continuo-area-gesto.md).


## Listas de casos consistentes con mascotas — 10 de octubre de 2026

Por instrucción del usuario, Mis casos/Mis reportes usan la implementación extraída de Mis mascotas a core: EntityCardContent/EntityCardSurface, SwipeActionCard, TwoOptionFilter, CollectionHeader/CollectionAddButton. Mascotas delega en los mismos componentes y conserva su referencia aprobada. Abiertos/Resueltos, foto real disponible y botón+ de56 reemplazan ListTile y el botón grande inferior. Swipe devuelve posición y abre confirmActionDialog común; shimmer/errores/confirmación siguen el patrón existente. Borradores encontrados conservan descarte con superficie compartida. Presentación consume ViewModels/casos de uso; dominio no adquiere dependencias de Flutter/SDK. Incremento de gestión por dueño solicitado sobre HU-05/RF-05 y HU-06/RF-06: eliminación de casos active/resolved y consulta privada de resueltos, con IDs/historial conservados y permisos versionados en016. No implica cierre de historias. Véase [ADR-026](decisiones/026-listas-casos-componentes-compartidos.md).

## Consistencia aplicada — 11 de octubre

[ADR-028](decisiones/028-consistencia-fronteras-y-reutilizacion.md): contrato de sesión común para entrada, notificación por cuenta/mascota tras cambios confirmados, estados de fotos inmutables y utilidades compartidas. architecture_test inspecciona lib completo, incluidos core y fronteras entre funcionalidades. La preparación de fotos se comparte en core/data_sources/photo_preparation.dart; los adaptadores mapean fallos propios. retainedRead comparte finalización de lecturas conservadas sin clases base. SQL061/plan017 limita esperas de escritura en encontrados. CI backend valida SQL y Edge sin despliegue.

Apertura de fichas: app/navigation/entity_detail_page.dart compone la transición común de mascotas/casos; el origen es un Rect de presentación entregado por la tarjeta. No cambia contratos de dominio ni introduce imports de app desde funcionalidades. Decisión ADR-029.


## Casos con la referencia aprobada de Mascotas — 11 de octubre de 2026

Por instrucción del usuario, la UI de Mascotas se conserva y se reutiliza en Casos. EntityScreenShell y entityEditorPage extraen su contenedor/apertura existentes: mismos márgenes, navegación glass y cover→stagger, fuente visual del botón y retorno. Registrar perdido/encontrado desde Reportar o+ usa esa misma transición; todos los campos, fotos, instrucciones y acciones participan del timeline existente, sin reiniciarlo por edición/teclado/selección. PhotoAddTile y SizeChoiceSelector comparten las implementaciones aprobadas; Encontrados conserva tamaño/sexo/custodia opcionales y los contratos del reporte. Listados usan cabecera/grupo de contenido con entrada compartida, sin count por registro. No se altera el panel de ficha inmersiva solicitado en ADR-030. Véase [ADR-031](decisiones/031-casos-reutilizan-ui-mascotas.md).

Validación local: suite completa309 pruebas aprobadas;8 regresiones nuevas repetidas tras reforzar el descarte en tamaños390×844/320×350 texto2 y movimiento reducido. Renders revisados en build/ui-preview/case-creation. Pendiente revisar Android autenticado con fotos/teselas reales; la aprobación visual no cierra historias ni confirma backend remoto.


## Consistencia de formularios perdido/hallazgo — 11 de octubre de 2026

Corrección explícita del usuario tras detectar controles extra en hallazgo. Se retiran Latitud/Longitud, Usar coordenadas, lectura numérica del punto, Recuperar foto interrumpida y el acceso permanente Mis encontrados dentro del formulario. CaseLocationFields de core compone ambos formularios con la misma selección en mapa, instrucciones de privacidad, referencia privada, invalid/shake y stagger; solo cambia el título del suceso y los callbacks del ViewModel. Coordenadas continúan internas, sin nueva captura numérica ni GPS. Fecha/hora siguen compartidas por ADR-032. Fotos usan la misma etiqueta pública y galerías/controles compartidos.

Se conservan las diferencias propias del producto: perdido elige mascota/fotos registradas; hallazgo describe y fotografía una mascota sin dueño conocido y permite custodia opcional. Consultar la lista permanece solo ante envío ambiguo, igual en ambos recorridos. La API de recuperación de fotos permanece para el ciclo de vida existente, sin botón técnico permanente ni afirmación de recuperación automática nueva. [ADR-033](decisiones/033-formularios-reportes-consistentes.md).

Validación:50 pruebas de reportes, entrada real, preview, arquitectura y consistencia aprobadas; análisis sin incidencias. Las8 pruebas de creación verifican controles retirados ausentes, uso del bloque común, punto del mapa entregado al estado y ausencia de coordenadas visibles, tamaños390×844/320×350 texto2 y movimiento reducido. Capturas regeneradas y revisadas; no acreditan fotos/teselas reales. Revisión Android pendiente.


## Nuevo significado de búsqueda y aviso — 11 de octubre de2026

Por instrucción del usuario, Mascota perdida admite Mi mascota u Otra mascota posiblemente perdida. Mascota encontrada avisa en una búsqueda abierta con La vi o La encontré y está conmigo, sin cerrarla. Desde ficha se vincula automáticamente el aviso; solo el autor confirma Ya fue recuperada. Se conservan UI de Mascotas, coordenadas privadas/zonas públicas y órdenes estables. Aviso admite foto opcional; búsqueda comunitaria exige fotos. Registros anteriores siguen como Reporte anterior, sin reclasificación automática. [ADR-034](decisiones/034-busquedas-y-avisos-vinculados.md) y [ficha](funcionalidades/busquedas-y-avisos.md).

Cambio de alcance autorizado: HU-05/RF-05 y HU-06/RF-06; se adelantan partes app de HU-10/RF-11 y confirmación de HU-13/RF-07. No se cierran historias ni se entrega web/QR, moderación completa, push o exploración/paginación de HU-07. Fuentes062–065/plan018, migración generada y probada localmente; activación remota/Android y concurrencia multiconexión pendientes.


LostReportScreen en app compone editores perdido/comunitario y mantiene sus ViewModels autoDispose durante una única ruta. Core ofrece encabezado persistente sin conocer funcionalidades. Selección local sin reinicializar providers; presentación de funcionalidades no se importa entre ellas. [ADR-035](decisiones/035-alternar-origen-sin-recargar-formulario.md).


Consulta unificada Mis reportes: entidades/casos de uso de dominio en found_cases colaboran con dominio de lost_cases mediante providers declarativos. ViewModel coordina estado/refresh/eliminación; pantalla no obtiene repositorios ni combina infraestructura. app/router inyecta callback de panel Home. No nuevas fuentes SDK o SQL. [ADR-036](decisiones/036-reportar-y-mis-reportes.md).


ReadRecoverySearch (dominio found_cases) colabora mediante contratos de repositorios lost_cases/found_cases y providers declarativos. Resuelve únicamente destino concreto de aviso, sin cargar catálogo; ViewModel mantiene vínculo fijo y pantalla renderiza referencia estática. App/router rechaza ruta de aviso sin contexto válido. Sin nuevos SQL/SDK/data ni imports cruzados de presentación. [ADR-037](decisiones/037-avisos-desde-ficha.md).


## Composición del formulario único de pérdida — 12 de octubre de 2026

LostReportScreen sustituye el selector de pestañas por elección de ficha y compone los datos específicos con un único CaseReportFields de core. Los ViewModels exponen restoreReportDetails para transferir fecha parcial/hora/punto/referencia del mismo reporte al cambiar origen, comprobando identidad y bloqueo, sin tocar mascota/fotos/UUID. La composición permanece en app; core recibe valores/callbacks sin importar features y las funcionalidades no importan presentación entre sí. Sin cambios de dominio/SQL/permisos; [ADR-038](decisiones/038-formulario-unico-mascota-perdida.md) sustituye la interfaz de ADR-035.


## Explorar — HU-07.1

Módulo explore con domain/entities/repositories/use_cases/failures, providers declarativos, data_sources/models/repositories y presentation/state/view_models/widgets. ExploreSection consume ExploreViewModel→SearchCases→ExploreRepository; repositorio mapea DTO y fallos y firma miniaturas mediante la fuente de datos. Bootstrap/main inyectan implementaciones y router entrega el widget a HomeScreen; home no conoce otras presentaciones. Consulta server-side paginada/filtrada sobre proyecciones existentes, índices públicos PostGIS y cursor ligado a filtros, sin ampliar lectura privada. [ADR-039](decisiones/039-explorar-lista-publica-paginada.md) y [ficha](funcionalidades/explorar.md).


## Panel de filtros reutilizable

Core contiene FilterPopover<T>, FilterChoiceGroup<T> y SelectionPillSurface. El primero posee y libera su ruta modal; los demás renderizan valores/callbacks sin dependencias de negocio. TwoOptionFilter conserva su operación y delega la superficie compartida. ExploreFilters compone el editor/borrador visual, confirma selección y llama al callback de ExploreViewModel; no adquiere SDK/repositorios ni imports de otra presentación. Dominio y SQL conservan las reglas existentes. [ADR-041](decisiones/041-filtros-flotantes-reutilizables.md).


## Búsqueda de lugares y filtros integrados

ADR-042 sustituye la ruta modal de ADR-041 por FilterExpansion<T>, manteniendo SelectionPillSurface/FilterChoiceGroup compartidos y sin dependencias core→features. ExploreFilters conserva borrador local y confirmación hacia ExploreViewModel. SearchPlaces→PlaceSearchRepository→PlaceSearchRepositoryImpl→PhotonPlaceDataSource incorpora búsqueda de ciudades/direcciones; DTO GeoJSON y errores/caché permanecen en data. PlaceSearchViewModel autoDispose gobierna consulta y descarte por cuenta/disposición. Bootstrap/main inyectan cliente/endpoint/repositorio; providers declaran contratos. ZoneMapPicker añade fitRadius opt-in sin reglas de negocio. Sin cambios de permisos o contrato SQL019. [ADR-042](decisiones/042-filtros-integrados-y-busqueda-zonas.md).

Reportar20/10, ADR-107: CaseLocationFields/CaseReportFields reciben slot
ReportLocationSearchBuilder sin imports core→features. App compone places para
pérdida propia/comunitaria y router inyecta el builder en hallazgo. ProviderScope
local aísla ViewModel autoDispose de Explorar; casos de uso/fuente/caché existentes.
Photon solicita countrycode=PE y filtra respuestas por código, sin límites de
mapa ni SQL nuevos. Selección pasa por el ViewModel del reporte; referencia
privada independiente. [ADR-107](decisiones/107-busqueda-reportes-y-sugerencias-peru.md).

Places20/10, ADR-108: OverlayPortal/CompositedTransformTarget/Follower resuelve
sugerencias sin afectar layout de formularios. Presentación conserva resultados
en ViewModel existente; foco/portal/geometría pertenecen al widget. AppTextField
acepta FocusNode externo sin disponerlo, mantiene nodo propio por defecto.
Sin cambios de dominio/data/servidor; restricciones de Perú de ADR-107 intactas.

Places20/10, ADR-109: cancelación de dominio por operación atraviesa SearchPlaces,
contratos y repositorio; data traduce a AbortableRequest del cliente inyectado.
ViewModel cancela al editar/limpiar/cambiar cuenta/desmontar y lanza a300ms sin
cola detrás de consultas antiguas. Generación descarta resultados/errores tardíos;
repositorio impide cachear respuestas canceladas. Sin SDK en presentación/dominio.

Corrección places20/10, ADR-110: debounce600ms por instrucción explícita, sin
cola para peticiones recientes y con cancelación por operación conservada.
Timeout de transporte20s tras reproducir respuestas válidas a13–16s; mantiene
aborto al vencer. Búsqueda parcial delegada a fuente sin comparar nombres por
igualdad ni introducir comodines. Filtro Perú y contratos de ADR-109 conservados.
