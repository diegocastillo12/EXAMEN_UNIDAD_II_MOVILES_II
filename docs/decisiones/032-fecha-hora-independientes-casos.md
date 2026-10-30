# ADR-032: fecha y hora independientes en reportes

Estado: aceptado por solicitud explícita del usuario. Fecha: 11 de octubre de 2026.

## Motivo

El control combinado de fecha/hora no coincide con la UI aprobada y obliga a recorrer ambos pickers cada vez. El usuario solicita dos inputs juntos.

## Decisión

EventDateTimeFields reutiliza AppFieldSurface en core: etiqueta interior Fecha/Hora, radio/padding/superficie/foco existentes, calendario/reloj separados y acciones accesibles. Row con dos campos equivalentes y separación12; texto ampliado apila para conservar contenido/acciones. Sigue dentro del mismo StaggerRevealItem/ShakeField del formulario. Sin mensajes de validación debajo de campos.

EventDateTimeDraft es estado de presentación compartido con fecha/hora/minuto opcionales. Los ViewModels eligen cada componente respetando busy/stage/lockedDraft; estado parcial marca cambios pero no crea un timestamp ni permite preview/publicación válidos. Las operaciones existentes que reciben occurredAt conservan compatibilidad; UTC/precisión de un valor recibido se conservan hasta seleccionar un nuevo componente. Dominios/backend siguen recibiendo un DateTime completo, con las mismas validaciones.

## Validación y límites

Pruebas de selecciones parciales, ambos órdenes, cambios independientes, preservación de timestamp, callbacks/deshabilitación y geometría normal/texto2. Regresiones de reportes/arquitectura/creación y capturas de ambos tamaños. Sin SQL ni cambios de autorización. Revisión Android con pickers en Android pendiente.

La consulta del usuario sobre editar casos publicados se investigó: no hay implementación de actualización publicada. La recomendación de editar información de casos abiertos por autor, con historial/versionado, requiere un incremento explícito separado; esta decisión no lo implementa ni lo autoriza por sí sola.
