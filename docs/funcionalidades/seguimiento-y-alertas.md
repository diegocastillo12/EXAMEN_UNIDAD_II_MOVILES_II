# Seguimiento y alertas

## Aceptación del usuario — 25/10/2026

El usuario confirma que cuenta/acceso, difusión, seguimiento y recuperación ya
fueron validados y solicita actualizar el seguimiento. Se registra su aceptación,
sin atribuir al agente una nueva demo ni un log individual de cada escenario.
Esta nota sustituye los pendientes de validación correspondientes de las notas
históricas; no activa FCM ni acredita baja/exportación sin implementar.

Seguimiento #40 y bandeja #41 aceptados y cerrados/Done. HU-12 sigue abierta solo por #42/FCM pospuesto; no activar emisor ni cron.

21/10: [bandeja web](notificaciones-web.md) desde la campana de cuenta, con
consulta, paginación y lectura persistida sobre las RPC de plan027. Sin nuevo
SQL, push/seguimiento/preferencias web ni cierre de historias; evidencia local
y límites en su ficha y ESTADO.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Refinamiento móvil20/10/2026:** la campana entrega sus límites reales respecto
al Navigator y su identidad visual mediante OriginPageSource. Alertas reutiliza
entityEditorPage/OriginPageTransition: expansión320ms y retorno260ms al origen,
inmediatos con movimiento reducido. Se conserva la sección de Inicio subyacente.
La bandeja confirmada vacía usa CollectionEmptyState de Mis mascotas/Explorar,
con campana neutra88px, título centrado y orientación sobre casos/ubicaciones y
preferencias. Skeleton y error no se presentan como vacío; reintento y refresh
conservan sus acciones. Solo presentación de HU-12.2/#41, RF-17,18, sin cambios
de persistencia, permisos, activación ni alcance.

Validación local:40 pruebas de notificaciones/navegación/Inicio/arquitectura y
consistencia aprobadas; cuatro regresiones comprueban carga→vacío, error y
reintento en390×844 y320×350/texto2 (movimiento reducido en este último).
La navegación comprueba geometría real, expansión intermedia y contracción.
Análisis Flutter sin incidencias. Revisión Android física pendiente.

**Auditoría de seguimiento18/10:** HU-12/#12 y #40/#41 siguen In progress:027 confirmado, implementación local probada, pero main todavía no contiene notifications y falta demo del evento/bandeja actual. FCM/Firebase #42 sigue pospuesto; no es el bloqueo de preferencias ni de bandeja.

HU-12.1/#40, HU-12.2/#41 y HU-12.3/#42; RF-16,17,18. Implementación local
Android/SQL/Edge.027 aplicado según confirmación del usuario; historias abiertas,
demo real pendiente, sin inspección remota independiente.

**Alcance vigente:** HU-12.3/#42 (FCM/Firebase) pospuesta por el usuario18/10/2026.
Se entrega seguimiento/bandeja con Supabase, sin SDK/plugin Firebase, permisos
push ni botón para registrar el teléfono. La preferencia anterior de teléfono
solo guarda una elección futura y lo indica expresamente. Contratos genéricos,
emisor y outbox preparados permanecen inactivos; no se activa Edge ni cron.
Las descripciones push inferiores son referencia diferida, no capacidad activa.
[ADR-068](../decisiones/068-posponer-fcm-firebase.md).

## Qué hace y recorrido

- Ficha disponible → Seguir caso / Dejar de seguir. Separado del marcador Guardados.
- Perfil → Ubicaciones de interés → Seguir zona / Dejar de seguir, sobre zonas reales.
- Campana de Inicio → Alertas → bandeja paginada → Marcar leída / Abrir caso.
- Desde Alertas se abren preferencias existentes; las novedades se consultan en la bandeja.

## Reglas, campos y persistencia

Seguimiento por cuenta/origen/UUID, versión y UUID de orden. Sin activación
automática para guardados o zonas previas; sin GPS continuo. Recepción depende
de enabled, tipo y canales de las preferencias. Zonas comparadas en servidor
con ubicación pública aproximada; coincidencias se deduplican.

Publicaciones pertinentes notifican seguidores de zonas. Novedades de casos
(avistamientos, avisos vinculados y revisión) y cierre notifican responsable y
seguidores del caso, según preferencias. No se generan nuevas alertas de
búsqueda cuando el caso está cerrado. Instalación no fabrica historial.

Notificación y trabajo push se guardan juntos. Push solo también conserva un
recibo en bandeja. Sin datos privados en títulos/payload: nunca coordenadas,
comentarios, fotos, motivos o datos de cuenta. Bandeja pagina20, máximo50 por RPC,
cursor ID descendente; lectura persistida por cuenta e idempotente.
Abrir consulta autorización actual; caso retirado puede no estar disponible.

Tablas de suscripciones/órdenes/notificaciones/dispositivos/outbox con RLS y
sin grants directos. RPC de cliente usan auth.uid(); claim/finish solo service_role.
Firebase no sustituye Supabase Auth. Token limitado a10 activos por cuenta,
reasignado al cambiar cuenta y desactivado al recibir UNREGISTERED.

## Errores y reintentos

Toast superior compartido, skeleton inicial y shimmer en operaciones/refresh;
contenido conservado solo para la misma identidad. Reintentar consulta tras error.
No confirmar seguimiento ni leído antes del recibo persistido. Respuesta ambigua
repite misma orden; conflicto requiere consulta; cambio de identidad oculta datos.

FCM caído conserva bandeja y trabajo pendiente con backoff. Claim vencido se
recupera, lease obsoleto no confirma otro intento. Revalidación de preferencias,
estado y seguimiento antes de reclamar. Sin dispositivo se difiere1 hora.
Aceptación de FCM no garantiza entrega; se admite repetición del push tras acuse
perdido, sin duplicar bandeja, con tag estable y TTL60s. Detalle en ADR-067.

## Dependencias y activación

HU-02 zonas/preferencias y HU-05/06/10/11;026 ya confirmado por usuario.
027 ya aplicado según usuario; actualizar Flutter y validar seguimiento/bandeja
según [CONFIGURACION](../CONFIGURACION.md). Firebase/Edge/planificador fuera del alcance activo.
No requiere actualizar Nuxt para crear avisos: triggers cubren las escrituras
web/app existentes. Flutter sin Firebase configurado conserva bandeja/seguimiento.

## Validación

Pruebas locales de permisos/deduplicación/páginas/lectura/CAS/leases y proveedor
simulado; ViewModels/arquitectura/navegación y renders390×844/320×350 con texto2.
Resultados definitivos y logs en [ESTADO](../ESTADO.md).
Pendiente: demo hosted con027, dos sesiones concurrentes, Android con permisos/token real,
app terminada, cambio de cuenta/logout offline y FCM caído/restaurado; sin cierre
de issues ni certificación de entrega. Build Android no acreditado por pruebas Dart.
