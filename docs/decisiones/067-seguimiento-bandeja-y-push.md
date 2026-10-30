# ADR-067: seguimiento, bandeja persistente y entrega push

Fecha: 18/10/2026. Estado: implementación local; activación pendiente.
Trazabilidad: HU-12.1/#40, HU-12.2/#41, HU-12.3/#42; RF-16,17,18.

## Decisión

Seguimiento explícito por cuenta y destino (caso perdido, búsqueda comunitaria,
reporte encontrado anterior o zona propia). No se convierte Guardados en
suscripción ni se activa el seguimiento de zonas existentes automáticamente.
Preferencias HU-02 siguen siendo la condición de recepción. No se usa GPS
continuo: el servidor compara la zona/radio guardados con la zona pública
aproximada del caso, la misma ubicación de Explorar.

Cada cambio de seguimiento lleva UUID estable y versión esperada. Una orden
repetida devuelve su recibo original incluso si después se dejó de seguir;
no restaura una elección antigua. Tras resultado ambiguo se reintenta la misma
orden; conflicto obliga a consultar. Tablas privadas sin grants directos,
RPC autenticadas sin aceptar owner del cliente y autorizando zona/destino.

Eventos publicados/resueltos, avistamientos web/app, avisos vinculados previos
y revisiones generan notificaciones mediante triggers transaccionales.
No se crean avisos históricos al instalar. Publicación selecciona seguidores
de zonas; novedades/cierre seleccionan responsable y seguidores del caso,
siempre según preferencias. Una alerta por destinatario/clave de evento;
coincidir por más de una zona no duplica. La revisión no publica motivo/evidencia.

La misma transacción guarda notificación y outbox antes de cualquier HTTP.
Aunque se elija solo push, la notificación permanece como recibo consultable
en bandeja para recuperar fallos de entrega. Pausar no borra recibos anteriores.
`in_app` habilita recepción sin exigir push; no crea una segunda copia.
Bandeja privada paginada por ID descendente; marcar leída es idempotente.
Abrir usa las fichas existentes y vuelve a comprobar su autorización actual:
un aviso antiguo no concede acceso a un caso cerrado/eliminado.

Entrega mediante Edge Function `notification-delivery`, invocada por un
planificador de servidor con secreto dedicado de al menos32 caracteres.
Sin invocación desde app, ni secretos en Flutter/Nuxt público. FCM HTTP v1
usa OAuth firmado con cuenta de servicio almacenada solo en secrets de Edge.
El proveedor no recibe fotos, puntos, referencias, comentarios, motivos,
identidad del destinatario ni ID de caso. El aviso de bloqueo es genérico y
abre la bandeja de la cuenta actual tras login/onboarding; nunca un destino
arbitrario aportado en el payload.

Outbox reclama hasta3 trabajos por invocación, con `SKIP LOCKED`, lease UUID
y vencimiento de5 minutos. Revalida caso, preferencias y suscripción al reclamar;
cancela trabajo que dejó de ser pertinente. No hay dispositivo: difiere1 hora.
Fallo de proveedor: backoff exponencial acotado, solo código seguro en last_error.
Token UNREGISTERED se desactiva; un registro posterior puede recuperarlo.
Máximo10 dispositivos activos por cuenta y vigencia operativa de60 días.

Android pide permiso únicamente con acción explícita en Alertas. Inicialización,
token y SDK quedan en fuentes data; casos de uso/ViewModel gestionan acciones
y señales; bootstrap inyecta servicios y app compone navegación. Cambio de
cuenta invalida resultados tardíos. Logout solicita eliminación del token;
registrarlo en otra cuenta reasigna su propietario en servidor.
El payload neutro evita filtrar información de la cuenta anterior si un logout
offline no alcanza al proveedor. Firebase queda desactivado sin configuración,
sin impedir el resto de la aplicación.

## Alternativas y consecuencias

Enviar push dentro de la escritura de negocio acoplaría publicación a FCM y no
permitiría recuperar fallos; se descarta. Topics de cliente no sirven para
autorizar destinatarios privados. Un backend adicional/Redis no se necesita.

El fanout transaccional tiene coste proporcional a destinatarios y puede hacer
fallar la transacción completa si excede recursos; no se finge una cola masiva.
Evaluar volumen antes de escalar; evolución futura requerirá outbox de eventos.
No hay email/SMS ni replay de novedades previas al seguimiento.

HTTP externo no participa en la transacción: entrega es al menos una vez.
Si FCM acepta y se pierde el acuse, puede repetirse el push, con tag estable
por alerta; la bandeja no duplica. Varios dispositivos con resultado parcial
pueden recibir un reintento. `sent` acredita aceptación del proveedor, no lectura
ni llegada al teléfono. Cierre posterior a claim/aceptación no puede retirar
un mensaje en tránsito; TTL60s reduce avisos tardíos. Las preferencias y el estado
se vuelven a revisar antes de cada nuevo intento.

## Activación y evidencia

Plan027/fuentes091–095, migración/patch generados y run_all actualizado.
No se reescribe SQL aplicado. Requiere026, confirmado por el usuario.
Firebase Android conserva el package existente: JSON nativo local y valores
Firebase públicos de compilación deben pertenecer al mismo proyecto.
Secrets, despliegue Edge y planificador son configuración operativa pendiente;
no se afirma que existan por incluir el código.

Pruebas locales y limitaciones en ESTADO; activación y demo en CONFIGURACION.
PGlite/PostGIS y proveedor simulado no certifican hosted, concurrencia con varias
conexiones, permisos Android reales ni entrega FCM.
