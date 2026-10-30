# notification-delivery

**POSPUESTA por instrucción del usuario18/10/2026 (ADR-068).** Código preparado
inactivo, fuera de la entrega actual. No desplegar (tampoco mediante deploy
global), configurar secrets ni programar cron ahora. Se retiró su entrada de
supabase/config.toml. Los pasos inferiores son referencia para una eventual
reactivación autorizada;027 aplicado y la bandeja con Supabase se conservan.

HU-12.3/#42 / RF-17,18. Despliegue y activación pendientes. Requiere patch027.

La Edge Function procesa hasta3 trabajos ya persistidos por invocación POST.
Debe invocarla un planificador de servidor (por ejemplo Supabase Cron con Vault
o el planificador de infraestructura existente), inicialmente una vez por minuto.
No hay planificador activo por añadir este directorio. La frecuencia/capacidad se
ajusta según cola; no exponer el secreto a navegadores ni Flutter.

Secrets de Edge:

- `FCM_SERVICE_ACCOUNT_JSON`: JSON de cuenta de servicio del proyecto Firebase
  con permiso de envío FCM HTTP v1; private_key y client_email solo en servidor.
- `NOTIFICATION_WORKER_SECRET`: aleatorio de al menos32 caracteres; el planificador
  envía `Authorization: Bearer <secreto>`. Distinto de la clave publicable o JWT de usuario.
- `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY`: entorno servidor de Supabase.

El planificador llama `/functions/v1/notification-delivery` con POST y guarda
el secreto en su almacén seguro. No se incorpora a una migración, ni al código
cliente, ni a un archivo versionado. Secrets y programación se configuran en
el entorno de desarrollo antes de validar; su despliegue requiere autorización
del usuario. No crear un cron que guarde el bearer literal en SQL versionado.

Deploy preparado en supabase/config.toml (`verify_jwt=false` con validación
propia de secreto). `supabase functions deploy notification-delivery` cuando
se autorice. No usar JWT de un usuario para activar entregas.

Validación local:

```powershell
node --experimental-transform-types --test supabase/functions/notification-delivery/delivery_test.ts supabase/functions/notification-delivery/handler_test.ts
npx --yes deno check supabase/functions/notification-delivery/index.ts
```

API OAuth/FCM según [HTTP v1 oficial](https://firebase.google.com/docs/cloud-messaging/send/v1-api).
Respuesta solo contadores y códigos seguros; no registra tokens ni respuestas
crudas del proveedor. Estado operativo en notification_deliveries: attempts,
next_attempt_at, last_error, status. Inspección solo administrativa en servidor.
No se incluye panel administrativo ficticio. Las alertas no se eliminan al fallar.
