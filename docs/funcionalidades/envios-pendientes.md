# Envíos pendientes y reintentos

Estado24/10: **Done**, [#48 cerrado](https://github.com/srg-cp/entrehuellas/issues/48)
y [PR67 fusionado](https://github.com/srg-cp/entrehuellas/pull/67) con CI aprobado.
Conserva los límites de emulador/desarrollo remoto detallados debajo; #49 sigue pendiente.

HU-15.2 / RF-32 / issue #48 · S6 · Android primero.
[ADR-132](../decisiones/132-cola-persistente-de-envios-android.md).

## Qué hace y recorrido

Al confirmar Publicar/Enviar, el formulario valida y conserva el comando en la
cola del dispositivo antes de contactar el servidor. Si no se confirma, queda
pendiente con UUID y contenido originales. Con sesión/bienvenida preparadas, la
app activa comprueba los pendientes al entrar/volver y cada15s, respetando backoff
5/15/30/60/120s. No se promete trabajo con la app cerrada o en segundo plano.

Perfil → Envíos muestra pendiente/en curso, fallido o publicado e intentos. Ver
motivo abre toast; Reintentar envío original mantiene el comando; Revisar reporte
abre su contexto; Ver resultado consulta la ficha correspondiente. Borradores
conserva los incompletos y enlaza a Envíos. Los publicados con limpieza local
pendiente se excluyen de la lista de borradores por su recibo duradero.

Un rechazo deja fallido y detiene reintentos automáticos. Conflicto no crea otro
UUID ni reemplaza payload. Invalid/photo conocidos pueden corregirse en el editor
mediante una acción explícita de publicación; el servidor conserva su autorización.
Los estados/etiquetas son visibles; errores, motivos y validación usan toast superior.

## Persistencia, campos y permisos

SQLite/Drift esquema2 agrega `submission_queue`, migración1→2 sin perder borradores.
Cuenta/UUID, payload exacto, huella de campos/bytes, estado, intentos, fecha de
próximo intento, reclamación/proceso y recibo de publicación. Se conservan versión
de mascota, destino, instante, fotos seleccionadas y bytes nuevos. La huella no
incluye URLs firmadas ni datos decorativos del snapshot. Ningún token/contacto.

Una transacción vincula la clave al payload y reclama el envío. La respuesta
solo finaliza su nonce vigente. Reiniciar recupera reclamaciones de procesos
anteriores; en el mismo proceso un intento en curso se comparte. Cambio/logout
oculta la otra cuenta y detiene el recorrido antes de iniciar el siguiente elemento.
App vincula el sincronizador a la identidad autorizada por la política global;
las fuentes comprueban identidad entre las operaciones remotas.

El recibo se verifica mediante los casos de uso existentes, se guarda y luego se
retiran los bytes nuevos de la fila y el borrador correspondiente. Un replay ya
confirmado retorna el recibo sin HTTP. Si el borrado del borrador falla, su recibo
permanece autoritativo. No hay SQL/RPC/grants remotos nuevos.

## Errores, cancelación y reintentos

Respuesta ausente/inválida no confirma publicación. Error de disco antes de encolar
impide HTTP; si no puede guardarse un recibo, el comando original permite resolver
la incertidumbre al recuperar almacenamiento/reiniciar. Un error no equivale a vacío.

Descarte explícito solo retira una intención pendiente/fallida; en curso/publicado
se rechazan. No revoca una publicación remota. Encontrado conserva la RPC que
comprueba ausencia de publicación activa; si falla, conserva el borrador/UUID para
revisarlo y reintentarlo manualmente. No se descartan intentos inciertos en secreto.

El editor acepta el recibo validado tardío del mismo envío; antes de recibirlo
sigue pendiente. Reintentar mientras ese Future está activo se une a él. Campos
se bloquean durante una intención pendiente/en curso para conservar la huella.

## Activación y dependencias

Actualizar cliente Android con las dependencias de ADR-131 y crypto para SHA-256.
`main` habilita sincronización de la app normal; la composición de previews/tests
puede dejarla inactiva. Esquema local migra al abrir; sin variables/servicios nuevos.
La validación de borradores Android se acredita en su ficha; no entrega caché
de casos HU-15.3 o paridad offline de Nuxt. La corrección de conflictos037 requiere
aplicación administrativa y cliente actualizado, como se detalla abajo.

## Validación acreditada —23/10/2026

Recorrido funcional aprobado en Android emulado y backend real de desarrollo
confirmado por el usuario. La ampliación detectó timeouts ante UUID/contenido
incompatible;037/038/ADR-134 corrigen las tres RPC públicas y su helper interno.
El usuario aplica ambos patches: **6/6 pruebas remotas estrictas aprobadas**,
incluyendo conflictos de perdido y de preparación/publicación de búsqueda.
No se oculta el fallo anterior; queda documentado como historial en ESTADO.
575/575 Flutter, análisis limpio, APK normal actualizado instalado y cuatro SQL
focalizadas de repetición/ACL aprobadas. Regresión completa posterior a038:
56/56 SQL aprobadas, cero fallos/omisiones. Validación técnica completada en este
entorno; siguiente incremento funcional HU-15.3, sin iniciarlo en esta tarea.
No equivale a cierre de issue/épica en GitHub ni a prueba en teléfono físico.

| Nivel | Resultado | Evidencia principal |
| --- | --- | --- |
| Flutter | 575/575, análisis sin incidencias | Cola, editores, router global, sincronizador, aislamiento, errores y arquitectura |
| SQL local completo | 56/56 PGlite/PostGIS después de038 | Permisos, invariantes, repetición de037/038, deduplicación y regresión del catálogo; distinto del servidor alojado |
| Remoto real | 6/6 estrictas después de037/038 | Conflictos sin timeout, perdido, búsqueda con tres fotos, encontrado de B, avistamiento Nuxt, permisos y revocación |
| SQLite Android | 10 checks aprobados | Migración1→2, dos conexiones/una reclamación, nonce, backoff, cancelación, aislamiento, hashes de3×2MiB y8MiB |
| App normal Android | Recorrido completo aprobado | Formulario, galería real/normalización, preview, pendiente sin red, force-stop/reapertura, sincronización automática y ficha publicada |

El harness remoto usa repositorios/casos de uso reales. Descartar la respuesta
HTTP2xx recibida del servidor provoca incertidumbre después del commit; reenviar
el mismo comando confirma una publicación, no otra. Repeticiones concurrentes
de perdido confirman el mismo ID; un recibo durable evita nuevas peticiones.
Logout de la sesión de prueba justo después del commit detiene el siguiente
comando; el refresh token revocado es rechazado por Auth y, al reingresar,
ambos comandos se confirman con sus UUID originales. No se invalidan otras sesiones.

En la app normal, una búsqueda QA con foto pasa a Pendiente tras publicar sin red.
Reiniciar el proceso conserva UUID/huella; al recuperar red, sin pulsar Reintentar,
el intento4 cambia a Publicado. SQLite confirma la misma huella y UUID, recibo
durable, retiro de evidencia del payload (289260→564 caracteres) y borrador limpio.
El servidor devuelve un solo resultado activo con una foto y Ver resultado abre
su ficha. Se retira únicamente esa publicación QA desde Mis reportes y deja de
ser pública. El recibo local se conserva, incluso después de retirar el caso.

Herramientas desde apps/mobile:

```powershell
flutter test --no-pub tool/check_submission_queue_remote_test.dart --reporter expanded
flutter build apk --profile --target tool/offline_queue_native_validation.dart --target-platform android-x64
```

El primer comando exige config/profile_test.local.json ignorado por Git y cuentas
dedicadas distintas; crea casos de prueba en desarrollo. Puede usar sesión B
verificada por OTP mediante PROFILE_TEST_REFRESH_TOKEN_B. Retira casos al terminar
y elimina/archiva mascotas QA según su historial; conserva recibos/auditoría del
servidor. El segundo requiere instalar/ejecutar su APK y obtener10 checks más
QUEUE_NATIVE_VALIDATION_PASS. Usa base temporal separada y la elimina al terminar.
El smoke previo offline_drafts_smoke.dart también pasó WRITE→force-stop→READ sin
red con su base separada. Restaurar siempre APK de entrada normal después de QA.

Logs finales: apps/mobile/build/queue-full-validation-tests-after-conflict.log,
queue-final-validation-analyze-after-conflict.log,
queue-hosted-validation-after-038.log y queue-native-validation-android.log;
database/tests/queue-full-sql-validation-after-038.log. Evidencia UI/SQLite en build:
queue-android-cycle-evidence.json y XML queue-{pending-list,offline-restarted-list,
auto-retry-result,published-card,cleaned-my-reports}.xml. Tiempos nativos observados:
migración/lectura6MiB682ms; enqueue6MiB709ms; escritura/lectura8MiB1296ms.
Son mediciones del emulador con bytes sintéticos, no SLA ni fotos de cámara máximas.

Condiciones/límites: Pixel_9a/API36/x86_64 y APK normal profile53.6MB durante QA,
actualizado luego a69.3MB con el adaptador PT409; ambos instalados para evitar
el límite del APK debug del AVD. Gradle funciona con directorio temporal de sockets por
proceso, sin modificar el proyecto. Caídas gráficas del emulador en Windows se
resuelven para la prueba con ANGLE, Vulkan/Impeller desactivados y render software
por extras de arranque; no se cambió Manifest. Configuración detallada en
[CONFIGURACION](../CONFIGURACION.md). No se acredita teléfono físico, todos los
drivers/fabricantes, reinicio completo del dispositivo o fallo físico de disco;
las pruebas locales sí cubren fallos de lectura/escritura y límites de datos.
037/038 aplicados en desarrollo por el usuario y comprobados remotamente; sin
despliegue de app/Edge por el agente durante aquella validación. El24/10 el usuario
autoriza integración/cierre de #48 por PR y CI, junto con #47. Véase la
[auditoría de GitHub](../backlog/auditoria-github-2026-10-24.md).
Siguiente incremento: HU-15.3.
