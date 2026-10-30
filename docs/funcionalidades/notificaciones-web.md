# Bandeja de alertas y cabecera de cuenta web

## Aceptación del usuario — 25/10/2026

El usuario confirma que cuenta/acceso, difusión, seguimiento y recuperación ya
fueron validados y solicita actualizar el seguimiento. Se registra su aceptación,
sin atribuir al agente una nueva demo ni un log individual de cada escenario.
Esta nota sustituye los pendientes de validación correspondientes de las notas
históricas; no activa FCM ni acredita baja/exportación sin implementar.

Bandeja/seguimiento aceptados por el usuario; #40/#41 Done. No equivale a seguimiento/preferencias web nuevos ni activa push.

21/10, corrección de movimiento [ADR-124](../decisiones/124-paridad-animaciones-mobile-web.md):
Perfil/Alertas expanden desde el control real320ms y retornan260ms con las curvas
y fases móviles. GlassDialog conserva contenido durante salida y libera foco/
scroll/animaciones en cierre, resize, preferencia y desmontaje. Prueba normal
de fotogramas en check-dialog-motion-browser.mjs; no basta el QA reducido previo.

Implementación local21/10/2026 por petición del usuario. HU-12.2/RF-17/issue #41
(bandeja); cabecera y consulta de perfil HU-01.7/RF-01/issue #23. No implica
cierre nuevo de historias ni paridad completa con Android.

## Qué hace y recorrido

Inicio, Explorar, Mis mascotas y Reportar muestran campana Alertas, avatar
circular y salida de sesión. El avatar abre Tu cuenta con datos reales y foto
almacenada o iniciales; no publica perfil ni permite editarlo en este incremento.
La campana abre un panel glass con alertas de la cuenta compartidas con móvil.
Las lecturas comienzan al abrir, sin bloquear Inicio ni gestión. Cada apertura
actualiza la primera página. Muestra título/fecha/hora local y estado Sin leer;
Marcar leída persiste y cambia la UI solo tras confirmación. Ver más alertas
pagina; Actualizar recarga conservando contenido confirmado. No hay contador
global ficticio; el punto azul solo indica alertas sin leer ya consultadas.

GlassSurface reproduce acabado polished de móvil en tarjetas y controles.
GlassDialog concentra top layer nativo, backdrop, cierre exterior/Escape/X,
foco y bloqueo/limpieza de scroll. Responsive y texto ampliado conservan acciones.
Las páginas componen NotificationBell por slot para respetar fronteras de features.

## Reglas, persistencia y permisos

ReadInbox y MarkNotificationRead consumen InboxRepository; InboxViewModel
coordina estado, duplicados, descarte al desmontar y errores seguros. HTTP y
servidor tienen repositorios/DTO separados; InboxSource encapsula las RPC
list_notifications y mark_notification_read ya versionadas en plan027.
IDs/cursor se mantienen como cadenas bigint, sin perder precisión en JavaScript.
Servidor valida sesión, cuenta completada y X-Account-Actor en cada operación;
las RPC autorizan por auth.uid(). POST conserva Origin/Fetch Metadata/limitación
global. Nunca se utiliza un owner recibido del cliente para elegir notificaciones.
Proyección web solo id/título/fecha/leído; no expone owner/case_id/contactos.

Avatar usa ReadAccountAvatar y el repositorio/fuente de acceso: ruta privada fija
del actor validado, JWT solo servidor, JPEG máximo2MiB, respuesta no-store y
sin URL de Storage en cliente. Falta de foto conserva iniciales; no bloquea
perfil. No usa fotos externas de proveedores sociales ni altera datos guardados.

## Errores y reintentos

Skeleton inicial, shimmer en refresh/operaciones, etiquetas estables. Toast
superior para error, con reintento real; fallo inicial nunca equivale a vacío.
Fallo de página conserva cursor/items y Ver más reintenta esa página. La lectura
es idempotente y un fallo no anticipa confirmación. Expirar/cambiar identidad
descarta items; desmontaje libera listeners y rechaza respuestas tardías.

## Dependencias y alcance

Requiere sesión web y plan027 ya confirmado aplicado por el usuario; sin SQL
nuevo. Foto opcional requiere profile-avatars existente. No incorpora push del
navegador, seguimiento/preferencias web, edición de perfil ni Abrir caso desde
notificación: no inventa enlaces QR o permisos sobre casos privados.
La autorización y disponibilidad del caso siguen en sus recorridos existentes.

## Validación

Unitarias cubren bigint/validación, DTO privado, vinculación HTTP/JWT,
deduplicación, confirmación real, errores/paginación, descarte por identidad
y avatar autorizado. Integración con servidor de producción y fixtures cubre
anónimo/otro actor/cuenta, origen, onboarding, lectura idempotente, error frente
a vacío y foto privada/faltante. QA Chrome en check-inbox-browser.mjs cubre
cabecera1440/390/320/texto200%, cuenta/Escape/scroll/foco, glass, carga inicial,
lectura persistida, fallo/reintento/paginación, cuenta distinta y avatar/iniciales.
Capturas en apps/mobile/build/ui-preview/web-inbox; evidencia final en ESTADO.
Pendientes backend real, Safari/Firefox/dispositivos físicos y revisión del usuario;
sin despliegue, push ni garantía de notificaciones nuevas en tiempo real.
