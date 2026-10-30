# Casos de mascotas perdidas

Excepción local20/10/2026, por petición explícita: el nombre de la ficha del
caso sobre fotografía conserva su diseño anterior a ADR-111: fuente del sistema,
blanco, tamaño48/peso800, altura1.05 y sombra negra suave, máximo dos líneas con
elipsis. Sin cápsula blanca. Solo CasePublicationPreview; los demás títulos
conservan Poppins400/32/gris. Acciones, panel y datos intactos.

Corrección20/10/2026: nombre principal de Ver ficha directamente sobre la
fotografía, sin cápsula blanca ni padding añadido. CasePublicationPreview
conserva Poppins400/32/gris, texto completo y scroll. Ajuste solicitado por el
usuario; sin cambios de datos, permisos o acciones.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Auditoría de seguimiento18/10:** HU-05/#5 en Done: publicación propia integrada,013 confirmado, pruebas existentes y casos/fotos reales consultados posteriormente. El alcance ADR-034 se conserva; no se ejecuta una publicación nueva por actualizar Projects.

Ampliación del16 de octubre: marcador glass superior derecho para Guardar caso/Quitar de guardados, compuesto por router con [saved_cases](casos-guardados.md). Estado operativo/permisos conservados. Requiere020; formato/análisis sin incidencias, sin pruebas ejecutadas ni activación remota. [ADR-050](../decisiones/050-casos-guardados-por-cuenta.md).

Ajuste del15 de octubre: texto visible Zona/Zonas pasa a Ubicación/Ubicaciones, incluidas indicaciones de privacidad. No cambian precisión pública, campos, permisos ni datos. Formato/análisis; sin nuevas pruebas por instrucción del usuario. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

Trazabilidad: **HU-05 / RF-05**, sprint S3, **issue #5**. Rama `feature/lost-pet-cases`. Implementación local; no historia cerrada ni despliegue confirmado. Contratos en [ADR-021](../decisiones/021-publicacion-casos-perdidos.md); evidencia en [ESTADO](../ESTADO.md).

## Qué hace y recorrido

Inicio → Reportar → Mascota perdida. Consulta las mascotas activas propias; si no hay ninguna permite abrir el registro y volver a consultar. Se elige mascota, se consultan su ficha/fotos actuales y se seleccionan de una a tres fotos públicas. La fecha y hora de desaparición se eligen con calendario/reloj; lugar por punto manual en mapa, sin solicitar GPS. La referencia del lugar queda privada.

Revisar publicación abre la vista previa con los datos que se harán públicos y el aviso para revisar información personal visible en rasgos/fotos. Publicar caso envía un UUID estable y conserva la etiqueta con shimmer durante el trabajo. Solo la respuesta válida del servidor abre Caso publicado → Ver ficha pública. Reportar → Mis casos permite recuperar publicaciones anteriores y abrir su proyección pública. No se publica directamente al elegir fotos o abrir vista previa.

## Campos y reglas

- Mascota propia, no archivada ni en eliminación; metadatos completos y versión vigente.
- Nombre/especie/tipo/tamaño/sexo opcional/edad/rasgos proceden de la ficha confirmada. Para cambiarlos abrir Editar mascota y luego volver a consultar fotos/ficha en el reporte.
- Fotos:1–3, distintas y elegidas explícitamente. El servidor exige estado publicado, processed_at y hash de procesamiento; fotos antiguas no verificadas requieren volver a guardarse desde el editor.
- Fecha/hora desde el año2000 y no posterior al reloj del servidor; Flutter convierte la hora local a UTC.
- Latitud−85..85 y longitud−180..180, finitas. Referencia privada1–120 caracteres Unicode tras normalizar.
- Solo un caso perdido activo por mascota. Reintento idéntico devuelve el caso; UUID con otros datos o versión desactualizada exige revisión.

## Persistencia y privacidad

Tablas `lost_cases` y `case_events`, RPC `publish_lost_case`, `read_public_lost_case` e `is_public_case_rendition`; [patch013](../../database/patchs/013_patch_lost_cases.sql). La publicación actualiza historial/contador/versión de mascota y el evento de publicación en una transacción. El historial impide eliminar definitivamente la mascota; el caso activo impide archivarla.

Datos públicos: copia de ficha permitida, fecha/hora, zona aproximada y fotos seleccionadas verificadas. Punto exacto, referencia del lugar y actor permanecen en fuente privada. No consulta documentos, salud, domicilio ni perfil/correo del responsable. La zona pública es el centro de una celda de0.01 grados; no representa el punto exacto. Las rutas de fotos incluyen UUID técnicos opacos, sin datos de perfil ni ubicación.

Los buckets siguen privados. Solo derivados seleccionados de casos activos admiten lectura pública mediante RLS; originales y fotos restantes no se exponen. URLs firmadas de5 minutos; retirar la foto impide nuevas consultas/firmas, pero enlaces existentes pueden seguir hasta su vencimiento. Retirada mantiene el ciclo de vida previo y puede reducir las fotos públicas disponibles. La pantalla móvil es protegida; el contrato RPC ya es público para la futura web QR, todavía sin web ni tokens/cartel de HU-08/HU-09.

## Errores y reintentos

Errores de campo y operación mediante toast superior compartido, sin mensajes debajo de campos ni acciones y sin SnackBar; invalid/ShakeField conservan la marca del campo. Véase [ADR-023](../decisiones/023-feedback-reportes-toast-superior.md). Fallos de consulta distinguen error de vacío confirmado y ofrecen Reintentar. Consultar de nuevo conserva datos previos con progreso fino; un fallo conserva la última consulta. Cambio de cuenta oculta datos previos y descarta solicitudes tardías.

Fallos al publicar conservan el formulario y UUID. Respuesta ambigua congela el comando y permite reintentar exactamente o consultar Mis casos; nunca se permite editar ese comando y reutilizarlo como otro envío. Los rechazos conocidos permiten volver al formulario y consultar ficha/fotos. Salir sin publicar pide confirmar descarte; si hubo un envío ambiguo explica que puede estar persistido. No hay borrador persistente ni cola offline: quedan para HU-15.

## Dependencias y activación

Requiere mascotas y fotos012/Edge `pet-photo-process` funcionando. Aplicar patch013 completo en Supabase de desarrollo y reconstruir/actualizar la app; procedimiento en [CONFIGURACION](../CONFIGURACION.md). No requiere Edge nueva, push, permisos de ubicación ni PostGIS para esta publicación. PostGIS/cercanía son el incremento de HU-07.

## Validación pendiente

Pruebas locales Flutter/SQL y renders normales/pequeños se registran en ESTADO. El usuario confirmó la ejecución de patch013 el 10 de octubre de 2026. Falta demostrar publicación/reapertura/reinicio, dos cuentas, GPS denegado o ausente, doble envío/concurrencia con conexiones independientes, fallo/reintento y bytes públicos/originales privados contra Android/Supabase real. Las pruebas usan sustitutos y metadata de Storage, no acreditan el servicio remoto. Sin cerrar #5, desplegar ni actualizar GitHub en esta tarea.

## Evidencia local del incremento

234 pruebas Flutter y16 SQL locales aprobadas; formato/análisis correctos. Las9 pruebas nuevas cubren reintentos, cuenta/disposición, refresco, navegación/protección/descarte, privacidad presentada, dos tamaños y adaptador SDK. Renders con fuentes reales revisados; no hay datos ni teselas remotas en fixtures. No se ejecutó build Android por el agente; el usuario confirmó posteriormente la ejecución de patch013. HU-05 permanece pendiente de demo remota.

Corrección del 10 de octubre: publicación/confirmación, consultas/refresco e imágenes fallidas comunican feedback en toast superior. El rechazo de fotos no verificadas no aparece bajo Publicar caso. Reconstrucción/actualización Android y demo remota de estas correcciones pendientes.

## Publicación sin respuesta — 10 de octubre de 2026

La RPC de publicación tiene un límite cliente de30 segundos; el ViewModel limita el conjunto de la espera a35 segundos. Vencimiento es respuesta ambigua, no cancelación ni descarte del servidor: conserva UUID/comando, sale del shimmer, explica el fallo en toast y permite reintentar o consultar Mis casos. Una respuesta tardía no cambia el resultado de un reintento posterior. No se anuncia éxito sin confirmación y no se desbloquea edición del comando ambiguo. Diagnóstico técnico registra solo tipo de excepción/código PostgREST normalizado, nunca payload, mensaje SDK, tokens ni URLs. La causa remota requiere observar un intento autenticado; el timeout no acredita publicación.

Diagnóstico remoto posterior: el emulador envía el cuerpo completo, pero no recibe respuesta; repetir exactamente el comando desde el equipo tampoco responde. Consulta autenticada del UUID devuelve cero filas y rechazo temprano con ID nulo responde en aproximadamente1s. Mascota inexistente responde42501; la misma mascota con versión imposible también espera, sin posibilidad de escritura. El usuario aportó una cadena de PostgREST esperando `Lock / tuple`: bloqueo confirmado, origen estable todavía no identificado. El script de diagnóstico entrega una sola tabla (SQL Editor puede mostrar solo el último resultado), sin datos de mascotas ni texto SQL.

Plan015/fuente056 añade `lock_timeout=5s` solo a `publish_lost_case`; no modifica permisos, validación, orden de bloqueos, deduplicación ni fuentes aplicadas. Rechazo55P03 se mapea a busy y se presenta únicamente en toast: otra operación usa la mascota. Al ser rechazo confirmado, permite editar/reintentar; el timeout cliente sigue siendo ambiguo. Patch015 preparado y validado localmente; aplicación y prueba concurrente en PostgreSQL independiente pendientes. No libera transacciones ya abiertas: recuperación operacional separada mediante cancelación limitada a PIDs observados y publicaciones activas esperando bloqueos. No se terminó ninguna conexión ni se ejecutó esa recuperación desde el equipo.

El usuario confirmó aceptación de cancelación para dos consultas de la cola (474663 y476153). Falta diagnóstico posterior para demostrar que la cadena terminó, aplicación de patch015 y publicación/reapertura real. La señal aceptada no equivale a transacción terminada ni publicación exitosa.

Actualización del incidente: usuario confirma patch015 aplicado; diagnóstico aún muestra sesión473812 idle in transaction como bloqueador. Recuperación operacional específica en `database/tests/release_idle_lost_case_blocker.sql`, con comprobación de estado actual, base, aplicación y bloqueo antes de solicitar terminación. Revierte operaciones no confirmadas de esa única sesión; no es una migración ni limpieza automática. Falta ejecutar la recuperación, verificar ausencia de cadena y confirmar publicación/reapertura.

La siguiente salida conserva una cadena con estados/PIDs cambiantes; no se continúa cerrando sesiones por PID. Recuperación preparada mediante reinicio exclusivo del contenedor rest/PostgREST del proyecto Dokploy observado, con validación de proyecto/servicio/unicidad/imagen en `supabase/self-hosted/restart-rest-connections.sh`. Interrumpe peticiones API pendientes y restablece sus conexiones; no acredita por sí mismo el origen del problema. Falta ejecución remota, diagnóstico sin cadena y publicación/reapertura real.

Indicación posterior vigente: se retira la propuesta de reinicio/cierre y nuevas consultas SQL después de la objeción del usuario. Lectura/firma de fotos recuperada con200 en Android, pero publicación todavía sin confirmación; comprobación con versión imposible sin posibilidad de crear caso también vence a10s. No afirmar cierre de HU-05 ni recuperación del backend por la galería. No se realizó reinicio remoto ni otra migración.


## Reutilización visual — 10 de octubre de 2026

Confirmaciones delegadas al diálogo completo confirmActionDialog de core, con acciones de geometría/alineación y adaptación compartidas, sin layouts propios. En reportes, terminar carga conserva la entrada del skeleton y no dispara cover/stagger nuevos; vista previa y confirmación conservan su transición. Validación local y límites en ESTADO; no cambia persistencia/permisos ni cierra la historia remota.


## Mapa y galería simplificados — 10 de octubre de 2026

Por instrucción del usuario, el formulario de perdida no solicita ni muestra coordenadas numéricas: el lugar se marca tocando el mapa, sin GPS. El ViewModel recibe el punto del adaptador visual y el dominio/servidor conservan rangos y privacidad. No cambian las RPC ni la proyección pública aproximada. Se retira el método de presentación que interpretaba coordenadas textuales.

Fotos y vista previa reutilizan PhotoGalleryStrip/PhotoGalleryTile extraídos de la galería real de mascotas, con scroll horizontal, tamaño de detalle adaptable112–160, separación10 y radio22. El reporte conserva la selección explícita para publicar1–3 fotos; las casillas están dentro de cada foto y la vista previa muestra solamente las elegidas. La galería de mascotas continúa usando estos mismos componentes para retirada, principal y borradores. Pruebas de deslizamiento/selección/punto de mapa y dos tamaños registradas en ESTADO; descarga de imágenes/teselas reales sigue siendo una comprobación integrada separada.


## Vista previa inmersiva — 10 de octubre de 2026

Vista previa reutiliza CasePublicationPreview de core: fotos protagonistas con pager/indicadores, nombre o especie sin datos inventados y panel GlassSurface de información pública. Publicar caso/Editar reporte conservan acciones del ViewModel, shimmer/bloqueos y manejo de respuestas ambiguas. Solo las fotos seleccionadas forman parte del preview perdido; encontrada usa los bytes del borrador antes del procesamiento/publicación.

Descripción larga contraída a dos líneas; tocarla expande todo el texto y el panel suavemente320ms, y permite contraerlo sin nuevo reveal ni cambio de foto. Movimiento reducido inmediato, texto ampliado y scroll para alcanzar las acciones. Fecha y privacidad/zona aproximada permanecen; punto y referencia privados excluidos. La composición de la vista previa sustituye las fotos pequeñas mencionadas en registros anteriores; formulario y ficha pública mantienen su galería actual. [ADR-024](../decisiones/024-vista-previa-publicacion-inmersiva.md), evidencia local y límites en ESTADO. Sin cambio de esquema/Edge ni cierre remoto de historia.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Ficha pública unificada — 10 de octubre de 2026

Ficha pública y vista previa usan el mismo renderer/CasePublicationPreview: fotos grandes deslizables, panel glass y descripción expandible suave. La ficha usa cabecera Ficha pública, conserva estado activo/consulta y no ofrece Publicar caso ni Editar reporte; las instrucciones preventivas se reservan al preview. Esto sustituye la conservación de la ficha anterior descrita en el incremento previo. En perdida se retiran Volver a consultar fotos y Mis casos del formulario; la recuperación Consultar Mis casos permanece ante respuesta ambigua.

Validación local: 42 pruebas de perdidos/encontrados, componente compartido, reveal y arquitectura aprobadas; capturas390×844/320×350 con texto ampliado y comprobación de consulta alcanzable. Sin cambio de persistencia/permisos; instalación y revisión con fotos reales en Android pendientes. No cierra la historia ni el incidente remoto de publicación.


Actualización del 10 de octubre de 2026: por instrucción del usuario se retira el título glass flotante de la ficha/vista previa inmersiva; se conserva únicamente GlassNavigationButton para volver. Fecha del suceso a20px/negrita, con ajuste por texto ampliado. La ubicación se representa mediante ZoneMapPicker compartido en modo lectura, con la zona aproximada pública, círculo y sin marcador de punto exacto; formulario conserva edición del punto privado. Preview usa la proyección aproximada existente y ficha solo las coordenadas públicas del contrato. Errores del mapa usan toast superior compartido y conservan Reintentar mapa, sin mensajes bajo el mapa ni solicitud de coordenadas numéricas. La consulta no modifica ubicación ni captura el scroll vertical. Sustituye las indicaciones previas de título inmersivo y ubicación explicada solo por texto.


## Listado y eliminación con UI compartida — 10 de octubre de 2026

Mis casos reutiliza la implementación de tarjetas, selector, cabecera/botón+ y swipe extraída de Mis mascotas a core. Abiertos/Resueltos filtra estados reales; portada de los derivados seleccionados/disponibles, con icono si no hay imagen. Tarjeta devuelve su posición antes del diálogo compartido; cancelar conserva datos, confirmar elimina mediante caso de uso/servidor. Resultado/error en toast superior; shimmer/bloqueo durante la operación y error permite reintentar sin quitar el caso. Casos resueltos se consultan solo por su dueño. Encontrados pendientes conservan Descartar y superficie compartida; no se muestran como publicados.

Persistencia: migración016/fuentes057–060. deleted_at oculta lista/publicación conservando ID/historial; perdido activo libera el contador atómicamente una vez, sin borrar mascota/fotos ni perder historial. Found activo/resuelto admite la misma retirada, sin convertir descarte de borrador en eliminación publicada. Cambio de cuenta ignora resultados anteriores y bloquea dobles envíos. URLs ya firmadas mantienen TTL300s; no hay purga física en esta operación. Véase [ADR-026](../decisiones/026-listas-casos-componentes-compartidos.md).

Validación local en ESTADO: tarjetas/selector/diálogo con390×844 y320×350 texto2, permiso dueño/otra cuenta/anon, reintentos, conservación y publicación posterior. Pendiente aplicar016 y probar Android autenticado con fotos reales; funcionalidad implementada localmente, sin cierre de historia ni confirmación remota.

## Corrección de consistencia — 11 de octubre de 2026

Publicar y eliminar notifican a mascotas por contrato de dominio. La validación de mascota con caso activo reside en dominio. Mapa invalid usa superficie compartida; preview, fecha y refresh reutilizan core.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.

## Carga de ficha y fotos — 11 de octubre

La ficha carga con CasePublicSkeleton compartido, congruente con foto de fondo y panel glass; no usa placeholders de inputs ni título de formulario. Shimmer accesible sin texto visible, navegación conservada y contenido desplazable con texto ampliado. Las fotos de ficha/vista previa usan CasePhotoView: shimmer solo hasta el primer fotograma; el fallo conserva espacio y usa toast. Refresh explícito conserva contenido con el componente previo. Comprobaciones locales y límites en ESTADO; sin cambios de esquema ni despliegue en esta corrección.

## Apertura y acciones de consulta — 11 de octubre

La ficha usa la apertura/retorno compartidos desde la tarjeta real (ADR-029), con movimiento reducido y navegación directa sin origen cuando corresponde. Los casos no presentan una acción permanente de volver a consultar; Reintentar aparece únicamente ante un fallo real. Se preservan guardado/inspección de mascotas, borrado/estados de casos, sus permisos y la invalidación tras operaciones confirmadas. Evidencia y límites en ESTADO.


## Panel de ficha expandible — 11 de octubre de 2026

Por solicitud del usuario, ficha pública y vista previa comparten un panel inferior arrastrable con apertura por toque en el indicador; foto/pager permanecen detrás. Desaparición (Encuentro en encontrados) aparece en badge fuera del glass, junto al nombre cuando hay espacio y debajo con texto ampliado. Nombre con sombra leve, máximo dos líneas y elipsis; la etiqueta accesible conserva el nombre completo. El mapa no se monta hasta abrir el panel; fecha, ubicación aproximada y privacidad se muestran en los datos ampliados. El contenido se desplaza dentro del panel y las acciones existentes conservan sus operaciones reales. Movimiento reducido desactiva animación y snap; no se reproduce reveal durante gestos. Véase [ADR-030](../decisiones/030-panel-ficha-expandible.md).


### Corrección del anclaje inferior — 11 de octubre de 2026

Por corrección del usuario, el resumen inicial baja (36% del viewport para ficha sin acciones,46% para vista previa con acciones; texto ampliado conserva espacio desplazable). El panel glass ocupa como mínimo el espacio restante hasta el margen seguro inferior aunque haya pocos datos, evitando una tarjeta suspendida con vacío debajo. Nombre con sombra más sutil: opacidad20%, blur3 y desplazamiento vertical1. Apertura/mapa/acciones conservados.


## Casos con la referencia aprobada de Mascotas — 11 de octubre de 2026

Por instrucción del usuario, la UI de Mascotas se conserva y se reutiliza en Casos. EntityScreenShell y entityEditorPage extraen su contenedor/apertura existentes: mismos márgenes, navegación glass y cover→stagger, fuente visual del botón y retorno. Registrar perdido/encontrado desde Reportar o+ usa esa misma transición; todos los campos, fotos, instrucciones y acciones participan del timeline existente, sin reiniciarlo por edición/teclado/selección. PhotoAddTile y SizeChoiceSelector comparten las implementaciones aprobadas; Encontrados conserva tamaño/sexo/custodia opcionales y los contratos del reporte. Listados usan cabecera/grupo de contenido con entrada compartida, sin count por registro. No se altera el panel de ficha inmersiva solicitado en ADR-030. Véase [ADR-031](../decisiones/031-casos-reutilizan-ui-mascotas.md).

Validación local: suite completa309 pruebas aprobadas;8 regresiones nuevas repetidas tras reforzar el descarte en tamaños390×844/320×350 texto2 y movimiento reducido. Renders revisados en build/ui-preview/case-creation. Pendiente revisar Android autenticado con fotos/teselas reales; la aprobación visual no cierra historias ni confirma backend remoto.


## Fecha y hora independientes — 11 de octubre de 2026

Por solicitud del usuario, los reportes muestran Fecha y Hora en dos inputs con AppFieldSurface, lado a lado en tamaño normal y apilados con texto ampliado. EventDateTimeFields se comparte entre perdidos/encontrados, con calendario y reloj separados. EventDateTimeDraft conserva selecciones parciales en el estado del ViewModel: elegir una no inventa la otra; el timestamp existe solo con ambas y cambiar una conserva la otra. Las operaciones bloqueadas por envío/respuesta ambigua siguen sin admitir cambios. Valores existentes preservan UTC/segundos hasta una edición explícita. Validación, shake/toast y entrada por stagger conservados. [ADR-032](../decisiones/032-fecha-hora-independientes-casos.md).

Edición revisada: casos publicados todavía no tienen contrato/caso de uso/RPC de actualización ni ruta de edición. Editar reporte modifica solo el borrador antes de publicar. Recomendación propuesta: permitir al autor corregir información de casos abiertos, con versionado/historial y misma ficha; alcance todavía no aprobado ni implementado.


## Consistencia de formularios perdido/hallazgo — 11 de octubre de 2026

Corrección explícita del usuario tras detectar controles extra en hallazgo. Se retiran Latitud/Longitud, Usar coordenadas, lectura numérica del punto, Recuperar foto interrumpida y el acceso permanente Mis encontrados dentro del formulario. CaseLocationFields de core compone ambos formularios con la misma selección en mapa, instrucciones de privacidad, referencia privada, invalid/shake y stagger; solo cambia el título del suceso y los callbacks del ViewModel. Coordenadas continúan internas, sin nueva captura numérica ni GPS. Fecha/hora siguen compartidas por ADR-032. Fotos usan la misma etiqueta pública y galerías/controles compartidos.

Se conservan las diferencias propias del producto: perdido elige mascota/fotos registradas; hallazgo describe y fotografía una mascota sin dueño conocido y permite custodia opcional. Consultar la lista permanece solo ante envío ambiguo, igual en ambos recorridos. La API de recuperación de fotos permanece para el ciclo de vida existente, sin botón técnico permanente ni afirmación de recuperación automática nueva. [ADR-033](../decisiones/033-formularios-reportes-consistentes.md).

Validación:50 pruebas de reportes, entrada real, preview, arquitectura y consistencia aprobadas; análisis sin incidencias. Las8 pruebas de creación verifican controles retirados ausentes, uso del bloque común, punto del mapa entregado al estado y ausencia de coordenadas visibles, tamaños390×844/320×350 texto2 y movimiento reducido. Capturas regeneradas y revisadas; no acreditan fotos/teselas reales. Revisión Android pendiente.


## Nuevo significado de búsqueda y aviso — 11 de octubre de2026

Por instrucción del usuario, Mascota perdida admite Mi mascota u Otra mascota posiblemente perdida. Mascota encontrada avisa en una búsqueda abierta con La vi o La encontré y está conmigo, sin cerrarla. Desde ficha se vincula automáticamente el aviso; solo el autor confirma Ya fue recuperada. Se conservan UI de Mascotas, coordenadas privadas/zonas públicas y órdenes estables. Aviso admite foto opcional; búsqueda comunitaria exige fotos. Registros anteriores siguen como Reporte anterior, sin reclasificación automática. [ADR-034](../decisiones/034-busquedas-y-avisos-vinculados.md) y [ficha](busquedas-y-avisos.md).

Cambio de alcance autorizado: HU-05/RF-05 y HU-06/RF-06; se adelantan partes app de HU-10/RF-11 y confirmación de HU-13/RF-07. No se cierran historias ni se entrega web/QR, moderación completa, push o exploración/paginación de HU-07. Fuentes062–065/plan018, migración generada y probada localmente; activación remota/Android y concurrencia multiconexión pendientes.


Selección Mi mascota/Otra mascota corregida: misma pantalla, selector persistente y borradores independientes conservados durante la visita, sin navegación ni nueva consulta al alternar. Salir revisa ambos borradores; no confirma descarte por seleccionar. Cambio inmediato de cuerpo, sin transición entre opciones por instrucción del usuario. [ADR-035](../decisiones/035-alternar-origen-sin-recargar-formulario.md); evidencia en ESTADO, Android real pendiente.


## Un único formulario — 12 de octubre de 2026

Mascota a reportar sustituye Mi mascota/Otra mascota como pestañas. Elegir una ficha usa sus datos/fotos; No está en mis mascotas pide descripción sin registrarla como propia. Un único bloque fecha/hora/lugar/referencia conserva lo escrito al cambiar el origen, manteniendo datos/fotos de cada mascota separados. Vista previa/publicación y privacidad existentes. [ADR-038](../decisiones/038-formulario-unico-mascota-perdida.md) y [ficha conjunta](busquedas-y-avisos.md); Android remoto pendiente.

## Búsqueda del lugar —20/10/2026

Reportar añade el [buscador compartido](ubicaciones-buscador.md) antes del mapa,
también para pérdida comunitaria. Elegir sugerencia de Perú marca/centra el punto
privado, ajustable después en mapa. Búsqueda opcional, referencia independiente
y mapa libre. Sin SQL/permisos nuevos;24 pruebas places/arquitectura/creación
aprobadas. Android pendiente. [ADR-107](../decisiones/107-busqueda-reportes-y-sugerencias-peru.md).


23/10, HU-15.1: el editor conserva un borrador local por cuenta/contexto, con
UUID y evidencia, recuperación sin red y conservación al salir. Comandos ambiguos
se retoman sin editar su contenido. [Recorrido, persistencia, reglas y validación
pendiente](borradores-locales.md), ADR-131. No activa cola automática ni caché
de fichas. La demo Android de reinicio sin red sigue pendiente.


23/10, HU-15.2/ADR-132: las confirmaciones de Publicar/Enviar pasan por la
[cola persistente de envíos](envios-pendientes.md), con estados veraces, UUID/payload
originales y recibo durable. App activa reintenta transitorios; rechazo/conflicto
requiere acción explícita. Un recibo validado tardío actualiza el editor; un
timeout no inicia otra petición mientras el intento original sigue activo.
Descarte respeta reclamación y autorización remota de encontrado. Validación
Android/Supabase real pendiente; no certifica cierre de esta historia.
