# Cierre y recuperación

## Aceptación del usuario — 25/10/2026

El usuario confirma que cuenta/acceso, difusión, seguimiento y recuperación ya
fueron validados y solicita actualizar el seguimiento. Se registra su aceptación,
sin atribuir al agente una nueva demo ni un log individual de cada escenario.
Esta nota sustituye los pendientes de validación correspondientes de las notas
históricas; no activa FCM ni acredita baja/exportación sin implementar.

Recuperación aceptada por el usuario; HU-13/#13 cerrada/Done. Los pendientes históricos de demo ya no son bloqueos de aceptación.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Actualización18/10:** el usuario confirma028 aplicado y autoriza pasar a HU-14.1. No se solicita reaplicarlo. Demo real/integración sin nueva evidencia; Firebase/FCM fuera del alcance.

HU-13 / RF-07; issue #13. Implementado localmente en `case_closure` sobre el
cierre anticipado de HU-05/06. Historia abierta;028 confirmado por el usuario, demo remota pendiente.

## Qué hace y recorrido

Ficha propia activa (mascota registrada o búsqueda comunitaria) → Ya fue
recuperada → motivo/evidencia → Confirmar recuperación → confirmación explícita
→ recibo persistido. Desde la ficha resuelta, Ver recuperación consulta ese
recibo. El historial conserva su evento de cierre. Solo el responsable cierra.
El visitante del cartel escanea el mismo QR y encuentra el cierre actualizado,
sin instalar la app ni recibir motivo/evidencia privados.

## Reglas y campos

Motivo obligatorio y evidencia testimonial opcional, ambos textuales, máximo500
caracteres Unicode por campo y contador interior. Sin adjuntos nuevos. Actor y
fecha los fija el servidor. No confundir avistamiento confirmado o custodia con
recuperación: la acción explícita del responsable finaliza la búsqueda.

El cierre bloquea nuevos avisos/avistamientos y revisiones ordinarias, retira
el caso de búsquedas activas y cancela trabajos pendientes de difusión. Conserva
bandeja e historial. Una nueva desaparición es otro caso con UUID nuevo; no
reabre el anterior. Los cierres antiguos se conservan sin motivos inventados.

## Persistencia y permisos

Plan028/fuentes096–098, migración y patch generados. `case_closures` tiene RLS,
sin acceso directo de cliente/servicio. RPC read_case_closure/close_recovery_case
autentican al responsable; no confían en canResolve del cliente. La transacción
conserva orden de bloqueo mascota→caso, actualiza contador/estado/evento/recibo y
cancelación del outbox. UUID único de orden y cierre único por origen/caso.
SQL anterior permanece inmutable; resolve_recovery_search conserva compatibilidad.
QR conserva su contrato público neutro. Detalles en ADR-069.

## Errores y reintentos

Sin éxito optimista. Respuesta perdida congela la misma orden y campos; repetir
recupera el recibo original. Segundo cierre/conflicto ofrece Consultar cierre;
su fallo conserva formulario y reintento. Sin datos privados tras cambio/error
de cuenta; respuestas tardías/disposición no confirman otra identidad. Toast
superior, invalid/shake y shimmer compartidos. La salida con borrador/resultado
ambiguo solicita confirmación. No hay borrador durable offline nuevo (HU-15).

## Dependencias y activación

Requiere027 ya confirmado por usuario; no reaplicarlo. 028 ya aplicado según confirmación del usuario; no reaplicarlo. Actualizar Flutter.
No requiere cambios ni despliegue Nuxt para consumir el estado cerrado del QR.
FCM/Firebase siguen pospuestos según ADR-068; no activar emisor ni cron. Si en el
futuro se activa push, los mensajes ya en tránsito no pueden retirarse; se
cancelan pendientes/leases y se conserva la notificación de cierre.

## Validación y demo pendiente

Resultados y logs definitivos en ESTADO. Evidencia local de permisos, idempotencia,
rollback, QR existente, avistamientos web/app, proyecciones, episodio nuevo,
cancelación/lease y auditoría. Flutter prueba pérdida de respuesta, conflicto,
sesión/disposición y renders390×844/320×350 texto2; navegación desde ficha real
comunitaria. Fixtures no certifican Supabase hosted ni permisos reales Android.

Tras028: dos cuentas y dos sesiones del responsable; guardar motivo/nota, perder
respuesta y reintentar; intentar cierre ajeno y simultáneo; reabrir mismo QR;
rechazar nuevos avistamientos web/app; revisar mapa/listado/historial/bandeja;
publicar otro episodio de la mascota conservando el recibo anterior. Los envíos
push reales no forman parte de esta demo por ADR-068.
