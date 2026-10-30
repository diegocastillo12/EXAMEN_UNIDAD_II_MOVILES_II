# Avistamientos desde la web pública

21/10, ADR-122: calendario/hora y comentario usan DateField/TimeField/TextField
compartidos con [la piel y animaciones de Sader](controles-web.md). Fecha local,
HH:mm, límites, punto privado y reintentos conservados. QA Chrome con fixture
comprueba envío anónimo, metadatos eliminados, reintento ambiguo, responsive,
texto200%, foco y CSP/hidratación sin errores; sin confirmación remota.

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

**Seguimiento actualizado:** HU-10.1/#36 aceptada explícitamente por el usuario el18/10/2026; Done y issue cerrado en GitHub, verificado por API. Código integrado en main mediante PR60 y CI aprobado. Se conservan la evidencia comunicada de operación y los límites de inspección independiente; los pendientes visuales o pruebas ampliadas anteriores no se afirman ejecutados por esta aceptación.

HU-11,18/10: [cronología y revisión](cronologia-y-revision.md) implementa la
consulta privada del responsable en Android para los avistamientos web/app,
incluida foto/punto y auditoría. Requiere026 pendiente;025 confirmado según
«ok ya esta» del usuario, sin inspección independiente. El QR público conserva
su proyección y no muestra evidencia privada ni revisiones.

HU-10.2,18/10: plan025 extrae la persistencia común en persist_sighting para
web/Android, conservando firma y recibo de submit_public_sighting y controles
de QR. Reintentos comprueban también actor; nuevos registros app conservan
reporter_id verificado y no requieren QR previo. No se amplía la lectura pública.
[ADR-065](../decisiones/065-avistamientos-android-y-persistencia-compartida.md),
[ficha Android](avistamientos-android.md).025 permanece pendiente de aplicación;
la confirmación operativa de024/web por el usuario se conserva.

HU-10.1 / RF-11 / issue #36. Implementación local en
`feature/public-web-sighting`; incremento funcional finalizado según confirmación
del usuario del18/10/2026. Estado del issue GitHub sin modificar.
[ADR-064](../decisiones/064-avistamientos-publicos-idempotentes.md).

Confirmación18/10: el usuario informa que024_patch_public_sightings.sql ya está
aplicado. Sustituye las notas de activación024 pendiente, sin inspección remota
independiente. Implementación local terminada; despliegue de esta revisión y
recorrido real inicialmente por confirmar. Tras comunicar los criterios,
el usuario responde «ok si esta»: operación confirmada por él y cierre del
incremento funcional registrado. Sin inspección remota independiente ni evidencia
detallada nueva de cada escenario. El ajuste visual de contraste sigue pendiente.

## Qué hace y recorrido

Desde la ficha QR activa, «La vi · Reportar avistamiento» abre el formulario sin
cuenta ni instalación. Se registra fecha y hora locales del suceso, punto elegido
en mapa o GPS, comentario y foto opcionales. Centro inicial aproximado no se envía
sin confirmación. El mapa puede moverse con teclado y «Usar centro del mapa»;
denegar GPS mantiene la selección manual. Galería y captura de cámara son
alternativas; cancelar o no adjuntar foto no impide enviar.

Confirmación solo después de recibir el registro guardado. El formulario muestra
el estado confirmado y toast de éxito. Volver actualiza la ficha real. No resuelve
el caso, envía push ni implementa cronología/revisión HU-11 o envío Android HU-10.2.

## Reglas y campos

Fecha desde 2000, nunca futura. Más de 24 horas entre observación y recepción
se identifica como tardío; se conservan ambas fechas. Latitud −85..85, longitud
−180..180; manual con precisión nula, GPS con precisión de 0..100000m. Comentario
opcional hasta500 caracteres, sin datos personales recomendados por instrucción
visible. JPEG/PNG/WebP opcional hasta8MiB; servidor recodifica a JPEG1280px,
máximo1MiB, sin EXIF/XMP. No se acepta archivo por su nombre/MIME solamente.

## Persistencia y permisos

`public_sightings` privada, RPC solo servidor. UUID por visita al formulario y
hash de contenido protegen reintentos. Registro y evidencia bytea se guardan
atómicamente. Se conserva vínculo al caso/origen, no se inventa propietario del
avistamiento. Coordenadas, comentario y foto no se añaden al DTO público del QR.
La lectura autorizada por responsable/cronología se implementará con HU-11.

El servidor rechaza casos cerrados/borrados y enlaces revocados. Origen HTTP
exacto, límites de cuerpo/tiempo/concurrencia y rate limit por proceso; servidor
SQL limita confirmaciones por pseudónimo/caso entre réplicas. No guarda IP cruda.

## Errores y reintentos

Toast superior, invalid/Shake, etiquetas y datos conservados, sin texto de error
bajo inputs. Botón con etiqueta estable/shimmer y doble envío bloqueado.
Después de respuesta ambigua se bloquea edición y reintenta el payload original;
el servidor devuelve el recibo previo sin duplicar. Un error confirmado de foto
permite cambiarla/quitarla. Caso cerrado obliga a volver a la ficha.
Disposición cancela observadores y descarta respuestas de GPS antiguas. Cerrar
o recargar descarta el borrador: no se acredita guardado offline (HU-15).

## Dependencias y activación

Supabase001–023 operativos (022/023 confirmados previamente por el usuario).
Aplicar [patch024](../../database/patchs/024_patch_public_sightings.sql) o
[migración024](../../supabase/migrations/20261018002400_public_sightings.sql),
generados con Build-PublicSightingsPatch/Build-RunAll. Configurar PUBLIC_WEB_ORIGIN
con origen HTTPS exacto, sin slash final, en el servidor Nuxt; clave Supabase
solo servidor. Recompilar para incluir sharp y Leaflet.024 aplicado según
confirmación del usuario, quien después confirma que ya está operativo.
El agente no ha modificado ni inspeccionado el entorno remoto.

## Validación y pendiente

Resultados locales, capturas y limitaciones en [ESTADO](../ESTADO.md). Se prueban
reglas/VM/EXIF, RPC/roles/idempotencia/cierre/revocación/límites/repetición,
servidor de producción y navegador con datos/teselas fixture. Pendientes:
Supabase/Storage/proxy/TLS reales, concurrencia multiconexión, cámara/GPS en
teléfono físico y Safari/Firefox, QR desde otro teléfono y volumen/coste bytea.
La evidencia local no cierra HU-10.1 ni certifica publicación/contraste AA global.
Evidencia final:15 pruebas web y25 SQL aprobadas, typecheck/build limpios,
4 pruebas del servidor de producción y QA Chrome142 responsive aprobados.

Contraste medido en esta revisión: texto principal/crema17.08:1,
secundario/crema5.48:1, azul/celeste5.03:1. El texto blanco sobre el degradado
azul aprobado da1.97–3.62:1 (centro2.78:1), por debajo de4.5:1 para texto normal.
Se conserva la referencia cromática explícita de ADR-063; su adaptación accesible
queda como pendiente visual concreto, sin declarar AA. Registro hu10-contrast.log.
Cartografía20/10, ADR-104: SightingMap adapta el punto de producto a LocationMap
compartido. Base Positron y acabado intermedio global móvil/web, créditos
OSM/CARTO enlazados y filtro solo en teselas. Selección manual/GPS, validación,
privacidad y reintento conservados. Configurar NUXT_PUBLIC_MAP_TILE_URL por
entorno; ver [cartografía compartida](cartografia-compartida.md).
