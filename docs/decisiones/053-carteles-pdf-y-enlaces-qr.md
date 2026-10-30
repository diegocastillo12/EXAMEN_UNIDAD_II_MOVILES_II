# ADR-053: carteles PDF y enlaces QR estables

Fecha:16 de octubre de2026, America/Lima. Estado: implementado localmente, activación pendiente. HU-08.1 / issue#34 y HU-08.2 / issue#35, RF-08,37. Rama:feature/pet-poster-qr. El usuario indica que no se necesita generar APK todavía y autoriza continuar S4.

## Decisión

case_posters entrega generación local de un PDF A4 con foto pública principal, nombre/especie/rasgos, fecha y QR opaco. Desde fichas de búsquedas abiertas propias se accede a Cartel con QR. Incluye búsquedas de mascota registrada, comunitarias y encontrados independientes anteriores; los avisos vinculados no generan carteles separados. El servidor valida autor/estado incluso ante una ruta manipulada. No se añade teléfono, domicilio, punto exacto, referencia privada, documentos, salud o custodia al PDF.

El usuario elige https://entrehuellas.kormind.com como base; contrato de ficha `/c/<slug>`. El dominio responde por HTTPS, pero GET/ de esta revisión devuelve404. La ficha anónima y su estado vigente pertenecen a HU-09; esta entrega no los simula ni publica una web. PUBLIC_CASE_WEB_URL tiene esa base por defecto; PUBLIC_CASE_WEB_READY permanece false hasta que el entorno disponga de una ficha pública funcional. Generar/exportar exige HTTPS y activación explícita, antes de crear enlaces o abrir acciones nativas. No se imprimen enlaces de prueba en producción.

## Fronteras y reutilización

Dominio declara PosterCase/Content/Document, fallos, contrato y casos de uso GenerateCasePoster/ExportCasePoster sin Flutter/Riverpod/SDK. Presentation mantiene estado, ViewModel autoDispose, pantalla y traducción de fallos; usa EntityScreenShell, navegación glass, reveal, LoadingShimmer y toast existentes. Las fichas reciben un slot desde router, sin imports de presentación entre funcionalidades. Bootstrap/main inyectan adaptadores y config.

Data encapsula Supabase/Storage, DTO, plantilla binaria PDF y servicios nativos. La plantilla del artefacto exportable (no un widget de pantalla) usa pdf3.12.0; sus fuentes Roboto se incluyen con licencia para evitar descargas durante generación. Los textos de feedback y controles permanecen en presentation. Se descarga exclusivamente una rendition procesada/autorizada y se vuelve a codificar su JPEG sin copiar metadatos al PDF. Nunca se incrustan originales, paths de Storage, URLs firmadas o sesión.

Printing5.14.3 abre Imprimir o guardar PDF, incluida la opción del sistema de guardar como PDF. Share_plus11.1.0 abre la hoja nativa para PDF+enlace o solo enlace. Son versiones compatibles con el SDK actual, sin actualizar Flutter/Gradle. Cancelación no se anuncia como éxito; resultado nativo desconocido pide confirmar en la app elegida. No se afirma entrega al destinatario. El PDF queda en memoria durante la visita; el plugin gestiona el temporal público de compartir. No se añade caché offline persistente.

## Persistencia y permisos

Fuentes077–079/plan022: case_public_links privada con RLS y sin grants de tabla para anon/authenticated; origen+UUID es único. Slug aleatorio de64 caracteres hexadecimales (dos UUIDv4 independientes sin guiones), distinto de la identidad de la cuenta/caso; no es un token de sesión. Se conserva entre reintentos y al cerrar un caso, para que HU-09 pueda resolver su estado vigente. revoked_at está reservado para revocación controlada posterior y una fila revocada nunca se reactiva con Generar.

RPC prepare_case_poster solo authenticated, SECURITY DEFINER con search_path vacío, límites de bloqueo/consulta y locks de fila: valida propietario, activo, no borrado, tipo raíz y foto procesada seleccionada. No cambia el caso. Inserción ON CONFLICT conserva el enlace frente a reintentos; devuelve una proyección explícita y una revisión del contenido imprimible. Repetir generación/abortar exportación no publica ni resuelve casos. El read_recovery_report versionado añade únicamente can_generate_poster para mostrar el acceso al autor de casos anteriores.

Antes de guardar/compartir se reconsulta autorización/estado/enlace/revisión; un cambio exige regenerar. No puede retirarse un archivo impreso o ya entregado: el pie indica consultar la ficha para el estado vigente. El futuro lector anónimo debe revalidar revocación y visibilidad en cada lectura; esta migración no concede ejecución anónima ni acceso público a bytes de Storage.

## Activación y validación

Build-Migration/Build-CasePostersPatch/Build-RunAll generan migración022, patch022 y run_all sin modificar SQL aplicado anterior. No se despliega el patch ni se genera APK por este incremento. La ruta móvil está protegida por el flujo de sesión/onboarding.

Pruebas locales: permisos entre autor/otra cuenta/anónimo, repetición de patch/bundle, identidad por origen, principal verificada, revocación/estado y exclusión de campos privados; Dart de configuración, URL estable, fallos/reintentos, cuenta y exportación; PDF de ambos orígenes y caso extremo renderizado con Poppler. QR de los tres PDFs decodificado automáticamente; nombres/rasgos largos conservan todo su texto. Pantalla revisada normal/pequeña/texto2/movimiento reducido. Evidencia final en ESTADO.

Pendientes: aplicar022 en desarrollo, implementar/activar HU-09 en el dominio indicado, escanear desde otro teléfono e impresión física y comprobar guardar/compartir/cancelar en una próxima ejecución nativa que incorpore los plugins. No se cierran HU-08/09 por evidencia local.
