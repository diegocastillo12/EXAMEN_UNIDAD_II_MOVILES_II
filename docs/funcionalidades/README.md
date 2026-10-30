# Funcionalidades de Entre Huellas

- [Lista de favoritos sin conexión para examen U2](lista-guardada-examen-u2.md):
  puntos1–3 del tipo4;1–2 demostrados por usuario. Ahora respaldo excluido,
  Guardados protegida y borrado de listas/claves en Perfil; demo del punto3 pendiente.

25/10: [Coincidencias entre casos](coincidencias-de-casos.md), HU-25/#71 y
HU-26/#72, implementación local Android/web en `feature/case-matching`.
Hallazgos independientes aprobados, motor CLIP CPU local, plan040 y revisión
humana. Activación/evaluación/aceptación pendientes; no implica historias cerradas.
Las notas inferiores de «sin implementar» son el plan inicial anterior.

25/10: cuenta/acceso, difusión, seguimiento y recuperación aceptados por el usuario;
#19/#34/#35/#40/#41/#13 y épica #8 cerrados. Estadísticas #50 ya aceptadas.
Las activaciones/demos históricas inferiores no sustituyen estas aceptaciones.

- [Coincidencias entre casos](coincidencias-de-casos.md): **incluido en MVP**,
  HU-25/#71 y HU-26/#72; RF-19/RF-20. Backlog/P1, sin implementar; modelo,
  contratos de candidatos y evaluación por refinar. ADR-137.

- [Estadísticas del piloto](estadisticas-piloto.md): HU-16.1/RF-35/#50; consulta
  web de agregados con permiso administrador independiente. Implementación local;
  activación039, asignación explícita, demo alojada e integración pendientes.

- [Fichas sin conexión](fichas-sin-conexion.md): HU-15.3/RF-32/#49; caché privada
  por cuenta de fichas consultadas y fotos, aviso de antigüedad e invalidación
  por respuesta del servidor. Evidencia y límites en su ficha.

24/10: [auditoría de los 51 issues de GitHub](../backlog/auditoria-github-2026-10-24.md).
Borradores #47 y cola #48 cerrados e integrados por PR67 con CI aprobado.
Las demás historias abiertas conservan los criterios pendientes allí detallados.

- [Envíos pendientes y reintentos](envios-pendientes.md): HU-15.2/RF-32/#48; cola SQLite
  por cuenta, estados persistentes y recibos verificados. Ciclo completo en app
  Android emulada y6/6 remotas estrictas con037/038 aplicados; evidencia en la ficha.

- [Borradores locales](borradores-locales.md): HU-15.1/RF-32/#47; guardado y recuperación
  por cuenta en Android, fotos y comando estable. SQLite nativo y reapertura sin
  red en app normal comprobados en emulador; teléfono físico no probado.

- [Bloquear y desbloquear cuentas](bloqueos-usuarios.md): HU-14.2/RF-23/#44;
  elecciones propias en móvil/web, rechazo SQL de nuevos avisos/avistamientos
  autenticados y ocultamiento de contacto/foto confirmado; activación034/036
  pendiente. QR anónimo conserva permisos; implementación local no equivale a historia cerrada.

- [Apelaciones de moderación](apelaciones-moderacion.md): decisiones propias,
  motivo, estado y respuesta auditada; usuario móvil/web, revisión solo web.

- [Distribución Android por GitHub Releases](distribucion-android.md): firma,
  secrets, APK por push a main, instalación, reintentos y validación pendiente.

Patrón UI/UX aprobado21/10: [Expansión desde origen con identidad del
control](../patrones-ui-ux/expansion-desde-origen.md), con contrato visual,
componentes, ejemplos y revisión para reutilizarlo en otros recorridos.
Implementación/evidencia: [transiciones web](transiciones-web.md).

Contrato vigente21/10, ADR-128: combinar fullscreen/GSAP Sader con identidad
móvil al abrir y cerrar. La superficie negra y su radio se transforman; icono
y nueve puntos mantienen tamaño, centrados dentro del contorno, con fase fuente
hasta45% invertida al regresar. Fade/blur de Sader solo al cuerpo de destino.
Control original oculto temporalmente para evitar duplicado y restaurado junto
a la limpieza de identidad, estilos y referencias. Se mantienen0.7s/CustomEase,
ruta anterior detrás, marca/barra, acceso/guards y reducido. Perfil/Alertas y
Flutter intactos. [ADR-128](../decisiones/128-identidad-mobile-en-origen-web-fullscreen.md).
Los apuntes anteriores que contradigan esa fase se conservan como historial.

21/10, instrucción posterior: [origen de navegación sustituido por Sader/GSAP](transiciones-web.md),
ADR-125; sin clonar pantallas y contenido solo al terminar apertura. Perfil/Alertas
conservan ADR-124; excepción explícita y evidencia acotadas al motor intervenido.

21/10: [paridad obligatoria de animaciones](transiciones-web.md), ADR-124;
Perfil/Alertas web expanden y retornan desde avatar/campana con tiempos/curvas
móviles. Verificación con fotogramas normales y movimiento reducido.

21/10: [cabecera y bandeja de alertas web](notificaciones-web.md), con avatar,
consulta de perfil y glass compartido con móvil. Lectura/paginación/marcar leída
reales sobre plan027; sin push, edición de perfil o migraciones nuevas.

21/10: [Inicio web](inicio.md) adopta el diseño de móvil con título azul,
accesos negros, ilustración y Cerca de ti; cuenta desplegable y gestión por
permiso. Build/typecheck/64 pruebas y QA Chrome responsive aprobados.

21/10: [navegación de cuenta](navegacion-web.md) sin frases decorativas sobre
títulos ni pie legal tras iniciar sesión; [legales](documentos-legales.md)
conservan sus accesos públicos. Typecheck y64 pruebas aprobados; build/revisión
visual pendientes según ESTADO.

21/10: [Reportar web](navegacion-web.md) carga campos y dependencias por separado,
con skeleton por selector y mapa, borrador íntegro y retry de cada fuente. ADR-123.

21/10: [Controles web compartidos desde sader-panel](controles-web.md),
FieldSelect/inputs/calendario/hora y línea de navegación superior. ADR-122.

Respuesta web20/10: [navegación](navegacion-web.md), [acceso](acceso-web.md) y
[transiciones](transiciones-web.md) eliminan esperas repetidas según ADR-121;
medición local con backend fixture, sin confirmación remota ni despliegue.

Hero20/10: [landing](landing-page.md) recupera título grande y mascotas de la
referencia original, por petición explícita. Excepción ADR-120 a ADR-111.

SEO20/10: [landing pública](landing-page.md), identidad SSR, dominio configurable
y WebP sin pérdida. Incluye migración futura a entrehuellas.app;
publicación e indexación real pendientes.

Web20/10: [transiciones desde origen y navegación liquid](transiciones-web.md),
barra solo con iconos, indicador deslizante y expansión/retorno compartidos con
la referencia móvil. ADR-119; evidencia local y dispositivos físicos pendientes.

Web20/10: [barra de navegación y recorridos de recuperación](navegacion-web.md),
Inicio/Explorar/Mis mascotas/Reportar, datos compartidos y operaciones autorizadas.
ADR-118; implementación/QA local, integración remota pendiente.

Entrada telefónica20/10: Perfil y Contacto del reportante comparten selector de país con bandera y prefijo (ADR-117). Búsqueda local en español y número nacional; contrato internacional/privacidad intactos, sin SQL adicional.

Celular20/10: [Perfil](perfil.md) incorpora número privado opcional y [Contacto del reportante](contacto-reportante.md) lo sugiere solo al autor, con consentimiento por ficha. ADR-116/plan033 después de032; activación remota pendiente.

20/10: [Compartir ficha pública](compartir-ficha.md), panel blanco sin X con Copiar enlace/WhatsApp/Facebook y dos iconos grises Descargar/Denunciar. Difusión y PDF para lectores autorizados de búsquedas activas; plan032 requiere activación remota. ADR-115, sin cierre de historias.

Ficha pública20/10: [corrección de posición de Perdido y acabado glass](ficha-publica-mobile.md), con frosted compartido y paginación centrada; refinamiento ADR-113. Validación visual normal/pequeña y preservación del glass anterior en ESTADO.

Ficha pública móvil20/10: [nuevo diseño por tarjetas glass](ficha-publica-mobile.md) y [contacto del reportante con permiso por caso](contacto-reportante.md), ADR-113/114. Diseño implementado localmente; contacto requiere activación031. El [patrón inmersivo](ficha-fotografica-inmersiva.md) se conserva en vistas previas.

Diseño conservado20/10: [Ficha fotográfica inmersiva](ficha-fotografica-inmersiva.md) (`ImmersivePhotoSheet`, antes `CasePublicationPreview`), renombrada para reutilización futura. Continúa activa; ADR-112.

Ficha del caso20/10: [nombre sobre fotografía con diseño original](identidad-visual.md),
blanco48/800 con sombra, sin cápsula; excepción local a ADR-111.

Móvil20/10: [títulos de las secciones alineados con Inicio](identidad-visual.md),
sin centrado vertical según la altura del botón. Refinamiento de ADR-111.

Títulos20/10: [regla Poppins400/32/gris para móvil y web](identidad-visual.md),
incluido [Guardados](casos-guardados.md); ADR-111.

Reportes20/10: [confirmación de salida rápida](busquedas-y-avisos.md), popup
compartido160ms sin expansión desde origen; refinamiento de ADR-006.


Explorar20/10: [panel minimizable hasta Ver ficha](explorar.md) y créditos
compactos que acompañan su borde superior, según ADR-106. Paleta global intacta.
Refinamiento de movimiento: impulso al soltar y detención al nuevo contacto;
validación y revisión Android pendiente en la misma ficha.

Cartografía21/10: [acabado y detalles compartidos móvil/web](cartografia-compartida.md),
intermedio entre Reportar y Explorar, obligatorio en adaptadores comunes.
Sustituye filtro local de Explorar; base/activación web según ADR-104.

Explorar20/10: [mapa y resumen compacto](explorar.md) según diseño aprobado;
miniatura mayor, descripción, detalles verticales y dos accesos a la ficha.
Acabado azul compartido con navegación y símbolo oficial en pines. ADR-103.

Móvil19/10: [fondo compartido](fondos-mobile.md) atenuado hacia blanco junto a la navegación, con luces superiores conservadas. ADR-102.

Explorar19/10: [Mapa flotante](explorar.md) sustituye Lista/Mapa tras elegir
la propuesta3; mismo mapa y consulta, espacio de listado recuperado. ADR-101.

Explorar19/10: [controles compactos](explorar.md) con lugar/radio en línea e
icono circular para filtros; área táctil48px, paneles existentes. ADR-100.

Corrección posterior19/10/2026 del usuario: Reportar (nueve puntos) vuelve
a su IconButton circular negro #111111 original, de64px y puntos blancos,
sin degradado, brillo ni sombra azul. El acabado de landing y sus efectos
se conservan únicamente en la selección activa de la barra.
Validación: formato, análisis completo y7 pruebas de Home aprobados.
Pendiente revisión visual Android.

Explorar móvil19/10: [mapa](explorar.md) con pines individuales separados
visualmente, especie en el resumen y foto adaptable mayor, sin contador,
selector entre coincidencias ni líneas de estado/conteo. ADR-099.

Navegación móvil19/10: [Inicio](inicio.md) adopta el acabado azul y los efectos
del botón de acceso de landing en selección activa y Reportar. ADR-098;
validación local aprobada, revisión Android pendiente.

Actualización móvil19/10: [Explorar](explorar.md) centraliza filtros en la sección
principal y muestra el resumen del pin con Ver ficha en el panel del mapa.
ADR-097; validación local aprobada y revisión Android del ajuste pendiente.

Toast móvil19/10: [mismo acabado, entrada y descarte por gesto que la web](toast-mobile.md),
en el componente compartido; ADR-096, sin cambios de backend ni nuevas historias.

Títulos móvil19/10: [Explorar](explorar.md), [Mis mascotas](mascotas.md) y
[fallback de Inicio](inicio.md) usan peso500 como Inicio web. CollectionHeader
extiende el mismo ajuste a sus listados de casos/reportes.

Inicio móvil, corrección19/10: [entrada suave del glass](fondos-mobile.md),
con fade/desplazamiento del stagger y sin recorte progresivo. ADR-095.

Corrección móvil19/10: [Inicio/glass](fondos-mobile.md) y [Explorar](explorar.md)
con un solo stagger, sin cover previo ni paneles glass vacíos. ADR-094.

Inicio móvil19/10: [glass estable y tarjeta de reunión](fondos-mobile.md),
con imagen original de web y superficie fuera del stagger. ADR-093.

Marca móvil19/10: [identidad visual](identidad-visual.md) usa el mismo lettering
Arial de web en BrandWordmark/arranque, conservando símbolo oficial. ADR-092.

Móvil19/10: [nubes en toda la altura con movimiento y tarjeta principal glass](fondos-mobile.md),
reutilizando el material compartido; pausa accesible y por ruta oculta. ADR-091.

Corrección móvil19/10: [fondo blanco con nubes azules](fondos-mobile.md) según
referencia aportada; ADR-088 sustituye el degradado inicial de ADR-086.

Acceso web19/10: [registro, verificación de correo y recuperación por código](acceso-web.md)
implementados localmente, con capacidad recovery aislada; ADR-087. Demo SMTP real
pendiente; no equivale a paridad global ni cierre de HU.

Móvil19/10: [fondo frío compartido](fondos-mobile.md), con los mismos colores
del resto de la web; arranque, shells y transiciones existentes. ADR-086.

Cartografía móvil19/10: [Positron y crédito compartido](cartografia-mobile.md),
con pines de marca conservados; ADR-084 sustituye ADR-054 para mapas CARTO.

Acceso web19/10: [avisos de una sola vez y URL limpia](acceso-web.md); se retira
reason consumido conservando parámetros de integración y fragmento.

Toast web: [entrada superior y descarte por gesto](toast-web.md), compartido
en todos sus consumidores actuales; ADR-081, validación local19/10/2026.

Corrección19/10: reveal compartido sin cobertura opaca en [acceso](acceso-web.md),
[moderación](moderacion-web.md), [QR](ficha-publica-qr.md) y
[avistamientos web](avistamientos-web.md). ADR-075; evidencia local en ESTADO.

Actualización19/10: [Acceso web](acceso-web.md) admite cuentas válidas sin rol de
revisión, con bienvenida por cuenta e inicio real de cuenta. Moderación conserva
permisos por operación y acceso desde gestión autorizada. /iniciar-sesion,
/terminos y /privacidad son canónicas, con redirecciones antiguas.
No se entrega paridad completa web/móvil ni administración; sin despliegue.

Confirmación posterior18/10:030 aplicado por usuario. Moderación web conserva
configuración/rol/login y demo real por verificar; no reaplicar030.


Moderación18/10: administración exclusivamente web por instrucción del usuario.
[Revisión y moderación](moderacion-web.md), HU-14.3/#45 implementada localmente;
030/configuración/demo pendientes. No se incorpora administración a Flutter.


Actualización posterior18/10:029 aplicado según confirmación del usuario.
HU-14.1 conserva validación real/integración pendientes; no reaplicar029.


Actualización18/10: el usuario confirma028 aplicado y autoriza continuar HU-14.1.
[Denuncias de contenido](denuncias-contenido.md) implementada localmente;029 confirmado, demo
pendiente. Firebase/FCM fuera del alcance; no bloquea la entrega. Estado remoto
del tablero conservado como última instantánea, sin nuevas acciones GitHub.


Auditoría ampliada18/10:27 Done,9 In progress,2 Ready y13 Backlog. Se
corrigieron20 tarjetas más tras contrastar integración/pruebas/confirmaciones.
[Motivo vigente por historia](../backlog/AUDITORIA_2026-10-18.md); las notas
históricas de las fichas no se tratan automáticamente como pendientes actuales.

Corrección18/10: HU-03 (#3/#28/#29) en Done y cerrada; los motivos de
seguimiento antiguos de fotos/patch se sustituyen por la implementación e
integración acreditadas. [Backlog actualizado](../backlog/README.md).

Seguimiento18/10: HU-10.1/#36 y HU-11.1/11.2 (#38/#39 y épica #11)
aceptadas por el usuario, Done y cerradas en GitHub. HU-12.1/12.2 y HU-13
permanecen In progress; FCM pospuesto. [Backlog sincronizado](../backlog/README.md).

Documentación del comportamiento implementado al 18 de octubre de 2026.
Cada ficha explica propósito, recorrido, reglas, persistencia, errores y
validación. Se actualiza junto con el código cuando cambia una funcionalidad.
Una funcionalidad implementada no equivale a una historia cerrada: la evidencia
de pruebas y despliegue se registra en [ESTADO](../ESTADO.md).

| Funcionalidad | Módulo Flutter | Trazabilidad |
| --- | --- | --- |
| [Fondos web compartidos](fondos-web.md) | apps/platform | Ajuste visual19/10/2026; toda la web excepto landing; sin HU/issue nuevo |
| [Documentos legales web](documentos-legales.md) | apps/platform | /terminos y /privacidad, con redirecciones antiguas; sin HU/issue nuevo |
| [Acceso web](acceso-web.md) | apps/platform | /iniciar-sesion, /bienvenida y /inicio; HU-01/RF-01,34 en web; conserva HU-14.3 / issue #45; demo real pendiente |
| [Revisión y moderación web](moderacion-web.md) | apps/platform / SQL Supabase | HU-14.3; RF-22,33; issue #45;030/configuración/demo pendientes |
| [Denuncias de contenido](denuncias-contenido.md) | content_reports / SQL Supabase | HU-14.1; RF-22; issue #43;029 confirmado; demo/integración pendientes |
| [Cierre y recuperación](cierre-y-recuperacion.md) | case_closure / SQL Supabase | HU-13; RF-07; issue #13; 028 confirmado aplicado; demo/integración pendientes |
| [Seguimiento y alertas](seguimiento-y-alertas.md) | notifications / SQL Supabase | HU-12.1/12.2; RF-16,17,18; issues #40/#41;027 confirmado, demo pendiente. HU-12.3/#42 FCM/Firebase pospuesta (ADR-068) |
| [Identidad visual y marca](identidad-visual.md) | core branding / apps/platform | Petición17/10/2026; sin HU/issue nuevo |
| [Landing pública](landing-page.md) | apps/platform (Vue/Nuxt) | Ampliación del usuario; integración17/10/2026; sin HU/issue nuevos |
| [Ficha pública QR](ficha-publica-qr.md) | apps/platform (Vue/Nuxt) | HU-09; RF-09; issue #9; lector operativo e integrado; Done |
| [Avistamientos web](avistamientos-web.md) | apps/platform / sightings | HU-10.1; RF-11; issue #36;024/operación aceptados; Done |
| [Avistamientos Android](avistamientos-android.md) | apps/mobile / sightings y servidor Nuxt | HU-10.2; RF-11; issue #37;025 confirmado e integración PR60; Done |
| [Cronología y revisión](cronologia-y-revision.md) | apps/mobile / case_timeline, RPC autenticadas | HU-11.1/11.2; RF-12,14; issues #38/#39 y épica #11;026/recorrido aceptados; Done |
| [Carteles PDF y QR](carteles-qr.md) | case_posters | HU-08.1/08.2; RF-08,37; issues #34/#35; integrado; impresión/escaneo y exportación nativa pendientes; In progress |
| [Buscador compartido de ubicaciones/ciudades](ubicaciones-buscador.md) | places | HU-07/RF-13 y Perfil HU-01.7/RF-01; ampliación16/10/2026 |
| [Casos guardados](casos-guardados.md) | saved_cases | Ampliación16/10 de HU-07/RF-13; online integrado; offline HU-15.3/#49 sin implementar |
| [Acceso y recuperación](acceso.md) | auth | HU-01; RF-01,34; #17/#18/#20/#22 Done; #19 retorno Google pendiente; épica #1 abierta por Google/baja/exportación |
| [Onboarding por cuenta](onboarding.md) | onboarding | HU-01.5; RF-01; issue #21; ADR-004; Done |
| [Inicio y navegación](inicio.md) | home | Composición de recorridos, acceso a Reportar y módulos |
| [Perfil y foto de cuenta](perfil.md) | profile | HU-01.7; RF-01; issue #23; entrega integrada; Done |
| [Mascotas](mascotas.md) | pets | HU-03; RF-03; issues #3/#28/#29; Done |
| [Fotos de mascotas](fotos-mascotas.md) | pets y Edge pet-photo-process | HU-04; RF-03; issues #4/#30/#31; cámara/procesamiento/principal integrados; Done |
| [Ubicaciones de interés](zonas.md) | interest_zones | HU-02.1; RF-02,16; issue #26 y épica #2;010 confirmado; Done |
| [Preferencias de alertas](preferencias-alertas.md) | alert_preferences | HU-02.2; RF-02,16; issue #27 y épica #2;011/HU-02 confirmados; Done |
| [Casos perdidos](casos-perdidos.md) | lost_cases | HU-05; RF-05; issue #5; entrega integrada; Done |
| [Avisos y reportes anteriores](casos-encontrados.md) | found_cases | HU-06; RF-06; issue #6; alcance ADR-034 integrado; Done |
| [Búsquedas y avisos vinculados](busquedas-y-avisos.md) | lost_cases / found_cases | HU-05/06 Done; partes HU-10; cierre nuevo HU-13 028 confirmado; integración/demo pendientes; ADR-034 |
| [Explorar: lista y mapa filtrados](explorar.md) | explore | HU-07.1/07.2; RF-13; issues #32/#33 y épica #7; integración/Android real; Done |
| [Mis reportes](mis-reportes.md) | found_cases / dominio lost_cases | HU-05/06; consulta unificada; ADR-036 |

Las HU son identificadores del producto; los números # son issues de GitHub.
El detalle de subtareas se conserva en [backlog](../backlog/README.md).

Todas las funcionalidades siguen [las reglas de arquitectura](../REGLAS_ARQUITECTURA.md):
pantallas → ViewModel → casos de uso → contrato de repositorio → fuente de datos.
Las sesiones y permisos se comprueban también en servidor; la UI no sustituye
RLS, grants ni restricciones. Al cambiar de cuenta se descartan resultados
tardíos y datos privados de la identidad anterior.

## Notas técnicas históricas

Las notas siguientes reflejan sus incrementos originales. Para el estado actual
se aplican la tabla y la auditoría del18/10; no reactivan pendientes ya superados.

Mapa de Explorar, carteles/QR y lectura web tienen implementación local;
activación y evidencia se detallan en sus fichas. Avistamientos web operativos
según usuario; Android implementado localmente con025/demo pendiente. Bandeja
y seguimiento/bandeja tienen implementación local HU-12.1/12.2 con027 confirmado
por el usuario; demo hosted pendiente. FCM/Firebase y HU-12.3 quedan pospuestos
por instrucción del usuario (ADR-068), fuera de la activación actual.

Para cada incremento, actualizar su ficha, enlazar nuevas fichas aquí y
registrar en ESTADO la validación real y lo pendiente. Los motivos técnicos van
en ADR; los pasos de activación van en CONFIGURACION, evitando copias de SQL o
comandos de despliegue que puedan divergir.

Corrección de feedback en reportes perdidos/encontrados: [ADR-023](../decisiones/023-feedback-reportes-toast-superior.md). Patch014 y copia/extracción del paquete confirmados por el usuario; validación remota autenticada pendiente.


Perdidos y encontrados comparten la vista previa inmersiva de publicación y la descripción expandible, según [ADR-024](../decisiones/024-vista-previa-publicacion-inmersiva.md). Vista previa y ficha pública comparten esta composición; la galería del formulario conserva sus tiles. Se mantienen los criterios remotos pendientes.


Los layouts con scroll de acceso, Inicio, perfil, mascotas, zonas, preferencias y reportes comparten la continuidad inferior y protección de acciones de [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md); modales/onboarding conservan sus geometrías específicas.

Las fichas/previas de perdidos y encontrados incorporan mapa compartido de zona pública, fecha destacada y retorno sin título glass. Ver fichas y ADR-024 actualizado; verificación de teselas reales en Android pendiente.

Mis casos/Mis reportes adoptan los componentes reales de Mis mascotas y eliminación por swipe de casos abiertos/resueltos. Activación por migración016 pendiente; detalle en ambas fichas y [ADR-026](../decisiones/026-listas-casos-componentes-compartidos.md).

La corrección global del11 de octubre aplica ADR-027/028 a las fichas existentes, incluido onboarding; todas documentan toast/shimmer, reintentos y límites. Evidencia consolidada en ESTADO.


Mascota perdida adopta un único formulario con selección de ficha y datos del reporte conservados: [búsquedas y avisos](busquedas-y-avisos.md), [ADR-038](../decisiones/038-formulario-unico-mascota-perdida.md).

Reportar20/10: [buscador compartido](ubicaciones-buscador.md) antes del mapa para
pérdida/hallazgo. Sugerencias de Perú también en Explorar y Ciudad del perfil;
mapa manual libre. [ADR-107](../decisiones/107-busqueda-reportes-y-sugerencias-peru.md).

Ubicaciones20/10: [sugerencias flotantes](ubicaciones-buscador.md) en panel único
continuo, sin empujar el contenido de Reportar, Explorar o Perfil. ADR-108.

Ubicaciones20/10: [respuesta reciente](ubicaciones-buscador.md) con debounce300ms
y cancelación HTTP por consulta para evitar esperas acumuladas. Filtro PE y
panel flotante conservados; latencia del proveedor variable. ADR-109.

Ubicaciones20/10: [corrección de espera y búsqueda parcial](ubicaciones-buscador.md).
Pausa600ms restaurada; timeout20s para respuestas válidas tardías del proveedor.
`tacn` devuelve Tacna en consulta real; cancelación/Perú/panel conservados. ADR-110.
