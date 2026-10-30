# Apelaciones de moderación

HU-14.4 / RF-33; issue #46. Implementada localmente el23/10/2026 en Flutter,
Nuxt y SQL versionado. La revisión administrativa permanece exclusivamente web.
No cierra HU-14 ni acredita activación remota.

## Qué hace y recorrido

En móvil: Perfil → Mis apelaciones. En web: Inicio → Mis apelaciones
(`/apelaciones`, política global account). Se consultan las decisiones sobre
contenido propio, se abre una decisión y se envía el motivo de apelación. La
misma vista permite consultar «Pendiente de respuesta» o la respuesta y fecha.

El moderador entra por Denuncias → Revisar apelaciones
(`/moderacion/apelaciones`, política global reviewer), abre una apelación y
registra respuesta con motivo. La base fija cuenta revisora y fecha. La lista
incluye pendientes y respondidas, identificadas por su estado, con paginación20.

La respuesta es una revisión escrita: no restaura ni oculta automáticamente.
Si corresponde cambiar la visibilidad, el revisor usa Revisar denuncia y registra
una nueva decisión con sus comprobaciones de versión existentes. Se conserva
la decisión apelada, incluso tras decisiones posteriores, junto al envío y respuesta.

## Reglas y campos

- Motivo de apelación y respuesta obligatorio, hasta1000 caracteres Unicode;
  espacios exteriores normalizados. Web/móvil cuentan el mismo límite.
- Una apelación por decisión y propietario, una respuesta definitiva por apelación.
  El UUID estable identifica cada escritura; repetir el mismo contenido devuelve
  el recibo persistido y un cambio de contenido/actor/objetivo produce conflicto.
- Se apela por autoría del recurso: lost/found por owner_id y avistamientos por
  reporter_id autenticado. El denunciante y el dueño del caso de un avistamiento
  ajeno no adquieren autoría. La evidencia anónima no se atribuye a una cuenta.
- Envío/consulta conservan el ciclo operativo del caso. Ni la decisión ni la
  denuncia original se borran o sustituyen para registrar la revisión.

## Persistencia y permisos

Plan035/fuentes119–121, migración `20261023003500_moderation_appeals.sql`
y patch035 generado. Requiere las tablas/RPC de030; no depende de HU-14.2/034.
La integración con bloqueos incorpora034 y036 al bundle y conserva035 y sus
fuentes119–121 intactos. El complemento de contacto de bloqueos usa036/fuente122
para evitar duplicar la versión035. No se renumeran migraciones ya aplicadas.

moderation_appeals, moderation_appeal_answers y moderation_appeal_access son
tablas privadas con RLS y sin grants directos. RPC security definer con
search_path vacío comprueban autoría o require_content_reviewer por operación;
no existe autoasignación de permisos. Los accesos de revisión quedan auditados.
Bloqueos por comando/decisión y bloqueo de fila al responder serializan reintentos.

La proyección solo contiene decisión, recurso, motivos, fechas y respuesta con
cuenta revisora. No expone denuncia, denunciante, coordenadas, evidencia ni paths.
Nuxt revalida Auth/onboarding/cuenta en cada API y usa JWT privado del usuario;
cookie HttpOnly, vínculo X-Account-Actor, Origin/Fetch Metadata, tamaño acotado,
sin secretos en cliente/SSR y sin caché compartida de datos o permisos.

## Errores, reintentos y ciclo de vida

Toast superior, campo invalid/shake, skeleton inicial y shimmer conservando
contenido durante refresh de la misma cuenta. Vacío solo tras lectura confirmada.
Reintento ambiguo conserva UUID y motivo y bloquea edición/doble envío. Conflicto
exige consultar estado actual; si falla esa consulta, conserva borrador y permite
repetirla. Una revocación oculta los datos privados y permite revalidar.

La salida con borrador/resultado ambiguo solicita confirmación. Cambio de cuenta,
expiración o disposición descartan estado y resultados tardíos. El borrador no
persiste al cerrar/reiniciar la pantalla; la apelación ya guardada sí se recupera.

## Dependencias y activación

Generar con `database/scripts/Build-AppealsPatch.ps1`. Aplicar solamente035
cuando030 y sus dependencias ya estén activas; no reaplicar030 confirmado por
el usuario ni ejecutar run_all sobre producción para esta actualización.
CONFIGURACION explica los pasos. Desplegar el nuevo Nuxt y distribuir Flutter
después de activar SQL; las versiones previas siguen funcionando sin el acceso
nuevo. No requiere variables adicionales, FCM ni roles distintos del revisor
ya asignado en servidor. Este incremento no ejecuta despliegues ni SQL remoto.

## Validación y pendientes

SQL local PGlite/PostGIS:3 escenarios nuevos y regresión completa48/48; aislamiento
por autoría, denegación de ajenos/anon/rol revocado, idempotencia/conflicto,
historial original, lectura privada, paginación y repetición del bundle.
Web:77 pruebas,30 pruebas de producción, typecheck y build aprobados.
Flutter: análisis sin incidencias y regresión524/524 con
`--dart-define=AMBIENT_BACKGROUND_MOTION=false`; tras añadir dos regresiones del
router real,18/18 focalizadas (ocho escenarios de apelaciones y10 de arquitectura),
incluidos cuenta distinta/disposición y formularios390/320 con texto200%.

Chrome con fixture: envío/validación/descarte cancelado/reintento único,
respuesta de revisor/consulta del autor/revocación, teclado, movimiento normal
y reducido, CSP/hidratación, anchos1920/1440/731/390/320 y texto200%.
Capturas locales en `apps/mobile/build/ui-preview/appeals-{web,mobile}`;
no son datos ni evidencia de Supabase remoto. Corregidos el montaje de la ruta
anidada y el contador del TextField compartido para que no tape texto ampliado.

Pendientes: aplicar035 en desarrollo remoto, probar dos cuentas y revisor reales,
contención multiconexión hosted, Android instalado y otros navegadores. No se
marca la historia como cerrada hasta completar la evidencia remota requerida.

Integración23/10 de ambas funcionalidades:537 pruebas Flutter,83 web,31 de
servidor y55 SQL aprobadas; formato/análisis/typecheck/build correctos. Chrome
sobre el build integrado vuelve a validar ambos recorridos con fixtures. El
router real móvil prueba acceso a bloqueos en sus tres etapas de cuenta y
conserva las regresiones de apelaciones. Evidencia local; activación y demo
remotas pendientes, como se detalla en ESTADO.
