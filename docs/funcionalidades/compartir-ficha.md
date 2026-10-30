# Compartir ficha pública

25/10, corrección solicitada: Denunciar conserva el panel montado detrás y abre
el formulario del mismo caso desde el círculo gris real (posición, radio28 e
icono26). Reutiliza `OriginPageSource`, `entityEditorPage` y
`OriginPageTransition`: apertura320ms/retorno260ms, easeInOutCubic, identidad
hasta45% y contenido desde65%; movimiento reducido inmediato. Al volver se
recupera el mismo panel y su scroll, sin volver a pulsar Compartir. El origen
se captura antes de navegar y se bloquea la apertura duplicada. La composición
sigue en router; no cambian autorización, envío, borrador ni recibo de denuncia.
Sustituye la descripción anterior que cerraba el panel al denunciar.

23/10, por instrucción del usuario, [ADR-133](../decisiones/133-acciones-de-ficha-y-navegacion-glass-compartida.md):
la cabecera conserva únicamente Volver y Compartir. Favoritos, Seguir/Dejar de
seguir y Bloquear/Desbloquear pasan al panel «Compartir ficha», junto a Descargar/Denunciar: círculos grises56, iconos26, sin texto visible,
con tooltip y semántica. Wrap centra los controles y permite varias filas. Las opciones mantienen
sus ViewModels, permisos, confirmaciones, shimmer, toast y reintentos. Seguir
conserva su disponibilidad anterior por tipo de caso y bloqueo no se ofrece
contra la propia cuenta. El contacto permanece en el cuerpo de la ficha.

GlassNavigationBar concentra el inset superior seguro +4 y márgenes simétricos24,
fuera del scroll; lo consumen CasePublicScreenShell y EntityScreenShell. Se retira
el hueco de Guardar en cabecera. Esto sustituye las notas anteriores de tres
controles; no implica migración de todas las pantallas ni cambios en QR/web.
Composición por slots desde router, sin imports de presentación entre features.
No cambia SQL, persistencia, privacidad ni los dos recorridos de avistamiento.

Validación de este incremento y límites en [ESTADO](../ESTADO.md). Pendiente
revisión en dispositivo Android y aprobación visual del usuario.

Implementado localmente20/10 según [ADR-115](../decisiones/115-panel-compartir-ficha-publica.md).
Ampliación explícita de HU-07/HU-08 y RF-08/13/37; sin issue nuevo ni cierre de historia.

## Qué hace y recorrido

Desde una ficha de perdido/encontrado, Compartir en cabecera abre un panel blanco
opaco. Copiar enlace (azul/icono blanco), WhatsApp y Facebook aparecen arriba;
debajo están los círculos grises Descargar y Denunciar, solo iconos con tooltip.
No hay X ni glass en el panel. Se cierra con gesto hacia abajo, toque fuera o
Atrás. La cabecera adapta el título en pantalla pequeña/texto ampliado, sin
solapar volver/compartir/guardar. Guardar sigue siendo una operación independiente.

Copiar confirma solo tras escribir en Clipboard. WhatsApp/Facebook abren el
destino externo con la URL precompuesta; el usuario elige si envía/publica y
a quién. No se confirma entrega. Descargar genera el PDF público con QR y abre
la impresión/Guardar como PDF del sistema; cancelar conserva la posibilidad de
reintento. Denunciar abre desde su botón el formulario real del mismo caso,
conservando el panel detrás durante apertura, edición y retorno.
En fichas públicas, esta entrada sustituye el botón largo de denuncia del cuerpo;
otras entradas existentes de denuncia permanecen.

## Reglas, datos y permisos

Copiar/compartir/descargar exigen sesión y búsqueda activa visible con foto pública
procesada y disponible en Storage. La RPC comprueba además que el lector QR
devuelva active. Orígenes soportados por el QR actual: perdida propia/comunitaria
y encontrado independiente anterior. Avisos vinculados/custodia sin contrato QR,
casos cerrados/ocultos/eliminados o sin foto no inventan enlaces o documentos.
Denunciar mantiene su autorización de servidor y su formulario existente.

Una URL opaca por origen+caso en case_public_links; crea el registro con el dueño
real, aun si quien comparte es otro lector. No expone tabla, otros perfiles,
contacto, coordenada exacta, referencia privada o credenciales. Revocación nunca
se deshace por compartir/reintentar. La RPC antigua de cartel conserva el permiso
del autor. El PDF reutiliza el saneamiento y la plantilla pública existente.

## Estados, errores y reintento

Skeleton breve al obtener sesión y shimmer solo para la operación activa.
Bloquea acciones simultáneas y nuevas aperturas duplicadas del panel. Errores y
resultados van al toast superior; no hay spinner/textos de carga o validación
debajo de las opciones. Reintentar usa el mismo caso/enlace estable. Se consulta
otra vez revisión/visibilidad/sesión antes de la salida; si cambió, no se entrega
el documento anterior. Cerrar elimina estado/toasts; resultados tardíos de otra
cuenta se descartan. Las aplicaciones externas pueden requerir login y sus
resultados no prueban recepción/publicación ni guardado físico del archivo.

## Dependencias y activación

case_posters organiza entidades/contrato/caso de uso/ViewModel/estado/repositorio/
fuentes de compartir. Composición en router, bootstrap/main; Clipboard inyectado
desde bootstrap sin Flutter en data. Reutiliza PDF/Printing, url_launcher y el
contrato QR; no añade paquetes, cuentas sociales o secretos al cliente.
Requiere las configuraciones públicas existentes PUBLIC_CASE_WEB_URL y
PUBLIC_CASE_WEB_READY. No se vuelve a declarar la web QR no disponible como un
bloqueo genérico: la nueva capacidad de servidor que falta activar es032.

Fuentes110–111, plan032, migración20261020003200_case_sharing.sql y
database/patchs/032_patch_case_sharing.sql generados con Build-Migration,
Build-CaseSharingPatch y Build-RunAll. Aplicar después de031 cuando se autorice.

## Validación

Corrección25/10:8 regresiones con GoRouter y formulario real verifican origen
gris56/radio28, crecimiento/retorno, misma instancia/scroll del panel, reapertura
y Atrás posterior. Perdidos/encontrados,390×844 y320×600 con texto200%, normal
y reducido. Suite pertinente38 aprobadas, análisis lib/test sin incidencias;
capturas de fases en `apps/mobile/build/ui-preview/share-report-origin` con
repositorios de prueba. Detalles y límites en ESTADO; Android físico pendiente.

Pruebas de repositorio comprueban URL opaca/configuración, PDF solo público y
revalidación; ViewModel verifica doble envío y cambio de cuenta. Layouts390×844
y320×350/texto2, movimiento normal/reducido, ausencia de X/etiquetas inferiores,
alineación de iconos, cierre por gesto/Atrás y denuncia real. Renders en
apps/mobile/build/ui-preview/case-sharing con fixtures y teselas simuladas.
SQL local/PostGIS comprueba lector ajeno, permiso de autor intacto, idempotencia,
revocación, cierre, moderación y repetición de migración/bundle. Resultados en
ESTADO. Pendientes activación032, prueba física Android de Clipboard/WhatsApp/
Facebook/guardar/cancelar y comprobación del enlace compartido en navegador real.
