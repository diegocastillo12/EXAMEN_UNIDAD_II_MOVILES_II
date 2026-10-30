# Patches manuales de Supabase

25/10: [040_patch_case_matching.sql](040_patch_case_matching.sql), generado
por Build-CaseMatchingPatch.ps1 desde plan040/fuentes128–134. Aplicar completo
después de039, con clientes/servidor coordinados. No aplicar run_all a un servidor
existente. Índices/revisiones privados y hallazgos independientes aprobados; sin
aplicación remota desde este chat. Modelo/evaluación en la ficha de matching.

Estadísticas24/10: [039_patch_pilot_statistics.sql](039_patch_pilot_statistics.sql)
generado mediante Build-PilotStatisticsPatch.ps1, con fuentes125–127. Aplicar todo
en desarrollo sobre el esquema previo cuando se active el incremento; no reaplicar
patches anteriores. No asigna administradores. La cuenta autorizada se asigna
explícitamente en servidor y conserva permiso independiente de moderación.
Activación/demo remotas pendientes; [ficha](../../docs/funcionalidades/estadisticas-piloto.md).

Apelaciones23/10:035_patch_moderation_appeals.sql generado mediante
Build-AppealsPatch.ps1; requiere030, no034. Aplicar el contenido completo solo
si está pendiente. Conserva decisiones originales y visibilidad; no requiere
reaplicar030. Desarrollo remoto aún pendiente; ver CONFIGURACION y la ficha.

Celular privado20/10: 033_patch_profile_contact_phone.sql después de032, añade profiles.contact_phone y sugerencia al autor. Contacto por caso está en031 y compartir en032; aplicar solo pendientes en orden. Generado con Build-ProfileContactPhonePatch, no editar independientemente.

Difusión20/10: [032_patch_case_sharing.sql](032_patch_case_sharing.sql), generado mediante Build-CaseSharingPatch.ps1. Ejecutar íntegro después de031 cuando se autorice activar la nueva RPC; no reaplicar patches anteriores. Validación local en ESTADO, sin despliegue remoto.

Contacto por caso20/10: [031_patch_case_contacts.sql](031_patch_case_contacts.sql), generado con Build-CaseContactsPatch.ps1. Ejecutar íntegro después de030 cuando se autorice activar el backend. No reaplicar patches anteriores. Validación local/limitaciones en docs/ESTADO.md; no aplicado remotamente.

**Confirmación posterior18/10:**030 aplicado por el usuario, sin inspección
remota nueva. No reaplicar030. Continúan los pasos de configuración/acceso/rol
y validación real de moderación web descritos en CONFIGURACION.


**Moderación web18/10:** [030_patch_content_moderation.sql](030_patch_content_moderation.sql)
completo después de029 confirmado aplicado, sin reaplicar029.030 pendiente en
desarrollo. Requiere Nuxt actualizado, variables de sesión/acceso y revisor
asignado desde servidor; no añade administración Flutter. Ver CONFIGURACION.


**Confirmación posterior18/10:**029 aplicado por el usuario, sin inspección
remota nueva. No reaplicar028 ni029. Pendiente actualizar Flutter y demo real.


**Actualización18/10:**028 confirmado aplicado por el usuario, sin reaplicarlo.
Nuevo incremento HU-14.1: [029_patch_content_reports.sql](029_patch_content_reports.sql)
completo después de028 y Flutter actualizado. Generado desde099–101/plan029;
029 pendiente en desarrollo. No requiere Firebase/FCM ni despliegue Nuxt.
La indicación inferior de028 pendiente es anterior a esta confirmación.


HU-13: ejecutar completo [028_patch_case_closure.sql](028_patch_case_closure.sql)
después de027 ya confirmado, sin reaplicarlo. Actualizar Flutter; el QR Nuxt
existente reconoce el cierre sin despliegue nuevo. Generar con
Build-CaseClosurePatch.ps1/Build-RunAll.ps1. Pendiente aplicación en desarrollo
y demo Android/Supabase; no activar FCM/Edge/cron (ADR-068).

027_patch_notifications.sql: HU-12.1/#40,12.2/#41,12.3/#42. Generado por
Build-NotificationsPatch.ps1 desde plan027/fuentes091–095. Requiere026 confirmado.
Aplicar solo027 completo en desarrollo; sin backfill ni secrets/cron.
Activación hosted/Firebase/Edge/planificador pendientes. Véase CONFIGURACION.

024_patch_public_sightings.sql: HU-10.1/#36, aplicar completo en desarrollo
después de023 y junto con el servidor Nuxt actualizado. RPC autorizada solo
service_role, tabla/evidencia privada, idempotencia y límites persistentes.
Generado por Build-PublicSightingsPatch.ps1 desde083–085/plan024; no editar
el artefacto ni volver a aplicar patches antiguos. Aplicación remota pendiente.

`004_patch_profile_avatars.sql` configura el bucket privado y las políticas de foto de perfil sin intentar alterar la tabla administrada `storage.objects`. Sustituye la ejecución fallida de la migración 003. Comprueba que RLS ya esté habilitado y aborta si no lo está; no cambia propietarios ni roles.

Pegar todo el archivo en una consulta nueva del SQL Editor del proyecto de desarrollo, con rol postgres. Quitar la selección de texto antes de Run para ejecutar la transacción completa. No ejecutar fragmentos del bloque DO. Se puede repetir y conserva las fotos existentes.

Es una salida generada, no otra fuente editable: `./database/scripts/Build-AvatarPatch.ps1` usa el plan 004 y las fuentes 010/012. `Build-RunAll.ps1` también la regenera. La migración 003 y fuente 011 se conservan como historial del intento fallido, pero no se deben usar para la activación manual. Antes de adoptar la CLI, conciliar su historial con las ejecuciones manuales.

005_patch_pets.sql: registro, consulta y edición privada de mascotas propias, generado por Build-PetsPatch.ps1 desde fuentes 013–018. Ejecutar archivo completo con rol postgres sobre esquema de acceso; no depende de Storage ni incorpora el patch anterior de avatar. No es una copia editable. Ver pruebas 005_pets_permissions.sql y ADR-010.

## Patch009: campos obligatorios de mascotas

009_patch_pet_required_fields.sql se genera con database/scripts/Build-PetRequiredFieldsPatch.ps1 y requiere008 aplicado. Ejecutar todo el archivo en Supabase de desarrollo al autorizar despliegue; no editarlo independientemente. Exige edad/tamaño/rasgos al crear o editar metadatos, con rasgos hasta200, conservando filas antiguas y sus operaciones de ciclo de vida. Fuentes034–035/ADR-016; tests locales no acreditan activación remota.

## 010 — Zonas de interés privadas

Generar con `../scripts/Build-InterestZonesPatch.ps1`. Aplicar completo [010_patch_interest_zones.sql](010_patch_interest_zones.sql) en Supabase de desarrollo con Auth/roles existentes. Crea tabla privada, RPC y permisos; no modifica mascotas ni requiere PostGIS. La salida deriva del plan010 y migración20261009001000; no editarla manualmente. Probado localmente, sin despliegue remoto en esta entrega.

## 011 — Preferencias de alertas

`011_patch_alert_preferences.sql` es generado por `../scripts/Build-AlertPreferencesPatch.ps1` desde plan011/SQL040–043 y migración20261010001100. Ejecutar **todo su contenido** en Supabase de desarrollo. Permite preferencias por cuenta con versión y RLS, sin activar entregas. Repetible sin borrar elecciones. Probar por separado `../tests/010_alert_preferences_permissions.sql`; la prueba usa usuarios ficticios y rollback. No editar el artefacto ni fuentes tras aplicarlo; cambios posteriores requieren otra migración.

## 012 — Procesamiento y principal de fotos

Generar mediante `database/scripts/Build-PetPhotoProcessingPatch.ps1`. Aplicar todo `012_patch_pet_photo_processing.sql` después de011 y coordinar activación con Edge pet-photo-process. No ejecutado remotamente por esta tarea. Añade derivados privados y principal; bloquea el circuito antiguo de cargas/publicación del cliente. Preparar WASM/desplegar según `supabase/functions/pet-photo-process/README.md` antes de actualizar la app. Mantiene fotos históricas privadas y sin processed_at inventado. No editar la salida: fuentes044–047/plan012.

## Patch013: casos perdidos

`013_patch_lost_cases.sql`, generado con `database/scripts/Build-LostCasesPatch.ps1`, se ejecuta completo después de012. Añade publicación autorizada/idempotente, historial/contador atómicos y proyección pública con derivados elegidos/verificados. Mantener buckets privados; sin DML cliente. Preparado y probado localmente; ejecución confirmada por el usuario el 10 de octubre de 2026, sin verificación remota por el agente. Ver CONFIGURACION y ADR-021.

## Patch014: casos encontrados

[014_patch_found_cases.sql](014_patch_found_cases.sql) se genera con Build-FoundCasesPatch.ps1 desde plan014/SQL052–055. Ejecutar completo después de013 y actualizar el handler existente pet-photo-process para x-found-case-id. No editar el artefacto ni volver a generar fuentes aplicadas con contenido diferente. Añade casos sin mascota/dueño conocido, fotos sanitizadas verificadas en buckets privados propios, publicación/evento idempotentes y limpieza autorizada de drafts. Preparado y probado localmente; activación remota pendiente. Ver CONFIGURACION/ADR-022.
# Límite de bloqueos al publicar perdido — patch015

Ejecutar completo [015_patch_lost_case_lock_timeout.sql](015_patch_lost_case_lock_timeout.sql), una vez aplicados los comandos de patch013. Regenerar con `./database/scripts/Build-LostCaseLockTimeoutPatch.ps1`. Plan015/fuente056 conserva historial previo y limita a5s cada espera de bloqueo dentro de la RPC; no cambia autorizaciones ni deduplicación. Su repetición y la de run_all están validadas localmente. No libera solicitudes antiguas ni acredita recuperación remota. La recuperación de la cola observada es un procedimiento operacional separado; no ejecutar scripts de cancelación como migraciones.

## Bloqueos de cuentas —034,23/10/2026

Generado [034_patch_user_blocks.sql](034_patch_user_blocks.sql) mediante
`database/scripts/Build-UserBlocksPatch.ps1`. Ejecutar todo el contenido después
de033 en desarrollo; después actualizar clientes. No reaplicar030 confirmado.
Gestiona elecciones propias y rechaza nuevas contribuciones autenticadas entre
cuentas; conserva historial, denuncias y QR anónimo. Después, aplicar
[036_patch_block_case_contacts.sql](036_patch_block_case_contacts.sql), generado
con `Build-BlockCaseContactsPatch.ps1`, para el ocultamiento de contacto/foto
confirmado por usuario, con consentimiento intacto. Activación remota
pendiente; [alcance y validación](../../docs/funcionalidades/bloqueos-usuarios.md).
