# Configuración y validación de la app

## Matching visual —25/10/2026

Implementación local HU-25/#71 y HU-26/#72; no activada en desarrollo alojado.
Aplicar completo [patch040](../database/patchs/040_patch_case_matching.sql) después
de039, nunca el acumulativo para actualizar un servidor. Publicar clientes y
servidor coordinadamente; no se han desplegado desde este chat.

En `apps/platform`, `npm run model:prepare` prepara pesos fijados y muestra
`MATCH_MODEL_DIRECTORY`; configurarlo solo en servidor y ejecutar
`npm run model:smoke`. Después del build,
`node scripts/check-matching-model-server.mjs` verifica modelo real con backend
de prueba. Docker empaqueta pesos y usa Node24/bookworm-slim CPU; no CUDA,
worker ni cron. Docker Engine local no está disponible para verificar ese contenedor.
Android usa `PUBLIC_CASE_WEB_URL` existente; fotos no salen a un proveedor IA.

La evaluación requiere fotos autorizadas e identidades separadas, con manifiesto
descrito en la [ficha](funcionalidades/coincidencias-de-casos.md) y
`npm run model:evaluate -- ruta/manifiesto.json`. No hay precisión acreditada
todavía. Demo de dos cuentas, evaluación y aceptación pendientes.

## Caché de fichas consultadas —24/10/2026

HU-15.3 no requiere configuración remota ni migración. Actualizar cliente Android;
SQLite privado case_cache.sqlite se crea al primer uso y queda fuera de backup/
transferencia. [Recorrido, reglas y evidencia](funcionalidades/fichas-sin-conexion.md).

Desde apps/mobile, validación reproducible:

```powershell
flutter test --no-pub --dart-define=AMBIENT_BACKGROUND_MOTION=false test/offline_cases_test.dart
flutter test --no-pub tool/check_case_cache_remote_test.dart --reporter expanded
```

La primera usa SQLite real local y adaptadores sustitutos para probar errores/
sesiones/widgets. La segunda requiere el archivo privado ignorado
config/profile_test.local.json con las cuentas A/B de desarrollo ya descritas;
publica una búsqueda QA con foto real, prueba reapertura/offline/invalidation
contra servidor y retira únicamente ese fixture. Puede rotar el refresh token B
en ese mismo archivo privado; no lo imprime ni cierra otras sesiones. No usar
datos de producción. Resultado final:16 focalizadas y591 de suite completa,
análisis limpio y remota aprobada. Recorrido Android normal con red realmente
desactivada/reinicio de proceso documentado en ESTADO, sin teléfono físico.

## Validación offline Android y Supabase de desarrollo —23/10/2026

Corrección final aplicada por el usuario:037 y038, [ADR-134](decisiones/134-conflictos-de-publicacion-sin-reintento-postgrest.md).
La suite remota estricta aprueba6/6, incluyendo UUID/payload distinto en perdido
y selección de fotos/campos incompatible en búsqueda. Los conflictos ya devuelven
rechazo de dominio sin timeout. Logs: build/queue-hosted-validation-after-038.log.
Regresión completa posterior:56/56 SQL locales;575/575 Flutter y análisis limpio.
El recorrido Android normal y10 checks SQLite nativos también están aprobados;
validación técnica del alcance completada, con límites de emulador en ESTADO.

Para activar en otro entorno: aplicar TODO patch037 y después038, desde
`database/patchs`, con rol administrativo y cliente Flutter actualizado.038
completa el helper publish_found_case que usa la RPC pública. No modificar037
aplicado ni usar run_all para actualizar el servidor. Los patches conservan
ajustes, propietario, ACL, seguridad y datos. Las cuentas autenticadas no pueden
aplicar DDL. La web ya interpreta HTTP409. No es migración global de40001.

No se inspeccionaron procesos privados de PostgREST ni se ejecutó cancelación/
restart remoto. Procesos antiguos en bucle, si existen, requieren diagnóstico
acotado del administrador; no ejecutar scripts con PID históricos ni afirmar
que cambiar funciones acredita su terminación.

HU-15.1/15.2 validadas en Pixel_9a/API36 y backend real confirmado como desarrollo
por el usuario. Detalles/evidencia en [envíos pendientes](funcionalidades/envios-pendientes.md)
y ESTADO. La prueba remota usa dos cuentas distintas y **crea publicaciones QA**;
no ejecutarla contra producción. Lee `apps/mobile/config/profile_test.local.json`,
ignorado por Git, con URL/clave publicable y credenciales A/B. También admite
PROFILE_TEST_REFRESH_TOKEN_B obtenido por verificación OTP autorizada, sin cambiar
la contraseña de B; actualiza ese token localmente cuando rota. No pasar secretos
por argumentos públicos ni guardarlos en logs. Cuenta A/B idéntica hace fallar
la comprobación. Se borran casos QA por las operaciones existentes y mascotas con
historia quedan archivadas; recibos/auditoría se conservan según contrato.

Desde apps/mobile:

```powershell
flutter test --no-pub tool/check_submission_queue_remote_test.dart --reporter expanded
flutter build apk --profile --target tool/offline_queue_native_validation.dart --target-platform android-x64
flutter build apk --profile --target-platform android-x64 --dart-define-from-file=config/supabase.local.json
```

El primer comando valida pérdida de respuesta tras commit y replay de perdido,
búsqueda, encontrado y avistamiento con servidor real, permisos A/B y revocación
de la sesión de prueba. El segundo genera checks de SQLite nativo con base temporal
separada, migración, reclamaciones y bytes máximos; requiere instalar/abrir su APK
y comprobar QUEUE_NATIVE_VALIDATION_PASS. El tercero restaura la entrada normal;
una compilación por sí sola no acredita ejecutar las pruebas.

Workaround de Java observado en este equipo: antes de invocar Flutter/Gradle,
crear un directorio temporal bajo apps/mobile/android/build y definir solo para
el proceso JAVA_TOOL_OPTIONS con `-Djdk.net.unixdomain.tmpdir=` y la ruta absoluta
`C:\Users\Administrator\Documents\projects\entreHuellas\apps\mobile\android\build\java-local-transport-temporary-directory`.
Se verificó gradlew help y ambos builds; no se modifica gradle.properties global.
JDK usado: Android Studio jbr21.0.7. Command-line Tools23 ya no emite el mensaje
que Flutter3.35.3 busca al comprobar licencias; Platform35 se instala/acepta durante
el build. No hace falta repetir --android-licenses por ese aviso de formato.

El AVD con6GB rechaza el APK debug normal de158MB; profile x64 de53.6MB y la
actualización PT409 de69.3MB se instalan sin borrar datos. El emulador headless inicial cae con0xc0000005 en Windows;
para completar la UI se usa `-gpu angle_indirect -feature -Vulkan -no-snapshot`
y extras temporales de Activity `--ez enable-impeller false --ez enable-software-rendering true`.
Son condiciones del harness, sin cambios de Manifest ni garantías sobre todos los
drivers. Queda comprobado reinicio del proceso sin red; no se probó teléfono físico.

## Bloqueos de cuentas —23/10/2026

HU-14.2 requiere plan034 después de033 y036 después de034. Generar con
`database/scripts/Build-UserBlocksPatch.ps1` y `Build-BlockCaseContactsPatch.ps1`;
aplicar ambos patches completos en
desarrollo y actualizar Nuxt/Flutter. Sin nuevas variables, roles o Firebase;
reutiliza Auth y el servidor de avistamientos configurado. No reaplicar030
confirmado por el usuario. Validar A/B/C, ambas direcciones, respuesta perdida,
cambio/reinicio de cuenta y QR anónimo. [Ficha y pasos](funcionalidades/bloqueos-usuarios.md).
No se ejecutó SQL ni despliegue remoto en este incremento.

Al integrar apelaciones,035 queda reservado a esa funcionalidad y el complemento
de contacto de bloqueos pasa a036/fuente122 con el mismo SQL. El anterior
035_patch_block_case_contacts.sql queda sustituido por036_patch_block_case_contacts.sql;
no ejecutar ambos como incrementos distintos. El orden del repositorio es
034 (bloqueos),035 (apelaciones),036 (contacto). Aplicar solamente lo pendiente;
si se registraron versiones mediante la CLI, comprobar primero su historial.

## Apelaciones de moderación —23/10/2026

HU-14.4 requiere030 y plan035. Generar mediante
`database/scripts/Build-AppealsPatch.ps1` y aplicar completo
`database/patchs/035_patch_moderation_appeals.sql` en desarrollo antes de desplegar
los clientes. Si se usan migraciones, aplicar su equivalente035 una sola vez;
no aplicar ambas copias como migraciones independientes. No reaplicar030.
035 no depende de034 (bloqueos), que puede integrarse por separado sin renumerar.
No requiere nuevas variables ni grants directos a tablas. El revisor existente
debe estar asignado por servidor; una cuenta normal no recibe ese permiso.

Verificar con dos autores y una cuenta revisora: decisión propia/ajena,
apelación/reenvío, respuesta/reenvío, consulta del autor, revocación del revisor
y decisión original conservada. Web usa Inicio → Mis apelaciones y
Denuncias → Revisar apelaciones; Android usa Perfil → Mis apelaciones.
El incremento dejó SQL/remoto/Android instalado pendientes; commit/push no
equivalen a despliegue ni a migración aplicada. [Ficha](funcionalidades/apelaciones-moderacion.md).

## Acceso general web —19/10/2026

El acceso canónico /iniciar-sesion ya no exige permiso de revisión. Reutiliza
SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, MODERATION_SESSION_SECRET y
PUBLIC_WEB_ORIGIN exacto. MODERATION_SESSION_SECRET conserva su nombre histórico
y cifra también eh_access con namespace independiente; no es un secreto OAuth.
En local usar http://127.0.0.1:5173 y el mismo puerto del proceso.
En producción configurar las variables en el servicio, nunca NUXT_PUBLIC.

Sin SQL nuevo: Auth/profiles/RLS y complete_onboarding existentes. Bienvenida
compartida por cuenta con móvil. Revisión mantiene require_content_reviewer
por operación; no se asignan roles automáticamente. Cuenta general no implica
permiso administrativo. eh_access HttpOnly/path /api/SameSite Strict/Secure HTTPS,
máximo1h sin refresh token; al vencer se vuelve al acceso.
Los secretos de Google/Facebook siguen en Supabase Auth autohospedado.
Conservar callback /api/moderation/oauth/callback en la allowlist web existente;
no cambia por traducir login/legal. /login, /terms y /privacy redirigen308.
[Alcance y evidencia local](funcionalidades/acceso-web.md).
Pendiente demo con cuentas/proveedores y cookies HTTPS reales; sin despliegue.

## Moderación web — HU-14.3, patch030

Administración/moderación exclusivamente en apps/platform por instrucción del
usuario. Flutter no tiene paneles, menús ni acciones administrativas.029 ya
aplicado según confirmación del usuario;030 también confirmado aplicado.
Sin inspección SQL remota independiente; no reaplicar029/030.

1. [030_patch_content_moderation.sql](../database/patchs/030_patch_content_moderation.sql)
   ya ejecutado según confirmación del usuario; no reaplicarlo.
2. Configurar en el servidor Nuxt SUPABASE_PUBLISHABLE_KEY (clave publicable o
   anon heredada) y MODERATION_SESSION_SECRET aleatorio de al menos32 caracteres.
   Debe ser idéntico entre réplicas; rotarlo invalida cookies anteriores. Nunca
   usar NUXT_PUBLIC ni guardar secretos en el repositorio. Mantener SUPABASE_URL,
   SUPABASE_SERVER_KEY y PUBLIC_WEB_ORIGIN (origen exacto, HTTPS en producción).
3. Elegir una cuenta existente con correo/contraseña y asignarle permiso desde
   una sesión SQL privilegiada del servidor. No hay revisor por defecto ni
   autoasignación desde móvil/web. Sustituir UUID_DE_LA_CUENTA por su UUID real:

```sql
begin;
insert into public.content_report_reviewers(user_id)
select id from auth.users where id='UUID_DE_LA_CUENTA'::uuid
on conflict(user_id) do nothing;
commit;
```

Para revocar, desde el mismo entorno privilegiado:

```sql
delete from public.content_report_reviewers
where user_id='UUID_DE_LA_CUENTA'::uuid;
```

No ejecutar estos ejemplos con el placeholder; no se han ejecutado en remoto.
La asignación es un dato operativo; esquema/grants/RPC están versionados en030.
No usar service_role para decisiones: el servidor ejecuta RPC con JWT del revisor.
La clave secreta existente solo se usa en QR/proxy de foto tras autorizar/auditar.

4. Actualizar Nuxt local; publicación y redeploy requieren autorización de la
   tarea de despliegue. Abrir /moderacion, entrar con la cuenta revisora y probar
   cola → detalle → foto bajo petición → motivo → decisión → recibo → consulta
   actualizada. Las cuentas sin rol reciben denegación, sin datos privados.
5. Verificar QR/lista/mapa/guardados sin contenido oculto, estado operativo del
   caso intacto, restauración y revocación del revisor. Probar dos revisores
   compitiendo sobre la misma versión y reintento tras respuesta perdida.

La sesión usa cookie HttpOnly cifrada/autenticada, SameSite Strict y Secure en
HTTPS; máximo1h, sin refresh token. Se pide nuevo login al expirar. Logout es de
esta sesión web, sin cerrar sesiones Android. No se serializa evidencia en SSR.
Los JWT emitidos conservan su vencimiento; revocar el rol bloquea nuevas
operaciones aun con cookie válida. No se afirma revocación retroactiva de bytes
ya descargados ni de URLs firmadas previamente emitidas. Firebase/FCM fuera del
alcance. [Ficha](funcionalidades/moderacion-web.md),
[ADR-071](decisiones/071-moderacion-exclusiva-platform.md).


**Confirmación posterior18/10:** el usuario ya ejecutó029. No reaplicarlo.
Actualizar/reiniciar Flutter y validar Denunciar contenido → recibo persistido.
Las indicaciones inferiores de029 pendiente quedan sustituidas por esta nota.


## Denuncias de contenido — HU-14.1, patch029

028 aplicado según confirmación del usuario; no reaplicarlo. Para este incremento
aplicar completo [029_patch_content_reports.sql](../database/patchs/029_patch_content_reports.sql)
en desarrollo y actualizar Flutter.029 aún no aplicado ni verificado remotamente.
No requiere Nuxt ni Firebase/FCM. No hay revisores predeterminados: la asignación
en content_report_reviewers es una operación privilegiada de servidor, nunca
metadatos de cuenta ni una acción cliente. Demo real debe probar denunciante,
autor ajeno y revisor/revocación; la tabla de roles no tiene acceso directo cliente.
Las notas antiguas de028 pendiente inferiores quedan sustituidas por esta confirmación.


**Google, auditoría18/10:** el authorize público devuelve302 a Google con
redirect_uri https://entrehuellas-supabase.kormind.com/auth/v1/callback,
sin duplicación. El diagnóstico de ruta duplicada del7/10 es histórico; no
repetir su corrección en un servidor que ya responde así. Falta demostrar el
retorno Android abierto/cerrado; esta consulta no autentica una cuenta ni
valida credenciales OAuth. Sin cambios de servidor ni tokens impresos.

## Cierre y recuperación — HU-13, patch028

027 ya aplicado según confirmación del usuario. Ejecutar **todo**
[028_patch_case_closure.sql](../database/patchs/028_patch_case_closure.sql) en
Supabase de desarrollo y actualizar/reiniciar Flutter. No reaplicar027 ni
reescribir migraciones anteriores. No requiere desplegar Nuxt: el QR existente
consulta el estado cerrado. No se configura Firebase/FCM/Edge/cron (ADR-068).

Validar con responsable y cuenta ajena; dos sesiones cierran el mismo caso,
reintento tras respuesta perdida conserva recibo/motivo/fecha, mismo QR muestra
cierre sin datos privados, web/app rechazan nuevos avistamientos y las consultas
activas/resueltas se actualizan. Comprobar historial/bandeja y publicar otro
episodio de la mascota sin reabrir el anterior. Ver
[ficha](funcionalidades/cierre-y-recuperacion.md) y [estado](ESTADO.md) para
pruebas y limitaciones: Gradle aún bloquea el APK por conexión loopback.


## Seguimiento y alertas — HU-12, 18/10/2026

**Actualización vigente:** el usuario pospone FCM/Firebase. Solo se activa y valida
seguimiento/bandeja con Supabase. El cliente ya no incluye SDK/plugin Firebase,
no observa push ni ofrece registrar el teléfono. No configurar Firebase,
secrets, Edge notification-delivery ni planificador para el incremento actual.
Las instrucciones Firebase/FCM que siguen se conservan como referencia diferida,
no como pasos pendientes para validar HU-12.1/12.2. Véase ADR-068.

026 y [patch027](../database/patchs/027_patch_notifications.sql) ya confirmados
por el usuario; no reaplicarlos. Confirmación comunicada, sin inspección remota
independiente. Actualizar Flutter. Regeneración de artefactos:
Build-NotificationsPatch.ps1 y Build-RunAll.ps1. No repetir025/026/027 ni ejecutar
run_all como sustituto del patch.
No requiere cambiar Nuxt: las escrituras existentes activan los triggers nuevos.

Seguimiento/bandeja funcionan con sesión Supabase y clave publicable, sin Firebase.
Abrir campana → preferencias → activar recepción/tipos/canales, seguir zona propia
o caso y generar un evento nuevo con otra cuenta o desde QR. Instalar no genera
alertas retroactivas. Leer, reiniciar, paginar y abrir caso con permisos actuales.
No confundir Guardados con seguimiento ni asumir que una zona existente se sigue.

Para push Android, registrar en Firebase el identificador existente
`com.example.flutter_application_entrehuellas` (no renombrarlo). Descargar su
google-services.json a apps/mobile/android/app/google-services.json, ignorado
por Git. El plugin Google Services4.4.4 se aplica solo cuando existe ese archivo.
Su configuración nativa permite recibir con app terminada; conservarla junto
con los cuatro valores públicos de compilación del mismo proyecto:

| Define Flutter | Valor del proyecto Android Firebase |
| --- | --- |
| FIREBASE_API_KEY | API key pública del proyecto/app |
| FIREBASE_APP_ID | App ID Firebase Android, no el package name |
| FIREBASE_MESSAGING_SENDER_ID | Número de proyecto / sender ID |
| FIREBASE_PROJECT_ID | ID del proyecto Firebase |

Añadirlos al mecanismo local de dart-defines existente, conservando los de
Supabase/web. Sin los cuatro valores, Firebase no se activa; el botón informa
indisponibilidad y la bandeja sigue operativa. Nunca colocar private_key,
service_role o JSON de cuenta de servicio en esos defines ni en google-services.json.
Dependencias fijadas firebase_core4.0.0/firebase_messaging16.0.0 para el contrato
de registration token HTTP v1; no migrar a FID/APIs de v17 implícitamente.
Referencia: [configuración Android oficial](https://firebase.google.com/docs/android/setup)
y [FCM Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/get-started).

Activar FCM HTTP v1 y configurar secrets/desplegar Edge notification-delivery
según [su README](../supabase/functions/notification-delivery/README.md).
Configurar un planificador de servidor una vez por minuto con secreto seguro;
sin planificador no se envía la cola automáticamente. Nada de esto está
desplegado/programado por este incremento. La autorización actual cubre código
y validación local; no modifica recursos remotos ni claves del usuario.

Demo pendiente: dos usuarios y dos sesiones; no consultar/marcar bandeja ajena;
seguir/dejar de seguir, pausar/tipos/canales, zona fuera/dentro de radio;
FCM caído → alerta guardada → restaurar proveedor → reintento sin duplicar
bandeja; token UNREGISTERED y token renovado; cierre antes del reintento;
permiso denegado/aceptado, app abierta/en segundo plano/terminada, login al tocar
aviso, cambio de cuenta y logout offline. Se acepta repetición del push tras acuse
perdido; no se acredita entrega solo con estado sent.

Intentos locales de APK debug (normal y preferencia IPv4) bloqueados por Gradle:
`java.io.IOException: Unable to establish loopback connection` antes de compilar.
No hay APK nuevo acreditado; compilar y ejecutar Android sigue pendiente.

## Cronología y revisión — HU-11, 18/10/2026

El usuario indicó «ok ya esta» tras la entrega025; se conserva esa confirmación,
sin inspección remota independiente. Este incremento requiere aplicar únicamente
el nuevo [patch026](../database/patchs/026_patch_case_timeline.sql) sobre025 y
actualizar Flutter. Regenerar con `./database/scripts/Build-CaseTimelinePatch.ps1`
y `./database/scripts/Build-RunAll.ps1`. No editar SQL generado ni reaplicar
incrementos anteriores confirmados.

La app usa las RPC autenticadas con clave publicable/sesión; no se añade secreto
ni se requiere cambiar Nuxt para estas lecturas/revisiones. Probar con responsable
y usuario ajeno: ficha→Ver historial→avistamiento web/app→foto/punto privados→
clasificar con motivo→historial. Probar recepción en orden diferente del observado,
tardíos, dos sesiones con misma versión, respuesta perdida tras guardar y
reintento de la misma orden. Al cerrar, lectura persiste y revisión nueva se
rechaza. Eliminar caso/mascota oculta acceso. Concurrencia multiconexión,
permisos hosted y Android real siguen pendientes. [Ficha](funcionalidades/cronologia-y-revision.md).

## Avistamientos Android — HU-10.2, 18/10/2026

Requiere024 ya confirmado por el usuario. Aplicar solo el nuevo
[patch025](../database/patchs/025_patch_app_sightings.sql) en desarrollo y activar
el servidor Nuxt actualizado junto con la app. No repetir022/023/024 por este
incremento. Generar artefactos desde raíz con
`./database/scripts/Build-AppSightingsPatch.ps1` y `./database/scripts/Build-RunAll.ps1`.
No editar los SQL generados ni ejecutar automáticamente escrituras remotas.

Flutter conserva URL/clave publicable y sesión. `PUBLIC_CASE_WEB_URL` debe ser
el origen HTTPS del servidor (predeterminado https://entrehuellas.app).
La ruta `/api/app/cases/{lost|found}/{id}/sightings` recibe bearer de usuario;
el adaptador servidor verifica con Supabase Auth y usa su configuración privada
existente. El móvil no envía Origin de navegador. No añadir CORS permisivo,
service_role ni claves secretas al archivo Flutter.

Demo pendiente: abrir ficha activa→Reportar avistamiento→fecha/hora real→GPS
denegado y punto manual→cámara cancelada y galería→enviar sin/con foto. Verificar
recibo/registro privado y repetir exactamente la misma orden tras respuesta
ambigua; comprobar que otra cuenta no lee evidencia, y que caso cerrado/no
disponible rechaza un envío nuevo. No buscar estos registros en la lista anterior
de avisos públicos: revisión/cronología privada se implementará en HU-11.
No se acredita dispositivo real, permisos hosted o concurrencia multiconexión
por pasar pruebas con fixtures. [Ficha](funcionalidades/avistamientos-android.md).

Ubicaciones17 octubre: ejecutar Flutter desde apps/mobile y Nuxt desde
apps/platform. F5 raíz apunta a apps/mobile y conserva config/supabase.local.json;
los valores locales se trasladaron sin cambios. Dokploy debe usar contexto
apps/platform y Dockerfile apps/platform/Dockerfile al desplegar esta revisión.

Vue/Nuxt17 octubre: Node24.15+ recomendado; npm ci en apps/platform y
npm run dev para desarrollo. No instalar Nuxt/Vue globalmente. Typecheck,
unitarias, build y pruebas de producción documentados en
[DESARROLLO.md](../apps/platform/DESARROLLO.md). Dokploy conserva variables,
contexto, stage y puerto; el comando de imagen ahora ejecuta .output de Nitro.
Publicar la rama nueva antes de redeploy. Usuario confirma022/023 aplicados y
generación/lectura QR operativas en la versión anterior; no se reejecuta SQL.

Facebook,17 de octubre: botón preparado en login sobre Supabase OAuth y retorno
móvil existente. Activar Meta y el servicio Auth de Dokploy según
[LOGIN_FACEBOOK.md](LOGIN_FACEBOOK.md), con callback HTTPS exacto y secreto
solo en servidor. Sin configuración remota ni demo Android acreditadas.

Dokploy17 octubre: preparación para Application desde GitHub, Dockerfile
apps/platform/Dockerfile, contexto apps/platform y puerto interno5173.
Campos, Environment, DNS/TLS, Auto Deploy y comprobaciones en
[DOKPLOY.md](../apps/platform/DOKPLOY.md). El usuario añade secretos en el panel;
no se incorporan a Git/build. Healthcheck es de proceso, no valida Supabase.

Web QR16 octubre: consulta HU-09 implementada localmente en apps/platform.
Aplicar [023](../database/patchs/023_patch_public_qr_case.sql) tras022 en desarrollo;
hosting Node22 con secreto servidor/TLS, sin caché/logs de tokens. Pasos en
[README](../apps/platform/README.md). No se ha desplegado; PUBLIC_CASE_WEB_READY
sigue false y formulario HU-10.1 pendiente. Actualiza el pendiente de implementación
de la nota histórica de carteles siguiente.

Carteles/QR (16 octubre): aplicar [patch022](../database/patchs/022_patch_case_posters.sql) después de001–021, con fotos operativas. Configurar PUBLIC_CASE_WEB_URL (base acordada: https://entrehuellas.app) y mantener PUBLIC_CASE_WEB_READY=false hasta implementar/verificar la ficha pública de HU-09 en `/c/<slug>`. El ejemplo versionado ya contiene estos valores públicos. No habilitar con una página provisional: al revisar, GET/ devuelve404. Con ready=false o URL no HTTPS no se crean enlaces ni PDFs; la UI informa mediante toast. No hay claves nuevas de servidor ni cambio de Auth. Los plugins printing/share_plus se prueban tras la próxima recompilación nativa; no se genera APK por instrucción del usuario. [Ficha](funcionalidades/carteles-qr.md), [ADR-053](decisiones/053-carteles-pdf-y-enlaces-qr.md).

Guardados/Ciudad (16 octubre): para Explorar → Guardados, aplicar [patch021](../database/patchs/021_patch_saved_case_list.sql) o migración20261016002100_saved_case_list.sql después de020 (aplicado según usuario). Build-SavedCaseListPatch/Build-RunAll generan fuentes074–076; no reescribir020. **021 pendiente**, sin SQL remoto ejecutado ni pruebas por instrucción vigente. Ciudad no necesita migración: buscador ahora en places, mismo PLACE_SEARCH_URL, modo layer=city/caché separada y selección explícita; guardar etiqueta mantiene límites/RLS del perfil. Endpoint sustituido debe admitir filtro de ciudades y GeoJSON reconocido. Análisis limpio; cobertura/recorridos Android por verificar. [ADR-051](decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

Actualización posterior: el usuario confirma aplicado el patch020. No equivale a verificación independiente de RPC/RLS ni prueba Android; esas comprobaciones siguen pendientes y no se ejecutan pruebas por instrucción vigente.

Casos guardados,16 de octubre: aplicar020 después de001–019 en desarrollo. [Patch020](../database/patchs/020_patch_saved_cases.sql)/migración20261016002000_saved_cases.sql derivados de070–073/plan020 con Build-SavedCasesPatch/Build-RunAll. Activar cliente y RPC juntos: sin contrato el marcador informa error de consulta, sin simular guardado. Sin claves/SDK/variables nuevos. Sin SQL remoto ni pruebas ejecutadas por petición del usuario; validar permisos/concurrencia/repetición antes de desplegar. [Ficha](funcionalidades/casos-guardados.md).

Base del chat 00, 6 de octubre de 2026. Flutter 3.35.3 / Dart 3.9.2. Ejecutar los comandos desde `apps/mobile`. Se mantienen el nombre del paquete y las plataformas existentes. Android conserva el identificador provisional `com.example.flutter_application_entrehuellas`; revisarlo antes de distribuir.

## Arranque

### Android y VS Code después del traslado a apps/mobile

Abrir la raíz actual del repositorio o directamente `apps/mobile`. Si VS Code
estaba abierto durante el movimiento, ejecutar **Developer: Reload Window**,
abrir `apps/mobile/lib/main.dart` y seleccionar **Entre Huellas - desarrollo local**
en Ejecutar y depurar. Los perfiles de ambas carpetas conservan su `cwd` correcto.
No usar **Enable android for this project**: `apps/mobile/android` ya existe.

El error `No supported devices found ... emulator-5554` indica que ese dispositivo
no está conectado en ese momento. Comprobar y arrancar el AVD existente desde
`apps/mobile`:

```powershell
flutter emulators
flutter emulators --launch Pixel_9a
flutter devices
```

Esperar hasta que aparezca como Android conectado (no `offline`), seleccionarlo
con **Flutter: Select Device** y pulsar F5. El ID del AVD (`Pixel_9a`) y el del
dispositivo encendido (`emulator-5554` en esta comprobación) son distintos;
usar el ID que muestre `flutter devices` para ejecutar por terminal:

```powershell
flutter run -d emulator-5554 --dart-define-from-file=config/supabase.local.json
```

Esto no exige cambiar `main.dart`, el nombre del paquete ni regenerar Android.
Referencia: [configuración Android de Flutter](https://docs.flutter.dev/platform-integration/android/setup).

### Arranque por terminal

```powershell
Set-Location apps/mobile
flutter pub get --enforce-lockfile
flutter run -d chrome
```

Sin configuración se puede navegar entre inicio y acceso. El acceso muestra que falta configurar el servicio. Registro, correo/Google, perfil, baja y exportación pertenecen a HU-01 / RF-01,34; no están implementados por esta base.

## Supabase

1. Crear o identificar un proyecto de desarrollo en Supabase. Obtener su URL HTTPS y la clave **publicable** `sb_publishable_...`.
2. Copiar el ejemplo y completar ambos valores en el archivo local:

```powershell
Copy-Item config/supabase.local.example.json config/supabase.local.json
flutter run --dart-define-from-file=config/supabase.local.json
```

`*.local.json` está ignorado por Git. El ejemplo contiene valores vacíos y puede ejecutarse para comprobar el arranque sin configuración. Los `dart-define` se incluyen en el cliente; usar solo configuración pública. El validador rechaza claves secretas y JWT heredados, incluyendo `service_role`. Esta base requiere la clave publicable moderna. Nunca introducir credenciales SQL o claves de servidor.

### Configuración por entorno y ejecución

El archivo se crea y completa una sola vez por entorno/equipo. Flutter necesita saber qué archivo usar al ejecutar o compilar: `--dart-define-from-file` incorpora esos valores a esa ejecución/build. No se lee un archivo del ordenador del desarrollador desde el teléfono del usuario; una vez instalada la app, el usuario no ejecuta comandos. Si cambias esos valores, detén y vuelve a iniciar la app o genera otro build; hot reload no los actualiza.

Para evitar escribir el comando durante el desarrollo, se añadieron perfiles de VS Code, tanto abriendo la raíz del repositorio como abriendo solo la carpeta Flutter. Con las extensiones Dart/Flutter instaladas, abre **Ejecutar y depurar**, selecciona **Entre Huellas - desarrollo local**, elige un dispositivo y pulsa **F5**. El perfil pasa el archivo local automáticamente. Si aún no existe ese archivo, usa **Entre Huellas - sin Supabase**. Los perfiles contienen rutas y argumentos, sin credenciales. Se validó su JSON y sus rutas; el lanzamiento interactivo F5 queda pendiente. [Configuraciones de ejecución de Dart Code](https://dartcode.org/docs/launch-configuration/).

También se puede ejecutar desde **Run/Debug de `main.dart`** con la extensión Dart/Flutter. El perfil local declara `templateFor` para `lib`, de modo que los lanzamientos predeterminados de archivos de la app utilizan sus argumentos de Supabase sin seleccionar manualmente el perfil. La plantilla cubre `lib` y no se aplica a las pruebas. Detener la ejecución con el botón cuadrado de la barra de depuración y volver a pulsar Run/Debug; hot reload o adjuntarse a una ejecución anterior no incorporan los dart-define. Los botones de extensiones distintas, como Code Runner, no utilizan necesariamente los perfiles de Dart.

La validación distingue configuración vacía, inválida, fallo de inicialización y SDK preparado. `Servicio de acceso preparado` no comprueba conectividad, credenciales remotas ni permisos. Bootstrap inicializa el SDK e inyecta `SupabaseAuthDataSource` y `AuthRepositoryImpl`. El caso de uso `WatchAuthSession` entrega la identidad a `AuthViewModel`, que expone el estado de pantalla. Reiniciar la app reintenta el arranque. Esta separación sigue [las reglas de arquitectura](REGLAS_ARQUITECTURA.md).

En Supabase Dashboard, **Authentication > URL Configuration > Redirect URLs**, registrar exactamente:

```text
entrehuellas://login-callback/
```

Al implementar HU-01, usar `AppConfig.authRedirectUri` como `redirectTo` en OAuth y como `emailRedirectTo` en correo, según el método del SDK. No añadir comodines para esta ruta. La web futura tendrá su propia URL HTTPS; este esquema corresponde al retorno móvil. [Redirecciones oficiales de Supabase](https://supabase.com/docs/guides/auth/redirect-urls).

Android registra esquema `entrehuellas`, host `login-callback` y ruta `/`, permiso INTERNET y actividad `singleTop`. iOS registra el esquema y desactiva también el manejador de enlaces de Flutter; no se compiló iOS en Windows. Supabase Flutter procesa los enlaces mediante app_links y PKCE; go_router conserva las rutas de la UI. [SDK de Supabase Flutter](https://pub.dev/packages/supabase_flutter), [deep links de Flutter y plugins](https://docs.flutter.dev/ui/navigation/deep-linking).

Las tablas de perfil, grants, RLS, funciones y triggers están preparados en `database`, siguiendo [su estructura, generación y ejecución](../database/README.md). No se han aplicado al proyecto remoto. Comprobar permisos con dos usuarios antes de declarar HU-01 completa. El JSON de Flutter contiene configuración pública; no es una conexión SQL para ejecutar esos scripts.

## Prueba Android pendiente

Completar Android SDK Command-line Tools desde Android Studio y revisar los términos con `flutter doctor --android-licenses`. Con un dispositivo Android conectado:

```powershell
flutter doctor
flutter devices
flutter run --dart-define-from-file=config/supabase.local.json
```

En otra terminal, con adb disponible, comprobar apertura con la app cerrada y abierta:

```powershell
adb shell am start -W -a android.intent.action.VIEW -d 'entrehuellas://login-callback/' com.example.flutter_application_entrehuellas
```

Ese enlace sin código comprueba apertura, no autenticación. En S1 iniciar un flujo real de correo/OAuth en el mismo dispositivo, completar el retorno y comprobar sesión restaurada, rechazo de callback inválido y cierre de sesión. PKCE necesita el verificador almacenado al iniciar el flujo; no simular éxito pegando un código arbitrario. No registrar ni compartir la URL de retorno que contiene códigos/tokens.

## Comprobaciones

El icono Android se genera a partir de los originales de `logo`. Para actualizarlo y comprobarlo instalado, seguir [logo/README.md](../logo/README.md). Una modificación del icono necesita reconstruir/reinstalar; hot reload actualiza el código Flutter, no los recursos del launcher.

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --no-pub
```

El workflow `.github/workflows/flutter.yml` fija Flutter 3.35.3 y ejecuta resolución con lockfile, formato, análisis y pruebas sin credenciales. Su ejecución en GitHub requiere publicar los cambios; el archivo local no acredita una ejecución remota. Consultar [ESTADO.md](ESTADO.md) para resultados y pendientes reales.

## Probar el login actual

El formulario conecta correo/contraseña y Google con Supabase Auth. En una consulta de solo lectura a la configuración pública de Auth del proyecto local, el 7 de octubre de 2026, Google y correo figuraron habilitados; Apple, deshabilitado y actualmente retirado de la interfaz. Esto no verifica las credenciales OAuth ni el recorrido de retorno.

1. Para ejecución manual en desarrollo, pegar `database/run_all.sql` completo en SQL Editor siguiendo [database/README.md](../database/README.md). Puede repetirse sobre una base compatible; conservar la migración inicial para el historial, sin aplicarla después sobre los mismos objetos ya creados. No requiere colocar claves SQL en Flutter.
2. En **Authentication → URL Configuration → Redirect URLs**, registrar exactamente `entrehuellas://login-callback/`.
3. En **Authentication → Sign In / Providers → Google**, comprobar las credenciales del cliente OAuth web. En Google Cloud, la URI autorizada de retorno es la de Supabase (`https://<project-ref>.supabase.co/auth/v1/callback` en hospedaje gestionado, o `https://<dominio-publico>/auth/v1/callback` con dominio propio); el esquema móvil se configura en Supabase, no como URI HTTPS de Google. [Guía oficial de Google](https://supabase.com/docs/guides/auth/social-login/auth-google).
4. Detener la app y volver a ejecutar ▶ desde `main.dart` con el perfil local y el emulador seleccionado. Abrir acceso.
5. Correo: ingresar una cuenta existente en Authentication → Users, con correo confirmado si el proyecto lo exige. Para una prueba inicial, crearla desde Add user; no insertar contraseñas mediante nuestros scripts SQL.
6. Google: pulsar el botón, elegir cuenta en el navegador y completar el retorno. La app debe mostrar **Sesión activa.**; abrir el navegador por sí solo no confirma éxito.
7. Cerrar sesión, volver a ingresar y reiniciar la app para revisar persistencia. Probar también una contraseña incorrecta: debe aparecer un mensaje seguro y permitir reintentar.

En web, OAuth usa el retorno de Site URL configurado en Supabase; la prueba principal de este incremento es Android. Registro, recuperación y edición de perfil no están implementados aún. [API oficial OAuth Flutter](https://supabase.com/docs/reference/dart/auth-signinwithoauth), [perfiles y triggers de Auth](https://supabase.com/docs/guides/auth/managing-user-data).


## Diagnóstico del callback Google con dominio propio

El 7 de octubre de 2026 se consultó el endpoint público `/auth/v1/authorize?provider=google`, solicitando el retorno móvil y sin seguir la redirección ni autenticar una cuenta. La respuesta HTTP 302 envió a Google:

```text
https://entrehuellas-supabase.kormind.com/auth/v1/auth/v1/callback
```

La captura de Google Cloud autoriza `https://entrehuellas-supabase.kormind.com/auth/v1/callback`. La ruta duplicada explica `redirect_uri_mismatch`: Google exige coincidencia exacta de la URI con el cliente OAuth usado.

En la configuración efectiva del servicio Auth/GoTrue del servidor, el valor debe ser:

```dotenv
GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI=https://entrehuellas-supabase.kormind.com/auth/v1/callback
```

Revisar el Compose o la plantilla del despliegue que construye esa variable. Por ejemplo, si `API_EXTERNAL_URL` ya termina en `/auth/v1`, añadir nuevamente `/auth/v1/callback` duplica la ruta; en esa composición corresponde `${API_EXTERNAL_URL}/callback`. La ubicación y composición exactas dependen del despliegue. Añadir una variable al `.env` no basta si Compose la sobrescribe o no la pasa al contenedor. Recrear/redesplegar el servicio Auth para aplicar el cambio y comprobar de nuevo su redirección. No modificar a ciegas `API_EXTERNAL_URL`, que también puede ser usado por otras partes del servicio.

Mantener el callback correcto en las URIs autorizadas del mismo cliente web de Google y `entrehuellas://login-callback/` en la allowlist de retorno de Auth. Esta corrección pertenece al servidor; `supabase.local.json` conserva la URL base de Supabase y la clave publicable de Flutter. No se ha accedido a la configuración privada ni modificado el despliegue. No añadir la ruta duplicada a Google como solución.

Referencias: [OAuth autohospedado de Supabase](https://supabase.com/docs/guides/self-hosting/self-hosted-oauth), [coincidencia del redirect URI en Google](https://developers.google.com/identity/protocols/oauth2/web-server#authorization-errors-redirect-uri-mismatch).

## Activar onboarding por cuenta

Volver a ejecutar el contenido completo del `database/run_all.sql` actualizado en SQL Editor. Ahora incluye 008–009: `profiles.onboarding_completed_at` y RPC `complete_onboarding()`. No reejecutar la migración inicial estricta sobre los objetos ya creados. En despliegue por CLI, aplicar la nueva migración `20261007000200_onboarding_completion.sql` respetando el historial existente.

Reiniciar la app para incorporar el asset. Sin sesión se abre login. Tras entrar, completar las tres etapas y pulsar Comenzar; cerrar sesión y volver a ingresar con la misma cuenta debe abrir la app directamente. Otra cuenta sin completar onboarding debe ver sus tres etapas. Si el perfil o la columna aún no existen, se presenta un error de preparación con reintento: aplicar SQL antes de probar este recorrido.

Si tras aplicar SQL PostgREST aún no reconoce la columna o RPC nueva, recargar su caché de esquema con `notify pgrst, 'reload schema';` desde SQL Editor y reintentar. No altera el esquema ni reemplaza la migración.

## Probar registro y recuperación por código (actualizado el 8 de octubre)

Registro y recuperación usan ahora códigos OTP de seis dígitos escritos dentro de la app. El usuario puede leer el correo en una PC y escribirlo en el teléfono. El código se valida directamente contra Auth con correo y token; no requiere el verificador PKCE de la instalación que lo solicitó. Google y los callbacks existentes conservan su configuración de Redirect URLs.

Revisar que Confirm signup y Reset password incluyan `{{ .Token }}`. El usuario informa que el correo actual ya muestra un código alternativo de seis dígitos; ese código se puede usar en la nueva pantalla. Para presentar solo código y evitar instrucciones de enlace, se prepararon las fuentes [confirm_signup.html](../supabase/auth/templates/confirm_signup.html) y [recovery.html](../supabase/auth/templates/recovery.html), junto a su [procedimiento de aplicación](../supabase/auth/templates/README.md). No se desplegaron ni se modificó Auth remoto en esta tarea.

En el Auth autohospedado con Dokploy, comprobar la configuración efectiva `GOTRUE_MAILER_OTP_LENGTH=6`, caducidad, límites de envío/verificación, SMTP y política de contraseña de al menos ocho caracteres. La espera del cliente es 60 segundos; no sustituye límites del servidor. Las URLs de las plantillas deben estar disponibles desde el contenedor y sus variables transmitidas por Compose antes de redesplegar. No usar una ruta de Windows como URL de plantilla ni guardar secretos en estos HTML.

### Texto de caducidad

Consulta de solo lectura del 8 de octubre: `/auth/v1/health` devuelve Auth `v2.189.0`; `/auth/v1/settings` no expone caducidad del correo. Esa versión [usa 86400 segundos (24 horas) como valor por defecto](https://github.com/supabase/auth/blob/v2.189.0/internal/conf/configuration.go#L1096); no demuestra el valor efectivo del despliegue. Revisar `GOTRUE_MAILER_OTP_EXP` en el servicio Auth de Dokploy y su entorno efectivo: el Compose puede sustituir el valor por defecto.

Cuando se confirme el plazo real, añadir `EMAIL_OTP_VALIDITY_MINUTES` con un entero positivo a la configuración pública de compilación (`config/supabase.local.json` o `--dart-define`) para mostrar «Válido por N minutos.» en ambas confirmaciones. N debe ser `GOTRUE_MAILER_OTP_EXP / 60` si el plazo es un número entero de minutos. Sin valor confirmado, la app muestra solo «Ingresa el código que llegó a {correo}.» y evita afirmar una duración inventada. Este define no cambia la caducidad del servidor ni el contador independiente de 60 segundos para reenviar.

### Registro

1. Desde login, Crear cuenta con nombre, correo, contraseña y confirmación. Con confirmación activa, Revisa tu correo muestra mascota, seis casillas y espera para reenviar. Sin confirmación y con sesión devuelta, entrar al onboarding como antes.
2. Leer el correo en la PC y escribir/pegar el código en el celular. Se verifica automáticamente al completar seis dígitos; si falla hay reintento explícito. `verifyOTP(type: email)` debe devolver sesión antes del onboarding. Probar un código que comience con cero y pegado completo.
3. Probar código incorrecto, vencido/usado y reenvío tras 60 segundos. Un error mantiene el correo y permite corregir/reintentar. Reenvío limpia las casillas. Comprobar perfil/nombre y primer onboarding; el trigger de perfiles ya versionado se mantiene, sin tablas nuevas.

### Recuperación

1. Desde ¿Olvidaste tu contraseña?, introducir correo y Enviar código. La orientación es neutral para cuenta existente/desconocida; reenvío usa la misma solicitud de recuperación y espera 60 segundos.
2. Leer el código en otro equipo y escribirlo en la app. `verifyOTP(type: recovery)` debe establecer sesión de recuperación y abrir Nueva contraseña antes de onboarding/Inicio. No se debe usar signInWithOtp ni un OTP de registro para recuperar contraseña.
3. Probar contraseña corta, confirmación distinta, contraseña anterior y política del servidor; guardar y revisar éxito. Regresar al login cierra la sesión local de recuperación. Comprobar que la nueva contraseña permite entrar y la anterior falla.
4. Probar código inválido/vencido/usado, desconexión al verificar/guardar y cancelación mediante X/retorno de sistema. Un código incorrecto se muestra en las casillas; no abandona el formulario ni habilita reset. Un fallo de cierre permite reintentar.

Si se interrumpe/reinicia la app después de verificar el código y antes de cambiar contraseña, solicitar un código nuevo: el propósito adicional de recuperación no se persiste por instalación. Los OTP no se guardan ni se registran en logs locales.

Las pruebas usan SDK real con HTTP y almacenamiento sustituidos, incluidos dos clientes independientes sin compartir almacenamiento PKCE. Cubren la verificación por código, propósito correcto, respuesta sin sesión, vencimiento y recorrido UI/router. No contactan el servidor, envían correo ni cambian contraseñas reales. Sigue pendiente demostrar lectura en PC → entrada en teléfono con el Auth de desarrollo.

Referencias: [verifyOTP](https://supabase.com/docs/reference/dart/auth-verifyotp), [Token en plantillas](https://supabase.com/docs/guides/auth/auth-email-templates), [configuración autohospedada](https://github.com/supabase/supabase/blob/master/docker/CONFIG.md), [updateUser](https://supabase.com/docs/reference/dart/auth-updateuser).

## Perfil: validación con cuentas reales de desarrollo

El formulario Perfil consulta y modifica solamente nombre visible y ciudad. Campos opcionales, hasta 120 caracteres Unicode; blanco/vacío se guarda como null. El esquema 001–009 debe estar aplicado. No se necesita una nueva migración para este incremento. Si falla la consulta, usar Reintentar; si falla el guardado, los campos se conservan y puede repetirse Guardar cambios.

Para verificar permisos/persistencia con dos cuentas dedicadas de desarrollo:

1. Copiar `config/profile_test.local.example.json` a `config/profile_test.local.json` dentro de la app. El destino queda ignorado por Git. Completar URL/clave publicable y los cuatro valores de las dos cuentas confirmadas de prueba; no compartir contraseñas por chat ni versionarlas.
2. Ejecutar desde `apps/mobile`:

```powershell
flutter test --no-pub tool/check_profile_remote_test.dart --dart-define-from-file=config/profile_test.local.json
```

La prueba ingresa con A y B, modifica datos editables de A y repite el guardado, vuelve a ingresar con un cliente nuevo, comprueba lectura/edición cruzadas rechazadas y columnas de servidor protegidas. Restaura nombre/ciudad originales de A en finally; la fecha updated_at cambia legítimamente. Sin los valores, la prueba queda omitida explícitamente y no contacta el servidor.

Para Android, comprobar además desde la app: entrar → Perfil → editar → guardar → cerrar/reabrir app → consultar; provocar fallo de red al guardar y reintentar; verificar salida y restauración de sesión. La prueba con nuevo cliente no acredita almacenamiento de sesión, SMTP/OAuth ni comportamiento Android. No ejecutar contra cuentas de producción.

Comprobación SQL adicional en desarrollo: `database/tests/003_profile_edit_permissions.sql`; crea fixtures temporales dentro de una transacción y termina con ROLLBACK. `npm test` en database/tests ejecuta los permisos/invariantes en PostgreSQL en memoria, distinto del entorno Supabase remoto.

## Activar foto de perfil privada

El correo del Perfil es de solo lectura y viene de la sesión de Auth. La foto se elige desde el avatar/cámara o Añadir/Cambiar foto; se normaliza a JPEG y usa Storage privado.

Con perfiles/onboarding ya aplicados, ejecutar en SQL Editor de **Supabase de desarrollo** el patch generado `database/patchs/004_patch_profile_avatars.sql`, completo y sin selección parcial, con rol postgres. Crea bucket privado profile-avatars y permisos por propietario. Sustituye la migración 003 que falló con «must be owner of table objects»: usa RLS administrado ya activo sin ALTER TABLE storage.objects. La migración 004 conserva esta corrección en el historial; 003 se conserva pero no se vuelve a ejecutar manualmente. No se ha aplicado remotamente desde esta tarea: falta una conexión administrativa al proyecto. Alternativa para bootstrap repetible compatible: `database/run_all.sql`, regenerado con fuentes 001–010 y 012 en lugar de 011. No editar salidas a mano; regenerar con Build-AvatarPatch/Build-RunAll.

Después, detener la app y ejecutarla/compilarla de nuevo desde el entorno Flutter que permita Gradle; el selector nativo nuevo no aparece mediante Hot Restart. El intento de APK de esta tarea falló antes de compilar la app con `Unable to establish loopback connection`. No hay APK ni instalación nuevos acreditados. iOS tiene descripción de acceso a galería, sin build iOS en Windows.

Demo necesaria: A selecciona JPG/PNG y confirma foto/correo; reiniciar y consultar; B no puede leer/firmar/sobrescribir objeto de A; cortar conexión, reintentar sin otro objeto; cancelar selección; comprobar permiso denegado y recuperación de actividad Android con la misma cuenta, sin subir automáticamente la imagen recuperada. Ejecutar `database/tests/004_profile_avatar_permissions.sql` aparte en desarrollo: prueba filas/políticas con rollback; no prueba los bytes del servicio Storage.

### Selector no abre después de Hot Restart

Comprobación del 8 de octubre: el APK instalado en emulator-5554 no contiene ImagePickerPlugin aunque el registrante del proyecto lo declare. Detener la ejecución Flutter anterior y abrir una terminal externa o el IDE en apps/mobile, después ejecutar:

```powershell
flutter run --dart-define-from-file=config/supabase.local.json -d emulator-5554
```

Esto recompila e instala la versión con selector nativo; no desinstalar ni borrar datos. Desde esta sesión la compilación vuelve a fallar por conexión loopback de Java/Gradle, antes de compilar Android. Cerrar/reabrir el APK antiguo o hacer Hot Restart no instala el plugin. El selector de galería Android no requiere agregar permisos generales de almacenamiento. Probar galería primero y luego confirmación de subida; el toast genérico no identifica por sí solo cuál de las dos etapas falló.

## Activar Mis mascotas en desarrollo

Con el esquema de acceso existente, ejecutar TODO database/patchs/005_patch_pets.sql en SQL Editor con rol postgres, sin selección parcial. El patch es generado desde plan 005/fuentes 013–018 y no depende del bucket de avatar; NO vuelve a ejecutar la migración 003 de Storage fallida. Regenerar mediante ./database/scripts/Build-PetsPatch.ps1; no editar el patch ni la migración a mano. run_all incorpora este incremento para bootstrap repetible.

No aplicado remotamente desde esta entrega. La app ofrece consulta real de mascotas; antes del patch mostrará error/reintento, nunca un supuesto listado vacío. Una vez aplicado: A registra Luna con opcionales desconocidos, abre ficha, edita y reinicia; B no consulta ni modifica esa mascota por app/REST/RPC. Probar desconexión/reintento sin duplicados y dos ediciones con versión antigua (la segunda debe rechazar conflicto sin sobrescribir). database/tests/005_pets_permissions.sql usa fixtures con rollback y pruebas de roles/normalización/versionado.

La ampliación de fotos privadas y tipo/tamaño requiere el patch 006 descrito abajo. No desinstalar para ver el incremento; reiniciar Flutter con la configuración local. El plugin de galería requiere el APK recompilado descrito antes.

## Activar tipo, tamaño y fotos privadas de mascotas

Después de aplicar 005, ejecutar **TODO** `database/patchs/006_patch_pet_gallery.sql` en Supabase de desarrollo con rol postgres, sin selección parcial. Creará columnas, RPC v2, metadata, bucket privado y políticas; no altera storage.objects ni exige cambiar su propietario. Regeneración: `./database/scripts/Build-PetGalleryPatch.ps1`; bootstrap completo: Build-RunAll. El patch no fue ejecutado remotamente desde este chat.

Esta versión de la app requiere 006: las RPC v2 validan tipo/tamaño; las anteriores se retiran de los permisos cliente para impedir bypass. Mascotas existentes se conservan; si su especie es other y no tiene detalle, al editar deberá completar el tipo. Tamaño desconocido sigue permitido.

Demo: A registra Conejo/Mediano, añade hasta tres JPG/PNG de galería, guarda y reinicia; consulta ficha/listado y retira una foto desde Editar. Cancelar galería no añade nada. Fallo de foto mantiene borrador y permite Guardar sin otra mascota/archivo; confirmar que no aparece toast de éxito antes de terminar. B no consulta/descarga/firma/sube/sobrescribe/retira archivos de A; anon sin acceso. Probar reserva incompleta, límite en RPC y recuperación de actividad Android como selección pendiente. `database/tests/006_pet_gallery_permissions.sql` usa fixtures/rollback y valida RLS/grants, no bytes reales del servicio.

Las imágenes son privadas del dueño; publicación de originales/miniaturas del QR/casos y sanitización en servidor siguen pendientes de HU-04.1. No se afirma build/instalación Android ni demo remota: el bloqueo Java/Gradle y el APK anterior sin plugin permanecen documentados hasta una compilación funcional.

## Activar eliminación de mascotas — parche 007

Después del parche 006, ejecutar TODO database/patchs/007_patch_pet_deletion.sql en SQL Editor de Supabase de desarrollo con rol postgres. Generar/verificar por database/scripts/Build-PetDeletionPatch.ps1; no editar el resultado ni reescribir migraciones aplicadas. El parche conserva las mascotas existentes y añade marcador, RPC begin_pet_deletion/finish_pet_deletion, restricciones Storage y permisos de eliminación por propietario.

Diagnóstico remoto del 9 de octubre: ambas RPC devuelven 404/PGRST202 (no disponibles en caché de esquema). La RPC create_pet_v2 del mismo proyecto sí responde 401/42501 con rol anónimo, como corresponde a una función existente protegida. Comprobación con clave pública y UUID nulo de prueba; no se intentó borrar una mascota real ni iniciar sesión como usuario. No se dispone aquí de conexión SQL administrativa y el parche NO fue aplicado remotamente.

Tras aplicar el parche, comprobar eliminación con cuenta propietaria, retirada de fotos y reintento; otra cuenta/anónimo deben seguir rechazados. Si Supabase sigue devolviendo PGRST202 después de confirmar el SQL completo, ejecutar NOTIFY pgrst, 'reload schema'; y repetir. Hot Restart actualiza los botones, pero no crea funciones del backend. No reejecutar patches 005/006 ni bootstrap entero para activar exclusivamente esta función.

## Activar archivo reversible y borrado protegido — parche008

Después de007, ejecutar TODO database/patchs/008_patch_pet_archiving.sql en el SQL Editor del mismo proyecto de desarrollo con rol postgres. Si007 aún no está aplicado, ejecutar primero su archivo completo;008 no sustituye las políticas/objetos de007. Regenerar con database/scripts/Build-PetArchivingPatch.ps1. No editar artefactos generados ni reescribir migraciones previas.

RPC para cliente autenticado:
- archive_pet(p_id, p_expected_version): archiva sin borrar fotos; bloqueada si hay casos activos.
- restore_pet(p_id, p_expected_version): restaura y conserva historial.
- begin_pet_deletion/finish_pet_deletion: mantienen protocolo de limpieza de Storage de007; ahora rechazan historial/casos activos.

Consulta activa: filtrar archived_at IS NULL; archivadas: IS NOT NULL, siempre por propietario/RLS. El parche NO cambia el listado/botones de la app actual; esa integración Flutter está pendiente. No se desplegó remotamente desde este chat.

S3 debe actualizar case_history_at y active_case_count dentro de las operaciones de casos, bajo bloqueo de mascota. No existen todavía casos de producto; la pruebaSQL usa indicadores controlados por servidor. No aplicar a un esquema externo con casos existentes sin integrar/backfill de esos indicadores. Véase ADR-014, incluyendo la transición de baja de cuenta con historial.

## Activar zonas de interés — HU-02.1 / parche010

Cuando se autorice su aplicación en desarrollo, ejecutar TODO `database/patchs/010_patch_interest_zones.sql` en el mismo proyecto Supabase configurado para la app, con rol postgres/SQL Editor. Requiere Auth y roles Supabase; no necesita volver a aplicar patches de mascotas. Regenerar con `database/scripts/Build-InterestZonesPatch.ps1`; migración versionada `20261009001000_interest_zones.sql`. La aplicación remota no se ejecutó en esta tarea.

La dependencia de mapa incorpora caché nativa/path_provider: reconstruir e instalar la app para registrar plugins; Hot Restart de un binario previo no sustituye este paso. Perfil → Zonas de interés → Añadir zona. Nombrar, mover/ampliar mapa y tocar un centro o Indicar coordenadas; definir radio y Guardar zona. Lima es encuadre inicial, no ubicación detectada. No solicita GPS.

Con A: crear dos zonas, editar radio, cancelar otra edición, reiniciar y comprobar persistencia; provocar fallo de red y reintentar con el mismo borrador; eliminar y repetir después de pérdida de respuesta. Con B/anónimo: lectura/escritura de A deben rechazarse. Ejecutar `database/tests/009_interest_zone_permissions.sql` en desarrollo para RLS/grants y guardias del servidor; sus pruebas de fixture no sustituyen las cuentas reales en la app.

Actualización19/10/2026: configuración local del usuario selecciona CARTO Positron
mediante `MAP_TILE_URL` con formato
`https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=TU_API_KEY`.
Guardar la clave solo en `apps/mobile/config/supabase.local.json`, ignorado por Git,
y reiniciar con `--dart-define-from-file=config/supabase.local.json`; hot reload
no actualiza valores de compilación. Sin define sigue OSM estándar de desarrollo.
La autorización actual permite los créditos enlazados CARTO/OpenStreetMap en el
mapa compartido y sustituye ADR-054 solo para ese proveedor (ADR-084). Caché HTTP,
User-Agent y ausencia de descarga offline/precarga conservados. Tesela real
verificada con200/image/png; revisión del estilo en Android pendiente.

## Preferencias de alertas

Antes de abrir Perfil → Preferencias de alertas, aplicar completo `database/patchs/011_patch_alert_preferences.sql` en Supabase de desarrollo. No requiere claves adicionales ni permisos GPS/push. Guardado con sesión y clave publicable; errores de esquema no se confunden con cuenta sin preferencias. Esta entrega guarda elecciones y no envía notificaciones. Tras actualizar app, verificar guardar/reabrir/reiniciar y aislamiento entre cuentas. Ver ADR-019 y ESTADO para evidencia y pendientes.

## Activación de fotos seguras y principal — patch012 + Edge

El incremento HU-04.1/#30 y HU-04.2/#31 requiere `database/patchs/012_patch_pet_photo_processing.sql` completo tras011 **y** la Edge Function pet-photo-process antes de usar cargas de la nueva app. Procedimiento de empaquetado, despliegue y validación en [README de la función](../supabase/functions/pet-photo-process/README.md). En esta tarea no se aplicó SQL ni se desplegó: ambos artefactos están preparados para revisar.

La migración deshabilita reserva/publicación y escritura antigua de archivos desde el cliente; no aplicarla de forma aislada manteniendo la app antigua como cliente de cargas. Fotos existentes siguen privadas y visibles; processed_at nulo no acredita bytes seguros para exposición de casos. Derivados y miniaturas se mantienen en buckets privados. Antes de cerrar historias probar cámara/denegación, principal tras reinicio/retirada, reintentos, usuarios A/B y cuotas reales del runtime hosted; descargar y verificar los bytes de las dos salidas. Registrar archivos privados incompletos/huérfanos si se corta el worker durante limpieza.

Intento de APK debug del incremento (10 de octubre): `flutter build apk --debug --no-pub --dart-define-from-file=config/supabase.local.json` falla en Gradle por `java.io.IOException: Unable to establish loopback connection`, antes de compilar. No hay instalación nueva acreditada; el flujo Android debe probarse desde un entorno de compilación funcional. Pruebas Flutter/Deno/PGlite no sustituyen esa demostración.

### Fotos en la instalación real de Dokploy

La lista de contenedores y Compose aportados por el usuario confirman que
Entre Huellas no tiene servicio functions, ni detenido. La indicación previa
de deploy por project-ref era para Supabase administrado y no aplica aquí.
Seguir [supabase/self-hosted/README.md](../supabase/self-hosted/README.md).
Hay snippet de servicio, router limitado a pet-photo-process y generador de
paquete con WASM. El Compose completo preparado se obtiene con el parámetro
ComposePath del generador. Ubicación real del volumen y ruta de Kong pendientes
de leer del servidor antes de activar; no se ha desplegado remotamente.

## Activación de HU-05: publicar mascotas perdidas

1. Confirmar que patch012 y pet-photo-process funcionan en el mismo proyecto de desarrollo. Guardar al menos una foto nueva procesada; no marcar fotos históricas como verificadas.
2. Ejecutar completo [database/patchs/013_patch_lost_cases.sql](../database/patchs/013_patch_lost_cases.sql), generado mediante Build-LostCasesPatch.ps1. Requiere012. El usuario confirmó su ejecución el 10 de octubre de 2026; el agente no verificó la base remota. No cambiar buckets a públicos ni conceder DML cliente sobre lost_cases/case_events.
3. Actualizar la app y abrir Reportar → Mascota perdida. Elegir una mascota/fotos, fecha/hora, punto o coordenadas y referencia privada. Revisar la vista previa, publicar, abrir ficha pública y reabrir desde Mis casos tras reiniciar.
4. Probar con cuentas A/B: B no publica ni lee fuente privada de A; read_public_lost_case(id) devuelve solo proyección permitida y derivados elegidos. Anónimo no lee tabla base, originales ni fotos sin seleccionar. Validar Storage real además de filas SQL.
5. Interrumpir red al publicar: el formulario conserva UUID y solicitud; reintentar confirma una sola fila/evento. Con dos conexiones independientes y UUID distintos, publicar simultáneamente la misma mascota: solo un caso activo. Probar versión desactualizada, fecha futura, foto no procesada, archivo y eliminación con historial.

No solicita GPS; selección manual disponible aunque permisos de ubicación estén denegados. URLs públicas de derivados se firman por300s y pueden sobrevivir ese plazo tras revocar nuevos accesos. La web QR, tokens revocables, exploración/cercanía PostGIS y cierre autorizado se activan en sus historias posteriores. Ver [ADR-021](decisiones/021-publicacion-casos-perdidos.md).

## Activación de HU-06: publicar mascotas encontradas

1. Mantener patch013 aplicado y procesamiento de fotos operativo. Ejecutar completo [patch014](../database/patchs/014_patch_found_cases.sql), generado con Build-FoundCasesPatch.ps1. Requiere013; no modificar SQL aplicado ni hacer públicos los buckets nuevos.
2. Actualizar el handler del endpoint existente `pet-photo-process` en Supabase self-hosted: el código nuevo reconoce `x-found-case-id`, procesa con el mismo WASM y escribe exclusivamente derivados sanitizados en los buckets found-photo-renditions/found-photo-thumbnails. El paquete local se regenera con `./supabase/self-hosted/Build-PhotoBundle.ps1` según [procedimiento del servidor](../supabase/self-hosted/README.md). No hace falta otra Edge Function ni cambiar main/router. SQL solo no activa el nuevo contexto. No se ejecutó despliegue/reinicio remoto en esta tarea.
3. Actualizar/reconstruir Android. Con una cuenta sin mascotas registradas, abrir Reportar → Mascota encontrada, indicar especie/rasgos/fotos/fecha/punto manual/referencia; dejar custodia sin indicar. Revisar la vista previa pública, publicar y reabrir desde Mis encontrados tras reiniciar. Repetir con custodia indicada y especie Otra; no debe crear mascota ni asignarle dueño.
4. Probar GPS/cámara denegados (selección manual/galería disponibles), bytes manipulados, error de Storage y pérdida de respuesta. Reintentar conserva mismo UUID/comando y produce una publicación/evento. Solicitud incompatible produce conflicto. Con dos conexiones independientes, comprobar la misma clave simultánea.
5. A/B/anónimo: pendientes privados, tabla fuente solo del reportero y columnas permitidas; proyección sin referencia/posición exacta/perfil, derivados activos elegidos legibles y ninguna escritura anónima/autenticada. Descargar los JPEG reales y verificar EXIF/GPS; las fixtures SQL solo representan metadata.
6. Probar salida tras tentativa fallida y descarte de pendiente desde Mis encontrados. Confirmar eliminación de ambos buckets antes de marcar descartado y liberar su cuota; activo no se puede descartar, error mantiene datos y admite reintento. Draft remoto no recupera metadatos locales tras cerrar proceso; persistencia offline es HU-15.

Ver [ficha de encontrados](funcionalidades/casos-encontrados.md) y [ADR-022](decisiones/022-publicacion-casos-encontrados.md). Patch014 y handler remoto aún pendientes de activar; no se cierra HU-06 por las suites locales.

## Recuperación de publicación perdida bloqueada

Si la app vence al publicar y `database/tests/diagnose_lost_case_waits.sql` confirma una cadena de PostgREST en Lock/tuple, detener los reintentos mientras se investiga el origen. El timeout Flutter no cancela la transacción del servidor. El script operacional de cancelación preparado para el incidente del10 de octubre limita la acción a los PIDs observados y consultas de publicación activas esperando bloqueos; no usar sus PIDs para otros incidentes ni como limpieza automática.

Después de cancelar las consultas pendientes y comprobar el diagnóstico, ejecutar completo [patch015](../database/patchs/015_patch_lost_case_lock_timeout.sql), que requiere patch013. Solo configura lock_timeout5s en la RPC existente; no requiere Edge ni nueva subida de fotos. La app actualizada convierte55P03 en aviso superior de mascota ocupada. Consultar Mis casos antes de reintentar una sola vez con el comando conservado, y comprobar reapertura/singularidad del caso. El patch no libera transacciones antiguas ni resuelve por sí solo el origen de un bloqueo persistente. Aplicación y comprobación remota pendientes.


Listas/eliminación de casos: aplicar `supabase/migrations/20261010001600_case_collections.sql`, generada con plan016/fuentes057–060. Requiere esquema de casos perdidos/encontrados y patch015. Nuevas RPC de tarjetas del dueño/retirada, permisos y ocultación de eliminados; clientes actualizados dependen de este contrato. Verificación PGlite local, aplicación remota y Android pendientes. No sustituye diagnóstico del incidente previo de publicación.

## Límite de escritura de encontrados — incremento017

Tras los incrementos anteriores, aplicar en desarrollo la migración20261011001700_found_case_lock_timeout.sql generada con el plan017. No editar SQL aplicado ni ejecutar únicamente en Dashboard. Las pruebas locales verifican permisos/repetición, no contención real concurrente ni salud del servidor. Esta tarea no aplica ni despliega migraciones.

### PGRST202 al consultar Mis casos/Mis reportes

Ejecutar database/tests/diagnose_case_collection_rpcs.sql en la misma base usada por la app. Resultado esperado: function_exists=true, authenticated_can_execute=true y anon_can_execute=false para ambas RPC. Si falta una función, revisar/aplicar completa migración016 tras sus requisitos;017 no la sustituye. Si las funciones y permisos están presentes, recargar la caché de esquema con NOTIFY pgrst, 'reload schema'; y reintentar. PGRST202 por sí solo no demuestra cuál de esas condiciones ocurre. No reiniciar contenedores ni reescribir migraciones aplicadas como primer paso.


## Activación del nuevo flujo de búsquedas/avisos — migración018

Aplicar en desarrollo el esquema001–017 antes de [018](../supabase/migrations/20261011001800_recovery_report_links.sql), generado desde [plan018](../database/migration_plans/018_recovery_report_links.json). Requiere pipeline de procesamiento de fotos anterior; no hay una nueva Edge Function en este incremento. Activar la app que consume prepare_recovery_report/publish_recovery_report/list_open_recovery_searches/read_recovery_* junto con018: el RPC antiguo de publicación independiente ya no está autorizado a clientes. No reaplicar patches antiguos aislados sobre la nueva versión.

Validación local en ESTADO; no se aplicó esta migración a Supabase remoto. Comprobar dos cuentas: búsqueda propia/comunitaria, aviso con/sin foto a búsqueda abierta, foto/ubicación pública aproximada, rechazo al cerrar y cierre idempotente por autor. Reintentar no duplica avisos ni cambia el caso a recuperado. Registrar concurrencia multiconexión/Android autenticado como verificación separada. La configuración pública local y credenciales existentes se conservaron.


## Activación de Explorar — migración019

Preparar001–018 y pipeline de fotos anteriores. Generar con ./database/scripts/Build-ExploreCasesPatch.ps1 y aplicar completo [patch019](../database/patchs/019_patch_explore_cases.sql), o gestionar [migración019](../supabase/migrations/20261015001900_explore_cases.sql) por el flujo de migraciones; no aplicar ambas como historias independientes. No hay Edge nueva. Habilita PostGIS en extensions; si existe en otro esquema, se detiene sin moverlo. Revisar esa instalación antes de continuar. No requiere claves adicionales, GPS o cambios de configuración Flutter.

Activar cliente y RPC explore_cases juntos. Si PostgREST conserva esquema antiguo, recargar su caché y comprobar que authenticated puede ejecutar la firma nueva y anon no. Comprobar con dos cuentas: filtros/páginas y ficha, resolución visible solo a su autor, borrados/drafts ausentes y consulta por centro manual sin GPS. Verificar miniaturas reales en Storage y repetir páginas con un caso insertado entre consultas. MapConfig/ZoneMapPicker reutilizan proveedor existente; las condiciones de atribución pendientes documentadas siguen pendientes antes de distribución. No se realizó despliegue en esta tarea.


## Buscador de zona de Explorar — Photon

Actualización: el control visible se llama Ubicación e inicia por ubicación actual/radio15km. geolocator14.0.2 fijado por compatibilidad con Dart3.9.2; Android solicita ACCESS_COARSE_LOCATION e iOS declara NSLocationWhenInUseUsageDescription. Sin permiso de fondo ni seguimiento continuo. Recompilar para activar el plugin/permiso: hot reload no basta. Si se deniega o falla, se elige centro manual sin consultar casos globales. Centro solo como parámetro Supabase; Photon sigue recibiendo texto, sin GPS automático. Pendiente prueba nativa Android y configuración/distribución Apple. [ADR-047](decisiones/047-ubicacion-actual-y-radio-inicial.md).

No requiere migración adicional a019 ni nueva clave. PLACE_SEARCH_URL es un dart-define público opcional con endpoint HTTPS compatible con Photon; por defecto https://photon.komoot.io/api/. Se inyecta en bootstrap, con cinco resultados y timeout12s. Por instrucción del usuario, ahora consulta sugerencias desde3 caracteres tras600ms sin edición, una petición activa y última consulta pendiente, con caché existente; teclado permite búsqueda explícita cuando no hay otra en curso. Sin botón Buscar ubicación. Véase [ADR-046](decisiones/046-sugerencias-automaticas-de-ubicacion.md). No configurar claves secretas en la URL cliente. El servidor inicial es demo de uso razonable, sin garantía de disponibilidad; para distribución/volumen mayor revisar instancia/proveedor con garantías y su privacidad/condiciones. El endpoint puede sustituirse sin cambiar la pantalla.

El servidor demo no acepta lang=es; se omite esa opción y conserva nombres locales. Consulta real de desarrollo Miraflores Lima Peru respondió correctamente. El servicio recibe el texto escrito de ciudad/dirección, sin sesión Supabase ni puntos privados de reportes. Se muestra atribución OpenStreetMap enlazada junto al buscador. Fallar o no disponer de red no impide elegir manualmente centro/radio en el mapa si sus teselas están disponibles. Validar cobertura de direcciones, conectividad y teselas en Android; no se acredita con mocks. [ADR-042](decisiones/042-filtros-integrados-y-busqueda-zonas.md).


Comprobación adicional con cliente Dart real: el endpoint inicial respondió403 al cliente sin identificar. PhotonPlaceDataSource envía ahora User-Agent legítimo EntreHuellas/0.1 con el enlace del proyecto, sin suplantación de navegador. Con esa cabecera, la fuente/repositorio/caso de uso devolvieron5 resultados válidos para Miraflores Lima Peru. Repetir en Android y en cualquier endpoint sustituido; no usar la prueba de escritorio como garantía del servidor demo.

## Login social web — Google y Facebook

La web usa los proveedores habilitados en el mismo Supabase que móvil; registrar
la redirección web adicional. Completar SUPABASE_PUBLISHABLE_KEY,
MODERATION_SESSION_SECRET (mínimo32 caracteres aleatorios privados) y
PUBLIC_WEB_ORIGIN con el origen exacto, por ejemplo http://127.0.0.1:5173 para
desarrollo o https://entrehuellas.app para producción. Guardar localmente
en .env.local y configurar servidor/Dokploy, nunca cliente/NUXT_PUBLIC.

En Auth URL Configuration autorizar únicamente los callback de los entornos
usados: <PUBLIC_WEB_ORIGIN>/api/moderation/oauth/callback?flow=* (la parte flow
es aleatoria por intento; usar el patrón acotado de redirect URLs de Supabase).
Validar que el patrón admita la query flow sin permitir hosts externos.

En Supabase autohospedado, la lista efectiva pertenece al contenedor Auth:
`GOTRUE_URI_ALLOW_LIST`. La plantilla estándar la recibe de
`ADDITIONAL_REDIRECT_URLS`; comprobar el mapeo del Compose antes de editar.
Añadir a la lista existente, separada por comas, esta entrada de producción:

```text
https://entrehuellas.app/api/moderation/oauth/callback?flow=*
```

Conservar las entradas móvil y local existentes. Recrear Auth para aplicar
el entorno y probar con un flujo nuevo. El23/10 se comprobó que el retorno
local se conservaba, mientras producción caía en `entrehuellas://login-callback/`:
el enlace inicial hacia Google puede incluir redirect_to aunque Auth finalmente
lo rechace. Comprobar el retorno real, no solo el302 inicial hacia Google.
No sustituir Site URL móvil ni modificar Google→Supabase para resolver esta
allowlist. Aplicación remota y login real pendientes; evidencia en acceso-web.

Google/Facebook se configuran en el Dashboard del proveedor/Supabase con sus
credenciales existentes; no copiar client secrets a esta app. El callback del
proveedor hacia Supabase sigue siendo el de ese backend, no el callback Nuxt.
Probar consentimiento/cancelación y retorno web con una cuenta revisora real.

No registrar códigos/verifiers/tokens ni query de callback en logs del proxy.
La cookie temporal eh_oauth es HttpOnly/Lax, dura10min y contiene estado/verifier
cifrados; solo el intento más reciente del navegador es válido. La cookie final
conserva Strict/HttpOnly. OAuth puede crear/vincular identidades según Auth, pero
los permisos administrativos siempre se asignan desde servidor.
Activación no realizada en esta tarea; pruebas con proveedores simulados.
