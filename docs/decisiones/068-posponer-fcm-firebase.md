# ADR-068: posponer FCM y Firebase

Fecha: 18/10/2026. Estado: aceptada por instrucción explícita del usuario.
Trazabilidad: HU-12.1/#40, HU-12.2/#41 y HU-12.3/#42; RF-16,17,18.

## Decisión y alcance actual

El usuario indica: «por el momento lo de notificaciones FCM y lo de
implementacion firebase queda fuera o pendiente». Se pospone HU-12.3/#42.
El incremento activo comprende seguimiento y bandeja persistente con Supabase
(HU-12.1/#40 y HU-12.2/#41). No se ofrecen avisos al teléfono con app cerrada.
No se sustituye FCM por otro proveedor ni por un servicio de conexión permanente.

Se retiran firebase_core/firebase_messaging y el adaptador Firebase del cliente,
el plugin Google Services y el permiso/metadata de notificaciones Android.
Bootstrap conserva la implementación no disponible del contrato genérico;
main no activa el observador de push y la bandeja no compone el registro del
teléfono. No se requiere proyecto, JSON ni defines Firebase para este incremento.
La preferencia de teléfono de HU-02 se conserva como elección guardada para
una activación futura, con texto explícito de envío pendiente; no solicita
permisos ni registra tokens. No se cambian silenciosamente elecciones de cuenta.

## Persistencia y código preparado

027 está aplicado según confirmación del usuario y no se reescribe ni reaplica.
Sus tablas/RPC/outbox y las preferencias persistidas se conservan. Pueden
acumularse trabajos pendientes para preferencias push guardadas; no se ejecutan
sin despachar la cola. No se borran recibos ni suscripciones ni se inventa una
migración de reversión. Seguimiento/bandeja siguen usando el contrato existente.

El emisor Edge y contratos genéricos ya preparados se conservan inactivos,
como trabajo diferido, no como funcionalidad entregada. Se retira la entrada
notification-delivery de supabase/config.toml. No desplegar su carpeta mediante
un deploy global ni activar cron/secrets. No hay despliegue o cron confirmado;
no se realizaron cambios remotos desde este chat. Una activación futura
requerirá revisar antigüedad/pertinencia de trabajos pendientes, restaurar la
integración Firebase y validar Android/FCM, además de autorización de despliegue.

Esta decisión sustituye la activación inmediata de FCM descrita por ADR-067;
sus límites de privacidad, autorización y persistencia siguen vigentes.
HU-12 completa no se declara cerrada: HU-12.3 queda pospuesta y no bloquea
validar el alcance activo HU-12.1/12.2 ni continuar el siguiente incremento
tras su confirmación. Evidencia local y pendientes reales en ESTADO.
