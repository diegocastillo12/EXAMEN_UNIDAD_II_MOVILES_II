# Casos encontrados — HU-06 / RF-06 / issue #6

23/10, HU-14.2: con034 activo, publicar un nuevo aviso vinculado respeta los
[bloqueos entre cuentas](bloqueos-usuarios.md). Un bloqueo en cualquier dirección
rechaza el envío en SQL con toast específico y borrador conservado. Recibos de
envíos anteriores e historial mantienen sus permisos. Activación034/demo pendientes.

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

**Auditoría de seguimiento18/10:** HU-06/#6 en Done conforme al alcance aprobado ADR-034 de búsqueda comunitaria/avisos vinculados, implementado e integrado.014 reportado y flujos posteriores consumen el contrato. La auditoría no crea casos ni atribuye propietario/cierre a un aviso.

Ampliación del16 de octubre: marcador glass superior derecho para Guardar caso/Quitar de guardados, compuesto por router con [saved_cases](casos-guardados.md). Origen found incluye comunitarios/avisos/anteriores sin ampliar permisos. Requiere020; formato/análisis sin incidencias, sin pruebas ejecutadas ni activación remota. [ADR-050](../decisiones/050-casos-guardados-por-cuenta.md).

Ajuste del15 de octubre: texto visible Zona/Zonas pasa a Ubicación/Ubicaciones, incluidas indicaciones de privacidad. No cambian precisión pública, campos, permisos ni datos. Formato/análisis; sin nuevas pruebas por instrucción del usuario. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

Implementación local en `feature/found-pet-cases`. No equivale a historia cerrada ni a despliegue remoto.

## Qué hace y recorrido

Inicio → Reportar → Mascota encontrada abre Reportar hallazgo. No consulta mascotas propias ni exige registrar un perfil. Se eligen rasgos, especie, fotos, fecha/hora y punto manual; luego se revisa la vista previa pública y se publica. Solo una confirmación autorizada abre Caso publicado → Ver ficha pública. Reportar → Mis encontrados permite reabrir publicaciones y descartar envíos pendientes tras confirmar la retirada de sus fotos.

## Campos y reglas

| Campo | Regla y exposición |
| --- | --- |
| Especie | Perro/gato/otra obligatoria; otra requiere tipo de 1–40 caracteres. Pública. |
| Tamaño/sexo | Opcionales, inicialmente No lo sé. Públicos si se indican. |
| Rasgos | Obligatorios, 1–200 puntos de código Unicode, contador interior. Públicos. |
| Fotos | 1–3, galería/cámara y recuperación de selección interrumpida; se pueden retirar antes de publicar. Derivados procesados seleccionados públicos. |
| Fecha/hora | Desde 2000, sin superar la actual. Pública. |
| Lugar | Mapa manual o coordenadas; latitud −85..85, longitud −180..180 finitas. Exacto privado; centro de celda de 0.01 grados público. No pide GPS. |
| Referencia | 1–120 caracteres, privada. |
| Custodia | Opcional: Sin indicar / Está bajo mi cuidado / No está bajo mi cuidado. Pública si se indica; no domicilio ni datos de contacto. |

`owner_id` identifica al reportero, no al dueño de la mascota; `pet_id` nulo. Sin nombre/edad inventados ni asociaciones por apariencia. Formulario/vista previa/confirmación con shell compartido, glass flotante, cover/stagger por etapa, errores en toast superior y campos invalid/shake y shimmer solo durante operaciones reales. Consultas con skeleton inicial y contenido conservado en refresh explícito de la misma cuenta.

## Persistencia y permisos

`found_cases`, `found_case_photos`, `found_case_events` y RPC del [patch014](../../database/patchs/014_patch_found_cases.sql), generado desde plan014/SQL052–055. Fotos procesadas por `pet-photo-process` con contexto encontrado en buckets privados propios, sin almacenamiento de originales. Publicación/evento atómicos; UUID estable deduplica reintentos y hash fija bytes de cada foto. SQL comprueba permisos/reglas; no concede DML cliente ni acceso a la tabla de fotos/eventos.

Tabla fuente con columnas permitidas y RLS del reportero. RPC pública separada de datos privados; bytes públicos solo de derivados verificados seleccionados del caso activo. Firma 300 s, con el límite de revocación de ADR-022. Políticas restrictivas resisten políticas permisivas adicionales. El procesamiento de mascotas existentes conserva su contrato.

## Errores, borradores y reintentos

Antes del envío se conservan campos/fotos en memoria. Validación no publica. Error ambiguo congela UUID/metadatos/bytes y bloquea doble envío/edición; reintentar confirma exactamente el mismo comando. Validación rechazada permite corregir sin perder datos. Sesión/disposición ignoran respuestas tardías; cambio de identidad oculta datos anteriores.

Draft remoto nunca se muestra como publicación. Para salir después de una tentativa, se comprueba que siga siendo draft, se retiran archivos y se confirma ausencia antes de marcar el reporte descartado. Se conservan tombstones privados que impiden reactivar el UUID y permiten limpiar bytes tardíos. La RPC de lista oculta descartados limpios; si un worker deja archivos después del descarte, muestra limpieza pendiente y permite repetir la retirada. Error conserva pantalla y permite reintentar. Un activo no puede descartarse. Mis encontrados ofrece limpieza con confirmación para drafts que sobrevivieron al cierre del proceso. Fotos retiradas por corrección se limpian antes del siguiente envío. Límites: 10 drafts por cuenta y 30 reservas de foto por draft, incluidas retiradas. No hay limpieza automática ni recuperación de metadatos locales tras cerrar la app; persistencia offline corresponde a HU-15.

## Dependencias y activación

Requiere Auth/onboarding, patch013 aplicado y procesamiento012 operativo. Aplicar patch014 completo y actualizar el código del endpoint existente `pet-photo-process` en el servidor self-hosted; [CONFIGURACION](../CONFIGURACION.md) explica el recorrido. SQL solo no activa las fotos de encontrados. Mantener buckets privados. Sin Edge Function nueva, push, QR ni PostGIS. [ADR-022](../decisiones/022-publicacion-casos-encontrados.md) registra decisiones y límites.

## Validación

Pruebas locales Flutter/SQL/Deno y renders registrados en [ESTADO](../ESTADO.md). Cubren ausencia de mascota propia, campos, doble envío, respuesta ambigua, sesión tardía/recuperación, privacidad, descarte, navegación, SDK y procesamiento real de bytes. No se aplicó patch014 ni se actualizó el handler remoto. Pendiente demo Android/Supabase: publicar con cuenta sin mascotas, reiniciar/reabrir, denegar GPS/cámara, reintentar con pérdida de respuesta, concurrencia independiente, A/B/anónimo, bytes privados/públicos y limpieza real de ambos buckets. No cerrar #6 por evidencia local.

## Confirmación y corrección del 10 de octubre

El usuario confirma ejecución de patch014 y subida/extracción del paquete de funciones en el servidor. Evidencia informada, sin comprobación remota por el agente; reinicio de functions y publicación autenticada no confirmados. El incremento visual mueve validación, publicación/confirmación, consultas/refresco e imágenes fallidas al toast superior, sin mensajes debajo de campos/acciones; conserva borrador, marcas de campo y reintentos. Véase [ADR-023](../decisiones/023-feedback-reportes-toast-superior.md). Actualización Android y demo pendientes.


## Reutilización visual — 10 de octubre de 2026

Confirmaciones delegadas al diálogo completo confirmActionDialog de core, con acciones de geometría/alineación y adaptación compartidas, sin layouts propios. En reportes, terminar carga conserva la entrada del skeleton y no dispara cover/stagger nuevos; vista previa y confirmación conservan su transición. Validación local y límites en ESTADO; no cambia persistencia/permisos ni cierra la historia remota.


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

Mis reportes reutiliza la implementación de tarjetas, selector, cabecera/botón+ y swipe extraída de Mis mascotas a core. Abiertos/Resueltos filtra estados reales; portada de los derivados seleccionados/disponibles, con icono si no hay imagen. Tarjeta devuelve su posición antes del diálogo compartido; cancelar conserva datos, confirmar elimina mediante caso de uso/servidor. Resultado/error en toast superior; shimmer/bloqueo durante la operación y error permite reintentar sin quitar el caso. Casos resueltos se consultan solo por su dueño. Encontrados pendientes conservan Descartar y superficie compartida; no se muestran como publicados.

Persistencia: migración016/fuentes057–060. deleted_at oculta lista/publicación conservando ID/historial; perdido activo libera el contador atómicamente una vez, sin borrar mascota/fotos ni perder historial. Found activo/resuelto admite la misma retirada, sin convertir descarte de borrador en eliminación publicada. Cambio de cuenta ignora resultados anteriores y bloquea dobles envíos. URLs ya firmadas mantienen TTL300s; no hay purga física en esta operación. Véase [ADR-026](../decisiones/026-listas-casos-componentes-compartidos.md).

Validación local en ESTADO: tarjetas/selector/diálogo con390×844 y320×350 texto2, permiso dueño/otra cuenta/anon, reintentos, conservación y publicación posterior. Pendiente aplicar016 y probar Android autenticado con fotos reales; funcionalidad implementada localmente, sin cierre de historia ni confirmación remota.

## Corrección de consistencia — 11 de octubre de 2026

Fotos usan galería compartida y mapa/fotos muestran invalid/shake; feedback solo en toast. Publicar/descartar acotan90s global y30s por petición, conservan el draft e IDs ante respuesta ambigua. SQL061/migración017 añade límite5s de espera de bloqueos; activación remota pendiente.

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


La vi/La encontré se reporta desde ficha de búsqueda abierta, con vínculo fijo. Retirado el acceso genérico de Reportar y dropdown de casos; ReadRecoverySearch solo lee el destino concreto. El listado histórico conserva consulta/descarte y + abre Mascota perdida. [ADR-037](../decisiones/037-avisos-desde-ficha.md). Sin SQL nuevo; Explorar/HU-07 y Android real pendientes.

## Búsqueda del lugar —20/10/2026

Avisos de hallazgo reutilizan el [buscador compartido](ubicaciones-buscador.md)
antes del mapa. Sugerencias de Perú; elegir centra/marca el punto privado, con
ajuste manual posterior. No rellena la referencia ni exige buscar; mapa libre,
sin SQL/permisos nuevos.24 pruebas places/arquitectura/creación aprobadas;
Android pendiente. [ADR-107](../decisiones/107-busqueda-reportes-y-sugerencias-peru.md).


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
