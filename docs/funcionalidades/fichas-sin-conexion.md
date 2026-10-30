# Fichas consultadas sin conexión

HU-15.3 / RF-32 / issue #49 · S6 · Android primero.
[ADR-135](../decisiones/135-cache-local-de-fichas-publicas.md).

## Qué hace y recorrido

Abrir una ficha pública de perdido o encontrado con conexión conserva su copia
local. Explorar → Guardados → Consultados en este dispositivo permite recuperar
esas fichas aunque no sean favoritas, sin red y tras reiniciar el proceso.
Los favoritos remotos siguen en una sección diferenciada de la misma pantalla.
La lista local no espera a que termine la consulta de favoritos.

La ficha recuperada informa Copia sin conexión, fecha/hora de la consulta y
posible desactualización, con Actualizar. Muestra datos y fotos descargadas;
explica que algunas fotos pueden faltar y que el mapa requiere conexión. No
monta contacto, compartir, historial ni acciones que dependan de autorización.
Al reconectar, abrir de nuevo o Actualizar revalida contra el servidor; no hay
sondeo permanente en segundo plano.

## Reglas y campos

Clave cuenta/origen/UUID, fecha, especie/nombre/rasgos/datos públicos del animal,
estado, fecha del suceso, coordenadas públicas aproximadas y hasta tres fotos.
Se conservan como máximo30 fichas y32MiB de payload por dispositivo; las más
antiguas se expulsan. Hasta2MiB por foto; las no descargadas muestran el
placeholder compartido. Un fallo de descarga conserva bytes previos únicamente
si coincide el identificador de la foto.

No se guardan teléfono/contacto/foto privada del autor, perfiles, puntos exactos,
referencias privadas, permisos, targets privados ni URLs firmadas. Las capacidades
canResolve/canGeneratePoster siempre son falsas al recuperar la copia.

## Persistencia y permisos

SQLite/Drift `case_cache.sqlite`, esquema1 independiente de borradores/cola;
ubicación privada de Android, exclusión de backup y transferencia con auxiliares.
Campos/fotos se reemplazan atómicamente. Cuenta y origen forman parte de cada
lectura/escritura/borrado. Cerrar/cambiar sesión oculta lo anterior; iniciar sesión
de nuevo con la misma cuenta permite sus copias mientras exista el almacenamiento.
Borrar datos/desinstalar las elimina. La base no autentica ni permite iniciar
sesión sin credenciales; conserva el acceso global por cuenta existente.

Las RPC y Storage existentes autorizan las consultas reales. Ausencia, cierre o
rechazo explícito del servidor invalida la copia; una respuesta de red fallida
posterior no la recupera. Sin red no puede conocerse un cambio remoto nuevo.
La copia histórica no es evidencia de que el caso siga activo.

## Errores y reintentos

Skeleton inicial, shimmer durante Actualizar y contenido conservado durante el
intento. Timeout/indisponibilidad usa copia solo de la cuenta actual. Sin copia,
toast y Reintentar. Escritura fallida conserva la consulta online, informa que no
pudo almacenarse y permite actualizar. Corrupción/lectura fallida no equivale a
lista vacía ni sobrescribe la base. Doble envío y respuestas de otra identidad
se descartan; descargas tardías no recrean una copia invalidada.

## Dependencias y activación

Actualizar cliente Android; sin migración Supabase, Edge Function ni variables
nuevas. Reutiliza Drift/path_provider/http existentes, composición main/router,
ficha pública, grilla y controles/transiciones compartidos. Web Nuxt conserva
sus recorridos online; no se implementa PWA ni teselas descargadas.

## Validación

Suite focalizada final:16 pruebas, incluidas reapertura real de archivo
SQLite con bytes de foto, separación A/B y lost/found, logout, límites,
reconexión, cierre/rechazo, invalidación mientras se descarga y widgets normal/
pequeño con texto200%, respuesta remota antigua y fallos reales SQLite de escritura/
invalidación. Regresión completa: **591/591 Flutter** con
`--dart-define=AMBIENT_BACKGROUND_MOTION=false`, análisis sin incidencias y formato/
diff correctos. La suite incluye las reglas arquitectónicas. Log final:
`apps/mobile/build/offline-cases-full-tests.log`; análisis:offline-cases-analyze.log.

`tool/check_case_cache_remote_test.dart`: prueba real en Supabase de desarrollo
aprobada con cuentas A/B distintas, publicación QA con JPEG procesado, foto
Storage decodificable, reapertura de SQLite, transporte offline, aislamiento,
reconexión y cierre real en servidor seguido de invalidación sin resurrección.
El fixture QA se retira mediante las APIs existentes al terminar; no altera
casos originales ni cierra otras sesiones. Log:build/offline-cases-remote.log.
La pérdida de red de ese harness se inyecta en HTTP; el recorrido Android inferior
comprueba adicionalmente la red del dispositivo. Repetición final aprobada en6s:
build/offline-cases-remote-final.log. Build profile x64 final correcto69.4MB en
build/offline-cases-android-build-final.log.

En app normal Pixel_9a/Android16/API36: abrir ficha perdida existente sin modificarla,
Wi-Fi desactivado+modo avión, force-stop, reabrir → Explorar → Guardados → ficha
local. Se recuperan foto, datos y fecha/aviso, sin contacto/compartir/acciones
remotas. Rehabilitar red y Actualizar retira el aviso y consulta de nuevo contacto/
compartir autorizados. Snapshot SQLite nativo:1 ficha/1 foto con hash completo,
sin URLs firmadas, contactos ni flags de autorización; evidencia en
build/offline-case-native-evidence.json. XML/captura:offline-case-restored.xml/png;
reconexión:offline-case-reconnected.xml. Cuenta y datos anteriores conservados.

El acceso local reutiliza entityDetailPage/OriginPageTransition con rectángulo
real de tarjeta,320/260ms y retorno existentes. Apertura/retorno con movimiento
normal grabados en build/cache-motion-normal.mp4 y fotogramas revisados
(cache-video-0006/0007/0013/0014.png); el muestreo variable del emulador (~4.7fps)
permite revisar estados/retorno, sin certificar duración/curva por medición de
video ni afirmar auditoría global de animaciones. Los widgets pequeños/reducidos
mantienen scroll, fotos locales y acción de actualización sin desbordamientos.

Instalación requiere reducir temporalmente el umbral de almacenamiento del AVD
por espacio libre bajo; se restaura inmediatamente, sin desinstalar ni borrar
datos. Red restaurada:Wi-Fi activo/modo avión desactivado. Se instala la app normal
final, no una entrada QA. No se acredita teléfono físico, reinicio del SO, mapa
descargado, aprobación visual del usuario ni funcionamiento offline de Nuxt.

Una invalidación que falla por almacenamiento oculta la copia en el proceso y
permite reintentar, sin afirmar borrado durable: si el dispositivo impide toda
escritura, no puede persistirse esa eliminación hasta recuperar almacenamiento.
La copia histórica nunca certifica vigencia remota mientras no hay conexión.

Implementación y validación local/remota completadas en el alcance descrito.
24/10: PR #69 fusionado a main, commit1424b72; Flutter/web del HEAD y validate
de main aprobados. #49 y épica #15 cerrados con evidencia y Projects en Done.
El run40159160220 de publicación APK no recibió los cinco secrets; después el
usuario informa su configuración definitiva. Falta verificar una nueva ejecución;
pendiente de distribución independiente, sin afirmar APK publicado ni cierre del MVP.
