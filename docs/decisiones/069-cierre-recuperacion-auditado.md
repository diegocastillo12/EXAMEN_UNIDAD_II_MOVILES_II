# ADR-069: cierre de recuperación con recibo privado

Actualización18/10:028 aplicado según confirmación expresa del usuario, sin
inspección remota independiente. Se autoriza avanzar a HU-14.1; la demo real
permanece sin evidencia nueva. Firebase/FCM está fuera del alcance.


Fecha: 18/10/2026. Estado: implementada localmente, 028 confirmado aplicado, demo real pendiente.
Trazabilidad: HU-13 / RF-07; issue #13 independiente del número de historia.

## Decisión

Completar el cierre adelantado en ADR-034 mediante `case_closure`, con dominio,
casos de uso, repositorio, DTO/fuente Supabase, providers declarativos y
ViewModel autoDispose. Bootstrap/main inyectan data; app/router compone la ruta
desde las fichas propias y refresca sus consultas. Explorar conserva sus filtros.
No se importa presentación/data entre funcionalidades.

El responsable escribe motivo obligatorio (hasta500 caracteres Unicode) y
evidencia testimonial opcional en texto (hasta500). Son privados; no se añaden
adjuntos ni se publican en QR, mapa o alertas. El formulario usa shell, retorno
glass, cover/stagger, inputs/contadores, shake/invalid, toast, skeleton y shimmer
compartidos. La confirmación muestra el recibo guardado; un cierre anterior sin
recibo se identifica sin inventar motivo o evidencia.

SQL096–098/plan028 añaden tabla privada con RLS y sin grants directos; RPC
autenticadas autorizan al responsable actual en lectura, escritura y reintento.
La orden tiene UUID estable y contenido inmutable. Se bloquea mascota→caso
(o caso comunitario), se cambia estado, actualiza contador de mascota, registra
actor/fecha/motivo/evidencia y evento de historial, y cancela entregas de búsqueda
pendientes en la misma transacción. Otro comando sobre un caso resuelto recibe
cierre; repetir el mismo devuelve el recibo original sin cambiar auditoría.
El UUID reutilizado con otro contenido produce conflicto.

La RPC anterior `resolve_recovery_search` delega al cierre nuevo con el motivo
veraz de su acción afirmativa; conserva su contrato void/idempotente y códigos
de permiso. No se rellenan cierres históricos. La instalación es repetible.

El QR existente consulta estado vigente y conserva su slug. Los contratos
existentes rechazan nuevos avistamientos/avisos en casos cerrados y permiten
crear otro episodio con otro UUID sin reutilizar ni reabrir el caso anterior.
No se amplía la visibilidad de fichas resueltas a terceros; QR devuelve el cierre
neutro y la fecha. No hay nueva administración ni autorización web ficticia.

## Reintentos y límites

Ante respuesta ambigua se congelan UUID/motivo/evidencia y solo se reintenta esa
orden. Conflicto/cierre exige consultar el recibo actual; fallo de esa consulta
conserva borrador y acceso a reintento. Cambio/error de sesión oculta contenido y
descarta respuestas tardías. Salir con borrador o resultado ambiguo requiere
confirmación de salida. Tras reiniciar se consulta el estado del servidor; la
persistencia de borradores offline corresponde a HU-15.

Se conserva la bandeja como historial y el aviso de cierre según preferencias.
Se invalidan leases de envíos de búsqueda pendientes. No puede retirarse un
push ya aceptado/en tránsito; TTL existente60s. ADR-068 sigue vigente: FCM y
Firebase pospuestos, emisor/planificador inactivos. No se despliegan aquí.

## Validación

Permisos/replay/rollback, QR antes/después, rechazo web/app, contador e historial,
episodio nuevo y cancelación de leases en PostgreSQL/PostGIS embebido. Pruebas
Flutter de dominio/DTO/ViewModel, sesión/disposición, reintento/conflicto y UI
normal/pequeña con texto2; navegación real comunitaria incluida en regresión.
PGlite serializa una conexión: no certifica contención multiconexión hosted.
Evidencia definitiva, build y pendientes en ESTADO. No se cierra la historia
hasta contar con integración y demo con Supabase/Android reales.
