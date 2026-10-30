# Base de datos de Entre Huellas

25/10, HU-25/#71 y HU-26/#72: plan040/fuentes128–134 generan índices visuales
y revisiones privadas, RPC solo servidor, invalidación y nuevo tipo explícito
`independent_found` sin reclasificar datos. Build-CaseMatchingPatch/Build-RunAll;
patch040 después de039. Sin aplicación remota. [Contrato y activación](../docs/funcionalidades/coincidencias-de-casos.md).

HU-16.1,24/10: fuentes125–127/plan039 generan migración y patch039 con
Build-PilotStatisticsPatch/Build-RunAll. Permiso administrador independiente
de revisores y RPC autenticadas de agregados por período de Lima. No asigna
roles, cambia casos ni amplía lectura privada; activación remota pendiente.
[Contrato y evidencia](../docs/funcionalidades/estadisticas-piloto.md).

Complemento23/10: usuario aplica037 y la prueba real de perdido ya devuelvePT409.
La comparación interna de búsqueda permanecía en publish_found_case; fuente124/
plan038 la corrige sin reescribir037. Build-RecoveryNestedBusinessConflictsPatch
genera patch038/migración20261023003800 y run_all la aplica al final de037.
Conserva cuerpo restante/settings/grants. Cuatro SQL focalizadas pasan para las
cuatro funciones. Usuario aplica037/038 y suite remota estricta6/6 aprobada;
regresión completa posterior a038 aprobada56/56, sin omisiones. Evidencia en ESTADO.

23/10, validación HU-15.2: plan037/fuente123 corrige conflictos deterministas en
publish_lost_case, prepare_recovery_report y publish_recovery_report:40001→PT409
para evitar reintentos internos de PostgREST. Requiere018 y cliente Flutter que
reconozca ambos códigos; web ya reconoce HTTP409. Build-RecoveryBusinessConflictsPatch
genera patch037/migración20261023003700; Build-RunAll la incorpora al final.
Sustitución acotada de definiciones por firma, conserva ajustes/ACL/propietario y
no cambia datos/RLS. Cuatro SQL focalizadas y56/56 de la suite completa pasan;
aplicación037 confirmada por el usuario y verificada remotamente junto con038.
No aplicar run_all para actualizar un servidor existente. [ADR-134](../docs/decisiones/134-conflictos-de-publicacion-sin-reintento-postgrest.md).

Bloqueos23/10: HU-14.2/RF-23/#44, plan034/fuentes115–118. Tabla privada/RPC propias
y triggers de contribuciones nuevas; lock por pareja, CAS y replay. Generar
Build-UserBlocksPatch/Build-RunAll; patch034 después de033 y036 después de034
(fuente122/Build-BlockCaseContactsPatch), con clientes actualizados.
036 oculta contacto/foto entre cuentas bloqueadas, sin cambiar consentimiento.
QR anónimo conserva permisos. Validación SQL local en ESTADO; activación
hosted pendiente. [Ficha](../docs/funcionalidades/bloqueos-usuarios.md).

HU-14.4/#46,23/10: plan035/fuentes119–121 añade apelaciones propias,
respuestas y lecturas auditadas privadas. Build-AppealsPatch genera patch035 y
migración20261023003500_moderation_appeals.sql; requiere030, sin dependencia de
034/HU-14.2. Build-RunAll incorpora034,035 y036 tras033. No ejecutar el acumulativo para
actualizar producción; aplicar solamente el incremento pendiente. Validación
local48/48, sin aplicación remota. [Ficha](../docs/funcionalidades/apelaciones-moderacion.md).

Celular privado20/10: plan033/fuentes112–114, patch033/migración20261020003300_profile_contact_phone.sql. Nullable text con formato internacional y grants por columna/RLS propia; read_case_contact sugiere solo al autor. Build-ProfileContactPhonePatch/Build-RunAll; después de032, sin reescribir031. Hosted pendiente.

Compartir ficha20/10: plan032/fuentes110–111, migración20261020003200_case_sharing.sql y patch032 generados con Build-CaseSharingPatch/Build-RunAll. RPC autenticada prepara solo búsquedas activas/visibles con foto validada por el lector QR; dueño real y slug estable, sin reactivar enlaces revocados ni permisos de autor. [Ficha](../docs/funcionalidades/compartir-ficha.md). Activación remota pendiente.

Contacto autorizado20/10: plan031/fuentes106–109 y migración20261020003100_case_contacts.sql, después de030. Tabla privada/RLS y RPC por autor/versionado, lectura solo con caso activo visible; foto opcional en Storage con permiso SELECT acotado, sin ampliar escrituras. Generar Build-CaseContactsPatch/Build-RunAll. Validación local en ESTADO; activación hosted pendiente. [Ficha](../docs/funcionalidades/contacto-reportante.md).

HU-14.3/#45: fuentes102–105/plan030, migración y patch030 generados mediante
Build-ModerationPatch/Build-RunAll. RLS/grants privados, rol por operación,
visibilidad independiente, decisiones CAS/UUID y accesos auditados.029 confirmado
aplicado; no reaplicarlo ni modificarlo.030/configuración/demo pendientes.
Build-RunAll valida migraciones previas sin reescribir sus patches manuales;
los generadores específicos de patch siguen disponibles. Se evita el bloqueo
Windows por reescrituras idénticas observado al generar. [ADR-071](../docs/decisiones/071-moderacion-exclusiva-platform.md).


HU-14.1/#43: fuentes099–101/plan029, migración20261018002900_content_reports.sql
y patch029 generados mediante Build-ContentReportsPatch.ps1/Build-RunAll.ps1.
Denuncias privadas, recursos autorizados, recibo estable y revisor asignado por
servidor; sin ocultamiento/cierre automático.028 ya aplicado según usuario;
no modificar/reaplicar sus fuentes.029/validación remota pendientes.
[Ficha](../docs/funcionalidades/denuncias-contenido.md),
[ADR-070](../docs/decisiones/070-denuncias-privadas-idempotentes.md).


HU-13,18/10: fuentes096–098/plan028 generan migración028 y
[patch028](patchs/028_patch_case_closure.sql), después de027 confirmado por usuario.
Recibo privado/RLS, cierre atómico autorizado e idempotente con auditoría,
contador y cancelación de difusión pendiente. Build-CaseClosurePatch/Build-RunAll;
SQL remoto028 pendiente. FCM sigue pospuesto por ADR-068.

HU-12,18/10: fuentes091–095/plan027 generan
[migración027](../supabase/migrations/20261018002700_notifications.sql) y
[patch027](patchs/027_patch_notifications.sql). Requiere026, confirmado por usuario.
Build-NotificationsPatch/Build-RunAll; sin reescribir migraciones previas.
Suscripciones/órdenes privadas CAS e idempotencia, bandeja paginada/leído y
outbox transaccional por evento/destinatario. Triggers sin backfill, destinatarios
según preferencias y zona pública aproximada; leases/reintentos solo servidor.
RLS sin grants directos; Edge y planificador requieren configuración operativa
separada. SQL hosted no aplicado; [ficha](../docs/funcionalidades/seguimiento-y-alertas.md).

Cronología/revisión18/10: fuentes088–090/plan026 generan
[migración026](../supabase/migrations/20261018002600_case_timeline.sql) y
[patch026](patchs/026_patch_case_timeline.sql), después de025 confirmado por
el usuario. RPC autenticadas solo para propietario del caso, foto privada,
cronología/historial paginados, clasificación append-only con motivo/actor/fecha,
UUID estable y versión esperada. Sin grants directos de tablas ni cambios en QR.
Regenerar Build-CaseTimelinePatch/Build-RunAll; aplicación remota026 pendiente.
[Ficha](../docs/funcionalidades/cronologia-y-revision.md).

Avistamientos Android18/10: fuentes086–087/plan025 generan
[migración025](../supabase/migrations/20261018002500_app_sightings.sql) y
[patch025](patchs/025_patch_app_sightings.sql), después de024 ya confirmado por
el usuario. Regenerar Build-AppSightingsPatch/Build-RunAll. Comando de persistencia
común web/app, RPC app solo servidor, reporter_id verificado y evidencia privada;
retira dependencia de QR generado sin ampliar grants de cliente. Requiere servidor
Nuxt actualizado y demo Android antes de cerrar HU-10.2. No aplicado remotamente.

Avistamientos web18/10: fuentes083–085/plan024 generan
20261018002400_public_sightings.sql y [patch024](patchs/024_patch_public_sightings.sql).
Después de023, RPC solo service_role y tabla sin acceso directo para clientes.
Fecha/punto/estado/budgets/reintento validados en transacción, evidencia JPEG
privada bytea hasta1MiB recodificada por el servidor Nuxt. No publica datos ni
crea un usuario anónimo. Regenerar Build-PublicSightingsPatch/Build-RunAll;
aplicación remota pendiente. [Ficha](../docs/funcionalidades/avistamientos-web.md).

Lector QR16 octubre: fuentes080–082/plan023 generan migración20261016002300_public_qr_case.sql
y [patch023](patchs/023_patch_public_qr_case.sql), después de022. Regenerar con
Build-PublicQrCasePatch.ps1/Build-RunAll.ps1. RPC read_qr_case solo service_role,
revocación autenticada por autor, sin ampliar lectura anónima de tablas/Storage.
Descriptores de fotos solo al servidor web, nunca directamente al navegador.
24 pruebas SQL/PostGIS locales aprobadas; hosted/Storage/concurrencia pendientes.
Sin modificar migraciones previamente aplicadas. [Ficha](../docs/funcionalidades/ficha-publica-qr.md).

Carteles/QR (16 octubre):077–079/plan022, migración20261016002200_case_posters.sql y [patch022](patchs/022_patch_case_posters.sql) generados por Build-CasePostersPatch/Build-RunAll. Tabla privada de enlaces estables por origen+UUID, sin acceso directo de cliente; RPC autenticada por autor/activo/foto verificada y revisión imprimible. Conserva slugs revocados/cerrados y no modifica casos. Nuevo flag can_generate_poster en la proyección autenticada de encontrados anteriores; sin lectura anónima (HU-09).23 pruebas SQL locales aprobadas, incluida repetición del bundle; aplicación hosted/concurrencia multiconexión pendientes. No se reescribieron migraciones aplicadas. [Ficha](../docs/funcionalidades/carteles-qr.md), [ADR-053](../docs/decisiones/053-carteles-pdf-y-enlaces-qr.md).

Listado privado de guardados:074–076/plan021, migración20261016002100_saved_case_list.sql/patch021 generados por Build-SavedCaseListPatch/Build-RunAll. Requiere020, cuyo usuario confirma aplicación;021 no aplicado. Índice parcial owner/fecha/origen/UUID y RPC autenticada paginada20 (máximo50), cursor por cuenta y proyecciones públicas vigentes. Excluye destinos no visibles sin ampliar permisos. Sin SQL nuevo para Ciudad del perfil; selección de sugerencia validada por flujo de app, no certificado en servidor. Generación/análisis sin incidencias, pruebas/SQL no ejecutados por instrucción vigente. [ADR-051](../docs/decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

Casos guardados: fuentes070–073/plan020, migración20261016002000_saved_cases.sql y patch020 derivados con Build-SavedCasesPatch/Build-RunAll, tras001–019. Tabla privada por cuenta/origen/UUID, RLS restrictiva, lectura de columnas/RPC autenticadas con visibilidad, versión y tombstone. Sin fotos/coordenadas copiadas ni ampliación de acceso a casos. Generación realizada; pruebas no ejecutadas por instrucción del usuario y aplicación remota pendiente. [ADR-050](../docs/decisiones/050-casos-guardados-por-cuenta.md).

Publicación de perdido con espera de bloqueo: [patch015](patchs/015_patch_lost_case_lock_timeout.sql), generado por `Build-LostCaseLockTimeoutPatch.ps1`, añade un límite de5s solo a la RPC existente. Requiere patch013. No cambia permisos ni publica datos; no cancela solicitudes antiguas. Diagnóstico operacional de solo lectura en `tests/diagnose_lost_case_waits.sql`; cancelación de los PIDs observados separada del historial de migraciones. Validación local registrada en ESTADO; activación remota pendiente.

Corrección vigente de avatar: usar [patchs/004_patch_profile_avatars.sql](patchs/004_patch_profile_avatars.sql) completo en SQL Editor. La migración 003 falló por ALTER TABLE sobre Storage administrado; plan 004/fuente 012 validan RLS existente sin alterar su propietario/configuración. Historial previo conservado. Regenerar con `./database/scripts/Build-AvatarPatch.ps1`; run_all también utiliza la corrección. Detalles en [patchs/README.md](patchs/README.md).

Esta carpeta contiene las fuentes SQL de PostgreSQL/Supabase, organizadas por tipo de objeto. El esquema y los permisos se incorporan por funcionalidad. La base de datos se ejecuta en Supabase; este directorio guarda su código versionado.

## Estructura

```text
database/
  extensions/    # Extensiones requeridas
  types/         # Tipos y enumeraciones
  tables/        # Tablas, claves y restricciones
  indexes/       # Índices adicionales
  functions/     # Funciones PostgreSQL y RPC
  triggers/      # Triggers y su vinculación a funciones
  views/         # Vistas y contratos de lectura
  policies/      # Habilitación de RLS y políticas
  grants/        # Privilegios y revocaciones
  seeds/         # Datos de desarrollo sin información privada
  tests/         # Pruebas SQL y PostgreSQL en memoria
  migration_plans/ # Fuentes incluidas en cada incremento
  scripts/       # Generadores PowerShell
  run_all.sql    # Entrada SQL generada y repetible del incremento actual
```

Los `.gitkeep` permiten versionar las carpetas mientras se implementan sus objetos. El incremento de acceso contiene las fuentes 001–007: perfiles, funciones, triggers, RLS, grants y carga de perfiles de cuentas existentes. Su ejecución remota aún no se ha realizado.

## Nombres y orden

Los scripts de esquema utilizan `NNN_descripcion.sql`: número de al menos tres dígitos, guion bajo y descripción en `snake_case`. La secuencia es **global entre las carpetas de esquema**, no se reinicia en cada una. Se compara el número como entero; después de `999` sigue `1000`.

Fuentes del primer incremento de acceso y perfil:

```text
tables/001_create_profiles.sql
functions/002_handle_new_auth_user.sql
functions/003_set_profile_updated_at.sql
triggers/004_profiles_auth_triggers.sql
policies/005_profiles_owner_policies.sql
grants/006_profiles_permissions.sql
tables/007_backfill_existing_profiles.sql
```

El prefijo expresa el orden de dependencias, no el sprint, la HU ni el número de issue. Una extensión o tipo requerido por una tabla debe precederla. Una función debe existir antes del trigger que la utiliza. Las vistas y políticas deben seguir a los objetos de los que dependen.

`seeds` y `tests` tienen sus propias secuencias `001_...sql` y se ejecutan aparte. No forman parte del despliegue normal del esquema. Las carpetas se mantienen organizadas por objeto; no se ejecutan completas por orden alfabético de sus nombres.

## Evolución y migraciones

1. Añadir scripts numerados para el incremento, conservando el SQL en su carpeta. Un script puede crear, alterar o retirar un objeto; describir la operación en el nombre.
2. Revisar dependencias y reunir todos los scripts del incremento en orden numérico en una migración de `supabase/migrations`, antes de aplicarla.
3. Generar esa migración a partir de las fuentes, con referencias a los archivos incluidos. No mantener dos copias editables del mismo SQL. `scripts/Build-Migration.ps1` utiliza un plan de `migration_plans` y registra cada fuente con su SHA256 normalizado.
4. Probar la migración y los permisos en un entorno de desarrollo. Publicar tablas de cliente solo con sus políticas y grants revisados en el mismo incremento.
5. Una vez aplicada, conservar inmutables la migración y sus scripts fuente. Un cambio posterior utiliza otro número y una nueva migración; no reescribir el historial.

La CLI de Supabase utiliza archivos `<timestamp>_<nombre>.sql` en `supabase/migrations`. Los números `001_...` identifican las fuentes organizadas; la migración registra el incremento que se aplica. [Documentación de migraciones de Supabase](https://supabase.com/docs/guides/local-development/database-migrations).

`database/functions` contiene SQL de PostgreSQL, incluidas RPC. Las Edge Functions son código de servidor y pertenecen a `supabase/functions`; no son archivos SQL.

El generador está preparado; la CLI y la ejecución remota no están configuradas por crear estas carpetas. El diseño se registra en [ADR-002](../docs/decisiones/002-organizacion-database.md).

## Reglas para nuevos scripts

- Usar nombres explícitos de esquema, tabla, restricción y política. Revisar `search_path`, permisos de ejecución y cualquier función `SECURITY DEFINER`.
- Versionar juntos restricciones, RLS, grants y operaciones autorizadas del incremento. Validar actor y transición en servidor.
- Separar datos públicos del QR de datos privados. Una política de filas no controla por sí sola las columnas o archivos que se exponen.
- Conservar identificadores estables y restricciones de deduplicación en operaciones reintentables.
- Incluir pruebas entre usuarios y roles, invariantes y reintentos cuando correspondan al cambio. Registrar resultados en [ESTADO.md](../docs/ESTADO.md).
- No guardar contraseñas, cadenas SQL privadas, tokens o claves de servidor. Los seeds usan datos ficticios de desarrollo.

Estas reglas complementan [REGLAS_ARQUITECTURA.md](../docs/REGLAS_ARQUITECTURA.md). La estructura inicial corresponde a la preparación; el primer esquema funcional pertenece a S1, HU-01 / RF-01,34.

## Ejecutar el incremento de acceso

Desde la raíz del repositorio:

```powershell
./database/scripts/Build-Migration.ps1
```

El plan `migration_plans/001_auth_profiles.json` genera `supabase/migrations/20261007000100_auth_profiles.sql`. Valida nombres, números globales únicos, dependencias por orden numérico y rutas dentro de `database`. La misma entrada produce el mismo archivo; si la migración existe con contenido diferente, rechaza sobrescribirla.

Para la ejecución manual repetible en Supabase de desarrollo, usar **run_all.sql**, como se explica abajo. La migración generada se conserva para el historial de despliegue y se aplica una vez mediante el flujo de migraciones. No ejecutar carpetas por separado, editar artefactos generados ni aplicar la migración inicial después de haber creado sus objetos con run_all. El registro de una aplicación manual en el historial de la CLI se debe conciliar antes de adoptar despliegues con esa CLI.

Supabase Auth gestiona `auth.users`, contraseñas y proveedores. El SQL no crea una tabla de contraseñas ni habilita Google. `public.profiles` referencia la identidad de Auth, guarda nombre y ciudad, crea el perfil por trigger y completa perfiles de cuentas existentes. Solo el propietario puede leer su fila y modificar nombre/ciudad; los clientes no escriben identidad ni timestamps, ni insertan o eliminan perfiles. Los metadatos se usan solo como nombre visible, nunca como autorización.

Después de aplicar, ejecutar aparte `database/tests/001_profiles_permissions.sql` en desarrollo. Comprueba dos usuarios, aislamiento, modificación autorizada, columnas protegidas, acceso anónimo y ejecución de la función privilegiada. Usa usuarios ficticios y termina en `ROLLBACK`. Estas comprobaciones requieren PostgreSQL/Supabase real: el análisis sintáctico local no verifica RLS.

Para probar correo/contraseña, usar una cuenta existente de **Authentication → Users**; puede crearse una cuenta de prueba mediante **Add user**. El registro desde la app aún no está implementado. Para Google y el retorno móvil, seguir [CONFIGURACION.md](../docs/CONFIGURACION.md).

## Entrada manual: run_all.sql

Abrir **Supabase → SQL Editor → New query**, pegar el contenido completo de [run_all.sql](run_all.sql) y ejecutar. Puede repetirse sobre una base compatible: no duplica tablas, funciones, triggers, políticas ni perfiles, y conserva los nombres, ciudades y fechas existentes. También acepta una base donde ya se aplicó la migración inicial de perfiles.

El archivo contiene su propia transacción. Crea objetos ausentes, asegura RLS/permisos y completa perfiles faltantes. Comprueba la estructura esperada de `profiles` antes de modificarla; una incompatibilidad produce error y requiere revisión. No elimina datos ni sustituye las funciones/políticas/triggers de la base inicial; la RPC de onboarding 009 tiene repetición explícita mediante CREATE OR REPLACE. Esto no repara automáticamente definiciones alteradas manualmente; ejecutar las pruebas de permisos y versionar correcciones como nuevas migraciones.

Para regenerarlo desde la raíz del repositorio:

```powershell
./database/scripts/Build-RunAll.ps1
```

Es un archivo generado, no otra fuente editable. El generador comprueba primero la migración existente y añade referencias/hashes de las fuentes. Su alcance actual comprende perfiles y onboarding (001–009); si cambia el plan, exige revisar las nuevas operaciones antes de ampliar la entrada. Seeds y tests no se incluyen. La decisión y límites están registrados en [ADR-003](../docs/decisiones/003-ejecucion-sql-idempotente.md).

## Estándar de nombres y SQL

| Elemento | Regla y ejemplo |
| --- | --- |
| Esquemas, tablas, columnas y objetos | Inglés, minúsculas y `snake_case`, sin identificadores con mayúsculas entre comillas. |
| Tablas | Plural: `profiles`, `pets`, `lost_cases`. |
| Columnas | `display_name`, `created_at`, `owner_id`; `id` para identidad propia. |
| Funciones | Verbo y propósito: `handle_new_auth_user`, `set_profile_updated_at`. |
| Triggers y políticas | Describir entidad/operación: `profiles_set_updated_at`, `profiles_select_own`. |
| Restricciones e índices | Incluir tabla y propósito: `profiles_city_length`; sufijos PostgreSQL `_pkey`, `_fkey`, `_idx` según el objeto. |
| Booleanos | `is_active`, `has_notifications`; expresar una condición. |
| Archivos de esquema | Secuencia global y operación: `008_add_profile_avatar.sql`. |
| Código SQL | Palabras clave en minúsculas siguiendo los scripts actuales; sangría de cuatro espacios y nombres de esquema explícitos. |
| Fechas | `timestamptz` para instantes; generadas en servidor cuando corresponde. |
| Dart | Variables/propiedades `camelCase`, clases `PascalCase`, archivos `snake_case.dart`; el DTO mapea los nombres SQL. |

`snake_case` es nuestra convención de base de datos. PostgreSQL convierte los identificadores sin comillas a minúsculas; `camelCase` obligaría a conservarlos con comillas o perdería las mayúsculas. [Documentación de identificadores](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS).

## Pruebas locales de repetición

Desde `database/tests`, con Node instalado:

```powershell
npm ci --ignore-scripts
npm test
```

Utilizan PostgreSQL en memoria con PGlite y una fixture mínima de Auth: no necesitan claves ni contactan Supabase. Comprueban repetir la entrada sin modificar datos/fechas/objetos, permisos entre usuarios después de repetirla, compatibilidad con la migración anterior y rechazo de una tabla incompatible. La prueba SQL de permisos también debe ejecutarse en Supabase de desarrollo para verificar su entorno real.

## Incremento 008–009: onboarding

El formulario de Crear cuenta usa Supabase Auth y envía `full_name`; el trigger 002 existente crea el perfil. No se añade SQL para guardar contraseñas ni otro insert desde Flutter. Registro y confirmación por correo reutilizan el esquema 001–009 y requieren que esté aplicado en desarrollo.

Añade `profiles.onboarding_completed_at` y `complete_onboarding()`. Solo se permite leer la fecha propia. El cliente no puede escribirla ni reiniciarla directamente: la RPC usa `auth.uid()`, fija fecha de servidor solo si estaba vacía y rechaza falta de sesión/perfil. Comenzar finaliza el recorrido con la misma RPC persistente; la interfaz ya no ofrece Omitir. La fecha pertenece a la cuenta y sobrevive a reinstalación/cambio de dispositivo.

El plan `002_onboarding.json` genera una migración nueva; la inicial permanece intacta. `run_all.sql` ahora incluye ambas fuentes nuevas y acepta tablas de perfiles anteriores (cinco columnas) o actualizadas (seis). La RPC 009 usa `CREATE OR REPLACE` de forma explícita y revisada para repetir su definición; las funciones de la base 001–007 siguen protegidas por existencia. `tests/002_onboarding_permissions.sql` comprueba finalización propia, repetición, prohibición de reinicio y aislamiento de otra cuenta.

## Consulta y edición de Perfil

HU-01.7 reutiliza los grants/políticas/restricciones versionados en 001–009: lectura propia y actualización de display_name/city, sin escribir id, fechas ni onboarding. No hay cambios de esquema ni nueva migración. Prueba adicional `tests/003_profile_edit_permissions.sql` valida columnas de servidor, longitudes Unicode, valores opcionales y reintentos; se ejecuta junto con 001 para aislamiento entre cuentas. `npm test` incluye ambos sobre PGlite. La demo autenticada remota se prepara con `tool/check_profile_remote_test.dart` y configuración local ignorada, según CONFIGURACION; no se acredita por pasar PGlite.

## Incremento de foto privada de cuenta — 010–011

Por solicitud del usuario, tabla/configuración de bucket en tables/010_create_profile_avatar_bucket.sql y RLS en policies/011_profile_avatar_owner_policies.sql. Plan 003_profile_avatars.json genera supabase/migrations/20261008000300_profile_avatars.sql. No cambia columnas de profiles ni SQL aplicado de 001–009; el correo sigue en Auth. Bucket privado, JPEG/2 MiB, ruta estable por usuario, upsert y guardas restrictivas contra políticas amplias ajenas.

Build-RunAll revisa el nuevo plan y añade fuentes idempotentes al final; baseline de perfiles permanece compatible (cinco/seis columnas). Tests incluyen una fixture mínima de Storage con UUID/unique(bucket_id,name) y RLS para PGlite; 004 comprueba aislamiento, ruta y privacidad aun con otra política permisiva. No representa todo el servicio Storage ni demuestra subida/descarga real. Procedimiento de activación y bloqueo de APK en CONFIGURACION/ESTADO; migración remota pendiente.

## Incremento privado de mascotas

Fuentes 013–018, plan 005, migración 20261008000500_pets.sql y salida manual patchs/005_patch_pets.sql. Build-PetsPatch genera el artefacto manual; Build-RunAll lo incorpora. Nombre/especie obligatorios, opcionales normalizados, SELECT con RLS por dueño y RPC autorizadas para creación/edición sin escrituras directas cliente. ID estable deduplica creación; versión y bloqueo de fila rechazan edición concurrente y reconocen reintento idéntico. SQL 005 verifica roles, Unicode, campos, privilegios y reintentos con rollback. Sin fotos ni borrado de mascotas en este incremento; ver ADR-010.

## Tipo, tamaño y galería privada de mascotas

Fuentes 019–025, plan 006, migración 20261009000600_pet_gallery.sql y patchs/006_patch_pet_gallery.sql derivados de Build-PetGalleryPatch. Ejecutar archivo completo después de 005. Build-RunAll agrega el incremento y verifica igualdad de fuentes con las migraciones anteriores. El plan nuevo aporta trazabilidad HU-03.1/HU-03.2/HU-04.1 / RF-03; los planes anteriores conservan sus bytes.

RPC v2 añaden species_detail/size y sustituyen los permisos cliente de RPC antiguas. Reservas privadas pet_photos cuentan en el límite de tres; publish exige objeto propio/MIME/tamaño; remove exige ausencia del archivo. Bucket privado pet-photos, 2 MiB/JPEG, rutas owner/pet/photo.jpg, RLS restrictiva contra políticas permisivas. Test 006 prueba límite, cuentas/anónimo, reintentos, retirada y validación, con rollback. Fixture local Storage agrega metadata; no demuestra contenido real del objeto ni sanitización de bytes en servidor. ADR-012 registra límites de publicación/miniaturas y demo Android/Storage pendiente.

## Archivado y eliminación definitiva protegida

Fuentes030–033 y plan008 generan supabase/migrations/20261009000800_pet_archiving.sql y database/patchs/008_patch_pet_archiving.sql mediante Build-PetArchivingPatch.ps1. Requiere007. Build-RunAll incorpora el nuevo incremento después de eliminación, sin reescribir SQL de planes anteriores.

archive_pet/restore_pet conservan ficha/fotos y controlan dueño, versión, reintento y caso activo. begin_pet_deletion/finish_pet_deletion evolucionan en la nueva fuente031 para rechazar historial antes de limpiar archivos. case_history_at/active_case_count son indicadores de servidor: S3 debe mantenerlos en las transacciones de casos; no exponer comandos cliente para modificarlos. RLS/grants previos conservados. Trigger impide borrar historia y constraints impiden archivar con casos activos. Véase ADR-014 para alcance, baja de cuenta y contrato de integración pendiente.

Prueba008 verifica propietarios, anónimo, archivo/restauración/reintentos, fotos, historial inmutable, contador activo y borrado definitivo sin historia. node --test run_all.test.mjs valida también reejecución completa; los fixtures no prueban servicios remotos.

## Campos obligatorios de mascota — plan009

Fuentes034–035, plan009_pet_required_fields.json, migración20261009000900_pet_required_fields.sql y patchs/009_patch_pet_required_fields.sql, generados mediante Build-PetRequiredFieldsPatch.ps1/Build-Migration.ps1. Requiere008; Build-RunAll incorpora el guard al final. Aplicar el patch completo en desarrollo cuando se autorice su despliegue.

Trigger de insert/update sobre metadatos exige tamaño, edad0–600 y rasgos1–200 puntos de código Unicode, además de nombre/especie/tipo y permisos existentes. No reescribe datos antiguos ni concede escrituras cliente. Su lectura y operaciones de ciclo de vida continúan disponibles; cambios de metadatos requieren completarlos. Test vigente en run_all.test.mjs cubre validación, Unicode, cuentas/anónimo, reintentos, registros antiguos y repetición. Tests históricos de mascotas usan el bundle hasta033 para mantener los contratos que verifican. Véase ADR-016. Activación remota pendiente.

## Incremento de zonas privadas — plan010

HU-02.1 / RF-02,16 / issue#26: fuentes036–039 y [plan010](migration_plans/010_interest_zones.json) generan [migración](../supabase/migrations/20261009001000_interest_zones.sql) y [patch010](patchs/010_patch_interest_zones.sql). Regenerar con `./database/scripts/Build-InterestZonesPatch.ps1`; Build-RunAll incorpora el plan y conserva el historial anterior. SQL requiere Auth existente y roles Supabase; no depende de PostGIS ni cambia mascotas.

La cuenta autenticada lee solo sus zonas vigentes y ejecuta save_interest_zone/delete_interest_zone; sin escrituras directas/anónimo. UUID estable, versión y bloqueo transaccional; eliminación conserva tombstone privado para rechazar reintentos antiguos de creación. Nombres1–60 Unicode, latitud−85..85, longitud−180..180 y radio100–50000m. Restrictive RLS protege frente a políticas permisivas ajenas.

`tests/009_interest_zone_permissions.sql` usa dos cuentas de fixture con rollback. `npm test` comprueba además repetir patch/run_all sin alterar datos, fechas, versiones o eliminaciones. PostgreSQL/PGlite local no prueba Supabase remoto; activación/demo real pendientes. Véase ADR-018 y CONFIGURACION.

## Preferencias privadas de alertas — HU-02.2

Fuentes040–043/plan011: tabla alert_preferences por propietario, RPC save_alert_preferences, RLS restrictiva y grants de lectura/ejecución. Versionado y reintento idéntico preservan datos; recepción general conserva elecciones al pausar. Activar exige tipo/canal. No contiene notificaciones, tokens ni envío. Generar mediante `./database/scripts/Build-AlertPreferencesPatch.ps1`; aplicar completo `patchs/011_patch_alert_preferences.sql` en desarrollo. run_all incluye las fuentes, sin reescribir migraciones anteriores. Prueba `tests/010_alert_preferences_permissions.sql` con cuentas ficticias/ROLLBACK y PGlite; repetición conserva valores, versión y fechas. Patch011 aplicado en Supabase según confirmación del usuario del 10 de octubre; operaciones remotas autenticadas pendientes de verificar. ADR-019 contiene el contrato que consumirá HU-12.

## Procesamiento privado y foto principal — plan012

HU-04.1/#30 y HU-04.2/#31 / RF-03: fuentes044–047, plan012, migración20261010001200_pet_photo_processing.sql y patch012 derivados de Build-PetPhotoProcessingPatch.ps1/Build-RunAll.ps1. Migraciones anteriores conservadas. Activación SQL junto con Edge pet-photo-process, pendiente en desarrollo; instrucciones en supabase/functions/pet-photo-process/README.md y ADR-020.

Solo servicio reserva por UUID/hash y confirma ambos derivados. Revocadas las RPC antiguas de reserva/publicación al cliente y bloqueada escritura autenticada de bytes en los tres buckets. Lectura/retirada limitadas al dueño con políticas restrictivas; SELECT de objetos en retirada/baja permite Storage DELETE. Principal única, selección con versión/CAS, reemplazo determinista, retiradas con tombstone y baja comprobando los tres buckets. Repetición conserva processed_at, hash, principal/versiones y tombstones. Fotos antiguas no se marcan procesadas ni se hacen públicas. S3 necesita proyección pública solo de derivados verificados.

Prueba nueva en run_all.test.mjs ejecuta upgrade desde011, repite patch/run_all y comprueba A/B/anónimo/servicio, RPC/grants/columnas, política amplia, confirmación incompleta, hash conflictivo, principal/reintento/CAS, retirada y baja. 15 pruebas SQL locales aprobadas. La fixture Storage solo representa metadata; pruebas Deno del motor real verifican bytes EXIF/GPS. Cuotas y Storage remoto pendientes.

## Publicación de casos perdidos — plan013

HU-05 / RF-05 / issue#5: fuentes048–051 y plan013 generan supabase/migrations/20261010001300_lost_cases.sql y patchs/013_patch_lost_cases.sql mediante Build-LostCasesPatch.ps1/Build-RunAll.ps1. Requiere012; aplicar patch completo en desarrollo, sin editar migraciones previas. Publicación bloquea mascota, valida actor/version/fotos/fecha/punto, reconoce reintento idéntico, impide otro activo y actualiza evento/historial/contador/versión atómicamente. Tabla base privada, proyección pública por RPC y SELECT de bytes de derivados elegidos/verificados en casos activos, con guards de escritura anónima. Repetición preserva filas/eventos. Prueba PGlite en run_all.test.mjs; concurrencia con sesiones independientes y Storage real pendientes. ADR-021 y CONFIGURACION documentan límites y activación.

## Publicación de casos encontrados — plan014

HU-06 / RF-06 / issue#6: fuentes052–055/plan014 generan migración20261010001400_found_cases.sql y patch014 mediante Build-FoundCasesPatch.ps1/Build-RunAll.ps1. Requiere013 y handler pet-photo-process actualizado para contexto encontrado. No altera fuentes/migraciones aplicadas anteriores. Found cases conservan pet_id nulo y reportero autorizado; selección/fotos verificadas/publicación/evento, permisos, proyección segura y limpieza de drafts con confirmación de ausencia de bytes. Buckets propios privados, sin originales ni DML cliente. Repetición conserva publicaciones/eventos. Prueba PGlite en run_all.test.mjs cubre roles, hash, metadata y reintento; Storage/concurrencia independientes pendientes. ADR-022 y CONFIGURACION explican activación y límites.


Listas/eliminación de casos: aplicar `supabase/migrations/20261010001600_case_collections.sql`, generada con plan016/fuentes057–060. Requiere esquema de casos perdidos/encontrados y patch015. Nuevas RPC de tarjetas del dueño/retirada, permisos y ocultación de eliminados; clientes actualizados dependen de este contrato. Verificación PGlite local, aplicación remota y Android pendientes. No sustituye diagnóstico del incidente previo de publicación.

Plan017 agrega functions/061_found_case_lock_timeout.sql y genera supabase/migrations/20261011001700_found_case_lock_timeout.sql. Repetible sin cambiar cuerpos/permisos; run_all incorpora061 mediante su generador. Activación remota pendiente. CI backend ejecuta las pruebas SQL/Edge, sin despliegue.


Recorridos redefinidos por usuario (11 octubre): fuentes062–065 y plan018 añaden búsquedas posiblemente perdidas y avisos vinculados. [Migración018](../supabase/migrations/20261011001800_recovery_report_links.sql) requiere001–017 y pipeline de fotos anterior. Nuevas RPC autorizadas; viejo publish_found_case deja de ser ejecutable por clientes. Datos antiguos conservan legacy_found y sus relaciones originales. Regenerar con Build-Migration.ps1 -Plan migration_plans/018_recovery_report_links.json y Build-RunAll.ps1. Validación y activación pendientes en ESTADO/CONFIGURACION/ADR-034.


## Lista filtrada de Explorar — plan019

HU-07.1 / RF-13 / issue #32: fuentes066–069, plan019, migración20261015001900_explore_cases.sql y patch019 generados mediante Build-ExploreCasesPatch.ps1/Build-RunAll.ps1. Requiere001–018 y fotos anteriores. PostGIS en extensions con comprobación expresa de esquema, índices GiST sobre puntos públicos y RPC explore_cases autenticada; no cambia filas ni permisos de tablas/Storage. Filtros por tipo/especie/estado/fecha/radio, cursor vinculado a consulta y publicación/origen/UUID. Proyecciones existentes conservan privacidad y lectura de resueltos por autor. Cercanía sobre puntos aproximados para evitar inferencia del exacto.

Pruebas locales usan @electric-sql/pglite0.5.10 y su extensión PostGIS0.2.10 fijadas en package-lock; se ejecuta PostGIS, sin simular sus funciones. El paquete de extensión es experimental y solo de tests. npm test verifica filtros combinados, permisos, ubicación privada distinta, paginación/empates/inserción y repetición. No acredita Supabase hosted, Storage, multiconexión ni rendimiento. Activación remota de019 pendiente; [ficha](../docs/funcionalidades/explorar.md) y [ADR-039](../docs/decisiones/039-explorar-lista-publica-paginada.md).
