# Estado del proyecto

## Examen U2 tipo4 punto3: respaldo, pantalla y borrado —30/10/2026

Usuario demuestra punto2: salida ADB version2 AES-GCM y lista daniel visible en
modo avión. Evidencia previa a FLAG_SECURE preservada en
apps/mobile/build/exam-evidence/point2 (captura de app y terminal cifrada).

Punto3 implementado: allowBackup=false y exclusión completa en reglas legacy,
cloud y device-transfer; Guardados protegida con FLAG_SECURE y miniatura reciente
desactivada API33+. Wrapper app espera protección antes de montar datos y libera
lease al cerrar/cancelar. Perfil incorpora botón de borrado fuera de la ruta
protegida, con diálogo que delimita listas offline y claves. Fuente serializa
guardar/leer/borrar; elimina claves primero y carpeta/temporales después.
No elimina cuenta/favoritos remotos, otras cachés ni borradores. ADR140.

24 pruebas Flutter aprobadas y análisis de archivos modificados limpio;6 pruebas
nativas reales aprobadas (incluye Keystore, borrado de claves de prueba, leases y
configuración instalada de respaldo). Pruebas de UI verifican cancelar/confirmar,
toast,390×844 y320×844/texto200% sin overflow. Un primer test de borrado detectó
sesión autoDispose sin observador; ViewModel ahora observa identidad y descarta
resultados tardíos tras cambios de cuenta. Prueba de carrera confirma que un
guardado en curso no recrea archivo después de borrar; fallo de Keystore reintentable.

APK debug y tests Android compilados, actualización en emulador sin borrar datos
del usuario. Pendiente demostración real por usuario: recientes/captura bloqueados,
Perfil después de confirmar borrado y ADB sin archivo. Los tests de eliminación
usan namespace aislado; no se atribuye borrado de la copia real a esas pruebas.
Sin prueba de backup cloud/transfer real, publicación, Git ni cierre de historias.

## Examen U2 tipo4 punto2: AES-GCM y Keystore —30/10/2026

Punto1 demostrado por el usuario: salida ADB con daniel en texto claro y captura
de Guardados en modo avión con aviso Sin conexión. Se preserva esa evidencia
antes de reinstalar en apps/mobile/build/exam-evidence/point1 (PNG y terminal TXT).

Punto2 implementado: clave AES256 por cuenta generada/no exportable en
AndroidKeyStore; IV96 nuevo, tag128 y AAD de cuenta/propósito/versión. Sobre cifrado
version2 en mismo cases.json; no hay escritura temporal en claro ni lectura
permisiva de esquema1. Interfaz de cifrado en data, transporte en app y nativo
fuera del hilo UI. Archivo/Keystore no comparten clave mediante canales.

16 pruebas Flutter y análisis de archivos modificados aprobados. Tres pruebas
instrumentadas con Keystore real aprobadas en emulator-5554: IV nuevo, persistencia
entre instancias y clave no exportable, alteración rechazada, no creación de
clave al leer cuenta ajena. APK y APK de tests compilados; CMake3.22.1 instalado
como dependencia de pruebas Android. Conservados avisos de herramientas previos.

Desinstalación SIN -k y reinstalación limpias ejecutadas según punto2; se comprueba
ausencia de archivo anterior antes de abrir. Red reactivada y app iniciada para
nuevo login. Pendiente que usuario inicie sesión, guarde copia cifrada y obtenga
capturas ADB y lista en modo avión. No afirmar punto2 aceptado por pruebas aisladas,
ni puntos3–5 completos; otras cachés existentes no se declaran cifradas. ADR139
y ficha actualizadas. Sin Git disponible, publicación ni cambios de backend.

## Examen U2: inspección antes del primer guardado —30/10/2026

Usuario ejecuta el script sin existir files/offline_saved_cases; ADB confirma
ausencia de cases.json. Inspección ahora busca desde files (existente) y muestra
pasos del primer guardado sin error nativo de PowerShell5. No se creó archivo
artificial ni se atribuye la evidencia a la app sin pulsar el botón real.

## Examen U2 tipo4, punto1 —30/10/2026

Usuario autoriza implementar el punto1. Guardados → Favoritos incorpora Guardar
sin conexión: lista visible en JSON privado separado por cuenta, texto claro
deliberado para inspección debug con adb shell run-as. Fallback al fallar backend
en carga inicial/refresh; estado offline, sin fotos/URLs firmadas, sin abrir fichas
desde este snapshot parcial. Caché previa de fichas conservada. Dominio, DTO,
fuente de archivo, repositorio y ViewModel separados; main inyecta por providers.
Script scripts/Inspect-OfflineSavedList.ps1 y ficha funcional con pasos de evidencia.

15 pruebas aprobadas (5 de archivo/ViewModel/UI y10 arquitectura); análisis de
archivos modificados limpio. Revisión visual390×844 y320×844/texto200% en fixtures.
APK debug compilado, instalado con adb install -r y actividad iniciada en
emulator-5554; sesión/datos existentes conservados. Script PowerShell con sintaxis
validada; su lectura real requiere guardar antes desde la app.
Primeros intentos de test UI se bloquearon por I/O bajo reloj simulado; se separó
prueba de archivo real de UI con repositorio simulado. No son evidencia válida
los intentos interrumpidos. Pendiente demo real del usuario con casos de prueba,
captura modo avión y JSON leído mediante ADB. Sin cifrado/puntos2–5, cambios SQL,
publicación ni cierre de HU. Esta copia sigue sin .git: no hay rama/diff verificable.

## Arranque configurado y complementos Android —28/10/2026

Configuración Supabase local ahora presente y JSON válido; GET público de
auth/settings con clave publicable devuelve200, sin enviar credenciales.
Se identifica PlatformException de shared_preferences: faltaba el registrador
Android porque la preparación inicial se interrumpió al crear symlinks Windows.
Ejecutar sin --no-pub y con FLUTTER_WINDOWS=false solo en el proceso regenera
GeneratedPluginRegistrant. APK recompilado, instalado y arrancado con configuración;
el nuevo proceso no registra el error de canal. Sin borrar datos del emulador.
Autenticación real pendiente de reintento por el usuario; HTTP200 no acredita login.

## Ejecución Android local por comando —28/10/2026

Entre Huellas compila e inicia en emulator-5554 (Android 15/API35) con
`flutter run --no-pub -d emulator-5554` desde apps/mobile. APK debug generado,
instalado y pantalla de inicio de sesión confirmada mediante captura ADB.
Entorno local Flutter3.47.2/Dart3.13.2; Flutter se configura con JBR21 instalado.
Compatibilidad de compilación: Gradle8.14, AGP8.11.1 y Kotlin2.2.20; NDK28.2
instalado. Flutter actualiza dependencias del lockfile, exclusiones del analizador
y flags de compatibilidad Android. Permanecen avisos de futuras versiones y
obsolescencia de dependencias. No se ejecutó suite de pruebas ni build release.

Esta copia no contiene .git ni config/supabase.local.json: no hay rama verificable
ni conexión Supabase configurada. El arranque visual no valida autenticación ni
operaciones remotas. Siguiente paso: aportar configuración local autorizada y
comprobar acceso real. Sin publicación, despliegue ni cierre de historias.

## Coincidencias: corrección de sharp/libvips en producción —25/10/2026

El usuario aporta logs500 de `/api/app/matching/searches` con
`libvips-cpp.so.8.18.7` ausente para el cargador Linux. Error reproducido en
Ubuntu x64/Node24.18: Nitro separa versiones de paquetes nativos y rompe su
resolución ELF relativa. Se conservan versiones fijadas de sharp0.35.5 y
sharp0.34.5 transitivo, y se empaquetan sus dependencias nativas completas como
hermanas en cada versión. Hook de compilación y prueba de JPEG/redimensionado
del paquete generado, incluida en CI y en la etapa final Docker. Instalación
Docker incluye opcionales y omite CUDA; no se instala libvips del sistema.

Encoder importa sharp/Transformers únicamente al procesar fotos, dentro del
manejo de fallos. Regresión con runtime nativo bloqueado: autenticación401,
listado200, comparación503 segura/reintentable y listado posterior200. No
cambia permisos, ranking, modelo ni SQL. Ficha funcional actualizada.

Validación: build/typecheck en Linux y Windows aprobados;94/94 pruebas web en
ambos y36/36 de servidor construido en Linux. Ambas versiones nativas procesan
JPEG en Linux, también desde una copia aislada de `.output/server` sin acceso
a dependencias de desarrollo, y en Windows. Servidor Linux con CLIP real y
backend fixture indexa dos imágenes, produce512 componentes normalizados y
reutiliza índices al reintentar. Las3 pruebas de servidor de matching y el
mismo smoke de CLIP real también pasan en Windows. Esto no evalúa identidad
de mascotas. El chequeo nativo ejecuta cada versión en un proceso separado
para evitar colisiones de nombres DLL al probarlas en Windows.
Los primeros intentos de la suite Linux aislada omitieron referencias móviles;
se copiaron fuentes/fuentes tipográficas necesarias y la suite completa pasó.

Pendiente construir el contenedor exacto (Docker Engine no disponible), publicar
los cambios, reconstruir/desplegar y repetir el recorrido alojado. No se ejecutó
SQL remoto ni se hizo commit/push/despliegue. Conservar cambios móviles previos.

## Denunciar desde Compartir conserva panel y origen —25/10/2026

Corrección solicitada en ficha pública móvil de perdido/encontrado: se elimina
el cierre previo del panel Compartir. Se captura posición/radio/color/icono del
botón Denunciar y se entrega a la transición de editor compartida, manteniendo
el panel montado detrás. Al volver conserva su instancia y scroll; bloquea
aperturas repetidas y respeta movimiento reducido. Sin cambios de dominio,
SQL, permisos, envío/recibo ni alcance web. Fichas Compartir/Denunciar actualizadas.

Validación:38 pruebas pertinentes aprobadas (compartir, denuncia, transición,
arquitectura y8 regresiones nuevas con GoRouter/formulario reales y repositorios
de prueba). Las8 regresiones se repiten tras cargar fuentes para renders:
perdidos/encontrados,390×844 y320×600/texto200%, movimiento normal/reducido,
dos aperturas/retornos y cierre posterior del panel con Atrás. Análisis lib/test
sin incidencias y diff sin errores. Se desactiva solo el fondo ambiental continuo
mediante `--dart-define=AMBIENT_BACKGROUND_MOTION=false`; la primera ejecución
sin ese parámetro produjo timeouts de pumpAndSettle, no evidencia válida.
Fotogramas de apertura0/5/15/45/99/100% y cierre50/75/95% generados en
`apps/mobile/build/ui-preview/share-report-origin`; revisión local de origen,
superficie creciente, panel detrás y retorno. Sin sesión/backend reales, APK,
despliegue ni cierre de historias. Siguiente paso: prueba física Android y
aceptación visual del usuario de este recorrido.

## Cabecera del README corregida —25/10/2026

El aviso de coincidencias había quedado dentro del bloque HTML centrado, antes
del icono, mezclando texto e imagen en GitHub. Se traslada a Sobre el proyecto
para conservar la cabecera y se precisa la confirmación del patch040 y los
pendientes reales. Cambio documental; revisión de estructura y diff sin errores.

## Publicación de rama autorizada —25/10/2026

El usuario solicita commit y push de `feature/case-matching`. Se prepara el
incremento completo con documentación de alcance/aceptaciones previas conservada.
Revisión de138 archivos: sin destinos locales ausentes ni credenciales detectadas;
env local, pesos ONNX, logs y work permanecen ignorados. Diff sin errores de
espacio. Evidencia disponible:597 Flutter,63 SQL,94 web y35 servidor aprobados;
build/typecheck, Chrome y modelo local documentados anteriormente.
040 aplicado según usuario y RPC remota presente con rechazo correcto de actor
nulo. Siguen pendientes demo de dos cuentas, evaluación con fotos autorizadas,
aceptación e integración/CI; commit/push no cierran #71/#72 ni despliegan.

## Aplicación040 confirmada por el usuario —25/10/2026

El usuario confirma ejecución del patch040 en Supabase. Se registra como
confirmación del usuario; no se atribuye al agente inspección remota ni se
reaplica SQL. Configurado MATCH_MODEL_DIRECTORY en .env.local sin exponer secretos.
Comprobación remota de solo lectura: read_case_match_context existe y rechaza
actor nulo con403/42501 matching_forbidden. No acredita todavía ranking ni
permisos entre cuentas reales. Typecheck y94 pruebas web finales aprobados;
build y smoke del servidor construido con modelo real/backend fixture aprobados.
Se inicia desarrollo local en127.0.0.1:5173 para la prueba del usuario. Publicación/despliegue y precisión
con mascotas reales todavía no acreditados. #71/#72 siguen abiertos.

## Matching: implementación local y pendientes de cierre —25/10/2026

Rama `feature/case-matching`. Usuario autoriza HU-25/#71 y HU-26/#72 e incluye
expresamente hallazgos independientes sin elegir una búsqueda, conservando avisos
vinculados y datos históricos. Motor CLIP visual CPU local en Nuxt existente,
indexación privada/versionada, ranking de hasta cinco casos y revisión humana;
recorridos Android/web, fotos obligatorias y custodia opcional elegida.
Confirmar sugerencia no asigna propietario ni confirma recuperación.
ADR-138, ficha, configuración y guía actualizados; plan040/fuentes128–134,
migración/patch generados y run_all mediante generadores. Integraciones de
cartel/QR/compartir/seguimiento/cronología conservan permisos y proyecciones.

Evidencia ejecutada:597/597 Flutter, análisis lib/test limpio;63/63 SQL/PostGIS;
94/94 web,35/35 servidor construido, typecheck/build aprobados. Modelo real
local produce512 componentes normalizados; servidor construido indexa dos
canarios con backend de prueba y reutiliza índices. Esto no evalúa identidad
de animales. Chrome1440/390/320, fases de apertura/cierre desde origen,
fullscreen, reducido, revisión/ficha, texto200% y retry aprobados con fixtures.
Capturas móvil390/320-texto2 revisadas; nueva prueba de origen/retorno móvil
aprobada. Logs ignorados: apps/mobile/build/matching-*.log,
apps/platform/matching-*.log y database/tests/matching-*.log.

Tras esos checks se ajustó el texto de presentación y la composición web del
destino al alternar aviso vinculado/hallazgo independiente; verificar ese último
ajuste antes de integrar. No se afirma que cada cambio posterior esté cubierto
por los resultados anteriores. Dockerfile preparado para CPU/glibc y pesos
fijados; Docker Engine Linux local no disponible, contenedor pendiente.

GitHub/Projects #71/#72 In progress/P1, abiertos; se retira needs:refinement
porque contrato/modelo/recorrido están concretados, sin marcar aceptación.
No se aplicó040 ni se desplegó backend/web, ni se hizo commit/push/PR de esta
feature. Trabajo documental previo del usuario conservado.

**Falta para cerrar:** comprobar ajustes finales y diff/enlaces/formato; activar
040 y servidor/clientes en desarrollo; demo con dos cuentas; dataset autorizado
con identidades separadas y evaluación Recall@5/falsos positivos/latencia;
aceptación del usuario e integración/CI. Android físico y contenedor Linux
pendientes. No hay precisión acreditada ni avisos automáticos activos, y no
se declara feature terminada ni cierre del MVP. Siguiente paso: completar esas
comprobaciones locales y preparar activación revisable; no solicitar fotos
privadas ni aplicar SQL remoto sin autorización.

## Seguimiento actualizado — 25/10/2026

Aceptación expresa del usuario: #19, #34, #35, #40, #41, #13 y épica #8
cerrados/Done en GitHub y Projects. La aceptación procede del usuario; no se
ejecutó una nueva demo del agente ni se fabrican logs de escenarios particulares.
HU-01 sigue abierta por #24/#25 sin implementar; HU-12 por #42/FCM pospuesto.
Moderación/denuncias/bloqueos/apelaciones conservan sus pendientes #43–#46.
Estadísticas #50 ya cerradas por la aceptación del24/10.

Match incluido expresamente en MVP: **HU-25 / #71** y **HU-26 / #72**,
RF-19/RF-20, Backlog/P1 y needs:refinement. No existían issues de estas
historias al revisar los51 issues abiertos/cerrados. Ahora hay53 issues:
**39 Done (31 historias y8 épicas),8 In progress (4 historias y4 épicas),
6 Backlog (6 historias)**. No es porcentaje de avance ni53 entregas distintas.

Pendientes de implementación: baja #24, exportación #25, controles #51 y
coincidencias #71/#72. Push #42 sigue diferido. Las tablas/notas inferiores
son instantáneas históricas, sustituidas por esta actualización.

## Alcance y evidencia de esta actualización

Usuario autoriza incluir el match y actualizar los recorridos ya validados.
Se conserva el trabajo local previo de estadísticas y sus documentos. ADR-137,
guía, backlog y fichas actualizados; sin modificar código de producto, ejecutar
SQL, desplegar, hacer commit/push o activar Firebase. La aprobación es de alcance,
no entrega del motor. Indexación versionada, ranking de hasta cinco candidatos
con señales visuales/geográficas/temporales y revisión humana; sin identidad
garantizada, propietario automático ni cierre del caso por sugerencia.

Validación final:53 issues y53 tarjetas consultados por API;39 Done,8 In progress
y6 Backlog, sin discrepancias de estado abierto/cerrado, etiqueta o Status.
#71/#72 con prioridad P1 verificada. Enlaces locales de documentos modificados
sin destinos ausentes y git diff --check correcto. Sin repetir
pruebas de producto por un cambio de planificación y aceptación. Siguiente paso:
refinar modelo, ejecución, candidatos reales y recorrido de HU-25/HU-26 antes
de implementar; no reclasificar los avisos ya vinculados como nuevos hallazgos.

## HU-16.1 cerrada con aceptación del usuario —24/10/2026

El usuario confirma haber probado el recorrido después de aplicar039 y asignar
la cuenta autorizada; solicita actualizar GitHub/Projects y no repetir la prueba.
Se registra como aceptación del usuario, sin atribuir al agente una comprobación
de sesión administradora ni un contraste alojado de conteos que no realizó.
Se cancela la autenticación adicional: no se envían códigos ni se cambian sesiones.
Se conserva la evidencia independiente alojada: cuatro rechazos correctos de
las RPC para cuenta ordinaria/visitante, además de89 web,33 servidor,58 SQL
locales, typecheck/build y Chrome previos.

PR70 fusionado en main, commitb8c12e4. CI del commit integrado aprobada: web
run40160764194 y backend run40160764206 (SQL y fotos). Algunas ejecuciones
duplicadas SQL de rama/PR seguían en curso al consultar; no se afirma su resultado.
#50/HU-16.1 cerrada, cuatro criterios marcados y status:done/Projects Done.
#16/HU-16 sigue abierta/In progress con #50 completada y #51 pendiente de acordar
funciones controlables e implementar. No se inicia HU-16.2 ni se cierra el MVP.
Documentación y ficha sincronizadas; sin nuevos cambios de producto, SQL remoto,
commit/push o despliegue por este seguimiento. Siguiente paso funcional: refinar #51.

## Asignación confirmada; primera comprobación alojada —24/10/2026

El usuario confirma ejecución de la operación privada de asignación. Se registra
como confirmación, pendiente de observar el acceso con sesión de esa cuenta.
Comprobación real de desarrollo de solo lectura: las RPC require_platform_administrator
y read_pilot_statistics rechazan a una cuenta ordinaria con403/42501 y a visitante
sin sesión con401/42501; cuatro verificaciones aprobadas. Sesión QA creada para
esta consulta cerrada con scope=local; otras sesiones conservadas. Evidencia local
ignorada: apps/platform/statistics-negative-remote.log.

PR70 ya fusionado, commitb8c12e4; comprobaciones web aprobadas, SQL todavía en curso
al consultar. No se afirma CI final ni cierre de #50/#16. Las sesiones de prueba
disponibles pertenecen a otras cuentas; se solicita al usuario elegir código de
correo o inicio local para autenticar la cuenta administradora, sin pedir su
contraseña ni cambiarla. Pendientes: acceso administrador/conteos alojados y CI SQL.

## Cuenta administradora identificada —24/10/2026

El usuario indica la cuenta concreta autorizada para estadísticas. Se prepara
operación privada local en work/assign-pilot-administrator.sql, fuera de Git,
que exige una coincidencia única en auth.users, asigna solo ese UUID de forma
idempotente y devuelve administrator_assigned. No se versiona el correo personal.
No hay conexión SQL administrativa disponible en esta sesión; la asignación
remota sigue pendiente de ejecutar la operación en SQL Editor de desarrollo.
No se reaplica039 ni se asigna permiso de moderador. Después se comprobarán
acceso administrador, rechazo de otras cuentas y conteos alojados.

## Aplicación de039 confirmada por el usuario —24/10/2026

El usuario confirma ejecución completa del patch039 en Supabase de desarrollo.
Se registra como confirmación, sin afirmar comprobación remota por el agente.
El patch no asigna administradores. Pendientes: identificar/asignar una cuenta
autorizada, comprobar roles y conteos alojados, publicar rama y revisar/integrar
con CI. #50/#16 siguen abiertas; no se repite039 por esta confirmación.

## Commit local de HU-16.1 observado al terminar —24/10/2026

El workspace ya contiene commit local6d43a21, con estadísticas y documentación;
árbol limpio al comprobarlo, sin rama remota ni PR de pilot-statistics. Esta
observación sustituye «sin commit» de las notas del incremento. La regresión SQL
final pasó58/58; permanecen89/89 web,33/33 servidor, typecheck/build y Chrome
aprobados. El agente no ejecutó ese commit ni publica otro por este seguimiento.
Activación039, cuenta administradora explícita, demo alojada e integración
siguen pendientes. #50/#16 permanecen abiertas; no se inicia #51.

## HU-15 cerrada; HU-16.1 implementada localmente —24/10/2026

Por autorización del usuario se continúa desde la rama offline. PR
[#69](https://github.com/srg-cp/entrehuellas/pull/69) ya fusionado en main,
commit1424b72; checks del HEAD477d33e Flutter validate y web aprobados.
En main también pasan validate y web. #49/HU-15.3 y épica #15/HU-15 cerradas,
etiqueta/Projects Done, con criterios y evidencia de las tres derivadas.
El job release de run40159160220 falló al no recibir los cinco secrets de
configuración/firma. La nota paralela inferior registra su configuración
confirmada posteriormente por el usuario; falta comprobar una nueva ejecución
con firma definitiva. No se afirma APK publicado.

Main local actualizado y nueva `feature/pilot-statistics`; se preserva la nota
local de seguimiento anterior en este documento. Implementación HU-16.1/RF-35/#50:
`/administracion/estadisticas`, siete agregados por fechas inclusivas de Lima,
máximo366 días, acceso desde Inicio y retorno por motor compartido. Dominio,
casos de uso, repositorios/DTO/fuentes y ViewModel; política global SSR/cliente
administrator y autorización de cada RPC con permiso independiente de moderación.
Usuario confirma cancelado=retirado sin recuperación registrada y archivado=
retirado después de recuperación registrada. No se infieren recuperaciones
antiguas de resolved ni se atribuyen a la app; sin datos personales/coordenadas.
Plan039/fuentes125–127, migración/patch039 generados y run_all actualizado mediante
generadores. No se cambian Flutter, estados de casos, roles existentes ni HU-16.2.
[Contrato, activación y límites](funcionalidades/estadisticas-piloto.md), ADR-136.

Validación final: **89/89 web**, **33/33 servidor Nuxt construido**, typecheck y
build correctos; **58/58 SQL/PostGIS locales**, incluidas dos nuevas con datos
reproducibles, permisos, revocación, repetición y límites05:00UTC de Lima. Chrome
con fixture: apertura0/5/15/45/99/100 y cierre50/75/95% en1440/390/320, fullscreen,
reducido, teclado/foco en fechas, refresh/fallo conservando consulta confirmada,
vacío y revocación sin datos residuales. Renders1920/1440/731/390/320 y320/texto200%
revisados, sin overflow, errores JS/CSP/hidratación detectados. Build conserva
avisos de rendimiento de plugins y exports obsoletos de Vue; sin cambiar dependencias.
Logs/capturas locales ignorados descritos en la ficha; no son artefactos publicados.

#50 y épica #16 pasan a In progress, sin cerrar criterios alojados ni #51.
Auditoría API final de los51 issues:31 cerrados/Done,16 abiertos/In progress y4
abiertos/Backlog; etiquetas y Projects concordantes. No equivale a porcentaje del
MVP ni a nueva demo de todas las historias. Los pendientes anteriores se conservan.

Siguiente paso: aplicar todo039 en Supabase de desarrollo, asignar explícitamente
una cuenta administradora autorizada y demostrar roles/conteos reales; después
publicar/revisar/integrar HU-16.1 y verificar CI. No se aplica SQL remoto, asignan
roles, despliega web ni hace commit/push/PR del incremento nuevo por esta tarea.
Se conservan los cambios paralelos en la guía raíz/README/ficha de distribución
y su nota de firma/secrets. Sin confirmación alojada no se cierra #50/#16.
Safari/Firefox y aprobación visual
del usuario pendientes; no se inicia HU-16.2 ni se declara auditoría global.

## Firma y secrets Android configurados; inventario documentado —24/10/2026

El usuario confirma generación de firma definitiva, carga de los cinco secrets
de repositorio (MOBILE_CONFIG_JSON, ANDROID_KEYSTORE_BASE64,
ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS y ANDROID_KEY_PASSWORD) y
key.properties local completado con sus datos. Comprobada existencia local de
JKS, exportación Base64, JSON y properties; properties ignorado/no versionado.
No se leen ni documentan contraseñas, JSON real o Base64. La carga en GitHub
se registra como confirmación del usuario, sin auditoría remota de correspondencia.

[Guía raíz: estado e inventario](../INSTALACION_ANDROID.md#estado-de-la-preparacion)
relaciona cada secret con su archivo/propiedad local, origen y regeneración;
distingue copia operativa de respaldo privado, sin duplicar valores en .env.local.
README y ficha de distribución actualizados; evidencia histórica de build con
firma desechable separada de esta configuración definitiva. No se modifica código,
workflow, credenciales ni los cambios paralelos de estadísticas/offline.

Validación documental: enlaces, cinco nombres de secrets y correspondencia de
propiedades con scripts/workflow; diff de estos documentos sin errores de espacio.
Sin repetir suites/build por cambios solo documentales ni ejecutar publicación.
Pendientes: confirmar respaldo privado, integración a main, Actions con firma real
y prueba de instalación/recorridos con backend real. Siguiente paso: primera
ejecución de Flutter desde main y revisión de validate/release.

## Seguimiento de HU-15.3 en GitHub actualizado —24/10/2026

El usuario confirma el commit; se verifica477d33e publicado en
feature/offline-case-cache. [#49](https://github.com/srg-cp/entrehuellas/issues/49)
actualizado con cuatro criterios técnicos verificados, evidencia local/remota,
enlaces al commit/documentación y límites. Etiqueta y Projects pasan de Backlog a
In progress. Permanece abierto: no existe PR de la rama ni fusión a main; CI web
run40158700222 estaba en curso al consultar, sin afirmar aprobación final.
No se crea PR, fusiona código, cierra #49/#15 ni publica otro commit por esta tarea.
Siguiente paso: PR, checks aplicables e integración antes del cierre.

## HU-15.3: fichas consultadas sin conexión implementadas y validadas —24/10/2026

Por autorización del usuario se implementa HU-15.3/RF-32/#49 en
`feature/offline-case-cache`, sin cerrar automáticamente #49 ni la épica #15.
`offline_cases`/ADR-135 conserva fichas públicas de perdido/encontrado consultadas
y fotos en SQLite privado por cuenta; Guardados incorpora Consultados en este
dispositivo por composición. Aviso/fecha/Actualizar en copia offline, sin contactos,
URLs firmadas ni permisos persistidos. Hasta30 fichas/32MiB y3 fotos de2MiB.
Ausencia/cierre/rechazo remoto invalida la copia y las respuestas/descargas tardías
no deben restaurarla. No hay SQL, Edge Function, mapas descargados o PWA nuevos.
[Contrato, recorrido y límites](funcionalidades/fichas-sin-conexion.md).

Validación final: **591/591 Flutter**, incluidos16 checks nuevos de caché y los
de arquitectura, con `AMBIENT_BACKGROUND_MOTION=false`; formato y análisis sin
incidencias, diff sin errores de espacio. Prueba real de desarrollo aprobada en6s:
cuentas A/B distintas, JPEG procesado/foto Storage decodificable, reapertura SQLite
sin red, aislamiento/logout, reconexión y cierre real del fixture seguido de
invalidación sin resurrección. Fixture QA retirado mediante APIs; casos originales
y otras sesiones conservados. No se reaplican patches ni se despliega backend.

App normal Android emulada: ficha perdida existente consultada, Wi-Fi desactivado+
modo avión, force-stop, reapertura → Explorar/Guardados → ficha con foto/datos/fecha
offline y sin contactos/acciones remotas. Red restaurada y Actualizar retira el
aviso y reconsulta operaciones autorizadas. Snapshot SQLite real confirma1 ficha/
1 foto con hash, cero URLs firmadas/contactos/flags. Build profile x64 final69.4MB
correcto e instalado conservando datos. Umbral temporal de almacenamiento del AVD
restaurado tras instalar; Wi-Fi activo y modo avión desactivado. Renders normales
y320×500/texto200% revisados, sin atribuir aprobación visual del usuario.

Logs locales en apps/mobile/build:offline-cases-full-tests.log,
offline-cases-analyze.log, offline-cases-remote-final.log,
offline-cases-android-build-final.log; evidencia nativa offline-case-native-evidence.json
y XML/capturas de reapertura/reconexión. No se acredita teléfono físico ni reboot
del SO. Si el almacenamiento impide borrar una copia invalidada, se oculta en el
proceso y se informa el fallo, sin afirmar persistencia hasta reintentar con éxito.

Siguiente paso: revisar/integrar este incremento y tramitar #49/HU-15 con su
evidencia cuando se autorice. No se hace commit/push/PR ni cierres en GitHub.
Se conservan los cambios paralelos del dominio público en el workspace; el resultado
de esta suite usa movimiento ambiental desactivado y no reescribe sus pendientes
de validación/publicación. No se inicia otra funcionalidad por arrastre.

## Dominio público entrehuellas.app —24/10/2026

Por instrucción del usuario, se actualiza el dominio público anterior en los
valores de respaldo del origen permitido, OAuth y cookies del servidor, SEO
Nuxt y consumidores Android de avistamientos, carteles/QR y compartir. Ejemplos,
configuraciones locales ignoradas de Android y guías actualizados; endpoints
Supabase e infraestructura conservados. No se reescribe SQL ni decisiones y
evidencias históricas. El usuario informa Cloudflare/Resend verificados y
cambios remotos de Supabase; el agente no los certifica ni despliega.

Validación local: npm test83/83; typecheck y build correctos; test:server31/31.
Tras añadir regresión del origen por defecto, production.test.mjs7/7: origen
nuevo llega a validación, anterior rechazado403, SEO predeterminado y sustitución
en runtime verificados. Build muestra advertencias de BigInt/es2019 y exports
de Vue; no se modifican dependencias por esta tarea. Flutter: formato correcto,
analyze sin incidencias;25 pruebas aprobadas y2 fallidas por pumpAndSettle
timeout en case_posters_test.dart (líneas155 y380), reproducidas en segunda
ejecución. No se afirma suite móvil completamente aprobada ni causa del timeout.

Siguiente paso: publicar esta revisión cuando se autorice y redesplegar web con
PUBLIC_WEB_ORIGIN y NUXT_PUBLIC_SITE_URL=https://entrehuellas.app. Recompilar
Android con PUBLIC_CASE_WEB_URL nuevo y actualizar la configuración privada de
CI si aún contiene el anterior. Comprobar acceso/correo/OAuth, fichas, QR y
avistamientos en producción. Mantener el host anterior o configurar redirección
permanente de navegación con ruta/parámetros para QR/PDF ya distribuidos; cookies
no se transfieren. Pendientes: redirección remota, revisión Google y2 timeouts
Flutter. Sin commit/push, despliegue, APK ni nuevos cierres de HU/issues.
[Ficha y activación](funcionalidades/landing-page.md).

## GitHub reconciliado: PR67 fusionado y #47/#48 cerrados —24/10/2026

PR [#67](https://github.com/srg-cp/entrehuellas/pull/67) fusionado en main,
commit12dac7b. CI del HEAD4968a34 aprobado: Flutter validate6m40s (cinco pruebas
Python, formato, análisis y suite Flutter), SQL56/56 y procesamiento de fotos.
#47/HU-15.1 y #48/HU-15.2 cerrados con criterios/evidencia, etiqueta Done y Status
nativo concordantes. Verificación final API de los51 issues:29 cerrados/Done,
15 abiertos/In progress y7 abiertos/Backlog; ninguna discrepancia ni etiqueta
status duplicada. #5/#6/#9 conservan cierres previos con casillas técnicas
corregidas. #43–#46 y épicas #14/#15 ya reflejan implementación iniciada;
needs:refinement retirado de #44 porque su alcance ya estaba acordado.

No hay otro cierre adicional justificado: los22 abiertos conservan los criterios
de la [auditoría](backlog/auditoria-github-2026-10-24.md). #15 sigue abierta por
#49/HU-15.3, siguiente incremento sin iniciar. No se reaplica SQL ni se despliega
backend por esta reconciliación. La distribución automática de APK tiene un
pendiente independiente y previo: faltan los cinco secrets de configuración/firma
en GitHub; run40040206814 validó Flutter y falló en Prepare private build files.
No se afirma publicación de APK ni se crean credenciales de firma por esta tarea.

## Integración y auditoría de GitHub autorizadas —24/10/2026

El usuario autoriza integrar HU-15.2 y revisar/cerrar también las demás entregas
terminadas. Auditoría de los 51 issues: 27 ya cerrados; #47/HU-15.1 y #48/HU-15.2
cumplen el cierre con la evidencia final inferior. Se tramita
[#67](https://github.com/srg-cp/entrehuellas/pull/67) a main y CI,
con herramientas de validación y patches037/038 ya comprobados en desarrollo.
Las otras historias abiertas conservan criterios pendientes concretos; no se
cierran por existir pantallas o por aplicación de un patch. Se sincronizan
etiquetas/Projects, casillas antiguas de #5/#6/#9 y la épica #15, que queda
abierta por #49. [Revisión de todos los issues](backlog/auditoria-github-2026-10-24.md).
Siguiente incremento funcional: HU-15.3; no iniciado. La evidencia Android es
de emulador y reinicio de proceso, sin afirmar teléfono físico o reboot del SO.

## HU-15.2: validación técnica completada con037/038 —23/10/2026

El usuario confirma aplicación del038 después del037. Nueva ejecución completa
contra Supabase de desarrollo: **6/6 aprobadas**, sin omisiones, en15s
(`apps/mobile/build/queue-hosted-validation-after-038.log`, exit0).
Ahora se comprueban expresamente los tres puntos de rechazo: payload distinto
de perdido, campos distintos de búsqueda y selección de fotos distinta en su
preparación. Devuelven conflicto de dominio, sin los timeouts anteriores.

Pasaron de nuevo fotos reales (tres en búsqueda), publicación perdida con
replay concurrente, respuesta descartada tras commit, reapertura de cola y recibo
sin HTTP; encontrado vinculado de B, avistamiento por Nuxt con evidencia,
aislamiento/autorización A/B y revocación de la sesión de prueba entre commit y
respuesta. Fixtures retirados/mascotas QA archivadas conforme al contrato.
No se modifican otras sesiones ni se ejecuta cancelación/restart remoto.

Validaciones previas vigentes:575/575 Flutter, análisis limpio,10 checks SQLite
nativos y ciclo real en app normal Android emulada sin red→force-stop→reabrir→
publicación automática con UUID/huella intactos, recibo y un solo resultado.
Cuatro SQL focalizadas con037+038 pasan y conservan metadatos/ACL de las cuatro
funciones. **Regresión SQL completa posterior a038:56/56 aprobadas**, cero fallos,
cero omitidas, exit0 (`database/tests/queue-full-sql-validation-after-038.log`).
La validación técnica solicitada queda completada para Android emulado y backend
de desarrollo:575 Flutter,56 SQL locales,6 remotas estrictas y10 checks SQLite
nativos, además del recorrido visible normal documentado. Análisis sin incidencias
y diff sin errores de espacio; no quedan checks ejecutándose ni bloqueos técnicos
del alcance comprobado. App normal actualizada instalada, sesión conservada,
Wi-Fi habilitado y modo avión desactivado. Siguiente incremento funcional:HU-15.3,
sin iniciarlo por arrastre. No se hizo commit/push ni cierre de issue/épica.
Esta entrada sustituye los pendientes de activación/suite remota de las notas
anteriores. No implica cierre en GitHub ni prueba de teléfono físico.

## Patch037 aplicado; complemento038 para helper interno —23/10/2026

El usuario confirma ejecución del037. Nueva suite contra desarrollo verifica
perdido con PT409 (sin el timeout anterior), replay concurrente y recibo local.
La prueba estricta de búsqueda con rasgos modificados sigue en timeout: la RPC
publish_recovery_report delega esa comparación a publish_found_case, cuyo cuerpo
no estaba en el alcance del037. Suite5/6; los otros escenarios, incluida revocación,
pasan y los fixtures se retiran. Log: queue-hosted-validation-after-037.log.

Se corrige la omisión con fuente124/plan038/patch038, sin reescribir037 aplicado.
Solo reemplaza40001 por PT409 en ese helper, conservando cuerpo restante,
OID/propietario/security definer/proconfig/ACL. La prueba de conversión ahora
cubre las cuatro funciones y repetición de ambos patches. Cuatro SQL focalizadas
aprobadas (queue-nested-conflict-sql-targeted.log); suite SQL completa posterior
en curso. Flutter no cambia:575 pruebas/análisis y APK actualizado previos vigentes.
Se solicita al usuario ejecutar TODO database/patchs/038_patch_recovery_nested_business_conflicts.sql
con rol administrativo; sin acceso DDL por las cuentas A/B. Siguiente paso:
confirmar038 y repetir las6 pruebas remotas estrictas. No se cierra la validación
por el éxito parcial del037 ni se ejecutan restart/cancelaciones remotas.

## Hallazgo final HU-15.2: conflicto remoto requiere patch037 —23/10/2026

La ampliación de la última prueba remota con mismo UUID y payload cambiado falla:
se esperaba CaseFailure.conflict, pero el servidor no responde y se alcanza el
timeout30s. Reproducción HTTP directa agota10s, independiente de Flutter. La suite
ampliada termina5/6; los seis escenarios base previos y el ciclo Android completo
sí pasaron como se detalla debajo. **La validación final aún no está cerrada.**

Preparada corrección [ADR-134](decisiones/134-conflictos-de-publicacion-sin-reintento-postgrest.md):
plan037/fuente123 y patch037 generados, sin alterar migraciones previas. Cambia
solo los40001 explícitos de tres RPC de cola a PT409, conservando cuerpos restantes,
settings y permisos; adaptadores Flutter compatibles con ambos. Cuatro pruebas
SQL y20 Flutter focalizadas pasan. Regresión completa posterior: **575/575 Flutter,
56/56 SQL locales**, análisis sin incidencias y diff sin errores de espacio.
Build profile normal actualizado69.3MB compilado e instalado con éxito; conserva
sesión/datos y compatibilidad con40001/PT409. Logs finales:
`apps/mobile/build/queue-full-validation-tests-after-conflict.log`,
`queue-final-validation-analyze-after-conflict.log`,
`queue-normal-android-profile-build-final.log` y
`database/tests/queue-full-sql-validation-after-conflict.log`.
Se solicita al usuario aplicar TODO database/patchs/037_patch_recovery_business_conflicts.sql
en SQL Editor de desarrollo, pues las cuentas A/B no autorizan DDL. Sin ejecución
remota, restart ni cancelación de sesiones por el agente. Siguiente paso: aplicar
037 y repetir la suite remota con conflicto estricto de perdido y de preparación/
publicación de búsqueda; no ocultar esas comprobaciones. No queda ningún check
local ejecutándose; pendiente exclusivamente la activación/verificación remota037.

## HU-15.1/15.2: evidencia previa al hallazgo final en Android y desarrollo remoto —23/10/2026

Por petición explícita de terminar la validación, se comprueba el backend real
de desarrollo confirmado por el usuario. La segunda cuenta ya existía; acceso
por código enviado/confirmado por el usuario, sin cambiar su contraseña.
Configuración privada/sesión solo en `apps/mobile/config/profile_test.local.json`,
ignorado por Git. No se registran credenciales ni tokens en estos documentos.

Resultados finales:

- **575/575 pruebas Flutter**, sin omisiones, con movimiento ambiental desactivado;
  análisis final sin incidencias y diff sin errores de espacio.
- **55/55 pruebas SQL de la suite completa** en PGlite/PostGIS; no son55 pruebas
  alojadas. La autorización remota se comprueba adicionalmente con A/B reales.
- **6/6 pruebas remotas nuevas**: perdido, búsqueda comunitaria con tres fotos,
  encontrado vinculado con autor B, avistamiento por endpoint Nuxt, aislamiento/
  permisos/logout y revocación de la sesión de prueba entre commit y respuesta.
  Usan repositorios/casos de uso reales y JPEG decodificable procesado por el
  servidor. La inyección descarta una respuesta HTTP2xx ya recibida del servidor;
  el replay del mismo UUID confirma una publicación y el recibo local evita HTTP.
  Dos publicaciones concurrentes idénticas de perdido devuelven el mismo caso.
  Logout local revoca realmente el refresh token, detiene el siguiente elemento
  y permite recuperar ambos UUID al reingresar. No se revocan otras sesiones.
- **10 comprobaciones nativas SQLite** en Pixel_9a/Android16/API36: migración1→2,
  tres evidencias de2MiB, aislamiento, conflicto de payload, dos conexiones con
  una sola reclamación, descarte protegido, reapertura, nonce antiguo, backoff
  y evidencia de avistamiento de8MiB. Hash completo de los bytes conservado.
  Tiempos observados: lectura/migración6MiB682ms, enqueue6MiB709ms,
  escritura/lectura8MiB1296ms; no son SLA ni medición en teléfono físico.
- **App normal instalada y recorrida** con la sesión que ya tenía el emulador:
  Perfil→Borradores/Envíos accesibles sin red incluso ante fallo de perfil;
  formulario→guardar/salir→force-stop→reabrir sin red→Retomar conserva el texto
  exacto. El intento de reportar una mascota con caso activo es rechazado sin
  cambiar ese caso; se descarta solo el borrador QA creado para la prueba.
  Búsqueda comunitaria nueva con foto normalizada desde galería: publicar sin red
  queda pendiente; cierre/reapertura conserva UUID/huella; al restaurar red,
  **sin pulsar Reintentar**, el intento4 publica y Ver resultado abre su ficha.
  SQLite antes/después confirma mismo UUID/huella, recibo durable, payload
  reducido289260→564 caracteres y cero borradores restantes. Consulta remota
  confirma un solo resultado activo con una foto. Se elimina exclusivamente
  esa publicación QA desde Mis reportes y se verifica que deja de ser pública.

Herramientas reproducibles nuevas en `apps/mobile/tool`:
`check_submission_queue_remote_test.dart` y `offline_queue_native_validation.dart`.
Logs en build: `queue-full-validation-tests.log`, `queue-final-validation-analyze.log`,
`queue-hosted-validation-final.log`, `queue-native-validation-android.log`;
SQL: `database/tests/queue-full-sql-validation.log`. Evidencia del ciclo real:
`queue-android-cycle-evidence.json`, snapshots SQLite y XML de las pantallas.

Gradle vuelve a funcionar dentro del agente usando solo para cada proceso
JAVA_TOOL_OPTIONS con directorio temporal de sockets bajo android/build.
Sin cambio persistente de Java/Gradle/proyecto. Build normal debug correcto;
por espacio del AVD, se instala el build profile x64 de53.6MB. Windows registra
caídas0xc0000005 del emulador headless con la configuración gráfica inicial;
se completa la UI con ANGLE, Vulkan desactivado y arranque software/Impeller
desactivado mediante extras de Activity, sin cambiar Manifest ni producción.
Wi-Fi/modo avión restaurados; queda instalada la app normal, sin APK de smoke.

Los fixtures remotos del harness se retiran mediante APIs de usuario; mascotas
QA con historia quedan archivadas según contrato y se conserva auditoría/recibos.
El recibo local de la publicación Android retirada permanece como comprobante.
Sin cambios de producto/SQL, migraciones, despliegue, commit/push o cierre en GitHub.
Los escenarios anteriores quedan acreditados para este entorno; la ampliación
posterior detecta el conflicto descrito arriba, que requiere patch037 antes de
completar la validación final. No se afirma teléfono físico, todos los fabricantes
ni fallo físico de almacenamiento. Siguiente incremento tras ese cierre: **HU-15.3**;
la comprobación complementaria en teléfono físico no se presenta como ejecutada.
Esta sección sustituye los bloqueos/pendientes de APK y demo remota de las notas
históricas inferiores para los escenarios concretos aquí comprobados.

## Smoke Android offline aprobado en emulador —23/10/2026

El usuario genera APK debug solo android-x64 del smoke existente:
`flutter build apk --debug --target tool/offline_drafts_smoke.dart --target-platform android-x64`.
Archivo126240513 bytes,23/10 a21:52; ADB instala con éxito en Pixel_9a,
Android16/API36/x86_64. Sustituye los bloqueos de instalación descritos debajo;
la compilación se realizó en PowerShell externo, no dentro del agente.

Primera ejecución: `OFFLINE_DRAFTS_SMOKE_PASS phase=WRITE count=3`, PID4196.
Se activa modo avión y se deshabilita Wi-Fi, se fuerza cierre con am force-stop
y se comprueba ausencia de PID. Nueva apertura en frío, PID4386:
`OFFLINE_DRAFTS_SMOKE_PASS phase=READ count=3 accountIsolation=true evidence=true partialDate=true queueProcessRecovery=true`.
Verificados UUID/campos parciales, bytes de evidencia y separación smoke-A/smoke-B;
la reclamación en curso vuelve a pendiente al abrir desde otro proceso.
Wi-Fi y modo avión restaurados a sus valores iniciales al terminar.
Logs locales: `apps/mobile/build/queue-android-write.log` y
`apps/mobile/build/queue-android-read-offline.log`.

Smoke usa SQLite separado y actores de prueba sin Auth/backend; no valida
fotos reales, recorrido normal Perfil/Borradores/Envíos, sesión real, pérdida de
respuesta del commit ni deduplicación en Supabase alojado. No equivale a reinicio
completo del dispositivo ni Android físico. En el emulador queda instalado el
APK de smoke, no la entrada normal main; datos existentes no borrados.
Sin cambios de producto/SQL, commit, push o despliegue remoto. Siguiente paso:
restaurar build normal para recorrido Android/Supabase real y validar reintento
sin duplicados, cambio/revocación de sesión y fotos máximas. HU-15.1/15.2 no se
cierran por este smoke. Diff documental sin errores de espacio.

## Validación Android offline: APK compilado, instalación pendiente —23/10/2026

El usuario compila correctamente desde PowerShell externo el smoke
`flutter build apk --debug --target tool/offline_drafts_smoke.dart`.
APK local verificado:193546225 bytes; Android SDK Platform35 instalado y licencia
aceptada durante el build. Command-line Tools23 instalado; Flutter3.35.3 sigue
informando licencias desconocidas al no reconocer la nueva salida de la CLI.
Gradle help funciona fuera del agente; dentro continúa el fallo de conexión
local de Java, también con JDK17 y selector alternativo. No se cambió la
configuración del proyecto ni se afirma resuelto ese fallo.

Emulador Android16/API36 conectado. Instalación ADB del APK intentada dos veces,
incluida selección x86_64: Android rechaza por espacio insuficiente, con475MB
libres de5.8GB. La reclamación de caché mediante `pm trim-caches 1G` no libera
espacio. No se borran datos ni se desinstala la app existente. No se ha ejecutado
el smoke ni validado reinicio nativo. Siguiente paso: compilar APK solo para
android-x64 para reducir tamaño; si no basta, ampliar almacenamiento del emulador.
Android/Supabase real, pérdida de respuesta y cierre de HU-15.1/15.2 pendientes.

Nueva verificación solicitada por el usuario: ADB inicialmente sin dispositivos;
se inicia Pixel_9a sin ventana y se espera arranque completo (API36). Sigue
disponible el mismo APK debug de193546225 bytes del23/10 a21:37, sin un APK
android-x64 nuevo en outputs. Con566MB libres tras arrancar, la instalación
`adb install -r --abi x86_64` vuelve a fallar:
`INSTALL_FAILED_INSUFFICIENT_STORAGE: Failed to override installation location`.
No se ejecutó el smoke, no se borraron datos y no se cierra el feature.

## Corrección visual del panel Compartir ficha —23/10/2026

El usuario precisa que Favoritos, Seguir y Bloquear deben tener el mismo diseño
que Descargar/Denunciar. Se sustituyen las filas de texto del incremento anterior
por círculos grises56/iconos26, todos debajo del separador del panel. Un único
PanelActionButton comparte diseño, tooltip/semántica y estado deshabilitado.
Wrap centra las cinco acciones y adapta filas en pantallas estrechas. Los
reintentos de bloqueo también mantienen formato circular; confirmación, guardado,
seguimiento y lógica de permisos existentes conservados. El modo de icono se
activa únicamente en el panel de ficha; otras entradas mantienen sus etiquetas.

Validación:43/43 pruebas focalizadas de compartir, notificaciones, bloqueos y
arquitectura, con movimiento ambiental desactivado; incluye guardado real con
reapertura/doble envío, cuatro combinaciones de tamaño/movimiento y acciones por
tooltip. Renders390×844 y320×350/texto200% revisados. Análisis Flutter sin incidencias y diff sin errores de espacio. Logs locales
`apps/mobile/build/public-actions-icons-{tests,analyze}.log`.
Pendiente revisión en Android real; sin APK, despliegue ni cambios SQL.


## Ficha pública: acciones y navegación glass —23/10/2026

Por instrucción del usuario, Favoritos, Seguir caso/Dejar de seguir y
Bloquear/Desbloquear se trasladan al panel blanco «Compartir ficha».
Cabecera con Volver/Compartir únicamente. El problema venía de offsets propios
laterales8 de la ficha frente a24 del shell habitual, además del espacio reservado
para Guardar. GlassNavigationBar concentra posición segura superior+4 y márgenes
simétricos24; CasePublicScreenShell y EntityScreenShell la reutilizan.

Router compone widgets existentes por slots del panel, sin imports cruzados de
presentación. Favoritos ofrece texto y conserva ViewModel/semántica de selección,
shimmer, reintento y bloqueo de doble envío. Seguimiento conserva su elegibilidad
por tipo de caso; bloqueo mantiene confirmación y refresco de contactos. Contacto
permanece en el cuerpo. Se conservan los dos recorridos de avistamiento: la tarea
actual no pide modificarlos. Sin cambios de dominio, SQL, QR o web ni despliegue.
Rama `feature/offline-submission-queue`, árbol inicialmente limpio.

Validación: **65/65 pruebas focalizadas** (compartir, tarjetas públicas, cargas,
contactos, transiciones de creación, notificaciones, bloqueos y arquitectura) con
`--dart-define=AMBIENT_BACKGROUND_MOTION=false`. Añadida después una prueba real
de Favoritos en el panel: guardar/quitar, doble envío y releer al reabrir; suite
final de compartir **10/10**, total66 pruebas distintas verificadas. Análisis
Flutter sin incidencias. Geometría comparada entre shells con inset24, estabilidad
al scroll y panel normal/reducido; renders390×844 y320×350/texto200% revisados,
acciones alcanzables por scroll. Formato aplicado y diff sin errores de espacio.
Logs: `apps/mobile/build/public-actions-{tests,analyze,sharing-final}.log`;
renders: `apps/mobile/build/ui-preview/{case-sharing,public-cards}`.

Decisión [ADR-133](decisiones/133-acciones-de-ficha-y-navegacion-glass-compartida.md),
[ficha pública](funcionalidades/ficha-publica-mobile.md) y
[panel](funcionalidades/compartir-ficha.md) actualizados. Pendiente revisión física
Android y aprobación visual del usuario. No se generó/instaló APK ni se auditó la
posición de todos los controles de la app. Siguiente paso: revisar esta ficha
en dispositivo con datos reales y comprobar servicios/contacto tras bloqueo.


## HU-15.2: cola persistente y reintentos —23/10/2026

Por autorización «ok siguiente», implementado el incremento local de
HU-15.2/RF-32/issue #48 en `feature/offline-submission-queue`. HU-15.1 se conserva;
durante el trabajo apareció como HEAD `1b9b05f`. Esta sesión no hizo commit,
push, acciones en GitHub ni despliegue.

La confirmación de perdido propio, búsqueda, encontrado o avistamiento guarda
primero el comando exacto en SQLite esquema2. Migración1→2 conserva borradores.
La cola separa cuenta/UUID, fija huella de campos y fotos y reclama cada intento
atómicamente. Pérdida de respuesta/reinicio conserva UUID, instante, versión,
destino y evidencia; nunca crea una publicación alternativa para resolver un
conflicto. Recibo validado duradero antes de limpiar bytes/borrador; un envío ya
confirmado no vuelve a realizar HTTP. La lista de borradores excluye recibos
publicados incluso si falló su limpieza local.

Perfil → Envíos muestra pendientes/en curso, fallidos y publicados; permite
consultar motivo por toast, reintentar el comando original, revisar formulario
y abrir resultado. Los editores bloquean cambios durante intención pendiente/en
curso y aceptan el recibo tardío del mismo envío. Descarte cancela solo intención
pendiente/fallida; no revierte publicaciones. Encontrado conserva su RPC protegida.

Sincronización solo con app activa y cuenta autorizada por la política global:
entrada/resume y sondeo15s, backoff5/15/30/60/120s. Los rechazos definitivos detienen
el automático; corregir invalid/photo exige publicación explícita. Logout/cambio
de cuenta/pausa impiden el siguiente envío. El cierre de la app libera el timer.
No se promete trabajo en segundo plano ni se introduce SQL remoto, permisos,
workers o paridad offline Nuxt. Véanse [ADR-132](decisiones/132-cola-persistente-de-envios-android.md)
y [ficha](funcionalidades/envios-pendientes.md).

Validación final: **573/573 pruebas Flutter**, incluidas18 nuevas de cola/UI,
con `--dart-define=AMBIENT_BACKGROUND_MOTION=false`; análisis sin incidencias.
SQLite real: migración, reinicio/proceso, bytes, reclamaciones concurrentes,
respuesta perdida antes/después de persistencia simulada, recibo/identidad,
conflictos, disco fallido, revisión y cancelación. Router real con sincronización
activa comprueba visitante/bienvenida/cuenta preparada; se corrigió la liberación
del timer detectada al desmontar la app. Renders390×844 y320×350/texto200% con
fuentes reales revisados, acciones alcanzables por scroll. Formato676 archivos
sin cambios y `git diff --check` correcto. Logs locales en
`apps/mobile/build/queue-{full-tests-final,analyze-final,sql-regression}.log`.

**3/3 pruebas SQL focalizadas** sobre PGlite/PostGIS: perdido, encontrado y búsqueda;
verifican autorización/deduplicación de los comandos existentes. No equivalen a
suite SQL completa ni prueba de Supabase alojado. Sin migraciones remotas nuevas.

Smoke Android ampliado para recuperar borrador y reclamación entre procesos,
con base separada sin backend. Intentado en emulador; Gradle falla antes de compilar
con `java.io.IOException: Unable to establish loopback connection`
(`apps/mobile/build/queue-android-smoke.log`). **No hay APK nuevo ni instalación**.
Pendiente resolver Java/Gradle y comprobar Android/Supabase reales: cierre sin red,
reinicio, pérdida de respuesta alrededor del commit, cuenta/fotos, concurrencia,
revocación de sesión y rendimiento máximo. Implementación local, historia #48 y
épica sin cerrar. Siguiente paso: esa validación; HU-15.3 requiere continuar el plan.

## HU-15.1: borradores locales por cuenta —23/10/2026

El usuario da por resuelto el login OAuth de Supabase y autoriza continuar con
HU-15.1/RF-32/#47. Esta confirmación sustituye el pendiente operativo de OAuth
como siguiente paso; no se atribuye a esta sesión una prueba remota del login.
Rama local `feature/offline-drafts`, desde `04ed9f7`; árbol inicial con tres documentos locales modificados.

Implementado guardado/recuperación en Android de perdido propio, búsqueda
comunitaria, aviso de encontrado y avistamiento. Drift/SQLite local esquema1,
clave cuenta/contexto y UUID estable, campos parciales de fecha/hora, coordenada,
selección/versión de mascota, referencias de fotos propias y bytes de evidencia
nueva. Se excluyen URLs firmadas y backup/transferencia Android. `offline_drafts`
separa dominio/casos de uso, repositorio, fuente/DTO y ViewModel; los editores
convierten su propio estado y colaboran mediante dominio/providers. Composición
en main/bootstrap; sin imports cruzados de presentation/data.

Los editores leen el borrador antes de consultar mascotas/búsquedas remotas.
Salir conserva y espera la escritura; Perfil → Borradores reúne los de la cuenta
actual y abre el contexto original. Confirmación para descarte, fallos mediante
toast superior, skeleton/shimmer compartidos y bloqueo de dobles acciones. La
vista previa inmersiva mantiene sus restricciones de tamaño originales. Una
lectura corrupta/fallida no se convierte en vacío ni sobrescribe el borrador.

Antes de enviar se confirma en disco el comando exacto. Una respuesta incierta
se recupera congelada y reintenta UUID/contenido originales, incluidos instante,
versión y fotos. La confirmación elimina solo ese UUID. Encontrado conserva la
RPC de descarte que comprueba que no hay publicación activa antes del borrado
local; el rechazo conserva ambos estados. La limpieza local fallida tras una
publicación puede dejar el mismo comando reintentable, sin confirmar duplicados.

Para entrar al reiniciar sin red, el adaptador de bienvenida recuerda únicamente
un resultado remoto confirmado por cuenta en SharedPreferences. Solo usa `true`
para la misma identidad ante timeout/ClientException; responde a negativos y
rechazos remotos sin fallback. La sesión sigue siendo la ya guardada por Auth y
las operaciones conservan autorización remota. No es sesión nueva, rol/permiso
cacheado ni omisión de bienvenida. [ADR-131](decisiones/131-borradores-locales-por-cuenta.md)
y [ficha](funcionalidades/borradores-locales.md).

Validación final local:555/555 pruebas Flutter con
`--dart-define=AMBIENT_BACKGROUND_MOTION=false`;18 nuevas cubren persistencia y
UI/acceso, junto a las537 existentes.63/63 focalizadas tras revisar descarte y
comandos congelados. Archivo SQLite real cerrado/reabierto, aislamiento A/B y
logout, fecha parcial/evidencia binaria, UUID/versiones/instantes intactos,
escrituras ordenadas y recibos antiguos, corrupción sin reemplazo, fallo de disco
sin petición remota, reintento y bienvenida por cuenta. Tres pruebas de router
verifican visitante/bienvenida/cuenta preparada. Formato664 archivos sin cambios
y análisis final sin incidencias; `git diff --check` correcto. Capturas con fuentes
reales revisadas en build/ui-preview/offline-drafts (390×844 y320×350/texto200%);
acciones alcanzables por scroll, reintento/descarte y apertura única comprobados.
Logs en apps/mobile/build/offline-{full-tests-final,regression-final,analyze-final,ui}.log.

Durante el trabajo se corrigieron errores de integración/API y las restricciones
de la previa inmersiva detectados por las pruebas. Un primer pase de regresión
omitió el dart-define y encontró timeouts del fondo continuo; se repitió con el
parámetro ya usado por este proyecto. El primer render de QA no cargaba Poppins;
se corrigió el harness y se revisaron las capturas con fuentes reales. No se
omiten pruebas ni se presentan esos intentos como validación final.

Android intentado con `tool/offline_drafts_smoke.dart` y base separada, sin
cuenta/backend. Gradle falla antes de compilar con
`java.io.IOException: Unable to establish loopback connection`; reproducido
con JVM IPv4. No se obtuvo APK nuevo, no se instaló ni se reinició la app.
Pendiente resolver ese entorno y comprobar cierre/reinicio Android sin red,
fotos reales, entrada global/Perfil/Borradores, cambio de cuenta y publicación
con Supabase, además del rendimiento con fotos máximas. Fixtures y SQLite local
no sustituyen esas condiciones ni la aprobación visual del usuario.

No se cambió SQL/backend/Nuxt ni se activó cola automática HU-15.2 o caché de
fichas HU-15.3. Sin commit/push/PR, publicación o cierre de historia; cambios
previos de CONFIGURACION/ESTADO/acceso-web conservados. Siguiente paso: validación
Android pendiente; después HU-15.2 según sus propios criterios.

## Diagnóstico OAuth Google en producción —23/10/2026

Se reproduce una diferencia de allowlist en Supabase Auth: con PKCE y un flujo
nuevo por entorno, la cancelación simulada del proveedor conserva el callback
de http://127.0.0.1:5173 y su query flow, pero sustituye el callback de
https://entrehuellas.kormind.com por entrehuellas://login-callback/.
Ambos usan el mismo cliente Google y callback HTTPS de Supabase. Producción
responde200 al inicio OAuth, emite cookie HttpOnly/Secure/Lax y Auth responde302
hacia Google. El callback Nuxt sin flujo responde303 al login con fallo seguro.

Hallazgo confirmado: el retorno web de producción no está autorizado por la
configuración efectiva de Auth. Añadir el patrón acotado del callback con flow
a GOTRUE_URI_ALLOW_LIST (ADDITIONAL_REDIRECT_URLS en la plantilla estándar),
conservando móvil/local y recreando Auth. No se accede al panel/servidor ni se
modifican variables remotas. Sader usa otro backend Supabase.

Validación: solicitudes HTTP reales sin autenticar cuentas; no se intercambian
códigos ni se crean sesiones. Esta prueba demuestra el retorno incorrecto,
pero no acredita que explique por sí solo la espera dentro de Google de la
captura. Pendiente aplicar configuración y probar consentimiento/cancelación
con cuenta real; si persiste la espera, revisar la petición pendiente del
navegador y logs Auth. Sin cambios de código/SQL, build ni despliegue.
Detalles en [acceso web](funcionalidades/acceso-web.md) y CONFIGURACION.

El usuario confirma Compose GOTRUE_URI_ALLOW_LIST: ${ADDITIONAL_REDIRECT_URLS}
y Environment con host Supabase, http://localhost:3000/* y callback móvil,
sin callback web de producción. Historial: b51aa4b (19/10) ya generaba el mismo
callback web con flow y PKCE; b364688 conserva esa construcción. No se atribuye
el fallo a un cambio reciente del callback sin evidencia. El éxito observado
con127.0.0.1 no se explica solo con la lista declarada: comprobar el entorno
efectivo del contenedor Auth si difiere del Environment mostrado en Dokploy.

## Integración de bloqueos y apelaciones —23/10/2026

Se incorpora origin/main (c03fa84, merge de apelaciones fdcf1e3/PR#64) en
feature/user-blocking (dc0195b/PR#65). Se resuelven los11 conflictos conservando
ambas funcionalidades, APIs, inyección, rutas y suites de pruebas. La integración
se prepara en la rama de bloqueos, sin reescribir los commits originales.

El plan035 de apelaciones y fuentes119–121 se conservan intactos. El complemento
de contacto de bloqueos pasa de035/fuente119 a036/fuente122; cuerpo SQL idéntico,
con migración/patch regenerados desde el plan.034 permanece intacto. El bundle
incluye034,035 y036. Nuevas comprobaciones del catálogo rechazan versiones de
migración y números globales de fuentes duplicados en la suite SQL.

Se corrige primary_titles_test: MaterialIcons se carga desde el asset empaquetado
por Flutter, sin acceder a la ruta interna del caché SDK que faltaba en CI Linux.
No se cambia la UI ni se omite la prueba.

La revisión del router detecta además que /home/blocked-users estaba declarada
pero faltaba en la política global de cuenta móvil: redirigía al Inicio incluso
con onboarding completado. Se reproduce el fallo con el router real y se añade
la ruta al mismo control global. Tres regresiones cubren visitante, cuenta sin
onboarding y cuenta preparada; se conservan las pruebas reales de apelaciones.

Validación final local:537/537 Flutter (AMBIENT_BACKGROUND_MOTION=false), formato
643 archivos sin cambios y análisis sin incidencias;5/5 pruebas Python de
preparación de distribución.83/83 pruebas web,31/31 de servidor, typecheck y
build Nuxt correctos.55/55 SQL PGlite/PostGIS, incluida repetición del bundle,
ambas funcionalidades y catálogo sin colisiones. Chrome sobre build integrado:
apelaciones y bloqueos aprobados con fixtures, reintentos, permisos, navegación,
movimiento normal/reducido, pantallas pequeñas/texto200% y sin fallos CSP/hidratación.
El primer pase móvil reprodujo el fallo del router; tras corregirlo, la regresión
completa537/537 queda en build/integration-tests-final.log. No se omiten pruebas.

Siguiente paso: commit firmado/push en PR#65, verificar CI y fusionar con merge
para conservar fdcf1e3 y dc0195b en main. Confirmación remota pendiente al
registrar esta evidencia local; no equivale a despliegue ni cierre de historia.
Activación Supabase, despliegue Nuxt y demo física siguen siendo tareas separadas.
No se ejecuta SQL remoto ni se dan por cerradas las historias con esta integración.

## Bloqueos propios en móvil y web —HU-14.2/RF-23/#44,23/10/2026

Por petición del usuario se implementa HU-14.2 con commit/push autorizados al
terminar. Rama `feature/user-blocking` creada desde `feature/platform-moderation`,
base7fd9adf y árbol inicialmente limpio. El usuario confirma el alcance de
impedir nuevos avisos y avistamientos autenticados y ocultar contacto/foto entre
las cuentas bloqueadas, conservando el consentimiento almacenado por caso.
[ADR-130](decisiones/130-bloqueos-de-interacciones-entre-cuentas.md)
y [ficha](funcionalidades/bloqueos-usuarios.md) concretan reglas y límites.

El primer intento de commit terminó con `gpg: signing failed: Timeout`.
El usuario indica que completó Pinentry; se reanuda el commit/push con firma,
conservando `commit.gpgsign=true` en su configuración local. No se desactiva GPG.

Flutter ofrece bloqueo desde fichas/revisión privada autenticada y gestión desde
Perfil. Web incorpora `/cuentas-bloqueadas`, acceso desde Perfil y contexto de
Explorar; política global `account`, APIs con identidad/origen/cuerpo acotado.
Ambas implementan dominio/casos de uso, repositorios/fuentes y ViewModels por
funcionalidad, con composición en bootstrap/router/páginas. No hay directorio
de perfiles, chat ni acciones administrativas móviles. Un recurso propio o
reportero QR anónimo no ofrece autobloqueo/identidad inventada.

Plan034/fuentes115–118, migración y patch generados por los scripts versionados,
sin alterar SQL anterior. Relación privada con UUID propio, elección y versión;
sin grants directos y lista propia de20. Autor derivado del contenido autorizado,
sin IDs de cuenta ni perfiles privados en DTO. Desbloqueo posible tras retirar
el contenido. CAS/replay evita duplicados y órdenes antiguas; la elección inversa
no se revela ni se retira. Lock por pareja serializa elección y contribución.
Triggers en escrituras rechazan nuevos avisos/avistamientos afectados incluso
desde adaptadores servidor; errores distinguen bloqueo de sesión/respuesta incierta.
Plan036/fuente122 añade el contacto confirmado sin reescribir034:
`case_contact_visible` devuelve falso para lectores bloqueados en cualquiera
de los sentidos; RPC y guard restrictivo de avatar comparten esa comprobación.
El autor y terceros autorizados conservan sus permisos. Consentimiento/teléfono/
versión almacenados intactos. Desbloquear restaura solo el contacto aún consentido.
Una URL de foto ya firmada puede durar60s; no se recuperan datos ya descargados.
Móvil invalida la familia de consultas de contacto tras mutaciones, también ante
respuesta ambigua, para retirar nombres/teléfonos/fotos consultados previamente.

Recibos previos, historial, denuncias, cierre, fichas/lista/mapa/Guardados
y QR sin cuenta conservan permisos. La UI comunica el alcance
antes de confirmar. Skeleton/shimmer/toast, refresh conservado, reintento exacto
tras respuesta perdida y descarte de datos/respuestas al cambiar cuenta.
En móvil una confirmación antigua no se aplica a otro estado. En web un conflicto
también limpia datos privados por posible cambio de identidad.

Validación local:526 pruebas Flutter aprobadas; análisis sin incidencias y
formato correcto.28 regresiones móviles tras ajustar rechazo conocido y18 de
bloqueos/arquitectura tras revisar DTO/composición.77 pruebas web, typecheck,
build Nuxt y30 pruebas de servidor aprobados. Tras confirmar contacto/foto,
se repiten las526 pruebas Flutter completas y50 SQL completas, todas aprobadas.
23 pruebas de bloqueos/contactos/arquitectura verifican también la retirada del
teléfono ya consultado y su recuperación solo tras desbloquear. Cinco escenarios
SQL de bloqueos incluyen contacto/foto en ambos orígenes, permiso restrictivo de
Storage incluso ante política amplia, consentimiento intacto y terceros.
La suite incluye publicación RPC auténtica,
retención del borrador y contribuciones en ambas direcciones. Incluyen permisos,
replay/conflicto, paginación, recurso retirado, repetición de run_all/035 y QR anónimo.

QA Chrome del build: acceso global, entrada por Perfil, cancelación, resultado
ambiguo/replay con una sola escritura, recarga, refresh fallido conservado,
desbloqueo, normal/reducido y1440/390/320 con texto200%; sin overflow ni errores
CSP/hidratación. Se corrigió overflow de título/acciones de ConfirmationDialog
compartido con texto200%; acción final comprobada mediante scroll. Renders
móviles390×844 y320×350/texto2 revisados, confirmación y acciones alcanzables.
Capturas en apps/mobile/build/ui-preview/{user-blocks,web-user-blocks}; logs
hu142-* en build ignorado. Una expectativa inicial de QA confundía el puente
global de acceso con login directo y otra comprobaba el envío antes de su
respuesta; ajustadas al contrato y repetidas. Añadidas llaves a un `if` existente
en case_creation_effects_test para dejar análisis limpio, sin alterar su lógica.

Pendientes: aplicar034 después de033 y036 después de034, actualizar clientes/Nuxt y probar A/B/C
en Android/Supabase reales, incluida contención multiconexión y reinicio físico.
PGlite de una conexión y fixtures no certifican esos escenarios. Safari/Firefox
y aprobación visual del usuario pendientes. Sin despliegue, SQL remoto, roles,
nuevos secrets ni cierre de issue/épica. Documentación/backlog conservan la
instantánea remota y distinguen implementación local. Siguiente paso: activar
y validar034/036; después continuar HU-14.4 (apelaciones) según sus criterios.

## HU-14.4: apelaciones de moderación —23/10/2026

Implementada la apelación de decisiones sobre contenido propio con motivo,
estado y respuesta en Flutter/Nuxt. Perfil móvil e Inicio web enlazan a Mis
apelaciones; Denuncias web enlaza a Revisar apelaciones, con política global
reviewer y autorización SQL en cada operación. Se distingue propietario del
contenido, denunciante y autor autenticado del avistamiento. Evidencia anónima
no se atribuye a una cuenta. [Ficha](funcionalidades/apelaciones-moderacion.md).

Plan035/fuentes119–121 genera migración y patch035. Tablas privadas con RLS,
RPC de autoría/rol, accesos de revisión auditados y bloqueos/idempotencia por
comando/decisión. Una apelación y respuesta definitiva por decisión. Se conserva
la decisión original; responder no cambia visibilidad, que sigue en la operación
auditada existente. Sin ampliación de permisos públicos ni exposición de denuncia,
evidencia, coordenadas o paths. No depende de034/HU-14.2, que se trabaja aparte.

Recorridos reutilizan campos, toast, skeleton/shimmer y confirmación de salida
con borrador, incluido cerrar sesión en web. Conflicto mantiene el motivo y
permite repetir una consulta fallida; reintento ambiguo conserva UUID/contenido.
Cambio de cuenta, expiración, revocación y disposición ocultan datos y descartan
respuestas tardías. /moderacion pasa a pages/moderacion/index.vue para montar
su nueva ruta hermana correctamente. El router móvil permite /home/appeals
solo tras cuenta/onboarding; dos pruebas de integración verifican el acceso real.

TextField admite límite Unicode opcional, usado en apelaciones, y su contador
compartido queda en flujo dentro del contorno para no tapar texto ampliado.
Regresión de controles Chrome aprobada. Ajustado el selector antiguo de ese
harness a la navegación Reportar y añadidas llaves a una expectativa Flutter
existente que impedía análisis limpio; sin cambiar su comprobación.

Validación local:

- SQL PGlite/PostGIS:48/48, incluidos3 escenarios nuevos y repetición del bundle.
- Web:77/77 pruebas,30/30 de servidor de producción, typecheck y build aprobados.
- Flutter:formato/análisis sin incidencias, regresión524/524 con
  AMBIENT_BACKGROUND_MOTION=false; después18/18 focalizadas, incluidos8 escenarios
  de apelaciones (dos nuevos de router) y10 de arquitectura. El primer intento
  global se interrumpió por timeouts del fondo continuo, ya documentados en
  este proyecto; no se ocultaron fallos mediante omisión de pruebas.
- Chrome fixture:envío/validación/descarte y logout cancelados/reintento único,
  respuesta/consulta del autor/revocación, límite1000 Unicode, teclado,
  movimiento normal/reducido, CSP/hidratación,1920/1440/731/390/320/texto200%.
  Renders revisados en apps/mobile/build/ui-preview/appeals-web y appeals-mobile;
  también aprobado check-fields-browser sobre el campo compartido.

Trabajo aislado en feature/moderation-appeals, carpeta entreHuellas-appeals,
para conservar los cambios simultáneos de HU-14.2 en la carpeta original.
Commit/push autorizados por el usuario para esta entrega; sin merge ni despliegue.
Pendientes:aplicar035 en desarrollo remoto, demo con autores/revisor reales,
contención multiconexión hosted, Android instalado y otros navegadores.
El siguiente paso es activar035 siguiendo CONFIGURACION. No se cierra el issue
remoto#46 ni HU-14 por la implementación local.

## Guía operativa Android en la raíz —22/10/2026

Creada [INSTALACION_ANDROID.md](../INSTALACION_ANDROID.md) por petición del usuario:
preparación de herramientas, firma/respaldo, JSON y procedencia de valores,
cinco secrets paso a paso, integración a main, ejecución manual/reintentos,
descarga/instalación/actualización, compilación local y resolución de fallos.
README raíz incorpora acceso superior, apartado propio y enlace documental;
ficha de distribución enlaza la guía. Conservados cambios locales anteriores.
Sin código, workflows, credenciales ni publicación remota modificados en este
incremento. Validación documental de enlaces y correspondencia con scripts/YAML;
no se repiten builds/pruebas de aplicación por cambios exclusivamente documentales.
Pendientes reales conservados: firma definitiva, valores/secrets del usuario,
integración a main, Actions real e instalación con backend/dispositivo reales.

## Preparación de distribución Android —22/10/2026

Configurado `.github/workflows/flutter.yml` para validar cada push a main y,
si pasa, compilar APK universal con firma propia, comprobarlo con apksigner y
publicar prerelease `android-build-N` con APK/checksum. Número Android10000+N,
reintento idempotente y artifact14 días ante fallo de publicación. PR sin firma
ni publicación; ejecución manual solo publica desde main. Identificador Android
existente conservado; no cambia SQL, acceso, Firebase ni funcionalidades.

Gradle consume firma desde entorno o key.properties ignorado y rechaza release
sin configuración, sin fallback debug. Script PowerShell genera/exporta JKS
sin sobrescribir; validador Python reconstruye archivos ignorados y rechaza
secrets ausentes, configuración ajena, claves privilegiadas y placeholders.
[Ficha con los cinco secrets y pasos del usuario](funcionalidades/distribucion-android.md),
ejemplos e índice/README/guía actualizados. Sin subir credenciales ni ejecutar
acciones remotas, commits, push o merge.

Validación local: formato620 archivos, análisis sin incidencias,518 pruebas
Flutter y5 Python aprobadas. Actionlint1.7.12 aprobado (binario contrastado con
digest SHA-256 publicado). Sintaxis PowerShell y exportación Base64 comprobadas
con certificado desechable; exportación de prueba retirada para no confundirla
con la firma definitiva. Gradle compila la configuración Kotlin y rechaza la
release sin firma como se esperaba. Error inicial de loopback Java resuelto
para estas comprobaciones con WindowsSelectorProvider, sin cambiar el entorno
global ni las opciones versionadas del proyecto.

La primera suite reveló7 expectativas antiguas de3 archivos: shell anterior
en retorno de ficha, color/selector Opacity de transición y dos campos frente
a tres tras el celular privado. Corregidas solo las pruebas a la implementación
vigente; sin cambiar apariencia, movimiento ni omitir pruebas para publicar.

APK release universal compilado con JDK17 en2m28s (402 tareas) y firma v2
verificada por apksigner; certificado CN=Local Build Validation y configuración
ficticia. Artefacto renombrado a build/android-signing-validation/
app-validation-only.apk: no es una entrega conectada al backend ni firma final.
Primer intento con JBR21 y heap8 GB terminó por memoria nativa insuficiente;
el reintento con heap3 GB/2 workers pasó y esos límites quedan en CI mediante
GRADLE_OPTS. Generación de archivos temporales Kotlin excluida de Git.

El usuario debe generar/respaldar firma definitiva, completar JSON y colocar cinco secrets,
integrar cambios a main y ejecutar Actions real. Instalación y recorridos con
backend real/dispositivo pendientes; no se acredita MVP listo ni release remota.
Siguiente paso: activar los secrets siguiendo la ficha y verificar primer APK.

## Pines y detalles del selector web según móvil —21/10/2026

Por instrucción explícita, comparados ZoneMapPicker/CaseLocationFields y
SightingScreen con LocationMap. ADR-104 solo igualaba teselas/filtro: web aún
mostraba círculo negro, zoom14, alto300/radio24, créditos inferiores y controles
propios de Leaflet. [ADR-129](decisiones/129-paridad-visual-de-mapas-mobile-web.md)
registra la referencia móvil para los recorridos equivalentes.

LocationMap ahora usa location_on negro36 centrado, zoom12, alto280/radio22,
créditos arriba8 con objetivos48 y fuente ampliable. Eliminados controles+/− y
botón Usar centro del mapa; flechas y Enter/Espacio conservan selección por teclado.
Reportar pérdidas conserva radio0; avisos sighting/with_reporter y SightingMap
QR usan200m, relleno111111/34 de255 y borde2. Misma matriz de color solo sobre
teselas, punto privado sin cambios y toast/reintento existentes. Bloqueo de
interacción durante envío y ResizeObserver con limpieza al desmontar para
expansión/resize. Sin SQL, nuevos paquetes, despliegue ni modificación Flutter.

Validación:71 pruebas aprobadas, typecheck y build Nuxt correctos usando
.nuxt-map-parity-qa. QA Chrome del build para avistamiento QR, Reportar y carga
progresiva aprobada: pin36, altura/radio reales, círculo/color/borde, teclado,
selección, crédito, filtro pintado, GPS denegado, reintento de envío ambiguo,
cuatro tipos de reporte y recuperación de borrador. Responsive1440/731/390/320/1920
y texto200%, sin overflow ni errores CSP/hidratación. El script de carga tenía
un selector ambiguo por los dos accesos Reportar de Inicio; acotado a navegación
y repetido correctamente. Capturas revisadas en apps/mobile/build/ui-preview/
public-sightings/map-mobile-parity.png y evidencia responsive en web-recovery.

Límite: backend y teselas fixture; no confirma red/proveedor reales ni aprobación
visual del usuario. Próximo paso: contrastar Android/web con Positron real.
Explorar web mantiene lista; el mapa de resultados con pines de marca de móvil
todavía no existe en web. No afirmar paridad funcional global o historia cerrada.
Ficha de cartografía/índice y regla UI web actualizados; trabajo local previo conservado.

## Animación aprobada y documentada como patrón UI/UX —21/10/2026

El usuario confirma aprobación visual de la animación de Reportar y pide
documentarla para reutilización. Creada la [guía del patrón](patrones-ui-ux/expansion-desde-origen.md):
experiencia, usos, parámetros/fases de apertura y retorno, componentes
compartidos, ejemplos reales de ruta/editor local, accesibilidad, limpieza
y criterios de revisión. Enlazada desde reglas UI/UX general/web, DISENO_UI,
índice de funcionalidades, ficha de transiciones, ADR-128 y AGENTS.

Solo documentación; no se alteran código ni parámetros de la animación.
Verificados enlaces locales y coherencia con componentes/estilos existentes;
no se repiten build o pruebas de navegador por este cambio documental.
La validación técnica anterior conserva sus límites: Chrome con fixture;
Safari/Firefox/físico y cada integración futura requieren su revisión.
Sin nuevas HU/RF, cierre de historias, migración global ni despliegue.

## Botón móvil que se transforma dentro del fullscreen de Sader —21/10/2026

Por petición explícita, combinado el origen móvil con el motor web ya aprobado.
Se revisó OriginPageTransition Flutter: color/radio fuente, identidad centrada
con tamaño original y opacidad hasta45%, invertida al cerrar. [ADR-128](decisiones/128-identidad-mobile-en-origen-web-fullscreen.md)
registra la combinación: GSAP/CustomEase0.7s y fullscreen de Sader conservados;
superficie negra visible desde el comienzo, icono sin estiramiento y radio visual
que vuelve al círculo. Fade/blur de Sader solo sobre el cuerpo de destino.

Captura únicamente icono/etiqueta del control en memoria; sin clonar páginas ni
formularios. Identidad aria-hidden, compensación por eje de escala y retirada
al finalizar/cancelar; control original oculto temporalmente y restaurado.
Se corrigió interpolación de radio con unidades mixtas que dejaba esquinas:
radio calculado en coordenadas visuales como ClipRRect móvil. Marca, navegación,
ruta anterior detrás, guards, reducido y limpieza de cuenta conservados.

Validación:71 pruebas, typecheck y build correctos. QA Chrome del build aprobada
por nueve puntos y acceso de Inicio en1852/1255/390/320: icono conserva tamaño
en apertura/cierre (tolerancia0.6px), fuente termina45%, reaparece antes de
llegar al botón y termina circular; identidad temporal retirada y control
restaurado. Fullscreen, fade/blur del cuerpo, geometría, contenido sin salto,
reaperturas, reducido y aviso de viewport aprobados. Regresión de navegación
aprobada con editores locales, borrador cancelado, resize e identidad.
Dev5173 aprobado1255 y320/texto200% por ambos accesos. Revisadas capturas de
apertura5/15% y cierre95% en apps/mobile/build/ui-preview/web-origin-sader.
Documentación y reglas actualizadas; sin despliegue, SQL, permisos o ampliación
funcional. Pendientes confirmación visual del usuario y Safari/Firefox/físico.
Sin modificar Flutter/Perfil/Alertas ni afirmar paridad global.

## Expansión fullscreen y fases originales de PrettyModal —21/10/2026

El usuario aprueba la sección anterior detrás pero pide cubrir toda la pantalla
y copiar la transformación progresiva de Sader. Revisados pretty-modal.tsx,
SectionModal y globals.css: SectionModal usa pretty-modal-fullscreen; la entrada
combina Flip0.7s con opacity0/blur10px→1/0 en500ms y cubic-bezier(0.56,0.27,0,1).
[ADR-127](decisiones/127-origen-fullscreen-y-fases-prettymodal-sader.md) sustituye
el destino main y la entrada sin fade de ADR-126; no inventa una espera al50%.

La superficie real ahora ocupa100dvw/100dvh durante morph, sin max-width de
columna. Cuerpo situado en sus coordenadas finales, con espaciador vacío que
conserva altura/scroll; se restauran sin salto al terminar/cancelar. Eliminados
relleno negro y radio interpolados propios. Se copian apertura/cierre CSS de
PrettyModal; Vue integra el efecto con rutas/guards y DOM saliente retenido.
Marca/barra estables, colores propios, reducido, resize e identidad conservados.

Validación local Chrome: typecheck,71 pruebas y build correctos. QA del build
por ambos accesos en1852/1255/390/320: rect inicial, fade/blur original,
destino completo a los cuatro bordes, contenido escalado, sección anterior
detrás, ausencia de salto del título al restaurar, cierre, reaperturas y
reducido; duración real687–705ms. Regresión de navegación aprobada con marca,
editores locales, borrador cancelado, resize e identidad. Dev5173 aprobado
1255/390 por ambos accesos;320/texto200% comprueba además duración500ms y curva
CSS exacta. Capturas en apps/mobile/build/ui-preview/web-origin-sader revisadas.
Documentación y reglas actualizadas; sin SQL, permisos, despliegue ni cambio
de alcance funcional. Confirmación visual del usuario y Safari/Firefox/físico
pendientes; sin auditoría global ni modificación de Perfil/Alertas o Flutter.

## Contenido que crece dentro del origen y sección anterior detrás —21/10/2026

El usuario precisa el contrato: no retirar la sección actual al abrir y no
esperar a terminar para mostrar el formulario. [ADR-126](decisiones/126-contenido-dentro-de-expansion-y-ruta-anterior-visible.md)
sustituye la fase de cuerpo oculto de ADR-125. NuxtPage conserva el DOM real
saliente mediante leave de Vue, fijo en su posición, inert y aria-hidden;
la nueva ruta tiene fondo exterior transparente durante apertura. Flip escala
la superficie real con su título/campos/mapa visibles desde0%, recortados por
su mismo contorno y fondo opaco, sin transparentar la vista anterior a través
del formulario. Al terminar se retira la ruta anterior, sin otro reveal.
Sin clones ni otra instancia del formulario; acceso/guards/datos conservados.

Validación: typecheck,71 pruebas y build correctos. QA Chrome del build aprobada
en1852/1255/390/320 por nueve puntos y acceso de Inicio: rect inicial del botón,
contenido visible desde0%, título escalado, sección anterior retenida, fotogramas
0/2/5/10/15/45/99/100%, duración real687–706ms, cierre, reaperturas, aviso de
viewport y reducido. Regresión de navegación aprobada: marca, editor local,
borrador cancelado, resize real, reducido e identidad. Capturas revisadas en
apps/mobile/build/ui-preview/web-origin-sader; en45% se ve Reportar dentro de
la expansión y la sección anterior fuera del contorno. Dev5173 aprobado1255
por ambos accesos y320/texto200% también aprobado con fixture.
Documentación, reglas e índice actualizados; sin cambios de alcance funcional,
SQL, permisos ni despliegue. Confirmación visual del usuario y otros navegadores/
dispositivo físico pendientes; sin afirmación de auditoría global.

## Cancelación prematura al abrir una ruta desde origen —21/10/2026

El usuario sigue observando entrada instantánea y cierre animado. Se amplía
QA para medir duración y crecimiento sin pausar GSAP. Un aviso inducido de
visualViewport.resize durante entrada reproduce el salto: el listener llamaba
cancel/finish y mostraba el formulario a21ms, aunque no cambiase el tamaño.
Esto demuestra una causa posible del síntoma; no hay trazas del navegador
del usuario para atribuirle ese evento concreto.

OriginTransitionHost compara ahora tamaño de ventana, altura visual y escala:
avisos sin cambio real o de ancho visual por scrollbar no terminan Flip.
Resize real, teclado/zoom, movimiento reducido e identidad conservan limpieza.
La ruta mantiene su contrato de acceso y contenido oculto hasta finalizar;
sin convertir Reportar en modal ni cambiar tiempos/curva. ADR-125 y ficha
actualizados. Validación dev5173 en1255/390 con aviso inducido aprobada;
typecheck,71 pruebas y build correctos. Regresión de navegación del build
aprobada, incluido resize real, borrador cancelado y cambio de identidad.
QA del build aprobada desde ambos accesos en1852/1255/390/320: duración real
observada684–708ms, crecimiento, formulario oculto, aviso inducido, capturas
iniciales, retorno y reducido. En320 el acceso rectangular crece principalmente
en altura; se comprueba área, no duplicación del ancho. Confirmación visual del usuario y
Safari/Firefox/dispositivo físico pendientes; sin despliegue ni auditoría global.

## Forma del botón visible desde el primer fotograma —21/10/2026

Nueva observación del usuario: seguía sin percibirse el nacimiento desde el
botón. La validación anterior comprobaba geometría y contraste intermedio,
pero no detectaba que el keyframe de apertura ocultaba la superficie con
opacidad0 y blur10px. Se elimina ese fade/blur de entrada: opacidad1 y sin
desenfoque, según la variante shell de Sader. Se mantienen Flip, curva0.7s,
radio/color reales, disolución del relleno y cuerpo oculto hasta finalizar.
ADR-125 y ficha de transiciones actualizadas; sin cambio de alcance funcional.

Prueba ampliada con fotogramas0/2/5/10/15%, opacidad1, sin blur y relleno
visible, además de contenido oculto hasta99%. Capturas revisadas del círculo
de nueve puntos y del acceso rectangular. Dev5173 aprobado en1255/390;
build aprobado por ambos disparadores en1852/1255/390/320 con retorno,
reaperturas y movimiento reducido. Regresión de navegación aprobada, incluidos
borrador cancelado, resize e identidad. Typecheck,71 pruebas y build correctos.
Solo evidencia local en Chrome con fixture; pendiente confirmación visual del
usuario y Safari/Firefox/dispositivo físico. Sin despliegue ni auditoría global.

## Apertura de Reportar perceptible —21/10/2026

El usuario precisa que se refiere a la apertura de Reportar. Causa confirmada:
el cuerpo permanecía oculto y su superficie pintaba el mismo degradado del fondo,
por lo que GSAP movía geometría que no contrastaba. Ahora se captura únicamente
color/radio del control, junto a su rect, y el componente real nace con ese relleno.
Flip conserva curva/duración; el relleno se disuelve linealmente en la misma
timeline hasta transparencia para llegar al fondo real sin salto de color.
El formulario sigue oculto hasta completar apertura y no se clonan pantallas.

QA de origen añade contraste efectivo del relleno y opacidad durante apertura,
sin limitarse a matrices/rects. Sincroniza también el keyframe CSS con GSAP para
capturar el fotograma45%; revisado con superficie visible. Validación dev5173
con fixture por ambos accesos a1255/390; QA del build aprobada en1852/1255/390/320,
incluidos apertura/cierre, contraste, contenido oculto hasta100%, ausencia de
copias, reducido y reaperturas. Regresión de navegación aprobada (borrador,
resize, retorno e identidad).71 pruebas, typecheck y build correctos.
Sin despliegue; Safari/Firefox/físico pendientes, sin auditoría global.

## Motor de origen sustituido por código de Sader —21/10/2026

Por instrucción explícita reiterada, reemplazado el motor de navegación desde
origen: GSAP3.15.0 y código de PrettyModal (Flip.getState/from/to, scale:true,
CustomEase original,0.7s y sus keyframes). OriginPageSurface es el componente
vivo; su cuerpo permanece oculto hasta terminar. Eliminados clonado de Inicio,
hold/previous, superficie paralela y WAAPI manual. El cierre anima antes de
desmontar/cambiar ruta y permanece oculto hasta el commit, sin destello al
restaurar estilos. [ADR-125](decisiones/125-origen-web-reemplazado-por-sader-gsap-flip.md)
registra la excepción explícita a tiempos/fases de ADR-124 solo en este motor.
Perfil/Alertas y Flutter conservados. Los apartados siguientes describen el
historial de las aproximaciones retiradas, no el motor vigente.

QA Chrome en dev5173 y build con APIs/backend fixture: nueve puntos y acceso
negro de Inicio en1852/1255/390/320; rect inicial coincide con control real,
duración0.7s, cuerpo oculto incluso99%, visible al100%,0 copias/capas antiguas,
cierre con componente montado, reaperturas reales y reducido. Texto200% a320px
comprobado por ambos accesos. Capturas de0/45/99/100% y cierre revisadas en
apps/mobile/build/ui-preview/web-origin-sader. Typecheck,71/71 pruebas y build
aislado correctos. Regresión check-navigation-motion-browser.mjs aprobada:
barra/marca, retorno local/ruta, cancelación de borrador, resize, reducido e
identidad. check-dialog-motion-browser.mjs confirma Perfil/Alertas conservados,
incluidos foco, texto200%, resize/reducido/desmontaje y reproducción real.

Sin datos/sesión/backend reales, despliegue, cambios de SQL, operaciones o cierre
de historias. Siguiente paso: revisión del usuario en su pestaña y Safari/Firefox/
dispositivo físico. No acredita auditoría global de animaciones.

## Contenido crece desde el origen con FLIP real —21/10/2026

Nueva corrección tras captura e instrucción reiterada del usuario. Los ajustes
anteriores mantenían el cuerpo con escala .98→1 en su posición final: el recorte
por sí solo no cumplía el movimiento solicitado. OriginTransitionHost ahora
traslada y escala superficie y contenido vivo con la misma matriz, siguiendo
PrettyModal/ExpandIntactModal de sader-panel. Layout final medido una vez e
invertido al rect real; radios/icono compensados,320/260ms y fases conservados.
La fuente no se limita a nueve puntos: también el acceso negro Reportar de Inicio.
Al montar se eliminan capas huérfanas de versiones anteriores durante HMR.

QA Chrome ejecutado contra el servidor existente127.0.0.1:5173, con APIs
interceptadas hacia backend fixture (sin datos/cookies/operaciones de la cuenta
real). Ambos disparadores en1852/1440/390/320: primer fotograma coincide con su
rect, cuerpo y superficie tienen la misma escala en0/15/45/65/75/85%, no hay
formulario visible antes del movimiento ni contenido antes65%. Escala inicial
de nueve puntos a1852px:0.0345572 horizontal y0.0820513 vertical, en lugar de.98.
Dos fotogramas de preparación por caso,0 vacíos; tres reaperturas por caso,
retorno/reducido y limpieza correctos. Capturas first-frame/opening/content en
apps/mobile/build/ui-preview/web-origin-continuity, con prefijos nine/shortcut.
Typecheck y build aislados correctos,71/71 pruebas aprobadas. La misma QA de
ocho combinaciones pasa también contra el build de producción; regresión
check-navigation-motion-browser.mjs aprobada (retorno local/ruta, cancelación,
resize, movimiento reducido, cambio de cuenta y estabilidad de marca/barra).
Sin despliegue ni auditoría global; pendiente revisión del usuario en su pestaña
y Safari/Firefox/dispositivo físico.

## Expansión de Reportar sin accesos de Inicio superpuestos —21/10/2026

Corrección tras captura del usuario: la validación anterior comprobaba cobertura,
pero no descartaba mezcla de contenido anterior y destino. Se revisan PrettyModal
y ExpandIntactModal de sader-panel y se adapta su principio de superficie y
contenido recortados juntos, sin introducir React/GSAP ni cambiar320/260ms.
El formulario se recorta al rect animado; el host se vincula al shell del destino
real y sale de él al terminar. El controlador espera el montaje real hasta2s
(salida limpia ante fallo/cambio de ruta/actor) y retira la copia anterior por
referencia aunque su contenedor haya cambiado. Permisos y datos conservados.

Validación local: typecheck,71/71 pruebas y build aislado correctos. Chrome
check-origin-continuity-browser.mjs ampliado a1852/1440/390/320, apertura/fase
de contenido/cierre, límites geométricos del recorte y ausencia de accesos
clonados/hosts huérfanos; tres reaperturas por ancho y movimiento reducido.
Cobertura previa:2 fotogramas por ancho,0 vacíos. Capturas desktop/móvil revisadas
en apps/mobile/build/ui-preview/web-origin-continuity. Regresión
check-navigation-motion-browser.mjs correcta: retorno local/ruta, cancelación,
resize, cambio de cuenta, marca y fases. Backend fixture; sin despliegue ni
verificación Safari/Firefox/dispositivo físico. Siguiente paso: revisión del
usuario en su instancia; no constituye auditoría global de animaciones.

## Expansión web sin fotogramas vacíos —21/10/2026

Corregido el parpadeo del botón de nueve puntos al entrar en Reportar: la copia
decorativa saneada de la pantalla anterior se monta antes de navegar, fuera de
NuxtPage, y se transfiere al host cuando la expansión está lista. Cubre también
los dos requestAnimationFrame de preparación; no modifica320/260ms, curvas,
fases, origen/destino ni retorno. Limpieza al completar/cancelar, cambiar actor,
resize, preferencia reducida o desmontaje; copia inerte, sin persistencia nueva.

Validación local: typecheck,71/71 pruebas y build aislado .nuxt-origin-flicker
correctos. Chrome check-origin-continuity-browser.mjs registra2 fotogramas de
espera y0 descubiertos en cada ancho1440/390/320; capturas de apertura/cierre
revisadas, retorno y modo reducido correctos. check-navigation-motion-browser.mjs
pasa expansión/fases, retorno local/ruta, marca, navegación cancelada, resize,
modo reducido y cambio de cuenta. Evidencia con backend fixture en
apps/mobile/build/ui-preview/web-origin-continuity. Sin despliegue; siguiente
paso: revisión del usuario y Safari/Firefox/dispositivos físicos. No acredita
auditoría global de animaciones.

## Barra web estable al cambiar el scroll —21/10/2026

Corregido el salto horizontal de la navegación al aparecer/desaparecer el
scroll vertical por carga de contenido o bloqueo del scroll en paneles.
main.css reserva el canal mediante scrollbar-gutter:stable en html; conserva
la barra persistente, selección animada, dimensiones y reglas de acceso.

QA local reproducible: scripts/check-navigation-stability-browser.mjs, Chrome
con scrollbar clásica visible (sin --hide-scrollbars). Antes: salto7,5px;
después: variación0px en posición/tamaño a1440/390/320, con navegación,
lecturas demoradas, contenido largo y apertura/cierre de Perfil.71/71 pruebas,
typecheck y build aislado aprobados sin detener el dev server. Build conserva
avisos preexistentes de BigInt/target y deprecación de exports de Vue.
Sin despliegue. Siguiente paso: comprobar Safari/Firefox y dispositivos físicos.

## Regla global de animaciones y corrección Perfil/Alertas —21/10/2026

Por instrucción explícita del usuario, AGENTS y reglas UI/UX móvil/web exigen
que las animaciones equivalentes coincidan en efecto, origen/destino, sentido,
duración, curvas, fases y retorno. Solo se adapta geometría final al viewport;
divergencias necesitan instrucción expresa y registro. ADR-124, arquitectura,
guía, diseño y fichas actualizados. La regla es global; esta entrega verifica
Perfil/Alertas y no acredita auditoría de todas las animaciones existentes.

Se corrige la omisión previa de GlassDialog: apertura desde avatar/campana real
320ms y contracción al mismo control260ms. origin_motion_contract centraliza
duraciones/curvas/fases móviles; origin_dialog_motion aplica progresión Flutter
easeInOutCubic, fuente hasta45%, contenido desde65%/easeOutCubic y escala según
ancho. Perfil no fabrica icono de fuente; Alertas conserva solo SVG decorativo.
Contenido y diálogo permanecen hasta finalizar salida. Se conserva el panel
glass responsive; operaciones, sesión, permisos y backend sin cambios.

Interacción inerte durante expansión, Escape disponible, foco al control
después del cierre. Resize/preferencia/desmontaje cancelan animaciones y limpian
estilos temporales/nodos/inert/scroll. Apertura/cierre rápidos y respuestas
tardías no dejan overlays bloqueados ni contenido invisible.

Validación: typecheck/build aislado correctos y71/71 pruebas aprobadas,
incluida paridad automática contra las rutas/intervalos/curvas Dart. QA normal
check-dialog-motion-browser.mjs pasa tiempos y fotogramas reales de apertura/
contenido/cierre, origen exacto, foco/marca,1440/390/320/texto200%, resize,
preferencia reducida en vivo, cierre durante apertura, recarga/desmontaje y
reproducción a tiempo real. Capturas mobile de apertura/contenido/cierre
revisadas en apps/mobile/build/ui-preview/web-dialog-motion. Las capturas se
toman del viewport sin redimensionarlo para no interrumpir la animación.
Regresiones check-inbox-browser.mjs, check-home-browser.mjs y
check-navigation-motion-browser.mjs aprobadas con fixtures, sin errores CSP/
hidratación ni overflow. Diff-check limpio.

Sin cambios Flutter, datos, dependencias ni despliegue. Próximo paso: revisión
del usuario en desarrollo y comprobación en Safari/Firefox/dispositivos físicos.

## Cabecera Home completa: usuario, alertas y glass —21/10/2026

Corrección posterior solicitada por el usuario: cabecera de cuenta con campana,
avatar privado/iniciales y logout circular accesible. Avatar abre Tu cuenta con
nombre/correo/ciudad reales; sustituye el desplegable inferior anterior. Las
iniciales se conservan mientras llega la foto o si no existe. Proxy JPEG propio
valida cuenta/onboarding/actor, ruta del dueño y tamaño2MiB; no expone Storage,
URL firmada, teléfono o token. Edición/foto de perfil web no incluida.

Campana compuesta por slots de las cuatro páginas; no importa presentación
entre funcionalidades. NotificationBell/InboxViewModel/ReadInbox y
MarkNotificationRead consumen repositorios/DTO HTTP y servidor con InboxSource.
Lectura/páginas/mark usan RPC de plan027 y JWT de usuario, previa validación de
sesión/onboarding/X-Account-Actor por operación. POST exige origen y mantiene
protecciones globales. IDs bigint como cadenas; proyección sin owner/caso/contacto.
Skeleton/fallo/vacío distintos, refresh con shimmer, lectura confirmada tras
servidor, retry de lectura idempotente y página fallida. Cambio/expiración de
identidad y desmontaje descartan datos/respuestas tardías. Sin push/seguimiento/
preferencias web, enlaces ficticios a casos ni nuevas migraciones/Flutter.

GlassSurface unifica degradado neutro, blur22, ribete y sombra polished móvil
en tarjetas/controles; GlassDialog comparte panel, backdrop, cierre exterior/X/
Escape, foco y limpieza de scroll. Marca y navegación persistentes conservadas.

Validación final local: build aislado .nuxt-home-review, typecheck,70/70 pruebas
unitarias/arquitectura y29/29 de servidor aprobados. Nueva integración prueba
anónimo, otra cuenta/actor, Origin, onboarding, lectura idempotente, privacidad
del DTO, error frente a vacío y avatar autorizado/faltante. QA Chrome de
check-inbox-browser.mjs cubre1440/390/320/texto200%, cabecera, foto/iniciales,
perfil/Escape/scroll, glass, bandeja lazy/skeleton/errores/reintentos/páginas,
lectura persistida y aislamiento al cambiar cuenta. Capturas mobile/perfil/
bandeja revisadas en apps/mobile/build/ui-preview/web-inbox. Regresiones
check-home-browser.mjs, check-stagger-browser.mjs y check-access-browser.mjs
aprobadas con fixtures, sin errores CSP/hidratación ni overflow. Diff-check limpio.

Guía, arquitectura, reglas UI web e índice/fichas actualizados. Sin despliegue;
próximo paso: revisión del usuario y comprobación con backend real, Safari/
Firefox/dispositivos físicos. No se afirma recepción push ni integración remota.

## Inicio de platform con diseño de móvil —21/10/2026

Por petición del usuario, AccountScreen compone HomeContent de presentación
con el diseño vigente de Home móvil: título Poppins32/gris y remate azul600,
accesos negros, ilustración original3:2 y descripción en glass26, Cerca de ti
con tarjeta glass y enlace a Explorar. Escritorio en dos columnas; responsive
en secuencia móvil y apilado de accesos en ancho reducido. Poppins600 local
copiado del mismo recurso móvil con su licencia existente.

Cuenta real conservada en desplegable nativo accesible; gestión/retry dependen
del permiso existente. Reportar conserva expansión/retorno desde origen.
Explorar sustituye Mis reportes entre los accesos porque no hay listado propio
web implementado; no se crean rutas vacías ni se promete geolocalización móvil.
Sin cambios de dominio, datos, onboarding, política de acceso ni SQL/Flutter.

Validación: typecheck y64/64 pruebas aprobados; build correcto con directorio
aislado .nuxt-home-review, sin detener el dev server ni eludir su lock.
Chrome check-home-browser.mjs pasa1440/390/320/texto200%, imagen/fuente, cuenta
por teclado, tres destinos/retorno, ausencia del pie legal, redirect anónimo
y gestión por rol. Capturas desktop/mobile/text200 revisadas en
apps/mobile/build/ui-preview/web-home. Regresiones check-stagger-browser.mjs
y check-access-browser.mjs aprobadas: entrada real, permisos pendientes,
movimiento reducido, QR sin JS, acceso/onboarding, retry, roles y logout.
Diff-check sin errores. Documentadas reglas web y fichas de Inicio/acceso/
navegación. Sin despliegue; próximo paso: revisión del usuario y backend real,
Safari/Firefox/dispositivos físicos. Sustituye el build pendiente del ajuste
anterior de cabeceras/pie de cuenta; los cambios anteriores se mantienen.

## Cabeceras y pie de cuenta simplificados —21/10/2026

Por petición explícita, retiradas las frases decorativas sobre títulos en
Inicio («Más caminos de vuelta a casa»), Explorar/Mis mascotas/Reportar
(«Cada huella cuenta»), Moderación y tarjeta de gestión. Eliminado el pie de
Términos/Privacidad de AccountScreen, compartido por las secciones autenticadas.
El espacio inferior pasa al contenido para conservar acceso sobre la barra
flotante. Enlaces legales públicos/login/registro y etiquetas de tipo/estado
se conservan. Sin cambios de dominio, datos, sesión ni permisos.

Validación local: typecheck y64/64 pruebas aprobados. Build intentado pero
rechazado por el lock del servidor Nuxt de desarrollo activo en127.0.0.1:5173;
se conserva ese proceso. Revisión visual responsive y build pendientes.
Reglas web y fichas de navegación/acceso/moderación/legales actualizadas.
Sin despliegue. Siguiente paso: revisión visual del usuario y build cuando
el servidor de desarrollo no esté utilizando el directorio de Nuxt.

## Reportar con carga por componente —21/10/2026

Por autorización del usuario, Reportar ya no oculta el formulario completo hasta
recibir mascotas/búsquedas. Tras la política de acceso, monta campos y mapa e
inicia en paralelo lecturas remotas y borrador local. La restauración local
deshabilita brevemente la edición para no sobrescribirla; las consultas remotas
solo afectan sus selectores, con FieldSkeleton compartido. RecoveryViewModel
entrega cada resultado al llegar y mantiene readiness/fallo/petición por fuente.
Fallo no equivale a vacío; retry específico, deduplicado, conserva lo escrito.

Publicar espera solo la lista pertinente al tipo de reporte, con validación y
autorización existentes. Guardar borrador antes de recibir metadata conserva
las referencias, versión y fotos restauradas. Respuestas tardías se descartan
al desmontar o confirmar publicación; reintento ambiguo conserva su payload.
Explorar/Mis mascotas, política global, sesión preparada y animación conservados.

Validación: typecheck/build y64/64 pruebas correctos. QA Chrome con fixtures pasa
check-report-loading-browser.mjs: mascotas/búsquedas/módulo Leaflet retenidos,
inputs utilizables, selectores/mapa independientes, error/retry de una sola
fuente, borrador editado/guardado antes de recibir listas con IDs/version/fotos
íntegros y390/320 sin overflow/CSP/hidratación. Captura revisada en
apps/mobile/build/ui-preview/web-report-loading/fields-before-data.png.
Regresión check-recovery-browser.mjs confirma crear/editar/foto, filtros, cuatro
tipos de reporte, borrador y retry ambiguo, incluido texto200%. Diff-check correcto.

ADR-123, arquitectura, reglas, guía y ficha actualizadas. Sin caché, SQL,
endpoints, permisos, Flutter ni despliegue nuevos. No se ha medido la latencia
real del backend; la validación de acceso aún puede esperar su respuesta.
Siguiente paso: revisión del usuario y validación remota/Safari/Firefox/físicos.

## Etiqueta y borde de inputs/textarea —21/10/2026

Corregido TextField compartido a partir de las capturas del usuario: la etiqueta
ya no pinta un rectángulo opaco sobre el degradado. Un fieldset/legend decorativo
con aria-hidden recorta la muesca real del borde; el label/for permanece visible
y transparente. Campo vacío sin foco mantiene el contorno cerrado; al enfocar
o conservar texto tras blur abre la muesca. Foco/error tienen un único trazo;
retirado el ribete/fondo de hover heredado. Etiquetas largas reservan sus líneas
adicionales y no se superponen al valor con texto200%; base48px conservada.

Validación local: build, typecheck,62/62 pruebas y diff-check correctos.
Chrome QA de TextField pasa input/textarea vacíos, hover, foco, texto/blur,
invalid,390/320/texto200% y etiqueta larga sin superposición. Capturas revisadas
en apps/mobile/build/ui-preview/web-text-field. También pasaron QA de controles,
avistamientos QR y moderación; después del ajuste final de espacio/rem se
repitieron TextField y QR. Sin errores de página/CSP/hidratación ni overflow
horizontal en estos escenarios. ADR-122/ficha/desarrollo actualizados.

Sin cambios de dominio, datos, permisos o Flutter ni despliegue. Siguiente paso:
revisión del usuario; Safari/Firefox y dispositivos físicos siguen pendientes.

## Tema celeste en los controles adaptados de Sader —21/10/2026

Por petición del usuario, fields.css sustituye colores neutros fijos por roles
CSS compartidos: superficies celestes suaves, selección #D6E8FF/texto #244C75,
hover #E5F2FA, foco #2C87CE, loader #2887EF y error #B53F48. Aplica a inputs,
selectores, paneles, calendario/hora y línea superior; conserva las dimensiones,
animaciones y comportamiento anteriores. Sin selector de temas, cambios de
dominio/datos, otras pieles ni Flutter. Refinamiento documentado en ADR-122.

Validación: build correcto; check-fields-browser.mjs pasa con backend fixture,
comprobando colores reales de selección/calendario/hora/foco/loader, morph,
teclado, búsqueda, movimiento reducido,1920/1440/731/390/320 y texto200%, sin
errores CSP/hidratación ni overflow horizontal. Capturas revisadas en web-fields.
Contrastes calculados de pares locales: selección7.12:1, texto secundario5.44:1,
hover4.81:1 y foco3.64:1; no equivalen a una auditoría global. Diff-check correcto.
Pendiente: revisión del usuario y Safari/Firefox/dispositivos físicos; sin despliegue.

## Línea superior que seguía cargando —21/10/2026

Corregido el ciclo de vida del loader reportado por el usuario. NuxtPage recibía
una función inline nueva en cada render de app.vue; Nuxt observa esa identidad
y podía emitir page:loading:start al actualizar cabecera/navegación sin otra
carga pendiente. pageKey ahora conserva una referencia estable. TopLoadingBar
deja de iniciar una segunda vez desde beforeEach y termina también al confirmar
la ruta y en page:finish, además del cierre normal/error. No modifica el diseño
de la línea, política de acceso ni preparación de sesión.

Validación local: build, typecheck y62/62 pruebas correctos. Nueva regresión
check-top-loading-browser.mjs pasa Chrome con fixture: login/montaje de barra,
recarga autenticada, cambios de sección, consulta de acceso retenida (loader
visible durante trabajo real), query/hash/ruta duplicada, guard abortado,
redirección por sesión y legales. Tras cada escenario la línea queda oculta,
sin errores de página. Sin despliegue ni comprobación Safari/Firefox.

Siguiente paso: comprobar el recorrido original del usuario en su navegador.

## Controles web compartidos desde sader-panel —21/10/2026

Por petición explícita, adaptados FieldSelect, inputs con etiqueta flotante/inset,
calendario y selector horario como componentes reutilizables de apps/platform.
MorphPanel comparte expansión centrada desde el control, radio32px,
apertura420ms/cierre300ms, curva power3.out y blur12px. Piel local Inter y
medidas/colores/iconos de la referencia; crecimiento natural con texto ampliado.
Sustituidos controles en filtros, mascotas, reportes, avistamientos y motivo de
moderación. Retirados estilos antiguos que contaminaban campos y buscador.
TopLoadingBar reproduce el segmento40%/670ms en línea4px superior durante
navegación real, incluida espera de política de acceso, con cierre por éxito,
cancelación/error y pulso sin desplazamiento en movimiento reducido.
Excepción explícita a ADR-027 solo para esta línea de navegación web.

Validación final local: typecheck correcto;62/62 pruebas; build correcto con
NUXT_BUILD_DIR=.nuxt-fields-validation, conservando el servidor dev existente;
git diff --check sin errores. Chrome QA de fields/recovery/sightings/moderación
correcto con fixtures: frames de morph/blur, búsqueda sin tildes, teclado/foco,
loader durante consulta de sesión retenida, fecha/hora local hasta23:59,
1920/1440/731/390/320 y texto200%/movimiento reducido. Formularios confirman
persistencia/reintentos de los cuatro tipos de reporte, mascota/foto/borrador,
avistamiento anónimo/EXIF y decisiones autorizadas. Sin fallos de hidratación,
CSP ni overflow horizontal en los escenarios comprobados. Capturas revisadas en
apps/mobile/build/ui-preview/web-fields, web-recovery, public-sightings y moderation-web.

ADR-122, reglas de arquitectura/UI, guía y fichas actualizadas. Sin cambios
de dominio/data/SQL, permisos, Flutter, backend remoto ni despliegue. No cierra
historias ni acredita equivalencia píxel a píxel en todos los navegadores.
Siguiente paso: revisión del usuario y validación Safari/Firefox/dispositivos
físicos; integración remota de los recorridos sigue pendiente según sus fichas.

## Navegación web sin esperas repetidas —20/10/2026

Por petición del usuario, corregida la pausa al cambiar secciones. AccountScreen
ya no emite un cambio de identidad en cada montaje, que invalidaba la caché de
su propia pestaña. Bootstrap reutiliza la proyección vigente de15s para iniciar
ViewModel/repositorio ligados al actor después de hidratar, sin skeleton ni
segunda lectura de sesión tras la política global. La hidratación inicial
conserva el estado SSR; vencimiento, foco, avisos y cambios de cuenta mantienen
invalidación. Gestión se consulta solo en Inicio. No se cachean permisos ni se
elimina autorización por operación.

NavigationLink prepara código/sesión por intención; la barra prepara código de
sus destinos. Ruta exacta activa no repite consultas. StaggerReveal general usa
240ms/35ms, máximo140ms de retraso, sin blur ni entrada superpuesta a la expansión
desde origen. Onboarding/login conservan parámetros propios. Identidad/perfil
y requisitos de Reportar se leen en paralelo sin exponer resultados antes de
validación. ADR-121, arquitectura, reglas, guía y tres fichas actualizadas.

Comparación local de builds anterior/posterior en Chrome con backend fixture y
250ms añadidos a cada lectura de sesión: seis cambios provocaban seis consultas
extra; ahora cero dentro del plazo vigente. Mediana clic→encabezado visible de
339,5ms a51ms (aproximadamente85% menos); primera navegación posterior156ms,
restantes40–69ms. Estas cifras incluyen automatización y no acreditan producción
ni latencia real de Supabase. Evidencia JSON/captura revisada en
apps/mobile/build/ui-preview/web-navigation-performance; script reproducible
apps/platform/scripts/check-navigation-performance-browser.mjs. La comparación
usa encabezados, no los tiempos de contenido del registro anterior.

Validación local: build Nuxt/typecheck,62/62 pruebas unitarias/arquitectura y
28/28 de servidor aprobadas. QA Chrome de rendimiento comprueba TTL real15s,
invalidación, recarga/hidratación y ausencia de errores; regresión de acceso,
onboarding/reintento, roles, logout entre pestañas y recuperación completa con
mascotas/fotos/cuatro reportes aprobada. Stagger comprueba fotogramas reales,
retrasos35ms, texto200%, movimiento reducido y QR sin JS. Renders1440/390/320
y otros anchos en scripts existentes, sin overflow/CSP/hidratación.

Sin SQL, despliegue ni acciones GitHub. Siguiente paso: revisión del usuario en
su navegador y medición en producción/dispositivos físicos cuando se autorice
publicar. La latencia de las operaciones y la revalidación tras vencer15s siguen
dependiendo de la red; no se promete navegación instantánea en toda condición.

## Barra web sin elevación al hover —20/10/2026

Por corrección explícita con captura, retirado translateY(-2px) del acento en
UserNavigation, también en foco/presión. Conserva brillo, tamaño compacto,
selección deslizante y arrastre con retorno. Reglas y fichas actualizadas.
Validación: typecheck/build y QA Chrome con backend fixture correctos, incluida
igualdad de posición vertical antes/durante hover de la opción seleccionada;
regresión de navegación, arrastre y movimiento reducido aprobada. Sin despliegue.
Siguiente paso: revisión del gesto en dispositivo físico.

## Retirado el impulso al hover de la barra web —20/10/2026

Por corrección del usuario, eliminado previewPush y su animación horizontal al
pasar el puntero. Se conserva el ancho compacto304px, el arrastre con retorno y
el deslizamiento al seleccionar sección. Reglas y fichas actualizadas.
Validación: typecheck/build y QA Chrome con backend fixture correctos; hover sin
impulso, arrastre con retorno, navegación y movimiento reducido comprobados.
Sin despliegue. Siguiente paso: revisión táctil en dispositivo físico.

## Barra web compacta y retorno elástico —20/10/2026

Por petición explícita, UserNavigation limita el conjunto a304px (antes480px).
Las tres opciones miden aproximadamente71×52px, más redondeadas; se conservan
glass, iconos, selección azul y Reportar. Hover impulsa el acento hasta6px y
vuelve en480ms. Arrastre horizontal lo desplaza hasta8px y al soltar retorna;
un arrastre no activa enlaces. Movimiento reducido elimina el desplazamiento
extra; cambio de ruta, cancelación y desmontaje limpian el gesto/animación.

Validación: typecheck/build correctos,59/59 pruebas, git diff --check y QA Chrome
con backend fixture aprobados. Renders1920/1440/731/390/320, áreas táctiles≥48px,
impulso/retorno, arrastre sin navegar, movimiento reducido y regresión de
transiciones, sin errores CSP/hidratación. Captura390 revisada visualmente;
evidencia en apps/mobile/build/ui-preview/web-navigation-motion/compact-*.png.
Sin despliegue. Siguiente paso: revisar sensación del gesto en dispositivo físico
y publicar cuando se autorice; la evidencia local no confirma integración remota.

## Cierre de Reportar web —20/10/2026

El recorrido abierto desde los nueve puntos incorpora X circular glass sticky,
mediante GlassNavigationButton compartido. Vuelve a la sección de cuenta de
origen; sin origen de cuenta, a Inicio. Mantiene el guard de cambios sin guardar,
el bloqueo durante operaciones y la transición de retorno existente.
Validación: typecheck correcto,12/12 pruebas de recuperación/arquitectura y
git diff --check correctos. Pendiente QA visual/interacción en navegador;
sin publicación. Siguiente paso: revisar cierre limpio, cancelar/confirmar
salida con cambios y entrada directa en navegador.

## Barra web sin tooltip —20/10/2026

Por petición explícita, retirado title de Inicio, Explorar, Mis mascotas y
Reportar en UserNavigation. Se conservan aria-label, foco y efectos existentes.
Regla web y fichas de navegación/transiciones actualizadas.
Validación: npm run typecheck y git diff --check correctos. Sin despliegue;
pendiente comprobación visual del hover en navegador y publicación autorizada.
Siguiente paso: comprobar la barra en la web al actualizar la versión.

## Segunda revisión SEO sin cambiar el hero aprobado —20/10/2026

Comprobación HTTPS de producción:200 con título antiguo, sin JSON-LD ni tarjeta
summary_large_image. Las mejoras locales previas aún no están publicadas.
La extensión.app no garantiza mejor ranking; dominio propio recomendado por
claridad de marca, con migración permanente documentada para cuando esté activo.

Nuevo incremento: variantes WebP320/640 para hero por viewport/densidad, con fuente
completa y PNG de respaldo conservados. No cambia texto, CSS o composición de
ADR-120. Variante social JPEG1200×630 de la ilustración pública aprobada,89.933
bytes frente a3.628.600 anteriores, con Open Graph/JSON-LD coherentes. Generación
reproducible en el script existente; sin dependencias, SQL ni endpoints nuevos.

Validación: build/typecheck correctos,59/59 pruebas unitarias/arquitectura y28/28
de servidor aprobadas. QA Chrome1440/731/390/320, texto200 %, sin JS, animaciones,
FAQ/teclado/anclas, CSP/hidratación y QR aprobado. A1440px DPR1/2/3 el navegador
elige320/640/completo; fuente Arial, tamaño100.8px y color #171918 conservados.
Peso conjunto de hero:186.122/702.904/2.604.418 bytes según densidad. DPR1 reduce
92,9 % respecto a WebP completos; no implica igual reducción de toda la página.
Capturas en ui-preview/landing-vue y logs platform-seo-next-* en apps/mobile/build.

Pendiente: despliegue autorizado, propiedad/Search Console/sitemap, indexación y
Core Web Vitals reales. No se afirman puntuaciones Lighthouse, posiciones o
tráfico sin medir. Siguiente paso: publicar y comprobar la portada real antes
de migrar dominio. Se mantiene el trabajo local anterior y no se realiza push.

## Título original de landing restaurado —20/10/2026

Por petición explícita con dos capturas, recuperados del padre de1fc1bd1 los
valores originales del hero: Arial500/#171918, line-height1.02, tracking−0.055em,
clamp42px/7vw/108px y móvil32–48px, junto con mascotas laterales62–148px y offsets
previos. La reducción provenía de la unificación de títulos ADR-111; no de una
necesidad de SEO. La afirmación anterior de conservación de tipografía en el
relevo de SEO era incorrecta: las capturas de aquel QA ya mostraban el hero reducido.

typography.css excluye solo #hero-title; los demás h1 conservan Poppins. ADR-120,
AGENTS, normas, diseño, arquitectura, guía y ficha/índice registran la excepción
explícita. Metadatos SEO, imágenes WebP y demás cambios locales conservados.

Validación: build Nuxt correcto,59/59 pruebas unitarias/arquitectura aprobadas;
QA Chrome de landing1440/731/390/320, texto200 %, animaciones/movimiento reducido,
SSR/FAQ sin JS y navegación QR aprobado, sin overflow ni errores CSP/hidratación.
Captura desktop-top revisada: vuelve el título grande oscuro de la referencia.
Logs platform-hero-* en apps/mobile/build; capturas en ui-preview/landing-vue.
Sin despliegue. Siguiente paso: revisión visual del usuario antes de publicar.

## SEO de landing y futura migración de dominio —20/10/2026

Revisión de producción por HTTPS: portada200, HTML SSR con título/description/
canonical, robots200 y sitemap200 del dominio entrehuellas.kormind.com.
Faltaban imagen social, og:url/identidad estructurada y configuración unificada
del dominio; las doce ilustraciones PNG originales sumaban27.134.705 bytes.
No se consultó Search Console ni se midieron rankings/Core Web Vitals reales.

Implementación local: título/descripción orientados a mascotas perdidas/encontradas,
apoyo del hero explícito, Open Graph/Twitter con ilustración pública existente y
JSON-LD WebSite/Organization/WebPage bajo nonce CSP. NUXT_PUBLIC_SITE_URL centraliza
canonical/social/JSON-LD/robots/sitemap y admite cambio en runtime; HTTPS validado
sin depender de Host, cabeceras reenviadas o campañas. El dominio actual permanece
predeterminado. Sitemap solo incluye portada; QR/cuenta/legales conservan noindex,
autorización y proyecciones. Sin datos privados ni disponibilidad/valoraciones falsas.

WebP sin pérdida y picture con respaldo PNG reducen las doce ilustraciones a
15.165.652 bytes (−44,1 %). Script reproducible verifica alfa y todos los RGB
visibles; conserva PNG, dimensiones y lazy loading. Picture usa display:contents
para conservar las ventanas aprobadas; revisión de capturas confirma encuadre.

Validación final local: build Nuxt, typecheck,59/59 pruebas unitarias/arquitectura
y28/28 de servidor aprobadas. Pruebas comprueban JSON-LD/nonce/imagen, URL canonical
sin campañas, cambio a entrehuellas.app en runtime sin residuos del dominio anterior,
Host ajeno ignorado y noindex privado conservado. QA Chrome pasa1440/731/390/320,
texto200 %, movimiento reducido/animaciones, FAQ/teclado/anclas, navegación QR y
SSR sin JS; WebP realmente seleccionado, sin overflow ni errores CSP/hidratación.
Capturas revisadas en apps/mobile/build/ui-preview/landing-vue; logs platform-seo-*
en apps/mobile/build. No acredita rendimiento de usuarios reales ni indexación.

Ficha landing/índice, guía, desarrollo y ejemplo de entorno actualizados con
activación y pasos DNS/HTTPS, redirecciones permanentes, OAuth/orígenes/cookies
y Search Console para la futura migración. Cambios previos de navegación conservados.
Sin SQL, compras, push, despliegue ni acciones remotas de configuración.
Siguiente paso: publicar este incremento autorizado en una tarea de despliegue,
verificar HTML/robots/sitemap reales y registrar la propiedad en Search Console.

## Barra solo con iconos y animaciones móviles reutilizadas en web —20/10/2026

Corregida la adaptación por petición del usuario: desaparecen las etiquetas
visibles también en escritorio, conservando aria-label/title/foco. La barra vive
fuera de NuxtPage y conserva instancia/posición entre las cuatro rutas de cuenta;
se habilita tras confirmar sesión/bienvenida. El indicador azul único se desliza
320ms con la curva móvil; los iconos interpolan gris/blanco según su posición.
Hover/foco/presión elevan el acento2px/200ms. Glass/ribete/sombra refinados según
GlassSurface y NavigationAccentSurface; Reportar sigue negro con nueve puntos.

Nuevo controlador origin_transition y OriginTransitionHost/OriginActionButton,
compuestos por plugin navigation_motion. NavigationLink opta con origin. Se
aplican a Reportar, Registrar/Editar mascota y revisión autorizada desde Inicio;
retorno de ruta y cierre local invierten el efecto. Entrada320ms/retorno260ms,
origen hasta45% y contenido desde65%, según OriginPageTransition móvil. Marca y
barra permanecen fuera. Entrada directa/recarga no simulan un origen; los guards
de autorización y cambios pendientes siguen siendo los existentes.

La transición espera el montaje de Nuxt y opera dentro de su shell. Mantiene
una copia visual anterior transitoria/inerta, sin campos de formulario, scripts,
IDs, diálogos o avisos; se libera al completar/cancelar y no se guarda en el
registro de retorno, SSR o almacenamiento. Cambio de identidad cancela y limpia;
resize/orientación/movimiento reducido/desmontaje liberan máscara, inert,
animaciones y frames. CSS/WAAPI/CSSOM conservan la CSP estricta, sin unsafe-inline.

Validación local: build y typecheck correctos,58/58 pruebas unitarias/arquitectura
y27/27 de servidor. QA Chrome nuevo comprueba fotogramas del indicador y expansión,
contenido tardío, continuidad real del nodo de barra, retorno de ruta/local,
cabecera estable, descarte cancelado, resize, movimiento reducido y cierre de
sesión a mitad de efecto sin datos anteriores visibles. Capturas revisadas en
apps/mobile/build/ui-preview/web-navigation-motion; sin errores CSP/hidratación.
Regresión Chrome de recuperación y acceso, con backend fixture y renders
1440/390/320/texto200%, documentada en sus scripts. No acredita pruebas remotas.

ADR-119, ficha transiciones-web/índice, navegación web, reglas visuales, diseño,
arquitectura, guía y desarrollo actualizados. Sin SQL/backend/Flutter ni nuevas
dependencias. El dev server existente se conservó y producción se verificó con
NUXT_BUILD_DIR aislado; logs web-motion-build/tests/server-tests en apps/mobile/build.
Pendiente revisión del usuario y gestos/foco en navegadores físicos. No se ha
desplegado ni realizado acciones GitHub. Siguiente paso: revisar estos efectos
en el recorrido real antes de publicar.

## Diagnóstico de acceso denegado en producción —20/10/2026

Comprobado en https://entrehuellas.kormind.com: POST vacío a /api/access/login,
sin credenciales/cookies, devuelve403 invalid_request con Origin del sitio HTTPS,
pero422 invalid con Origin http://127.0.0.1:5173. Confirma que producción acepta
el origen de desarrollo; el middleware rechaza antes de autenticar en Supabase.
No es una denegación por rol ni evidencia de contraseña incorrecta. También se
rechazan HTTPS con barra final y HTTP del dominio. Sin cuentas reales ni cambios
remotos realizados.

Corrección operativa pendiente: configurar PUBLIC_WEB_ORIGIN exactamente como
https://entrehuellas.kormind.com en el entorno de ejecución de producción y
reiniciar/recrear el contenedor para que el proceso reciba el nuevo valor.
Desarrollo conserva http://127.0.0.1:5173. No se relaja CSRF, cookies o permisos.
Tras aplicar, repetir petición vacía: origen HTTPS debe producir422 invalid y
localhost403 invalid_request; después verificar acceso real. No requiere SQL
ni cambio de código. No se ha confirmado aún la corrección remota.

## Navegación de cuenta y recuperación web —20/10/2026

Implementado el alcance confirmado por el usuario: barra estilo móvil con
Inicio/Explorar/Mis mascotas y Reportar independiente. Cápsula glass flotante,
selección azul, nueve puntos, etiquetas en escritorio/semántica móvil, foco,
tooltip y área segura. La marca permanece en la cabecera. Se reserva scroll
final para acceder a contenido/legales por encima de la barra.

Nuevas rutas account de la política única SSR/cliente. Explorar consulta RPC
existente con filtros tipo/especie/estado y cursor. Mis mascotas consulta registros
propios, permite alta/edición con validación y añadir foto mediante Edge existente.
Reportar publica pérdida propia, posible pérdida, avistamiento y custodia: selección
de mascota o búsqueda real, fecha/hora, referencia privada, LocationMap y fotos
verificadas. Los envíos ambiguos conservan UUID/datos y reintentan sin duplicar;
foto de mascota pendiente también conserva ID/bytes para reintento.

Guardar borrador es local/explícito en IndexedDB por cuenta, con fotos y UUID,
restaurable hasta siete días y eliminación tras confirmación cuando el navegador
lo permite. No publica ni sincroniza automáticamente. Toast superior, invalid/
shake, skeleton inicial y shimmer conservando contenido durante refresh. Salida
con cambios sin guardar se confirma. Botones apilados en móvil/texto ampliado.

AccountScreen expone slot; las páginas componen recovery sin imports entre
presentaciones. RecoveryViewModel consume casos de uso/contratos propios; HTTP,
IndexedDB y fuentes RPC/Edge/Storage en data; composición plugin/Nitro. APIs
revalidan cuenta/onboarding, actor esperado y origen; publicable/JWT de usuario
solo en servidor. Fotos recodificadas sin EXIF y proxy con sesión/proyección
permitida. No se envían rutas Storage, token, referencia exacta o teléfono en
tarjetas públicas. Consultas Explorar limitadas como lecturas, sin consumir el
cupo de publicaciones. SQL/RLS/Edge existentes conservados; sin migración nueva.

Validación final local: typecheck y build Nuxt correctos;58/58 pruebas de
dominio/arquitectura y27/27 de servidor aprobadas. Chrome sobre build de producción
con backend fixture: cuatro entradas, filtros, mascota alta/edición/foto, cuatro
tipos de reporte, restauración de borrador y reintento ambiguo sin duplicados.
Regresión de acceso Chrome completa aprobada: onboarding, roles/revocación,
reintentos, logout entre pestañas, expiración y OAuth simulado. Renders revisados
1440/390/320 y texto200%, sin overflow ni errores CSP/hidratación. Logs
web-recovery-build/tests/server-tests en apps/mobile/build y capturas en
apps/mobile/build/ui-preview/web-recovery. No equivale a validar RLS remota.

ADR-118, ficha navegacion-web/índice, acceso-web, arquitectura/diseño/regla web,
guía y desarrollo actualizados. Límite actual: Explorar en lista, hasta100 mascotas
activas propias, alta/edición/adición de fotos; sin mapa de resultados, ficha web
autenticada completa, archivo/baja/gestión de galería ni paridad global móvil.
Pendiente integración Supabase/Edge con dos cuentas reales y revisión en
dispositivos físicos. No se publicó web/SQL ni se realizaron acciones GitHub;
trabajo móvil concurrente del selector telefónico conservado. Siguiente paso:
comprobar estos recorridos con la configuración y datos reales antes de publicar.

## Selector de país con bandera para teléfonos —20/10/2026

Implementado InternationalPhoneField compartido en Perfil y Contacto del
reportante: bandera vectorial/prefijo seleccionable y entrada del número nacional.
Panel blanco con tirador, sin X, búsqueda local en español por nombre sin tildes,
ISO o prefijo; cierre por toque fuera/Atrás/arrastre. Perú/+51 inicialmente en
campos vacíos; elegir país sin número no crea un valor. En ancho pequeño/texto2
se apilan selector y número. Scroll integral del panel con teclado/área segura y
movimiento reducido. Nombre y prefijo accesibles; objetivos del selector48px.

country_picker2.0.28 aporta catálogo/localización y circle_flags5.0.1 los SVG
locales, dibujados mediante flutter_svg existente. Se evita depender de emojis
o del loader propio de banderas, que no completaba su precarga en pruebas.
Versiones fijadas y lock actualizado; sin red, permisos de dispositivo o GPS/IP.
No se guardan países ISO separados ni se deduce un país de un prefijo ambiguo:
globo/prefijo hasta elegir; una elección explícita compatible se conserva en
el formulario. Valores con prefijo desconocido se mantienen completos.

Controller externo/VM/dominio/SQL conservan el contrato internacional. Pegado de
número completo no duplica prefijo, cambio de país conserva parte nacional,
ceros iniciales conservados y vacío sigue vacío. Campos existentes no se
reescriben al montar/cancelar/recargar. Disabled/busy bloquean controles; listeners,
controller interno y foco se liberan. Conserva validación + y8–15 dígitos, toast
superior/ShakeField, privacidad y consentimiento independiente por caso/foto.
No añade patch: siguen pendientes los anteriores031/032/033 y Android físico.

ADR-117, fichas perfil/contacto e índice, arquitectura/diseño y guía actualizados.
Refinamiento HU-01/05/06/07 RF-01/05/06/13 sin nueva HU/issue ni cierre de historia.
Cambios ajenos en web conservados.

Validación:31/31 pruebas Flutter aprobadas (selector, perfil/contacto, navegación
y arquitectura); formato/diff correctos. Incluyen búsqueda por nombre/ISO/prefijo,
país sin número, pegado completo, borrado, nacional sin prefijo, cambio de país,
compartidos/desconocidos, ceros, control deshabilitado/cancelación, cambio de
controller y liberación; panel390 y320/texto2 con teclado simulado sin overflow.
Renders revisados en apps/mobile/build/ui-preview/country-phone y profile-contact,
con SVG reales precargados para la captura y fuentes locales.
flutter analyze sin incidencias (64.4s).

Logs country-phone-final-tests y country-phone-final-analyze en apps/mobile/build.
No se repite SQL por este cambio de presentación; no hay despliegue, APK o GitHub.
Pendientes teclado/autofill/banderas/selector en Android físico y activación de
los patches anteriores. Siguiente paso: prueba física del recorrido de contacto.

## Celular privado de perfil y sugerencia del reportante —20/10/2026

Completado el recorrido solicitado: Perfil permite guardar/eliminar celular de
contacto opcional, con teclado telefónico, autofill y código de país. Reutiliza
AppTextField/ShakeField/espaciado existentes y feedback en toast superior. Formato
+ y8–15 dígitos; normaliza espacios, guiones y paréntesis. Sin inferir números ni
verificación de titularidad SMS. Guardado junto con nombre/ciudad; estado conserva
borrador ante fallo, cambio de foto/ciudad y bloqueo durante envío; Descartar,
relectura y cambio de identidad mantienen las garantías existentes.

AccountProfile/DTO, contratos, fuente Supabase, UpdateProfile, ViewModel/estado y
ProfileEditor ampliados. read_case_contact incorpora suggested_phone solo para
el autor desde profiles.contact_phone privado. case_contacts consume su propia
proyección y precarga la sugerencia sin activar contacto/foto. Editar/eliminar
el número del perfil no altera contactos publicados; se gestionan en cada ficha.
No amplía proyecciones QR anónimas/PDF/sociales ni acceso a perfiles ajenos.

El contacto por caso ya está preparado en patch031, aún pendiente de activación.
Nuevo plan033/fuentes112–114, migración20261020003300_profile_contact_phone.sql y
patch033 generados mediante Build-ProfileContactPhonePatch/Build-Migration y
Build-RunAll. Aplicar solo pendientes en orden030→031→032→033. Se añade columna
nullable con restricción de formato, grants por columna/RLS propia y sugerencia
autorizada. No se reescriben SQL031/032 ni se insertan datos en cuentas reales.
El validador de run_all admite la nueva columna/estructura sin debilitar rechazo
de tipo o nulabilidad incompatibles; se verifica repetición sin pérdida de datos.

ADR-116, ficha perfil/contacto e índice, guía HU-01/05/06/07 RF-01/05/06/13,
arquitectura/diseño, AGENTS y README SQL/patchs actualizados. Sin nueva HU/issue
ni cierre adicional de historias. Trabajo previo de compartir conservado.

Validación: formato/diff correctos, flutter analyze sin incidencias y39/39 pruebas
Flutter aprobadas (perfil, SDK simulado, foto, contacto, arquitectura y navegación
de perfil/casos). Normalización/rechazo/borrado/reintento/cambio de identidad,
consentimiento desactivado, sugerencia restringida al autor y preservación al
cambiar foto/ciudad. Renders revisados390px normal y320px/texto2, scroll y sin
overflow; fixtures en apps/mobile/build/ui-preview/profile-contact.
SQL/PostGIS local:45/45 pruebas aprobadas en la suite completa. Incluye formato
autoritativo, aislamiento entre dos cuentas, rechazo anónimo, sugerencia solo al
autor, consentimiento/retirada, número publicado independiente del perfil y
repetición del patch033/bundle completo conservando datos y permisos.

Logs profile-contact-verified-tests, profile-contact-final-analyze y
profile-contact-final-sql en apps/mobile/build. Pendiente aplicar SQL remoto
031/032/033 después de030 y verificar persistencia, consentimiento, foto y
teclado/autofill en Android físico. No se ha desplegado SQL, web o APK ni
realizado acciones GitHub. Siguiente paso: activación de los patches pendientes
y prueba con dos cuentas en el entorno real.

## Compartir ficha: panel blanco sin X —20/10/2026

Implementado el diseño aprobado: botón glass junto a Guardar, panel inferior
blanco opaco con tirador, sin glass ni X por corrección explícita. Copiar enlace
en círculo azul/icono blanco, WhatsApp y Facebook con etiquetas; Descargar y
Denunciar son dos círculos grises contiguos solo con iconos, tooltip y semántica.
Cierra por arrastre, toque fuera o Atrás. Scroll/área segura/texto ampliado y
movimiento reducido; cabecera bajo380px reserva título en otra fila para evitar
solapamiento de los tres controles. Denunciar sale del panel al formulario real
del mismo caso y sustituye el botón largo del cuerpo de estas fichas.

case_posters incorpora entidad/contrato/SharePublicCase, ViewModel/estado propios,
repositorio y fuentes RPC/plataforma; reutiliza DTO y PDF saneado existentes.
Bootstrap/main inyectan implementaciones y Clipboard como callback para conservar
la frontera sin Flutter en data. No se relajó la comprobación arquitectónica.
WhatsApp/Facebook abren el destino externo con solo la URL pública; usuario elige
si envía/publica. Descargar abre impresión/Guardar como PDF, con cancelación sin
confirmación falsa de guardado. Toast superior/shimmer solo por operación real,
bloqueo de doble acción y descarte de resultados de otra cuenta.

Plan032/fuentes110–111, RPC prepare_case_share autenticada y patch/migración
20261020003200_case_sharing.sql generados con Build-Migration,
Build-CaseSharingPatch y Build-RunAll. Autor derivado del caso aun si comparte un
lector ajeno; slug estable sin reactivar revocación. Exige búsqueda activa,
visible y con foto comprobada por el lector QR. Avisos vinculados/custodia,
cerradas/ocultas/eliminadas o sin foto no generan enlaces ficticios; Denunciar
permanece disponible. prepare_case_poster sigue exclusivo del autor. Sin nuevos
grants directos, contactos en QR/PDF, SDK social, dependencias o permisos de rol.
La revisión/sesión/enlace se validan otra vez antes de entregar al dispositivo.

ADR-115, ficha compartir-ficha, índice, ficha móvil/carteles, arquitectura,
normas, diseño, AGENTS, guía y README de datos/patchs actualizados. Referencia
visual en mockups/compartir-ficha-referencia.png; su X se elimina por la corrección
posterior del usuario. Ampliación explícita HU-07/HU-08, RF-08/13/37, sin issue
nuevo ni cierre de historias. ImmersivePhotoSheet conservado.

Validación final: formato correcto, flutter analyze sin incidencias y63/63 pruebas
Flutter aprobadas: repositorio/URL/configuración/revisión/PDF, doble acción/cambio
de cuenta, panel normal/pequeño con texto2, movimiento normal/reducido, ausencia
de X/etiquetas inferiores, cierre por los tres medios, denuncia real, reserva de
cabecera360px, fichas, carga, carteles, recuperación y arquitectura.
SQL/PostGIS local45/45: incluye compartir por lector ajeno, propiedad intacta,
idempotencia, revocación/cierre/moderación y repetición de migración/bundle.

Renders revisados en apps/mobile/build/ui-preview/case-sharing, con fuentes reales,
fixtures y teselas simuladas; no acredita el proveedor cartográfico por red.
Logs case-sharing-final-{analyze,tests}, case-sharing-layout-final y
case-sharing-sql-suite en apps/mobile/build. Generación sin reescribir SQL previo.
Pendiente activar032 después de031 y comprobar Clipboard, WhatsApp/Facebook,
enlace QR y guardar/cancelar PDF en Android físico. Se reutiliza la configuración
pública ya existente; no se afirma que la web QR previamente confirmada esté caída.
Sin despliegue, APK o GitHub. Siguiente paso: activación remota autorizada y prueba
física. Cambios existentes conservados.

## Ficha pública: fidelidad de Perdido y glass —20/10/2026

Por corrección explícita del usuario, la etiqueta del caso se coloca a la derecha
del nombre en la misma fila, centrada verticalmente. Los puntos de galería van
centrados debajo. Texto ampliado o etiqueta larga apilan sin recortar el estado;
la foto ampliada usa proporción0.8 para reservar espacio.

GlassSurface incorpora el acabado frosted compartido: ribete blanco único,
sombra difusa suave y gradiente perla/celeste traslúcido. Tarjetas de la ficha y
controles de contacto lo reutilizan, retirando el relleno gris adicional y el
doble borde oscuro. SMS/teléfono conservan iconos azules, ahora22, y objetivo52.
Volver/guardar mantienen el glass anterior; polished sigue siendo el valor por
defecto para todos los consumidores previos. ImmersivePhotoSheet intacto.

ADR-113, normas, diseño, arquitectura, índice y fichas actualizados. Sin cambios
funcionales, datos, SQL, permisos o alcance HU; activación031 sigue pendiente.

Validación: formato correcto y flutter analyze sin incidencias.28 pruebas de ficha,
contacto, patrón inmersivo, carga y arquitectura aprobadas;26 de perdidos/encontrados
y1 de estabilidad de glass en Inicio también aprobadas (55 en total). Regresión
geométrica confirma misma línea nombre/estado, margen derecho16 y paginación
centrada;390×844 y320×350/texto2, movimiento normal/reducido. La prueba de Inicio
ya verificaba pintura estable y falló solo por una etiqueta retirada; se actualizó
su toque a la acción real Mis mascotas, sin cambiar Inicio.

Capturas normal/pequeña revisadas en apps/mobile/build/ui-preview/public-cards,
comparadas con mockups/ficha-publica-glass-contacto.png. Fotos/datos de fixture y
teselas simuladas; no prueba red real. Logs public-cards-fidelity-{tests,analyze,
regressions,home-glass} en apps/mobile/build. Siguiente paso: revisión Android
físico. Sin APK, despliegue ni operaciones remotas; cambios previos conservados.

## Nueva ficha pública glass y contacto autorizado —20/10/2026

Implementados CasePublicCards/CasePublicScreenShell en consultas de perdidos y
encontrados, según el último mockup aprobado (conservado en
mockups/ficha-publica-glass-contacto.png). Foto redondeada, nombre blanco48/800,
metadatos/rasgos en tarjetas gris perla, mapa propio con punto/halo azul y créditos
compactos, CTA azul y enlace Ver seguimiento. Volver/guardar mantienen glass
compartido; SMS/teléfono también usan ese control con iconos azules. Título de
navegación20 por composición aprobada,32 en fila propia con texto ampliado.
Scroll normal; título se desplaza para evitar solapamientos. Se conservan
operaciones reales y permisos de seguimiento, avisos/custodia, cartel, cierre y
denuncia. ImmersivePhotoSheet conserva íntegro su diseño y uso en vistas previas.

Por elección explícita del usuario se añade case_contacts, dominio/casos de uso,
DTO/fuente/repositorio y ViewModel autoDispose por caso/cuenta. Router compone el
panel por slot; bootstrap/main inyectan. El autor registra/edita/retira contacto
DESDE SU FICHA PUBLICADA, con consentimiento desactivado inicialmente y elección
separada para foto. Guardado independiente, sin volver a publicar el caso.
Nombre público2–80, teléfono internacional y avatar de perfil almacenado opcional;
inicial real si no hay foto. SMS/marcador son acciones externas, sin chat propio.

Plan031/fuentes106–109, migración20261020003100_case_contacts.sql y patch031
versionados/generados. Tabla privada/RLS/RPC, autor por auth.uid(), CAS/reintento
exacto y autorización por caso activo/visible. Foto: SELECT acotado y URL60s;
escrituras continúan privadas incluso ante políticas permisivas amplias.
Retirada/cierre/ocultamiento bloquean nuevas lecturas/firmas, sin recuperar
imágenes descargadas ni invalidar antes de tiempo una firma ya emitida.
No se amplían QR/web anónima/carteles ni consultas de perfiles privados.

Documentados ADR-113/114, fichas ficha-publica-mobile/contacto-reportante,
índice, patrón conservado, guía, arquitectura, diseño, normas y AGENTS.
Ampliación explícita de HU-05/06/07, RF-05/06/13; sin issue nuevo ni cierre de HU.

Validación local final: flutter analyze sin incidencias, formato correcto y
78/78 pruebas Flutter aprobadas: layouts390×844 y320×350/texto2, movimiento
normal/reducido, galería/descripción, mapa público, acciones/retorno, contacto,
reintento ambiguo/doble envío/cambio de cuenta, navegación, recuperación,
cronología, mapas compartidos y arquitectura. Se corrigió un desbordamiento
real del enlace de seguimiento con texto2 detectado al ampliar la suite.
Pruebas con AMBIENT_BACKGROUND_MOTION=false y base Positron configurada.
Renders revisados en apps/mobile/build/ui-preview/public-cards (fixtures de
prueba y teselas simuladas, sin afirmar validación del proveedor por red).

SQL:43/43 pruebas de la batería PostgreSQL/PostGIS local aprobadas, más repetición
de las2 de contacto fortalecidas con ocultamiento por moderación y conflicto
tras edición intermedia. Se verifican aislamiento, consentimiento, firma autorizada,
revocación, restricciones, reintentos y repetición de migración/bundle.
Build-Migration/Build-CaseContactsPatch/Build-RunAll correctos, sin reescribir
migraciones anteriores. Logs public-cards-final-{analyze,tests},
public-cards-sql-suite y sql-contact-tests en apps/mobile/build.

Pendiente: aplicar031 después de030 en Supabase, verificar Storage/foto y
SMS/marcador en Android físico. Sin activación hosted, APK, despliegue o GitHub.
Siguiente paso: activación remota autorizada y revisión física con dos cuentas;
el diseño queda implementado y el patrón anterior conservado. Cambios locales
previos preservados, incluido mockups/detalles-ficha.png.

## Diseño conservado: Ficha fotográfica inmersiva —20/10/2026

Por petición explícita se conserva el diseño actual de Ver ficha para una futura
funcionalidad. CasePublicationPreview se renombra a ImmersivePhotoSheet y su
geometría a ImmersivePhotoSheetGeometry, con archivos, imports, consumidores y
pruebas actualizados. Sin cambios visuales o de comportamiento: sigue activo
en fichas/vistas previas de perdidos/encontrados. No se elimina ni duplica.

ADR-112 y ficha funcionalidades/ficha-fotografica-inmersiva.md documentan
composición, medidas, gestos, campos, privacidad, dependencias, errores y
reutilización. Índice, arquitectura, diseño, normas UI, AGENTS, guía y ficha de
reportes enlazan la conservación. Sin nueva HU/issue, cierre de historias,
operaciones, SQL o permisos. Propuesta glass por tarjetas aprobada visualmente,
aún sin aplicar; funcionalidad futura sin definir.

Validación local: formato de8 archivos y40/40 pruebas existentes aprobadas
(composición normal/compacta, texto2, movimiento normal/reducido, integraciones
perdidos/encontrados y arquitectura), con AMBIENT_BACKGROUND_MOTION=false.
Flutter analyze sin incidencias. Revisión física Android pendiente. Siguiente paso:
aplicar el nuevo diseño a Ver ficha en otro incremento conservando este patrón.
Sin APK, despliegue ni acciones GitHub. Cambios locales previos conservados.

## Ficha del caso: nombre con diseño original —20/10/2026

Por instrucción explícita se restaura únicamente el nombre sobre fotografía
de CasePublicationPreview a su diseño anterior: fuente del sistema, blanco,
tamaño48/peso800, altura1.05, sombra suave y dos líneas con elipsis; sin cápsula.
Los demás títulos mantienen Poppins400/32/gris. Excepción registrada en AGENTS,
ADR-111, norma UI y fichas. Sin cambios de datos/permisos/acciones o alcance.

Validación: formato correcto y4/4 pruebas del preview aprobadas en390×844 y
320×350/texto2 con movimiento normal/reducido; se verifican estilo original,
scroll y acciones. Captura390 revisada con texto blanco directamente sobre foto;
renders en apps/mobile/build/ui-preview/publication-preview. Flutter analyze sin incidencias.
Logs case-title-original-* en apps/mobile/build. Siguiente paso: revisión Android
físico; sin APK ni despliegue.

## Ver ficha: nombre sin cápsula blanca —20/10/2026

Por corrección explícita del usuario se retira GlassSurface/ColoredBox y padding
añadidos bajo el nombre en CasePublicationPreview. Nombre directamente sobre la
fotografía, conservando Poppins400/32/gris, ajuste de texto, panel y operaciones.
ADR-111, norma UI y fichas actualizadas; sin cambios de datos/permisos o alcance.

Validación: formato correcto, flutter analyze sin incidencias y4/4 pruebas del
preview aprobadas en390×844 y320×350/texto2, con movimiento normal/reducido y
acciones/scroll accesibles. Captura390 revisada sin fondo blanco; renders en
apps/mobile/build/ui-preview/publication-preview y logs preview-no-title-background-*
en apps/mobile/build. Siguiente paso: revisión Android físico; sin APK ni despliegue.

## Títulos de las secciones alineados con Inicio —20/10/2026

Corregido el centrado vertical de CollectionHeader: la fila ancla sus hijos
arriba, conservando altura mínima56 y espacio de acciones. Explorar y Mis
mascotas comparten origen superior/lateral con «Su regreso»; se elimina la
bajada8 con texto normal. Se reutiliza la cabecera en los demás listados,
sin offsets negativos ni ajustes por pantalla. Tipografía Poppins y datos/
permisos intactos. Refinamiento de ADR-111 y regla UI; fichas actualizadas.

Validación: regresión integrada en Home reproduce antes el desfase92→100 y
pasa después, con fuentes reales y navegación entre secciones en390×844 y
320×350/texto2. Suite de títulos, Inicio, listados, carga de mascotas y
arquitectura37/37 aprobada; formato correcto y flutter analyze sin incidencias.
Capturas en apps/mobile/build/ui-preview/primary-titles y logs title-alignment-*
en apps/mobile/build. Siguiente paso: revisión Android físico; sin APK ni despliegue.

## Títulos principales Poppins en móvil y web —20/10/2026

Regla explícita del usuario, ADR-111: Poppins Regular400, base32, gris #454746,
altura1.25 y tracking0 para títulos de pantalla/página/etapa. AppTypography y
typography.css centralizan el contrato; mismo Regular local/OFL en ambas apps.
Incluye Guardados, listados, acceso/onboarding, perfil/preferencias/ubicaciones,
fichas, landing h1, cuenta/moderación, QR/avistamientos y legales. Retirados los
overrides de títulos por recorrido; texto ampliado con ajuste y scroll. La marca
oficial y el remate azul600 de Inicio conservan su estilo. El nombre sobre foto
usa superficie clara para contraste; ilustraciones del hero ajustadas al título32
para evitar solapar la descripción. No unifica márgenes/altura de cabeceras.

Regla registrada en AGENTS, normas UI móvil/web, DISENO_UI, guía y fichas enlazadas.
Sin nuevas HU/RF/issues ni cambio de dominio/data/SQL/permisos o cierre de historias.

Validación final: formato correcto, flutter analyze sin incidencias y70/70 pruebas
de layouts, preview, Inicio, acceso, listados, arquitectura, perfil, mascotas y
entrada de preferencias aprobadas con AMBIENT_BACKGROUND_MOTION=false.
Seis layouts nuevos usan fuentes reales en390×844 y320×350/texto2, con acciones
alcanzables. Preview verifica también nombre largo completo y ambos modos de
movimiento. Primera pasada detectó expectativas antiguas de truncado/sombra y
un gesto de prueba con posición fija; adaptados al nuevo título y scroll real.
La captura nueva se corrigió para ejecutar rasterización fuera del reloj de prueba.

Web: typecheck/build correctos,56/56 pruebas aprobadas, incluida paridad de tokens
y archivo de fuente móvil/web. Chrome verificó30 layouts de10 páginas, texto200%,
QR sin JS, ausencia de overflow/CSP/hidratación y fuente local cargada; QA existente
de onboarding también aprobada con su nueva tipografía y flujos intactos.
Capturas revisadas en apps/mobile/build/ui-preview/primary-titles y
publication-preview; logs primary-titles-{format,analyze,final-tests},
primary-web-{build,tests} en apps/mobile/build. Siguiente paso: revisión física
Android y dispositivos reales; sin APK, publicación ni despliegue.

## Títulos de Explorar y Mis mascotas —20/10/2026

Por petición del usuario, ambos títulos usan peso400 y gris #454746, como
«Su regreso», conservando fuente del sistema, tamaño32 y adaptación accesible.
CollectionHeader permite compartir el estilo entre ambas secciones sin cambiar
los demás listados. El fallback de Home también conserva esta coherencia.
Sin cambios de alcance, dominio, datos o permisos. Fichas: funcionalidades/explorar.md
y funcionalidades/mascotas.md. Formato correcto y flutter analyze completo sin
incidencias. Sin pruebas nuevas por tratarse de un ajuste tipográfico; siguiente
paso: revisión visual en Android. Sin APK ni despliegue.

## Navegación móvil: arrastre al pasar por Explorar —20/10/2026

Corregida la pérdida de animación Inicio→Explorar→Mis mascotas y vuelta.
Insertar/retirar el botón flotante Mapa desplazaba el Positioned sin clave de
la barra y desmontaba LiquidNavigation. Clave estable en ese contenedor
conserva estado y tween320ms; movimiento reducido inmediato. Solo presentación,
sin cambios de alcance, dominio, datos o permisos. Ficha: funcionalidades/inicio.md.

Validación: las dos nuevas regresiones integradas fallaron antes del ajuste
por desmontaje y pasan después; comprueban ambos sentidos con Mapa, identidad
y posiciones inicial/intermedia/final. Suite Home/refresh de Inicio y mascotas/
arquitectura/consistencia27/27 aprobada con AMBIENT_BACKGROUND_MOTION=false;
formato correcto y flutter analyze completo sin incidencias.
Siguiente paso: revisar animación en Android físico; sin APK ni despliegue.

## Confirmación de salida: popup rápido —20/10/2026

Corregido «¿Salir del reporte?» y las confirmaciones compartidas sin origen:
PopupDialogTransition funde superficie y contenido juntos con escala uniforme
.96→1 en160ms al abrir/cerrar. Retira cuadro central expandido y texto tardío;
sin desplazamiento desde retorno. Conserva layout/acciones, scroll, insets y
movimiento reducido inmediato. Confirmaciones con origen explícito conservan
OriginDialogTransition/320ms. Refinamiento de ADR-006, HU-05/RF-05 y HU-06/RF-06;
sin cambios de dominio/data/SQL ni ampliación de alcance.

Validación: formato correcto, análisis Flutter completo sin incidencias y34/34
pruebas de confirmaciones, morph con origen, arquitectura, consistencia y entrada
real de reportes aprobadas con AMBIENT_BACKGROUND_MOTION=false. Dos regresiones
verifican entrada completa a160ms, escala mínima96%, cierre y movimiento reducido.
Renders390×844 y320×350/texto2 revisados en build/ui-preview/confirmations;
acciones alcanzables con scroll. Log: apps/mobile/build/popup-confirmation-tests.log.
Primeros intentos detectaron un nombre de archivo de prueba inexistente y un
finder demasiado amplio en la nueva prueba; corregidos antes de la suite final.
Siguiente paso: revisar sensación de apertura/cierre en Android autenticado;
sin APK ni despliegue ni cierre de historias.

## Alertas: expansión desde campana y vacío compartido —20/10/2026

La campana de Inicio entrega OriginPageSource con sus límites reales relativos
al Navigator a la ruta existente de Alertas. Reutiliza entityEditorPage y
OriginPageTransition (320ms/260ms, movimiento reducido inmediato), conservando
la sección subyacente. Bandeja vacía confirmada reutiliza CollectionEmptyState
de Mis mascotas/Explorar con campana neutra, título y descripción centrados.
Skeleton/error no muestran vacío; preferencias, lectura, paginación y refresh
conservan su comportamiento. Refinamiento de HU-12.2/#41, RF-17,18 según ADR-006;
sin dominio/data/SQL nuevos ni cambios de alcance.

Validación:40/40 pruebas de notificaciones, navegación, Inicio, arquitectura y
consistencia aprobadas con AMBIENT_BACKGROUND_MOTION=false; análisis Flutter
completo sin incidencias. Regresión de navegación verifica origen real,
expansión intermedia y retorno; cuatro de bandeja verifican carga/vacío/error
y recuperación en390×844 y320×350/texto2, este último con movimiento reducido.
Capturas del vacío en apps/mobile/build/ui-preview/notifications.
Siguiente paso: revisión visual Android autenticado y demo real de HU-12;
sin APK, despliegue ni cierre de historia.

## Selectores móviles: una sola entrada de opciones —20/10/2026

Corregida la apertura duplicada de AppSelectField, visible en Especie y Sexo
(opcional): el panel inferior ya animaba su entrada y su cuerpo añadía otra
cortina de AppPageBackground antes del stagger. Retirada esa cortina interna;
StaggerReveal empieza al completar la animación de ruta del panel, con cabecera
estable y movimiento reducido inmediato. Corrección compartida para todos sus
consumidores, sin cambiar opciones, selección, cancelación o contratos.
Refinamiento de ADR-006, sin ampliar HU-03/RF-03 ni otros recorridos consumidores.

Validación: formato correcto y análisis Flutter completo sin incidencias;
20/20 pruebas de selector, arquitectura y consistencia aprobadas;
cuatro regresiones nuevas comprueban Especie/Sexo, ausencia de cortina, espera
hasta abrir el panel, progreso sin reinicio y selección, en390×844 y320×350
con texto2/movimiento reducido. Las pruebas existentes mantienen cancelación,
valor desconocido y bloqueo. Fondo ambiental desactivado mediante configuración
de pruebas para permitir pumpAndSettle. Logs en apps/mobile/build/select-reveal-*.log.
Siguiente paso: revisión visual Android de apertura/cierre; sin APK ni despliegue.

## Preferencias y ubicaciones: entrada sin reveal duplicado —20/10/2026

Corregido el reinicio de cover/stagger al resolver la consulta en Preferencias
de alertas y Ubicaciones de interés (HU-02.2/#27 y HU-02.1/#26; RF-02,16).
Las claves dependientes de datos reconstruían la transición al pasar de
unavailable a la cuenta; en preferencias también reconstruían el scroll.
Se conserva el subárbol de entrada y se deshabilita la cortina durante carga,
siguiendo la regla existente: skeleton y resultado pertenecen a una sola entrada.
Las etapas lista/editor mantienen su transición; datos de otra identidad siguen
ocultos por el estado del ViewModel. Sin cambios de dominio, persistencia o alcance.

Validación: formato correcto, análisis Flutter completo sin incidencias;24 nuevas
regresiones de ambas pantallas con consultas50/2000ms, datos/vacío/error y
movimiento reducido. Suite focalizada38/38 con fondo animado; suite ampliada61/61
con AMBIENT_BACKGROUND_MOTION=false, incluidos formularios normales/pequeños,
descarte, reintentos, arquitectura y consistencia. Primer intento ampliado:55/61,
con6 timeouts de pumpAndSettle por la animación continua del fondo; repetición
con su configuración de movimiento desactivada aprobada. Logs en
apps/mobile/build/preferences-reveal-{focused,static-background,analyze}.log.
Siguiente paso: comprobar ambas entradas en Android autenticado; no se generó
APK ni se desplegó.

## Explorar: continuidad del gesto del panel —20/10/2026

Nueva corrección solicitada por el usuario: el acomodo conserva velocidad al
soltar mediante resorte amortiguado1/260/34; sustituye el reinicio desde reposo
de easeInOutCubic. Tocar otra vez detiene el controlador antes de reconocer el
nuevo arrastre. Controlador liberado al desmontar; límites, scroll de contenido,
resistencia inferior, créditos y movimiento reducido conservados. Solo presentación,
refinamiento de ADR-106 / HU-07.2 / RF-13 / issue #33, sin ampliar alcance.

Validación inicial:16 pruebas de mapa/arquitectura aprobadas, incluida regresión
de impulso tras pasada rápida, interrupción al contacto y arrastre en sentido
contrario. Las6 pruebas de mapa repetidas con CARTO/capturas también aprobadas
en apps/mobile/build/explore-panel-fluid-carto.log. Formato correcto y análisis
completo sin incidencias (build/explore-panel-fluid-analyze.log).
Siguiente paso: revisar sensación y rendimiento en Android físico;
los frames de widget no certifican fluidez del dispositivo. Sin APK ni despliegue.

## Explorar: movimiento más suave del panel —20/10/2026

Por petición del usuario, sustituir snap lineal por acomodo easeInOutCubic al
soltar, con duración320–540ms según recorrido. Pasadas rápidas avanzan en su
dirección; liberaciones lentas van a la parada cercana. Mismos límites mínimo
adaptable/50%/90%, Ver ficha accesible y créditos acompañando el panel. Durante
arrastre sigue al dedo sin tween; retorno de resistencia con resorte amortiguado
1/190/28. No cortar la inercia de contenidos ni activar acomodo por simples
toques. Nuevos gestos invalidan callbacks pendientes, con mounted/dispose.
Reduced mantiene acciones inmediatas y sin acomodo autónomo. Refinamiento de
ADR-106 / HU-07.2 / RF-13 / issue #33; sin dominio/data/SQL nuevos.

Validación:6 pruebas de mapa con proveedor CARTO de fixture y10 de arquitectura
aprobadas. La regresión de movimiento comprueba posición intermedia tras100ms
y llegada a la parada al soltar despacio, además de los gestos de minimización,
resistencia, selección, ficha, créditos, pan y altura pequeña/texto2 existentes.
Formato correcto, análisis Flutter completo sin incidencias y diff limpio.
Siguiente paso: comprobar sensación de movimiento en Android físico; las pruebas
de frames no sustituyen esa revisión. Sin APK, instalación o despliegue.

## Inicio: accesos negros con contenido blanco —20/10/2026

Por nueva instrucción del usuario, Reportar/Mis reportes/Mis mascotas usan
fondo negro #111111 y texto/iconos blancos. Texto recupera peso600 original y
se retira el refuerzo de iconos. Tamaños compactos conservados; origen visual
de apertura de Reportar actualizado al negro. Sin cambios de alcance o permisos.
Validación: formato/análisis completos limpios;11 comprobaciones de
arquitectura/captura aprobadas, tamaños390×844/texto1 y320×350/texto2 sin
overflow. Captura normal revisada. Siguiente paso: revisión visual Android.

## Inicio: actualizar al jalar hacia abajo —20/10/2026

Por petición del usuario, Inicio habilita el PullToRefresh compartido, con
el mismo indicador glass/gesto/retorno de Explorar y Mis mascotas. Recarga
real del perfil de cabecera mediante su ViewModel/caso de uso existente;
tarjetas e ilustración siguen siendo contenido fijo. Router inyecta callback,
sin imports entre presentaciones. HomeViewModel bloquea duplicados y descarta
errores tardíos al cambiar sección; toast superior con Reintentar ante fallo.
Avatar conserva información durante refresh explícito de la misma identidad.
Sin retrasos simulados, navegación nueva, SQL, permisos o ampliación de HU.

Validación: formato/análisis completos limpios;14 pruebas de recarga de
Inicio/Mascotas/arquitectura y8 de perfil aprobadas. Incluyen consulta real de
perfil, conservación de iniciales, gesto/espera/duplicados, destino propio de
Explorar, error/reintento y respuesta tardía. Dos pruebas antiguas de perfil
esperaban cierre del toast a4s; ajustadas a6500ms y su animación de salida.
Siguiente paso: comprobar el gesto y la consulta autenticada en Android.

## Inicio: accesos con azul más intenso y mayor grosor —20/10/2026

Por petición del usuario, Reportar/Mis reportes/Mis mascotas usan azul #2887EF
en texto e iconos, conservando fondo gris y tamaño compacto. Texto700 (antes600)
y refuerzo horizontal de iconos0.25px por lado, sin blur. Sin cambios de rutas,
dominio, permisos o alcance. Formato/análisis completos limpios;11 comprobaciones
de arquitectura/captura aprobadas, tamaños390×844/texto1 y320×350/texto2 sin
overflow. Captura normal revisada. Siguiente paso: revisión visual Android.

## Inicio: título mayor con degradado de referencia —20/10/2026

Por nueva referencia del usuario, título Poppins32 (antes26), «Su regreso»
gris400 y «empieza contigo» peso600 con degradado horizontal #459FF6→#75C9EF.
ShaderMask local sobre la segunda frase; sin fondo glass. Dos textos con
ajuste natural/ampliación y una etiqueta semántica completa, stagger conservado.
Sin cambios de alcance o arquitectura. Descripción permanece bajo ilustración.
Validación: formato/análisis limpios;11 comprobaciones de arquitectura/captura
aprobadas. Renders390×844/texto1 y320×350/texto2 revisados sin overflow;
texto ampliado puede repartir palabras entre líneas. Captura no acredita imagen.
Siguiente paso: revisión visual Android.

## Inicio: título libre y descripción junto a ilustración —20/10/2026

Por instrucción del usuario se retira GlassSurface del título «Su regreso
empieza contigo» y se aumenta de23 a26, conservando Poppins, pesos, colores,
salto y stagger. La descripción se mueve debajo del perro/gato dentro de
HomeReunionCard, con la imagen3:2 y glass existentes. Cerca de ti conserva glass.
Sin cambio de alcance, dominio, datos o permisos.
Validación: formato/análisis completos limpios y11 comprobaciones de
arquitectura/captura aprobadas; renders390×844/texto1 y320×350/texto2 revisados
sin desbordamientos. La captura no acredita el render de la ilustración.
Siguiente paso: revisión visual en Android con el asset real.

## Inicio: glass en Cerca de ti —20/10/2026

Por petición del usuario, HomeNotice reutiliza GlassSurface/radio26 en la
tarjeta «Explora cerca de ti», como el título principal y la ilustración.
Conserva contenido/padding y acción Explorar; entrada con preserveBackdrop
para mantener el material glass. También aplica al fallback que usa HomeNotice.
Sin cambios de alcance, datos o permisos.
Validación: formato y análisis completo limpios;11 comprobaciones de
arquitectura/captura aprobadas, tamaños390×844/texto1 y320×350/texto2 sin
desbordamientos. Captura normal revisada. Siguiente paso: revisión en Android.

## Inicio móvil: tarjeta y accesos compactos —20/10/2026

Por instrucción del usuario se retiran la huella sobre «Su regreso» y el
enlace «Conoce Mis mascotas». Corrección del usuario: Reportar, Mis reportes y
Mis mascotas conservan fondo gris #F5F5F7; solo iconos/textos usan azul #459FF6,
igual que «empieza contigo».
Padding vertical16 (antes20), iconos25 (antes28), separación10 (antes12) y
texto12.5 (antes13); ampliación y columna adaptable conservadas. Origen visual
de apertura de Reportar conserva el fondo gris. Sin cambio de alcance o permisos.

Validación: formato correcto, análisis Flutter completo sin incidencias y11
comprobaciones aprobadas (arquitectura y captura específica de Inicio).
Renders390×844/texto1 y320×350/texto2 revisados, sin desbordamientos.
La captura aísla contenido y no acredita la imagen de reencuentro ni Android.
Siguiente paso: revisar el ajuste en Android.

## Explorar: panel minimizable y créditos junto al borde —20/10/2026

Por instrucción del usuario, permitir bajar el panel hasta Ver ficha completo,
antes del separador de Detalles. Apertura50% (o mínimo accesible si requiere
más), máximo90% y mínimo según altura real del resumen/botón +tirador32 +inset
inferior+12. Sin selección22%; contenido excepcional mantiene scroll. Medición
solo en presentación, con callback tras layout y comprobación mounted.

MapAttribution.compact usa fuente8/objetivos48 y fondo estrecho a la derecha,
aproximadamente8px sobre el panel, acompañando extensión/resistencia. Créditos
enlazados/semántica completa conservados, elipsis/tooltip con texto ampliado.
ZoneMapPicker omite su crédito superior solo porque ExploreCaseMap lo compone
en la nueva posición. Cámara reserva espacio adicional para evitar tapar pines;
título central se retira si falta altura, retorno conservado hasta expansión.
Otros mapas y paleta global intactos. [ADR-106](decisiones/106-mapa-panel-minimizable-y-creditos-compactos.md),
[ficha](funcionalidades/explorar.md). HU-07.2 / RF-13 / issue #33.

Validación:17 pruebas mapa/selector/arquitectura aprobadas con CARTO de fixture,
AMBIENT_BACKGROUND_MOTION=false y capturas activadas. Regresión por gesto en
390×844 y320×350/texto2: Ver ficha completo, Detalles fuera del área visible,
créditos sobre panel, retorno/selección/pan/ficha y reintentos conservados.
Análisis completo sin incidencias; último análisis de archivos intervenidos y
formato correctos. Renders minimizados normal/pequeño revisados: crédito pequeño
y sin superposición con retorno. Teselas neutras, sin acreditar proveedor real.
Siguiente paso: revisión Android del gesto/posición. Sin APK, instalación,
SQL, despliegue o cierre de historia; cambios previos de Inicio conservados.

## Tipografía del título de Inicio móvil —20/10/2026

Por referencia explícita del usuario, «Su regreso» usa Poppins regular/gris y
«empieza contigo» seminegrita/azul, separados por salto de línea, tamaño23 y
altura1.25. Fuentes400/600 incluidas con licencia OFL, sin descarga en ejecución.
Excepción local a la fuente del sistema en [ADR-105](decisiones/105-titulo-inicio-mobile-referencia-tipografica.md).
Tarjeta glass, acciones y entrada conservadas; sin cambio de alcance de HU.

Validación: formato correcto y análisis Flutter completo sin incidencias.
Home/arquitectura:15 comprobaciones aprobadas y2 fallos por timeout de
pumpAndSettle con el fondo animado continuo. La herramienta general de
capturas presenta el mismo bloqueo. Se añade captura específica
tool/capture_home_title.dart con fuentes reales y movimiento reducido:
aprobada en390×844/texto1 y320×350/texto2, sin desbordamientos. Título revisado
en build/ui-preview/home-title/normal.png y small.png; la frase crece y se
reparte en más líneas al ampliar texto. Estas capturas aíslan el contenido.

Siguiente paso: revisión visual Android y adaptación de las esperas de las
pruebas generales al fondo continuo. Sin APK, instalación ni despliegue.

## Cartografía global con acabado intermedio —20/10/2026

Por instrucción del usuario, todos los mapas móviles/web usan el punto medio
entre Reportar original y el filtro anterior de Explorar:50% color fuente y50%
acabado anterior. MapStyle en core/presentation se aplica obligatoriamente en
ZoneMapPicker; retirar filtro/override local de Explorar. Incluye selectores,
reportes, ubicaciones, avistamientos/revisión y fichas/previas móviles.

Web extrae LocationMap compartido: SightingMap solo adapta el contrato de punto.
Matriz equivalente en SVG/CSS local únicamente sobre teselas. Usa la misma base
CARTO Positron mediante NUXT_PUBLIC_MAP_TILE_URL, configurada en .env ignorado
desde la URL móvil, sin versionar la clave pública de teselas. CSP permite solo
host CARTO en imágenes externas; créditos OSM/CARTO enlazados fuera del filtro.
Selección, radios, pines, datos y permisos conservados. No crea Explorar web.
[ADR-104](decisiones/104-cartografia-global-mobile-web.md),
[ficha](funcionalidades/cartografia-compartida.md). Regla registrada también en
AGENTS, arquitectura y normas UI móvil/web; comprobaciones previenen bypass y
divergencia numérica de matrices. Sin SQL ni nuevas operaciones de producto.

Validación:17 pruebas Flutter mapa/selector/arquitectura aprobadas; formato y
análisis completo sin incidencias.55 pruebas web y26 de servidor de producción
aprobadas; typecheck y build correctos. Build aislado .nuxt-map-style para
conservar el servidor de desarrollo activo; no se detuvo el proceso del usuario.
QA navegador1440/731/390/320/1920 y320×350/texto200% aprobada: selección manual,
GPS denegado, foto/reintento ambiguo, CSP/hidratación, créditos y píxel filtrado
realmente pintado sobre tesela fixture. Captura del mapa web revisada. Las
capturas no acreditan apariencia/red real del proveedor en producción.

Siguiente paso: revisión de mapas reales Android/web; configurar la URL pública
de teselas en el entorno web publicado y desplegar cuando se autorice. El
fallback OSM móvil sin configuración también recibe el filtro, pero no equivale
a la base Positron configurada. Sin APK, instalación, despliegue o historia cerrada.

## Panel del mapa al50% —20/10/2026

Elección explícita del usuario: inicio y mínimo50%, ya que60% resulta demasiado
alto. Selección, colapso, cámara y resistencia acompañan el nuevo mínimo;
máximo90% y contenido desplazable conservados. La fecha puede requerir scroll.
ADR-103 / HU-07.2 / RF-13 / issue #33, sin cambios de alcance o backend.

Validación:6 pruebas de mapa aprobadas, con acceso a fecha mediante scroll,
retorno/selección y320×350/texto2. Análisis de pantalla/widget sin incidencias
y formato correcto. Siguiente paso: revisión visual Android de la altura50%.
Sin APK, instalación o despliegue.

## Cartografía casi neutra según segunda captura —20/10/2026

El usuario corrige el amarillo hueso excesivo y aporta una referencia blanco
grisáceo apenas cálido. Ajustar solo filtro de teselas: luminancia92%, mezcla8%
hacia blanco y azul−4; gris245→#F6F6F2 y blanco→#FFFFFB. Recupera contraste
frente al aclarado18% anterior. Pines/créditos, foto, glass y panel60–90%
conservados. Refinamiento de ADR-103 / HU-07.2 / RF-13 / issue #33.

Validación:6 pruebas de mapa aprobadas, análisis del widget sin incidencias,
formato correcto y captura normal revisada con teselas neutras. Siguiente paso:
revisión visual sobre cartografía real Android. Sin APK, instalación o despliegue.

## Panel del mapa más alto al abrir y colapsar —20/10/2026

Por instrucción del usuario, altura inicial y mínima de45 a60% para evitar
que la fecha quede recortada tras ampliar foto/espaciados. Máximo90%, cámara,
selección, colapso y resistencia alineados con el nuevo mínimo. Conserva scroll
para pantallas pequeñas/texto ampliado. ADR-103 / HU-07.2 / RF-13 / issue #33.

Validación:6 pruebas de mapa aprobadas, incluida regresión que comprueba fecha
completa sobre el área del sistema con16px de margen a390×844; también cubren
320×350/texto2. Análisis de pantalla/widget sin incidencias, formato correcto
y captura normal revisada con todos los datos visibles. Siguiente paso:
revisión física Android. Sin APK, instalación, despliegue o cambios de backend.

## Espaciado de Detalles del caso —20/10/2026

Por comparación explícita de capturas del usuario, aumentar separación del
resumen del mapa: separador con padding vertical16 (antes12), título→datos16
(antes10) y16 entre filas (antes8). Mantener textos, etiqueta/valor, iconos,
foto y acciones; panel permite scroll. Refinamiento de ADR-103 / HU-07.2 /
RF-13 / issue #33, sin cambio de alcance o backend.

Validación:6 pruebas de mapa aprobadas, análisis del widget sin incidencias y
formato correcto. Captura del panel expandido revisada, con filas más separadas;
pruebas incluyen320×350/texto2. Siguiente paso: revisión visual Android del gap.
Sin APK, instalación ni despliegue.

## Color amarillo hueso del mapa —20/10/2026

Corrección explícita del usuario: sustituir el gris neutro de Explorar por
amarillo hueso suave. Filtro solo en teselas: gris245 se convierte en #F7F5EB
y blanco en #FFFDF3, manteniendo contraste de calles/textos y pines/créditos
sin filtrar. Foto112px, cabecera glass, cámara y consulta conservadas.
Refinamiento de ADR-103 / HU-07.2 / RF-13 / issue #33, sin cambio de alcance.

Validación:6 pruebas de mapa aprobadas, análisis del archivo sin incidencias,
formato correcto y capturas regeneradas; normal revisada con teselas neutras.
Siguiente paso: revisión visual del tinte sobre cartografía real en Android.
Sin APK, instalación o despliegue.

## Refinamiento del mapa, foto y cabecera glass —20/10/2026

Por nueva petición del usuario, foto del resumen de80 a112px y título Explorar
en GlassSurface/radio24/padding22×12, con centrado y retirada al expandir intactos.
Cartografía desaturada y aclarada18% solo en teselas; pines oficiales/créditos
conservan contraste. Selección acerca hasta zoom15 desde una vista más amplia,
sin alejar zoom superior ni cambiar búsqueda/ubicaciones públicas; pan/zoom libre.
ZoneMapPicker recibe tileColorFilter opcional; mapas restantes sin filtro.
Refinamiento de [ADR-103](decisiones/103-mapa-resumen-compacto-referencia-aprobada.md)
y [ficha](funcionalidades/explorar.md), HU-07.2 / RF-13 / issue #33.

Validación:16 pruebas de mapa/selector de ubicación/arquitectura aprobadas en
serie con AMBIENT_BACKGROUND_MOTION=false, formato correcto y análisis completo
sin incidencias. Capturas390×844 y320×350/texto2 revisadas: foto mayor/cabecera
glass y scroll disponibles; fecha/detalles pueden requerir desplazar el panel.
Las teselas de fixture no acreditan calles reales. Siguiente paso: revisión
visual Android del proveedor configurado. Sin APK, instalación ni despliegue.

## Mapa y resumen compacto aprobados —20/10/2026

Implementada la propuesta visual aprobada por el usuario: mapa despejado sin
disco gris del radio, pines con silueta de ubicación/símbolo oficial y selección
negra/blanca. Panel45–90% con foto80×80, nombre/rasgos, flecha azul y Ver ficha
gris; tamaño/especie/fecha en vertical tras separador. Acabado azul extraído
a NavigationAccentSurface de core y compartido con navegación, sin duplicación
ni imports entre features. Ambos botones abren el detalle desde su origen real;
bloqueo durante navegación evita aperturas duplicadas. Créditos conservados bajo
cabecera, consulta/radio público intactos, sin SQL ni nuevas operaciones.
[ADR-103](decisiones/103-mapa-resumen-compacto-referencia-aprobada.md),
[ficha](funcionalidades/explorar.md). HU-07.2 / RF-13 / issue #33.

Validación: formato y git diff --check correctos; flutter analyze --no-pub sin
incidencias.43 pruebas aprobadas en serie de mapa, preview, Home, arquitectura,
selector de ubicación y Explorar con AMBIENT_BACKGROUND_MOTION=false. Incluyen
ambas acciones, coordenadas/consulta conservadas, reintento, permisos de lectura
por sesión, retorno, pines independientes y320×350/texto2. La ejecución inicial
se interrumpió por falta de memoria; las ejecuciones separadas finalizaron bien.
Capturas390×844 y320×350/texto2 revisadas: resumen/datos verticales legibles,
scroll al ampliar texto/altura reducida. Teselas neutras de fixture: no acredita
apariencia de cartografía remota. Siguiente paso: revisión visual en Android con
el proveedor configurado. Sin APK, instalación, despliegue ni cierre de historia.

## Panel del mapa con estado compartido —19/10/2026

Por petición del usuario, el panel de Explorar sin pin seleccionado reutiliza
CollectionEmptyState, como el vacío del listado: huella, título y descripción
centrados. Con resultados indica Selecciona un pin; sin resultados confirmados,
No encontramos casos. Conserva instrucciones específicas de ubicación/reintento,
resumen al seleccionar, panel desplazable y consulta compartida.
HU-07.2 / RF-13 / issue #33, sin cambio de alcance ni backend.

Validación: formato, flutter analyze --no-pub sin incidencias y15 pruebas de
mapa/arquitectura aprobadas con AMBIENT_BACKGROUND_MOTION=false. Capturas
390×844 y320×350/texto2 revisadas; en altura pequeña el contenido requiere
expandir/desplazar el panel. Teselas de fixture, sin validar cartografía remota.
Siguiente paso: revisión visual en Android físico; sin APK ni despliegue.

## Fondo móvil más tenue abajo —19/10/2026

Por instrucción del usuario, AppPageBackground conserva las luces del tercio
superior y atenúa progresivamente el celeste hasta casi blanco en navegación.
Velo dentro del painter, antes del contenido; movimiento y glass conservados.
[ADR-102](decisiones/102-fondo-mobile-atenuado-hacia-navegacion.md),
[ficha](funcionalidades/fondos-mobile.md). Sin HU/issue nuevo ni cambio de alcance.

Validación: formato correcto, flutter analyze sin incidencias y18 comprobaciones
aprobadas (fondo animado, Home, arquitectura y captura UI), con
AMBIENT_BACKGROUND_MOTION=false; el test de movimiento fuerza animate:true.
Renders de Inicio390×844 y320×350/texto2 regenerados y revisados: zona inferior
más blanca y cabecera conservada. git diff --check correcto.
Siguiente paso: revisión visual en Android físico; no se generó ni instaló APK.

## Mapa flotante en Explorar —19/10/2026

Por elección del usuario de la propuesta3 se retira Lista/Mapa. Mapa es una
cápsula con GlassSurface, icono y etiqueta, fija sobre la navegación con20px
de separación. Solo Explorar; carga/error inicial sin botón y busy bloqueado.
Router compone ExploreMapButton en el slot de Home, sin imports entre
presentaciones. Padding final200px más crecimiento de texto/inset permite
retirar la última tarjeta de debajo del botón. Mismo origen/retorno y consulta.
[ADR-101](decisiones/101-mapa-acceso-flotante-explorar.md),
[ficha](funcionalidades/explorar.md). HU-07.1/07.2, RF-13, issues #32/#33.

Validación:36 pruebas Home/Explorar/arquitectura/mapa aprobadas con
AMBIENT_BACKGROUND_MOTION=false. Normal/pequeño/texto2, scroll fijo y retorno,
sin consultas adicionales al abrir. Formato y análisis completo sin incidencias;
git diff --check correcto. Capturas390×844 y320×350/texto2 revisadas;
datos/fotos de fixture no acreditan backend remoto. En altura pequeña el botón
se superpone al contenido durante el scroll, como la navegación; el padding
final permite descubrir la última tarjeta/acción.
Siguiente paso: revisión física Android. Sin APK, instalación o despliegue.

## Explorar: fila compacta de ubicación y filtros —19/10/2026

Ubicación usa el ancho disponible con lugar/radio en línea; Filtrar casos es
un icono circular48×48 con tooltip y semántica, sin chevrón ni texto visible.
Fila48px a tamaño normal; texto ampliado puede aumentar Ubicación, sin reducir
fuente. Área táctil mínima48, paneles/animaciones/borradores/Aplicar conservados.
FilterExpansion reutiliza su variante compacta y SelectionPillSurface permite
omitir el padding exterior; otros selectores conservan sus valores por defecto.
[ADR-100](decisiones/100-explorar-controles-compactos.md),
[ficha](funcionalidades/explorar.md). Sin backend, permisos o alcance nuevos.

Validación:25 pruebas Explorar/arquitectura/navegación de mascotas aprobadas,
incluyendo dimensiones48px, texto2, descarte/Aplicar y consulta conservada.
Formato correcto y análisis completo sin incidencias. Capturas390×844 y
320×350/texto2 de listado/paneles revisadas; teselas de red no disponibles
en el entorno de pruebas, sin acreditar cartografía real.
Siguiente paso: revisión física Android. Sin APK/despliegue.

Corrección posterior19/10/2026 del usuario: Reportar (nueve puntos) vuelve
a su IconButton circular negro #111111 original, de64px y puntos blancos,
sin degradado, brillo ni sombra azul. El acabado de landing y sus efectos
se conservan únicamente en la selección activa de la barra.
Validación: formato, análisis completo y7 pruebas de Home aprobados.
Pendiente revisión visual Android.

## Mapa: especie, foto mayor y pines individuales —19/10/2026

Corrección explícita del usuario: tipo de mascota en lugar de raza; foto4:3
a ancho completo en lugar de altura136px; retirar Abierto/Resuelto y conteo de
casos/ubicaciones del panel. Cada caso tiene su pin, con separación en píxeles
ante solapamientos y sin contador/selector1 de2. La cámara recalcula la posición
visual con zoom/giro; no se alteran coordenadas públicas, filtros o radio.
Ver ficha y resumen seleccionados por identidad compuesta; se conservan carga,
reintento, paginación, retorno y panel accesible. ADR-099; sin SQL, permisos o
activación remota nuevos; HU-07.1/07.2, RF-13, issues #32/#33.

Validación:22 pruebas de mapa/preview público/arquitectura/ZoneMapPicker aprobadas
con AMBIENT_BACKGROUND_MOTION=false; giro45°, zoom12/18, coincidencias exactas,
cercanía, objetivos táctiles separados, apertura individual y especie/fallback.
Análisis completo limpio y formato correcto. Capturas390×844 y320×350/texto2
con movimiento reducido y panel expandido revisadas con fotos/teselas de fixture.
No equivalen a evidencia remota. Siguiente paso: revisar el ajuste en Android
con datos reales y concentración elevada de casos; sin APK ni despliegue nuevos.

## Navegación móvil con acabado de landing —19/10/2026

La opción activa y Reportar de LiquidNavigation usan el degradado azul, brillo
superior, sombras y efectos de Iniciar sesión de landing. Hover/foco/pulsación:
elevación2px y oscurecimiento3% en200ms; movimiento reducido sin elevación ni
transición. Mantiene glass exterior, destinos, tamaños y deslizamiento320ms.
Trabajo previo conservado. [ADR-098](decisiones/098-navegacion-mobile-acabado-boton-landing.md),
[ficha](funcionalidades/inicio.md).

Validación:16 comprobaciones existentes de Home/arquitectura aprobadas con
AMBIENT_BACKGROUND_MOTION=false; formato y flutter analyze sin incidencias.
Capturas390/320px con texto2 en tamaño pequeño revisadas, sombras habilitadas.
Siguiente paso: revisión visual/táctil en Android. Sin APK, instalación ni
despliegue; sin cambios de producto/backend ni cierre de historias.

## Filtros solo en Explorar y resumen inferior del mapa —19/10/2026

Por aprobación del usuario, Mapa retira el editor/Aplicar filtros y muestra el
resumen público del pin seleccionado con Ver ficha. Filtrar casos/Ubicación
permanecen en Explorar. Sin callout duplicado; coincidencias anterior/siguiente,
panel42–90%, retorno glass, carga/reintento, paginación y filtros conservados.
El preview usa scroll exterior; CTA fijo cuando cabe, por scroll en altura
reducida/texto2. No cambia SQL, permisos ni dominio. ADR-097; HU-07.1/07.2,
RF-13, issues #32/#33, sin cambios de estado en GitHub ni despliegue.

Validación: formato, flutter analyze --no-pub completo sin incidencias y19
pruebas focalizadas mapa/preview/arquitectura aprobadas. Verifican filtros no
predeterminados compartidos, ausencia de editor, selección, Ver ficha, refresh,
paginación/retorno, coincidencias y accesibilidad en390×844 y320×350/texto2 con
movimiento reducido. Capturas con fixture revisadas en build/ui-preview/explore-map.
La espera de pruebas avanza frames acotados porque AppPageBackground tiene
animación continua; no se espera a que todos sus tickers queden inactivos.
Siguiente paso: revisar el nuevo recorrido en Android con datos reales. Sin
APK, instalación ni confirmación remota nueva; trabajo local anterior conservado.

## Toast móvil igual al web, con descarte por gesto —19/10/2026

ConfirmationToastHost compartido adopta texto14/peso400, acción subrayada,
entrada desde fuera del viewport480ms, retorno420ms y salida superior240ms.
Sigue el dedo/ratón; descarta hacia arriba y retorna con gesto corto/cancelado,
con resistencia hacia abajo. Texto extenso conserva scroll y gesto en el icono.
6500ms como web, pausados al sostener. Mantiene toque/teclado/Escape, semántica,
reintento y exclusión de hosts anidados. Reemplazo durante arrastre libera el
aviso anterior e impide timers/callbacks tardíos. Movimiento reducido conservado.

Validación:33 comprobaciones de toast/arquitectura/preferencias/avatar/harness
y54 de consumidores (perdidos/encontrados, validación/salida del editor de mascotas,
carteles y Explorar) aprobadas con AMBIENT_BACKGROUND_MOTION=false; movimiento
del toast activo. Formato verificado, flutter analyze sin incidencias y
git diff --check aprobado. Capturas390×844/320×350/texto2 y entrada/arrastre/retorno en
apps/mobile/build/ui-preview/mobile-toast revisadas. Suite general no completada:
timeouts con fondo continuo, límite de hilos/memoria y fallos observados en
origin_page_transition_test ajenos al toast. No se declara suite global verde.
Sin APK/instalación/despliegue ni cambios de datos/permisos. Siguiente paso:
revisión del gesto en dispositivo Android/iPhone y resolver la regresión global
de transiciones en su propio incremento. [ADR-096](decisiones/096-toast-mobile-igual-web.md),
[ficha](funcionalidades/toast-mobile.md).

## Títulos de sección móvil en peso500 —19/10/2026

Por petición explícita del usuario, CollectionHeader pasa de700 a500 como el
título de Inicio web: Explorar, Mis mascotas y listados de casos/reportes que
reutilizan la cabecera. Fallback de Home ajustado al mismo peso. Tamaño32,
color, adaptación y operaciones conservados. Fichas y regla visual actualizadas.

Formato correcto y análisis focalizado de los dos archivos sin incidencias.
El análisis completo y la ejecución conjunta de Home/Explorar/Mascotas/listados
se interrumpieron por falta de memoria de Dart. Reintento secuencial de listados
no valida el cambio: pumpAndSettle agota su espera. Sin nuevas pruebas añadidas.
Siguiente paso: revisión visual en Android y repetir suite con entorno estable;
sin APK ni instalación nueva, ni cierre de historias.

## Restaurar stagger suave de Inicio —19/10/2026

El usuario rechaza el recorte progresivo de094. Se recuperan fade y desplazamiento
de28px con el mismo timeline/curva850ms/90ms del stagger; preserveBackdrop solo
excluye ImageFiltered de entrada sobre el glass. Superficie/contenido aparecen
juntos, sin panel vacío ni barrido. GlassSurface parametriza backdropBlendMode;
las tarjetas de Inicio usan src para su capa de opacidad; otros usos conservados.
Una entrada sin cover permanece en Inicio/Explorar. ADR-095; sin cambios de
contenido, consultas, permisos, SQL o historias.

Formato correcto,34 regresiones aprobadas y análisis sin incidencias. Verifican
entrada conjunta, desplazamiento sin cambio de tamaño, resultado estable y
única entrada de Explorar. Siguiente paso: verificar sensación en Android con
el usuario. Sin APK/instalación ni revisión física nueva.

## Corrección de doble entrada en Inicio y Explorar —19/10/2026

Por capturas del usuario se retira el cover previo a stagger en estas dos
secciones. Inicio conserva cuatro grupos; Home no añade entrada activa sobre
Explorar/Mascotas reales. Explorar usa una sola línea temporal para skeleton y
datos sin reiniciar al completar consulta. Las tarjetas glass se revelan junto
al contenido mediante preserveBackdrop/ClipRect, sin blur/opacidad del material
ni paneles vacíos al principio. Glass final, cabecera/navegación y movimiento
reducido conservados. ADR-094 sustituye esta parte de093; sin cambios de otras
pantallas, datos, consultas, permisos, SQL, HU/issue nuevos o cierre de historias.

Validación:34 pruebas de glass/Inicio/Explorar/stagger/arquitectura aprobadas.
Regresión visual confirma tarjeta inicialmente oculta, ribete revelado idéntico
al final y acción Mis mascotas;90 frames de Explorar con un stagger, cero covers,
una consulta y misma instancia de skeleton, con/sin movimiento reducido. Fondo
ambiental fijado para regresiones. Formato correcto y análisis sin incidencias.
Sin APK ni
ejecución Android nueva; siguiente paso: verificar entrada en dispositivo.

## Glass estable al entrar e ilustración de reunión en Inicio —19/10/2026

Por capturas del usuario, se retira GlassSurface del efecto ImageFiltered/Opacity
de entrada: la superficie principal envuelve ahora el stagger de su contenido.
Conserva material/radio26/padding22/acción. El fondo animado sigue reflejándose,
sin aplicar un acabado temporal distinto al glass. HomeReunionCard añade el PNG
original de platform/images/landing/reunion.png en card glass3:2, sin recorte,
con etiqueta accesible y sin acción ficticia. Copia verificada por SHA256 idéntico.
Ubicada entre accesos rápidos y Cerca de ti; cuatro grupos de entrada. Sin cambios
web, datos, permisos, SQL, HU/issue nuevos ni cierre de historias. ADR-093.

Validación:18 comprobaciones aprobadas de Inicio/arquitectura/harness y regresión
visual nueva que compara píxeles del ribete y geometría durante/final de entrada,
asset presente y acción Mis mascotas conservada. Análisis sin incidencias.
Harness actualizado repetido y aprobado; home.png y home_reunion.png revisadas,
con las mascotas completas, fondo transparente y sin recorte. Capturas pequeñas
con texto2 del mismo harness conservadas sin overflow. Formato/análisis finales
sin incidencias. Sin instalación/APK
ni revisión Android nueva. Siguiente paso: inspección visual del nuevo card y
revisión del usuario tras reiniciar para incorporar el asset.

## Lettering móvil igual al de la web —19/10/2026

Por petición explícita, BrandWordmark y StartupReveal comparten BrandName con
lettering «entre huellas»: contornos de Arial regular equivalentes al peso500
disponible en web, #171918, tracking−.05em y dos líneas para el layout móvil.
Gap7px compacto/16px grande. Icono oficial verificado idéntico por SHA256 entre
app_icon.png y /brand.png. Se retira sans-serif800/mayúsculas de ambas variantes.
SVG de paths sin fuente instalada/remota; script local de exportación añadido,
sin dependencias runtime nuevas. Tamaño gráfico explícito y etiqueta accesible
conservados; cuerpo de textos y ampliación ajenos a la marca no cambian.
ADR-092, reglas, diseño y ficha identidad-visual actualizados. Sin cambios web,
launcher, dominio, datos, permisos o nuevas HU/issue/cierres.

Validación:30 comprobaciones de arranque/Inicio/app/onboarding/arquitectura y
harness visual aprobadas. Formato correcto y análisis sin incidencias. Capturas
acceso/Inicio normal/pequeño revisadas en apps/mobile/build/ui-preview. Se ajustó
la geometría gráfica para evitar overflow de onboarding en320×350/texto2.
Sin nueva instalación Android; siguiente paso: revisar capturas y abrir la app
con asset nuevo tras detener/iniciar. No se genera APK ni se despliega.

## Hover glass web con mayor presencia —19/10/2026

El usuario considera casi imperceptible el primer hover. Se refuerza el borde
a#8FA9C4, el ribete interior de1 a2px y el reflejo blanco/azul. Sin halo exterior,
cambios de tamaño o alteración de foco/error/táctil/disabled/readonly.
ADR-090, regla web y ficha de acceso actualizadas con la corrección.

Validación: build .nuxt-input-hover correcto; QA Chrome fixture verifica nueva
intensidad/borde, geometría estable y estados anteriores conservados. Captura
hover-desktop.png en apps/mobile/build/ui-preview/web-input-hover regenerada y
revisada. Sin errores JavaScript; git diff --check correcto. Sin despliegue.
Siguiente paso: revisión visual del usuario sobre la intensidad actual.

## Nubes móviles en toda la altura y tarjeta glass —19/10/2026

Por nueva referencia del usuario, «Su regreso empieza contigo» usa GlassSurface
compartido/radio26 en lugar de gris opaco, conservando padding22, textos y acción.
AppPageBackground distribuye cinco nubes azules por todo el viewport y las mueve
con trayectorias suaves cerradas de24s. Pintura aislada por RepaintBoundary sin
reconstruir contenido; controlador pausado con movimiento reducido/TickerMode y
liberado al desmontar. Conserva insets/scroll/teclado y capas de transición.
ADR-091 sustituye distribución estática de ADR-088. Sin cambios de web, datos,
permisos, SQL, HU/RF/issue nuevos ni cierre de historias.

Validación:30 comprobaciones aprobadas de Inicio/arranque/reveal/arquitectura,
harness visual y test nuevo significativo de movimiento real de píxeles, contenido
sin rebuild, pausa/reanudación y liberación. Regresiones/capturas fijan solo la
animación ambiental mediante AMBIENT_BACKGROUND_MOTION=false; el test nuevo
fuerza animate:true. Comando CI/README actualizados, sin ejecución remota de CI.
Análisis sin incidencias; capturas390×844 y320×350/texto2 revisadas en
apps/mobile/build/ui-preview (home.png muestra tarjeta glass y fondo completo).
Sin nueva ejecución Android/APK. Pendiente revisar fluidez/coste del blur y
sensación del movimiento en dispositivo; renders no acreditan ese rendimiento.
Siguiente paso: revisión visual del usuario con ejecución móvil actualizada.
[Ficha](funcionalidades/fondos-mobile.md), [ADR-091](decisiones/091-nubes-mobile-animadas-y-tarjeta-glass.md).

## Hover glass fino en campos web —19/10/2026

Por petición del usuario, los campos compartidos de reader-shell tienen hover
con borde tenue#CAD6E3, reflejo blanco/azulado y luz inset1px, sin halo exterior.
Solo puntero fino con hover y campos habilitados/editables sin foco ni error;
foco interior/errores conservados. Sin cambios de geometría/padding/fondo base.
Transición180ms de borde/sombra; movimiento reducido elimina transición.
Landing, controles checkbox/radio/range/file y dispositivos táctiles conservados.
[ADR-090](decisiones/090-hover-glass-interior-campos-web.md), regla/ficha actualizadas.

Validación: build Nuxt aprobado (.nuxt-input-hover); Chrome de producción con
fixture verifica hover/borde/reflejo interior, geometría idéntica, prioridad de
foco/error, exclusión disabled/readonly y ausencia de hover en contexto táctil.
Movimiento reducido comprobado; sin errores JavaScript. Captura escritorio
revisada en apps/mobile/build/ui-preview/web-input-hover/hover-desktop.png.
git diff --check correcto. Sin tests permanentes nuevos para este ajuste CSS.
Sin SQL, Flutter, operaciones remotas, despliegue o cierre de HU. Siguiente paso:
revisión visual del usuario sobre la intensidad del reflejo.

## Foco interior en campos web —19/10/2026

Por referencia explícita del usuario, el contorno de foco de los campos crece
hacia dentro: outline2px con offset−2px, sin aro exterior ni cambios de geometría.
Regla compartida en reader-shell para inputs de texto, textarea y select;
retirados overrides exteriores de acceso, moderación y avistamientos. Se mantiene
azul#3C537B y rojo#B53F48 cuando aria-invalid=true. :where evita que las exclusiones
de tipos ganen especificidad al estado de error. Botones/enlaces, controles
checkbox/radio/range/file y landing conservan su foco. Sin cambios de negocio.
[ADR-089](decisiones/089-foco-interior-inputs-web.md), regla web y ficha actualizadas.

Validación local: build Nuxt correcto (.nuxt-input-focus); QA Chrome de producción
con fixture a1440/390 verifica foco interior2px por clic/teclado, geometría y
padding idénticos antes/después, error rojo y herencia en login/registro/moderación.
Sin errores JavaScript. Captura móvil revisada en apps/mobile/build/ui-preview/
web-input-focus/login-focus-390.png. git diff --check correcto. Avistamientos
verificado por retirada del override y herencia CSS; sin envío real nuevo.
Sin SQL, Flutter, despliegue ni cambios de Auth/SMTP. Siguiente paso: revisión
visual del usuario sobre el foco interior.

## Corrección del fondo móvil según referencia —19/10/2026

El usuario rechaza el degradado vertical y aporta referencia de pantallas de
envíos. AppPageBackground ahora pinta blanco con nubes azules difuminadas arriba,
aperturas blancas y reflejo frío tenue inferior izquierdo. Radiales proporcionales
al viewport, estáticos y sin dependencia/bitmap. Alcance compartido y superficies
conservados; CoverReveal y OriginPageTransition reutilizan el nuevo fondo.
ADR-088 sustituye la paleta de ADR-086; web/landing conservadas. Sin operaciones,
permisos, SQL, HU/issue nuevos ni cierre de historias.

Validación:22 comprobaciones existentes de arranque/reveal/arquitectura y harness
visual aprobadas. Capturas acceso/onboarding/Inicio/perfil revisadas en
apps/mobile/build/ui-preview, con390×844 y320×350/texto2. Formato correcto y
análisis final sin incidencias.
Sin instalación ni revisión Android de este ajuste; render local no certifica
identidad exacta con la captura ni aprobación del usuario. Siguiente paso:
revisar el fondo en su ejecución móvil actualizada.
[Ficha](funcionalidades/fondos-mobile.md), [ADR-088](decisiones/088-fondo-mobile-nubes-azules-referencia.md).

## Registro, verificación y recuperación web completos en local —19/10/2026

Por autorización del usuario se trasladan los recorridos de acceso móvil a web:
Crear cuenta (nombre/correo/contraseña/confirmación), código6 con reenvío60s,
recuperar acceso por código y guardar nueva contraseña. Enlaces reales en login;
/crear-cuenta y /recuperar-contrasena con política guest, /restablecer-contrasena
con recovery en la política única SSR/cliente. Registro confirmado entra al
onboarding por cuenta; autoconfirmación Auth también compatible. Misma cuenta,
full_name y perfil existentes, sin autoasignar roles.

CredentialScreen observa CredentialViewModel y casos de uso concretos;
HTTP/Auth tras repositorios/fuentes por petición. Recuperación usa cookie cifrada
HttpOnly eh_credentials con propósito/AAD propio, id/espera/vencimiento y token
solo en servidor/cookie. Nunca establece eh_access al verificar recovery;
API general/moderación y páginas de cuenta siguen inaccesibles con esa capacidad.
Reset revalida identidad y vencimiento antes de PUT Auth. Progreso sin tokens
en JSON y sin datos de usuario en SSR. Pendiente máximo30min, reset máximo10min
limitado por JWT; no se afirma el vencimiento remoto del código. Cancelar/confirmar
retiran cookie; login/logout/OAuth confirmado limpian flujos anteriores. Conflicto
de pestaña no borra el flujo nuevo. Sin reintentos automáticos de escrituras.

UI mantiene fondo/orbe, marca responsive compartida, retorno glass sobre scroll,
StaggerReveal, skeleton, shimmer de acciones y toast superior/invalid/shake.
Recargar restaura etapa; falla de red conserva datos y permite reintentar.
Mensajes de registro/recuperación no confirman existencia del correo.

Validación local: typecheck y build Nuxt con .nuxt-credentials;54 pruebas unitarias/
arquitectura y26 de servidor aprobadas (8 unitarias y5 de producción nuevas).
Chrome fixture prueba registro inválido/coincidencia, código rechazado y correcto,
restauración al recargar, llegada a onboarding; recuperación, nueva contraseña,
fallo/reintento de guardado, éxito y login con nueva clave, cancelación, bloqueo
de dobles envíos/shimmer y reset protegido SSR/SPA sin montar campos sin capacidad.
18 capturas en apps/mobile/build/ui-preview/web-credentials a1440/390/320 con
texto200%; revisados registro móvil y reset pequeño con texto ampliado. Sin
overflow/CSP/hidratación/JavaScript. QA Chrome de acceso anterior también aprobado:
Google/Facebook PKCE fixture, cuenta/revisión, permisos/revocación, expiración,
onboarding, logout entre pestañas y responsive1920/1440/731/390/320/texto200%.
git diff --check correcto.

Documentados [ADR-087](decisiones/087-registro-y-recuperacion-web.md), reglas,
arquitectura, guía, ficha/índice de acceso y desarrollo. Incremento HU-01/RF-01,34,
sin nueva HU/issue ni cierre de historia. Sin SQL, cambios de Flutter propios de
este incremento, variables nuevas, modificación Auth/SMTP remota o publicación.
Trabajo paralelo móvil conservado. No acredita paridad global de funcionalidades.

Pendiente demo con correo real y configuración efectiva de Auth: registro/correo
habilitados, OTP6, SMTP y plantillas existentes con .Token. Ningún correo real
enviado en las pruebas. Una respuesta perdida tras consumir código o actualizar
clave puede requerir volver al login/reenvío; no se promete rollback ni revocación
inmediata de JWT al cerrar localmente. Sin bloqueo de implementación local.
Siguiente paso: probar ambos correos y el acceso final con una cuenta de desarrollo.

## Fondo móvil con la regla de la web interior —19/10/2026

Por instrucción del usuario se sustituye el fondo blanco exterior móvil por
#E5EFFF → #F5F7FA55% → #FFFFFF. AppPageBackground/AppScaffold compartidos cubren
las12 composiciones existentes de Scaffold: arranque Flutter, preparación de
cuenta, acceso/registro/contraseña, onboarding, Inicio, perfil, preferencias,
ubicaciones, EntityScreenShell y mapa inmersivo cuando no lo cubre la cartografía.
Fondo fuera de áreas seguras y del ajuste de teclado; scroll conserva viewport.
CoverReveal y expansión desde origen usan paleta compartida. Campos, tarjetas,
fotos, mapas, paneles y splash nativo conservados. Sin orbes nuevos, SQL, dominio,
datos, permisos o cambios web. ADR-086, reglas y ficha fondos-mobile actualizados;
sin nueva HU/issue ni cierre de historias.

Validación:53 pruebas existentes focalizadas de acceso/Inicio/app/onboarding/
arranque/transiciones/creación de reportes/arquitectura aprobadas, más1 harness
visual aprobado (54 en total). Formato de lib y harness correcto; análisis sin
incidencias. Capturas de acceso, onboarding, Inicio y perfil revisadas en
apps/mobile/build/ui-preview, incluyendo320×350/texto2 y390×844. El harness
se actualiza para usar el retorno Volver real del reporte y simular path_provider;
sin modificar navegación de producto. Sin pruebas nuevas de negocio.
Emulador Android detectado al cierre; no se instaló/adjuntó una ejecución ni se
generó APK. La evidencia es Flutter test/render local, sin backend real.
Siguiente paso: revisar el fondo en la ejecución Android actualizada del usuario.
[Ficha](funcionalidades/fondos-mobile.md), [ADR-086](decisiones/086-fondo-mobile-compartido-frio.md).

## Marca grande en login responsive —19/10/2026

Por captura explícita del usuario, login hasta600px reutiliza SiteHeader/SiteBrand
con logo76px, texto2rem en dos líneas, gap16px y padding superior52px/lateral24px.
El título queda32px debajo de la cabecera; se retira el centrado vertical móvil.
Excepción local a ADR-076/077: marca fuera del formulario/stagger, escritorio
y otros recorridos conservados. Fondo frío y orbe sin cambios. Ancho min-content
del texto permite ampliación sin overflow. [ADR-085](decisiones/085-marca-responsive-login.md),
regla web y ficha de acceso actualizadas; incremento visual HU-01 sin cierre.

Validación local: typecheck y build Nuxt correctos (.nuxt-login-responsive).
QA Chrome de marca compartida actualizado para la excepción móvil y aprobado
en1440/731/601/600/390/320 y texto200%, incluyendo acceso, bienvenida, inicio,
moderación, QR, legales y landing como referencia; sin overflow/CSP/hidratación.
Comprobación adicional con animación activa confirma geometría de marca estable
desde SSR, durante hidratación y recarga en320/390/600/601/1440. Capturas revisadas
en apps/mobile/build/ui-preview/web-brand/login-reference-390.png y
login-320-enlarged.png. git diff --check aprobado. Backend fixture local;
sin SQL, Flutter, publicación o cambios de autenticación. Sin bloqueo local.
Siguiente paso: revisión visual del usuario en su dispositivo.

## Cartografía móvil clara con Positron —19/10/2026

Por solicitud del usuario se activa CARTO Positron desde MAP_TILE_URL local,
conservando flutter_map y los pines del logo. Clave existente comprobada sin
imprimirla ni versionarla: descarga HTTPS200/image/png de una tesela real de Lima,
inspeccionada visualmente. ZoneMapPicker incorpora crédito discreto superior con
enlaces separados OpenStreetMap/CARTO, texto adaptable, separación del retorno y
reintento debajo. Fallo al abrir enlaces usa toast compartido. La confirmación del
usuario tras configurar la clave autoriza el crédito: ADR-084 sustituye ADR-054
solo en estos mapas; buscador y web conservados. Sin SQL, permisos o consultas
nuevas, ni cambios a coordenadas, pines o historial de HU-07/RF-13.

Validación: formato correcto,14 pruebas existentes de mapa/selección/reintento/
navegación y arquitectura aprobadas con URL CARTO sin clave y teselas simuladas.
Renders390×844 y320×350/texto2 revisados; corregida una intercepción del pin por
el crédito en tamaño pequeño. No acreditan cartografía real dentro de Flutter.
Análisis estático final sin incidencias.
Sin Android conectado (flutter devices solo muestra
Windows/Chrome/Edge); pendiente comprobar el estilo dentro de Android tras un
reinicio completo con dart-defines locales. No se genera APK ni se despliega.
Siguiente paso: revisión en dispositivo de Explorar y selección de ubicación.
[Ficha](funcionalidades/cartografia-mobile.md), [ADR-084](decisiones/084-mapa-mobile-claro-carto-positron.md).

## Fondo web frío fuera de landing —19/10/2026

Por instrucción del usuario y referencia aportada, el fondo exterior compartido
usa azul pastel #E5EFFF → gris frío #F5F7FA al55% → blanco #FFFFFF, sin amarillo.
WebShell declara la base; AmbientPageShell y LegalPage dejan de sobrescribirla.
Aplicado a acceso, bienvenida, inicio, moderación, legales, QR y avistamientos
por su shell compartido. BackgroundGlowOrb conserva colores, intensidad,
animaciones, máscaras y movimiento reducido. Landing conserva su CSS/fondos
propios; no se modifican superficies de tarjetas, campos, fotos o mapas.
[ADR-083](decisiones/083-fondo-web-frio-fuera-de-landing.md),
[ficha](funcionalidades/fondos-web.md) y regla web actualizadas.

Validación local: typecheck y build Nuxt correctos con NUXT_BUILD_DIR aislado
.nuxt-background;46 pruebas existentes aprobadas; git diff --check correcto.
Chrome de producción con backend fixture comprobó el mismo degradado calculado
en login/bienvenida/inicio/moderación/términos/privacidad/QR a1440×1000 y390×844,
sin overflow horizontal ni errores CSP/hidratación/JavaScript.14 capturas en
apps/mobile/build/ui-preview/web-background; revisados visualmente login móvil
y moderación escritorio. Colores del orbe verificados y fondo crema de landing
conservado. No se añaden tests permanentes para este ajuste CSS reversible.

Sin bloqueo local, SQL, Flutter, despliegue o cierre de historias. La revisión
de avistamientos se limita a su herencia del WebShell, sin envío nuevo.
Siguiente paso: revisión visual del usuario; no acredita publicación remota.

## Avisos web de una sola vez y URL limpia —19/10/2026

Por autorización del usuario, login consume los motivos signed-out, expired,
forbidden, oauth-failed y oauth-cancelled; inicio consume forbidden. Tras comprobar
la sesión se reemplaza la entrada actual del router, retirando solo reason
reconocido y mostrando el toast compartido. Recargar o volver desde legales no
repite el aviso consumido. Parámetros ajenos (incluidos repetidos) y fragmento
se conservan; el guard también conserva el fragmento al retirar entry=checked.
No cambia autorización, callbacks OAuth, política SSR ni comprobación por operación.
Los parámetros desconocidos no se interpretan como avisos. La limpieza requiere
JavaScript; en SSR se mantiene el transporte existente hasta la hidratación.
Sin SQL, Flutter, variables nuevas, despliegue ni cierre de HU-01/HU-14.3.

Validación local: typecheck y build de Nuxt correctos;46 pruebas unitarias/
arquitectura y21 de servidor aprobadas. Chrome sobre build de producción y backend
fixture verifica los cinco motivos, alias /login, URL limpia sin entrada adicional
en historial, parámetros repetidos/fragmento, navegación sobre la misma pantalla,
recarga/volver, cierre de cuenta/moderación y denegación SSR/SPA sin montar revisión.
Sin errores CSP/hidratación. No se usaron cuentas remotas ni se publicó.
Siguiente paso: comprobar el recorrido con la configuración real antes de publicar.



## Cierre de sesión web sin espera de Supabase —19/10/2026

El usuario autoriza corregir la demora al cerrar sesión. Ambos endpoints web
preparaban el borrado de cookies pero esperaban hasta5s a Supabase antes de
enviar la respuesta. Ahora /api/access/logout y /api/moderation/logout borran
eh_access en / y /api y eh_moderation, registran el caso de uso remoto con
event.waitUntil de Nitro y responden {signedOut:true} sin esperar esa red.
La confirmación acredita cierre local; si falta configuración remota también
se borran cookies. Controles de origen/método siguen activos y rechazos no
envían headers de borrado. Dominio/repositorios/fuentes conservan timeout5s,
scope local y semántica remota; sin promesa suelta ni worker/servicio nuevo.
Cliente conserva limpieza de datos, invalidación de preparación, avisos entre
pestañas y espera la respuesta HTTP de borrado antes de salir al login.
[ADR-082](decisiones/082-cierre-web-sin-esperar-supabase.md), reglas, arquitectura,
fichas y guía de desarrollo actualizadas. Misma HU-01/HU-14.3, sin cierre de HU.

Validación local: typecheck/build aislado .nuxt-logout aprobados,46 pruebas
unitarias/arquitectura y21 de servidor aprobadas. Nuevos tests retienen el logout
de Supabase y reciben200/cookies borradas antes de liberar ese trabajo en ambos
endpoints; cubren configuración ausente y rechazo cross-origin. Chrome de política
global también llega al login desde cuenta y moderación mientras Supabase sigue
retenido (límite2s), con cookies/datos privados retirados, recarga posterior sin
sesión y sin errores CSP/hidratación. Suite Chrome de moderación completa aprobada.
Suite Chrome de acceso completa aprobada: logout entre pestañas, caducidad,
onboarding, recuperación de conexión/permisos, OAuth fixture y responsive/texto200%.
git diff --check aprobado. Evidencia con backend fixture, no medición remota.

Sin SQL, Flutter, cambios de variables ni despliegue. Sin bloqueo local.
El intento remoto depende del proceso/timeout y no es entrega duradera frente
a reinicios; JWT emitidos conservan su vencimiento anterior y no se cierran
sesiones móviles. La salida aún requiere red al servidor web. Siguiente paso:
comprobar la sensación de cierre en el navegador real del usuario.

## Toast web con entrada superior y descarte por gesto —19/10/2026

TopToast compartido baja desde fuera del viewport y permite arrastrar hacia
arriba con dedo/ratón para descartarlo. Gesto corto/cancelado vuelve a posición;
hacia abajo ofrece resistencia. Entrada480ms, retorno420ms y salida240ms,
sin transiciones con movimiento reducido. Mantiene toque, teclado/Escape,
roles, reintento y expiración6500ms (pausada al sostener); arrastrar no dispara
callbacks. Capturas y QA de producción con fixture:1920/1440/731/390/320 y
texto200%, ratón/touch CDP, entrada, retorno/cancelación, reintento, teclado,
expiración y movimiento reducido, sin overflow horizontal/CSP/hidratación.
typecheck, build (NUXT_BUILD_DIR=.nuxt-toast para conservar dev activo) y46
pruebas aprobados. Render320/texto200% revisado. Sin despliegue ni cambios
remotos. Siguiente paso: comprobar sensación del gesto en Safari/iPhone físico.
[ADR-081](decisiones/081-toast-web-deslizable.md), [ficha](funcionalidades/toast-web.md).

## Acceso preparado desde landing, sin repetir la consulta al clic —19/10/2026

Por autorización del usuario se sustituye la solución de solo feedback por
preparación previa. Landing consulta mediante AccountViewModel/AccessAccount
en segundo plano y precarga los componentes del destino. Iniciar sesión apunta
a /inicio, /bienvenida o /iniciar-sesion antes del clic. AccountSessionTransport
en data agrupa lecturas y reutiliza la respuesta para middleware/pantalla dentro
de la misma app cliente, máximo15s/expiración (401 confirmado máximo5s). Sin
singleton de servidor, datos privados SSR, almacenamiento persistente o permisos
cacheados. Bootstrap lo inyecta también a moderación para invalidar su logout.

La landing visible actualiza cada10s, foco/visibilidad y mensajes entre pestañas;
se liberan timers/listeners/canal al salir. Mutaciones invalidan antes y después,
401/409 y eventos de identidad descartan la preparación. Las respuestas anteriores
en vuelo se rechazan; el guard vuelve a comprobar una sola vez si hubo conflicto
por broadcast, resolviendo una carrera observada al cerrar sesión. Operaciones
y permisos siguen autorizándose en servidor. Si se pulsa antes de preparar,
caducó o falla la conexión puede haber espera real, con feedback existente.
[ADR-080](decisiones/080-preparar-acceso-desde-landing.md), reglas, arquitectura,
guía de desarrollo y fichas actualizadas; misma HU-01/RF-01,34, sin cierre.

Validación local: typecheck y build aislado aprobados;46 pruebas unitarias y
arquitectónicas y19 de servidor aprobadas. Nuevas pruebas cubren deduplicación,
TTL/vencimiento,401/fallos, aislamiento por app y carreras con cambios de cuenta.
Chrome global comprueba que preparación/guard/llegada comparten una consulta
si el clic es temprano. Con href preparado bloquea nuevas consultas de sesión
y exige llegar a /inicio o /bienvenida con datos correctos: cero consultas nuevas
de sesión durante el salto. Comprueba además que un broadcast tras logout
descarta el destino anterior y lleva al login sin montar cuenta.

Suites Chrome de acceso y moderación completas aprobadas (caducidad, pestañas,
logout, onboarding/reintento, permisos/revocación, operaciones/evidencia/OAuth
fixture). Landing completa aprobada: responsive/texto200%, navegación SPA/QR,
SSR sin JS y marca/estilos sin cambios, sin overflow ni errores CSP/hidratación.
El401 de preparación anónima es esperado en QA de landing. git diff --check pasa.

Sin bloqueos locales; evidencia de backend fixture, no medición de latencia
remota. Sin SQL, Flutter, variables o despliegue. Siguiente paso: revisar el clic
desde landing con la sesión real del usuario y desplegar solo si se autoriza.

## Navegación con feedback inmediato durante la comprobación —19/10/2026

El usuario detecta que Iniciar sesión parece no responder desde landing mientras
el middleware global espera la API y resuelve /inicio. Vue Router mantiene la
página actual hasta resolver el destino; faltaba feedback de trabajo en el enlace.
NavigationLink compartido conserva href, texto, clases y navegación nativa,
muestra el shimmer existente con aria-busy inmediatamente y bloquea clic repetido
hasta resolver navegación/redirecciones. finally limpia al terminar/fallar;
movimiento reducido usa brillo estático. Landing, cuenta, acceso, legales y
moderación reutilizan el componente. No elimina la latencia del backend ni
introduce caché de sesión/permisos o una pantalla intermedia. Marca sin cambios.

Validación: typecheck, build y43 pruebas unitarias/arquitectura aprobadas.
Chrome de política global aprobado con respuesta retenida: feedback visible
antes de responder, mismo texto, doble clic sin consulta adicional y llegada a
/inicio sin login intermedio. Recorre inventario SSR/SPA, cookie anterior, permisos,
logout, conexión503, enlace externo y sin JS; sin errores CSP/hidratación.
Suite Chrome de acceso completa aprobada también: onboarding, permisos,
caducidad, pestañas, OAuth fixture y responsive/texto200% sin overflow.
Sin SQL, Flutter, variables ni despliegue. Backend fixture; siguiente paso:
revisar la respuesta visual al clic en la sesión real del usuario.

## Puente de acceso bloqueado al llegar desde otro sitio —19/10/2026

La captura del usuario muestra JSON forbidden en /api/access/entry al entrar a
/inicio. Causa reproducida: Fetch Metadata conserva cross-site a través de las
redirecciones y el filtro general API rechazaba el puente. Las pruebas previas
cubrían navegación directa/SPA pero no un enlace desde otro sitio.
security permite exclusivamente GET/HEAD navigate/document en ese endpoint de
redirección interna, sin relajar cookies Strict ni autorización. Fetch/XHR,
iframes, escrituras y otras API conservan rechazo cross-site. ADR-079 y ficha
de acceso actualizados. No cambia la política global de las páginas.

Validación: typecheck y build aprobados;19 pruebas de servidor aprobadas, con
headers reales mediante HTTP (Node fetch sobrescribe Sec-Fetch-Mode). Chrome
recorre un enlace desde un origen externo antes del inventario completo SSR/SPA:
llega al login sin forbidden, sin pantallas privadas/skeleton y sin errores
CSP/hidratación. Sin SQL, Flutter, variables ni despliegue. Backend fixture;
siguiente paso: volver a abrir /inicio en el navegador del usuario.

## Política global de acceso en todas las rutas —19/10/2026

Por corrección explícita del usuario, el acceso se aplica a toda la navegación
mediante route_policy compartida, session-entry de servidor y access.global.
Se retiran account-access, guest-access y moderation-access y su selección desde
las páginas. Toda página/alias debe declarar su política: pages:extend rechaza
omisiones en Nuxt y la comprobación arquitectónica contrasta el inventario real.
Clasificación única de públicas, acceso, cuenta, onboarding y revisión con permiso.
Sin sesión no se renderiza/monta ninguna ruta protegida ni su skeleton antes
del login; el permiso de moderación también se consulta antes del HTML/montaje.
Landing, legales, QR, redirecciones antiguas y fallback mantienen acceso público.
Las APIs conservan autorización por operación y SSR no publica datos privados.
Puente de cookie antigua conserva únicamente destinos de cuenta registrados,
sin aceptar retornos externos. Backend fallido mantiene los reintentos existentes.
[ADR-079](decisiones/079-politica-global-de-acceso-web.md) sustituye los guards
particulares de ADR-078; AGENTS, reglas, arquitectura y fichas actualizados.
Sin ampliación del MVP ni cierre de HU-01/HU-14.3.

Validación local: typecheck y build aislado aprobados;43 pruebas unitarias y
arquitectónicas y18 de servidor de producción aprobadas. El test de inventario
comprueba rechazo de una página sin política. Servidor recorre todas las rutas
registradas y comprueba permisos, onboarding, revocación y destinos del puente.
Chrome check-session-entry-browser recorre el inventario completo SSR/SPA,
observando ausencia de montajes privados tras logout y de moderación sin permiso;
incluye aliases, QR, legales, cookies anteriores, fallo503/reintento y acceso sin JS.
Suites Chrome completas de acceso y moderación aprobadas: operaciones/evidencia,
reintentos ambiguos, revocación, pestañas/caducidad, onboarding, OAuth fixture,
responsive y texto200%, sin overflow ni errores CSP/hidratación.

Sin bloqueos locales ni cambios de SQL/Flutter/configuración remota/despliegue.
Evidencia con backend fixture; siguiente paso: revisión del usuario con su sesión
real y, si se autoriza, despliegue del conjunto. No confirma el entorno publicado.

## Inicio y bienvenida sin skeleton al entrar sin sesión —19/10/2026

El usuario detecta el caso omitido por la corrección anterior: /inicio todavía
montaba AccountScreen y su skeleton antes de comprobar sesión en onMounted.
session-entry ahora intercepta /inicio y /bienvenida antes de renderizar;
account-access comprueba mediante ViewModel/caso de uso antes del montaje SPA.
Tras logout, ambas rutas llegan al formulario sin mostrar shell/skeleton de
cuenta. Una sesión válida también redirige según onboarding antes de renderizar
una ruta incorrecta. No se publican perfiles/tokens en HTML ni se cambia la
autorización de las APIs. ADR-078 y ficha de acceso actualizadas, sin ampliar HU.

La recuperación de cookies antiguas mantiene su reintento ante fallo de backend:
entry=unavailable permite únicamente el shell vacío de /inicio para evitar
bucles al volver al puente; nunca concede sesión ni acceso a datos.

Validación local: tipos y build aislado .nuxt-session-entry aprobados;42 pruebas
unitarias/arquitectura y17 de servidor aprobadas. Chrome comprueba ausencia de
montaje de AccountScreen/skeleton tras logout en /inicio y /bienvenida, apertura
directa, recarga y navegación SPA, además de cookie antigua/fallo503/reintento,
onboarding y login previo sin regresión. Sin errores CSP/hidratación.
La simulación de caducidad de check-access-browser usa un vencimiento temporal
real compartido por las consultas, en lugar de invalidar tras una sola lectura:
la comprobación previa y la pantalla pueden consultar la misma sesión válida.
Suite completa check-access-browser aprobada tras ese ajuste: caducidad,
logout entre pestañas, onboarding/reintento, permisos, OAuth fixture y responsive
con texto200%, sin overflow, errores CSP ni desajustes de hidratación.

Sin SQL, Flutter, variables nuevas ni despliegue. Evidencia con backend fixture;
pendiente comprobar la sesión real del usuario. Siguiente paso: revisar ambas
rutas tras cerrar sesión en el navegador del usuario.

## Acceso web sin login intermedio —19/10/2026

Por solicitud del usuario, /iniciar-sesion comprueba sesión en servidor y
responde302 a /inicio o /bienvenida antes de generar HTML de login. Navegación
cliente espera al ViewModel antes de montar. Sin formulario ni skeleton de
acceso intermedio; la carga de datos del destino conserva su comportamiento.
eh_access HttpOnly/cifrada pasa a path /; /api/access/entry recupera las cookies
anteriores /api con validación real, sin renovar el vencimiento. El salto anónimo
termina con entry=checked (sin autoridad), retirado por cliente conservando reason.
El cierre elimina ambos paths. Cookie inválida se limpia; fallos de backend
conservan sesión y van a /inicio con su reintento existente.
[ADR-078](decisiones/078-acceso-web-redireccion-servidor-sin-login-intermedio.md),
[ficha](funcionalidades/acceso-web.md). Misma HU-01/RF-01,34, sin cierre de historia.

Validación local: typecheck aprobado,42 pruebas unitarias/arquitectura y16 de
servidor de producción aprobadas; build Nuxt aprobado con directorio aislado
.nuxt-session-entry para conservar el dev server del usuario en5173.
Chrome check-session-entry-browser confirma ausencia de montaje de login en
SSR/SPA y recuperación de cookie /api, destinos por onboarding, sesión sin JS,
logout/recarga y sin errores CSP/hidratación. check-access-browser completo
aprobado: acceso ordinario/revisor, onboarding persistido/reintento, revocación,
logout entre pestañas, expiración, fallos de conexión/gestión, OAuth fixture y
responsive1920/1440/731/390/320 con texto200% sin overflow.

Sin bloqueos locales. Backend fixture: no acredita cuentas/configuración remotas.
Sin SQL, Flutter, cambios de entorno, publicación ni despliegue.
Siguiente paso: comprobar la entrada con la sesión real del usuario; para la web
publicada requiere desplegar estos cambios mediante autorización correspondiente.

## Regla ratificada: ubicación y estabilidad de marca —19/10/2026

El usuario solicita registrar como norma el resultado corregido de landing.
REGLAS_UI_UX_WEB precisa ubicación superior izquierda, márgenes responsive,
logo y texto en línea, color/fuente/medidas de referencia y estabilidad desde
SSR hasta hidratación/recarga; fuera de contenido, skeletons y stagger.
AGENTS, ADR-077 y guía de diseño refuerzan la misma condición; las acciones
se acomodan sin mover o tapar la marca. Actualización documental: no cambia
código ni repite pruebas de aplicación. Enlaces locales/diff comprobados;
la evidencia de navegador del incremento anterior sigue registrada debajo.
Siguiente paso: exigir estas comprobaciones al modificar cualquier cabecera.

## Landing: cabecera estable durante recarga e hidratación —19/10/2026

El usuario detecta un descenso leve tras cargar. Se reproduce en build de
producción y servidor dev5173: logo y texto pasan de y8px a y11px en1440px.
CSS compartido y landing declaran align-items distintos con igual especificidad;
el orden de hojas cambia durante hidratación. Las pruebas previas solo comparaban
el estado final y no detectaron esta regresión introducida al compartir cabecera.

Se retiran los selectores de layout .landing-page .site-header de la hoja
compartida: la composición de la cabecera landing queda gobernada por su CSS
aprobado, sin regla competidora. SiteBrand/SiteHeader y las medidas/color comunes
se conservan; reader-shell conserva su layout de cabecera. Sin cambios de
negocio ni datos. Nueva prueba captura fotogramas desde SSR hasta hidratación
y recarga completa, comparando marca, altura de cabecera y origen del hero.
Falla antes con el desplazamiento8→11px y pasa tras corregirlo. Build y
Chrome aprobados: primer render, hidratación y recarga estable en1440/731/390/320,
tanto producción como dev5173. También pasan paridad de marca entre pantallas
y suite completa de landing (responsive/texto200%, SPA, SSR/no-JS y CSP).
Sin despliegue. Siguiente paso: revisión del usuario en su navegador.

## Marca web alineada con landing —19/10/2026

El usuario señala que registrar ADR-076 no corrigió diferencias reales.
Se implementan SiteBrand/SiteHeader compartidos por landing, login, onboarding,
inicio, moderación, QR/avistamientos y legales. Coinciden posición, color, fuente,
peso, espaciados y tamaños adaptables con landing; se retiran marcas por
funcionalidad. Login lleva marca arriba y conserva cuatro grupos de contenido.
Legales conserva scroll interior; retorno glass se ubica bajo cabecera cuando
hay withBack. Móvil/autenticación/roles/datos conservados. ADR-077/normas/fichas
actualizados. Typecheck/build,42 pruebas unitarias/dependencias y14 de servidor
pasan. Chrome compara posición/color/fuente/peso/espaciado/interlineado/logo
contra landing en1440/731/390/320 y texto200%, sin overflow. Suites de acceso,
login recargado (cuatro grupos), onboarding, moderación, legales y landing pasan,
incluyendo SSR/no-JS, navegación y CSP/hidratación. Capturas revisadas en
apps/mobile/build/ui-preview/web-brand (fixtures); sin sesión real del usuario.
Al retirar reglas antiguas se detectó y restauró la grilla móvil de Inicio;
la comparación posterior y QA responsive confirman el resultado final.
Sin despliegue. Siguiente paso: revisión visual local del usuario.


## Regla de posición del logo web —19/10/2026

El usuario pide formalizar logo + texto «entre huellas» en la misma posición
superior de landing y onboarding, también en responsive. ADR-076 y normas
UI/AGENTS/diseño/arquitectura registran cabecera superior izquierda, márgenes
de referencia, fuera de contenido/stagger/skeleton y estable entre etapas.
Incluye acceso y gestión; no cambia móvil. Incremento documental, sin cambios
de código ni afirmación de adaptación global. Validación: enlaces y diff.
Siguiente paso: aplicar/revisar esta norma al adaptar las cabeceras existentes.


## Corrección definitiva del bloque gris en Inicio —19/10/2026

El ajuste anterior solo cambió la forma del skeleton; seguía mostrándolo y no
resolvió la petición. Se elimina ManagementSkeleton y sus estilos/import.
La comprobación de acceso opcional a gestión no monta ni reserva un panel de
carga bajo las tarjetas. Inicio muestra contenido real; gestión se añade solo
con permiso confirmado. aria-busy anuncia la consulta sin bloque visual.
El skeleton inicial de sesión conserva su función mientras no hay cuenta leída.

Si la consulta falla, el toast y la acción real de reintento permanecen. Durante
el reintento se conserva el botón con LoadingShimmer, bloqueando doble envío;
el ViewModel limpia managementFailed al confirmar, sin sustituirlo por un panel.
No cambian SQL, permisos, sesión, móvil ni autorización de cada API.

La nueva regresión Chrome falla con el build anterior al detectar cinco nodos
de placeholder. Ahora exige cero nodos grises durante todos los fotogramas con
las tarjetas montadas, tanto al iniciar sesión como al recargar /inicio, con
la respuesta de permisos retenida, y verifica320px/texto200% y movimiento reducido.
Typecheck/build y42 pruebas unitarias/dependencias pasan. Chrome verifica
entrada y recarga con respuesta retenida sin placeholders en los fotogramas;
captura revisada shared-stagger/reload-management-pending.png. Suite completa
de acceso Chrome aprobada: cuentas normales/revisor, roles, revocación, errores
y reintentos, responsive y texto200%, sin errores CSP/hidratación.
Sin uso de credenciales reales ni despliegue. Siguiente paso: revisión local.

## Inicio: skeleton de permisos con forma y entrada correctas —19/10/2026

El bloque gris bajo las tarjetas era ContentSkeleton de checkingManagement:
reutilizaba una silueta de ficha con foto300px y se montaba fuera del stagger,
por lo que aparecía antes de las tarjetas todavía transparentes. Se sustituye
por ManagementSkeleton de access: resumen de líneas/acción dentro de un panel,
con las formas shimmer compartidas, semántica de consulta y sin texto de carga.
Carga, gestión autorizada y reintento forman parte de la grilla/reveal de Inicio;
el panel ocupa ambas columnas y usa su separación24px, sin margen duplicado.
No cambia consultas, permisos ni ViewModel; una cuenta sin rol retira el panel
al confirmar la consulta. Sin demora artificial, ocultar carga o bloquear Inicio.

Validación: typecheck/build y Chrome con permisos retenidos deliberadamente:
panel menor200px en escritorio, después de las tarjetas en el stagger, separación
real24px,320px/texto200% sin overflow y retiro al confirmar sin ocultar tarjetas.
Suite completa de acceso en Chrome aprobada (cuentas, roles, reintentos,
onboarding,1920/1440/731/390/320 y texto200%, sin fallos CSP/hidratación). Capturas
locales shared-stagger/management-loading*.png con fixture. Sin cuenta real,
SQL, Flutter ni despliegue. Siguiente paso: revisión visual local del usuario.

## Reveal web: eliminación de la cobertura crema compartida —19/10/2026

El rectángulo reportado en /inicio procedía de .reveal::before en main.css:
una capa #fffbeF animada antes del contenido. Se retiran la utilidad global,
el pseudo-elemento y los keyframes cover/arrive. Ocho grupos de inicio,
moderación, ficha QR y formulario/confirmación de avistamientos pasan al
componente StaggerReveal, que reutiliza useStaggerReveal sin pintar coberturas.
Login/onboarding conservan los parámetros aprobados del mismo composable.

El componente conserva etiquetas HTML y eventos, captura los hijos de cada
entrada y no reproduce el efecto por edición/refresh. Movimiento reducido
inmediato; hoja externa noscript permite leer el QR SSR sin JavaScript bajo
la CSP existente. Sin cambios de negocio, servidor, SQL, permisos ni Flutter.
ADR-075 actualiza normas, arquitectura y fichas afectadas. Guardia automática
impide recuperar .reveal y la utilidad antigua.

Validación local: typecheck y build completos;41 pruebas unitarias/dependencias
y14 de servidor pasan. Chrome: fotogramas reales del inicio sin pseudo-capa,
stagger/resize/texto200%/movimiento reducido, QR activo/neutro sin JS; suites
completas de acceso, onboarding, moderación, avistamientos y lector QR pasan,
incluyendo formularios, galería, actualización sin replay, reintentos y CSP.
La primera captura de fotogramas terminaba antes del estado final: se amplió
su ventana. La prueba antigua del lector esperaba cerrar un toast que el
reintento ya cierra; se corrigió la aserción al comportamiento compartido actual.
Captura revisada en apps/mobile/build/ui-preview/shared-stagger/home.png con
cuenta fixture. No se utilizaron credenciales ni sesión real del usuario.

Siguiente paso: revisión del usuario en su navegador local. Sin despliegue,
commit ni nuevo cierre de historia.

## Onboarding: imágenes mayores y corrección de finalización204 —19/10/2026

El usuario pide ampliar ilustraciones y reporta toast de error al terminar.
La imagen pasa de máximo288px a todo el ancho de columna (448px base escritorio,
ancho disponible móvil), conservando PNG/proporción y cabecera superior.

Se reproduce defecto de AccountSource: el éxito HTTP204 sin contenido de una RPC
void se trataba como unavailable por exigir body/getReader. Se acepta204 solo
para complete_onboarding; estados de error se clasifican antes de leer cuerpo.
Repositorio/VM siguen leyendo perfil real y exigiendo onboarding_completed_at
antes de confirmar navegación. Sin éxito optimista, cambios SQL o permisos.
La fixture anterior200/null no cubría este caso; ahora devuelve204. Dos nuevas
regresiones fallan antes y pasan tras la corrección. Esto explica un guardado
potencialmente confirmado seguido de toast erróneo; no se capturó la petición de
la sesión real del usuario ni se usaron sus credenciales.

Validación:40 pruebas unitarias/dependencias, typecheck/build, servidor construido
y Chrome de onboarding/acceso con fixture204. Se comprueba ancho real de imagen,
recorridos completos de guardado/reintento, responsive y texto200% sin overflow.
Ficha y regla visual actualizadas. Sin Flutter, cambios remotos o despliegue.
Siguiente paso: confirmar con la cuenta real; si ya quedó guardado, recargar
consulta el perfil y dirige a inicio sin repetir onboarding.

## Marca del onboarding en cabecera de página —19/10/2026

El usuario aclara que logo/texto van bien arriba como en landing, también en
responsive. La marca pasa de OnboardingFlow a la cabecera de AccountScreen,
fuera de la columna centrada de pasos, con márgenes/padding de landing.
La cabecera permanece en el flujo superior de la página; el cuerpo ocupa
el espacio restante, sin superposición ni altura extra de viewport.
Conserva logo52px, texto, transiciones, avance único y guardado existentes.
ADR-074/regla web/ficha actualizados. Sin SQL, Flutter, permisos o despliegue.

Validación: typecheck/build y QA Chrome de onboarding con fixture, posición
superior/alineación de marca entre pasos y en1440/390/320×350/320 texto200%,
sin overflow/CSP/hidratación. Capturas en build/ui-preview/web-onboarding de móvil.
Pendiente revisión visual del usuario.

## Onboarding: marca superior y avance único —19/10/2026

Por solicitud del usuario se retiran Anterior y los tres puntos visibles de
/bienvenida. Se añade logo oficial52px y texto entre huellas sobre la ilustración,
fuera del stagger, persistentes entre pasos. Continúa con Continuar/Comenzar;
anuncio accesible del paso sin indicador visual. Sin cambios a las tres etapas,
imágenes/textos móviles, sesión, RPC, permisos o Flutter. Se conserva guardado
con shimmer/error/reintento y movimiento reducido; sin despliegue.
ADR-074, regla web y ficha de acceso actualizadas.

Validación: typecheck/build y QA Chrome con fixture para onboarding/acceso,
incluidos ausencia de controles retirados, marca estable, avance/guardado,
movimiento reducido, desmontaje y320px/texto200%. Capturas en
apps/mobile/build/ui-preview/web-onboarding; revisión visual del usuario pendiente.

## Onboarding web con referencia de sader-panel —19/10/2026

Por corrección del usuario se sustituye la presentación provisional de /bienvenida.
La clase global .reveal generaba el rectángulo crema y lo repetía al cambiar paso;
se retira solo de onboarding. OnboardingFlow reutiliza useStaggerReveal:
cuatro grupos550ms/90ms, blur18px/offset56px, salida inferior en orden invertido,
cambio tras820ms y nueva entrada; press400ms y bloqueo de clics repetidos.
Orbe strong continuo, movimiento reducido sin efectos/esperas, incluso al
cambiar preferencia durante salida. Timers/listeners/callbacks se limpian al salir.
El guardado mantiene contenido/shimmer visible y solo sale tras confirmación;
error conserva tercer paso y reintento sin repetir entrada.

Composición de WelcomeStep de sader-panel: ancho448px, izquierda, Inter local,
título48/600, descripción18/500 y botón carbón/radio18px base/mínimo48px/flecha20px.
Móvil alineado abajo con margen60px; escritorio centrado. Se conservan tres pasos,
textos/saltos y PNG móviles originales, copiados byte a byte en public/images/
onboarding. Sin cabecera/footer extra ni configuración de apariencia de Sader.
Inter con OFL local; no peticiones a Google al navegar. AccountViewModel,
complete_onboarding, sesión, permisos y Flutter sin cambios.
[ADR-074](decisiones/074-onboarding-web-referencia-sader-y-mobile.md) registra
excepciones locales a Arial/cápsula/cover; reglas/guía/ficha/recursos actualizados.

Validación: typecheck/build y38 pruebas unitarias/dependencias aprobados;14 de
servidor construido aprobadas. Chrome fixture de onboarding comprueba tiempos/
estilos reales, salida/entrada/anterior/siguiente/doble clic, imágenes idénticas,
guardado visible/error/reintento, movimiento reducido/cambio en salida y desmontaje.
Regresión de acceso/OAuth/roles/sesión aprobada. Capturas1440/390/320×350/320 con
texto200% revisadas, sin overflow/CSP/hidratación. Renders en
apps/mobile/build/ui-preview/web-onboarding. La revisión ampliada detecta el
skip-link asomando por ocultación fija−100px: se oculta ahora por su propia
altura, conserva foco/teclado y se comprueba con texto200%.
Verificados36 enlaces documentales nuevos/actualizados y git diff --check.

Sin SQL, configuración remota, despliegue o cierre de historia. Pendiente revisión
visual del usuario y comprobación con su cuenta real; las pruebas fixture no
certifican proveedores ni entorno remoto.

## Acceso general web, bienvenida e inicio de cuenta —19/10/2026

Por autorización del usuario se separa autenticación general de moderación.
/iniciar-sesion admite cuenta válida por correo/Google/Facebook sin exigir rol;
/bienvenida aplica tres pasos sin Omitir y guarda complete_onboarding por cuenta,
compartido con móvil. /inicio consulta nombre/correo/ciudad reales y permite
cerrar sesión; gestión solo al confirmar permiso. /moderacion conserva control
por operación y retorno a inicio; quitar rol no bloquea uso normal.
Landing conecta acceso y legales; /login, /terms y /privacy redirigen308 a
/iniciar-sesion, /terminos y /privacidad con parámetros conservados.

access contiene dominio/casos de uso, DTO/repositorios/fuente REST/ViewModel y
pantallas propios. Sesión general HttpOnly/cifrada/path /api, máximo1h sin refresh,
secreto servidor existente; SSR sin datos privados. PKCE conserva callback/API
anteriores y crea sesión general. Onboarding/gestión validan identidad esperada.
Se retiran adaptadores sociales anteriores de moderación. Prueba de dependencias
ampliada para impedir imports de data/presentation entre funcionalidades.
[ADR-073](decisiones/073-acceso-general-web-y-gestion-por-permisos.md) registra
la decisión y alcance; reglas/guía/configuración/fichas actualizadas.

Validación local: typecheck y build Nuxt aprobados;38 pruebas unitarias/arquitectura
y14 de servidor construido. Chrome con fixtures: cuenta normal/revisora,
onboarding con reintento/persistencia, permisos revocados conservando cuenta,
cierre entre pestañas, expiración, errores/reintentos, OAuth Google/Facebook,
destinos fijos y redirecciones; sin errores CSP/hidratación. Se corrigió el
desajuste detectado al redirigir una visita SSR antes del montaje.
QA de moderación completo (evidencia, decisiones/reintentos/restauración,
cancelación), legales/SSR sin JS y stagger aprobado. Inicio/bienvenida/acceso
en1920/1440/731/390/320 con texto200% sin overflow; capturas revisadas en
apps/mobile/build/ui-preview/web-access. Sin SQL nuevo ni cambios Flutter.
QA adicional de landing y toast aprobado;25 enlaces Markdown nuevos/actualizados
verificados y git diff --check aprobado. Revisión final añade regresión para
descartar cierre de sesión recibido tras disposición; total38+14 pruebas.

Límites: inicio es consulta de cuenta; Explorar/mascotas/reportes/avisos/perfil
editable, registro/recuperación web y administración siguen pendientes. Sin datos
simulados ni rutas vacías; no se afirma paridad completa. Pruebas fixture no
certifican cuentas/proveedores/allowlist/HTTPS reales. No se asignan roles,
configura Auth remoto, despliega ni cierra historias.
Siguiente paso: validar acceso real del usuario en5173 y entregar un siguiente
recorrido completo de usuario (Explorar web propuesto).

## Regla de rutas web en español —19/10/2026

Por instrucción del usuario se registra ADR-072: navegación visible en español,
minúsculas y guiones, sin tildes ni ñ; código/SQL/endpoints internos pueden seguir
en inglés. Mantener raíz / y contrato QR /c/:token; callbacks OAuth y deep links
no se renombran por esta regla. Al migrar /login, /terms y /privacy, conservar
redirecciones hacia /iniciar-sesion, /terminos y /privacidad con parámetros
necesarios del flujo y destinos internos seguros.

AGENTS, reglas de arquitectura/UI web, arquitectura, guía y fichas de acceso/legal
enlazan la decisión. Cambio exclusivamente documental: rutas actuales, permisos
y despliegue conservan su estado. Verificación de enlaces nuevos, coherencia
con páginas existentes y git diff --check; sin build/pruebas de aplicación.
Siguiente paso: aplicar la convención en próximos incrementos y migrar rutas
existentes con pruebas de navegación/retornos; no crear páginas vacías.

## Acceso local: puerto real y salida a proveedores —19/10/2026

Capturas del usuario identifican http://127.0.0.1:3000/login. Se reproduce
OAuth start403/invalid_request desde ese origen; el mismo proceso acepta5173
y genera callback5173. Al actualizar .env.local, Nuxt se reinicia y pasa a
escuchar5173, acorde con el comando dev del proyecto. Se deja
PUBLIC_WEB_ORIGIN=http://127.0.0.1:5173 y se verifica la instancia en ese puerto:
Google/Facebook start200, callback5173; las URLs generadas llegan a Supabase
y reciben302 hacia accounts.google.com y www.facebook.com respectivamente.
No se introducen IDs/secretos de proveedores en Nuxt: pertenecen al servicio
Supabase Auth autohospedado. La habilitación y redirección no demuestran la
validez completa de credenciales ni allowlist de retorno tras autenticarse.

El aviso de credenciales de la captura es forbidden de moderación; puede proceder
del control de rol o del rechazo de origen (ambos403), por lo que la captura sola
no confirma contraseña válida ni rol faltante. No se asignan permisos ni se
prueba con credenciales del usuario. Sin cambios de código, SQL o despliegue.
Siguiente paso: abrir5173 y comprobar recorrido real de proveedor/retorno con
cuenta autorizada. El503 publicado documentado abajo es una observación separada.

## Diagnóstico de acceso web —19/10/2026

El usuario informa «No pudimos conectar». Comprobación del dominio publicado:
GET /login devuelve200 y GET /api/moderation/session sin cookie devuelve401
(esperado); POST /api/moderation/oauth/start con origen correcto, JSON válido y
Google devuelve503/unavailable. Esta última ruta no contacta al proveedor ni a
Supabase: apunta a configuración de acceso ausente/inválida en el proceso
publicado. Pendiente inspeccionar variables/logs de Dokploy; sin acceso a su
configuración no se confirma la variable concreta. No se modifica el despliegue.

En .env.local se detecta el origen de producción usado para pruebas HTTP locales:
el POST local devuelve403/invalid_request. Se corrige solo PUBLIC_WEB_ORIGIN a
http://127.0.0.1:5173, conservando credenciales. Verificación con runtime construido
existente y entorno explícito: inicio Google/Facebook200, callback local, cookie
HttpOnly sin Secure sobre HTTP; origen externo sigue403. Lectura pública de Auth
con la clave local devuelve200 y proveedores email/Google/Facebook habilitados.
Esto no acredita login con cuenta real, callback autorizado remotamente ni rol.
Sin cambios de código, SQL, autenticación remota o nuevo build. Guía local y ficha
actualizadas; git diff --check aprobado. Siguiente paso: revisar configuración
del servicio publicado y verificar acceso completo con una cuenta autorizada.

## Reglas UI/UX consolidadas —19/10/2026

Por solicitud del usuario, se consolidan REGLAS_UI_UX_WEB, REGLAS_UI_UX y
DISENO_UI con los valores finales del login, toast sin negrita y controles
legales compactos. Se corrigen referencias vigentes a flecha20px/retorno52px
que ya no correspondían a la barra legal y se retiran notas sueltas duplicadas.
Se distingue el retorno legal36px/icono16px del compartido52px/icono28px,
y el texto400 del toast web del peso600 de su referencia móvil.
Validación documental y git diff --check; sin cambios de código ni nuevos
builds/pruebas. Siguiente paso: usar esta referencia en futuros cambios visuales.

## Retorno legal compacto —19/10/2026

Por solicitud del usuario, el botón izquierdo de /terms y /privacy pasa a
36×36px e icono16px, emparejado con la altura normal del enlace derecho.
Mantiene diseño circular glass y navegación al login. Override local en
LegalPage: GlassNavigationButton conserva su tamaño en otros recorridos.
Chrome local confirma36px/icono16px, radio50%, blur22px y retorno real
al login en ambas rutas. Sin overflow a320px/texto200%; git diff --check
aprobado. Sin build para este ajuste CSS. Siguiente paso: revisión visual.

## Proporciones del botón legal —19/10/2026

La comparación con sader-panel confirma que no bastaba cambiar el radio:
el botón derecho tenía mínimo48px y padding12/16px. Ahora usa mínimo36px,
padding8/12px, fuente14px/500 con línea20px e icono16px, como su Button
(h-9, py-2 y has-svg:px-3). Conserva radio18px y colores de Entre Huellas.
Altura flexible para texto ampliado y ajuste de líneas. Chrome local confirma
36px, padding8/12px, radio18px, fuente14px/500 e icono16px en ambas rutas.
Sin overflow a320px con texto200%; git diff --check aprobado. Sin build
para este ajuste CSS. Siguiente paso: revisión visual del usuario.

## Radio del enlace legal superior —18/10/2026

Por solicitud del usuario, el botón derecho compartido de /terms y /privacy
usa calc(.625rem + 8px), equivalente a rounded-2xl de sader-panel
(--radius .625rem + 8px):18px a tamaño base. Sustituye16px.
Verificación CSS y git diff --check; sin cambios de contenido o navegación.
Siguiente paso: revisión visual del usuario.

## Texto del toast sin negrita —18/10/2026

Por solicitud del usuario, TopToast cambia el peso de600 a400.
Regla web y ficha de acceso actualizadas. Verificación del CSS y
git diff --check aprobados; sin ejecutar build para este ajuste de peso.
Siguiente paso: revisión visual del usuario.

## Toast web alineado con móvil —18/10/2026

Por solicitud del usuario, TopToast compartido reproduce ConfirmationToastHost
móvil: cápsula #F5F5F7 al90%, borde blanco70%, radio28px, blur18px y sombra
#24282A al10% desplazada6px/blur20px. Ancho ajustado al mensaje hasta360px,
márgenes laterales24px y safe-area superior+12px, mínimo48px, padding16/8px.
Icono Material Rounded oficial20px dentro de círculo neutro32px; error_outline
en #B53F48 para error y check #111111 para confirmación. Texto14px/600,
fuente heredada de la página. Sin X: tocar el aviso o activar su botón mediante
teclado lo cierra. Reintentar sigue siendo acción independiente, cierra primero
y ejecuta su callback. Entrada fade lineal y slide easeOutCubic de180ms;
movimiento reducido estático. Mensajes extensos/texto ampliado pueden hacer
scroll vertical dentro del límite30svh/220px, sin recorte de contenido.

Conserva API show, roles alert/status, expiración web6500ms y limpieza al
desmontar; no se altera autenticación, stagger, orbe ni código Flutter.
La adaptación se comparte con los recorridos que ya consumen TopToast.

Validación: typecheck/build aprobados. QA Chrome del toast confirma cápsula,
blur/iconos/colores, estados alert/status, cierre al tocar y por teclado,
expiración y movimiento reducido;1440/390/320px con texto200% sin overflow,
CSP ni errores de hidratación. Capturas escritorio/móvil revisadas en
apps/mobile/build/ui-preview/web-toast. QA completo de login y moderación
aprobado con backend fixture. git diff --check aprobado. Siguiente paso:
valoración visual del usuario; OAuth remoto conserva su configuración pendiente.

## Stagger del login portado desde sader-panel —18/10/2026

El usuario solicita copiar el mecanismo completo, no solo sus parámetros.
Se reemplazan los keyframes del login por useStaggerReveal compartido, adaptado
a Vue: transiciones originales, doble rAF, will-change persistente, opciones de
entrada/salida y limpieza. Icono con entrada exterior y hover interior separados.
Se conserva Arial, formulario, orbe y comportamiento de sesión.

vStaggerReveal aplica estilos por CSSOM para cumplir la CSP de platform;
clase SSR inicial equivalente y movimiento reducido estático. Sin cambios de
seguridad, autenticación, Flutter ni despliegue.

Validación: typecheck y build aprobados. QA Chrome de producción confirma
transiciones CSS reales,850ms/90ms, will-change persistente, posición final
estable, hover aislado, sin reinicio al editar; recarga normal y movimiento
reducido,390/320px y texto200%, sin overflow/CSP/hidratación. Capturas escritorio
y móvil revisadas en apps/mobile/build/ui-preview/login-reload. QA completo de
login y login/legal también aprobado, incluidos accesos sociales con backend
fixture. git diff --check aprobado. Siguiente paso: valoración visual del usuario;
la activación OAuth real sigue pendiente de configuración.


## DM Sans legal e iconos Material reales —18/10/2026

Por corrección del usuario, el retorno web deja de representar el chevrón
mediante el carácter ‹. GlassNavigationButton usa AppIcon con el SVG oficial
Material Symbols Rounded chevron_left de28px; círculo52px, transparencia,
gradiente/reflejos interiores y blur22px alineados con GlassSurface móvil.
No se alteran posición local en barra legal, tooltips, foco ni navegación.

Fecha y anuncio dejan de usar dibujos outline aproximados: se incluyen
Material Symbols Outlined FILL1/optical20 schedule y campaign, los mismos
usados por sader-panel a16px. AppIcon reutiliza sus trazados locales; no se
carga una fuente de iconos ni se consulta Google al navegar. Flecha cruzada
conserva su trazo existente. Licencia Apache2 incluida.

El usuario amplía explícitamente la instrucción de fuente: solo /terms y
/privacy adoptan DM Sans, la familia confirmada en layout de sader-panel.
Fuente variable100–1000, subconjunto latino con acentos, WOFF2 local/preload
y OFL adjunta. Se aplica a toda la shell legal, incluidos metadatos y títulos;
login, landing y moderación conservan sus familias previas. Esta indicación
sustituye la conservación de Arial en legales, sin cambiar el resto de la web.
Escala45/32/16px, texto/contacto, orbe y layout previos conservados.

Validación: typecheck/build aprobados. QA Chrome de legal/login verifica
DM Sans computada y fuente disponible, iconos sólidos locales, retorno SVG28px
sin carácter de texto, glass blur22px, posiciones/scroll/orbe y responsive
1440/390/320 con texto200%; sin overflow/CSP/hidratación. Capturas escritorio
y móvil revisadas en apps/mobile/build/ui-preview/login-legal. QA moderación
aprobado tras corregir selector obsoleto de la etiqueta del botón de acceso;
se conserva la etiqueta actual Iniciar Sesión. QA completo de login también
aprobado, incluida su familia Arial y los flujos OAuth simulados. Sin cambios SQL/Flutter,
autenticación, envío de correos o despliegue. Siguiente paso: valoración visual
del usuario; OAuth real mantiene su activación/configuración pendiente.

## Diseño legal alineado con sader-panel —18/10/2026

Por corrección explícita del usuario, /terms y /privacy adoptan la composición
de sader-panel: viewport de lectura con scroll propio, documento máximo896px,
padding24/48px, barra superior dentro del documento, enlace al otro documento,
título centrado con degradado y metadatos de fecha/anuncio con iconos SVG locales.
Se retiran el logo/descripción e índice adicionales de la variante anterior.

GlassNavigationButton conserva su círculo/glass/chevrón y52px; solo en la
barra legal su posición pasa de fixed a static, alineada con el documento.
No cambia el componente global ni los otros recorridos. Escala tomada de CSS
real de sader-panel (incluidos overrides markdown): h1 45px, h2 32px, cuerpo16px/
interlineado24px, metadatos14px y footer12px. Se conserva Arial por la instrucción
anterior del usuario; no se importa DM Sans. Texto ampliado mantiene ajuste
natural de línea sin recorte ni reducción de fuente.

El orbe de las páginas legales usa medium0.5, fijo al viewport sin máscara
vertical; su luz permanece durante el scroll del documento. Fondo blanco/celeste
y capa backdrop-blur10px con desvanecimiento en bordes como referencia. El texto
es estático, sin cover/reveal de la versión anterior; login/landing y contenido
legal/contacto/fecha conservados. Sin cambios de sesión, permisos, SQL o Flutter.

Validación local: typecheck y build aprobados. Chrome comprueba título45px,
encabezados32px/cuerpo16px, tres iconos, retorno dentro de la barra con posición
static y orbe fixed sin máscara vertical. Movimiento del orbe comprobado con
frames distintos y opacidad0.5; conserva posición al desplazar el contenedor.
Enlaces/retorno/contacto, SSR sin JS y1440/390/320 con texto200% aprobados, sin
overflow ni errores CSP/hidratación. Capturas de escritorio, móvil y lectura
desplazada revisadas en apps/mobile/build/ui-preview/login-legal.
Git diff --check aprobado. Sin despliegue; siguiente paso: valoración del usuario.

## Recarga de login sin destello crema —18/10/2026

El usuario detecta un destello amarillo al recargar. Causa comprobada:
.login-form usaba .reveal y su pseudo-elemento de cobertura #FFFBEF del
componente global. Se retira esa clase solo del login; no se modifica el
reveal global ni las páginas legales/QR/landing.

Por solicitud expresa, /login adopta la entrada de useStaggerReveal de
sader-panel: opacidad0→1, blur18→0px, translateY(-28px)→0,850ms y curva
cubic-bezier(.22,1,.36,1). Seis grupos con separación90ms: icono, nombre,
título, lema, formulario y enlaces legales. Reutiliza keyframes arrive existentes,
sin capa pintada; sustituye entrada previa del icono700ms/12px/escala. Hover del
icono1.05 y orbe se conservan. Cabecera entra una sola vez por esta instrucción,
y permanece estable durante sesión/edición; no se remonta ni se repite entrada.
Movimiento reducido muestra todos los grupos estáticos desde el inicio.

Validación: typecheck/build y QA Chrome de carga/recarga aprobados. Comprobados
valores de seis grupos, ausencia de pseudo-elemento en inicio/mitad/final,
capturas de recarga y ausencia de reinicio al editar.390/320px con texto200%,
sin overflow/errores CSP/hidratación. QA login/legal previo aprobado: orbe/hover,
links/retorno/SSR sin JS y1440/390/320. Capturas en
apps/mobile/build/ui-preview/login-reload revisadas. git diff --check aprobado.
Sin cambios de autenticación, SQL, Flutter o despliegue. Siguiente paso:
valoración visual del usuario; OAuth real conserva su configuración pendiente.

## Icono, orbe y documentos legales del login —18/10/2026

Por solicitud del usuario se adapta la entrada del icono y hover1.05 de
sader-panel: animación de aparición700ms, hover/foco300ms y movimiento reducido
estático. Editar campos o comprobar sesión no repite la entrada. El orbe ya
existente en login pasa a strong0.62, con colores celestes y sin radial fijo que
oculte su movimiento. AmbientPageShell reutiliza fondo y BackgroundGlowOrb en
login y documentos legales; landing conserva sus estilos e intensidad.

/login añade enlaces reales a /terms y /privacy. Documentos públicos SSR,
composición compartida LegalPage sin dominio/ViewModel vacíos, índice con anclas,
retorno glass al login, enlaces cruzados y mailto al contacto. El usuario confirma
sergiotlv51@gmail.com y korMind cuando sea necesario identificar al responsable.
Contenido redactado como documentos del servicio, sin referencias a MVP/borrador,
sin inventar domicilio, razón social completa o plazos de conservación. Se usa
korMind en identificación y privacidad; el resto mantiene Entre Huellas.

No se crea registro de aceptación/consentimiento ni se modifican cookies, roles
o datos de autenticación. Sin cambios SQL/Flutter, envío de correos o despliegue.
Validación: typecheck,30 pruebas y build Nuxt aprobados. Chrome de producción
con fixtures: entrada/hover del icono, orbe animado, ausencia de reinicio al editar,
movimiento reducido estático; enlaces, retorno glass, anclas y mailto correctos;
SSR sin JavaScript en documentos. Renders1440/390/320 con texto200%, sin overflow
ni errores CSP/hidratación. Se corrigió ajuste de títulos largos para permitir
lectura con texto ampliado. Capturas revisadas en
apps/mobile/build/ui-preview/login-legal. QA completo de login previo también
aprobado, incluidos Google/Facebook fixture. git diff --check aprobado.
Siguiente paso: valoración visual del usuario; OAuth real sigue pendiente de
configuración. No se publica ni despliega.

## Login estable y Google/Facebook web — 18/10/2026

Se retira el skeleton que sustituía el formulario al comprobar sesión. /login
renderiza el formulario estático desde SSR, mantiene el mismo árbol durante la
consulta y deshabilita envíos con aria-busy hasta terminar, sin shimmer por simple
deshabilitación. La entrada no se repite por comprobación o edición. Se elimina
el texto «Acceso para cuentas autorizadas…». Skeleton de datos de moderación
permanece; este formulario no muestra datos remotos.

Se añaden Continúa con Google/Facebook y separador «o continúa con» siguiendo
móvil, con SocialSignInButton compartido por ambos proveedores e iconos locales.
StartSocialSignIn/CompleteSocialSignIn expresan operaciones de dominio,
HttpSocialSignInRepository y fuente Supabase encapsulan HTTP; AccessViewModel
coordina busy/proveedor, toast y descarte tardío. Plugin compone dependencias.

OAuth servidor PKCE: POST same-origin /api/moderation/oauth/start, redirect a
Supabase y retorno GET /api/moderation/oauth/callback?flow=…&code=…. Cookie de
flujo AES-GCM/HttpOnly/SameSite Lax, scope /api/moderation/oauth,600s, state aleatorio
y verifier privado; código se intercambia solo en servidor. Callback limpia cookie
de flujo y valida estado/expiración antes de intercambiar. Auth/rol se verifican
antes de guardar la cookie de moderación, que conserva SameSite Strict y scope
/api/moderation. No tokens/verifier en payload cliente ni localStorage, ni roles automáticos.
Solo GET callback admite navegación cross-site; las otras API mantienen bloqueo,
protección de origen y límites. Retorno fijo, sin open redirect. Supabase consume
el código una sola vez; pruebas de replay incluidas.

Validación local: typecheck,30 pruebas unitarias/arquitectura, build y8 pruebas
de servidor aprobados. Chrome fixture: ambos proveedores recorren inicio/retorno
y cierre, más flujos previos; formulario SSR sin skeleton/texto retirado. Renders
1920/1440/731/390/320 y texto200% sin overflow/CSP/hidratación; capturas escritorio
y pequeña revisadas en apps/mobile/build/ui-preview/web-login.

Pendiente configuración local (clave publicable, secreto y PUBLIC_WEB_ORIGIN),
habilitación Google/Facebook y allowlist de callback web en Supabase, y demo con
cuentas reales. Proveedores móviles no implican URL web autorizada. Sin cambios
remotos, SQL, Flutter, despliegue o cierre de historia. Siguiente paso: configurar
y verificar la autenticación real; no reaplicar030.

## Login inspirado en acceso móvil y sader-panel — 18/10/2026

Por petición del usuario, /login toma la composición del acceso móvil y la
columna concentrada de sader-panel, manteniendo Arial/Helvetica/sans-serif.
Marca oficial grande con nombre en dos líneas, título y lema; formulario directo
sin tarjeta exterior ni cabecera/footer institucional duplicados. WebShell
incorpora variante minimal y conserva el enlace de salto accesible.

LoginInput se reutiliza en correo/contraseña: superficie #F5F5F7, radio22px,
iconos de correo/candado, etiquetas flotantes persistentes y control accesible
Mostrar/Ocultar contraseña. Botón Entrar carbón #111111 y texto blanco como
en móvil, cápsula64px; es variante de login autorizada por esta solicitud.
Fondo blanco/celeste/cream y BackgroundGlowOrb soft conservados. Cabecera fuera
del reveal; edición y visibilidad no reinician entrada; movimiento reducido
respetado. No se copian acciones sociales/registro/recuperación que no tengan
implementación web en este alcance. Autenticación, roles y redirecciones iguales.

Validación: typecheck,27 pruebas y build aprobados. QA Chrome de login con
fixtures aprobado (autenticación/roles/redirects/logout/caducidad/reintento),
además de Arial, ausencia de tarjeta y mostrar/ocultar sin perder el valor.
Renders1920/1440/731/390/320, texto200% en320, sin overflow ni errores
CSP/hidratación. Capturas escritorio/móvil/pequeña revisadas en
apps/mobile/build/ui-preview/web-login. Configuración remota/cuenta revisora
y otros navegadores pendientes; sin despliegue ni cambios SQL/Flutter.
Siguiente paso: valoración visual del usuario y acceso real tras configurar servidor.

## Corrección de consulta anónima de sesión — 18/10/2026

La captura del usuario muestra aviso al abrir /login. Diagnóstico local: GET
/api/moderation/session sin cookie devolvía503 porque se validaba configuración
antes de reconocer ausencia de sesión. .env.local tiene SUPABASE_URL pero faltan
SUPABASE_PUBLISHABLE_KEY, MODERATION_SESSION_SECRET y PUBLIC_WEB_ORIGIN.
Solo se inspeccionó presencia de variables, sin mostrar ni modificar secretos.

readModerationSession devuelve401 si no hay cookie antes de componer backend.
Con cookie presente conserva descifrado/Auth/rol y errores reales; login sigue
fallando cerrado si la configuración está incompleta. No se ocultan fallos503
ni se otorgan permisos. Configuración de acceso real sigue pendiente.

Validación: typecheck/build y7 pruebas de servidor de producción aprobados,
incluida regresión sin configuración (sesión anónima401, cookie suministrada503,
login503). Nuxt dev5173 comprobado: sesión sin cookie401, formulario visible sin
toast de conexión y /moderacion redirige a /login. git diff --check aprobado.
Sin cambios de variables, SQL o despliegue. Siguiente paso: configurar servidor
local y comprobar acceso con cuenta revisora real.

## Login web separado y redirecciones — 18/10/2026

Por autorización del usuario se crea /login como página separada; /moderacion
ya no contiene formulario. LoginScreen/AccessViewModel consumen AccessModeration
y el repositorio HTTP existentes, sin consultar la cola desde el login.
Instancias por consumidor, sin estado privado singleton. Usa WebShell,
BackgroundGlowOrb soft, ActionButton, TopToast y ContentSkeleton, con referencia
visual web vigente, campos accesibles, shake/invalid y shimmer de trabajo real.

Sin sesión, /moderacion redirige a /login; al entrar o visitar /login con sesión
autorizada se vuelve a /moderacion. Destino fijo, sin aceptar URLs de retorno
arbitrarias. Rol denegado se anuncia por toast sin acceder al panel. Expiración,
logout y cambios entre pestañas limpian datos y llevan al acceso cuando procede.
Fallo de red/servidor permite reintento, sin tratarlo como ausencia de sesión.

La cookie conserva alcance /api/moderation, HttpOnly/cifrado/SameSite y permiso
por operación en servidor. La primera visita SSR sirve shell/skeleton público,
y la redirección se ejecuta tras montar en navegador; el middleware protege
navegaciones cliente posteriores. No se afirma redirección HTTP3xx en SSR.
Sin registro, roles nuevos, panel de usuario, cambios SQL/Flutter o despliegue.

Validación local: typecheck,27 pruebas unitarias/arquitectura, build Nuxt y
6 pruebas de servidor de producción aprobados. Chrome con backend fixture:
login, validación, denegación de rol, Enter, destino fijo, sesión existente,
logout entre pestañas, recuperación503 y caducidad. QA moderación aprobado
(cola/evidencia/decisiones/reintentos/revocación); sin errores CSP/hidratación.
Renders1920/1440/731/390/320 y texto200% en320, sin overflow; escritorio y
tamaño pequeño revisados en apps/mobile/build/ui-preview/web-login.
Pendiente acceso con cuentas/configuración remotas reales y otros navegadores.
030 confirmado previamente por usuario; no reaplicarlo. Sin publicación/GitHub.
Siguiente paso: revisión visual del usuario y demo con cuenta revisora real.

## Consolidación de reglas UI/UX web — 18/10/2026

Se consolida REGLAS_UI_UX_WEB con fondo general blanco/celeste, fondo exterior
del carrusel blanco/cream, paneles #F3F2EE, footer cream y contrato de
BackgroundGlowOrb (intensidades, tokens, capas, movimiento/CSP). Texto secundario
y oportunidad reflejan los retoques locales del usuario. Se integra la información
en paleta/movimiento/aceptación y se retira el apéndice duplicado. REGLAS_UI_UX
enlaza la consolidación vigente.

Cambio exclusivo de Markdown, sin cambios de app, alcance o permisos.
Validación: enlaces locales, concordancia con CSS/componente y git diff --check.
No se repiten builds ni pruebas de app por esta edición.
Siguiente paso: aplicar estas reglas en futuros incrementos web.

## Corrección: fondo exterior del carrusel blanco/cream — 18/10/2026

El usuario aclara con captura que el ajuste corresponde al fondo detrás del
carrusel de mascotas. Se revierte el cambio equivocado de .purpose, que conserva
el panel #F3F2EE. Una capa decorativa de .character-strip mezcla blanco predominante
y cream tenue con bordes difuminados sobre el fondo celeste animado. Mantiene
mascotas, tarjetas, espacios, controles y animaciones sin cambios.

Validación Chrome local1440/390/320px, etiquetas200% en320: fondo computado
correcto y panel original restaurado, sin overflow ni errores de página. Captura
de escritorio revisada en apps/mobile/build/ui-preview/landing-carousel-cream.
Sin build nuevo ni despliegue. Siguiente paso: valoración visual del usuario.

## Patch030 confirmado y consulta sobre acceso web —18/10/2026

El usuario confirma haber ejecutado030. Aplicación registrada según confirmación,
sin inspección SQL remota nueva; no pedir reaplicarlo. La captura local de
/moderacion muestra el formulario de acceso sin error visible: es la etapa
esperada cuando no hay sesión web autenticada vigente. Sesión móvil no equivale
a sesión del navegador; ejecutar SQL no inicia sesión ni asigna revisores.
La captura acredita render del acceso, no login/rol ni demo completa de backend.
Pendientes de validar: variables de Nuxt, cuenta revisora asignada en servidor,
login y recorrido real. No se infiere que esos pasos ya estén hechos ni que
fallen. Sin pruebas nuevas de app/SQL, despliegue o acciones GitHub. Documentación
de activación/ficha/backlog actualizada; git diff --check aprobado.


## Resplandor animado reutilizable de landing — 18/10/2026

Por petición del usuario se adapta el efecto de sader-panel como componente Vue
compartido BackgroundGlowOrb, sin dependencias de React ni del otro proyecto.
Dos orbes celestes, halo y grano SVG local; movimiento CSS17/11/16s y entrada
por opacidad. intensity acepta soft/medium/strong; los colores se personalizan
con --glow-color y --glow-secondary desde CSS, sin atributos style ni relajar CSP.
El contenedor consumidor aporta posición relativa y orden de capas.

Landing lo monta una vez, en intensidad soft, detrás del contenido. Sigue el
viewport mediante sticky y se desvanece hacia el footer cream mediante máscara
exclusiva de landing. Decorativo, aria-hidden, sin eventos ni datos; movimiento
reducido lo deja estático y visible. No afecta otras rutas ni sus permisos.

Validación local: typecheck,25 pruebas y build Nuxt aprobados. Chrome de
producción en1920/1440/731/390px y320px con texto200%: desplazamiento real de
orbes, seguimiento del scroll, máscara del footer, modo reducido sin animaciones,
FAQ operable y ausencia de overflow/errores CSP/hidratación. QA existente de landing
aprobado: teclado/anclas/ilustraciones, SSR/FAQ sin JS y navegación landing→QR→landing.
Capturas de escritorio/móvil y footer revisadas en
apps/mobile/build/ui-preview/landing-glow. Sin despliegue; pendiente valoración
del usuario y comprobación en otros navegadores.
Siguiente paso: revisión visual del usuario; reutilizar el componente al intervenir
otro recorrido autorizado.

## Fondo blanco/celeste de landing — 18/10/2026

Por petición del usuario, el fondo general cambia del radial crema a blanco con
celeste difuminado lateral y transición gradual al cream existente del footer.
Se conservan los retoques locales previos de texto, paneles y oportunidad.
Solo presentación CSS; sin cambios funcionales ni despliegue.

Validación local: Chrome sobre Nuxt dev existente en5173, renders1440/390px
y320px con textos al200%, sin overflow horizontal ni errores de página.
Captura de escritorio revisada; evidencia en
apps/mobile/build/ui-preview/landing-background. No se ejecutó build de producción
para este ajuste de fondo. Siguiente paso: valoración visual del usuario.

## Moderación exclusiva de platform — HU-14.3 / RF-22,33, issue #45 —18/10/2026

El usuario autoriza continuar y exige administración exclusivamente web. Se
actualizan AGENTS, reglas de arquitectura/UI web/móvil, ADR-071, guía, ficha/
índice, arquitectura/diseño/configuración, backlog y documentos de platform/SQL.
Flutter conserva denuncia de usuario: sin cambios de lib/test móvil ni nuevos
menús, pantallas, guards o acciones administrativas.029 ya confirmado aplicado;
no se solicita reaplicarlo. Firebase/FCM fuera del alcance y de la aceptación.

Implementación local en feature/platform-moderation, conservando cambios previos
de documentación de029. Se preserva cambio paralelo ajeno en el degradado de
landing.css, sin atribuirlo a moderación. No se hizo commit/push/PR/merge,
publicación, SQL remoto, asignación de roles ni cambios de GitHub. No se declara
HU-14 completa ni issue cerrado por esta entrega local.

/moderacion → acceso con cuenta existente autorizada → cola paginada20 de
pendientes/resueltas → revisión privada de motivo/evidencia y contenido → foto
primaria procesada bajo petición → ocultar/restaurar/resolver sin cambiar
visibilidad con motivo obligatorio500 → confirmación explícita → recibo guardado.
Consulta de estado e historial de últimas20 decisiones, completo conservado en
SQL. No se entregan suspensión de cuentas, bloqueo, apelación ni métricas.

Dominio TypeScript/contratos/casos de uso, DTO y repositorios cliente/servidor,
fuentes Auth/RPC/Storage encapsuladas, ViewModel y presentación separados. API
comprueba Auth/rol en cada operación y SQL vuelve a autorizar. Sin secretos,
tokens, paths de Storage, identidad del denunciante o coordenadas privadas en
cliente/payload SSR. HTML inicial solo shell/skeleton; estado privado por
instancia, sin singleton de sesión. Se asigna rol desde servidor, sin alta
ficticia/autorización por navegación ni revisores predeterminados.

Cookie de acceso HttpOnly cifrada/autenticada AES-256-GCM, SameSite Strict,
Secure con HTTPS, máximo1h/sin refresh token; origen exacto y límites de cuerpo/
tiempo/tasa. Logout local de sesión web, sin cerrar sesiones Android. Datos
ligados a identidad esperada, cambios entre pestañas/expiración/falta de rol/
disposición limpian estado y descartan respuestas tardías. Nuevas variables de
servidor SUPABASE_PUBLISHABLE_KEY/MODERATION_SESSION_SECRET; configuración de
lector QR permanece. La landing/QR no dependen de acceso administrativo.

Plan030/fuentes102–105/migración/patch generados, sin cambiar SQL029 aplicado.
Visibilidad separada del ciclo operativo, tablas privadas/RLS sin grants directos,
decisiones append-only y accesos auditados a cola/detalle/evidencia/decisión.
Versiones de denuncia y recurso, UUID estable y serialización entre denuncias
del mismo recurso: replay no duplica, conflicto no borra decisiones. Lecturas
privilegiadas de la RPC de029 también auditadas. Rol bloqueado durante operación.
Pérdida de respuesta congela orden/contenido y habilita reintento idéntico;
consulta fallida tras conflicto conserva borrador. Salida/cancelación confirmada.

Ocultamiento excluye público/Explorar/guardados/QR/permisos de fotos y se hereda
a avisos vinculados/avistamientos; revisión ordinaria no muestra avistamientos
ocultos. Nuevos avisos/avistamientos rechazados en búsquedas ocultas. No cambia
status del caso, contador de mascota ni historial de recuperación. Restauración
no revierte retiro/cierre ni ocultamiento de la búsqueda vinculada. Bytes/URLs
firmadas ya emitidos conservan límites de vigencia previos, sin prometer retirada
retroactiva. Proxy de foto autoriza/audita antes de obtener bytes.

UI con referencia aprobada de landing: crema/Arial/cápsulas, WebShell ancho
alineado, retorno glass flotante, ActionButton/TopToast/ContentSkeleton compartidos.
ConfirmationDialog nativo con foco/Escape/cancelación. Decisiones en radios con
etiquetas completas y área táctil, contador500, invalid/shake, shimmer/etiqueta
estable. Skeleton inicial y refresh con contenido conservado. Cabecera fuera del
reveal; no repetir por edición. Movimiento reducido y navegación por teclado.

Validación final web: typecheck y build Nuxt aprobados;25 pruebas de dominio,
DTO, repositorio/fuente, sesión cifrada, ViewModel, arquitectura y exclusividad
administrativa web aprobadas;6 pruebas de producción Nuxt aprobadas, incluyendo
SSR sin evidencia, Auth/rol, Origin/cookie/CSRF, proxy y reintento tras commit.
Chrome con fixture: acceso denegado/correcto y Enter, cola/revisión/foto, respuesta
perdida/replay único, restauración, cancelación de salida, revocación, teclado,
movimiento reducido y retorno landing/QR sin errores CSP/hidratación. Capturas
1440/731/390/320/1920 y320 texto200% revisadas, sin overflow ni acciones cortadas;
apps/mobile/build/ui-preview/moderation-web. No son demo hosted ni prueba Safari/
Firefox. Build/Chrome avisan de exports obsoleto de @vue/shared (DEP0155); no falla
la validación ni se cambian versiones por este incremento.

SQL: regresión completa40/40 aprobada con la implementación final. Después se
añadió un cuarto escenario de moderación para paginación22 recursos, herencia
de ocultamiento y decisiones competidoras: suite final de moderación4/4 aprobada
(incluye los3 casos ya presentes en la regresión completa). Cubre también rol/
revocación, auditoría, CAS entre denuncias, replay, grants, QR/fotos/público,
contador/estado intactos y repetición de run_all. PGlite usa una conexión y
encola solicitudes: no certifica contención hosted multiconexión. No se repite
Flutter419 ni APK porque no cambia código móvil. Comprobación de ausencia de
rutas administrativas Flutter incorporada a las pruebas de arquitectura web.

Durante QA se corrigió invocación de fetch nativo del navegador (ahora con
regresión), nombre accesible de la decisión y etiqueta durante primer envío.
Se sustituyó select por radios para evitar recortar opciones con texto200%.
Generación inicial bloqueada por archivos Windows al reescribir patches previos
idénticos; Build-RunAll ahora valida migraciones anteriores sin reescribirlos y
sigue generando030/bundle con los scripts versionados. Generación y repetición
SQL posteriores aprobadas; los generadores específicos de patch se mantienen.

Logs hu143-{generation,typecheck-final,platform-tests-final,build-final,
server-tests-final,browser-final,full-sql,sql-final}.log en apps/mobile/build.
Ficha/ADR/configuración distinguen evidencia local y confirmación remota.
Pendiente aplicar030 en desarrollo, configurar variables/asignar revisor en
servidor, actualizar Nuxt y demo real con revisor/cuenta ordinaria/revocación,
QR/lista/mapa y conflicto multiconexión. Despliegue/integración según autorización
posterior. Siguiente paso operativo: activar/validar esta entrega web; bloqueo/
apelación conservan sus historias y refinamiento, sin adelantar otro incremento.


## Patch029 aplicado según confirmación del usuario — 18/10/2026

El usuario confirma haber ejecutado el patch029 de HU-14.1. Se registra como
aplicado, sin inspección SQL remota independiente; no solicitar reaplicarlo.
Sustituye las referencias anteriores a029 pendiente. No se ejecutaron pruebas
nuevas de aplicación, SQL remoto, despliegue ni acciones GitHub por esta nota.

Siguiente: actualizar/reiniciar Flutter, abrir una ficha disponible, denunciar
con motivo/evidencia opcional y comprobar el recibo y que el caso sigue con el
mismo estado. Validación real ampliada de permisos/reintentos sigue sin evidencia
nueva. Integración en main no verificada aquí; rama local feature/content-reports.
Después corresponde HU-14.3/#45: cola de revisión y moderación con motivo,
permisos y auditoría. HU-14.2/#44 conserva refinamiento pendiente sobre qué
interacciones bloquea. Firebase/FCM fuera del alcance y sin bloquear el avance.
Validación documental: git diff --check.


## Denuncias de contenido — HU-14.1 / RF-22, issue #43 — 18/10/2026

El usuario confirma028 aplicado y autoriza pasar al siguiente incremento. Se
registra la confirmación sin nueva inspección remota ni exigir reaplicarlo.
Firebase/FCM queda fuera del alcance activo y de sus criterios de avance;
no es bloqueo ni tarea pendiente de esta entrega. ADR-068 sigue vigente.
La demo real de HU-13 no se inventa ni se considera acreditada por aplicar SQL.

Implementación local en feature/content-reports, conservando el trabajo existente.
Durante el trabajo se observa el commit externo afe4831 con las pruebas/auditoría
previas; no se hizo commit/push/PR, merge, despliegue ni cambio GitHub aquí.
Se conservan los estados remotos como última instantánea, sin cierre de historias.

Fichas de casos perdidos/búsquedas comunitarias/avisos/reportes anteriores y
revisión privada de avistamiento → Denunciar contenido → motivo obligatorio500
caracteres Unicode/evidencia escrita opcional1000 → Enviar denuncia → recibo
persistido con actor/fecha servidor/referencia. Sin adjuntos nuevos, ocultamiento,
bloqueo, decisión automática, apelación ni paneles/guards vacíos. La denuncia no
altera estado del caso, contador, historial de recuperación ni revisión del aviso.

Módulo content_reports con dominio/caso de uso/contrato, DTO/fuente/repositorio,
providers declarativos y estado/ViewModel autoDispose. Bootstrap/main inyectan
implementaciones; app/router compone slots en fichas/revisión. Shell/glass,
transición desde botón compartido, cover/stagger, inputs/contadores, toast/shake,
skeleton/shimmer reutilizados. Cabecera estable; edición no reinicia entrada.
Recibo solo tras confirmación remota; doble envío bloqueado. Respuesta ambigua
congela orden/contenido para repetir el mismo UUID; conflicto bloquea cambios.
Cambio/error de sesión/disposición descarta respuestas tardías y oculta datos;
recuperación de la misma cuenta permite empezar limpio. Salida con borrador o
resultado ambiguo pide confirmación. Borrador durable offline corresponde a HU-15.

SQL099–101/plan029, migración y patch generados; run_all regenerado con los scripts
versionados, sin cambiar SQL028 aplicado. RLS/tablas sin grants directos de
cliente/servicio. RPC autoriza visibilidad mediante proyecciones existentes y
acceso privado a cronología para avistamientos; UUID serializado/replay/conflicto.
Recibo repetible tras retirar el recurso, nuevo envío exige visibilidad vigente.
Lectura de denuncia solo por su denunciante o revisor asignado por servidor;
registro privado de revisores sin autoasignación ni usuarios predeterminados.
No se expone evidencia al autor denunciado por el mero hecho de ser autor.

Validación Flutter: análisis final sin incidencias, formato de570 archivos sin
cambios.18 pruebas dirigidas aprobadas:7 del módulo,9 de arquitectura y2 recorridos
reales normal/pequeño que ahora incluyen entrar desde ficha comunitaria, guardar
recibo y retornar. Suite Flutter completa con concurrencia2:419 pruebas aprobadas.
Renders390×844/320×350 texto2 revisados en build/ui-preview/content-reports;
campos/acciones/recibo accesibles por scroll. Son fixtures, no demo Android hosted.

Tres escenarios SQL nuevos aprobados: permisos/Unicode/replay/conflicto y recurso
retirado, lectura privada/revisor/revocación/escalada, avistamiento autorizado y
solicitudes encoladas sin duplicado; incluyen repetición del bundle y ciclo de
vida operativo intacto. Regresión SQL completa:37 pruebas aprobadas,0 fallos (npm test).
PGlite usa una conexión,
no certifica contención hosted multiconexión. Sin cambios web ni build APK nuevo.

Logs hu14-{generation,analyze-final,format-final,tests-final,full-mobile,sql,
full-sql}.log en apps/mobile/build. Análisis inicial tuvo4 avisos de estilo,
corregidos; verificación final limpia. Actualizados ADR-070, ficha/índice,
arquitectura/diseño/configuración/guía y backlog local. No se da HU-14 completa.

Pendiente aplicar029 completo en desarrollo y actualizar Flutter; demo con
Supabase real para denunciante, autor, usuario ajeno y revisor asignado/revocado,
pérdida de respuesta y concurrencia multiconexión. Después continuar moderación
según las siguientes historias; bloqueo HU-14.2 conserva refinamiento pendiente.


## Auditoría ampliada de tarjetas en progreso — 18/10/2026

Por solicitud del usuario se revisaron las29 In progress, además del inventario
de51 elementos. Se detectaron motivos no reconciliados: integración en main
pendiente pese a PR fusionadas, cámara/principal/miniaturas todavía no
implementadas pese a PR54, o Android nunca revisado pese al recorrido real
del16/10. Se contrastó el árbol remoto main7367c5f y las PR53–60, pruebas
existentes/CI y confirmaciones de010/011,012/WASM/guardado,022/023/QR y025.

20 tarjetas más pasan a Done: #2/#4/#5/#6/#7/#9/#10/#17/#18/#20/#21/#22/
#23/#26/#27/#30/#31/#32/#33/#37. Se actualizaron29 cuerpos y las51 fichas
locales con Status/etiqueta/estado remoto;27 Done y cerrados,9 In progress,
2 Ready,13 Backlog,0 In review;24 issues abiertos. Verificación API de los51
sin desajustes. La clasificación refleja entrega integrada y evidencia posterior;
no se inventan demos o inspecciones nuevas de permisos hosted.

Pendientes específicos conservados: #1 por Google/baja/exportación; #19 por
retorno OAuth Android abierto/cerrado; #8/#34/#35 por impresión/escaneo físico
y hojas nativas guardar/compartir; #12/#40/#41 por integración de notifications
y demo actual; #13 por integración de case_closure,028 y demo. Árbol main contiene
0 fuentes de notifications y case_closure; no confundir pruebas locales412
aprobadas con esas integraciones. FCM sigue pospuesto. Ready #14/#43 sin iniciar.

Única red de producto nueva: consulta pública Google authorize sin seguir
redirecciones/login, HTTP302 a accounts.google.com con redirect_uri correcto
https://entrehuellas-supabase.kormind.com/auth/v1/callback. El antiguo fallo por
ruta duplicada no es actual. No se imprimen códigos/estado/tokens/client_id ni
se considera esa consulta una sesión OAuth completa.

Matriz en docs/backlog/AUDITORIA_2026-10-18.md; índice/fichas funcionales y
configuración coherentes con los motivos vigentes, historial conservado. JSON
antes/después, árbol main, plan/auditoría en apps/mobile/build/backlog-audit*.json
y backlog-audit-20261018. Sin pruebas de aplicación nuevas, SQL, despliegue,
cambio de prioridad/estimación/dependencias, commit/push o inicio de moderación.
Validación documental y git diff --check. Siguiente: integrar/validar HU-12/13;
resolver recorridos concretos retenidos o iniciar la denuncia preparada #43.


## Corrección de clasificación HU-03 — 18/10/2026

El usuario cuestiona HU-03 en In progress porque la considera ya terminada.
Revisión detecta motivos históricos de9/10 (fotos no implementadas/patch de
mascotas pendiente) mantenidos sin reconciliar con integración y avances
posteriores. Registro, consulta y edición con fotos están implementados e
integrados (PR53/54 fusionadas); pruebas de mascotas/fotos y regresión412
Flutter ya acreditadas. Se corrige HU-03/#3 y sus derivadas #28/#29 a Done.
No se atribuye al usuario una nueva demo detallada ni al agente nuevas pruebas
o inspección hosted; se corrige el seguimiento a partir de la revisión solicitada.

Verificados por API los51 elementos y etiquetas:7 Done,29 In progress,2 Ready,
13 Backlog,0 In review;44 issues abiertos/7 cerrados. #3/#28/#29 quedaron
cerrados tras moverlos a Done. Índice/fichas y ficha/índice funcional actualizados,
conservando el historial anterior. git diff --check sin errores. Sin código,
pruebas nuevas, SQL, despliegue ni commit/push. Los otros recorridos no pasan
a Done por arrastre; HU-12/13 conservan activación/aceptación pendientes y FCM
sigue pospuesto.


## Backlog de GitHub sincronizado por autorización del usuario — 18/10/2026

Consultados los51 elementos de Projects3, campos/status, cuerpos/etiquetas/estado
de issues y PR integradas. El usuario acepta explícitamente «Darlos por
aceptados y moverlos a Done» para HU-10.1 y HU-11: #36/#38/#39 y épica #11
pasan a Done; después se verifican los cuatro issues cerrados en GitHub. Se
comprobaron integración por PR60 y CI remoto Flutter/SQL/reader/photos aprobado.
No se atribuye inspección remota independiente a la aceptación comunicada.

Resultado:4 Done,32 In progress,2 Ready,13 Backlog y0 In review.21 tarjetas
cambian de estado;22 cuerpos actualizados con motivo/evidencia, incluido #42
FCM pospuesto. Se verificó por API el Status nativo y una sola etiqueta status:*
coincidente en los51 elementos;47 issues abiertos/4 cerrados. HU-12.1/#40 y
HU-12.2/#41 siguen In progress (027 confirmado, demo pendiente), HU-13/#13
In progress (028/demo pendientes); no se aceptan automáticamente los otros
recorridos. HU-14.1/#43 y su épica #14 Ready por criterios/dependencias disponibles.
FCM/Firebase #42 permanece Backlog/pospuesto (ADR-068); offline/cuenta/métricas
y needs:refinement de #44/#51 se conservan. Sin estimaciones nuevas.

Índice y51 fichas locales sincronizados; se conserva instantánea histórica
anterior. Actualizados los seguimientos de cronología y avistamientos web y el
índice funcional. Verificación documental y git diff --check; sin cambios de
código ni pruebas nuevas de app por esta sincronización. Capturas JSON de antes/
después, plan aplicado y auditoría en apps/mobile/build/backlog-sync-20261018
y backlog-{project,issues}-{before,after}.json, sin credenciales. Sin SQL,
despliegue, commit/push ni implementación de moderación. Siguiente paso operativo:
activar/verificar HU-13 y la bandeja; HU-14.1 está preparada como siguiente historia.


## Cierre y recuperación — HU-13 / RF-07, issue #13 — 18/10/2026

Implementación local en feature/case-recovery, creada conservando el trabajo
existente de HU-12. Se preservan cambios paralelos de landing y la decisión
ADR-068: FCM/Firebase pospuestos, sin activar emisor/cron.027 ya confirmado;
028 pendiente. Historia implementada localmente, sin cierre remoto de issue.

Ficha propia activa→Ya fue recuperada→Cierre→motivo/evidencia testimonial
opcional (texto500 por campo)→confirmación explícita→recibo persistido.
Ver recuperación desde ficha resuelta; registros anteriores sin datos inventados.
Módulo case_closure con dominio/casos de uso/contrato, DTO/fuente/repositorio,
providers declarativos y ViewModel autoDispose; inyección bootstrap/main y ruta
compuesta en app. Reutiliza shell/glass/cover/stagger/input/contador/toast/shake/
skeleton/shimmer. Título Cierre evita partir palabras en320px/texto2. Recibo como
etapa discreta; edición/carga no reinician reveal. Refresco conserva contenido y
Explorar conserva filtros al actualizar tras cierre.

Fuentes096–098/plan028, migración/patch generados con los scripts versionados;
run_all regenerado sin editar SQL aplicado. Tabla privada/RLS sin grants
cliente/servicio; lectura/escritura autentican responsable. Orden UUID congelada
ante respuesta ambigua; repetición devuelve recibo original, conflicto/cierre
exige consultar estado. Consulta fallida conserva borrador/reintento. Cambio/
error de cuenta y disposición descartan respuestas tardías y ocultan datos.
Salida con borrador o resultado ambiguo pide confirmación.

Transacción bloquea mascota→caso, registra actor/fecha servidor/motivo/nota,
actualiza estado/contador e historial y cancela pendientes/leases de difusión de
búsqueda. Contador inconsistente falla y revierte, sin corregirlo silenciosamente.
Bandeja y notificación de cierre se conservan. RPC anterior conserva contrato y
permisos, delegando las acciones nuevas, sin backfill de cierres históricos.
QR previo conserva slug y refleja cierre neutro/fecha, sin motivo/nota; web/app
rechazan nuevos avistamientos, responsables pueden crear otro episodio con otro
UUID conservando el anterior. No cambia Nuxt ni amplía visibilidad de resueltos.
Push en tránsito no puede retirarse; FCM permanece pospuesto/inactivo.

Validación local:18 comprobaciones Flutter finales aprobadas (dominio, DTO/fallos
seguros, ViewModel, orden ambigua/doble envío, conflicto/consulta fallida,
cuenta/error de sesión/disposición, UI en390×844/320×350 texto2 y navegación
real desde ficha comunitaria, más9 reglas arquitectónicas). Renders revisados en
apps/mobile/build/ui-preview/case-closure; campos/acciones y recibo accesibles por
scroll. Análisis final limpio y formato de16 archivos comprobado. Primera suite
Flutter completa:410 aprobadas/2 fallos por el acceso a la ruta nueva desde la
redirección raíz; corregido y regresiones específicas aprobadas. Repetición
completa final con concurrencia2:412 pruebas aprobadas, sin fallos.

SQL/PostGIS:26 regresiones existentes y4 HU-12 aprobadas;4 escenarios HU-13
aprobados sobre la versión final (y escenario de rollback/mapa reforzado repetido).
Incluyen permisos/columnas privadas, reintentos/conflicto, repetición del bundle,
QR previo antes/después, rechazo web/app, historial/contador, episodio nuevo,
cancelación de lease, rollback ante fallo y contador inválido, solicitudes
competidoras encoladas y proyecciones activas/resueltas. npm test incorpora las
tres suites con concurrencia1. PGlite es una conexión; no certifica concurrencia
hosted multiconexión.17 pruebas de regresión Nuxt aprobadas sin cambios web propios.

APK debug intentado: vuelve a fallar antes de compilar por Gradle,
java.io.IOException: Unable to establish loopback connection. Sin APK nuevo.
Logs hu13-{generation,format-final,analyze-final,final-tests,full-mobile,
full-mobile-final,sql-final,sql-preflight-final,full-sql,platform-tests,
android-build}.log en apps/mobile/build. Fallos intermedios de pruebas fueron
corregidos; la evidencia final se distingue de las ejecuciones iniciales.

Pendiente ejecutar028 completo en desarrollo y actualizar Flutter; demo con
Supabase real, dos cuentas/sesiones, cierre concurrente y respuesta perdida,
QR ya emitido, rechazo de nuevos avisos, mapa/historial/bandeja y otro episodio.
Sin SQL remoto, despliegue ni acciones GitHub desde este trabajo. No se reactiva
FCM. Ficha/índice/ADR-069/arquitectura/diseño/guía/configuración/backlog actualizados.
Siguiente paso: activar/verificar HU-13; después HU-14, moderación.


**Distribución irregular solicitada — 18/10/2026:** se sustituye la alineación y el tamaño uniforme por huellas con tamaños, alturas, separaciones y giros diferentes, sobre el crema exterior. Diez en escritorio y cuatro en móvil. Build Nuxt y revisión Chrome en 1920/1440/731/390/320px (320 con texto al 200%) aprobados: tamaños y posiciones distintos, sin invadir el panel ni producir overflow o errores de página. Capturas closing-paws actualizadas. Sin despliegue; pendiente revisión del usuario.

## Huellitas del cierre sobre fondo crema — 18/10/2026

Por petición del usuario, las huellas de «Una huella tuya puede acercarlos a casa» pasan al fondo amarillento exterior. Un contenedor de presentación reserva bandas superior/inferior; el panel aurora conserva título y acciones. Diez huellas en escritorio y cuatro en móvil, decorativas y sin eventos.

Validación local: typecheck,17 pruebas y build Nuxt aprobados. Chrome en1920/1440/731/390/320px (320 con texto200%): huellas fuera del panel, sin overflow ni errores de página; capturas de escritorio/móvil revisadas en apps/mobile/build/ui-preview/closing-paws-*.png. Sin despliegue. Siguiente paso: revisión del usuario.

## FCM/Firebase pospuestos por el usuario — 18/10/2026

Por instrucción explícita, HU-12.3/#42 queda pospuesta y fuera del incremento
activo. HU-12.1/#40 y HU-12.2/#41 continúan como seguimiento y bandeja con
Supabase. Sustituye el requisito de activar Firebase/Edge/cron de las notas
anteriores; HU-12 completa no se declara cerrada. ADR-068 registra el recorte.

Retirados SDK firebase_core/firebase_messaging, adaptador Firebase, plugin Google
Services y permiso/metadata Android. Pub get actualizó lock y registrants sin
Firebase. Bootstrap conserva contrato no disponible y main no observa push;
campana abre bandeja sin registro del teléfono. La preferencia de teléfono de
HU-02 se conserva como elección futura guardada con texto explícito de pendiente,
sin pedir permisos ni registrar tokens. No se introduce un proveedor alternativo.

027 permanece aplicado según confirmación del usuario: sin modificación,
reaplicación ni reversión de su SQL. Se conservan suscripciones/bandeja/outbox,
contratos genéricos y emisor preparado, inactivos; quitada la entrada del emisor
en config.toml. No configurar secrets, desplegar esa carpeta (tampoco por deploy
global) ni programar entregas ahora. Los trabajos pendientes no se despachan.

Validación de este ajuste: flutter pub get aprobado, análisis limpio y formato
de6 archivos comprobado.30 pruebas Flutter aprobadas: seguimiento/bandeja,
preferencias, navegación y arquitectura; incluye recorrido real de campana
que confirma ausencia de observación/registro push. Renders390×844/320×350
texto2 regenerados y revisados en build/ui-preview/notifications. Sin nuevos
tests SQL, despliegue, cambios remotos, APK o comprobación de Gradle; no cambia
el esquema aplicado. Logs hu12-defer-fcm-{pub,format,analyze,tests}.log en
apps/mobile/build. Se preserva trabajo paralelo ajeno de case_closure/plan028.

Siguiente paso del alcance activo: reiniciar/actualizar Flutter y confirmar
seguimiento→evento nuevo→bandeja→leída/reentrada con Supabase real y dos cuentas.
FCM no bloquea esa validación ni continuar HU-13 tras confirmarla. Guía,
configuración, fichas/índice, arquitectura y backlog actualizados.

## Patch027 aplicado según confirmación del usuario — 18/10/2026

El usuario confirma haber ejecutado el patch027 de seguimiento/alertas.
Sustituye el pendiente de aplicación027 en las notas anteriores; no se solicita
reaplicarlo. Confirmación comunicada, sin inspección SQL remota independiente.
Pendiente actualizar/reiniciar Flutter y validar seguimiento/bandeja con sesión
real y un evento nuevo. Para completar push faltan configuración Firebase
Android, secrets/despliegue Edge notification-delivery y planificador seguro,
seguido de demo Android/FCM y reintentos. El bloqueo de build Gradle documentado
no se ha vuelto a comprobar. Sin pruebas nuevas por esta actualización
documental, ni cierre de historias, despliegue o cambios de GitHub.

## Seguimiento y alertas — HU-12.1/#40,12.2/#41,12.3/#42 — 18/10/2026

Implementación local en feature/following-notifications, creada desde
feature/case-timeline-review con árbol limpio. Se respeta026 y HU-11 ya
confirmados por el usuario; no se pide reaplicarlos. Sin cambios de Nuxt.

Fichas→Seguir/Dejar de seguir; zonas propias→seguimiento explícito; campana
Inicio→bandeja paginada→Marcar leída/Abrir caso; preferencias existentes y
registro voluntario del teléfono. Guardados sigue siendo independiente.
Contratos/casos de uso de dominio, providers declarativos, ViewModels, estado,
DTO/repositorios/fuentes de notifications; composición mediante slots de app,
sin imports de UI/data entre funcionalidades. Reutiliza shell/reveal/glass,
superficies/toast/skeleton/shimmer, refresh con datos conservados e identidad
protegida. Órdenes de seguimiento UUID/CAS con recibo original en reintentos;
doble envío bloqueado y resultados tardíos descartados. Registro/borrado de
tokens serializados para evitar carrera entre logout y cambio de cuenta.

Plan027/fuentes091–095, migración y patch generados, run_all ampliado sin
reescribir migraciones aplicadas. Tablas privadas/RLS sin grants directos.
Destinatarios por seguimiento/preferencias y distancia a zona pública aproximada,
sin GPS continuo. Eventos nuevos de publicación, avistamientos web/app,
avisos vinculados, revisión y cierre guardan alerta/outbox atómicamente;
deduplicación por evento/cuenta y sin backfill. Lectura por cuenta y destino
con autorización actual; avisos sin evidencia/comentarios/coordenadas privados.

Edge notification-delivery preparada con secreto de máquina, FCM HTTP v1/OAuth
solo servidor, claim/lease/expiración, revalidación de caso/preferencias/seguimiento,
backoff y tokens inválidos. Push neutro abre bandeja tras login/onboarding.
La bandeja permanece si falla el proveedor. Aceptación no acredita llegada;
respuesta perdida puede repetir push/tag estable, sin duplicar la bandeja.
Cierre posterior a claim/aceptación no retira mensajes en tránsito; TTL60s.
App sin configuración Firebase mantiene bandeja/seguimiento operativos.

Validación local:23 pruebas finales Flutter (dominio, repositorio/DTO, ViewModels,
reintento ambiguo/conflicto, cuenta/sesión/disposición, retiro de token, UI,
navegación desde campana/push con y sin sesión y9 comprobaciones arquitectónicas)
aprobadas.40 regresiones Flutter previas aprobadas. Renders390×844 y320×350
con texto2 revisados en apps/mobile/build/ui-preview/notifications; scroll permite
alcanzar lectura/acciones. Fixtures locales, sin acreditar permisos/token reales.
Suite SQL existente26/26 y4 nuevos escenarios SQL/PostGIS aprobados; cubren
cuentas/grants, CAS/replay, destinatarios/radios/tipos/pausa, páginas/leído,
deduplicación, outbox/leases/vencimiento, fallos/tokens y cancelación tras cierre
o cambios de preferencias/suscripción.6 pruebas servidor con proveedor/OAuth
simulados aprobadas y Deno check de Edge aprobado.

Primer intento de suite Flutter completa en paralelo abortó tras79 pruebas
por Out of memory de Dart VM; log hu12-full-mobile.log conservado. Repetición
secuencial completa:403 pruebas aprobadas (hu12-full-mobile-sequential.log).
Las23 comprobaciones específicas/arquitectónicas se ejecutaron también sobre
los ajustes finales y aprobaron. Análisis final limpio y formato comprobado.
Dos intentos de APK debug (normal/IPv4) fallaron antes de compilar por Gradle:
java.io.IOException: Unable to establish loopback connection. No APK nuevo
acreditado. Logs hu12-{final-tests,mobile-tests,sql,full-sql,push-tests,edge-check,
analyze-final,format-final,android-build,android-ipv4}.log en apps/mobile/build.

Pendiente aplicar027 en desarrollo, actualizar Flutter, configurar Firebase
(JSON nativo/defines públicos del mismo proyecto), secrets Edge y planificador
servidor; probar Android/Supabase/FCM reales, app terminada, permisos, dos sesiones
concurrentes y logout offline. No hay despliegue, SQL remoto, cron activo,
commit/push ni modificaciones de GitHub. Historias abiertas por activación/demo
pendientes. Siguiente paso: activar y validar HU-12 antes de continuar HU-13.
Ficha/índice/ADR-067/arquitectura/guía/configuración/backlog actualizados.

## HU-11 operativa según confirmación del usuario — 18/10/2026

Después de confirmar la aplicación026 y recibir los pasos de validación Android,
el usuario indica «ok perfecto, ya esta». Se registra su confirmación del recorrido
para dar por finalizado el incremento funcional HU-11.1/#38 y HU-11.2/#39:
cronología y revisión privada de avistamientos. Sustituye el pendiente de
confirmación operativa de las notas anteriores. Evidencia comunicada por el
usuario, sin inspección remota independiente ni certificación detallada de todos
los escenarios de aislamiento, concurrencia multiconexión o pérdida de respuesta.
No se cierran issues/épica en GitHub ni se integra/publica la rama desde este chat.
Sin nuevas pruebas de código por esta actualización documental. Siguiente
incremento del backlog: HU-12, seguimiento y alertas/bandeja persistente.

## Patch026 aplicado según confirmación del usuario — 18/10/2026

El usuario confirma haber ejecutado el patch026 de cronología/revisión.
Sustituye el pendiente de aplicación026 de las notas anteriores; no se solicita
reaplicarlo. Confirmación comunicada, sin inspección SQL remota independiente.
Falta actualizar/reiniciar Flutter con el código de HU-11 y validar en Android
autenticado: ficha propia→Ver historial→avistamiento web/app→foto/punto privados→
clasificación con motivo→auditoría persistida al volver a entrar. Comprobar
usuario ajeno, caso cerrado y reintentos/conflictos con dos sesiones. No requiere
actualizar Nuxt por HU-11. Sin nuevas pruebas de código por esta confirmación
documental ni cierre de historias, despliegue o cambios de GitHub.

## Detalle superpuesto trasladado al footer — 18/10/2026

El usuario aclara que «última sección» significa el footer situado debajo del
cierre. LandingSideNote se mueve exclusivamente al footer; conserva posición
absoluta, mancha irregular, huellas SVG y Kalam local. Sin reserva de espacio
ni modificación del contenido; z2/pointer-events none superpone el detalle sin
interceptar enlaces. Footer usa aislamiento de apilado local. Oculto bajo1100px.
Esta nota sustituye la ubicación en el cierre indicada anteriormente.
Build aislado aprobado. Renders1920/1440/1100/731/390/320px comprobados sin
overflow; comparación geométrica con/sin adorno confirma que texto y mascotas
del footer no se desplazan. Kalam cargada; captura1440-footer-overlay revisada
en apps/mobile/build/ui-preview/landing-paws. Superposición visual sobre la
mascota derecha conservada según autorización del usuario. No se repite suite
completa por el traslado; Safari/Firefox pendientes. Sin despliegue ni commit/push.

## Mancha superpuesta en última sección — 18/10/2026

Por corrección explícita del usuario, LandingSideNote pasa de beneficios al
cierre. Retirado padding/min-height reservados en beneficios: el adorno es
absoluto z2 a la derecha, sin desplazar contenido. Formas SVG con contornos
irregulares verde/crema/durazno, huellas originales y corazones; superposición
visual permitida, pointer-events none conserva acciones. Oculto bajo1100px.
Kalam Regular local (SIL OFL con licencia incluida) sustituye Arial cursiva solo
en su frase por petición manuscrita; no se afirma fuente exacta de la captura.
Actualizados ADR-063, reglas web, manifiesto y ficha. Sin alcance funcional nuevo.

Typecheck/build aislado aprobados. QA navegador completo aprobado: responsive,
texto200%, FAQ/teclado/anclas, movimiento reducido, SSR sin JS, CSP/hidratación
y landing→QR→landing. Renders1920/1440/1100/731/390/320px sin overflow en
apps/mobile/build/ui-preview/landing-paws/*-closing.png. Verificación geométrica
compara título/acciones con y sin adorno y confirma posiciones idénticas; fuente
manuscrita cargada. Sin despliegue, commit/push ni cambios de backend. Siguiente
paso: valoración del usuario; Safari/Firefox pendientes.

## Cronología y revisión privada — HU-11.1/#38 y HU-11.2/#39 — 18/10/2026

Implementación local en feature/case-timeline-review, creada desde
feature/android-sightings con árbol limpio. El usuario indicó «ok ya esta» tras
las instrucciones de activar025; se registra confirmación comunicada, sin
inspección remota ni demo detallada independiente. No se solicita reaplicar025.
Los cambios de landing/documentación surgidos en paralelo se conservan; este
incremento no implementa UI web ni cambia el lector QR.

RF-12,14: ficha propia→Ver historial→cronología→avistamiento→evidencia privada→
clasificación/motivo→decisión persistida e historial. Publicación/recuperación
registradas y avistamientos web/app se ordenan por hora del suceso, recepción y
tardíos separados. Páginas estables y foto solo por consulta explícita; punto
exacto, comentario y foto disponibles solo al responsable. Confirmado no equivale
a ubicación actual ni a recuperación. Caso cerrado conserva lectura y bloquea
nuevas revisiones. Avisos públicos previos de found_cases mantienen su recorrido,
sin conversión automática ni eventos/auditoría inventados.

Módulo case_timeline con dominio/casos de uso/contrato, providers declarativos,
ViewModels autoDispose, estado, pantallas, DTO y data. SDK solo en fuente,
composición en bootstrap/router y slots en fichas, sin UI entre funcionalidades.
Reutiliza shells, glass, cover/stagger, surfaces, mapa, selectores, inputs,
toast/invalid/shake y shimmer. Foto limitada visualmente a320px para conservar
acciones accesibles; mapa de lectura/navegación usa precisión GPS registrada,
sin precisión ficticia para manual. Renders normales/pequeños revisados.

Fuentes088–090/plan026, migración y patch generados, run_all regenerado sin
reescribir025. RPC autentican propietario en cada consulta/acción/foto; no hay
grants directos sobre tablas ni secretos nuevos. sighting_reviews append-only
con actor/fecha servidor, motivo, estado anterior/nuevo y versión. Útil/Dudoso/
Rechazado/Confirmado admiten reclasificar a otra distinta en caso abierto.
UUID estable y CAS evitan doble decisión y sobrescritura obsoleta. Respuesta
ambigua congela la orden, conflicto exige actualizar conservando el formulario;
la UI confirma solo tras recibo guardado. Historial paginado conserva todas las
decisiones. Errores de permiso/cambio de cuenta ocultan datos; respuestas tardías
y disposición no restauran evidencia anterior.

Validación local: análisis Flutter limpio, formato sin cambios pendientes y28
pruebas Flutter aprobadas (dominio, VM, DTO/fallos seguros, fotos, error de sesión
y recuperación de misma cuenta, disposición, arquitectura y navegación desde
ficha en ambos tamaños). Renders390×844 y320×350/texto2 con fixtures/teselas
neutras: historial, detalle, foto, formulario y auditoría en
apps/mobile/build/ui-preview/case-timeline. Suite SQL completa26 pruebas
aprobadas: incluye dos usuarios/roles, evidencia privada, orden observado,
páginas, motivos/cuatro estados, reintento original tras revisiones/cierre,
conflicto CAS, eliminación y repetición. Tras el ajuste final de normalización
Unicode del motivo, una ejecución conjunta se interrumpió tras9 casos aprobados
sin aserción fallida; la comprobación final ejecutó los26 casos secuencialmente
en procesos separados y todos aprobaron. Log del intento interrumpido conservado
en hu11-full-sql-aborted.log. PGlite y repositorios sustituidos no
certifican Supabase hosted ni concurrencia multiconexión. Logs
hu11-{analyze,format,mobile-tests,sql,sql-preflight,full-sql}.log en apps/mobile/build.

Pendiente aplicar026 en desarrollo y probar Flutter con Supabase real: casos
propio/comunitario, foto y mapa privados, usuario ajeno, cierre, dos sesiones
revisando la misma versión y respuesta perdida tras guardar. Sin APK nuevo,
build Android, SQL remoto, despliegue, commit/push o modificaciones de GitHub.
No hay nuevo servidor Nuxt que activar para estas lecturas/revisiones. Historias
sin cerrar por evidencia local. Ficha/índice/ADR-066/arquitectura/guía/diseño/
configuración/backlog actualizados. Siguiente incremento funcional HU-12,
bandeja/alertas, después de activar y validar HU-11.

## Detalle lateral derecho de comunidad — 18/10/2026

Aclaración del usuario: la referencia debe ser un adorno lateral, sin sección
nueva. LandingSideNote se integra dentro de beneficios, al costado derecho:
190×285px, formas orgánicas salvia/durazno, frase pequeña inclinada, corazones
SVG y LandingPawTrail con siluetas del SVG original. Reserva240px de lateral
en escritorio≥1100px; se oculta en anchos menores para conservar el contenido
y evitar convertirlo en un bloque. Decorativo aria-hidden, sin interacción ni
movimiento nuevo; conserva las huellas grandes anteriores. Sin cambios de
alcance funcional, HU/RF/issues, permisos o backend.

Typecheck y build aislado aprobados. QA responsive/200%/teclado/FAQ/anclas,
SSR sin JS, CSP/hidratación y navegación QR aprobado antes del ajuste final de
especificidad del padding lateral. Primer intento de QA falló al decodificar
una imagen; repetición completa aprobada. Revisión visual detectó padding
sobrescrito y se corrigió reservando el lateral mediante selector específico.
Build final aprobado; renders1920/1440/1100/731/390/320px revisados en
apps/mobile/build/ui-preview/landing-paws/*-side-note.png. Comprobación geométrica
confirma separación entre adorno y tarjetas en escritorio, sin overflow global.
Sin despliegue ni commit/push; valoración del usuario y Safari/Firefox pendientes.

## Retorno al diseño con huellas ampliadas — 18/10/2026

Por petición del usuario se retira el último bloque añadido de ondas, frase y
corazones, junto con sus estilos. Se recupera la landing anterior con las huellas
grandes distribuidas en hero, oportunidad y cierre. Sin cambios en otros trabajos,
sin despliegue. Comprobación de diferencias sin errores; no se repite build.

## Huellas ampliadas según referencias — 18/10/2026

El usuario pide huellas mayores y más distribuidas como en sus dos referencias,
usando nuestro SVG. Sustituye el primer ajuste de pares pequeños: LandingPawTrail
ahora distribuye cuatro siluetas de logo/only.svg por los bordes de hero,
oportunidad y cierre (12 en escritorio, 10 en móvil). Máscaras CSS del recurso
original, sin modificarlo, en salvia/celeste/durazno suaves con opacidad0.36;
tamaños34–130px según posición/viewport. Sin movimiento adicional, interacción
ni anuncios accesibles. En móvil oportunidad conserva solo dos huellas, junto
a las mascotas y lejos del texto. No cambia alcance funcional ni HU/RF/issues.

Typecheck y build aislado aprobados. QA de navegador existente aprobado:
1440/731/390/320px, texto200%, FAQ/teclado/anclas, movimiento reducido, SSR sin
JS, CSP/hidratación y navegación landing→QR→landing. Renders adicionales1920px
y capturas revisadas en apps/mobile/build/ui-preview/landing-paws, sin overflow.
No se repiten pruebas de dominio por este cambio puramente decorativo.
Ficha/manifiesto actualizados; sin despliegue ni commit/push. Siguiente paso:
valoración visual del usuario; Safari/Firefox pendientes.

## Huellitas sutiles en la landing — 18/10/2026

Solicitud visual del usuario: tres pares pequeños en hero, oportunidad y cierre,
combinando LandingIcon/paw con `logo/only.svg`, copiado sin modificar a recursos
públicos. Widget LandingPawTrail reutilizado, opacidad suave, proporción original,
sin animaciones adicionales ni interacción y aria-hidden. Ajustado el par de
oportunidad a la esquina inferior tras revisar móvil para evitar el título.
Sin cambios de alcance, HU/RF/issues, permisos ni backend. Se conservan los
archivos SQL locales existentes en feature/case-timeline-review.

Typecheck, 17 pruebas existentes y build de producción aprobados; build aislado
con NUXT_BUILD_DIR=.nuxt-landing-paws-qa para conservar el servidor dev existente.
Chrome local: renders1920/1440/731/390/320px sin overflow, tres pares y SVG
decodificado. Capturas revisadas en apps/mobile/build/ui-preview/landing-paws;
log de build en apps/mobile/build/landing-paws-build.log. Ficha y manifiesto de
recursos actualizados. QA de navegador existente aprobado: responsive, texto200%,
teclado/FAQ/anclas, movimiento reducido, SSR sin JS, CSP/hidratación y navegación
landing→QR→landing. Sin publicación, commit/push ni despliegue.
Siguiente paso: valoración visual del usuario; Safari/Firefox no verificados.

## Avistamientos Android — HU-10.2 / RF-11 / #37 — 18/10/2026

Implementación local en feature/android-sightings, creada desde
feature/public-web-sighting conservando los cambios previos de este documento
y avistamientos-web.md. Ficha abierta→Reportar avistamiento→La vi→fecha/hora
real→punto manual/GPS→comentario/foto opcionales→recibo persistido→retorno.
Cámara/galería, denegación GPS con alternativa manual, formulario conservado,
doble envío bloqueado y orden congelada tras resultado ambiguo. Cambio de cuenta
oculta datos anteriores y descarta respuestas tardías. No convierte estos
registros privados en avisos públicos ni cambia la custodia anterior.

Módulo móvil sightings con dominio/contratos/casos de uso, providers declarativos,
ViewModel autoDispose, estado, pantalla, DTO y data inyectada desde bootstrap.
Router compone destino fijo; shell/fecha/mapa/galería/toast/shake/shimmer compartidos.
Capturas390×844 y320×350/texto2 revisadas; título breve evita partir palabras,
scroll permite llegar a todas las acciones y recibo. Teselas neutras/fixtures,
sin acreditar fotos, cartografía o permisos reales de Android.

Nuxt incorpora ruta nativa autenticada; verifica bearer contra Supabase Auth y
rechaza usuarios anónimos e identidad aportada por cliente. Reutiliza parser
acotado, validación, saneamiento sharp sin EXIF y repositorio del flujo web.
Plan025/fuentes086–087 y patch/migración generados: persistencia SQL común,
reporter_id verificado, reintento ligado a actor, presupuestos y evidencia privada.
Retira FK hacia enlace QR para aceptar casos sin cartel; comandos validan caso
bajo bloqueos. RPC app solo servidor; no hay grants de cliente para tabla/evidencia.
Web conserva revocación/vigencia QR y su contrato de recibo. ADR-065 documenta
alternativas, retención lógica y límites de bytea.

Validación local: formato de507 archivos sin cambios pendientes, análisis Flutter
sin incidencias,18 pruebas de dominio/VM/formulario/arquitectura/navegación
aprobadas, incluidas entrada desde ficha y retorno a custodia en ambos tamaños.
17 pruebas web y5 pruebas del servidor compilado aprobadas: sesión inválida,
Origin, futuro, envío nativo, pérdida de respuesta tras commit y reintento único.
Typecheck y build Nuxt producción aprobados; build aislado en .nuxt-hu10-2-qa
conserva servidor dev del usuario. Suite SQL completa25 pruebas aprobadas:
roles, actor incorrecto, fecha, cierre, caso sin QR, idempotencia y repetición.
Logs hu10-2-{format,analyze,mobile-tests,web-typecheck,web-tests,web-build,
production,sql,full-sql}.log y renders build/ui-preview/android-sightings
en apps/mobile/build. La evidencia HTTP usa backend fixture; SQL usa PGlite.

Pendiente aplicar025 en desarrollo, actualizar servidor y probar Android con
sesión real, GPS/cámara/galería, teselas/fotos, aislamiento hosted y concurrencia
multiconexión.022/023/024 ya confirmados; no se solicita reaplicarlos. Sin APK
nuevo, SQL remoto, despliegue, commit/push ni cambios de GitHub. Borrador en memoria,
sin recuperación tras muerte de proceso/offline HU-15. Historia sin cerrar por
evidencia local; cronología/revisión HU-11 y push permanecen pendientes.
Siguiente paso: activar025/servidor y confirmar demo Android antes de continuar
HU-11. Ficha Android/índice/guía/arquitectura/diseño/configuración/backlog actualizados.

## Avistamientos web operativos según confirmación del usuario — 18/10/2026

Tras informar que024 está aplicado y recibir los criterios de validación
integrada, el usuario confirma «ok si esta». Se registra su confirmación de
operación para dar por finalizado el incremento funcional HU-10.1/#36 y poder
continuar con el siguiente. Evidencia comunicada por el usuario; no es inspección
remota independiente ni certificación detallada de cada escenario de abuso,
concurrencia o navegador. Sustituye el pendiente de confirmación operativa de
la nota anterior. El ajuste de contraste del botón aprobado sigue registrado
como pendiente visual. No se cierran issues ni se integra/publica la rama desde
este chat. Siguiente incremento del backlog: HU-10.2/#37, avistamientos Android.

## Patch024 aplicado según confirmación del usuario — 18/10/2026

El usuario confirma haber aplicado024_patch_public_sightings.sql. Sustituye
el pendiente de aplicación024 de las notas anteriores; no se vuelve a solicitar.
Confirmación comunicada por el usuario, sin inspección SQL remota independiente.
HU-10.1 está implementada y validada localmente; falta confirmar que la revisión
web correspondiente esté desplegada y verificar envío/persistencia/reintento
desde un segundo teléfono, caso cerrado/revocado y aislamiento reales.
Se conserva el pendiente visual de contraste del primario aprobado.
La aplicación del patch por sí sola no cierra la historia ni acredita esos
recorridos. No se ejecutan nuevas pruebas de código por esta actualización
documental, ni se publica/despliega o modifica Supabase desde este chat.
Siguiente paso: validación integrada de la web con024 activo.

## Avistamientos desde QR sin cuenta — 18/10/2026

HU-10.1 / RF-11 / issue #36 implementada localmente en
feature/public-web-sighting, creada desde feature/vue-nuxt-web conservando
los cambios locales previos de móvil y las normas web actualizadas en paralelo.
Ficha activa→formulario→fecha/hora real→punto manual/GPS con origen/precisión→
comentario/foto opcionales→recibo guardado. Sin cuenta ni instalación. No cambia
Android HU-10.2, cronología/revisión HU-11, push u offline; historia sin cerrar.

Módulo sightings con contratos/SubmitSighting/LocateSighting independientes,
ViewModel para envíos/GPS/disposición y adaptadores HTTP/navegador/Supabase/sharp.
Página compone lector/formulario por slot; sin imports de UI entre features.
Plan024/fuentes083–085 y patch/migración generados: RPC solo servidor, tabla,
punto exacto y evidencia privados; fecha no futura/tardía>24h, vigencia bajo
bloqueo, UUID/hash estables y presupuestos persistentes por pseudónimo/caso.
No inventa owner de found_cases ni añade evidencia al DTO QR. JPEG/PNG/WebP
decodificados y recodificados a JPEG1280px/1MiB sin EXIF; bytea atómico evita
cargas huérfanas, con coste/escala y evolución a Storage explícitos en ADR-064.

WebShell/ActionButton/QR/formulario adoptan ADR-063: crema/Arial/azul/celeste,
cápsulas, marca minúscula, retorno glass con espacio propio y enlace a inicio.
Toast, invalid/Shake, campos conservados y shimmer real. Tras respuesta ambigua
se bloquea editar y se reintenta el mismo payload. GridLayer de Leaflet usa
imágenes de teselas normales evitando data-GIF y sin relajar nonce CSP con
unsafe-inline/data/eval. GPS/cámara solo self; POST con origen exacto, cuerpo
y tiempo acotados y concurrencia limitada. PUBLIC_WEB_ORIGIN documentado.

Validación local: typecheck limpio,15 pruebas web (incluidas arquitectura,
VM/GPS tardío, parser multipart acotado, fotos animadas/EXIF y normalización),
build Nuxt producción y4 pruebas de servidor aprobadas. Navegador Chrome142
sin cuenta: GPS denegado/manual, foto inválida/válida, fallo después de commit,
reintento único, cierre, foco, una cabecera, sin overflow/hidratación/CSP en
1440/731/390/320/1920 y320×350/texto200%. Renders fixture/teselas neutras en
apps/mobile/build/ui-preview/public-sightings; móvil y texto ampliado revisados.
Logs hu10-{typecheck,web-tests,web-build,production-tests,browser-qa,sql-tests}.log
en apps/mobile/build. SQL focalizado aprobado: roles, invariantes, idempotencia,
límites, cierre/revocación/ficha no disponible y repetición; suite SQL completa
con25 pruebas aprobadas en hu10-full-sql-tests.log. Un intento previo abortó
por memoria del equipo; el reintento con comprobaciones secuenciales completó
sin cambiar configuración global. Sin afirmación de concurrencia hosted.

Preflight Explorar:33 pruebas focalizadas aprobadas. En instalación debug
existente, attach/hot restart con config local y sesión recuperada, consulta
real Lima/15km con2 casos, fotos/teselas, pin→preview→ficha→retorno y arrastre
del panel comprobados; capturas hu10-map-preview/expanded.png y XML de navegación.
Sin nuevo APK ni arranque frío. Se deja la app y el servidor dev del usuario.

Pendientes materiales: aplicar024 en desarrollo y desplegar conjuntamente web;
022/023 ya confirmados por usuario, no se vuelven a marcar sin aplicar. Verificar
QR con otro teléfono, GPS/cámara/Safari/Firefox, proxy/TLS real, permisos y
concurrencia multiconexión, proveedor cartográfico y coste/volumen de evidencia.
Motor Docker Linux local no disponible: imagen/ejecución Linux no certificadas.
Contraste medido: texto/crema17.08:1, secundario/crema5.48:1 y azul/celeste5.03:1;
blanco/degradado azul aprobado1.97–3.62:1 no alcanza4.5:1. Conservada la referencia
explícita y registrado el ajuste accesible pendiente, sin certificar AA.

Siguiente paso: activar024/web en desarrollo y comprobar envío desde un segundo
teléfono antes de cerrar HU-10.1; resolver contraste del primario aprobado y
validación restante. Ficha avistamientos-web/índice/QR/Explorar/guía/arquitectura/
diseño/configuración/ADR-064 actualizados. Sin commit/push, SQL remoto o despliegue.

## Landing aprobada y norma de UI/UX para toda la web — 18/10/2026

El usuario confirma su aprobación de la landing terminada y pide documentar
su referencia para desarrollar el sistema web. REGLAS_UI_UX_WEB.md consolida
valores del CSS final: crema/azul/celeste/lima por variante, familia y jerarquía,
radios, espacios, cápsulas con brillo, ilustraciones, movimiento y responsive.
Distingue composición institucional de adaptación a formularios/listados,
con feedback/carga global, accesibilidad y criterios de aceptación.

ADR-063 extiende la referencia visual de ADR-060 a público/usuarios/administración
en apps/platform. Actualizados normas, diseño, arquitectura, guía, instrucciones,
guía de desarrollo y ficha/relevo de landing. El móvil conserva su referencia;
QR y paneles no se declaran adaptados. Sin nuevas HU/RF/issues ni cierre de historias.

Validación documental: valores cotejados con CSS/componentes, enlaces locales
comprobados y git diff --check sin incidencias. No se repiten builds ni pruebas
de app por cambio exclusivo de Markdown. Sin bloqueos documentales ni despliegue.
Siguiente paso: aplicar la norma al siguiente incremento web autorizado y registrar
su evidencia visual/funcional; contrastes y adaptación QR pendientes por recorrido.

## Vista previa: foto arriba y datos con iconos en fila —18/10/2026

Por corrección del usuario, ExploreMapPreviewContent coloca foto principal136
a ancho completo arriba, nombre debajo y fila de tamaño/raza/fecha con iconos.
La fila mantiene tres columnas y admite scroll horizontal con texto ampliado;
en poca altura se recorre toda la tarjeta verticalmente. Altura preferida de
la etiqueta adaptada; controles de coincidencias conservados fuera del scroll.
Sin cambios de lectura pública, dominio, permisos o SQL.

19 pruebas de mapa/preview/arquitectura aprobadas: nueva comprobación de foto
por encima de los datos y mismo eje horizontal de iconos, recorrido de datos
con texto2, apertura de ficha y mínimo del panel. Renders normales/pequeños
regenerados y revisados en build/ui-preview/explore-map/*-preview-photo.png;
log apps/mobile/build/map-preview-photo-top-qa.log. Formato y análisis limpios.
ADR-062/norma UI/diseño/ficha actualizados. Sin APK ni despliegue;
siguiente paso: revisión de composición en Android.

## Pines de marca y vista previa detallada del mapa —18/10/2026

Se integra copia exacta de logo/only-black.svg como pin negro mediante
flutter_svg2.2.1; grupos conservan la marca y contador. La etiqueta seleccionada
reutiliza CasePhotoView, EntityCardSurface, toast/shimmer y formateador de fecha:
foto principal, nombre, tamaño, raza ausente declarada y fecha local según
desaparición/encuentro/avistamiento, sin rótulo visible Abrir caso. Conserva
apertura al tocar y navegación entre coincidencias. Cámara/altura ajustadas al
mapa visible sobre el mínimo42%; datos con texto ampliado desplazables.

ReadExploreCasePreview usa contratos públicos lost_cases/found_cases ya
inyectados; ViewModel autoDispose por caso observa identidad y permite reintento.
No consulta catálogo, mascota privada ni cambia SQL/permisos. Raza no existe
en formularios/modelos actuales: Raza no registrada es la limitación explícita,
sin inferencia ni afirmación de captura/persistencia implementada.

35 pruebas aprobadas de preview/mapa/Explorar/borradores/arquitectura: SVG exacto,
orígenes coincidentes, foto/tamaño, fallos seguros, reintento, identidad y gestos;
en pequeño también valida datos accesibles y preview por encima del panel.
Formato/análisis sin incidencias y sintaxis PowerShell válida. SVG sincronizado
por el generador existente, sin ejecutar regeneración global de launchers.
Logs apps/mobile/build/map-detailed-preview-final-qa.log; renders con foto fixture
y teselas neutras revisados en build/ui-preview/explore-map/*-preview-photo.png
y *-preview-selected.png. Sin build Android, despliegue o certificación remota.
ADR-062/normas/diseño/arquitectura/guía/ficha/logo actualizados.
Siguiente paso: detener y volver a ejecutar la app para incorporar dependencia
y asset, y revisar mapa/foto/tamaño reales en Android.

## Estado vacío reutilizado en Explorar y Mascotas —18/10/2026

Por petición del usuario, se extrae el layout aprobado de Mis mascotas a
core/presentation/widgets/collection_empty_state.dart. CollectionEmptyState
compone huella/título/descripción/acción opcional con los mismos estilos y
espaciados. Mascotas conserva sus textos Activas/Archivadas y registro; Explorar
sustituye la línea No hay casos con estos filtros por No encontramos casos y
una sugerencia de cambiar ubicación/filtros. Solo tras vacío confirmado: no se
confunde con carga, fallo o ubicación faltante. Sin imports entre presentaciones
ni cambios de consultas, dominio, permisos o SQL.

30 pruebas de Explorar/carga y navegación de Mascotas/arquitectura aprobadas,
incluidas aserciones de componente compartido y ausencia durante fallo. Formato
y análisis sin incidencias. Renders con fuentes reales regenerados/revisados
en apps/mobile/build/ui-preview/explore/normal-empty.png y small-empty.png;
registro build/collection-empty-state-qa.log. Texto ampliado continúa por scroll.
Actualizadas fichas de ambas funcionalidades, diseño y arquitectura.
Sin build ni despliegue; siguiente paso: revisión Android del estado vacío.

## Mapa: mínimo normal, resistencia y retorno glass progresivo —18/10/2026

Por referencia e instrucción del usuario, panel inicial/mínimo42% y máximo90%.
Retirado estado14%, también al seleccionar pines; cámara/etiqueta reservan ahora
el panel normal. Intentar bajar del mínimo desplaza solo la superficie hasta18px
con resistencia y vuelve en240ms al soltar, sin reducir la extensión real.
Retorno glass pierde opacidad y sube en78–90%, recuperándose al bajar; oculto
sin interacción ni semántica. Movimiento reducido inmediato/sin rebote.
Se retira Filtros de búsqueda conservando campos/borrador/Aplicar filtros.

29 pruebas aprobadas:4 del mapa con gesto real, rebote, ocultación/retorno,
pines/ficha/consulta y tamaños normal/pequeño/texto2;25 de Explorar, borradores
y arquitectura. Formato/análisis sin incidencias. Logs en apps/mobile/build/
map-sheet-minimum-qa.log y map-sheet-related-qa.log. Capturas normales/expandidas
revisadas en build/ui-preview/explore-map con teselas neutras; no acreditan
cartografía o fluidez Android reales. Sin APK, SQL ni despliegue.
ADR-061, normas UI, diseño, arquitectura, guía y ficha actualizados; sustituye
el mínimo14% de ADR-055/056. Siguiente paso: revisar gesto y retorno en Android.

## Desplazamiento de la barra de navegación restaurado —18/10/2026

Causa reproducida en Home: ValueKey(section) en PullToRefresh desmontaba
también LiquidNavigation y su TweenAnimationBuilder en cada selección. La
animación existía y pasaba pruebas aisladas, pero saltaba al destino en la
composición real. Se traslada la clave al SingleChildScrollView: el contenido
se reinicia por sección y la barra conserva su estado y desplazamiento320ms.
Regresiones integradas verifican misma instancia, posición inicial/intermedia,
cambio de destino antes de terminar y movimiento reducido inmediato.

Formato y análisis sin incidencias;31 pruebas de Home/Explorar/recarga de
mascotas/arquitectura aprobadas. Evidencia local:
apps/mobile/build/home-navigation-animation-qa.log. Sin build Android ni
despliegue; siguiente paso: comprobar fluidez en el emulador con hot restart.
Ficha Inicio actualizada; títulos alineados y entrada única conservados.

## Títulos de Explorar y Mis mascotas alineados —18/10/2026

Por corrección del usuario, se reproduce diferencia vertical4px con fuentes
reales: CollectionHeader centraba cada texto según su acción48/56. La fila
compartida tiene ahora altura mínima56; no añade offsets por funcionalidad ni
duplica transiciones. Conserva cabeceras fuera del efecto, reserva del+ y una
sola consulta/entrada de Explorar. Regresión integrada compara coordenadas
de ambos títulos desde Inicio, durante carga/datos y90 fotogramas, en390×844
y320×350/texto2.35 pruebas de Explorar, mascotas, Home, colecciones gestionadas
y arquitectura aprobadas; análisis limpio. Dos regresiones repetidas para
generar capturas normales/pequeñas, revisadas en build/ui-preview/explore/
*-header-*.png; log apps/mobile/build/home-header-origin-renders.log;
sin build Android ni cambios de datos/SQL. Siguiente paso: revisión en Android.

## Una sola transición inicial en Explorar —18/10/2026

Reproducidas dos secuencias cover/stagger anidadas: Home y ExploreSection.
Home omite la exterior al componer Explorar real; la sección inicia su propio
cover seguido de stagger, con cabecera fuera. No cambia etapa al resolver la
carga. Nuevas regresiones desde Inicio verifican una sola entrada/consulta,
identidad de shimmer estable durante90 fotogramas y movimiento reducido.
La prueba de renders avanza fotogramas reales para completar cover y stagger,
en lugar de saltar tiempo y capturar el segundo efecto aún en opacidad cero.

36 pruebas de Explorar/Home/transiciones/arquitectura aprobadas y análisis sin
incidencias;12 pruebas de Explorar repetidas tras reforzar la visibilidad final.
Renders normal/pequeño con texto2 regenerados y revisados.
Evidencia apps/mobile/build/explore-single-entrance-qa.log y
explore-single-entrance-renders.log; sin build Android, SQL ni despliegue.
Siguiente paso: revisión de fluidez en Android; ficha Explorar actualizada.

## Cabecera estable al aparecer el+ de Mis mascotas —18/10/2026

Causa: con action=null CollectionHeader devolvía solo el texto; al resolver la
lista añadía una fila centrada con botón56 y cambiaba altura/ancho del título.
PetsSection reserva ahora el mismo espacio sin acción durante carga/vacío,
conservando el componente compartido y su adaptación en pantallas pequeñas.
Pruebas nuevas reproducen el cambio de geometría previo y verifican título y
filtros idénticos durante carga→lista→vacío en390×844 y320×350 con texto2.
Formato, análisis sin incidencias y16 pruebas de carga/arquitectura/navegación
aprobadas. Renders regenerados con fuentes reales y revisados en tamaño normal
y pequeño/texto2; evidencia apps/mobile/build/pets-header-layout-qa.log y
build/ui-preview/pets_*.png. Revisión Android pendiente. Sin cambios
de dominio, persistencia, permisos ni alcance HU-03/RF-03; ficha actualizada.

## Diagnóstico de Android tras mover Flutter a apps/mobile —18/10/2026

El error de dispositivo ausente se reproduce: no había emulador ejecutándose.
Se inicia el AVD existente Pixel_9a; ADB y flutter devices reconocen
emulator-5554 como Android16/API36 conectado, con arranque completado.
daemon.getSupportedPlatforms confirma Android en apps/mobile. Validados los
cuatro perfiles F5 (raíz y carpeta móvil): cwd, main.dart y archivo local
existentes. No se modifica main.dart ni se regenera el proyecto; se conserva
el cambio previo del usuario en .metadata. CONFIGURACION documenta recarga de
VS Code, selección del dispositivo y diferencia entre ID de AVD y dispositivo.

La prueba de flutter run alcanza Gradle, pero el primer intento falla en la
conexión loopback de Java. Un directorio temporal corto, limitado al proceso
de prueba, permite avanzar; después Java se interrumpe por falta de memoria.
El reintento con heap2GiB y dos workers solo mediante variables del proceso
también falla: desaparece el daemon y se genera hs_err_pid29020.log; el entorno
llega a impedir iniciar PowerShell por OutOfMemoryException. No se acredita
compilación/instalación. Siguiente paso: liberar memoria comprometida del equipo
y repetir F5 tras recargar la ventana del editor. flutter doctor también
detecta Command-line Tools ausentes y estado de licencias desconocido.
Sin cambios de producto, SQL, identificadores ni configuración global Java.

## Radio de cápsula uniforme en botones de landing —17/10/2026

Por instrucción del usuario, todos los botones comparten border-radius999px.
La regla base .button centraliza el radio y se retiran valores particulares de
cabecera/tablet/móvil; el control circular conserva su999px existente. Colores,
sombras y tamaños conservados. Chrome1440/731/390/320 comprueba todos los botones
con radio999px y sin overflow. Build SSR aislado en landing-all-buttons-radius-build.log;
sin despliegue. Siguiente paso: valoración visual del usuario.

## Botones azules con brillo y dog-report corregido —17/10/2026

El usuario precisa botones como las referencias: cápsula azul/celeste con
degradado vertical75BFFF→459FF6→2887EF, texto blanco, brillo superior y sombra
suave en cabecera/cierre. Se conservan botones lima de hero y secciones4/5.
Sustituye la propuesta intermedia de degradado celeste con texto oscuro.
Además pide imagegen para corregir la pata extra del perro en dog-report.png.
Edición integrada generada y copiada al recurso público:1312×1199 RGBA con
alpha real, cuatro extremidades del perro, pañuelos/emblemas/personajes
conservados. Ambas referencias web reciben la imagen nueva. Procedencia y
prompt en LANDING_ASSETS.md; dimensiones nativas y CSS de encuadre intactos.

Chrome1440/390/320 confirma estilos de cápsula, decodificación de ambos usos,
bytes servidos nuevos y sin overflow. Botones y ambos usos de ilustración
revisados en capturas locales ui-preview/glossy-buttons y report-anatomy.
Build/QA final en landing-glossy-buttons-anatomy-*.log en apps/mobile/build.
Sin despliegue. Siguiente paso: valoración visual del usuario.

## Corrección de fondos ausentes en hero y cierre —17/10/2026

El usuario detecta que ambas secciones quedaron blancas tras el ajuste anterior.
Causa: al consolidar gradientes se retiraron por error content/position/z-index/
inset de .aurora::before. Restauradas las cuatro propiedades compartidas;
hero conserva gradiente original y cierre su gradiente azul. Sin otros cambios
visuales. Las comprobaciones previas verificaban el color calculado, pero no
que existiera una capa generada: esa evidencia no acreditaba el fondo visible.

check-landing-browser.mjs verifica ahora en ambas secciones contenido generado,
visibilidad, opacidad y dimensiones que cubren el contenedor. Build SSR aislado y
QA Chrome1440/731/390/320/texto200%/FAQ/teclado/anclas/no-JS/CSP/hidratación/QR
aprobados. Capturas de hero/cierre1440 y390 generadas, ambas1440 revisadas.
Evidencia landing-aurora-fix-*.log y ui-preview/aurora-fix en apps/mobile/build.
Sin despliegue. Siguiente paso: revisión local del usuario.

## Colores anteriores en secciones4/5/6; cierre azul conservado —17/10/2026

Por solicitud del usuario, oportunidad, comunidad y colaboración recuperan
fondos, botones lima/celeste, numeración y etiquetas anteriores a la paleta azul.
El usuario corrige durante el trabajo que «Una huella tuya» debe conservar azul;
confirmado su gradiente y botones nuevos. Hero original, ajustes de geometría,
márgenes/altura y retirada de pines02/03 conservados.
Build SSR aislado aprobado. Chrome1440/390/320 verifica colores originales en
4/5/6, cierre azul y sin overflow; capturas escritorio de4/6 revisadas.
QA general en landing-sections-original-*.log y capturas ui-preview/sections-original
en apps/mobile/build. Sin despliegue. Siguiente paso: valoración del usuario.

## Propósito: numeración original y sin pines CSS —17/10/2026

Por instrucción del usuario, 01–04 recuperan el color original heredado171918.
Eliminados los pseudo-elementos de pin morado y trazo decorativo de las imágenes
02/03 (art-step-found/help); PNG y encuadres conservados. Build SSR aislado
aprobado. Chrome1440/390/320 confirma cuatro números con color original,
pseudo-elementos ausentes y sin overflow; captura1440 revisada. QA general en
landing-steps-cleanup-*.log y capturas ui-preview/steps-cleanup en apps/mobile/build.
Sin despliegue. Siguiente paso: valoración visual del usuario.

## Hero con sus colores anteriores —17/10/2026

Por corrección del usuario, restaurados solo los colores originales de la
primera sección: gradiente vivo, botones lima/celeste, badge, valores blancos
y fondos de mascotas. Alturas, márgenes, recursos y movimientos conservados;
las demás secciones y cabecera mantienen paleta azul. Reglas UI/ADR-060 actualizados.
Build SSR aislado aprobado. Chrome1440/390/320 confirma paleta original del hero,
azul del cierre y ausencia de overflow; captura1440 revisada. QA general de
landing/SSR/texto200%/QR registrado en landing-hero-original-colors-*.log y
capturas ui-preview/hero-original-colors en apps/mobile/build. Sin despliegue.
Siguiente paso: revisión visual del usuario.

## Landing: paleta acorde al nuevo logo azul —17/10/2026

Tras aprobar la propuesta, el usuario autoriza ajustar suavemente los colores.
Botones principales3C537B/blanco y secundarios celesteB5D5E9/azul; gradientes
del hero/cierre y tarjetas con azul/celeste/lavanda, verde residual suave en
decoraciones. Numeración y valores del hero azul profundo para legibilidad;
iconos2C87CE, FAQ abierto celeste tenue. Crema, textos oscuros, PNG, geometría,
pie, márgenes y animaciones conservados. Variantes semánticas de botones;
CSS aislado de QR/móvil. Actualizadas reglas UI y ADR-060.

Build SSR aislado, typecheck y9 pruebas web aprobados. QA Chrome en1440/731/
390/320px, texto200%, teclado/FAQ/anclas, SSR/no-JS, CSP/hidratación y navegación
landing→QR→landing aprobado. Comprobación adicional hasta1920px sin overflow.
Contraste de acciones7.73:1 azul/blanco y5.03:1 azul/celeste, AA; capturas de
hero escritorio/móvil, beneficios y cierre revisadas. Evidencia local:
apps/mobile/build/landing-blue-palette-*.log y ui-preview/blue-palette.
Sin despliegue ni cambios de producto; siguiente paso: valoración del usuario.

## Nueva exportación del logo de23:30 —17/10/2026

Sincronizada la última exportación del usuario mediante el generador existente:
marca PNG/SVG web, favicon, Flutter, splash Android y catálogos de iconos
Android/iOS/macOS/Windows/web. Gradiente sin cambios; diseño del pie conservado.
Verificadas cinco copias idénticas a sus originales,40 PNG/ICO legibles y
cuadrados, y respuestas HTTP200 con bytes nuevos de PNG/SVG/favicon en5173.
Favicon revisado visualmente. Sin cambios de código ni repetición de suites
ya aprobadas; sin nuevo build ni despliegue. Siguiente paso: revisión del usuario;
launcher instalado requiere recompilar/reinstalar.

## Pie más próximo al cierre y última exportación del logo —17/10/2026

Tras aprobar el encuadre, el usuario pide reducir el margen superior del pie:
clamp(24px,3vw,48px), antes40–88px compartidos. Texto entre mascotas, tamaños
y altura del cierre conservados. Sincronizadas de nuevo las cinco copias PNG/SVG
oficiales y regenerados splash/launchers Android, iOS/macOS, Windows y web/PWA
desde las exportaciones renovadas por el usuario; fuentes intactas.

Build SSR aislado aprobado, análisis Flutter sin incidencias y11 pruebas de
arranque/arquitectura aprobadas. Chrome1920/1440/731/390/320 verifica margen
48/43.2/24/24/24px, proporciones originales y logo servido idéntico a su fuente;
cinco copias oficiales verificadas byte a byte. Captura1440 revisada.
QA web y logs landing-footer-gap-logo-*; capturas ui-preview/footer-gap-logo
en apps/mobile/build. Sin build/instalación nativa ni despliegue. Siguiente paso:
revisión local del usuario; launcher requiere recompilar/reinstalar Android.

## Pie: texto entre mascotas, ligeramente elevado —17/10/2026

Aclaración del usuario: el texto debe quedar entre ambas imágenes y solo un
poco más arriba que la referencia original. En escritorio comparte fila con
las mascotas, centrado verticalmente con elevación20–40px; ancho36% para separar
los enlaces de las figuras. Mascotas conservan39% y encuadre completo, cerca de
los laterales. Móvil conserva texto arriba y figuras50% debajo. Cierre alto
intacto. Sustituye la fila separada del contenido del ajuste anterior.

Build SSR aislado aprobado. Geometría Chrome en1920/1440/731/390/320px confirma
proporciones, texto dentro del pie y sin overflow/recorte; capturas1920/731
revisadas. QA general: responsive/texto200%/FAQ/teclado/anclas/SSR/no-JS/CSP/
hidratación/QR, logs landing-footer-centered-* y capturas ui-preview/footer-centered
en apps/mobile/build. Sin despliegue; siguiente paso: valoración del usuario.

## Corrección: conservar el tamaño original de mascotas del pie —17/10/2026

El usuario aclara que solo fallaba el recorte del contenedor. Restaurado el
ancho original39% por mascota en escritorio y50% en móvil. El pie reserva una
fila natural para las ilustraciones completas y mantiene los enlaces arriba;
el cierre superior conserva la altura ampliada solicitada. Sin editar PNG.
Build SSR aislado aprobado; Chrome1920/1440/731/390/320px confirma proporciones
originales, mascotas completas, texto separado y ausencia de overflow.
Captura1440 revisada en apps/mobile/build/ui-preview/footer-original-size.
QA general y resultados en landing-footer-original-size-*.log; sin despliegue.
Siguiente paso: valoración visual del usuario.

## Landing: mascotas completas en el pie y cierre más alto —17/10/2026

Por captura e instrucción del usuario, el pie usa columnas reales: mascotas
completas a los lados y contenido central alineado arriba. Se retiran posiciones
negativas y el recorte del contenedor que ocultaba las cabezas; enlaces sin
cruce con ilustraciones. En móvil, contenido arriba y mascotas en segunda fila.
El bloque «Una huella tuya» crece a420–640px mínimos (440px móvil), con contenido
centrado y espacio vertical amplio. Se conserva el servidor5173 y trabajo previo.

Build SSR aislado y QA Chrome de landing aprobados: responsive, texto200%,
FAQ/teclado/anclas, SSR/no-JS, CSP/hidratación y navegación QR. Comprobación
geométrica adicional en1920/1440/731/390/320px y320 con texto ampliado: mascotas
dentro del pie, sin superposición con texto ni overflow. Capturas de escritorio
y móvil revisadas en apps/mobile/build/ui-preview/footer; logs landing-footer-*
en apps/mobile/build. git diff --check aprobado. Sin publicación ni commit.
Siguiente paso: valoración visual del usuario.

## Logo azul sincronizado en todas las aplicaciones —17/10/2026

Petición del usuario tras renovar las exportaciones de logo/. Actualizadas
copias oficiales PNG/SVG en landing/lector QR/favicon, marca Flutter y splash
Android. Regenerados iconos Android clásicos/adaptativos/monocromáticos,
catálogos iOS/macOS, Windows y web/PWA. Colores de composición iOS/PWA alineados
con el gradiente azul. El generador sincroniza ahora las copias oficiales;
fuentes del usuario conservadas. No cambia la UI ni las ilustraciones con
estampados blancos de las variantes auxiliares que no se actualizaron.

Validación local: formato488 archivos sin cambios, flutter analyze sin
incidencias,11 pruebas Flutter de arranque/arquitectura y9 pruebas web aprobadas.
Cinco copias idénticas byte a byte a sus fuentes;40 PNG/ICO legibles y cuadrados;
cinco paths adaptativos con geometría/color del SVG oficial. Chrome sobre el
servidor5173 existente muestra el PNG nuevo en cabecera/pie, sin overflow en
1440×960 y320×640 con fuente raíz200%; capturas revisadas en
apps/mobile/build/ui-preview/brand-update. git diff --check aprobado.
Sin builds nativos, reinstalación ni despliegue. Siguiente paso: verificar el
launcher al recompilar/reinstalar Android; hot reload no actualiza ese recurso.
No implica cierre de historias ni confirmación remota. Ficha: identidad-visual.

## Landing: títulos de sección uniformes e imagen de comunidad más alta —17/10/2026

Por petición del usuario, todos los h2 de sección comparten el tamaño de
«Una comunidad con un propósito»: --section-title-size con clamp(29px, 4.3vw,
58px) y34px en móvil. Se eliminan tamaños específicos de secciones posteriores;
el hero conserva su h1. Los títulos permiten corte de palabras en móvil con
texto ampliado. Tarjeta de imagen de «La ayuda puede estar cerca» pasa de
305:123 a305:160, aproximadamente30% más alta a igual ancho, con contain.
Recursos, onda, márgenes y alineación conservados. Servidor5173 reutilizado.
Build SSR y QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados.
Igualdad de los siete títulos y proporción de tarjeta comprobadas en
1920/1440/731/390/320px, sin overflow; capturas escritorio/móvil revisadas.
Logs landing-heading-scale-*.log en apps/mobile/build. Sin commit/publicación;
siguiente paso: valoración visual del usuario y ajustes que indique.

## Landing: onda viajera amplia según referencias —17/10/2026

El usuario precisa una curva que avance de tarjeta en tarjeta. La onda6s
abarca ahora12 tarjetas con desfase progresivo0.5s hacia la derecha, amplitud
adaptable24–56px. Cada grupo contiene dos series visuales de las seis tarjetas;
las repeticiones son decorativas. Dos grupos iguales mantienen continuidad
espacial y temporal al cerrar el loop. Recorrido horizontal duplicado y duración
120s para conservar la velocidad previa en píxeles; botón pausa solo ese avance.
Marcos, PNG, hero, márgenes y movimiento reducido conservados.
Build SSR aislado y QA responsive/200%/FAQ/teclado/anclas/no-JS/CSP/hidratación/QR
pasados. Muestreo en0/1.5/3s confirma cresta progresiva, fases iguales entre
copias y continuidad entre tarjetas, incluida unión de grupos; velocidad
horizontal previa comprobada. Capturas de onda revisadas. Servidor5173
reutilizado; logs landing-traveling-wave-*.log en apps/mobile/build.
Sin commit/publicación; siguiente paso: valoración visual del usuario.

## Landing: separación entre secciones y onda más ágil —17/10/2026

Por petición del usuario, separación uniforme tras propósito y entre las
secciones restantes/pie mediante --section-gap: clamp(40px, 6vw, 88px).
Se conserva el espacio existente entre tarjetas y tercera sección.
Onda vertical de tarjetas acelerada de12s a6s, fases cada1s y curva suave
cubic-bezier(0.37, 0, 0.63, 1); amplitud, dimensiones y avance horizontal60s
conservados. Pausa solo horizontal y movimiento reducido siguen vigentes.
Build SSR aislado y QA responsive/200%/FAQ/anclas/no-JS/CSP/hidratación/QR
pasados. Separaciones medidas en1920/1440/731/390/320px, sin overflow;
muestreo de onda verifica continuidad del ciclo y desplazamiento suave.
Capturas escritorio/móvil revisadas; servidor5173 existente reutilizado.
Logs landing-spacing-wave-build.log y landing-spacing-wave-browser.log
en apps/mobile/build. Sin commit/publicación. Pendiente valoración visual del
usuario; siguiente paso: continuar los ajustes que indique.

## Landing: ancho unificado en todas las secciones —17/10/2026

Tras aprobar la tercera sección, el usuario extiende su alineación al resto.
El contenedor compartido `.wrap` usa ahora el ancho del hero, sin máximo1280px;
se elimina la regla duplicada de hero/propósito. Cabecera, secciones y pie
comparten márgenes; móvil conserva14px. Imágenes, tarjetas, altura de ventanas
de propósito y animaciones aprobadas conservadas. Servidor5173 reutilizado.
Build SSR aislado y QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR
pasados; diez contenedores con ancho y posición iguales en1920/1440/731/390/320px,
sin overflow. Capturas escritorio/móvil revisadas. Evidencia local:
apps/mobile/build/landing-sections-width-build.log y
landing-sections-width-browser.log. Sin commit/publicación; siguiente paso:
revisión visual del usuario y ajustes que indique, sin ampliar funcionalidades.

## Landing: ancho y altura de la tercera sección —17/10/2026

«Una comunidad con un propósito» comparte ahora ancho y márgenes del hero,
sin el límite anterior de1280px. Las cuatro ventanas de ilustración pasan de
proporción3.6:1 a3:1, un20% más altas a igual ancho. Recursos, hero, tarjetas
y movimientos aprobados conservados; servidor5173 existente reutilizado.
Build SSR aislado y QA de landing pasados (1440/731/390/320px, texto200%,
FAQ/teclado/anclas, no-JS, CSP/hidratación y aislamiento QR). Además se comprobó
igualdad de ancho/márgenes y ausencia de overflow en1440/1920/731/390/320px;
capturas de la sección revisadas en escritorio/móvil. Evidencia local:
apps/mobile/build/landing-purpose-build.log y landing-purpose-browser.log.
Sin publicación ni commit. Siguiente paso: revisión del usuario y continuar
con los ajustes que indique; no se cierran historias ni se amplía el alcance.

## Relevo al siguiente chat —17/10/2026

El usuario aprobó el diseño actual («ok esta perfecto») y continuará en otro
chat. Estado vigente, decisiones visuales, límites, archivos y validación en
[RELEVO_LANDING.md](RELEVO_LANDING.md). Leerlo antes de seguir: las notas
cronológicas inferiores incluyen enfoques ya sustituidos. Trabajo local sin
commit/push/despliegue; conservar cambios existentes. Siguiente paso: continuar
con las secciones que indique el usuario, sin rehacer hero, arte ni tarjetas.

## Aumento leve solo del marco —17/10/2026

Petición del usuario: un poco más alto/ancho, sin cambiar mascotas. Ajustadas
únicamente las dos dimensiones del marco: en1440px pasa de310 a325px de ancho
y aumenta24px de alto; en móvil aumenta8px de ancho/12px de alto. Ventana,
escala, imagen, botón y movimiento conservados. Build SSR y QA responsive/
200 %/SSR/no-JS/QR pasados, tamaño de arte previo verificado y captura revisada.
Registros apps/mobile/build/landing-card-small-increase-build.log y
landing-card-small-increase-browser.log. Sin publicación ni commit.

## Ancho aprobado restaurado; sin recorte interior —17/10/2026

Corrección del usuario: las tarjetas tenían el ancho correcto, solo fallaba
la ventana interior. Se restaura ancho base +12–24px, sin multiplicarlo por
la escala del arte. La ventana mantiene el tamaño de imagen y overflow visible:
ya no introduce un corte recto dentro de la tarjeta. Solo el marco exterior
redondeado delimita la ilustración. Botón60/icono28, espacio y onda conservados.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados, ancho310px comprobado en
1440px, ventana interior sin clipping, pausa horizontal/onda activa y separación
del botón. Captura revisada. Registros apps/mobile/build/landing-inner-window-
build.log y landing-inner-window-browser.log. Sin publicación ni commit.

## Ventanas ampliadas sin recortar mascotas —17/10/2026

El usuario identifica el recorte en art-help-dalmatian y pide conservar las
mascotas grandes. Se amplían ventana y marco al ancho de la imagen renderizada:
factor1.45 para individuales y1.85 para pareja; se conserva la altura visual
anterior. Imagen contain a tamaño de ventana, sin zoom/margen negativo interno.
Esto sustituye la ventana estrecha anterior: las tarjetas también quedan más
anchas para alojar completos los cuerpos/colas sin reducirlos. PNG intactos.

Botón circular60px con icono28px, arriba a la derecha. Mayor separación externa
40–72px y padding superior128–168px para bajar la fila y dejar espacio incluso
en la cresta de la onda. Pausa horizontal/onda vertical conservadas.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados; verificados alto de arte
conservado, ventana dentro del marco, imagen sin zoom recortado y separación
botón/tarjetas >=16px. Captura revisada. Registros apps/mobile/build/
landing-unclipped-frames-build.log y landing-unclipped-frames-browser.log.
Sin publicación ni commit.

## Restaurar escala de mascotas y control mayor —17/10/2026

Por corrección explícita del usuario se restaura el tamaño visual previo de las
mascotas: cover general, pareja185 % y dálmata145 %, manteniendo los marcos
mayores. Sustituye el contain general de la pasada anterior. Control circular
superior derecho ampliado76×76 (recupera el ancho de la cápsula original), con
pausa solo horizontal y onda continua. PNG y animaciones conservados.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados, incluido control circular
76px y pausa horizontal con onda activa. Captura revisada. Registros
apps/mobile/build/landing-restored-card-scale-build.log y
landing-restored-card-scale-browser.log. Sin publicación ni commit.

## Control circular arriba y mascotas sin recorte —17/10/2026

Petición posterior: botón superior derecho, circular44×44, conservando pausa
solo horizontal y onda activa. Se cambia cover por contain para todas las
imágenes de tarjetas y se retiran los zooms185 %/145 % de pareja/dálmata que
recortaban sus extremos. Ventanas y marcos conservados: las ilustraciones se
ajustan completas con su proporción nativa, por lo que ocupan menos altura.
No se alteran PNG, hero ni animaciones.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados, incluidos encuadre contain
sin márgenes de zoom, control circular superior, pausa horizontal/onda activa.
Captura revisada. Registros apps/mobile/build/landing-card-fit-build.log y
landing-card-fit-browser.log. Sin despliegue ni commit.

## Marcos mayores y pausa horizontal independiente —17/10/2026

Por petición explícita se amplían solo las tarjetas: ancho adicional12–24px
y alto adicional48–72px respecto al marco anterior. La ventana de arte conserva
el ancho previo145–288px (155px móvil), altura proporcional anterior y escalas
de cada mascota; centrada abajo. No se regeneran ni amplían las ilustraciones.
Control cápsula inferior derecha76×44 con pausa/play y nombre accesible alterno;
pausa/reanuda exclusivamente character-track. Character-wave sigue activa al
pausar el avance lateral. Sin pausa automática hover/foco; movimiento reducido
del sistema se conserva y oculta el control sin función en ese modo.

Build SSR y QA Chrome responsive/200 %/SSR/no-JS/FAQ/teclado/anclas/CSP/QR pasados.
Verificado tamaño de ventana anterior, marco mayor, transform horizontal estable
al pausar mientras cambia el vertical y reanudación horizontal. Captura revisada.
Registros apps/mobile/build/landing-card-frame-build.log y
landing-card-frame-browser.log. Sin despliegue ni commit.

## Onda continua en las tarjetas —17/10/2026

El usuario sustituye la alternancia fija por efecto de ola/gusanito suave:
cada tarjeta oscila verticalmente en12s con seis fases desfasadas2s, mientras
la fila avanza en horizontal con su ciclo60s. Grupos duplicados conservan fases
y anchura para continuidad. Se retiran botón/estado de pausa y pausas hover/foco
por petición explícita; se conserva la preferencia del sistema de movimiento
reducido. Más separación: margen32–64px y padding72–104px por lado vertical.
Etiquetas centradas con flex/text-align y peso400. Recursos y tamaños conservados.

Build SSR y QA Chrome responsive/200 %/no-JS/FAQ/teclado/anclas/CSP/QR pasados.
Verificados cambios reales de transform horizontal y vertical entre frames,
seis fases distintas, continuidad de grupos y movimiento activo durante hover.
Captura characters revisada. Registros apps/mobile/build/landing-character-wave-
build.log y landing-character-wave-browser.log. Sin publicación.

## Tarjetas escalonadas con desplazamiento horizontal —17/10/2026

Por petición del usuario: mayor espacio vertical alrededor de la fila, tarjetas
alternadas arriba/abajo y movimiento horizontal suave continuo. Se reutilizan
dos grupos de seis tarjetas con el segundo oculto para lectores de pantalla;
desplazamiento lineal de60s por ciclo, mismo ancho para cierre sin salto.
Pausa/reanudar real, pausa al hover/foco y sin movimiento con prefers-reduced-motion.
Las imágenes de la fila cargan anticipadamente para que las copias inicialmente
fuera de pantalla no entren vacías; resto de ilustraciones conserva lazy.
Dálmata ampliado al145 % y pareja al185 % en sus tarjetas, anclados abajo;
no se modifica ningún PNG ni otras apariciones. Hero y animación de entrada
conservados. Captura characters revisada: alternancia visible y tamaños equilibrados.

Build SSR y QA Chrome1440/731/390/320px, texto200 %, SSR/no-JS/FAQ/teclado/anclas,
CSP/hidratación/aislamiento QR pasados. Comprobado desplazamiento real entre frames,
anchos equivalentes con tolerancia subpíxel, pausa/reanudación y movimiento reducido.
Registros apps/mobile/build/landing-character-drift-build.log y
landing-character-drift-browser.log. Sin despliegue ni commit.

## Hero de primera pantalla —17/10/2026

Nueva petición explícita con referencia: primera sección ocupa la pantalla,
no un bloque compacto sobre las tarjetas. Hero usa min-height basado en100svh
menos cabecera/margen, ancho casi completo sin límite1280 y contenido centrado
verticalmente. Título hasta108px e ilustraciones hasta148px en escritorio;
móvil conserva su tipografía adaptada y permite crecer con texto ampliado.
Sin altura fija ni recorte del contenido. Marca minúscula, recursos y secuencia
de animación conservados. Build SSR y QA Chrome 1440/731/390/320px y200 %
pasados: imágenes/FAQ/teclado/anclas/no-JS/CSP/hidratación/aislamiento QR sin
incidencias. Capturas desktop-top/reference revisadas. Registros en
apps/mobile/build/landing-fullscreen-hero-build.log y
landing-fullscreen-hero-browser.log. Sin publicación.

## Hero más grande y marca en minúsculas —17/10/2026

Por petición del usuario se aumenta la primera sección: título hasta78px
(antes64), ilustraciones hasta120px (antes100) y mayor espacio vertical,
también en tablet/móvil. LandingBrand muestra «entre huellas» en cabecera y
footer con peso500 (antes750). Identidad gráfica conservada; no se alteran
los textos editoriales, el QR ni animaciones. Build SSR y QA Chrome responsive
1440/731/390/320px, texto200 %, FAQ/teclado/anclas/no-JS/aislamiento QR pasados;
capturas desktop y móvil ampliado revisadas, sin overflow. git diff --check
sin errores. Registros apps/mobile/build/landing-hero-size-build.log y
landing-hero-size-browser.log. Sin despliegue.

## Imágenes anteriores restauradas solo en el hero —17/10/2026

Por petición del usuario se recuperan los PNG anteriores del perro y gato del
inicio desde la copia previa a la última colección. Se guardan independientes
como hero-dog.png y hero-cat.png (1254×1254) y se asignan exclusivamente a
hero-dog/hero-cat. Tarjetas, footer, escenas nuevas y Volvemos ampliado conservados.
Sin regeneración, cambio de animaciones ni filtros. La colección pasa a doce
recursos independientes; comprobación del navegador actualizada a esa cantidad.
Build SSR y QA responsive/200 %/no-JS/QR aprobados; captura desktop-top revisada.
Registros en apps/mobile/build/landing-hero-restored-build.log y
landing-hero-restored-browser.log. git diff --check sin errores. Sin despliegue.

## Colección integrada desde el dálmata aprobado —17/10/2026

El usuario aprobó el nuevo dálmata y pidió aplicar su estilo a las restantes
mascotas y agrandar «Volvemos». Integrados ocho PNG nuevos con ImageGen:
dog-curious, cat, dog-wave, corgi, tabby, dog-report, pets-home y pets-map.
Referencias: dálmata aprobado y emblema blanco oficial. Variedad de razas,
pelajes y pañuelos, con el emblema dentro de la ilustración. Copias directas
RGBA sin filtros posteriores ni overlays; dimensiones nativas actualizadas.
Dálmata aprobado y pareja original conservados. «Volvemos» amplía la pareja
al 160 % centrada y anclada abajo. Diseño y animación principal conservados.

Recursos y prompts exactos en apps/platform/LANDING_APPROVED_STYLE.md, enlazado
desde LANDING_ASSETS.md; destino apps/platform/public/images/landing.
Validación: revisión de las diez ilustraciones sobre fondos claro/oscuro,
build SSR y QA Chrome 1440/731/390/320 px, texto200 %, FAQ/teclado/anclas,
no-JS, imágenes decodificadas, sin overflow ni errores CSP/hidratación,
aislamiento landing→QR→landing. Revisadas capturas desktop/mobile/characters.
Registros: apps/mobile/build/landing-approved-style-build.log y
landing-approved-style-browser.log. git diff --check sin errores. Servidor
de desarrollo existente conservado. Sin despliegue ni commit. Implementación
solicitada completada; no se presupone aprobación artística de las ocho nuevas.

## Dálmata regenerado desde la referencia indicada —17/10/2026

El usuario rechazó también `exec-e5839c84` por sombra oscura en la mejilla y
cola insuficiente. Se generó una nueva imagen usando directamente su referencia
`mockups/Imagen de ChatGPT 7 oct 2026, 17_03_12.png` y el emblema oficial,
sin usar como entrada el dálmata rechazado. Recurso integrado:
`exec-228f74fc-9ac3-428c-89de-5a5f1d1932bc.png`, 1312×1199 RGBA, sin filtros
posteriores. Orejas negras, pañuelo naranja con emblema blanco, cola completa
con mechones visibles. Se corrigió además el encuadre de su tarjeta: contain
en lugar de cover para mostrar toda la ilustración, incluida la cola.
La aprobación artística del usuario sigue pendiente; no se afirma que ImageGen
haya reproducido al 100 % el original ni se declara terminada toda la colección.
Validación de esta versión: build de producción y check de navegador pasados
(`landing-dalmatian-reference-build.log` y `landing-dalmatian-reference-browser.log`
en apps/mobile/build). Chrome: 1440/731/390/320 px y texto al 200 %, imágenes
decodificadas, sin overflow, SSR/FAQ/teclado/anchors y navegación QR comprobados.
Captura de tarjetas revisada: cola completa visible. Sin despliegue.

## Sustitución concreta del dálmata con ImageGen —17/10/2026

Se reemplazó `apps/platform/public/images/landing/dalmatian.png` por la nueva
edición `exec-e5839c84-0e7b-46ec-8087-e9bfc66c8f4c.png`, conservada también en
el directorio generated_images de Codex. Edición directa con ImageGen, sin
filtros manuales de color, alfa ni desenfoque posteriores. Conserva pañuelo
naranja, emblema blanco integrado, pose de saludo y cola con hebras definidas.
La comparación al 100 % sobre gris muestra reducción del halo anterior y
continuidad del pelo negro en el borde de la oreja. No se declara igualdad
píxel a píxel con la referencia ni aprobación artística del usuario.

La pareja pública conserva los píxeles originales fuera de las dos áreas de
estampado. Los otros ocho recursos no se sustituyeron en esta pasada: sigue
pendiente completar la revisión de toda la colección. Build de producción
comprobado; evidencia `apps/mobile/build/landing-dalmatian-final-build.log`.
No se publicaron cambios ni se modificó la animación principal.

## Criterio vigente del usuario: variantes desde la referencia original —17/10/2026

La corrección cromática posterior TAMBIÉN fue rechazada: ribete blanco sobre
pelo negro y pérdida de detalle en la cola. No hay aprobación del dálmata ni
del conjunto. No se han iniciado las otras ocho generaciones anunciadas ni
se han integrado los dos candidatos nuevos. La petición visual ya es clara;
repetir el prompt o pedir de nuevo la misma aclaración no resuelve el defecto.
Imagegen no ha conseguido reproducir el acabado solicitado en estas pruebas.
Se conserva la pareja con pelaje original y emblemas; el dálmata público sigue
siendo el recurso anterior rechazado, no una corrección aprobada.

Inspección de solo lectura de bordes negros del candidato: los puntos muestreados
tienen RGB oscuros incluso en semitransparencia. Eso no demuestra por sí solo
contaminación por un fondo blanco; no aplicar una fórmula de eliminación de
matte sobre toda la imagen suponiendo una causa que no está acreditada. El
rechazo artístico del usuario permanece vigente aunque esos puntos sean oscuros.

El nuevo dálmata desde el master también fue rechazado por un borde anaranjado.
El prompt arrastraba «ivory» y el sombreado/material del master; no usar marfil
ni iluminación cálida sobre pelo blanco. El usuario exige blanco neutro sin
tinte y detalle de fibras, conservando el emblema. Se detienen las otras ocho
variantes; solo se prueba una corrección cromática con imagegen sobre ese
candidato, manteniendo su groom. Ninguno de estos dos candidatos se ha integrado.

El usuario vuelve a exigir imagegen guiado por hero-bienvenida.png para TODAS
las mascotas: hebras/mechones definidos, volumen de cola y espacios transparentes
limpios, sin difuminación, halo blanco/gris/naranja ni contorno. Mantener el
emblema oficial estampado en tela. Se descarta usar las variantes rechazadas
como referencia visual para nuevas generaciones. Se inicia un nuevo dálmata
desde el original como comprobación previa del acabado; no publicar ajustes
manuales de alfa como sustituto de esta nueva petición de generación.

Estado real al recibir esa instrucción: pareja pública basada en el original
con solo dos zonas de estampado procedentes de imagegen (20246píxeles cambiados,
cero cambios de RGBA fuera de pañuelos y cero cambios de alfa). Dálmata público
con ajuste local de color anterior, rechazado por halo. El candidato de limpieza
de alfa está solo en build/landing-local-correction y NO se ha integrado. Las
demás imágenes mantienen la pasada anterior y no se consideran aprobadas.
La copia temporal de pareja sin logo fue reemplazada por la versión con estampados.

Verificación de esa pareja y PNG anteriores: build/landing-local-web-{build,browser}.log
(SSR y Chrome responsive aprobados). Es evidencia de integración, no de aceptación
artística ni validación de los candidatos nuevos. Sin despliegue o commit.
Siguiente paso: revisar la generación desde el master original y completar el
conjunto según ese acabado. Las notas inferiores son historial de intentos.

## Revisión del pelaje de landing —17 de octubre de2026

**Referencia principal aclarada después:** el usuario compara la cola compacta
del reencuentro generado con mockups/landing-mascotas-v1/hero-bienvenida.png:
busca volumen y mechones separados, además de pelo blanco sin franja gris. Se
abandona el enfoque de seguir suavizando las siluetas rechazadas. El original
hero1536×1024 ya es RGBA transparente (muestras exteriores con alfa0), por lo
que no necesita extracción de fondo. Se prueba una edición mínima con imagegen
que solo cambia los estampados genéricos por el símbolo oficial, preservando
el pelo original; muestra fuera del público, sin dar por corregido el dálmata.
No se ha ejecutado la propuesta de corrección manual de color/alfa.

Muestra generada1536×1024 en build/landing-approved-source-review/hero-bienvenida.png;
alfa exterior0 comprobado y comparación de cola al100% en
build/ui-preview/landing-approved-tail-comparison.png. Se compara fuente original,
edición mínima solicitada para logos y reencuentro rechazado. No se afirma
identidad de píxeles fuera del estampado. Pendiente revisión de esta nueva vía
antes de producir variantes, sin nuevos reemplazos públicos ni build.

**Corrección posterior del usuario:** también rechaza el último piloto y el
conjunto extendido: detecta sombreado gris/oscuro alrededor del pelo blanco,
especialmente en la oreja del dálmata. La integración y los checks descritos
abajo no equivalen a acabado aceptado. Se detienen los reemplazos en bloque y
se prepara una sola muestra dirigida al sombreado del pelo blanco junto a la
silueta, manteniendo manchas negras y detalle. Referencia de problema: captura
codex-clipboard-c22d3e04-c379-47e2-9e9c-a5756c6bfcef.png. No se altera todavía
el conjunto público ni se repite build para una muestra fuera de ejecución.

Muestra preparada con imagegen en dos ediciones: retirar la franja gris del
material blanco y después recuperar hebras en esa silueta clara. La primera
quedó demasiado lisa y se conserva solo como intermedio. Candidato y comparación
de oreja al100% en build/landing-white-fur-review/dalmatian.png y
build/ui-preview/landing-white-fur-ear.png. PNG inspeccionado, renderizado sin
modificar píxeles con scripts; sin sustituciones públicas en esta revisión.
Siguiente paso necesario: revisión del acabado de esta muestra por el usuario
antes de extrapolar el tratamiento; la corrección global permanece pendiente.

El usuario rechazó también esta muestra. Se detienen nuevas generaciones a ciegas.
Diagnóstico de solo lectura: comparación del mismo PNG sobre blanco/gris/oscuro
y muestreo RGBA nativo, sin modificar el recurso. Hay cambios de color dentro
de las fibras de la zona blanca, además de píxeles semitransparentes; no atribuir
todo el defecto exclusivamente a CSS o alfa. Evidencia: build/landing-edge-diagnosis.json
y build/ui-preview/landing-edge-diagnosis.png. Se propone probar una corrección
localizada de color/transparencia preservando las hebras existentes; requiere
que el usuario elija ese cambio de método frente a su petición de usar imagegen.
No se ha ejecutado tratamiento de píxeles ni modificado el conjunto público.

El usuario rechazó las pasadas de contornos: mantenían perfiles/luminosidad y
perdían detalle. Referencia prioritaria actual: mockups/landing-mascotas-v1/
gatito-curioso.png. Se calibró primero un dálmata con hebras visibles y color
local hasta las puntas, en vez de desenfocar su perímetro. Después se generaron
individualmente los otros nueve PNG desde las copias previas al suavizado. Los
diez archivos seleccionados están integrados en apps/platform/public/images/landing;
conservan mascotas, escenas, pañuelos y emblemas blancos estampados en tejido.
Sin cambios de UI, hero/tiempos, fuentes de marca, móvil, datos o publicación.

Validación local de esta pasada: diez copias exactas de los PNG seleccionados,
RGBA y dimensiones nativas contrastadas con landing_artwork.ts; ocho1254×1254 y
dos1774×887,20862121bytes en total (build/landing-fur-assets.log). Revisión de
archivos y comparación visual sobre fondos claros/oscuros; detalle nativo en
build/ui-preview/landing-fur-pilot-detail.png, conjunto en landing-natural-edges
y landing-natural-edges-dark. Build SSR aislado aprobado sin cerrar el servidor
de desarrollo del usuario (build/landing-fur-web-build.log).

QA Chrome aprobado en1440/731/390/320 y320 con texto200%: diez recursos
decodificados, sin overflow ni errores CSP/hidratación/recursos; sin logos
superpuestos, FAQ/anclas/teclado/sinJS, hero original/movimiento reducido y SPA
landing→QR→landing conservados (build/landing-fur-web-browser.log). Capturas
actualizadas y revisadas en build/ui-preview/landing-vue. No se repiten pruebas
Flutter ni de negocio para una sustitución de PNG. Estas comprobaciones verifican
integración; no equivalen a aprobación artística del usuario. Pendientes revisión
visual final del usuario, Safari/Firefox y publicación cuando se autorice.
Prompts/procedencia: apps/platform/LANDING_ASSETS.md. Siguiente paso: revisar esta
versión local y conservar como referencia el pelo definido, sin perfilarlo.

## Diversidad, pañuelos estampados y logo actualizado —17 de octubre de2026

Petición del usuario en feature/vue-nuxt-web: más mascotas/razas/pelajes, pañuelos
variados y only-black.svg en blanco INTEGRADO en la tela mediante imagegen,
expresamente sin superposiciones. Se generaron corgi, dálmata y atigrado, y después
se regeneraron los10 PNG finales con estampados blancos y colores carbón, verde,
marino, burdeos, petróleo, ciruela y terracota. Escenas incluyen spaniel, mestizo/
calicó, retriever/gato gris y beagle/gato blanco-negro, conservando composición y
transparencia. Retiradas todas las capas SVG/posiciones de emblemas del intento
inicial corregido por el usuario. LandingArt solo muestra PNG; caption/superficies/
CTA/decoración siguen siendo Vue/CSS/SVG reales. Hero/animación/tiempos intactos.
Prompts finales y procedencia: apps/platform/LANDING_ASSETS.md; recursos finales
en apps/platform/public/images/landing. [Ficha](funcionalidades/identidad-visual.md).

Fuentes actualizadas por el usuario en logo/ conservadas. Logo oficial propagado
a header/footer/QR, favicon PNG256 y vector completo disponible en brand.svg;
PNG oficial@2x en brand.png y BrandMark/BrandWordmark/StartupReveal. Navegación usa
el PNG original para conservar la textura sin aliasing de filtros SVG a tamaño
pequeño. Splash Android, iconos clásicos/adaptativos/monocromo, catálogos iOS/macOS,
Windows y PWA/favicon Flutter regenerados con flutter_launcher_icons0.14.4. Se
corrigen rutas relativas después de apps/mobile y se conserva la bandera Xcode
Swift asset symbols ante el comportamiento del generador, sin cambiar paquetes.
Hashes confirman copias PNG/SVG exactas y tamaños de todos los PNG en catálogos.
No se recrean apps ni se habilita soporte funcional de plataformas futuras.

Validación: Flutter analyze global sin incidencias y28 pruebas de app/acceso/
Google/fronteras aprobadas (build/brand-refresh-{analyze,tests}.log). Harness global
de capturas falló con MissingPluginException de path_provider/caché de flutter_map
y búsqueda de Cerrar al avanzar un flujo; no se cambió ese harness ni se afirma
regresión visual global aprobada (brand-refresh-renders.log). Render focalizado
de BrandWordmark con fuente real y precarga de imagen aprobado, normal390/texto200%
en320, en build/brand-refresh-focused-renders.log y ui-preview/brand-refresh.
Typecheck web, build SSR aislado para conservar el dev server abierto,9 unitarias/
fronteras y3 pruebas de producción aprobadas. QA Chrome final con10 imágenes,
logo oficial, sin overlays ni errores CSP/hidratación/recursos/overflow, responsive
1440/731/390/320 y texto200%, FAQ/teclado/sin JS, hero/movimiento reducido y SPA
landing→QR→landing aprobado; regresión QR completa también aprobada. Logs
apps/mobile/build/brand-refresh-web-{build,tests,server,browser}.log y
brand-refresh-qr-browser.log; capturas revisadas en ui-preview/landing-vue.

Sin SQL, cambios de negocio, dependencias nuevas, publicación, push o commit.
No se compilaron APK/iOS/macOS/Windows ni se comprobó launcher instalado; iconos
requieren recompilación/reinstalación. Pendientes Safari/Firefox, harness móvil
global y despliegue cuando se autoricen. Siguiente paso: revisar recursos/landing
local y publicar/reinstalar en el incremento que corresponda.

## Landing: ilustraciones independientes y componentes reales —17 de octubre de2026

Por instrucción del usuario, en la rama vigente feature/vue-nuxt-web y apps/platform,
se retiran TODOS los recortes del mockup: eliminado del público landing-reference.png,
sin atlas, offsets ni imagen de UI por debajo. Siete PNG generados individualmente
con la herramienta integrada image_gen/habilidad imagegen: perro curioso, gato,
saludo, reencuentro, aviso, casa y mapa; cinco1254×1254 y dos1774×887 con transparencia.
Se conservan los originales sin reescalado artificial en public/images/landing;
prompts/procedencia en apps/platform/LANDING_ASSETS.md. LandingArt usa recursos
independientes/dimensiones reales y carga diferida salvo hero; LandingCharacterCard
contiene figura/etiqueta/trazos SVG. Fondos, degradados, superficies, círculos y pins
decorativos son CSS/SVG. Header/footer usan el logo oficial /brand.png existente.
La animación principal aprobada conserva cover/stagger, duración/demoras y movimiento
reducido. Textos, anclas y FAQ siguen siendo HTML; sin operaciones nuevas de producto.
[Ficha](funcionalidades/landing-page.md) y corrección de [ADR-060](decisiones/060-landing-integrada-en-platform-vue.md).

Validación: typecheck estricto y9 pruebas unitarias/fronteras aprobados; build Nuxt
SSR correcto y3 pruebas del servidor compilado aprobadas. El comando estándar de
build detectó un dev server ajeno activo en5173/PID9128; no se detuvo ni se ignoró
su lock. Se construyó mediante loadNuxt/build oficiales con buildDir separado en
apps/mobile/build/platform-landing-nuxt, conservando la configuración del proyecto.
Log final: apps/mobile/build/landing-generated-art-build.log. QA Chrome/Playwright
en1440/731/390/320px y320px/texto200%: siete recursos reales, ambos logos, imágenes
decodificadas también tras ampliar texto, anclas/FAQ/teclado/sin JS, aislamiento SPA
landing→QR→landing, sin overflow ni errores CSP/hidratación/recursos. Verificación
de cover-reveal0.7s y stagger-reveal/demora0.2s, sin animación con movimiento reducido.
Log final: apps/mobile/build/landing-generated-art-browser.log. Regresión completa
QR también aprobada: galería, copia, offline/reintento, cierre/revocación, desconocido
y CSP con fixtures. Capturas revisadas en apps/mobile/build/ui-preview/landing-vue,
incluidas characters.png, desktop-top.png y small-text-200.png.

Sin cambios de SQL, dependencias, configuración sensible, acceso/roles ni código
Flutter. PNG originales suman aproximadamente12.5MB y usan lazy/reutilización; no se
ha medido transferencia móvil real ni Core Web Vitals. Pendientes: revisión del
usuario, Safari/Firefox y publicación/redeploy cuando se autoricen. Sin commit,
push ni despliegue; no se cierra HU-09 ni se afirma indexación/posicionamiento.
Siguiente paso: revisar la landing local y publicar el incremento cuando corresponda.

## Landing integrada en la plataforma Vue —17 de octubre de2026

Por solicitud del usuario se integra en / de apps/platform el trabajo existente
del worktree feature/landing-page (fuentes React/Next sin confirmar allí).
Conversión a componentes Vue/TypeScript, sin cambiar ni confirmar el worktree
original. Header/hero/personajes/propósito/pasos/comunidad/FAQ/footer conservan
la referencia aprobada. LandingPage, Art/Icon/Brand/Actions y CSS propios de
presentación; no se añaden dominio/repositorio vacíos ni otro runtime Next.
[ADR-060](decisiones/060-landing-integrada-en-platform-vue.md),
[ficha](funcionalidades/landing-page.md).

CSS limitado a .landing-page y QR a .reader-shell, comprobado al navegar en SPA
en ambos sentidos. Ilustración raster autorizada copiada intacta; recortes con
clases CSS fijas sin styles inline, sin relajar CSP. La landing se entrega en HTML
SSR con nonce por respuesta, FAQ nativo y anclas reales, sin consultas Supabase,
sesión, formularios, métricas inventadas ni descargas falsas. / indexable con
metadatos/canonical; robots excluye fichas/API/app/admin, sitemap solo raíz. QR
conserva URLs/proyección/noindex/no-store/controles de acceso y su apariencia.
Sin SQL, dependencias, nuevas variables ni cambios Flutter.

Validación final: TypeScript estricto y build correctos;9 unitarias/fronteras y
3 pruebas del servidor compilado aprobadas. Logs landing-nuxt-{typecheck,tests,
build,production}.log en apps/mobile/build. Browser QA Chrome/Playwright aprobado
en1440×1000,731×1000,390×844,320×700 y texto200%: imágenes, anclas, FAQ por teclado
y sin JS, no overflow ni errores CSP/hidratación, sin lecturas de producto,
aislamiento SPA. Capturas revisadas en build/ui-preview/landing-vue y comparadas
con referencia original; mantienen su composición y limitación del raster.
Regresión QR completa también aprobada (build/landing-qr-regression-browser.log).

Publicación de la migración/directorios previos confirmada por el usuario; esta
integración nueva permanece local hasta push/redeploy. Mismo Dokploy/contexto/
puerto/Environment. .env.local conservado; para desarrollo se documenta la opción
--dotenv .env.local, sin exponerlo al build. Pendientes: revisión del usuario,
Safari/Firefox, redeploy y seguimiento SEO. Sin commit/push/despliegue ni APK en
este incremento. Login/admin web y HU-10.1/formulario siguen pendientes.

## Organización apps: segundo movimiento —17 de octubre de2026

Primer commit **eb94af4**: web en apps/platform con build/11 pruebas aprobadas.
Ahora Flutter se mueve completo a apps/mobile, conservando config local verificada
por hash y sin cambiar package name/imports/identificadores nativos. Windows negó
el rename de la carpeta raíz; se trasladaron sus contenidos y se retiró la carpeta
vacía, sin pérdida. Se detuvo un Gradle daemon identificado que podía retener
archivos; gradlew --stop reprodujo el problema de loopback ya conocido, sin build.
Rutas CI/F5/CMake/documentación/scripts adaptadas, sin recrear aplicación.
La instrucción del usuario sustituye la prohibición histórica de mover Flutter.
Los paths de documentación se normalizan a la nueva ubicación; logs/artefactos
previos se conservan dentro del build trasladado. Sin push ni despliegue.

Validación final desde apps/mobile: pub get --enforce-lockfile correcto, lockfile
idéntico al original; formato488 archivos sin cambios, análisis sin incidencias y
**359 pruebas Flutter aprobadas**. Evidencia en build/mobile-move-{pub,format,
analyze,tests}.log. Browser QA de apps/platform aprobado con las rutas de assets
y salida nuevas (build/platform-mobile-move-browser.log):390×844,1280×900 y320×350/
texto200%, SSR sin consulta duplicada, copia, galería, errores y cierre/revocación.
Revisión del diff/staging sin secretos ni artefactos ignorados. No se generó APK
ni se acredita build nativo o CI remoto de la nueva estructura.

## Organización apps: primer movimiento —17 de octubre de2026

Por instrucción del usuario se renombra la web a apps/platform, con workflow
platform.yml y referencias de operación/documentación actualizadas. Es el primer
movimiento de ADR-059 y tendrá su propio commit. Flutter permanece en la raíz
en este punto; el segundo movimiento lo ubicará en apps/mobile. Rama de landing
independiente conservada. No se cambia Dokploy ni se hace push/despliegue.

Validación desde apps/platform: TypeScript sin errores,9 pruebas unitarias/
arquitectura y2 de servidor compilado aprobadas; build SSR correcto. Logs
platform-move-{typecheck,tests,build,production}.log en el build de Flutter.
Las rutas de Dockerfile/contexto/Watch Paths nuevas están en DOKPLOY.md y deben
cambiarse en el panel al desplegar esta revisión. Sin cambios SQL ni APK.

## Ajuste visual de botones sociales —17 de octubre de2026

Por solicitud del usuario, Facebook pasa a azul #0866FF y glifo24px para
igualar visualmente el asset Google20px con el margen interno de Material.
SocialSignInButton reduce padding vertical13→10 y altura mínima56→50 para
ambos proveedores, conservando área táctil y adaptación de texto. Sin cambios
de Auth, SDK, contratos ni configuración remota. Ficha de acceso actualizada.

Validación: formato correcto,11 pruebas existentes de Facebook/layout y
arquitectura aprobadas en build/social-buttons-tests.log; análisis sin incidencias en
build/social-buttons-analyze.log, dentro de apps/mobile.
Renders normales/pequeños con texto2 revisados en build/ui-preview/facebook. Pendiente
comprobación Android real; sin APK, commit, push o despliegue.

## Login con Facebook —17 de octubre de2026

Solicitud explícita del usuario, ampliación de HU-01 / RF-01,34 / issue #1.
En la rama real `feature/vue-nuxt-web`, conservando cambios locales previos de
la web, se añade Continuar con Facebook debajo de Google. Reutiliza
SocialSignInButton, LoginViewModel, SignIn, contrato/repositorio y fuente
Supabase. SocialProvider añade facebook y el adaptador usa switch exhaustivo
para no enviar proveedores nuevos a Google accidentalmente. Conserva
toast superior, bloqueo/shimmer real, cover→stagger y scroll/texto ampliado.
La sesión y el onboarding por cuenta solo avanzan al recibir Auth válido;
abrir OAuth no se considera sesión iniciada. Sin SDK nativo nuevo ni SQL.

Validación local: **29 pruebas Flutter aprobadas**, incluyendo URL de los tres
proveedores con PKCE y retorno móvil, lanzamiento fallido/reintento, Facebook
desde pantalla con doble envío bloqueado y recuperación tras error, y pruebas
existentes de acceso/feedback/fronteras. Registro en
`apps/mobile/build/facebook-tests.log`. Formato de los
5 archivos Dart correcto; `flutter analyze --no-pub` sin incidencias en
`build/facebook-analyze.log`. Renders revisados en
`build/ui-preview/facebook` a390×844 y320×350/texto2/movimiento reducido;
el contenido pequeño continúa por scroll. Pruebas con plataforma/repositorio
sustituidos: no acreditan OAuth remoto ni permisos reales de Meta.

[Guía de activación Meta/Dokploy](LOGIN_FACEBOOK.md), configuración, guía MVP
y ficha de acceso actualizadas. Siguiente paso: crear/configurar Meta,
añadir App ID/Secret al servicio Auth y retorno móvil a su allowlist, activar
el servicio con autorización de despliegue y probar Android con cuentas de
prueba/nuevas/existentes, cancelación y reentrada. Publicación Live depende de
los requisitos de privacidad/eliminación/permisos que muestre Meta. Sin acceso
remoto, secretos nuevos en Flutter, APK, commit, push ni despliegue; HU-01
no se declara cerrada.

## Web Vue/Nuxt: migración de ficha QR —17 de octubre de2026

Decisión explícita del usuario: web única Vue/Nuxt/TypeScript para público,
usuarios y administración organizada por módulos y permisos; Flutter en móvil.
Rama nueva **feature/vue-nuxt-web** desde14b6978 con árbol limpio. Se conserva
apps/platform y se migra por completo su funcionalidad QR existente, sin crear
pantallas vacías de login/admin ni modificar el worktree de feature/landing-page.
La integración/conversión de esa landing y los flujos web autenticados son
incrementos posteriores. [ADR-058](decisiones/058-web-unica-vue-nuxt-y-roles.md).

Vue3.5.44/Nuxt4.6.2/TypeScript6.0.3 con lockfile, Node24 LTS para CI/Docker.
Dominio/contratos/ViewModel puros TypeScript y fuentes/repositorios del servidor
separados de componentes. SSR entrega ficha pública en HTML; hidratación no
consulta otra vez. Vue conserva diseño, galería, compartir/copia, refresh y
neutral/cerrado. API/URLs/SQL/variables Dokploy se conservan. Nuevo nonce CSP por
respuesta para scripts de hidratación, no unsafe-inline; no se serializan
credenciales, descriptores Storage ni campos privados. Estado por petición,
deduplicación/abort y borrado al confirmar revocación. Se retira servidor/vista
DOM manual para evitar dos implementaciones de la misma funcionalidad.

Validación local: TypeScript estricto sin errores (build/nuxt-typecheck.log),
**9 pruebas unitarias/arquitectura aprobadas** (build/nuxt-tests.log), build SSR
correcto (build/nuxt-build.log), **2 pruebas del servidor compilado aprobadas**
(build/nuxt-production-tests.log): HTML inicial, API, fotos, nonce, secreto/path
canario excluido, cierre/revocación/error, health y límites60/min con leases
liberados. Browser QA Chrome/Playwright1.62.1 aprobado (build/nuxt-browser.log):
390×844,1280×900 y320×350/texto200%/movimiento reducido, galería/copia/offline/
reintento/cierre/neutral, CSP sin rechazos, sin desbordamiento y sin segunda
consulta al hidratar. Capturas con fixtures en build/ui-preview/public-web,
revisión visual realizada; no acreditan backend real ni Safari.

Auditoría runtime declarado y dependencias exactas de .output/server:0 avisos
conocidos (build/nuxt-runtime-audit.json y nuxt-bundled-runtime-audit.log). El árbol
de build/desarrollo conserva11 altas transitivas por braces/node-forge sin
versión corregida disponible; compatible audit fix no resuelve. Paquetes
afectados ausentes del inventario runtime; sin downgrade forzado ni ocultar
avisos. Mantener seguimiento/revisión antes de distribución. No equivale a una
certificación de seguridad del bundle.

El usuario confirma022/023 aplicados, dominio publicado y generación/lectura QR
funcionando en versión previa; configuración Flutter local true conservada.
Esta evidencia sustituye pendientes históricos de activación comunicados, sin
verificación independiente de políticas/Storage/concurrencia. La migración Vue
no se ha desplegado ni probado contra sus casos reales. Docker/CI actualizado,
sin imagen local ni workflow remoto nuevo verificados. Sin SQL nuevo, APK,
commit/push o redeploy. Documentación de iniciación y operación actualizada:
[DESARROLLO](../apps/platform/DESARROLLO.md), [Dokploy](../apps/platform/DOKPLOY.md).
Siguiente paso: publicar/revisar migración en Dokploy y coordinar integración
de landing; HU-10.1/formulario y aplicación web privada siguen pendientes.

## Preparación Dokploy desde GitHub —17 de octubre de2026

Por petición del usuario se prepara apps/platform para su VDS/Dokploy, conservando
el trabajo local de HU-09 en feature/public-qr-case-web. Dockerfile multietapa con
runtime no root/puerto5173, .dockerignore con entradas permitidas y healthcheck
Node sin curl. GitHub Actions amplía validación con build/smoke del contenedor
sin credenciales reales ni despliegue. [Guía exacta](../apps/platform/DOKPLOY.md)
para Application/proveedor GitHub, rama, Dockerfile/contexto, Environment,
DNS/HTTPS, health, Auto Deploy y límites del proxy. Usuario completa Environment.

Docker CLI instalado pero daemon Docker Desktop Linux no disponible; build/arranque
de imagen local no verificados, CI remoto pendiente. Se valida arranque Node con
el bootstrap real y probe de salud sin Supabase: **10 pruebas Node aprobadas**
en build/dokploy-web-tests.log, incluido ese recorrido. /health es liveness, no evidencia
de RPC/Storage. Pendientes: publicar la rama, configurar panel/DNS/secretos, aplicar
SQL022/023 según estado real y comprobar caso real/cierre/revocación. Sin commit,
push, acceso a Dokploy, despliegue ni cambio de PUBLIC_CASE_WEB_READY.

## HU-09: ficha pública QR —16 de octubre de2026

Incremento local en **feature/public-qr-case-web**, desde3db6de6 con árbol inicial
limpio. Consulta sin app/cuenta en apps/platform, dominio acordado
https://entrehuellas.kormind.com y ruta /c/<token64hex>. Activo: fotos procesadas,
rasgos/campos públicos, fecha/zona aproximada, compartir/copia y actualización.
Cerrado: estado/fecha real sin exponer ficha privada; inexistente/revocado/eliminado:
mismo neutral. Consulta cada60s visible/al volver a pestaña y manual; sin prometer
tiempo real ni retirar copias ya descargadas.

Cliente DOM con ViewModel/casos de uso/repositorios y servidor HTTP Node de lectura;
secreto solo en servidor. SQL080–082/plan023 genera migración20261016002300_public_qr_case.sql,
patch023 y run_all sin reescribir migraciones anteriores. read_qr_case solo
service_role; revocación solo autor, idempotente. Fotos por índice con revalidación
después de descargar; navegador no recibe UUID privados/paths Storage ni URLs
firmadas. Sin ampliar grants anónimos de tablas/Storage. Se corrigió en validación
el uso del marcador real deletion_requested_at de pets y la invocación de fetch
del navegador conservando su receptor global.

**Validación local:**24 pruebas SQL/PostGIS aprobadas (build/qr-web-sql-tests.log);
9 pruebas Node aprobadas (build/qr-web-node-tests.log). Chrome headless mediante
Playwright1.62.1:390×844,1280×900 y320×350 con texto200%/movimiento reducido,
galería, copia real, offline/reintento, cierre, revocación e inexistente, CSP y
ausencia de desbordamiento horizontal (build/qr-web-browser.log). Capturas con
fixtures de prueba/asset aprobado revisadas en build/ui-preview/public-web.
Node local24.18.0; workflow nuevo usa22, aún sin ejecución remota. Flutter no se
modificó y no se repitió su suite ni se generó APK. Dockerfile preparado, sin build.

**Pendientes:** aplicar022/023 en desarrollo según estado real, configurar hosting
Node/secreto/TLS en el dominio y comprobar Supabase/Storage reales, proxy sin caché,
otro teléfono sin app/Safari y QR físico. PUBLIC_CASE_WEB_READY permanece false.
Formulario HU-10.1/#36 todavía pendiente; es el siguiente incremento funcional.
HU-09/#9 no cerrada. Sin SQL remoto, despliegue, commit/push ni cambios en GitHub.
[Ficha](funcionalidades/ficha-publica-qr.md), [ADR-057](decisiones/057-ficha-qr-web-y-proxy-privado.md),
[operación](../apps/platform/README.md). La evidencia local no sustituye activación remota.

Revisión del mapa: filtros inferiores y acceso junto al pin,16 de octubre. Se conserva pantalla/expansión de ADR-055, pero el panel contiene ExploreFilterEditor compartido con lista y Aplicar filtros. Borrador hasta confirmar (incluidos GPS/centro visual); CTA fijo si cabe, scroll con altura mínima/texto ampliado. Pin muestra etiqueta compacta de un caso/Abrir caso, reduce filtros y acomoda cámara; coincidencias se recorren en etiqueta. Aplicar retira selección y recupera panel42%. Metadatos del lugar en ExploreState conservan la cápsula de Ubicación al volver/refrescar/paginar; GPS deduplicado por generación y resultados de otra cuenta descartados. Sin SDK nuevo, SQL, permisos o persistencia adicional. Se retiran opciones de grilla añadidas para la ficha inferior que ya no tienen consumidores. [ADR-056](decisiones/056-mapa-filtros-inferiores-y-acceso-en-pin.md) sustituye contenido inferior/selección inicial de ADR-055. Formato y análisis global limpios (build/map-filters-final-analyze.log); suite final de353 pruebas aprobada (build/map-filters-full-tests.log),25 focalizadas y6 finales de mapa/GPS con renders (build/map-filters-focused-tests.log y build/map-filters-final-renders.log). Capturas normal/pequeña/texto2 revisadas en build/ui-preview/explore-map: screen-*.png para filtros y normal.png/small.png para etiquetas. Usan teselas neutras, sin validar cartografía real. Revisión Android pendiente; sin APK ni publicación. Trabajo previo conservado.

Diagnóstico de parámetros del selector,16 de octubre: captura muestra subtitle/placement no definidos en FilterExpansion. En los archivos guardados ambos parámetros, sus campos y FilterPanelPlacement están presentes; solo existe una declaración de cada tipo y el import de ExploreFilters apunta a ella. `dart analyze lib/core/presentation/widgets/filter_expansion.dart lib/features/explore/presentation/widgets/explore_filters.dart` termina sin incidencias (build/filter-parameter-diagnostic.log). No se reproduce el error de la captura ni se modifica la API correcta. Estado desactualizado del analizador, buffers sin guardar u otra copia abierta siguen como hipótesis; reinicio del analizador/editor y confirmación visual pendientes.

Mapa inmersivo de Explorar,16 de octubre: `/home/explore-map` usa entityEditorPage/OriginPageSource desde la opción Mapa y retorno glass. Mapa a todo viewport y panel inferior deslizable14/42/90%, tirador persistente/accesible y una ficha de ancho completo; nombre una sola vez, foto/estado/distancia compartidos y Ver ficha. Coincidencias recorren casos individualmente. Consulta/páginas/cursor compartidos; abrir/cerrar no consulta, volver de ficha actualiza como antes. Se retira mapSelected del estado de presentación; sin cambios de dominio/datos/SQL. [ADR-055](decisiones/055-explorar-mapa-inmersivo-y-panel-deslizable.md) sustituye composición integrada de ADR-052. Formato/análisis global sin incidencias y suite final de351 pruebas aprobada (build/explore-fullscreen-map-final-analyze.log y build/explore-fullscreen-map-full-tests.log). Cuatro pruebas finales de mapa/ruta aprobadas con capturas (build/explore-fullscreen-map-route-tests.log);11 de acceso/onboarding aprobadas incluyendo la nueva ruta (build/explore-map-access-tests.log). Renders normales/pequeños con texto ampliado, insets y movimiento reducido revisados en build/ui-preview/explore-map/screen-*.png: teselas neutras, sin validar cartografía real. Revisión Android pendiente; sin APK, despliegue o publicación. Trabajo previo de carteles y demás ajustes conservado.

Recarga de Mascotas y selección de Ubicación, 16 de octubre: reproducido remonte de contenido al iniciar/terminar shimmer, corregido manteniendo estable la estructura compartida de LoadingShimmer. Prueba de gesto real confirma una sola consulta adicional y misma instancia de tarjeta durante todo el ciclo; otro gesto ocupado no consulta. No se reproduce doble consulta en esa prueba. La cápsula de Ubicación ahora muestra lugar aplicado/radio, distingue GPS y Punto del mapa, conserva texto real del buscador por separado y ofrece tooltip del nombre completo. Análisis global limpio y suite completa de 350 pruebas aprobada (build/pets-location-analyze.log y build/pets-location-full-tests.log); prueba de reproducción previa fallida en build/pets-refresh-reproduction.log. Capturas normales/pequeñas con texto ampliado revisadas en build/ui-preview/explore/*-location-applied.png; 10 pruebas de render/recorrido aprobadas (build/location-summary-renders.log). Validación Android pendiente; sin APK, SQL ni publicación. Trabajo local previo conservado.

Salida de selectores, 16 de octubre: refinada en ambas variantes con contracción/retirada de 8 px, fundido diferido y blur/velo coordinados en 320 ms. Apertura conservada; cierre interrumpiendo entrada captura progreso sin salto, conserva portal y respeta movimiento reducido. Análisis limpio y 19 pruebas de Explorar/arquitectura aprobadas, incluidas dos de salida durante apertura (build/filter-exit-analyze.log y build/filter-exit-tests.log). Revisión perceptual Android pendiente; sin APK ni publicación.

Corrección de animación, 16 de octubre: por aclaración del usuario, Ubicación recupera la misma escala/fundido sincronizados con blur del selector principal; solo cambia el anclaje del panel. No se incorpora transición de página desde origen. Análisis limpio y 8 pruebas de Explorar aprobadas (build/filter-animation-tests.log); sin APK ni publicación.

Variantes de selectores, 16 de octubre: FilterExpansion conserva `below` por defecto en Filtrar casos y añade `atOrigin` para Ubicación, con panel superpuesto desde el borde superior de su control, con la animación original de escala/fundido del selector. Centrado de etiquetas mediante espacios laterales simétricos. Cierre exterior/atrás/aplicar y scroll conservados. Análisis limpio; 17 pruebas de Explorar/arquitectura aprobadas, incluyendo posición real del panel normal/pequeño con texto ampliado. Logs build/filter-variants-analyze.log y build/filter-variants-tests.log; capturas build/ui-preview/explore. Revisión Android pendiente; sin APK ni publicación. Trabajo local previo conservado.

Simplificación explícita de Ubicación, 16 de octubre: en Explorar se conserva únicamente título, ubicación actual, buscador, radio/deslizador, mapa y Aplicar. Se retira Centro y las etiquetas sintéticas del input; al elegir punto manual se limpia el texto, sin perder coordenadas. El texto explicativo del mapa ya había sido retirado en el trabajo local del usuario y se conserva su cambio. Sin modificaciones de consulta/SQL ni al trabajo de carteles. Formato y análisis sin incidencias; 12 pruebas de Explorar/buscador aprobadas (build/explore-location-panel-analyze.log y build/explore-location-panel-tests.log). Sin APK ni publicación.

Diagnóstico de captura16 de octubre: casePosterRepository está declarado en AppBootstrap (constructor/campo/composición) e inyectado desde main.dart; solo existe una declaración de AppBootstrap en la app. `dart analyze lib/main.dart lib/app/bootstrap.dart` devuelve No issues found (build/poster-bootstrap-diagnostic.log). No se reproduce el getter undefined de la captura en los archivos guardados; estado desactualizado del analizador o buffers distintos siguen siendo hipótesis. Se recomienda guardar y reiniciar Dart Analysis Server en el editor; no se modifica código correcto ni se afirma resolución del diagnóstico del editor sin comprobarla.

Corrección explícita del usuario16 de octubre: se retiran todas las menciones visibles del proveedor cartográfico en Explorar y en el buscador compartido de Ubicación/Ciudad, incluidos enlaces y feedback asociado. Se elimina el slot de atribución sin consumidores del mapa compartido. [ADR-054](decisiones/054-retirar-menciones-visibles-proveedor-mapas.md) sustituye la indicación de atribución visible de ADR-052/051; servicios y consultas conservados. Trabajo previo de carteles preservado. Formato/análisis sin incidencias y25 pruebas focalizadas aprobadas: build/remove-map-branding-analyze.log y build/remove-map-branding-tests.log. Escaneo de lib/features y lib/core/presentation sin menciones del proveedor; sin APK ni despliegue.

## Carteles PDF y QR — HU-08.1/08.2 — 16 de octubre de 2026

Por instrucción del usuario, el APK se difiere y no bloquea continuar S4. Rama nueva **feature/pet-poster-qr**, desde20576fa y árbol inicialmente limpio. Implementación local de HU-08.1/#34 y HU-08.2/#35, RF-08,37: generación de PDF A4 con foto principal pública procesada, datos mínimos y QR opaco estable; impresión/guardado mediante diálogo nativo, compartir PDF+enlace o solo enlace. Case_posters mantiene dominio/casos de uso, data/SDK/plantilla/exportación y ViewModel/estado/pantalla separados, con inyección en bootstrap/main y slots de router en fichas propias abiertas. Se conserva el feedback/reveal compartido, cancelación/reintento y bloqueo de duplicados. No se cierran historias por implementación local.

El usuario indica **entrehuellas.kormind.com**. Base HTTPS configurada por defecto y en el ejemplo versionado; ruta `/c/<slug>`. GET/ comprobado devuelve404 (web tool no accesible; comprobación HTTP directa). PUBLIC_CASE_WEB_READY permanece false hasta disponer de la ficha pública HU-09; crear/exportar sin activación se bloquea antes de crear enlaces o abrir acciones nativas. No se ha publicado web, cambiado DNS/hosting ni añadido lectura anónima. El dominio indicado no se sustituye por uno inventado.

SQL077–079/plan022 genera migración20261016002200_case_posters.sql, patch022 y run_all mediante scripts, sin modificar migraciones anteriores. Tabla privada sin grants de cliente; RPC autenticada valida autor/activo/no borrado/tipo raíz/foto y conserva slug por origen+caso. Snapshot explícito sin coordenadas/referencia/contacto/documentos; revisión antes de exportar detecta cambios y evita compartir un cartel obsoleto. Revocación nunca se revierte al generar. Foto principal se toma únicamente entre derivados públicos autorizados y el PDF vuelve a codificar sin metadatos. No cambia estado de casos.

Dependencias resueltas con Flutter3.35.3/Dart3.9.2 sin actualizar SDK: pdf3.12.0, printing5.14.3 y share_plus11.1.0; se conservan registrantes generados. Fuentes Roboto incluidas con licencia para generar sin descargar tipografía. La prueba inicial de printing5.14.2 no resolvió con image4.10.1 y se usó5.14.3 compatible; sin downgrade de image. Configuración local/credenciales conservadas.

Validación final: formato de482 archivos correcto y análisis sin incidencias (build/poster-final-analyze.log). **346 pruebas Flutter aprobadas** en build/poster-final-full-flutter-tests.log;16 focalizadas aprobadas, incluyendo7 de cartel y9 de arquitectura (build/poster-final-focused.log). **23 pruebas SQL/PostGIS aprobadas** (build/poster-sql-full-tests.log), incluidas autor/otra cuenta/anónimo, estabilidad/repetición, principal, separación de origen, revocación y cierre. Regeneración final de run_all/migración022 comprobada idéntica a fuentes. Renders UI390×844 y320×350/texto2/movimiento reducido revisados en build/ui-preview/posters; usan fixtures/servicios nativos sustituidos. git diff --check correcto.

PDFs de prueba perdido/encontrado/extremo en build/poster-preview, renderizados con Poppler y revisados visualmente; una página A4 cada uno, QR de los tres decodificado a la URL de prueba exacta mediante zxing-cpp. Extracción con pdfplumber confirma80 caracteres del nombre y200 de rasgos del caso extremo sin truncar. Son artefactos de prueba con dominio reservado, no carteles para difundir casos reales. No se acredita impresión física ni escaneo desde otro teléfono.

Pendientes/siguiente paso: aplicar022 en desarrollo, implementar/activar HU-09 en el dominio indicado y comprobar la lectura sin app/estado vigente/revocación. Probar impresión/Guardar PDF/compartir/cancelar con los plugins en la próxima recompilación nativa; APK no solicitado ni generado. Falta demo hosted, concurrencia multiconexión y QR físico. Sin SQL remoto, despliegue, commit/push ni cambios en GitHub en este incremento. [Ficha](funcionalidades/carteles-qr.md), [ADR-053](decisiones/053-carteles-pdf-y-enlaces-qr.md), guía/configuración/índice actualizados.

## CI remoto y recorrido Android de HU-07.2 — 16 de octubre de 2026

Resultado final: corrección del singular y evidencia Android publicadas en **04b3a13**. [Flutter38947608248](https://github.com/srg-cp/entrehuellas/actions/runs/38947608248) también **aprobado en Linux con339 pruebas**, formato y análisis; log en build/map-final-ci-success.log. Validación local de ese ajuste: formato correcto, análisis sin incidencias y12 pruebas de mapa/arquitectura aprobadas (build/android-review-analyze.log y build/android-review-tests.log). La app se deja abierta con sesión conservada; el bloqueo de APK descrito abajo continúa pendiente.

Continuación autorizada por el usuario. Al iniciar, el trabajo ya estaba confirmado y publicado en c727b2f de feature/explore-case-map, con árbol limpio. [Flutter38946521408](https://github.com/srg-cp/entrehuellas/actions/runs/38946521408) **completado con éxito en Ubuntu/Linux: formato, análisis y339 pruebas**. Los tests de perfil, navegación y Explorar que fallaban en el run anterior ahora pasan en CI; evidencia descargada en build/map-ci-success.log. No se modificaron reglas de protección, workflows ni estados de issues.

Emulador Android16/API36 emulator-5554 con sesión existente: se carga el código de esta rama mediante flutter attach y hot restart, conservando cuenta/sesión. Con ubicación inicial no disponible se consulta Photon y se elige Lima manualmente, radio15km. Backend real devuelve3 casos con fotos/miniaturas; lista y mapa coinciden. Se revisan teselas reales, puntos aproximados, selección de marcador→tarjeta→ficha con foto, retorno a la misma consulta, desplazamiento de cámara sin cambiar resultados y filtro Gato que deja1 caso tanto en lista como en mapa. Se corrige el texto singular a «1 caso consultado» detectado durante la revisión. Capturas locales en build/android-explore-map.png, build/android-explore-list-verified.png y build/android-explore-map-cat.png. Solo lecturas: sin crear/editar reportes, cambiar permisos o escribir SQL remoto.

Limitación de build: flutter build apk --debug --no-pub --dart-define-from-file=config/supabase.local.json falla en Gradle/Java con «Unable to establish loopback connection»; diagnóstico en build/gradle-loopback-diagnostic.log (SocketException: Invalid argument: connect en UnixDomainSockets/PipeImpl). Preferencia IPv4, proveedor de selector alternativo y diagnóstico con JDK17 no resuelven el entorno. Opciones limitadas a procesos, sin cambios persistentes de Java/Gradle. El recorrido por attach acredita código Dart actualizado sobre la instalación debug existente; **no acredita un APK nuevo ni arranque frío de esta revisión**.

Pendientes acotados: corregir entorno Gradle para APK nuevo, Android físico/arranque frío, denegación explícita de GPS, error/reintento de teselas con red controlada, volumen/paginación mayor y permisos entre cuentas/concurrencia hosted. No se declara HU-07 cerrada ni se inicia S4 automáticamente. Tras validar el alcance restante, el siguiente incremento funcional es cartel PDF/QR/web pública.

## HU-07.2 y corrección de CI — 16 de octubre de 2026

Rama de partida feature/explore-case-list en46c9429, árbol limpio y sin diferencia con su referencia local origin; se crea feature/explore-case-map. Implementado mapa de resultados con selector Lista/Mapa, consulta/filtros/páginas compartidos sin peticiones al alternar, marcadores de coordenadas públicas aproximadas y agrupación de coincidencias. Las tarjetas seleccionadas abren las fichas existentes; pan/zoom no cambia el centro de consulta. Se conservan vista/filtros durante refresh/paginación/error y alternativa manual sin GPS. ZoneMapPicker comparte teselas, ajuste al radio y recuperación; nuevas opciones conservan los predeterminados de sus otros consumidores. No se requiere SQL nuevo ni despliegue. [ADR-052](decisiones/052-explorar-mapa-de-resultados.md), [ficha](funcionalidades/explorar.md) e índice/guía/backlog local actualizados; sin cierre de HU-07.2 ni cambios de estado remoto.

Ante las capturas del usuario se consulta el log de [Flutter38934279610](https://github.com/srg-cp/entrehuellas/actions/runs/38934279610). Causas: profile_test escribía Cusco sin seleccionar sugerencia, profile_navigation_test no sustituía GPS y el toast de error interceptaba el avatar, y Explore cargaba roboto-regular.ttf con nombre distinto del SDK Linux. Se adapta el test de guardado a selectCity, se inyecta FakeCurrentLocation en navegación y loadFonts resuelve el nombre real mediante inventario insensible a mayúsculas. El ZIP oficial del SDK3.35.3 confirma Roboto-Regular.ttf/Roboto-Medium.ttf/Roboto-Bold.ttf; no se relajan validación de ciudad ni comportamiento de ubicación/feedback de producción.

Validación local: reproducción inicial con3 fallos; tras corregir,18 pruebas de perfil/navegación/Explorar aprobadas. Suite completa **339 pruebas aprobadas** en build/flutter-full-validation.log. Mapa/arquitectura:12 pruebas aprobadas en build/explore-map-tests.log, incluidas3 nuevas de paridad/paginación/reintentos/filtros y agrupación/apertura/pan en390×844 y320×350/texto2/movimiento reducido. Renders revisados en build/ui-preview/explore-map con teselas neutras generadas en memoria; se ajustó contraste del contador seleccionado. Tras el ajuste final de carga vacía y contraste,31 pruebas focalizadas aprobadas en build/final-targeted-validation.log. Formato de lib/test:465 archivos sin cambios pendientes. Análisis final sin incidencias en build/flutter-final-analyze.log; git diff --check correcto.

Límites/siguiente paso: volver a ejecutar CI al publicar; no se ha ejecutado Linux local ni un nuevo workflow remoto, y no se hicieron commit/push. Revisar Android autenticado con backend019, fotos/teselas reales, selección manual/GPS denegado, paginación/retorno y volumen representativo. Verificar caché/condiciones del proveedor antes de distribución; sin APK, SQL remoto o despliegue. La confirmación previa del usuario de020/021/Guardados se conserva y sustituye los pendientes históricos de esos patches. Tras validar HU-07, continuar S4 (cartel PDF/QR/web pública).

Confirmación del usuario16 de octubre: patch021 aplicado y recorrido de guardar/Guardados probado con resultado correcto («ya esta el patch ese, si permite guardar ya lo probe y todo esta bien»). Sustituye el pendiente de activación021 en notas anteriores; evidencia comunicada por el usuario, sin inspección remota independiente ni certificación adicional de permisos/concurrencia.

Corrección de recarga16 de octubre: PullToRefresh usa Stack sin recorte para que el indicador glass que entra desde coordenadas negativas no quede cortado durante el descenso/retirada. En Home envuelve toda la composición, incluida LiquidNavigation, y pinta el indicador al final sobre cabecera/contenido/acciones. Sin cambiar gesto, material o tiempos. Formato y análisis estático sin incidencias; sin pruebas/renders/build por instrucción vigente, revisión visual Android pendiente.

Última actualización: 16 de octubre de 2026, America/Lima.

## Corrección de navegación a Guardados —16 de octubre de2026

Corrección16 de octubre: el guard de sesión del router omitía /home/saved-cases y redirigía a /home al pulsar el marcador. Se permite explícitamente esa ruta solo cuando EntryDestination.home está resuelto; acceso/onboarding/recuperación mantienen sus controles. Se conserva OriginPageTransition existente. Formato y análisis estático de router sin incidencias; sin pruebas por instrucción del usuario y sin verificación Android. Pendiente revisar apertura/retorno en dispositivo;021 sigue pendiente para cargar el listado.

## Guardados: pantalla con expansión desde el marcador —16 de octubre de2026

Ajuste vigente del16 de octubre: el marcador compacto de Explorar abre la pantalla independiente Guardados en /home/saved-cases. Reutiliza OriginPageSource/OriginPageTransition mediante entityEditorPage: expansión desde el icono y retorno al origen al cerrar, con movimiento reducido respetado. Sustituye el cambio de vista en la cabecera y la segunda pulsación. SavedCasesScreen reutiliza EntityScreenShell con retorno glass y cover→stagger, SavedCasesSection y PullToRefresh; scroll siempre desplazable incluso con lista vacía. Explorar permanece debajo con filtros/posición conservados. Sin cambios SQL;021 sigue pendiente de aplicación y revisión Android.

Validación: formato y dart analyze lib sin incidencias. Sin pruebas, renders ni build por instrucción vigente; revisión de apertura/retorno/gesto en Android pendiente. No se ejecutó SQL, despliegue ni commit/push.

## Explorar → Guardados y Ciudad con sugerencias — 16 de octubre de2026

Por instrucción del usuario, Explorar incorpora Guardados mediante un marcador pequeño junto al título (icono24/área48), sin selector de secciones, por corrección posterior del usuario. Vacío/lleno indica vista cercana/guardados; título identifica la vista y una segunda pulsación vuelve a Explorar. Cabecera en una fila y entrada cover→stagger del contenido. Mantiene consulta cercana al cambiar; Guardados pagina marcas propias20, comparte grilla/fichas, jalar/Ver más/reintentos y refresca al volver de ficha. Excluye casos no visibles; no exige GPS/radio en la colección privada. PublicCaseCard/Kind/Status, DTO y grilla extraídos a core con alias compatibles de Explore, sin duplicar UI ni core→features.

Buscador Photon extraído de explore a places y compuesto desde router en slots de Ubicación/Perfil, sin imports entre presentaciones. Ciudad usa modo layer=city, valida tipo/nombre/longitud y exige seleccionar sugerencia antes de guardar texto nuevo; vacío opcional/ciudades antiguas sin editar se conservan. Estados/caché separados por modo; mismo debounce600ms, serialización, descarte por identidad y toast/shimmer. Perfil guarda etiqueta, no coordenadas; SQL de perfil no certifica procedencia de la selección.

Plan021/fuentes074–076: índice parcial y RPC list_saved_cases autenticada, cursor por propietario/as_of/fecha/origen/UUID y proyecciones vigentes. Migración20261016002100_saved_case_list.sql/patch021/run_all generados sin alterar020, cuya aplicación solo está confirmada por el usuario. **021 aún no aplicado**. Formato y flutter analyze --no-pub sin incidencias; contratos/imports/fixtures adaptados, **sin pruebas ejecutadas por instrucción vigente**, sin SQL/geocodificación real/build/renders/despliegue. Pendientes permisos/paginación/visibilidad/concurrencia, cobertura de ciudades y recorridos Android de selección/descartar/fallo/cuenta. Siguiente paso: validar/aplicar021 y revisar ambos recorridos. [ADR-051](decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md), [buscador](funcionalidades/ubicaciones-buscador.md). Sin commit/push ni cierre de historia.

## Indicador de recarga glass — 16 de octubre de 2026

Por petición del usuario, PullToRefresh usa GlassSurface compartido con el retorno: círculo52/radio26, icono28, mismo desenfoque/transparencia/ribete/sombra. Se retira su superficie gris/borde propios y se ajusta el punto oculto a52 para conservar la retirada completa. Gesto, giro, callbacks y movimiento reducido conservados. Aplica a Explorar, Mis mascotas y Ubicaciones de interés. Formato/dart analyze del componente sin incidencias; sin pruebas/renders/build por instrucción vigente, aspecto/rendimiento Android pendientes.

## Guardar casos desde la ficha — 16 de octubre de 2026

Confirmación posterior del usuario: patch020 aplicado (respuesta «okey ya esta» al paso de activación). Se registra como confirmación del usuario, sin ejecución/inspección remota independiente del agente. Persistencia y permisos todavía pendientes de comprobar en app/servidor; no se ejecutan pruebas por instrucción vigente ni se cierra historia.

Ampliación explícita del usuario de HU-07/RF-13, sin issue nuevo: marcador glass arriba a la derecha en fichas disponibles lost/found, incluidas búsquedas comunitarias. Guardar/quitar por cuenta, marca confirmada tras servidor, toast/shimmer y bloqueo de dobles envíos. Router inyecta SaveCaseButton mediante slots opcionales de ficha/shell; ninguna dependencia entre presentaciones ni core→features. saved_cases separa dominio/casos de uso, DTO/fuente/repositorio, providers y ViewModel autoDispose por identidad. Bootstrap/main inyectan.

Plan020/fuentes070–073: tabla privada owner/origen/UUID, RLS restrictiva, grants sin DML cliente y RPC autenticadas con visibilidad al guardar. Versionado/bloqueo/tombstone para reintentos; timeout conserva operación deseada, conflicto requiere reconsulta. Sin ampliar permisos del caso ni suscribir alertas. Recorrido desde ficha, sin listado propio/descarga offline.

Formato y **flutter analyze --no-pub sin incidencias**. Build-RunAll generó migración20261016002000_saved_cases.sql/patch020/run_all y verificó migraciones previas. **Sin pruebas por instrucción del usuario**, incluidas SQL; sin APK/build/renders ni aplicación remota por el agente. Tras confirmación de aplicación por el usuario, pendiente verificar A/B/anónimo, visibilidad, CAS/reintentos/concurrencia, repetición y persistencia/reinicio/cuenta/Android. Generación o confirmación de aplicación no acredita esas verificaciones. [ADR-050](decisiones/050-casos-guardados-por-cuenta.md), [ficha](funcionalidades/casos-guardados.md). Sin publicación/commit/push ni cierre de historia.

## Explorar: controles en una fila — 16 de octubre de 2026

Por instrucción del usuario, Ubicación queda a la izquierda y Filtrar casos a la derecha, siempre en la misma fila. Se retira la disposición apilada. FilterExpansion admite presentación compacta: menor padding horizontal/iconos, sin reducir fuente ni área táctil. Con poco ancho o texto ampliado se omite solo el icono inicial para dar espacio a las etiquetas; texto puede crecer en altura y ambas cápsulas conservan altura compartida. Desplegables mantienen ancho completo, anclaje izquierdo para Ubicación y derecho para Filtrar casos, blur/transición y selección previos. Sin cambios de consulta, radio, permisos o backend.

Formato aplicado; análisis estático de los dos componentes. Sin pruebas, renders ni build por instrucción vigente; pendiente comprobación visual en Android normal/pequeño/texto ampliado. Se conserva feature/explore-case-list y el trabajo existente, sin publicación ni cierre de historia.

## Ajuste vigente de Explorar: desplegable y distancia — 15 de octubre de 2026

**Indicador vigente al jalar:** tras investigar documentación oficial de Flutter y fuente instalada3.35, se reemplaza la flecha por Icons.refresh_rounded que acompaña el descenso, se acomoda al soltar, gira durante la operación real y se retrae/desvanece al terminar/cancelar. Movimiento reducido sin giro ni retorno animado; contenido conserva shimmer. Se sincroniza refresh explícitamente porque noSpinner3.35 no notifica esa entrada; la acción accesible también se retira al finalizar. [ADR-049](decisiones/049-indicador-recarga-y-retorno.md) sustituye el detalle de flecha de048. Formato/dart analyze del componente sin incidencias. Sin pruebas, renders o build por instrucción vigente; gesto y rendimiento Android pendientes.

**Actualización por gesto:** por petición del usuario, se elimina el icono de refresco de Explorar y el botón ordinario Actualizar ubicaciones. PullToRefresh/PullToRefreshTarget compartidos conectan jalar desde arriba al ViewModel de Explorar, lista activa/archivada de Mis mascotas y Ubicaciones de interés. Vacíos/listas cortas admiten gesto; umbral y cancelación nativos sin spinner, flecha y shimmer durante operación real, semántica Actualizar contenido y movimiento reducido. Mantiene filtros/centro/radio y contenido durante refresh. Ubicaciones usa ContentRefresh en vez de su franja fina anterior y no admite gesto con editor abierto. Scrolls anidados no disparan actualización. Reintentos de error conservados. [ADR-048](decisiones/048-actualizar-listas-al-jalar.md).

Validación de este incremento: formato y flutter analyze --no-pub sin incidencias; componente compartido revisado además con dart analyze tras añadir accesibilidad, sin incidencias. **Sin ejecutar pruebas por instrucción vigente**, sin renders/build ni comprobación de gesto en dispositivo. Pendiente Android: umbral/cancelación, listas cortas/vacías, selección/filtros, errores, cambios de sección/cuenta y accesibilidad. Sin SQL/permisos nuevos, publicación ni cierre de historia.

Diagnóstico posterior de captura de VS Code: currentLocationRepositoryProvider/placeSearchRepositoryProvider y getters de AppBootstrap existen en los archivos actuales, con imports e inyección presentes en main.dart. `dart analyze lib/main.dart lib/app/bootstrap.dart lib/features/explore/providers/explore_providers.dart` devuelve No issues found. No se reproduce el diagnóstico undefined mostrado por el editor; posible estado desactualizado del servidor de análisis o buffers distintos, sin confirmar causa. Se indica reiniciar Dart Analysis Server y, si persiste, recargar ventana. Sin cambios artificiales de código ni pruebas ejecutadas; no se acredita compilación nativa con esta comprobación.

**Comportamiento vigente:** inicio por ubicación actual/radio15km; control Ubicación, sin Todas las ubicaciones. Denegación/servicio apagado/timeout deja selección manual sin consultar un listado global ni mostrar vacío confirmado. Usar mi ubicación actual permite volver conservando radio/filtros. GetCurrentExploreLocation/CurrentLocationRepository y adaptador/fuente de geolocator14.0.2 inyectados desde bootstrap/main; permiso aproximado Android y descripción iOS. SearchCases exige centro/radio, sin cambiar contrato SQL019. Texto visible Zona/Zonas sustituido en toda la app por Ubicación/Ubicaciones, manteniendo contratos/rutas/datos. [ADR-047](decisiones/047-ubicacion-actual-y-radio-inicial.md).

Validación de este incremento: flutter pub get resuelto, formato y **flutter analyze --no-pub sin incidencias**. La versión14.1.1 no resolvió con Dart3.9.2; se fijó14.0.2 sin actualizar SDK. Expectativas existentes/fixtures de ubicación y comprobación de fronteras adaptados, **sin ejecutar pruebas por instrucción del usuario**. Sin build, renders, GPS real ni despliegue. Pendiente recompilar Android por permiso/plugin nuevo y comprobar ubicación/denegaciones/timeout/manual/radio15km con019 activo; Apple pendiente de configuración/prueba. Evidencia previa no acredita estos recorridos nuevos.

Último cambio: sugerencias de ciudad/dirección mientras escribe, desde3 caracteres y tras600ms de pausa. Se retira Buscar ubicación y el campo permanece editable durante consulta. ViewModel cancela temporizador/cola al limpiar, seleccionar, cambiar cuenta o desmontar; descarta respuestas antiguas y serializa una petición activa con última consulta pendiente. Se conserva caché, cinco resultados, toast de fallos y selección manual. Photon declara search-as-you-type; demo sigue condicionada a uso razonable. [ADR-046](decisiones/046-sugerencias-automaticas-de-ubicacion.md). Formato/revisión y recorrido existente adaptado sin ejecutar pruebas, renders, build ni llamadas reales por instrucción vigente. Pendiente revisión Android de concurrencia, teclado y resultados.

Última separación solicitada: Zona sale de Filtrar casos a un control propio, con ciudad/dirección, mapa, radio y Aplicar zona. Filtrar casos conserva tipo/especie/estado/período. Selección confirmada única: aplicar uno conserva lo confirmado en el otro. Controles en fila o vertical según ancho/texto; paneles de ancho completo, Zona anclada por la derecha en fila. Reutilizan transición y componentes existentes. [ADR-045](decisiones/045-explorar-zona-independiente.md). Formato/revisión de código y adaptación del recorrido existente sin ejecutarlo por instrucción vigente; sin tests, renders o build nuevos. Pendiente validación visual Android y conservación de consulta con019; sin cambios de backend ni cierre de historia.

Por petición posterior del usuario, el indicador móvil de las opciones de filtros pasa de320ms a180ms para responder más rápido, manteniendo curva suave y movimiento reducido directo. Cambio en FilterChoiceGroup compartido; no modifica los tiempos de apertura/cierre del panel. Formato aplicado, sin pruebas por instrucción vigente; pendiente confirmación visual.

Refinamiento posterior: el color de Filtrar casos, texto/iconos y rotación del chevrón siguen la misma animación del panel; al cerrar empiezan a volver inmediatamente, sin esperar a retirar el portal ni sumar la animación implícita de Material. Se elimina además el destello claro al pulsar opciones: FilterChoiceGroup y el disparador usan NoSplash/overlay transparente como TwoOptionFilter de Mis mascotas. Formato y revisión de código; sin pruebas/build/renders por instrucción del usuario. Pendiente confirmación visual Android.

Último ajuste de UX pedido por el usuario: sustituir el blur inmediato y cover/stagger por transición inspirada en Control Center de iPhone. Fondo con blur progresivo0–16 y velo0–28%, expansión/fundido del panel desde arriba, apertura420ms/cierre280ms sincronizados. Recorte excluye el selector real, que permanece nítido e interactivo. Salida animada antes de retirar portal, doble envío bloqueado, ticker liberado y movimiento reducido directo. Aproximación Flutter, sin afirmar igualdad con compositor nativo. [ADR-044](decisiones/044-filtros-transicion-control-center.md). Formato aplicado; sin pruebas, renders ni build por instrucción vigente. Pendiente revisión Android de apariencia/rendimiento, recorte, teclado y cierre durante apertura.

Por aclaración del usuario, FilterExpansion ahora usa OverlayPortal anclado debajo de Filtrar casos: mismo ancho, superficie neutra y scroll propio, sin desplazar las cards ni abrir ventana centrada. Cerrar fuera/Atrás descarta edición; Aplicar confirma sin mover el scroll principal. Portal ligado al ciclo de vida del propietario. Conserva selección compartida, búsqueda de ciudad/dirección, mapa y radio1–50km.

Cards con un único badge de estado Abierto/Resuelto, nombre y distancia aproximada desde el centro elegido: A 4 km o A menos de 1 km. Sin especie, fecha ni badge de tipo. Sin distancia del servidor se omite esa línea; no se inventa ubicación. Nombre ausente se indica como Sin nombre. Sin cambios de SQL, permisos ni alcance de HU-07.1.

Validación de este ajuste: formato Dart y revisión estática; **no se ejecutaron pruebas por instrucción explícita del usuario**, ni se generaron nuevos renders/compilaciones. La expectativa existente de posición de cards se adapta al desplegable, sin ejecutarla. Las336 pruebas de la iteración anterior no validan estos cambios. [ADR-043](decisiones/043-explorar-desplegable-anclado-y-distancia.md) y ficha actualizados. Siguiente paso: revisar visualmente en Android el desplegable/teclado/scroll y distancia con019 activo. Sin publicación, commit/push ni cierre de historia.

## Hechos comprobados

- Carpeta actual: `C:\Users\Administrator\Documents\projects\entreHuellas`.
- Comprobación inicial del chat 00: `main`, commit de partida `8c5fdee` (`init`), árbol limpio. El proyecto ya tenía commits y una app Flutter multiplataforma con una pantalla `Hello World!`; el estado previo del 4 de octubre quedó desactualizado.
- La app se conserva en `apps/mobile`, según la decisión de ubicación del 6 de octubre de 2026. No se creó `apps/mobile` ni se regeneraron las plataformas.
- Flutter 3.35.3 stable / Dart 3.9.2. No se actualizó el SDK.
- `flutter doctor`: Android SDK 36.1.0-rc1, Command-line Tools ausentes y licencias de estado desconocido. `flutter devices`: Windows, Chrome y Edge; ningún Android conectado.
- Identificador Android conservado: `com.example.flutter_application_entrehuellas`, provisional. El proyecto mantiene firma debug para release; distribución pendiente.
- No se consultó ni modificó el remoto en esta tarea. No se realizaron commit, push, issues, PR ni despliegues.

## Completado

- Chat **00 - Proyecto y estructura**: preparación local de arquitectura. No corresponde al cierre de HU-01 / RF-01,34.
- Clean Architecture por funcionalidad con `presentation`, `domain` y `data`. Entidad/contrato de sesión independientes del SDK, repositorios y fuentes de datos inyectados, casos de uso y estado de presentación.
- Riverpod 3.3.2, go_router 17.2.3 y supabase_flutter 2.18.0, resueltos con el SDK instalado y registrados en `pubspec.lock`. Se conservaron los registros de plugins generados para macOS/Windows.
- Inicio, tema Material 3, pantalla de acceso y navegación `/` -> `/access` con regreso. Rutas desconocidas permiten volver al inicio sin mostrar la URL.
- Bootstrap valida configuración pública e inicializa Supabase con PKCE antes de montar Riverpod. Estados explícitos: falta configuración, configuración inválida, fallo de arranque y SDK preparado. Este último no acredita conectividad ni credenciales remotas válidas.
- `AuthViewModel` observa cambios de identidad mediante `WatchAuthSession` y el contrato del repositorio; las pantallas no llaman al SDK. Identidad de sesión sin tokens en `domain/entities`.
- Configuración vía `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`, usando `--dart-define-from-file`. Ejemplo vacío en `config/supabase.local.example.json`; `config/supabase.local.json` comprobado como ignorado por Git. Solo se aceptan URL HTTPS y claves `sb_publishable_...`.
- Android registra INTERNET y `entrehuellas://login-callback/`. iOS registra el esquema. Manejador de deep links de Flutter desactivado en ambos para que Supabase/app_links gestione Auth sin duplicar el callback en go_router.
- CI local preparado en `.github/workflows/flutter.yml`, Flutter 3.35.3, formato/análisis/tests y lockfile. No ejecutado en GitHub.
- Actualizados AGENTS, README, arquitectura y guía para conservar la ubicación existente. Añadida `docs/CONFIGURACION.md` con preparación de Supabase y pruebas móviles pendientes. Las plantillas previas se conservaron.

## Refuerzo de la base, 7 de octubre de 2026

- Se estableció una estructura de arquitectura común para el MVP y los incrementos posteriores: operaciones de dominio mediante casos de uso, entidades y contratos independientes de UI/backend. La decisión quedó registrada en AGENTS, arquitectura y guía.
- Se conservó `main`, todo el trabajo local del chat anterior y `.vscode/settings.json` existente. No hubo commit/push ni cambios de infraestructura.
- `AuthSession` se organizó en `domain/entities`, `AuthRepository` en `domain/repositories` y se añadió `domain/use_cases/WatchAuthSession`. El caso de uso elimina identidades consecutivas repetidas, mantiene transiciones y propaga errores. Se actualizaron los imports y la inyección de Riverpod.
- Se añadió prueba de dependencias arquitectónicas para imports/exports de dominio y acceso directo desde presentación a data/SDKs. Se probaron deduplicación de identidad, cambio de usuario, cierre/reentrada y propagación de errores.
- Se detectó que `config/supabase.local.json` ya existe, sin leer ni modificar sus valores. Se añadieron perfiles de VS Code para desarrollo local y sin Supabase, abriendo la raíz o la carpeta Flutter; sin credenciales en launch.json. JSON y rutas de entrada comprobados. F5 interactivo no ejecutado.
- Validación del refuerzo: `dart format lib test` completado (20 archivos), `flutter analyze --no-pub` sin incidencias, `flutter test --no-pub`: **15 pruebas aprobadas** y `git diff --check` correcto. No se repitió build web; la compilación anterior consta debajo. Android y Supabase remoto siguen pendientes.

## Revisión de presentation y data, 7 de octubre de 2026

- Se mantuvieron la rama `main`, todos los cambios previos, configuración local y plataformas existentes. No se leyeron valores de configuración ni se realizaron acciones GitHub.
- Presentation se organizó en `screens`, `view_models`, `state` y `widgets`. `AccessScreen` observa solo `AuthViewModel`, que entrega `AuthViewState` con arranque y AsyncValue de sesión. Los mensajes de UI se trasladaron de core a presentación. Home sigue sin ViewModel porque no tiene operaciones ni datos de negocio.
- Data se organizó en `data_sources`, `models` y `repositories`. `SupabaseAuthDataSource` encapsula el SDK y expone DTO sin tokens; `AuthRepositoryImpl` transforma DTO a entidades y errores síncronos/de stream a `AuthFailure`. El repositorio puede seguir observando después de un error.
- Declaraciones DI de auth en `features/auth/providers/auth_providers.dart`, sin dependencias de data/presentation. `main` y bootstrap inyectan implementaciones. Se retiró `app/providers.dart`; presentación ya no depende de app. Arranque no configurado evita resolver/observar auth.
- ViewModel/stream de sesión usan autoDispose. Se desactivó el reintento automático del provider de stream; la recuperación mediante un evento posterior conserva la suscripción. El caso de uso transmite cancelación/pausa/reanudación y mantiene historial independiente por suscripción.
- Las pruebas detectaron un fallo en la deduplicación previa con `distinct`: después de un error se descartaba una identidad igual a la última válida. Corregido y comprobado tanto para sesión activa como para sesión nula. El error se muestra sin presentar una identidad obsoleta como estado válido.
- Reglas arquitectónicas ampliadas a presentation/data/providers, incluyendo directivas condicionales y `part`. La revisión de directivas complementa el análisis, no sustituye una auditoría completa de símbolos/transitividad.
- Validación: formato correcto (30 archivos), `flutter analyze --no-pub` sin incidencias y `flutter test --no-pub`: **26 pruebas aprobadas**. Incluyen mapeo/error/continuación/cancelación del repositorio, estados y ciclo de vida del ViewModel, recuperación tras errores, suscripciones independientes, adaptador con estado local del SDK y layout 320×350 con escala de texto 2.
- `flutter build web --no-pub`: correcto tras la reorganización; dry run Wasm correcto y mismo aviso no bloqueante de CupertinoIcons ausente. `git diff --check`: correcto.
- Las pruebas del adaptador usan sesión ficticia almacenada solo en el SDK local; no acreditan autenticación remota. No se modificaron dependencias ni se implementó HU-01. Android y Supabase remoto continúan pendientes.

## Validación de la base del 6 de octubre de 2026

Desde `apps/mobile`:

- `flutter pub get --enforce-lockfile`: correcto.
- `dart format --output=none --set-exit-if-changed lib test`: correcto, 17 archivos sin cambios después del formato inicial.
- `flutter analyze`: sin incidencias.
- `flutter test`: **12 pruebas aprobadas**. Cubren arranque sin backend, rechazo de configuración parcial/HTTP/credenciales en URL/query/claves secretas/JWT, navegación y regreso, propagación de sesión y errores desde un repositorio sustituido, estados inválido/fallido y ruta desconocida.
- `flutter build web --no-pub`: correcto; también pasó el dry run Wasm. Aviso no bloqueante sobre fuente CupertinoIcons ausente. Este build de la app Flutter no implementa la web pública QR de S4.
- Manifiesto Android e Info.plist iOS parseados como XML correctamente. Esto no acredita la resolución del enlace en un dispositivo.
- `git diff --check`: sin errores de whitespace. Git avisa de conversión futura LF/CRLF por configuración local.

Las pruebas de sesión usan un repositorio sustituido; no equivalen a acceso contra Supabase. No se ejecutó la app en teléfono/emulador ni en navegador interactivo.

## Norma de arquitectura, 7 de octubre de 2026

- Creado `docs/REGLAS_ARQUITECTURA.md` como norma del sistema: Clean Architecture por funcionalidad, MVVM, Repository, Adapter, casos de uso, inyección, estado inmutable y SOLID.
- Define responsabilidades de presentation/domain/data/providers/composición, dependencias permitidas/prohibidas, calidad por responsabilidades sin límites arbitrarios de líneas, manejo de errores/streams, seguridad y criterios de revisión. Los cambios de reglas se registran como decisiones versionadas.
- Lectura incorporada a AGENTS y enlaces añadidos desde README, arquitectura y guía. Se conservó la app y todo el trabajo local previo en `main`; esta tarea modifica solo documentación.
- Validación documental: coherencia con la implementación actual, enlaces locales y `git diff --check`. No se repitieron pruebas/builds Flutter; la última evidencia de código sigue siendo 26 pruebas aprobadas y build web correcto, descrita arriba. Los controles automáticos existentes son parciales y se complementan con revisión.
- Siguiente paso: aplicar esta norma al implementar HU-01 y mantener las comprobaciones arquitectónicas. Android y Supabase remoto continúan pendientes.

## Documentación de la decisión arquitectónica, 7 de octubre de 2026

- Añadido `docs/decisiones/001-arquitectura-aplicacion.md` (ADR-001) con contexto, decisión, motivos, alternativas y consecuencias. Relaciona las capas con los recorridos de recuperación, datos públicos/privados, pruebas y la incorporación prevista de almacenamiento local.
- README general, arquitectura, reglas, guía y AGENTS describen Clean Architecture por funcionalidad con MVVM, casos de uso, repositorios, adaptadores e inyección. La configuración describe el recorrido de sesión actual. Se conservaron los registros históricos y sus resultados de validación.
- Sustituido el README genérico de Flutter por instrucciones de desarrollo, configuración, comprobaciones y referencias de arquitectura. Las plantillas de historia/PR incluyen la norma y el registro de cambios arquitectónicos.
- La documentación distingue la base de sesión implementada de los flujos previstos de mascotas, recuperación y almacenamiento local. El registro de decisión incluye los costos de los contratos/mapeos y los límites de una futura sustitución del backend.
- Validación: enlaces locales y coherencia de referencias revisados, `git diff --check` sin errores. Cambios solo documentales; no se repitieron pruebas Flutter. Se conservó el trabajo local en `main` sin acciones GitHub ni configuración remota.

## Organización de la base de datos, 7 de octubre de 2026

- Estado de partida de esta tarea: rama `main`, commit `8503fa3` (`feat: Initialize Supabase and set up authentication structure`), árbol limpio antes de editar. Se conservaron los archivos existentes.
- Confirmado `config/supabase.local.json`: JSON y formato de URL HTTPS/clave publicable compatibles con AppConfig, sin mostrar ni modificar valores. Archivo ignorado por Git. Esto no verifica credenciales remotas ni autenticación.
- Creado `database` con 11 directorios versionables: extensions, types, tables, indexes, functions, triggers, views, policies, grants, seeds y tests. Su README define numeración global `001_...sql`, dependencias, separación de datos de prueba y conservación del SQL aplicado. No se crearon objetos de base de datos ni scripts SQL ficticios.
- ADR-002 registra la organización por objeto y la generación prevista de migraciones de Supabase a partir de las fuentes. Actualizados AGENTS, README, arquitectura, reglas, guía y configuración. El procedimiento de generación se debe implementar y comprobar en S1 antes del primer despliegue.
- Validación: directorios y enlaces locales comprobados, `git diff --check` correcto y protección Git de la configuración local confirmada. No hay SQL nuevo que ejecutar; no se realizaron pruebas de permisos ni se repitieron pruebas Flutter. Supabase CLI y psql no se encontraron en PATH.
- No se ejecutó SQL local/remoto ni se modificó el proyecto Supabase. No hubo commit, push o despliegue en esta tarea.
- Siguiente paso: S1 / HU-01, definir el primer esquema y sus políticas en database, preparar generación/migración y probar permisos con dos usuarios antes de aplicarlo al entorno de desarrollo autorizado.

## Icono Android, 7 de octubre de 2026

- Inicio de tarea: rama `main`, commit `6abc4a5`; solo `logo` tenía archivos sin seguimiento. Se conservaron todos los originales exportados desde Figma.
- Fuente clásica: PNG `Logo EntreHuellas 512 vector inner v2@2x.png`, 1024×1024. Fuente adaptativa: SVG `Logo EntreHuellas 512 vector inner v2-16.svg`, viewport 512×512. PNG inspeccionado visualmente y dimensiones de las cuatro exportaciones comprobadas.
- Añadido flutter_launcher_icons 0.14.4 como dependencia de desarrollo, configuración Android y script `tool/generate_android_icons.ps1`. Generados los PNG clásicos para mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi, vectores de símbolo/fondo/monocromo y recursos adaptativos API 26+/33+. El manifiesto conserva `@mipmap/ic_launcher` y su deep link existente.
- La variante adaptativa conserva formas y colores del vector y centra el símbolo con escala 0.72. VectorDrawable no traslada los filtros de textura/sombra interna del SVG. Los iconos de otras plataformas no se modificaron.
- Generación ejecutada correctamente. PNG xxxhdpi inspeccionado visualmente; cinco densidades comprobadas como 48/72/96/144/192 px y cinco XML parseados. Sintaxis del script PowerShell comprobada.
- AAPT2 36.0.0 compiló todos los recursos Android y los enlazó contra android-36 correctamente con un manifiesto de validación mínimo. Esto verifica recursos/referencias; el artefacto de validación no es un APK ejecutable de la app.
- Formato: 30 archivos Dart sin cambios. `flutter analyze --no-pub`: sin incidencias. No se repitieron las pruebas de lógica Flutter; las comprobaciones pertinentes al cambio fueron generación, recursos nativos y análisis.
- `flutter build apk --debug --no-pub` falló antes de compilar por `java.io.IOException: Unable to establish loopback connection`. Un intento con opciones temporales IPv4/sin daemon produjo el mismo fallo; no se cambiaron opciones persistentes de Gradle. Build de la app e instalación/icono en launcher no verificados.
- `flutter doctor` mantiene Command-line Tools ausentes y licencias desconocidas. `flutter devices` no detectó Android conectado. No hubo commit, push ni despliegue.
- Instrucciones de regeneración/instalación en `logo/README.md` y enlace desde configuración. Siguiente paso: resolver entorno Android/Gradle, iniciar emulador y verificar el icono con sus recortes tras reinstalar la app.

## Primera ejecución Android observada, 7 de octubre de 2026

- Se reportó compilación desde VS Code y se aportaron capturas del emulador con las pantallas Inicio y Acceso y cuenta. La navegación a acceso es visible; la interfaz coincide con la base implementada. No se aportó un log de build, ni se repitió la compilación desde esta sesión.
- `flutter devices` detectó `emulator-5554`, Android 16/API 36, android-x64. Las comprobaciones anteriores sin dispositivo son históricas.
- La pantalla muestra `Falta configurar el servicio de acceso`: esa ejecución recibió los dos dart-define vacíos. El archivo local conserva las propiedades de URL y clave publicable con valores; los perfiles de launch.json incluyen el argumento esperado. Revisar perfil seleccionado y detener/reiniciar con `Entre Huellas - desarrollo local`, en lugar de continuar una ejecución sin configuración.
- Estado esperado al cargar la configuración: `Servicio de acceso preparado` y `Sin sesión activa`. Esto confirma inicialización del SDK, no autenticación remota. Registro/login/perfil siguen pendientes de HU-01.
- El icono en el launcher y el retorno real del deep link no se observan en estas capturas. El error de loopback documentado corresponde al intento previo de esta sesión; no bloqueó la ejecución reportada desde VS Code.
- Siguiente paso: relanzar con el JSON, comprobar el estado de acceso y el icono del launcher; después implementar y validar S1. No se cambiaron archivos de la app ni se leyeron valores de credenciales para mostrarlos.

## Arranque desde main.dart, 7 de octubre de 2026

- Configurado `templateFor` del perfil local en ambos launch.json: `apps/mobile/lib` al abrir el repositorio y `lib` al abrir la app. Run/Debug predeterminado de Dart/Flutter utiliza los argumentos del JSON sin seleccionar manualmente el perfil. El perfil sin Supabase permanece disponible para ejecución explícita.
- Se conservaron los settings existentes y los valores de configuración. La plantilla no se aplica a las pruebas ni añade argumentos globales a otros proyectos.
- Validación: JSON, rutas de plantilla/entrada/configuración y diff comprobados. El comportamiento de templateFor se contrastó con la documentación de Dart Code. El relanzamiento desde el botón del editor aún requiere comprobarse en la sesión de VS Code; no se volvió a compilar ni se ejecutaron pruebas de lógica por este cambio de configuración.
- Siguiente paso: detener con el botón cuadrado y relanzar desde Run/Debug de main.dart; comprobar `Servicio de acceso preparado` en acceso. La ejecución Android observada anteriormente sigue siendo válida para la base sin configuración.

## Arranque con configuración confirmado, 7 de octubre de 2026

- Se confirmó que, al relanzar desde el botón de main.dart, Acceso y cuenta muestra `Servicio de acceso preparado` y `Sin sesión activa`. El perfil local carga el JSON y el SDK se inicializa en la ejecución Android reportada.
- Esta confirmación corresponde al arranque y estado inicial; todavía no acredita login, permisos remotos, restauración de sesión o retorno del deep link. No se ejecutaron pruebas ni builds adicionales desde esta sesión.
- Siguiente incremento: S1 / HU-01, RF-01,34, con registro/acceso, perfil, cierre de sesión y permisos. Conservar este procedimiento de arranque y la organización de fuentes SQL en database.

## Trazabilidad con GitHub, 7 de octubre de 2026

- Consultados los issues de `srg-cp/entrehuellas`: se encontraron las historias HU-01 a HU-16. No se encontró un issue específico de preparación/chat 00 en los resultados.
- S1 / HU-01, RF-01,34 corresponde actualmente a [issue #1: Entrar y gestionar mi cuenta](https://github.com/srg-cp/entrehuellas/issues/1). El número de historia y el número de issue se conservan como identificadores distintos aunque en este repositorio coincidan.
- La base de arquitectura, configuración y observación de sesión prepara HU-01; no cumple todavía sus criterios de registro/correo/Google, perfil, cierre, persistencia de sesión y baja. No corresponde declarar la historia terminada por el arranque del SDK.
- El issue #1 conserva tareas de ASP.NET Core que no coinciden con ADR-001 y la arquitectura Flutter + Supabase. Su descripción técnica requiere actualización antes de ejecutar S1; no se modificó ni cerró ningún issue en esta consulta.
- Validación de esta tarea: lectura del repositorio/issues y contraste con la guía. Sin cambios de código, pruebas o build nuevos.

## Rediseño de Inicio y Acceso, 7 de octubre de 2026

- Dirección visual basada en las referencias aportadas: tarjetas de radio 32, botones tipo píldora, títulos grandes, superficies coloreadas y fondo claro (dirección inicial sustituida por la paleta neutra vigente). Tema y colores en core; componentes compartidos para tarjetas, marca, etiquetas y acción fija. La UI está construida con Flutter; bootstrap solo prepara el arranque.
- Inicio muestra marca, ilustración, acceso real a cuenta y próximos recorridos identificados. Acceso conserva su ViewModel/estados de arranque y sesión, incorpora tarjetas visuales y una acción de regreso. No se implementó login ni se añadieron publicaciones/acciones simuladas; dominio/data permanecen sin cambios.
- Ilustración derivada mediante image_gen del material existente en mockups, guardada en `assets/illustrations/community_pets.png`; origen/prompt en su README. Transparencia y composición inspeccionadas. Copia del logo original en `assets/branding/app_icon.png`; assets registrados en pubspec sin nuevas dependencias.
- `flutter pub get --enforce-lockfile`, formato y análisis correctos. `flutter test --no-pub`: **27 pruebas aprobadas**, incluyendo navegación y estado más Inicio/Acceso en 320×350 y texto ampliado a escala 2.
- Render QA ejecutado con `flutter test --no-pub tool/capture_ui_preview.dart`: 1 comprobación aprobada y capturas 390×844 en `build/ui-preview`. Fuentes reales del SDK cargadas para inspección; se revisaron ambas pantallas y se ajustó la ilustración de Acceso para mantener el estado inicial visible. El repositorio de esas capturas está sustituido: no prueba autenticación remota.
- `flutter build web --no-pub`: correcto, incluido dry run Wasm. Persiste el aviso no bloqueante de fuente CupertinoIcons de comprobaciones anteriores. Enlaces y `git diff --check` correctos. No se compiló ni instaló este rediseño Android desde esta sesión.
- Actualizados guía y arquitectura, añadido `docs/DISENO_UI.md` y regla de UI en AGENTS. Se conservaron los cambios locales anteriores y los valores de configuración; sin acciones GitHub ni modificaciones remotas.
- Pendiente comprobar este rediseño en el emulador, deteniendo/reiniciando desde main.dart para incorporar assets. El siguiente incremento funcional sigue siendo HU-01; su issue requiere adaptar las tareas técnicas registradas previamente.

## Login y preparación de perfiles, 7 de octubre de 2026

- Se conservó `main` y el trabajo previo. El acceso se reemplazó por el mockup: fondo blanco, marca negra, sans serif del sistema, campos redondeados, contraseña ocultable y botones sociales. Se retiraron widgets de estado visual que habían quedado sin uso.
- Correo/contraseña y Google conectados mediante `SignIn`, `AccessRepository`, fuente Supabase y `LoginViewModel`; `SignOut` cierra la sesión local. Se mantiene observación de sesión por eventos: iniciar OAuth no se presenta como sesión confirmada. Controles bloqueados durante solicitudes, prevención de duplicados, mensajes seguros y recuperación tras error/disposición del ViewModel.
- Consulta de solo lectura a `/auth/v1/settings` con configuración pública local: Google y correo habilitados; Apple deshabilitado. No se imprimieron ni modificaron claves. Apple aparece deshabilitado; registro y recuperación muestran aviso de pendiente, sin simular operaciones completas.
- Preparadas fuentes SQL 001–007: `public.profiles`, funciones de alta/timestamp, triggers, RLS por propietario, grants por columna y perfiles para cuentas existentes. Contraseñas permanecen en Supabase Auth. `database/scripts/Build-Migration.ps1` y plan versionado generan `supabase/migrations/20261007000100_auth_profiles.sql`, con transacción, fuentes y hashes; regeneración idéntica comprobada.
- Preparada prueba SQL con dos usuarios y rollback: creación por trigger, lectura/actualización propia, aislamiento cruzado, timestamps protegidos, rechazo de DELETE/acceso anónimo y revocación de ejecución de función privilegiada. **No ejecutada en PostgreSQL**: psql/CLI no disponibles y Docker sin motor accesible. Analizador pglast verificó sintaxis de 9 archivos SQL, ambas funciones PL/pgSQL y los bloques de pruebas; esto no acredita permisos ni integración con el catálogo de Supabase.
- Formato correcto (50 archivos), análisis sin incidencias y **34 pruebas Flutter aprobadas**. Incluyen límites arquitectónicos, validación de credenciales, reintento/duplicados, disposición durante solicitudes y adaptador contra HTTP sustituido con sesión devuelta y rechazo Auth. `http` se declaró como dependencia de desarrollo para este cliente de prueba, conservando su versión ya resuelta 1.6.0. Todas las credenciales de pruebas son ficticias.
- Render QA: 1 comprobación aprobada; captura de login inspeccionada en 390×844. Corregidos desbordamientos del separador y marca al ampliar texto; pruebas en 320×350/escala 2 aprobadas. `flutter build web --no-pub` correcto y dry run Wasm correcto; persiste aviso no bloqueante de CupertinoIcons ausente.
- Actualizados diseño, arquitectura, configuración, guía, ADR-002, READMEs y organización SQL. Símbolo Google guardado como asset local con procedencia oficial documentada.
- **Pendiente:** aplicar migración y probar RLS en desarrollo, ingresar con una cuenta real por correo y Google, comprobar callback/retorno con app abierta/cerrada, persistencia y cierre en Android. No se compiló ni instaló este incremento Android desde esta sesión. No hubo despliegue remoto ni acciones GitHub; HU-01 (issue #1) sigue abierta.

## Run all y convención SQL, 7 de octubre de 2026

- Preparado `database/run_all.sql`, autocontenido para SQL Editor, generado por `scripts/Build-RunAll.ps1` desde las fuentes 001–007. La migración anterior y sus fuentes permanecen intactas; los hashes se comprueban antes de generar. El generador rechaza cambios de plan sin revisar cómo repetirlos.
- Transacción y bloqueo asesor; creación de objetos ausentes, RLS/grants y backfill sin duplicados. No sustituye funciones/políticas/triggers preexistentes ni modifica datos de perfiles existentes. Valida estructura básica/constraints de la tabla existente y rechaza incompatibilidad. No es una auditoría completa ni reparación automática de deriva.
- Convención registrada: identificadores SQL en inglés y `snake_case`; propiedades Dart `camelCase`, clases `PascalCase`. ADR-003, reglas, AGENTS, arquitectura, configuración, guía y README actualizados.
- **3 pruebas locales aprobadas** en PostgreSQL en memoria (PGlite 0.5.8): tres ejecuciones conservan perfiles editados/fechas/OID; entrada después de la migración anterior; tabla incompatible aborta sin alterar datos. También se ejecutaron las aserciones SQL de permisos entre usuarios, roles y columnas en esa base local con fixture de Auth. No incluye GoTrue ni valida el proyecto Supabase remoto.
- Análisis sintáctico SQL/PLpgSQL correcto y generación reproducible comprobada. Sin cambios Flutter, despliegues ni acciones GitHub. Sigue pendiente aplicar y comprobar `run_all.sql` y permisos en Supabase de desarrollo, además del login real Android.

## Ajustes visuales del login, 7 de octubre de 2026

- Reemplazada la huella genérica del login por `BrandMark`, reutilizando el logo original y su asset existente en `assets/branding/app_icon.png`. SHA256 idéntico a `logo/Logo EntreHuellas 512 vector inner v2@2x.png`; originales conservados sin copias adicionales.
- Campos con radio 22, botones con radio 24 y alturas mínimas 56–58. Textos de campos/sociales/subtítulo 16, ingreso 17, recuperación 14, pie 15 y título 28. Se conserva sans serif del tema, texto ampliable y scroll; marca ajustable al ancho.
- Solo cambió presentación. Los ViewModels, casos de uso, repositorios y comportamiento de acceso permanecen intactos. Actualizados diseño y procedencia de assets.
- Formato correcto (42 archivos de lib), análisis sin incidencias y 34 pruebas aprobadas, incluyendo 320×350 con texto a escala 2. Captura Flutter 390×844 generada y revisada; no se compiló/instaló este ajuste en Android. Sin cambios de Supabase ni acciones GitHub.

## Diagnóstico de Google OAuth, 7 de octubre de 2026

- Captura Android: Google rechaza el ingreso con `400 redirect_uri_mismatch`. La captura del cliente web autoriza el callback público con una sola ruta `/auth/v1/callback`.
- Consulta de diagnóstico sin seguir redirecciones ni iniciar sesión: Auth responde HTTP 302 y envía `https://entrehuellas-supabase.kormind.com/auth/v1/auth/v1/callback` a Google. Confirmada duplicación de ruta en el callback generado por el servidor. No se imprimieron claves, códigos, estado OAuth ni tokens.
- Documentada corrección de la variable efectiva `GOTRUE_EXTERNAL_GOOGLE_REDIRECT_URI` y revisión de su composición con `API_EXTERNAL_URL`, seguida de recreación del servicio Auth. Flutter/SQL no requieren cambios para este error. No se accedió al servidor ni se modificó Google Cloud.
- Pendiente identificar la plataforma de despliegue, corregir su configuración, volver a consultar el callback y repetir el ingreso real. Sin nuevas pruebas Flutter ni build: solo diagnóstico de red y documentación.

## Login primero y onboarding por cuenta, 7 de octubre de 2026

- Corrección explícita del usuario: retirada la bienvenida pública y la pantalla intermedia “Tu cuenta”. Login es la entrada sin sesión; sesión confirmada conduce automáticamente al onboarding pendiente o a la app. La pantalla posterior es una base autenticada para funcionalidades futuras, sin publicaciones simuladas.
- Implementada funcionalidad onboarding con dominio (contrato, fallos, CheckOnboarding/CompleteOnboarding), data (DTO, fuente SDK/repositorio) y presentación (ViewModels/estado/pantallas). Inyección en bootstrap/main. Router único refrescado por estado de entrada: no recrearlo por cada sesión ni permitir rutas protegidas antes de autenticar/completar.
- Tres etapas exactas de texto: Cada huella importa, Volvamos a casa y Una nueva historia; imágenes originales del mockup mostrado por regiones en Flutter, sin generación nueva. Original conservado y copia en assets/onboarding. Marca compartida en core como BrandWordmark, controles reales, indicadores, scroll y áreas seguras.
- Omitir/Comenzar guardan finalización por cuenta en Supabase mediante RPC. Lectura fallida ofrece reintento sin saltar el flujo; guardado fallido conserva onboarding. Una sesión restaurada/completada abre la app; otra cuenta conserva su propio criterio. Una respuesta tardía del usuario anterior no modifica la ruta actual.
- Nuevas fuentes 008–009 y migración 20261007000200_onboarding_completion.sql: columna protegida onboarding_completed_at y RPC complete_onboarding con auth.uid(), fecha de servidor y operación repetible. Ampliado run_all explícitamente; migración inicial conservada intacta. Nueva prueba SQL 002 de propiedad, repetición y prohibición de reset.
- Validación: análisis Flutter sin incidencias, formato correcto y **36 pruebas Flutter aprobadas**. Render QA aprobado e inspección de las tres etapas en 390×844; pruebas de login/onboarding en 320×350/escala 2. **4 pruebas PostgreSQL locales (PGlite) aprobadas**, incluida RPC/aislamiento/repetición; 14 archivos SQL analizados sintácticamente. Build web correcto con dry run Wasm; persiste aviso no bloqueante de CupertinoIcons. No se compiló ni instaló este incremento Android.
- Usuario informó haber corregido OAuth en Dokploy y aportó captura de sesión activa. No se realizó ingreso con sus credenciales desde esta sesión ni se accedió al despliegue. Este nuevo SQL aún debe aplicarse en Supabase para probar onboarding remoto; sin despliegues ni acciones GitHub.
- Registrado ADR-004 y actualizado diseño, arquitectura, reglas de entrada en AGENTS, READMEs, guía y configuración. Siguiente paso: aplicar run_all actualizado, completar/omitir con una cuenta, reiniciar/cerrar sesión/reingresar y comprobar que no se repite; repetir con otra cuenta.

## Ilustraciones independientes del onboarding, 7 de octubre de 2026

- Por solicitud del usuario, reemplazados los recortes de baja resolución del tablero por tres PNG independientes derivados del mockup con la herramienta integrada image_gen: dog_waving.png, dog_with_map.png y dog_and_cat.png.
- Assets en apps/mobile/assets/onboarding, 1254×1254 RGBA con transparencia real. Copiados desde las salidas originales sin redimensionar/recomprimir; orejas, patas y colas inspeccionadas. Son reconstrucciones generadas a partir de la referencia, no una ampliación determinista del tablero.
- OnboardingIllustration simplificado a Image.asset con BoxFit.contain y filtrado medio. Eliminada del bundle la copia del tablero usada anteriormente; el original de mockups se conserva. Prompts exactos versionados en assets/onboarding/generation_prompts.json y procedencia/método en su README.
- Configuración de assets y captura QA actualizadas. Resolución con lockfile, formato, análisis sin incidencias y **36 pruebas Flutter aprobadas**; render QA adicional aprobado y las tres pantallas inspeccionadas sobre fondo blanco, incluyendo composición/bordes. No se realizó nuevo build/instalación Android ni cambios SQL, de sesión, despliegue o GitHub.
- Actualizados diseño, ADR-004 y documentación de assets. Para ver la sustitución en el emulador, detener la app y ejecutar nuevamente desde main.dart. El onboarding ya completado por una cuenta continúa sin repetirse, según su persistencia existente.

## Centrado y legibilidad del onboarding, 7 de octubre de 2026

- Comprobado que OnboardingIllustration y pubspec utilizan los tres PNG independientes de image_gen. La captura del usuario parece mostrar el recorte anterior (borde rectangular y gato recortado); no se comprobó qué build está instalado en el emulador.
- Extraído OnboardingPage como componente de presentación: centra el conjunto ilustración/título/descripción en el espacio disponible y permite scroll al aumentar texto o reducir altura. La ilustración sigue completa con BoxFit.contain y alto proporcional al viewport.
- Títulos 32, descripciones 19, acciones 18, indicadores 10 y botón mínimo 56. Marca del onboarding configurable a icono 56/texto 24; corregida la distribución del encabezado para evitar que Flexible+Spacer la reduzcan pese a aumentar tamaños.
- Formato y análisis correctos, 36 pruebas Flutter aprobadas incluyendo pantalla pequeña/texto ampliado, más render QA de las tres páginas. Capturas revisadas. No se instaló ni recompiló un APK desde esta sesión; sin cambios de flujo, SQL, persistencia o despliegue.
- Para cargar los assets actuales en Android, detener completamente la ejecución y volver a iniciar con el perfil local de VS Code. El onboarding completado no se restablece por esta revisión visual.

## Actualización comprobada en el emulador, 7 de octubre de 2026

- Identificada ejecución de VS Code cuyo target es el main.dart del proyecto correcto; dispositivo emulator-5554, Android API 36. Las capturas anteriores del usuario mostraban el diseño/corte anterior, pese a que las fuentes locales ya estaban actualizadas.
- Aumentados título 36, descripción 22, botón 22/alto mínimo 68/ancho mínimo 180, indicadores 16 y Omitir 20. No se modificó el tamaño ni contenido de los PNG. Conservado centrado del conjunto y separadas acciones adaptables en OnboardingActions.
- La prueba con 320×350 y texto al doble detectó desbordamiento del botón grande en una fila estrecha. Corregido mediante apilado de indicadores/acción en ancho reducido o texto ampliado y altura de línea explícita; 36 pruebas finales aprobadas, formato y análisis correctos, render QA aprobado.
- Conexión mediante flutter attach a la app ya en ejecución, con configuración pública local, sin DDS adicional. Hot restart/hot reload completados y primera captura real del emulador inspeccionada: imagen nueva transparente completa, conjunto más abajo/centrado, texto y acción/indicadores grandes. Tras aplicar el ajuste responsive final, el estado visible había cambiado a login con sesión cerrada; esa última captura se conserva como build/ui-preview/login_android.png y no se presenta como prueba visual del onboarding. No se reconstruyó APK ni se desinstaló la app; no se reinició el onboarding persistido ni se pulsó Comenzar/Omitir.
- Al desconectar el cliente adicional flutter attach, la herramienta Flutter 3.35.3 terminó con Bad state: Stream has already been listened to; registrado en flutter_01.log (ignorado). Se comprobó después que el proceso Android y la ejecución original de VS Code seguían activos. No fue un error de análisis/tests de la app.
- Actualizado diseño y evidencia. No hubo SQL, cambios de cuenta, despliegues ni acciones GitHub. Las capturas finales del harness muestran las tres etapas; la comprobación real del emulador se distingue de ese render sustituido. No se forzó acceso al onboarding tras el cambio de sesión.

## Login a escala del onboarding, 7 de octubre de 2026

- Por instrucción del usuario, retirado el botón Apple y todos los avisos informativos de sesión/arranque que ocupaban espacio entre subtítulo y correo. Sesión cerrada e inicio de OAuth ya no se presentan como bloques informativos. Los errores de una operación permanecen después del formulario, con semántica accesible, para permitir corregir/reintentar.
- Login sin appBar fijo: marca y formulario dentro de un bloque centrado en el alto disponible, con scroll al abrir teclado/ampliar texto. Logo 80/texto de marca 32, título 36/subtítulo 22, campos 20 e iconos 24, ingreso 22/alto mínimo 68, Google 20/alto mínimo 64, recuperación/pie 18. No se cambió el flujo de sesión ni onboarding.
- Formato y análisis correctos, **37 pruebas Flutter aprobadas**. Nueva regresión verifica ausencia de Apple/mensaje de salida y presencia de errores debajo del ingreso. Se mantienen pruebas de pantalla pequeña/texto al doble. Render QA adicional aprobado y login 390×844 inspeccionado; no se compiló/instaló ni actualizó la ejecución Android en esta revisión.
- Actualizados diseño, arquitectura, configuración y guía. Sin cambios de backend/SQL ni acciones GitHub. Reiniciar la app desde VS Code para revisar el nuevo login en el emulador.

## Ajuste intermedio del formulario de login, 7 de octubre de 2026

- Conservada la escala de la cabecera aprobada por el usuario. Reducidos campos a 18, ingreso a 20/alto mínimo 60, Google a 18/alto mínimo 58 y recuperación/pie a 16. Mantenidos centrado, scroll, radios y ausencia de Apple/avisos informativos.
- Subtítulo sustituido por “Ingresa a tu cuenta”: la frase anterior procedía del mockup, pero suponía una visita previa. El nuevo texto sirve también para el primer ingreso.
- Formato y análisis correctos, 37 pruebas aprobadas y render QA inspeccionado. Sin cambios de autenticación, onboarding ni backend; actualización en emulador pendiente de reejecución desde VS Code.

## Errores del login en los campos, 7 de octubre de 2026

- Reemplazado el párrafo de error por outline rojo suave y shake horizontal amortiguado en el campo afectado (4 px, 360 ms). Correo inválido, contraseña vacía y correo no confirmado tienen pistas cortas; rechazo genérico marca ambos y muestra una única notificación transitoria corta. Los errores generales del servicio no marcan credenciales como incorrectas.
- LoginViewModel publica LoginFieldIssue e identificador de intento; el formulario consume estado/callbacks y ShakeField se limita a animación visual. Edición limpia la marca; reintento vuelve a sacudir; animaciones desactivadas mantienen feedback estático y semántica accesible. No hay SDK ni reglas de autenticación dentro del widget.
- Separado emailNotConfirmed del rechazo genérico en fuente, fallos de dominio y repositorio, mediante código tipado del SDK sin propagar mensajes externos.
- Formato y análisis correctos; **42 pruebas Flutter aprobadas**: mapping SDK/repositorio de confirmación, precisión de campos, reintentos, limpieza, movimiento y preferencia de animación reducida. Render QA aprobado y access_error.png inspeccionado con repositorio sustituido. No se intentó ingresar con credenciales reales ni se actualizó el emulador en esta revisión.
- Actualizados diseño y arquitectura. Sin cambios SQL, políticas, configuración remota o GitHub. Recargar/reiniciar la ejecución para revisar el nuevo feedback en Android.

## Regla sin SnackBar y outline de error, 7 de octubre de 2026

- Eliminado el SnackBar del login por instrucción del usuario. El rechazo de credenciales permanece en borde/iconos/shake de los campos, sin barra inferior. Los fallos generales mantienen únicamente un mensaje breve en el contexto del formulario.
- Borde danger aumentado a 2.5 px en estados normal de error, enfocado y con pista de validación. Fondo del input conservado en su gris normal; iconos continúan danger. Captura access_error.png inspeccionada sin notificación inferior ni fondo rosado.
- Registrado ADR-005 y actualizados AGENTS, reglas obligatorias, diseño y arquitectura: no usar SnackBar en funcionalidades/componentes ni mediante wrappers; no sustituirlo por una barra/toast equivalente.
- Nueva comprobación automática del código de lib que rechaza referencias al componente y APIs de presentación. Pruebas de campos verifican grosor y fondo conservado. Formato/análisis correctos y **43 pruebas Flutter aprobadas**, más render QA aprobado.
- Sin cambios SQL/remotos ni acciones GitHub; el ajuste requiere recargar/reiniciar la ejecución del emulador. No se compiló ni instaló un APK en esta revisión.

## Ajustes finos de inputs y botones del login, 7 de octubre de 2026

- Ingresar reducido de 20 a 18, Google de 18 a 16 y pie de cuenta de 16 a 14. Padding vertical de ambos inputs aumentado de 18 a 22 (+4 arriba y abajo), conservando el horizontal en 16.
- La validación detectó una discrepancia previa: la prueba existente exigía borde danger 3.5 y el widget usaba 2.5. Conservada la prueba y alineado el componente/documentación a 3.5, sin cambiar el fondo del input ni la regla sin SnackBar.
- Formato/análisis correctos, 43 pruebas finales aprobadas y render QA inspeccionado. Sin cambios de autenticación, onboarding, SQL o remoto; revisión en el emulador pendiente de recarga de la app.

## Cabecera y alineación de Google en login, 7 de octubre de 2026

- Retirado el subtítulo “Ingresa a tu cuenta”; el título “Iniciar sesión” explica la acción sin repetirla. Pie de cuenta aumentado de 14 a 15.
- Icono y texto de Google centrados como conjunto, separados por 8 px. Conservados tamaños de inputs, botones y cabecera.
- Formato y análisis correctos, 43 pruebas Flutter aprobadas y render QA del login inspeccionado. Actualizado DISENO_UI. Sin cambios de autenticación ni backend; la ejecución Android requiere recarga para mostrar estos ajustes.

## Separación de marca y texto danger, 7 de octubre de 2026

- Separación logo/título aumentada de 28 a 40 y título de 36 a 38; el bloque mantiene su centrado y scroll adaptable.
- El texto ingresado en cada input con error adopta el mismo rojo del borde/icono. Al editar y limpiar el error recupera su color normal; no se modifica el fondo ni los placeholders.
- Formato/análisis correctos y 43 pruebas Flutter aprobadas, incluida comprobación de color por campo y recuperación tras edición. Render QA aprobado e inspeccionado; actualizado DISENO_UI. Sin cambios de backend ni actualización del emulador desde esta revisión.

## Entrada escalonada al onboarding, 7 de octubre de 2026

- Añadido componente compartido StaggerReveal/StaggerRevealItem: opacidad y desplazamiento suave de 14 px, secuencia de cinco grupos en 760 ms. Aplicado a cabecera, ilustración, título, descripción y acciones al entrar; no se repite con cambios de estado o etapa.
- Ruta onboarding con fundido de 240 ms. La preferencia de reducir animaciones elimina entrada, fundido y desplazamiento programático de páginas. Sin cambios de acceso Google/correo ni persistencia.
- Formato/análisis correctos, 45 pruebas Flutter aprobadas: nuevos casos verifican desfase, fin, ausencia de repetición, reducción de movimiento y desmontaje; se mantienen navegación y layout pequeño. Render QA aprobado y primera etapa inspeccionada. Actualizado DISENO_UI; suavidad perceptiva del retorno OAuth en Android pendiente de revisión en dispositivo, no se actualizó el emulador ni se hizo login remoto.

## Consulta de cuenta sin spinner central, 7 de octubre de 2026

- Identificado el loader en EntryScreen, durante la consulta de sesión/finalización del onboarding previa al stagger reveal. Sustituido por marca estática con semántica “Preparando tu cuenta”; ruta intermedia sin deslizamiento. Conservados comprobación real, errores, reintento y salida.
- Formato/análisis correctos y 46 pruebas aprobadas. Nueva regresión mantiene una consulta pendiente y verifica marca sin spinner, ausencia de acceso anticipado y entrada al onboarding al resolverla. Render QA aprobado y entry_check.png inspeccionado. Actualizado DISENO_UI; sin login remoto ni actualización del emulador en esta revisión.

## Entrada más pausada, 7 de octubre de 2026

- Stagger reveal ampliado de 760 a 1400 ms, desfase de 70 a 140 ms y duración de cada elemento de 480 a 840 ms. Conservados curva, desplazamiento, accesibilidad y ejecución única.
- Formato/análisis correctos y 46 pruebas aprobadas. Actualizado DISENO_UI. Revisión perceptiva en Android pendiente de reiniciar la app; sin cambios de layout ni backend.

## Reveal de texto por etapa, 7 de octubre de 2026

- Limitado el stagger al título y descripción de cada una de las tres etapas. Mascotas, cabecera, indicadores y acciones quedan fuera. Cada timeline se inicia al activar su página, por botón o swipe, y se conserva para no repetirlo al regresar; duración total 1400 ms.
- La regresión de swipe detectó que el listener iniciaba animateToPage durante el gesto. Corregido para animar solo cambios programáticos aún pendientes.
- Formato/análisis correctos y 47 pruebas aprobadas, incluida activación por botón/deslizamiento, ausencia de wrappers en imágenes/botones y no repetición al volver. Render QA aprobado y segunda etapa inspeccionada. Actualizado DISENO_UI; revisión en emulador pendiente de Hot Restart, sin cambios remotos ni de persistencia.

## Barrido desenfocado de referencia Sader, 7 de octubre de 2026

- Consultado en solo lectura el hook use-stagger-reveal.tsx del proyecto local platform-sader-kormind. Identificada la diferencia: blur progresivo, entrada desde arriba y cubic-bezier(0.22, 1, 0.36, 1), además de opacidad.
- Adaptado en Dart: ImageFiltered con blur inicial 18, desplazamiento -28, misma curva y desfase 90 ms entre título/descripción. Duración individual 1310 ms para mantener los 1400 ms totales solicitados. El filtro se desactiva al finalizar; se conserva una reproducción por etapa y reducción de movimiento. No se modificó el proyecto Sader.
- La captura intermedia detectó que el fundido global superponía la marca anterior sobre la mascota. Retirado ese fundido de ruta: el reveal queda solo en los textos y las mascotas/controles se muestran directamente. Repetidas comprobaciones tras corregirlo.
- Formato/análisis correctos y 47 pruebas aprobadas, con filtro activo durante entrada y desactivado al terminar/con movimiento reducido. Render QA aprobado; captura intermedia onboarding_reveal.png inspeccionada. Actualizado DISENO_UI. No se ejecutó retorno Google real ni se actualizó el emulador; fluidez en Android pendiente de Hot Restart y revisión.

## Parámetros exactos del login de Sader, 7 de octubre de 2026

- Revisados en solo lectura app/page.tsx, app/(auth)/page.tsx y el alias /login de Sader. La raíz usa useStaggerReveal({ count: 5 }) sin overrides: 850 ms por elemento, gap 90, blur 18, offset -28 y curva (0.22, 1, 0.36, 1).
- Alineado el componente Dart a esos valores exactos, retirando la duración individual 1310 ms de la adaptación anterior. Con dos bloques, el onboarding termina el reveal en 940 ms. Se conservan alcance solo textual, activación por página y no repetición.
- Formato/análisis correctos, 47 pruebas aprobadas y render QA aprobado/inspeccionado. La prueba de animación verifica título completo a 850 ms y descripción a 940 ms. Actualizado DISENO_UI. Sin modificar Sader ni ejecutar OAuth/emulador; revisión visual en dispositivo pendiente de Hot Restart.

## Cascada por línea y activación al llegar, 7 de octubre de 2026

- Por elección del usuario, título y descripción se revelan línea por línea mediante StaggerRevealText, conservando etiqueta accesible completa por bloque. El timeline admite el número real de líneas: cuatro o cinco, a 850 ms por línea y gap 90 ms; resto de parámetros iguales al login de Sader. Mascotas y controles siguen fuera del stagger.
- Corregido el inicio anticipado: el reveal espera el ScrollEnd de la página, sin consumirse durante el avance por botón/swipe. Se conserva el estado para no repetirlo al regresar.
- Formato/análisis correctos y 48 pruebas aprobadas. Regresiones verifican líneas consecutivas, semántica, texto oculto durante el desplazamiento y no repetición. Render QA aprobado y segunda etapa final inspeccionada. Actualizado DISENO_UI; percepción de blur/rendimiento en Android aún pendiente de Hot Restart y prueba en dispositivo.

## Inicio del reveal con menos espera, 7 de octubre de 2026

- Anticipado el inicio al último 15 % del desplazamiento de llegada, en lugar de esperar ScrollEnd. Conservados blur, curva, duración, secuencia por línea y reproducción única.
- Formato/análisis correctos y 48 pruebas aprobadas. La regresión verifica texto aún oculto a mitad del avance y animación iniciada antes de terminar el desplazamiento. Actualizado DISENO_UI; percepción en Android pendiente de recarga/reinicio, sin cambios de backend.

## Crear cuenta por correo, 7 de octubre de 2026 — HU-01 / RF-01,34

- Sustituida la acción pendiente del login por /register con nombre, correo, contraseña y confirmación, visibilidad independiente, formulario adaptable y el mismo feedback por campo del login. Sin casilla legal por elección explícita del usuario. Extraída decoración compartida para evitar divergencias; conservado diseño del login.
- Implementados RegistrationRepository, RegisterAccount, ResendRegistrationConfirmation, DTO/fallos de data, adaptador Supabase signup/resend, ViewModel autoDispose y composición en bootstrap/main. Metadata full_name reutiliza el trigger 002; no hay nuevas tablas de credenciales ni cambios de esquema/migración.
- Registro sin sesión muestra Revisa tu correo y reenvío tras 60 segundos, con temporizador liberado al salir. Registro con sesión sigue el observador de Auth/EntryViewModel al onboarding. Router permite registro únicamente en el flujo sin sesión; confirmación usa enlace/callback existente, no OTP simulado.
- Formato/análisis correctos y **60 pruebas aprobadas**. Nuevas pruebas: validación antes de red, contraseña sin trim, duplicados/desmontaje, errores por campo/recuperación, ausencia de casilla legal, espera/reenvío, entrada tras sesión y viewport 320×350 con escala 2. SDK real con HTTP/storage PKCE sustituidos verifica signup/resend, metadata, callback, respuestas con/sin sesión y fallos tipados. Estas pruebas no contactan Supabase real ni envían correo.
- Render QA aprobado; register.png y register_confirmation.png inspeccionados con fuentes reales. Detectada y corregida tipografía de botones que perdía la familia al sobreescribir el estilo. Actualizados arquitectura, diseño, configuración, guía, README de app y database. No se instalaron builds, crearon cuentas remotas, desplegaron SQL ni realizaron acciones GitHub.
- Pendiente de prueba en Android: SMTP/registro habilitado, política de contraseña en servidor, entrega y retorno del enlace con app abierta/cerrada y creación real del perfil. Procedimiento en CONFIGURACION. Recuperación y editor de perfil permanecen pendientes.

## Entrada escalonada de Crear cuenta, 8 de octubre de 2026

- Reutilizado StaggerReveal en toda la pantalla de registro: regreso, marca, título/subtítulo, cuatro campos independientes, pista de contraseña, acción y pie. Once componentes con parámetros de Sader (850 ms/elemento, gap 90, blur 18, offset -28 y curva original); duración total 1750 ms. Retirada transición adicional de ruta para mostrar la cascada desde el inicio.
- Un único timeline se conserva durante edición, teclado, validación y cambios del ViewModel. No se repite al mostrar errores; movimiento reducido muestra todo inmediatamente. Registro/confirmación y persistencia no cambian.
- Formato/análisis correctos y **62 pruebas aprobadas**. Dos regresiones nuevas verifican todos los órdenes, desfase entre campos, ausencia de reinicio con edición/errores, movimiento reducido y desmontaje. Se mantienen pruebas de viewport pequeño/texto ampliado y registro/reenvío.
- Render QA aprobado; register_reveal.png intermedia y register.png final inspeccionadas. Actualizados DISENO_UI y ARQUITECTURA. Sin backend/SQL, cuentas remotas, instalación Android ni acciones GitHub; probar percepción y rendimiento en dispositivo tras Hot Restart.

## Cabecera alineada entre login y registro, 8 de octubre de 2026

- Identificada la diferencia: registro reservaba un AppBar, reducía marca/título y centraba un bloque con otra altura. Extraído AuthPageLayout compartido: marca 80/32, título 38, separación 40 y un único anclaje independiente del contenido. Flecha superpuesta sin desplazar el cuerpo; teclado y pantallas pequeñas conservan scroll.
- Crear cuenta entra con elevación suave desde abajo (8 % del alto, 320 ms; salida 240 ms), sin alterar la posición final de cabecera. Se mantiene el stagger por componente y se desactivan ambas animaciones con movimiento reducido.
- Formato/análisis correctos y 62 pruebas aprobadas. Ampliada regresión de registro para comparar rectángulo de marca y altura del título entre pantallas, además de comprobar entrada vertical. Se mantienen validación, reenvío, flujo de sesión y viewport pequeño/texto ampliado.
- Render QA aprobado; access.png y register.png finales inspeccionados y alineados. Actualizados diseño y arquitectura. No se actualizó el emulador ni se tocó backend/SQL; revisión perceptiva pendiente de Hot Restart.

## Expansión desde Crear cuenta y cierre al origen, 8 de octubre de 2026

- Sustituida elevación vertical por OriginPageTransition compartida: CreateAccountButton mide su rectángulo real respecto al Navigator; superficie blanca redondeada se expande hasta pantalla completa en 560 ms y contrae al origen en 480 ms. Curva simétrica, escala uniforme de pintura con layout estable, recorte redondeado y entrada progresiva del contenido. Sin origen se usa fundido; movimiento reducido presenta la pantalla directamente.
- Corregido el salto de regreso: flecha, Iniciar sesión y retorno desde confirmación hacen pop para completar la animación inversa y conservar el login. go queda solo para navegación sin ruta anterior. Se conserva stagger y geometría final de cabecera. Interacción con formulario bloqueada durante la transición.
- Formato/análisis correctos y 65 pruebas aprobadas. Nuevas pruebas verifican geometría de origen/pantalla, reversa, layout sin deformación y movimiento reducido; integración comprueba ambos cierres, ruta todavía montada durante contracción y mismo origen. Tras ajustar escala uniforme por la revisión visual, se repitieron nueve pruebas pertinentes y render QA, aprobados.
- Capturas register_origin_open.png y register_origin_close.png inspeccionadas; corrección de escala evita cortar horizontalmente marca/textos en estados intermedios. Actualizados DISENO_UI y ARQUITECTURA. Sin cambios de backend ni instalación Android; revisar percepción/rendimiento tras Hot Restart en el emulador.

## Registro sin pie redundante y cierre con X, 8 de octubre de 2026

- Retirados subtítulo y pie ¿Ya tienes una cuenta?/Iniciar sesión del formulario de registro. La X superior sustituye la flecha y conserva pop/contracción hacia el origen. Confirmación de correo mantiene su acción de retorno.
- Ambos títulos aumentados de 38 a 42; separación de marca/título reducida de 40 a 28 dentro de AuthPageLayout compartido. Cabeceras continúan alineadas. Stagger ajustado a nueve componentes y 1570 ms totales, sin huecos de elementos eliminados.
- Formato/análisis correctos y 65 pruebas aprobadas. Regresión actualizada verifica X y retorno de sistema, ausencia de subtítulo/pie, orden completo y cierre inverso; se mantienen geometría, accesibilidad y pantallas pequeñas. Render QA aprobado; login y registro finales inspeccionados.
- Actualizados diseño y arquitectura. Sin backend ni actualización Android; revisar tras Hot Restart.

## Ajuste de títulos, cierre y Google, 8 de octubre de 2026

- X desplazada de 8 a 16 px desde el borde izquierdo del contenedor. Separación marca/título reducida de 28 a 20 y ambos títulos aumentados de 42 a 44, dentro del layout compartido.
- Google reducido de icono 28 a 22 y texto 16 a 15, conservando separación 8 y área táctil del botón. Sin cambios de flujo ni animación.
- Formato/análisis correctos y 65 pruebas aprobadas; render QA aprobado e inspeccionados login/registro finales. Actualizado DISENO_UI. Sin backend ni actualización del emulador; revisar tras recarga/Hot Restart.

## Entrada más rápida y cabeceras a la izquierda, 8 de octubre de 2026

- Expansión de registro reducida de 560 a 320 ms y contracción de 480 a 260 ms, conservando el botón de origen y pop inverso. Logo y títulos de ambos formularios alineados al margen izquierdo del layout compartido.
- Placeholder/texto ingresado reducidos de 18 a 17. Altura de línea conservada en 27 para no reducir el alto de los inputs; paddings, radios, iconos y acciones sin cambios.
- Formato/análisis correctos y 65 pruebas aprobadas. Render QA aprobado; login/registro inspeccionados, campos con mismas dimensiones y cabeceras alineadas. Actualizado DISENO_UI y tiempos de capturas intermedias. Sin backend ni actualización Android; probar tras Hot Restart.

## Títulos reforzados y menos espacio, 8 de octubre de 2026

- Ambos títulos aumentados de 44 a 48, conservando alineación izquierda. Espacio marca/título reducido de 20 a 14 y título/formulario de 32 a 20.
- Texto ingresado y placeholders reducidos de 17 a 16 con altura de línea 27 para conservar el tamaño exterior de campos. Quitado chevron de Ingresar; etiqueta y carga centradas.
- Formato/análisis correctos y 65 pruebas aprobadas. Render QA aprobado; ambos formularios finales inspeccionados. Actualizado DISENO_UI. Sin backend ni cambios de flujo; revisión Android pendiente de recarga/Hot Restart.

## Inputs y acciones con dimensiones iguales, 8 de octubre de 2026

- Registro adopta el padding vertical 22 del login, con la misma decoración, tipografía, fondo y radio. Ingresar adopta las dimensiones de Crear cuenta: padding vertical 18/horizontal 24, radio 24, alto mínimo 60 y texto 18, mediante authPrimaryButtonStyle compartido.
- Formato/análisis correctos y 65 pruebas aprobadas, más render QA. Ampliada la regresión de registro para comparar el tamaño renderizado de sus cuatro campos con el input de login y el botón de registro con Ingresar; siete pruebas de registro repetidas tras añadirla, aprobadas.
- Login/registro finales inspeccionados; actualizado DISENO_UI. Sin cambios de flujo/backend ni actualización Android; revisar tras recarga/Hot Restart.

## Google con icono y botón más pequeños, 8 de octubre de 2026

- Icono reducido de 22 a 20 y alto mínimo del botón de 58 a 56. Padding vertical de 14 a 13 por lado para reducir 2 px en total; texto y alineación conservados.
- Formato/análisis correctos y 65 pruebas aprobadas. Render QA aprobado e inspeccionado login; actualizado DISENO_UI. Sin backend ni actualización del emulador.

## Onboarding sin Omitir y acción de ancho completo, 8 de octubre de 2026

- Retirado Omitir por instrucción del usuario. Finalización únicamente desde Comenzar en la tercera etapa; guardado delegado a método privado del ViewModel. Se conservan RPC, fechas anteriores y reintento tras fallo, sin cambios SQL.
- Conservados tres puntos centrados como guía de progreso, encima de Continuar/Comenzar de ancho completo con flecha derecha. Texto/indicadores mantienen tamaños; PNG y reveal textual no cambian. El pie conserva área segura y permite texto ampliado.
- Formato/análisis correctos y 65 pruebas aprobadas. Regresiones actualizadas para ausencia de Omitir, flecha, finalización/reintento desde última etapa y recorrido completo en viewport pequeño. Render QA aprobado e inspeccionada primera etapa. Actualizados AGENTS, diseño, configuración, guía, README de database y actualización fechada de ADR-004.
- Sin despliegue ni actualización del emulador; revisar la propuesta de puntos sobre botón tras Hot Restart.

## Mascotas más grandes y controles menos redondeados, 8 de octubre de 2026

- Ampliado espacio de ilustraciones: margen horizontal de 24 a 12 y proporción de alto de .62 a .68, límite superior 460. PNG completos con contain, sin modificar assets ni tamaño/márgenes de texto.
- Indicadores reducidos de 16 a 12 (margen 5); radio explícito 26 en Continuar/Comenzar para reducir forma de píldora. Conservados ancho completo, alto, flecha y flujo.
- Formato/análisis correctos y 65 pruebas aprobadas, incluido viewport pequeño/texto ampliado. Render QA aprobado e inspeccionadas primera/tercera etapa. Actualizado DISENO_UI; sin backend ni actualización del emulador, revisar tras recarga.

## Mascota de Revisa tu correo, 8 de octubre de 2026 — S1 / HU-01 / RF-01,34

- Rama `main`, sin cambios locales al iniciar. Generado con image_gen integrado el perrito con sobre/corazón del mockup, usando además la mascota del onboarding como referencia de identidad. PNG RGBA 1254 × 1254 con transparencia, guardado sin recomprimir en `assets/illustrations/dog_with_envelope.png`; prompt exacto y origen documentados junto al asset.
- Sustituido el icono de RegistrationConfirmation por la ilustración de 240 × 240, completa con contain y decorativa para accesibilidad. Asset registrado en pubspec; captura precarga la imagen y verifica confirmación en viewport 320 × 350/texto escala 2.
- Formato correcto, análisis sin incidencias y 65 pruebas aprobadas. Render QA aprobado y capturas de confirmación normal/pequeña inspeccionadas; reenvío y entrada tras sesión cubiertos por pruebas existentes.
- Pendiente revisar en Android tras reiniciar Run/Debug para incluir el asset nuevo. Capturas con repositorios sustituidos; no verifican entrega de correo real. Siguiente paso: revisión en dispositivo y validación remota de HU-01. Sin acciones GitHub, despliegue ni cambios de backend.

## Recuperar contraseña, 8 de octubre de 2026 — S1 / HU-01 / RF-01,34

- Rama `main`, sin commit/acciones GitHub en esta tarea; conservados cambios locales de la mascota de correo. Sustituido el aviso pendiente de ¿Olvidaste tu contraseña? por solicitud real de enlace, confirmación con mascota y reenvío tras 60 segundos. Misma confirmación para correo existente/desconocido; errores de campo, límites y conexión contextuales.
- Módulo con contratos/casos de uso, fuente Supabase, DTO, repositorio, providers, ViewModels autoDispose e inyección bootstrap/main. SDK encapsulado; sin cambios SQL/migraciones ni credenciales adicionales. El callback PKCE passwordRecovery abre Nueva contraseña antes del onboarding/Inicio; actualización validada, éxito visible y cierre local al volver/cancelar. Sin OTP simulado.
- Reutilizados AuthPageLayout, decoración/dimensiones de inputs, authPrimaryButtonStyle, ShakeField, OriginPageTransition y StaggerReveal. Extraído EmailLinkConfirmation compartido con registro; preservada ilustración creada anteriormente. Expansión 320 ms/reversa 260 ms desde enlace; siete elementos de solicitud y nueve de reset. Scroll/texto ampliado/movimiento reducido comprobados.
- Formato correcto, análisis sin incidencias y **84 pruebas aprobadas**. Pruebas nuevas cubren validación sin red, duplicados/desmontaje, cooldown/límites, respuesta tardía frente al callback, dimensiones, reenvío y reversa, prioridad del reset con callback previo/posterior al montaje, bloqueo de navegación, contraseña distinta/confirmación, cierre de sistema, error/recuperación y 320 × 350 a escala 2 con movimiento reducido. SDK real con HTTP/storage PKCE sustituidos verifica recover/callback/update/logout, tokenRefreshed/userUpdated, sesión normal rechazada, enlace vencido, cuenta desconocida y fallos de contraseña/límites tipados.
- Render QA aprobado; inspeccionados solicitud, confirmación, reset, éxito y variantes pequeñas, con fuentes reales. Capturas en build/ui-preview; no acreditan correo entregado ni deep link ejecutado en Android. Actualizados arquitectura, diseño, guía, configuración y README de app.
- Pendiente: SMTP/plantilla Recovery, límites/política del servidor, enlace real en la misma instalación PKCE con app abierta/cerrada, enlace usado/vencido y reingreso con contraseña nueva. No se contactó Auth real, cambió contraseña real, instaló build ni desplegó. Si se reinicia después de consumir el enlace y antes de actualizar contraseña, el propósito adicional no persiste y se requiere nueva solicitud. Siguiente paso: reiniciar Run/Debug y seguir CONFIGURACION para validación Android con cuenta de desarrollo; HU-01 sigue abierta (issue #1).

## Registro y recuperación por OTP, 8 de octubre de 2026 — S1 / HU-01 / RF-01,34

- Rama `main`, conservados cambios de las tareas anteriores; sin commit/acciones GitHub. Por instrucción del usuario, sustituido el flujo principal de enlaces por códigos de seis dígitos en registro y recuperación. Puede leerse el correo en una PC e introducirse el código en la app. Misma mascota/componentes/animaciones, seis casillas, teclado numérico, pegado/autofill, ceros iniciales y retroceso; verificación automática al sexto dígito con acción de reintento.
- VerifyRegistrationCode y VerifyRecoveryCode validan formato antes de red; contratos/fuentes/repositorios/providers incorporan verifyCode. SDK verifyOTP con tipo email para registro y recovery para restablecimiento. Solo respuesta con sesión válida habilita acceso/reset; OTP incorrecto/vencido mantiene formulario, correo y error contextual. Reenvío de código tras 60 segundos, contador mm:ss y limpieza de casillas; verificación/reenvío bloquean operaciones simultáneas. No se generan ni guardan códigos localmente. Se conservan callbacks existentes.
- Fuentes de correo preparadas en supabase/auth/templates/confirm_signup.html y recovery.html con Token, sin enlaces. Procedimiento versionado para Auth autohospedado y longitud seis; no se aplicaron cambios remotos. El usuario informa que el correo actual ya incluye código alternativo de seis dígitos, que la nueva pantalla puede utilizar.
- Formato/análisis correctos y **94 pruebas aprobadas**. Nuevas pruebas: formato sin red; SDK con dos clientes independientes que solicitan/verifican sin compartir almacenamiento PKCE; tipos correctos; códigos incorrectos/vencidos y respuesta sin sesión; entrada/pegado, ceros iniciales, retroceso y reintento; bloqueo de duplicados, permanencia tras fallo y rutas de onboarding/reset solo tras verificación. Suite previa actualizada para OTP y aprobada. Render QA aprobado; revisadas confirmaciones de registro/recuperación y casillas en 320 × 350 con texto escala 2. Captura de reset entra ahora mediante el caso de uso de verificación con repositorio sustituido.
- Actualizados arquitectura, guía, diseño, configuración y README de app/ilustraciones. Sin SQL/migraciones, cuentas/contraseñas reales, envío de correo, instalación Android ni despliegue. Pendiente: aplicar/revisar plantillas cuando proceda y validar lectura en PC → código en teléfono, OTP vencido/usado, reenvío, contraseña nueva y límites reales de Auth. Reiniciar Run/Debug para revisar; seguir CONFIGURACION con cuenta de desarrollo. HU-01 sigue abierta (issue #1).

## Texto breve de confirmación y consulta de caducidad, 8 de octubre de 2026

- Registro/recuperación muestran «Ingresa el código que llegó a {correo}.» con el correo real, sin repetir el email como bloque ni el párrafo largo anterior. Se conserva tipografía de 18 y el flujo OTP/reenvío. Define público opcional EMAIL_OTP_VALIDITY_MINUTES permite añadir duración confirmada; sin él no se imprime una cifra.
- El usuario desconoce la caducidad actual. Consulta pública solo de lectura: health indica Auth v2.189.0 y settings no devuelve el plazo. Código oficial de esa versión: valor por defecto 86400 segundos/24 horas; la duración efectiva puede estar sustituida en Dokploy. No se asumió ese defecto como configuración efectiva ni se modificó el servidor. Comprobación/documentación en CONFIGURACION.
- Formato correcto, análisis sin incidencias y 26 pruebas pertinentes aprobadas (registro, recuperación y OTP), más render QA aprobado. Pendiente confirmar GOTRUE_MAILER_OTP_EXP efectivo y entonces configurar la cifra en minutos. Sin GitHub, despliegue ni envíos reales.

## CoverReveal y stagger al enviar/verificar código, 8 de octubre de 2026

- Rama main; conservados cambios locales, incluida configuración de ejemplo modificada por el usuario. Usuario informa haber aplicado caducidad de 15 minutos; no se consultó ni modificó nuevamente el servidor en esta tarea.
- Añadidos CoverReveal/AuthStageTransition sobre OriginPageTransition compartido. Registro y recuperación expanden la confirmación desde el botón real de envío en 320 ms; envío programático usa cover desde abajo. Formulario anterior conservado durante la expansión, sin interacción/semántica. Nueva contraseña usa cover desde abajo al verificar OTP.
- Línea de tiempo independiente por etapa de confirmación, nueve componentes/1570 ms: cierre, marca, mascota, título, texto, casillas, ayuda, reenvío y retorno. Contador/edición/error/reenvío no repiten efectos; movimiento reducido presenta el destino directamente. Geometría final, OTP y backend sin cambios.
- Formato correcto, análisis sin incidencias y **96 pruebas aprobadas**. Dos regresiones nuevas verifican origen del botón, conservación del correo durante cover, descarte del formulario al finalizar, nueva cascada y ausencia de reinicio con contador/reenvío/error, incluyendo movimiento reducido. Regresiones existentes mantienen registro/navegación/viewport pequeño y flujos OTP. Corregida inicialización del controlador para garantizar desmontaje seguro antes de cualquier transición.
- Render QA aprobado; inspeccionadas capturas intermedias de registro/recuperación/reset y confirmación final. Sin despliegue, SQL, GitHub ni instalación Android. Siguiente paso: Hot Restart y revisión perceptiva/rendimiento en dispositivo; entrega/caducidad real de OTP siguen pendientes de prueba de desarrollo.

## Cover plano, logo persistente y stagger posterior, 8 de octubre de 2026

- Por instrucción del usuario, eliminada la expansión desde el botón en formulario → Revisa tu correo y código → Nueva contraseña. Cover blanco plano de 320 ms limitado al contenido bajo la marca; después comienza el stagger. Sin escala/radios animados ni captura de rectángulos de botones en estas etapas. Apertura original de Crear cuenta conserva su transición independiente.
- AuthPageLayout separa cabecera y contenido animado; AuthStageTransition conserva el anterior durante la cortina y activa el play del nuevo timeline solo al terminar. Recuperación/OTP/reset comparten PasswordRecoveryScreen y cabecera; ResetPasswordScreen delega callbacks externos. Router conserva la página visible durante refresh de push y mantiene bloqueo hacia destinos autenticados antes de terminar recuperación. Logo conserva render/posición entre etapas; contador/error/reenvío no repiten efectos.
- Formato correcto, análisis sin incidencias y **96 pruebas aprobadas**. Regresiones ampliadas: cortina antes de stagger, marca persistente entre solicitud/código/reset, contenido anterior y edición preservados durante cover, navegación y movimiento reducido. Se mantienen fronteras, cierre/sesión, OTP y pantallas pequeñas. Render QA aprobado; capturas intermedias y finales revisadas.
- Actualizados arquitectura y diseño. Conservados cambios locales/configuración del usuario; sin backend/SQL, GitHub ni instalación Android. Siguiente paso: Hot Restart y revisión perceptiva de la secuencia en dispositivo; las pruebas usan repositorios sustituidos, no acreditan OTP/SMTP real.

## Transiciones por etapa y carga con shimmer, 8 de octubre de 2026

- Contraseña actualizada tiene etapa propia: cover plano y luego stagger de título, descripción y retorno, conservando la marca. Login e Inicio incorporan entrada con cover/stagger; registro, recuperación y OTP reutilizan los componentes. La cortina conserva la altura del contenido anterior hasta terminar. Edición, errores, contador y reenvío no repiten la entrada; el gesto continuo del onboarding mantiene su animación existente.
- LoadingShimmer compartido mantiene etiqueta y dimensiones de los botones durante operaciones reales. Aplicado a ingreso, Google, registro, envío/reenvío/verificación de códigos, guardado de contraseña, finalización del onboarding y salida. Sin etiquetas de carga con puntos suspensivos ni spinner en botones; verificación y reenvío identifican su operación por separado. Controles bloqueados durante carga, anuncio semántico y brillo estático con movimiento reducido.
- Regla versionada en ADR-006, AGENTS, arquitectura y diseño. Comprobación automática rechaza etiquetas de presentación que terminan en puntos suspensivos. Formato correcto, análisis sin incidencias y **99 pruebas aprobadas**, incluidas carga/accesibilidad/movimiento reducido y transición de éxito con marca persistente. Render QA aprobado; revisadas pantallas finales y capturas de carga/cortina.
- Conservados cambios locales y configuración del usuario. Sin backend, SQL, GitHub ni instalación Android. Siguiente paso: Hot Restart y revisión perceptiva de animaciones/shimmer en dispositivo. Las capturas y pruebas usan repositorios sustituidos; OTP/SMTP real sigue pendiente de validación.

## Ajuste de Revisa tu correo, 8 de octubre de 2026

- S1 / HU-01 / RF-01,34: mascota ampliada de 240 a 300 px en el componente compartido de registro/recuperación, conservando imagen completa y scroll. Eliminado Volver a iniciar sesión solo de esta etapa; la X mantiene el cierre. Indicación del código y duración en negro #111111, fuente reducida de 18 a 16 e interlineado 1.4. Cover/stagger y operaciones OTP se conservan.
- Formato correcto, análisis sin incidencias y 99 pruebas aprobadas. Actualizada regresión de cierre para usar la X y comprobada ausencia del retorno; render QA aprobado, revisadas confirmaciones normales y reenvío en 320 × 350 con texto escala 2. Diseño actualizado. Sin backend ni instalación Android; siguiente paso: revisar con Hot Restart en dispositivo.

## Barrido desde el inicio y botones atenuados, 8 de octubre de 2026

- Mascota de Revisa tu correo ampliada de 300 a 320 px en registro/recuperación. LoadingShimmer dejaba el controlador en 0.5 estando inactivo, por lo que los botones ya montados empezaban a mitad del barrido; ahora reposo usa 0 y cada carga nueva arranca desde el borde. Reconstrucciones durante la misma carga conservan su progreso; movimiento reducido mantiene brillo estático.
- El componente compartido atenúa el contenido a opacidad 0.72 durante carga, con brillo encima y bloqueo de interacción; al finalizar recupera su apariencia. Aplicado también a Ingresar sin modificar etiquetas ni dimensiones. ADR-006 y diseño actualizados.
- Formato/análisis correctos y 100 pruebas aprobadas. Nueva regresión compara píxeles al inicio, durante el barrido y al iniciar una segunda operación; las existentes verifican opacidad, bloqueo, dimensiones, semántica y movimiento reducido. Render QA y capturas de confirmación/carga revisados. Sin backend ni instalación Android; siguiente paso: Hot Restart y revisión perceptiva en dispositivo.

## Espacio y tonos de confirmación, 8 de octubre de 2026

- Reducida separación debajo de la mascota de 24 a 8 px en Revisa tu correo de registro/recuperación. Indicación y duración recuperan gris #747781; solo el correo usa negro #111111 mediante Text.rich, manteniendo fuente 16, interlineado, texto ampliable y una lectura continua.
- Formato/análisis correctos, 28 pruebas pertinentes aprobadas y render QA aprobado; captura de recuperación revisada. Diseño actualizado. Sin backend ni instalación Android; siguiente paso: revisión en dispositivo tras recarga.

## Presentación de marca al arrancar, 8 de octubre de 2026

- S1 / HU-01: splash nativo Android con fondo inicial #F2F8F5 (sustituido posteriormente por #FFFFFF), mismo PNG 3D de marca y recursos explícitos API 31+ claro/oscuro. StartupReveal desde MaterialApp.router presenta primero icono centrado, desplaza icono a izquierda y revela Entre Huellas por detrás hacia derecha, en 1100 ms; movimiento reducido omite secuencia. Pantalla de espera conserva fondo/marca.
- Destino visual montado al terminar presentación; su cover/stagger empieza entonces. Login usa NoTransitionPage para evitar fundido de plataforma adicional. Capturas verifican título Iniciar sesión durante stagger. Sin cambios de destinos, reglas de sesión ni backend.
- Formato/análisis correctos y 102 pruebas aprobadas. Dos regresiones nuevas verifican desplazamiento/reveal, montaje posterior, orden cover/stagger, movimiento reducido y superficie pequeña/texto ampliado. Render QA aprobado; capturas startup_icon, startup_brand_reveal, startup_brand y access_startup_reveal inspeccionadas. Recursos Android compilados correctamente con AAPT2.
- Build APK intentado dos veces (también con preferIPv4Stack): Gradle falla antes de compilar con java.io.IOException: Unable to establish loopback connection. Sin APK nuevo ni reinstalación; no se afirma validación del splash nativo en dispositivo. Siguiente paso: resolver conexión local de Gradle, recompilar/reinstalar y revisar arranque frío. Cambios nativos requieren recompilación, no Hot Restart. Conservados cambios existentes; sin GitHub ni despliegue.

## Fondo blanco de arranque, 8 de octubre de 2026

- Por instrucción del usuario, sustituido fondo inicial por blanco #FFFFFF en presentación Flutter, espera de cuenta y recurso compartido del splash Android. Animación de marca conservada; diseño actualizado.
- Formato/análisis correctos y recursos Android compilados con AAPT2. Sin APK/reinstalación; bloqueo de Gradle de la tarea anterior sigue pendiente. Fondo nativo requiere recompilar/reinstalar para verse en dispositivo.

## Icono de splash sin recorte por máscara, 8 de octubre de 2026

- Captura del usuario muestra esquinas recortadas en splash Android. El drawable anterior tenía tamaño intrínseco 96 dp sin margen para la máscara del sistema. Añadida variante drawable-v31 con lienzo transparente de 288 dp e icono 96 dp centrado dentro de círculo seguro 192 dp, según dimensiones oficiales Android. Se conserva PNG, fondo blanco, launcher y animación Flutter.
- Recursos compilados correctamente con AAPT2. Nuevo intento APK vuelve a fallar en Gradle con Unable to establish loopback connection, antes de compilar app. No se pudo reinstalar/verificar el recorte en dispositivo; siguiente paso: recompilar/reinstalar al resolver Gradle y revisar arranque frío. Hot Restart no actualiza este recurso nativo. Diseño actualizado; sin backend ni GitHub.

## Margen proporcional del splash Android, 8 de octubre de 2026

- Usuario confirma recorte persistente. Inspeccionado APK instalado en emulator-5554 mediante AAPT2: sí contiene la variante drawable-v31 anterior con capas de 288/96 dp; descartado que fuera solo una instalación antigua. Sustituida por InsetDrawable con 33.3333% por lado: el margen escala con los límites de dibujo del sistema, en lugar de depender de tamaños de capa fijos. PNG, fondo y presentación Flutter se conservan.
- AAPT2 compila todos los recursos correctamente. Build APK vuelve a fallar en conexión loopback de Gradle; no se pudo instalar ni comprobar visualmente la nueva variante. No se considera demostrado el resultado en dispositivo. Siguiente paso: Run completo/recompilación desde el entorno que permite compilar y revisar arranque frío; Hot Restart no cambia recursos Android. Diseño actualizado, sin backend/GitHub.

## Resorte horizontal de marca, 8 de octubre de 2026

- StartupReveal usa easeOutBack para logo y nombre: sobrepasan ligeramente su posición horizontal y regresan, sin desplazamiento vertical. Texto emerge desde detrás del icono mediante máscara móvil; margen de pintura conserva extremos durante rebote. Opacidad usa curva separada limitada a 0–1. Fondo blanco y movimiento reducido se conservan.
- Secuencia verificada: termina presentación de marca, destino se monta con cover, y solo al finalizar cover empieza stagger de Iniciar sesión. Regresión ampliada compara posiciones en sobrepaso/retorno, verifica Y constante y bloqueo del timeline hasta completar cortina.
- Formato/análisis correctos, 102 pruebas aprobadas y render QA aprobado; marca final revisada. Sin nuevo APK/instalación; siguiente paso: Hot Restart para animación Flutter y revisión perceptiva en dispositivo. Corrección nativa del recorte sigue requiriendo recompilar/reinstalar desde entorno con Gradle operativo.

## Regla de oro de UI y UX, 8 de octubre de 2026

- Creada norma obligatoria docs/REGLAS_UI_UX.md por instrucción del usuario. Referencia: Login, Crear cuenta, Recuperar contraseña, Revisa tu correo, Nueva contraseña y Contraseña actualizada aprobados. Incluye identidad, tokens/dimensiones, componentes, orden cover/stagger, resorte horizontal, shimmer/atenuación, feedback, OTP, accesibilidad, criterios verificables y evolución. Revocada dirección antigua de superficies coloreadas/tarjetas como estilo general. DISENO_UI queda como índice de implementación y revisión, sin valores contradictorios; AGENTS, arquitectura, reglas y guía enlazan la norma.
- Retirada UI anterior de Inicio (AppBar/Tu comunidad/aviso futuro). Destino provisional reutiliza layout/marca/título/acción/cover/stagger de referencia y mantiene bienvenida, cierre de sesión real y error contextual. No es diseño definitivo ni añade funcionalidades. Layout y estilo de botón extraídos a core con aliases/wrapper de Auth; ninguna importación de presentación Auth desde Home. Tema base alineado a blanco, negro/gris y botón radio 24/alto mínimo 60/texto 18. Conservados sesión/onboarding/OTP y cambios existentes.
- Formato/análisis correctos, 102 pruebas aprobadas y enlaces de norma comprobados. Render QA aprobado; login y nuevo Inicio normal/320 × 350 con escala 2 revisados, cierre alcanzable por scroll. Suite conserva pruebas de fronteras, acceso, navegación y recuperación. Sin APK/instalación, backend ni GitHub.
- Siguiente paso: usar la norma en todo incremento visual y diseñar Inicio definitivo alrededor de funcionalidades/HU reales. Revisión perceptiva en Android pendiente; corrección de máscara splash sigue requiriendo build/reinstalación desde entorno con Gradle operativo. Validación Auth/SMTP real no se acredita con estos renders.

## Pendiente

- Ejecución inicial Android observada en capturas y emulador detectado. Revisar herramientas/licencias si afectan nuevas compilaciones; build APK desde esta sesión, icono instalado y retorno de Auth aún no verificados. iOS no compilado en Windows.
- Registrar/verificar el retorno exacto en Authentication > URL Configuration > Redirect URLs. La configuración pública de Auth fue consultada en solo lectura: Google y correo activos, Apple inactivo. No se modificó el Dashboard ni se verificaron las credenciales OAuth.
- Probar retorno con app abierta/cerrada y luego correo/OAuth real en S1. No se verificó autenticación ni restauración remota de sesión.
- Completar HU-01 / RF-01,34: validar registro/confirmación y recuperación reales, editor de perfil y gestión de cuenta. Registro, recuperación, correo/Google/salida están implementados localmente; aplicar las migraciones de perfiles/onboarding ya generadas y ejecutar pruebas de permisos entre usuarios. El esquema no se ha desplegado desde esta sesión.
- Revisar identificadores definitivos, firma y requisitos de distribución antes de publicar una app.
- Publicar cambios y ejecutar CI remoto solo cuando la tarea autorice acciones GitHub.

## Siguiente chat

Completar validación Android del chat **00** siguiendo `docs/CONFIGURACION.md`, y continuar con **01 - Acceso y cuenta**, HU-01 / RF-01,34. La base local está preparada; el criterio de salida Android del chat 00 sigue pendiente.

Al iniciar, comprobar Git y herramientas de nuevo y conservar los cambios locales de esta entrega. Usar el prompt de S1 de `docs/GUIA_MVP.md` sin recrear la app.

## Revisión de issues frente al avance, 8 de octubre de 2026

- Consulta de solo lectura en GitHub: 16 issues de historias abiertos, #1–#16. En este repositorio coinciden con HU-01–HU-16; se comprobaron sus títulos y criterios, sin asumir equivalencia general entre HU e issue.
- Rama `main`, commit `b57f05e`, árbol limpio al iniciar. Revisados estado, reglas, arquitectura, guía S1, funcionalidades y fuentes/migraciones existentes. La app contiene auth, onboarding e Inicio provisional; no hay implementaciones de las funcionalidades HU-02–HU-16.
- Recomendación: ningún issue completo tiene evidencia suficiente para pasar a Terminado. HU-01 / RF-01,34 / issue #1 está en curso: acceso, registro/OTP, recuperación, cierre y onboarding implementados; faltan solicitud de baja con registro/consulta de estado y validación integrada Android/Auth, persistencia de sesión y permisos de perfiles entre usuarios. Las migraciones de perfiles/onboarding existen; esta revisión no comprueba su aplicación remota. Editor de perfil y exportación siguen pendientes en la guía S1.
- El issue #1 conserva una tarea obsoleta de ASP.NET Core. Debe alinearse con ADR-001 y Supabase manteniendo sus criterios funcionales. Esta consulta no modificó issues, tablero, comentarios ni otros recursos de GitHub.
- Validación: contraste documental y de código con los criterios publicados. No se ejecutaron pruebas Flutter, build, correos ni SQL; la última evidencia registrada es 102 pruebas locales aprobadas, sin acreditar Auth/SMTP ni RLS remotos.
- Siguiente paso: completar gestión de cuenta de HU-01 y demostrar sus criterios integrados antes de cerrarla; actualizar su descripción técnica cuando una tarea autorice editar GitHub.

## Reestructuración autorizada del backlog, 8 de octubre de 2026

- Por solicitud del usuario, reorganizados los issues de GitHub manteniendo formato de historia de usuario y asignados todos a su identidad verificada `srg-cp`. Conservadas las 16 HU originales y sus criterios: 12 issues originales son agrupadoras; #5, #6, #9 y #13 conservan una entrega cohesiva. Creadas 35 derivadas HU-XX.n en #17–#51: 39 historias ejecutables más 12 agrupadoras, sin contar esfuerzo dos veces.
- Cada derivada incluye Como/quiero/para, HU y RF originales, sprint objetivo, aceptación, dependencias concretas, trabajo técnico, validación y definición de terminado. HU-01 se divide en registro/confirmación #17, acceso correo #18, Google #19, sesión/salida #20, onboarding #21, recuperación #22, perfil #23, solicitud de baja #24 y exportación básica #25, esta última ya prevista en la guía. Identificado avance local sin marcar criterios como acreditados en servicios reales.
- Actualizadas las agrupadoras con listas enlazadas y las historias conservadas con dependencias e integración explícitas. Retiradas referencias obligatorias a ASP.NET Core/workers; Supabase y generación de cartel en Flutter siguen ADR-001 y la guía. No se añadió alcance posterior al MVP ni se repartieron automáticamente los puntos originales. Las relaciones de agrupación se expresan mediante enlaces/listas de issues; no se modificó un tablero ni se establecieron relaciones nativas de sub-issue.
- Añadido docs/BACKLOG_MVP.md con índice GitHub y desglose; actualizadas GUIA_MVP y plantilla de historia. Rama main, commit base b57f05e; conservado cambio previo de ESTADO. Sin cambios en app, SQL, configuración ni despliegue; sin commit/push local.
- Validación remota: 51 issues abiertos, los 51 asignados a srg-cp; lectura de los cuerpos de todos coincide con las versiones esperadas. Comprobación individual de #1, #13, #18, #29, #42 y #51 confirma estado, asignación y enlaces. Preservados todos los criterios originales y comprobadas dependencias de las 39 historias ejecutables sin ciclos. No se cerró ningún issue; sin pruebas/build Flutter por tratarse de planificación y documentación.
- Siguiente paso: demostrar y cerrar las derivadas de HU-01 que tienen implementación local; completar perfil/baja/exportación. Las agrupadoras se cierran solo tras sus derivadas y demo integrada. Confirmar prioridades/estimaciones durante planificación, sin interpretar S1–S6 como plazos comprometidos.

## Revisión académica del backlog, 8 de octubre de 2026

- Por solicitud del usuario de mejorar la calidad para evaluación universitaria, revisada la estructura sin eliminar ni renumerar los issues: 12 originales se titulan explícitamente Épica y 39 entregas se identifican como historias de usuario ejecutables. HU-XX.n es la convención documentada de trazabilidad; no se presume una rúbrica docente específica.
- Conservados todos los criterios originales. Añadidos escenarios específicos de validación a las 39 historias, prioridad heredada como referencia y estimación pendiente por entrega, sin inventar puntos ni prometer sprints. Refinamiento pendiente explícito en #44 (interacciones que afecta bloqueo) y #51 (interfaz/funciones administrativas); no están listas para comprometer implementación mientras esas reglas sigan abiertas.
- Delimitada la exportación básica #25 a JSON UTF-8 con perfil propio y solicitudes/estados de baja propios, descargable o compartible en Android, sin depender de mascotas/casos futuros. Especificación de planificación; no se implementó la exportación ni se amplió a funciones posteriores al MVP.
- Reescrito BACKLOG_MVP con clasificación, trazabilidad y fichas de las 39 historias sincronizadas con los criterios/dependencias/validación actuales. Actualizadas guía y plantilla para distinguir tipo de elemento, prioridad, estimación, refinamiento y definición de terminado.
- Validación: lectura remota de los 51 issues coincide en título/cuerpo con los cambios esperados; 12 épicas y los 51 issues abiertos asignados a srg-cp. Criterios originales preservados; 39 fichas locales comprobadas; git diff --check correcto. Sin cierre de issues, tableros, relaciones nativas de sub-issue, commit/push local, cambios de app/SQL ni pruebas Flutter por ser planificación/documentación.
- Siguiente paso: validar las entregas de acceso implementadas; acordar estimaciones al planificar y concretar reglas de #44/#51 antes de comprometerlas. Si el docente aporta una rúbrica específica, contrastar la presentación con ella sin romper la trazabilidad.

## Archivos individuales y estados de issues, 8 de octubre de 2026

- Por solicitud del usuario, exportados los 51 issues a docs/backlog/NNN-HU-XX[.n].md: un archivo por issue, más README como índice (52 Markdown). Cada ficha conserva íntegro el cuerpo remoto y añade URL, tipo, responsable, snapshot de estado/fecha, motivo y relaciones locales. Se mantuvieron los cambios previos y no se modificó la app, SQL ni configuración.
- Clasificación basada en evidencia, aplicada en GitHub con etiquetas: 7 In Progress (#1 y #17–#22), 5 Ready (#2, #3, #23, #26, #28), 39 Backlog, 0 In Review y 0 Done. Son 6 historias ejecutables en progreso, 3 preparadas y 30 en backlog; las 12 épicas agregan el estado de sus historias y no se cuentan como esfuerzo adicional. Ready significa alcance/contratos disponibles para iniciar, no criterios ya cumplidos; acordar estimación antes de comprometer la entrega.
- Creadas etiquetas status:backlog/ready/in-progress/in-review/done, type:epic/story y needs:refinement. Conservadas etiquetas ajenas a esta clasificación; los 51 issues siguen abiertos y asignados a srg-cp. #44 y #51 tienen refinamiento pendiente. La consulta de PRs no encontró entregas presentadas a revisión; no se marcó Done por implementación o tests locales.
- Limitación comprobada: GitHub GraphQL rechazó consultar Projects por INSUFFICIENT_SCOPES; la credencial existente carece de read:project/project. No se pudieron inspeccionar tableros ni mover sus columnas. Los estados publicados son etiquetas de issues, no valores nativos de Status de un tablero. Se usó la credencial existente sin mostrarla ni guardarla en archivos; no se modificaron sus permisos.
- Validación: 51 issues remotos y 51 fichas locales, exactamente una etiqueta de estado esperada por issue, asignación/tipo correctos, cuerpos locales iguales a GitHub y enlaces relativos existentes. 52 Markdown contando índice, sin incidencias. git diff --check correcto. No se ejecutaron tests/build Flutter por ser documentación y organización de issues; sin commit/push local ni despliegue.
- Siguiente paso: completar evidencia real de #17–#22 y elegir la siguiente historia Ready según sprint. Para mover tarjetas de Projects, habilitar una conexión/credencial con permiso project o equivalente, identificar el tablero y aplicar los estados ya clasificados. Actualizar las fichas/índice al cambiar GitHub: no hay sincronización automática.

## Sincronización del tablero de GitHub Projects, 8 de octubre de 2026

- Usuario informó haber completado la autorización. GitHub CLI encontrado en C:/Program Files/GitHub CLI/gh.exe; sesión activa srg-cp con permiso project, almacenada en keyring. No se extrajo ni guardó el token en archivos.
- Localizado un único proyecto asociado al repositorio: EntreHuellas, proyecto de usuario #3, https://github.com/users/srg-cp/projects/3. Su vista Backlog #1 es un tablero y el campo Status dispone de Backlog, Ready, In progress, In review y Done. Los 51 issues ya estaban añadidos, todos inicialmente en Backlog.
- Actualizado Status de 12 tarjetas: #1 y #17–#22 a In progress; #2, #3, #23, #26 y #28 a Ready. Las otras 39 permanecen en Backlog. No se cambió aceptación, asignación, estimación, tamaño, prioridad, fechas ni estado abierto/cerrado de issues; no se marcó revisión o finalización sin evidencia.
- Validación remota posterior: 51 tarjetas sin paginación pendiente, todas del repositorio, no archivadas, issues abiertos asignados a srg-cp; Status coincide con la etiqueta de cada issue. Resultado: 7 In progress, 5 Ready, 39 Backlog, 0 In review, 0 Done; cero discrepancias.
- Añadidos enlace de tablero y estado nativo verificado a los 51 archivos locales. Actualizadas README de backlog, BACKLOG_MVP y GUIA_MVP para retirar el bloqueo vigente de acceso; el registro anterior se conserva como historia. Los 51 archivos siguen presentes y git diff --check correcto. Sin cambios de app/SQL, pruebas Flutter, commit/push ni despliegue.
- Siguiente paso: completar la validación integrada de #17–#22 y continuar con la siguiente historia Ready según sprint, manteniendo juntos Status de Projects, etiquetas y documentación. No hay sincronización automática.

## Diseño navegable de Inicio, 8 de octubre de 2026

- Usuario aprobó distribución inspirada en su referencia: cápsula flotante liquid glass con Inicio, Explorar, Mis mascotas y Perfil, más botón circular «+» de Reportar. Implementados blur limitado, transparencia, reflejo claro, selección semántica y panel desplazable con los dos tipos de reporte. Inicio presenta tarjeta destacada, acciones y bloque Cerca de ti con blanco/negro/gris; la norma cromática vigente es la del mockup aprobado el 9 de octubre. Registrada composición específica en REGLAS_UI_UX, DISENO_UI y GUIA_MVP.
- Navegación local controlada por HomeViewModel autoDispose; salida real mediante SignOut existente, bloqueo de duplicados, LoadingShimmer y error contextual recuperable. Retirada importación de presentación de Auth desde Home. Conservados router protegido, onboarding por cuenta y acceso. Cabecera fuera del cover/stagger; scroll completo y margen inferior mantienen accesibles contenido y barra con texto ampliado. Paneles respetan movimiento reducido.
- Límite funcional: mascotas, búsqueda/mapa, zonas, alertas y publicación no se implementan en esta tarea de diseño ni se marcan HU como completas. Se identifican explícitamente como pendientes; no se muestran registros simulados ni se afirma una consulta vacía al servidor. Perfil contiene cierre de sesión; el panel Reportar describe opciones sin aceptar envíos ficticios.
- Validación: dart format sin cambios pendientes; flutter analyze --no-pub sin incidencias; flutter test --no-pub, 105 pruebas aprobadas. Tres pruebas nuevas cubren cierre duplicado/error seguro/reintento y navegación/panel en 390 × 844 y 320 × 350 con escala 2 y movimiento reducido. Corregido overflow detectado inicialmente en cabecera ampliada. Harness de render aprobado; revisadas capturas home, home_report, home_small y home_profile_small. Comprobación de dependencias/feedback/carga incluida en suite; git diff --check correcto.
- Sin build APK, instalación, cambios SQL/backend, commit/push ni acciones GitHub. El acabado usa blur/transparencia de Flutter; su fluidez y percepción en Android aún requieren revisión en dispositivo. Renders y repositorios sustituidos no acreditan Auth/servicios remotos.
- Siguiente paso: revisar el diseño mediante Hot Restart en la app y ajustar con feedback del usuario; completar las historias de mascotas/casos/zonas antes de conectar acciones de publicación y búsqueda real.

## Ajuste de Inicio: iconos y glass neutro, 8 de octubre de 2026

- Por corrección explícita del usuario, retiradas todas las etiquetas visibles de la cápsula. Conservados nombres accesibles, tooltip, semántica de botón/selección, destinos y área táctil. Selección carbón con icono blanco; resto gris.
- Contrastados colores con auth_input_decoration y primary_action_button_style reales: #24282A, #111111, #626773, #747781, #F5F5F7 y #E5E5EA. Retirados acentos cromáticos de acciones, selección y cristal; asset original conservado; no establece colores de UI. Icono de alertas usa gris explícito para evitar tintes derivados del tema.
- GlassSurface usa transparencia mayor, blur localizado de 22, doble borde direccional y sombra neutra; el contenido desplazado se percibe difuminado debajo. No se afirma refracción física ni validación de rendimiento en Android. Sin nuevas animaciones, dependencias ni cambios de flujo/negocio.
- Validación: formato correcto, flutter analyze sin incidencias, 105 pruebas aprobadas y render harness aprobado. Revisadas capturas normal, pequeña 320 × 350 con escala 2 y cierre accesible desde Perfil. Actualizadas REGLAS_UI_UX y DISENO_UI. Sin APK/instalación, backend, GitHub ni commit/push.
- Siguiente paso: Hot Restart y revisión perceptiva en dispositivo del contraste, transparencia y movimiento al desplazar el contenido.

## Nueve puntos e indicador deslizante, 8 de octubre de 2026

- Por instrucción del usuario, reemplazado «+» por nueve puntos blancos 3 × 3. Acción circular con fondo sólido #24282A, idéntico al indicador activo y sin glass; conserva panel Reportar y tooltip accesible.
- Cápsula conserva glass. Un único indicador se desplaza de origen a destino en 320 ms con easeInOutCubic; al tocar otra sección durante el recorrido, parte de su posición interpolada. Iconos ajustan contraste según el paso del indicador. Movimiento reducido resuelve selección inmediatamente. Contenido conserva cover/stagger; la animación local no reinicia su timeline por frame.
- Validación: formato sin cambios, flutter analyze sin incidencias, 107 pruebas aprobadas. Dos nuevas pruebas comprueban posición inicial/intermedia/final, retarget sin salto y destino inmediato con movimiento reducido. Harness de render aprobado y revisadas capturas home, home_navigation_slide, home_explore y home_profile_small. git diff --check correcto.
- Actualizadas norma UI, índice de diseño y ADR-006 con el efecto local autorizado. Conservados cambios previos, arquitectura, sesión y alcance funcional; sin backend, APK/instalación, commit/push ni acciones GitHub.
- Siguiente paso: Hot Restart y revisión de movimiento/fluidez en Android, aún no acreditados por renders de pruebas.

## Selección sin destello, 8 de octubre de 2026

- Por última corrección del usuario, eliminados splash y overlay de Material en los destinos de navegación (NoSplash y overlay transparente). Conservados glass de cápsula, indicador carbón deslizante, iconos y semántica de selección.
- Validación: formato correcto, análisis sin incidencias, ocho pruebas de Home/arquitectura aprobadas y harness render aprobado. Captura home_navigation_slide revisada: indicador a mitad de recorrido sin círculo luminoso de pulsación sobre el destino. Sin repetir suite completa por cambio exclusivamente visual; última suite completa previa: 107 aprobadas.
- Actualizadas norma UI e índice de diseño. Sin APK/instalación ni acciones externas. Siguiente paso: Hot Restart y comprobar percepción del cambio en Android; no se acredita revisión en dispositivo.

## Cabecera compacta de Inicio, 8 de octubre de 2026

- Aplicada alternativa propuesta por el usuario: conservar logo original pequeño, retirar «Unidos para volver a casa» y distribuir nombre en «Entre»/«Huellas». Reutilizado BrandWordmark de core con icono 46/texto 22 y alineación izquierda; mantiene semántica de marca y alertas. Conservado trabajo previo.
- Validación: formato correcto, análisis sin incidencias, ocho pruebas Home/arquitectura aprobadas y harness de render aprobado. Revisadas capturas normal y pequeña con texto ampliado; cabecera compacta y navegación accesible. Sin nuevas pruebas estéticas ni suite completa repetida; última completa previa 107 aprobadas.
- Actualizadas norma UI e índice de diseño. Sin APK/instalación, cambios backend o acciones GitHub. Siguiente paso: Hot Restart y revisión visual por el usuario; validación perceptiva en Android pendiente.

## Perfil de cuenta — HU-01.7 / RF-01, issue #23, 8 de octubre de 2026

- Implementada consulta y edición de nombre visible/ciudad desde Perfil. Campos opcionales hasta 120 puntos de código Unicode; trim y vacío a null acorde con restricciones existentes. Guardar confirma solo después de respuesta persistida, bloquea dobles envíos y usa LoadingShimmer; Descarta restaura los datos leídos. Fallos de campo son contextuales y recuperables; fallo de red conserva borrador para reintentar. Cierre de sesión existente permanece disponible.
- Feature profile con dominio (entidad, fallo, contrato, ReadProfile/UpdateProfile), data (DTO, fuente Supabase y repositorio), providers declarativos y AsyncNotifier autoDispose. Bootstrap inyecta implementación y router compone ProfileEditor en Home por parámetro Widget, evitando imports entre sus presentaciones. Decoración de inputs extraída a core con wrapper compatible de Auth. Conservados diseño/navegación/cabecera previos, login/onboarding y separación de capas.
- Fuente selecciona id/display_name/city y actualiza solo display_name/city. Comprueba cuenta antes/después; ViewModel descarta respuesta tardía al cambiar identidad o desmontarse. Error de lectura permite retry explícito y recuperación de stream aun con identidad igual; no simula perfil ausente ni reintenta escrituras automáticamente. Sin cambios de esquema: reutilizados grants/RLS/restricciones 001–009 inmutables, sin migración nueva.
- Validación Flutter: formato correcto, análisis sin incidencias, suite completa 117 aprobadas; ocho pruebas de Perfil repetidas tras el ajuste de recuperación/estilo. Diez pruebas nuevas en total verifican normalización/Unicode, validación antes del servidor, confirmación, fallos/reintentos, duplicados, descarte, identidad, disposición, UI pequeña y contrato HTTP del SDK con mensajes externos seguros. Prueba de dependencias incluida. Harness render aprobado; revisados estados normal/carga/error/guardado/shimmer y 320 × 350 escala 2, campos/acciones alcanzables por scroll.
- Validación de datos: cinco pruebas npm/PGlite aprobadas, incluyendo nuevo 003_profile_edit_permissions.sql y aislamiento 001. Comprueban actualización propia, identidad/fechas/onboarding protegidos, longitudes/valores opcionales Unicode y reintentos. Prueba remota de solo lectura con clave publicable configurada: Auth settings HTTP 200 y perfiles anónimos HTTP 401/code 42501. Esto acredita respuesta remota y denegación anónima, no permisos autenticados entre cuentas ni aplicación completa del esquema.
- Preparada prueba opt-in tool/check_profile_remote_test.dart con dos cuentas confirmadas dedicadas; comprueba persistencia al reingresar con cliente nuevo, aislamiento y columnas protegidas, y restaura valores editables de A. Ejecución sin credenciales de prueba queda omitida explícitamente: no se ha demostrado su resultado remoto. Configuración de ejemplo y procedimiento en CONFIGURACION; archivo local real ignorado por Git. No se solicitan/registran secretos en chat.
- Pendientes materiales: demo con dos cuentas reales, reinicio/restauración de sesión en Android, Auth/SMTP/OAuth y corte de red real. No se compiló/instaló APK, desplegó esquema, editó GitHub ni realizó commit/push. Conservados cambios anteriores en main. Issue #23 no se marca Done; ficha local añade evidencia separada del snapshot remoto. Docs arquitectura/diseño/guía/configuración/base de datos actualizadas; git diff --check correcto.
- Siguiente paso: Hot Restart para nueva inyección, abrir Perfil y comprobar con cuenta autenticada; ejecutar procedimiento remoto con las dos cuentas dedicadas antes de cerrar HU-01.7. Continuar HU-03.1 (issue #28) solo como siguiente incremento autorizado; no se implementaron mascotas/baja/exportación en esta tarea.

## Perfil simplificado y salida danger suave, 8 de octubre de 2026

- Por corrección explícita del usuario, sustituido Tu cuenta por Perfil y retirados Tu información/instrucciones permanentes de opcionalidad/límite. Campos Nombre/Ciudad conservan validación contextual y operaciones existentes. La pantalla tiene una sola jerarquía principal.
- Cerrar sesión conserva su operación y LoadingShimmer, pero usa danger suave: fondo #F9ECEE, texto #B53F48, fuente 14, padding 16/10, mínimo 48 y radio 18. Guardar cambios sigue siendo acción principal carbón. Área táctil y crecimiento con texto ampliado conservados.
- Validación: formato y análisis correctos, 16 pruebas Perfil/Home/arquitectura aprobadas y harness render aprobado. Revisadas capturas normal y pequeña con texto escala 2; salida compacta accesible por scroll. Ajuste exclusivamente visual; no se repiten pruebas SQL ni suite completa. Sin APK/instalación, backend o GitHub.
- Actualizadas reglas UI e índice de diseño. Siguiente paso: Hot Restart y revisión visual del usuario; demo de persistencia/permisos reales de HU-01.7 sigue pendiente.

## Toast superior propio para confirmación, 8 de octubre de 2026

- Por instrucción explícita del usuario, reemplazado texto permanente «Perfil actualizado.» por toast superior propio «Cambios guardados», carbón/blanco, icono de éxito y cierre accesible. No desplaza el formulario; desaparece a los 3 s (6 con accessibleNavigation). Entrada local 180 ms; respeta movimiento reducido y texto ampliado del contexto de origen. Errores permanecen junto al campo/acción.
- ConfirmationToastHost compartido en core solo se dispara en nueva transición a éxito confirmado; no repite por rebuild ni al montar datos previamente guardados. Limpia overlay/timer al editar, desmontar o cambiar identidad. Perfil lo consume después de respuesta persistida, sin cambios en dominio, SQL ni credenciales. Aplicación actual limitada a éxito de Perfil.
- Registrada ADR-007 para sustituir la prohibición general de toast de ADR-005 solo en éxitos superiores propios. Actualizados AGENTS, normas UI/arquitectura, ADR-005 e índice de diseño. Se mantiene prohibición del componente inferior y sus APIs; sin excepción implícita ni paquete externo.
- Validación: formato/análisis correctos, suite completa 119 pruebas aprobadas. Dos pruebas nuevas verifican no duplicación, cierre, nuevo éxito y disposición, con movimiento reducido/escala 2; pruebas de Perfil verifican desaparición automática y conservación de resultado. Harness render aprobado y captura de éxito revisada; añadido profile_toast_small para QA ampliada. Tras ajuste de herencia MediaQuery, repetidas comprobaciones pertinentes.
- Sin APK/instalación, backend ni acciones GitHub. Pendiente percepción/fluidez en Android y criterios remotos de HU-01.7. Siguiente paso: Hot Restart y guardar desde Perfil para revisar el aviso con el usuario.

## Toast con estética iOS, 8 de octubre de 2026

- Por solicitud del usuario, aviso superior cambia de barra carbón a cápsula de ancho ajustado al texto, cristal claro neutro, blur 18, borde blanco/sombra ligera, icono y texto carbón. Retirada X; se cierra al tocar con hint/acción semántica de dismiss. Alto mínimo 48/radio 28, texto ampliable sin truncar.
- Conservados temporizador, ciclo de vida por pantalla, no repetición por rebuild, confirmación solo tras servidor y movimiento reducido. No se añaden datos simulados al producto ni paquetes externos. Estética inspirada en iOS, implementada en Flutter para Android; no se afirma un componente nativo de Apple.
- Validación: formato y análisis correctos, 13 pruebas de toast/Perfil/arquitectura aprobadas y harness render aprobado. Capturas profile_saved y profile_toast_small revisadas; cierre al tocar/disposición y escalado comprobados. Sin repetir suite completa por cambio de composición visual; última completa previa: 119 aprobadas.
- Actualizados ADR-007, regla UI e índice de diseño. Sin APK/instalación, backend ni GitHub. Siguiente paso: Hot Restart y guardar para revisión del usuario en Android; fluidez/percepción de dispositivo pendiente.

## Perfil desde avatar, 8 de octubre de 2026

- Por aprobación del usuario, conservados logo Entre/Huellas y campana; añadido avatar a la derecha como acceso a Perfil. Retirado destino Perfil de la cápsula y enum/HomeViewModel: solo Inicio, Explorar y Mis mascotas, más Reportar separado. Indicador deslizante ajusta tres posiciones y RTL.
- Perfil pasa a ruta anidada protegida /home/profile, abierta mediante OriginPageTransition desde bounds reales del avatar; apertura 320/cierre 260 ms. Después de expansión comienza stagger del contenido. X/Atrás conserva sección/scroll anterior. Editor, confirmación toast y cierre danger conservan operaciones; salida de cuenta ahora pertenece a ProfileExitViewModel autoDispose, sin acoplar Home a sus comandos.
- Foto se lee de avatar_url/picture en metadatos de la cuenta actual, únicamente si URI HTTPS sin credenciales embebidas; fuente/DTO mapean avatarUri a entidad. Avatar muestra foto cuando está disponible, iniciales del nombre persistido si no, e icono neutro ante ausencia/carga/error. No hay imágenes ficticias en producción, cambios SQL ni permisos de Storage. Elegir/subir foto desde galería permanece sin implementar y sin control simulado; este incremento cubre acceso y visualización.
- Validación: formato/análisis correctos, suite completa 121 aprobadas y harness render aprobado. Dos pruebas nuevas comprueban origen geométrico, cierre/regreso a sección previa y protección tras salida, en normal/320 × 350 con texto 2. Ajustadas pruebas de indicador a tres destinos y salida reubicada; SDK comprueba foto HTTPS válida y rechazo de file URL. Revisados home/profile normales/pequeños y fases profile_origin_start/middle; corregida familia de fuente explícita de salida para QA.
- Documentadas nueva entrada autorizada en ADR-006, regla UI, arquitectura, diseño y guía. Sin APK/instalación, backend, acciones GitHub ni commit/push; trabajo previo conservado. Fluidez Android y demo remota HU-01.7 pendientes.
- Siguiente paso: Hot Restart y probar abrir/cerrar Perfil desde avatar en Android. La carga desde galería necesita su incremento de selección, validación, almacenamiento y permisos antes de ofrecerse al usuario.

Revisión adicional de avatar: iniciales tratadas como gráfico decorativo de tamaño estable (ExcludeSemantics y TextScaler.noScaling) para evitar recorte de dos letras con texto ampliado; nombre/campos/títulos mantienen el escalado del usuario. Pruebas de navegación y renders pequeños repetidos tras el ajuste.

## Inicio sin lema, 8 de octubre de 2026

- Por solicitud del usuario, retirados «Cada huella cuenta» y «Ayudemos a que vuelvan a casa» con su espaciado del Home. Conservados logo/campana/avatar, tarjeta existente, acciones y Cerca de ti. Ajustados órdenes/count de stagger a tres bloques reales (dos en secciones secundarias); onboarding intacto.
- Validación: formato/análisis correctos, ocho pruebas Home/arquitectura aprobadas y harness render aprobado. Captura normal revisada: contenido comienza directamente bajo cabecera, con más espacio visible para acciones/casos. Sin tests nuevos para cambios de texto ni suite completa repetida.
- Normas UI/diseño actualizadas. Sin APK/instalación, backend o GitHub. Siguiente paso: Hot Restart y revisión visual por el usuario.

## Foto privada y correo visible en Perfil, 8 de octubre de 2026

- Por solicitud explícita del usuario, incorporados correo de Auth seleccionable de solo lectura y selección de foto desde galería, mediante avatar/cámara o Añadir/Cambiar foto. Nombre y ciudad siguen siendo los únicos campos editables; no se envía el correo en sus actualizaciones. Home recibe el avatar confirmado sin perder borradores del formulario.
- Flujo separado por capas: contrato/repositorio y caso de uso de foto, fuentes de galería/Storage, ViewModel autoDispose y editor. image_picker añadido; image/shared_preferences declarados directos. Procesamiento nativo fuera del hilo UI: orientación, recorte 512 × 512 y JPEG nuevo sin EXIF/GPS. Cancelación sin subida, duplicados bloqueados, error contextual/reintento y toast solo tras lectura firmada confirmada. Recuperación Android vinculada a cuenta con confirmación explícita, sin subida automática. Mantención temporal del ViewModel solo durante operación activa, liberada en finally; cierre de editor no pierde actualización confirmada de cabecera ni recrea toast.
- Bucket privado y ruta estable por propietario en fuentes SQL 010–011, plan 003 y migración generada 20261008000300_profile_avatars. Límites de tamaño/MIME y guardas RLS restrictivas frente a políticas permisivas ajenas. Generador run_all actualizado y salida regenerada; SQL aplicado anterior intacto. Sin columnas nuevas en profiles ni URL pública.
- Validación: formato, análisis sin incidencias y suite completa de 130 pruebas Flutter aprobadas; seis pruebas SQL aprobadas, incluyendo repetición/aislamiento de avatares. Contrato HTTP de upload multipart/URL firmada, fallo de confirmación, reintento/cancelación, recuperación por cuenta, cambio de identidad, cierre durante subida y limpieza EXIF comprobados localmente. Harness render aprobado y vistas normal/pequeña con texto 2 revisadas. XML de permiso de galería iOS incluido; sin build iOS.
- Límites materiales: migración nueva NO aplicada en Supabase, sin conexión administrativa disponible. Subida/lectura real y demo entre cuentas en Android pendientes. Intento flutter build apk --debug falló antes de compilar por Gradle «Unable to establish loopback connection»; no APK ni instalación acreditados. Un fallo tras escritura remota no garantiza reversión; mensaje indica que no se pudo confirmar y permite reintentar el mismo objeto.
- Actualizados ADR-008, configuración, arquitectura, reglas UI/diseño, guía y trazabilidad HU-01.7; no cerrar issue 23 sin demo remota. Sin despliegue, commit/push ni acciones GitHub. Siguiente paso: aplicar migración en Supabase de desarrollo según CONFIGURACION y detener/recompilar la app en entorno con Gradle funcional; Hot Restart no instala el selector nativo.

## Corrección del patch de Storage administrado, 8 de octubre de 2026

- Usuario reporta ERROR 42501 must be owner of table objects al ejecutar el avatar y solicita carpeta patchs. Causa identificada: fuente 011 incluía ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY, operación innecesaria sobre tabla administrada por Supabase. Corregido en nueva fuente 012, validando RLS existente sin alterar tabla/propietario ni elevar roles. Fuente 011 y migración 003 conservadas como historial.
- Plan 004 genera migración correctiva y Build-AvatarPatch produce database/patchs/004_patch_profile_avatars.sql como salida derivada, sin copias editables independientes. Incluye bucket y todas las políticas para permitir activación tras transacción fallida. Build-RunAll actualizado para usar 010/012. Configuración y README indican ejecutar archivo completo, sin selección parcial (la captura mostraba Run selected).
- Validación: siete pruebas SQL locales aprobadas, incluida aplicación/repetición del patch, permisos entre cuentas y aborto cuando RLS está deshabilitado. Sin cambios Flutter ni repetición de su suite. No aplicada remotamente; usuario debe ejecutar patch corregido en SQL Editor con rol postgres y comunicar resultado. Sin GitHub/deploy/commit.

## Perfil sin acción de foto duplicada, 8 de octubre de 2026

- Por corrección explícita del usuario, retirados Añadir/Cambiar foto y texto de error bajo avatar. Tocar avatar abre galería; tras fallo con bytes retenidos reintenta la misma foto. Avatar conserva distintivo de cámara y etiqueta semántica, con LoadingShimmer durante trabajo real y bloqueo de dobles envíos. Confirmación excepcional de selección Android recuperada permanece explícita y no aparece en uso habitual; conserva su estado también ante fallo.
- El componente toast superior compartido admite icono de error danger suave para fallos de foto, manteniendo estética, duración y limpieza; éxito conserva check y requiere confirmación remota. Error no ocupa espacio en formulario. Host ligado a identidad y operación evita repetición por rebuild y avisos al cambiar cuenta/desmontar.
- Registrada ADR-009 por autorización explícita para ampliar ADR-005/007 únicamente a errores de foto. Actualizadas normas UI/arquitectura, AGENTS, índice de diseño y ADR-008. Sin cambio de Storage ni SQL.
- Validación: formato y análisis sin incidencias, 13 pruebas pertinentes de foto/widget/toast/arquitectura aprobadas, harness render aprobado. Revisados profile/profile_small con texto ampliado y nueva captura profile_photo_error; probado reintento desde avatar, expiración del error fuera del layout y éxito tras respuesta. No se repite suite completa ni SQL sin cambios de contrato. Sin build/instalación ni validación remota nueva; activación de Storage continúa pendiente de resultado del usuario.
- Siguiente paso: Hot Restart y revisar avatar/toast en Android. No hay commit/push ni acciones GitHub.

## Diagnóstico de selector que no abre, 8 de octubre de 2026

- Usuario reporta que no llega a seleccionar foto. Comprobado emulador emulator-5554 por ADB y APK instalado real: análisis de classes*.dex no encuentra Lio/flutter/plugins/imagepicker/ImagePickerPlugin;. El registrante generado del proyecto sí declara el plugin, pero el binario instalado no lo contiene. Por tanto no se acredita un problema de permisos de Supabase: selector nativo ausente en esa instalación. Logcat reciente no proporcionó excepción de plugin; no se afirma un código de excepción capturado.
- Intento nuevo flutter build apk --debug --dart-define-from-file=config/supabase.local.json vuelve a fallar por Unable to establish loopback connection. Gradle help --stacktrace --no-daemon reproduce fallo antes de compilar, en PipeImpl/UnixDomainSockets.connect0 con Invalid argument: connect. No se modifica firewall/roles/configuración global ni se instala APK viejo. Diagnóstico no instala ni desinstala la app y conserva sesión/datos.
- Se corrige recomendación previa: Hot Restart es suficiente para los últimos cambios de composición, pero nunca para añadir image_picker al binario anterior. Detener ejecución Flutter y lanzar flutter run desde terminal externa/IDE que permita compilar Gradle. No basta cerrar/reabrir el APK existente. Android gallery no requiere permisos adicionales de almacenamiento según documentación oficial image_picker; manifest usa singleTop compatible.
- Sin cambios de código/SQL ni tests repetidos. Registro de Storage sigue pendiente de resultado remoto; selector y upload son fases distintas. Siguiente paso: nueva compilación/instalación desde entorno funcional y comprobar apertura de galería antes de evaluar Storage.

## Mis mascotas y actualización de GitHub Projects, 9 de octubre de 2026

- Autorizado por usuario: desarrollar registro, consulta y edición de mascotas propias y actualizar estados del Project según avance real. Trabajo en codex/pets-registration, conservando cambios locales previos, sin commit/push/PR. HU-03.1 / RF-03 / issue #28 y parte de metadatos HU-03.2 / #29; fotos de mascotas siguen pendientes de HU-04, sin controles simulados.
- Home recibe PetsSection por composición desde router; lista real con carga/error/reintento y vacío solo tras consulta satisfactoria. Rutas privadas de registro, ficha y edición. Nombre/especie obligatorios; sexo/edad aproximada en meses/rasgos admiten desconocidos. Formulario y ficha reutilizan paleta neutra, inputs, acción principal, LoadingShimmer, ShakeField y cover/stagger con cabecera persistente. Errores contextuales y confirmación de servidor mediante toast existente, ligada al dueño. Texto ampliado y scroll conservados.
- Feature pets respeta domain/use_cases/repositories, data/data_sources/models/repositories y presentation/state/view_models/screens/widgets. Bootstrap/main inyectan repositorio. Generaciones por cuenta y keepAlive limitado a escritura protegen resultados tardíos; error conserva borrador. Ficha actual después de conflicto invalida caché y abre consulta sin otra edición anidada; los cambios pendientes se conservan en el editor. Prueba de caché previa comprueba lectura de nueva versión sin perder borrador.
- SQL privado public.pets y RPC create_pet/update_pet con validación, auth.uid(), search_path vacío y permisos restringidos. Clientes solo consultan filas propias; sin escrituras directas ni eliminación. UUID por borrador/deduplicación de creación; bloqueo de fila/versión esperada y reconocimiento de reintento idéntico sin segunda modificación. Fuentes 013–018, plan 005, migración 20261008000500_pets y patch manual generado database/patchs/005_patch_pets.sql. run_all regenerado por script y comprobada igualdad de migraciones, sin reescribir historial previo.
- Validación: formato y análisis sin incidencias; suite completa de 140 pruebas Flutter aprobada. Tras ajustes finales de contraste/fuentes y consulta de conflicto, 10 pruebas pertinentes de mascotas/navegación/arquitectura aprobadas y prueba de caché ampliada aprobada. Ocho pruebas SQL locales aprobadas, incluyendo roles A/B/anónimo, restricciones Unicode, opcionales, reintento, timestamp/versión, edición concurrente y repetición del patch. Contrato HTTP del SDK probado (proyección propia, RPC solo campos permitidos y fallo seguro). Harness general aprobado y capturas específicas con fuentes reales de vacío/formulario/selección/guardando/ficha/error/listado, normal y 320x350 con texto 2, revisadas. Fallos intermitentes de memoria del runner durante primeras ejecuciones se resolvieron al ejecutar pruebas secuencialmente; no se alteraron procesos ajenos ni configuración global.
- GitHub, autorizado en esta tarea: Project EntreHuellas — Backlog / users/srg-cp/projects/3 y etiquetas sincronizados y releídos. #23 Perfil, #3 épica Mascotas, #28 registro/consulta y #29 edición parcial -> In progress. #4 épica Fotos y #30 carga de fotos -> Ready, por contrato de ficha disponible localmente. Los demás estados conservados. Totales verificados: 36 Backlog, 4 Ready, 11 In progress, 0 In review/Done; 51 issues abiertos. Sin comentarios, cierre de issues ni cambios de criterios remotos. Instantánea local actualizada (seis archivos e índice); no marcar Done por implementación local sin evidencia integrada.
- Documentados ADR-010, arquitectura, guía, UI/diseño, configuración y database/patchs. Límites: patch NO aplicado remotamente, sin nueva compilación/instalación Android ni demo de persistencia reiniciada/RLS en Supabase. Se conserva bloqueo Java/Gradle y diagnóstico del APK antiguo sin selector de Perfil. Pruebas locales no acreditan servicios remotos; #29 tampoco se cierra sin fotos.
- Siguiente paso: ejecutar COMPLETO 005_patch_pets.sql en Supabase de desarrollo según CONFIGURACION, reiniciar ejecución Flutter con configuración local y probar A registra/edita/reinicia, B no accede; después implementar HU-04.1. No ejecutar el patch antiguo 003 de Storage.

## Selector propio para Especie y Sexo, 9 de octubre de 2026

- Por solicitud del usuario, retirado DropdownButtonFormField de PetEditorScreen y sustituido por AppSelectField compartido. Campo reutiliza decoración/radio/padding/tipografía de los inputs; flecha redondeada, foco/error existentes, apertura única y deshabilitación durante guardado. El helper compartido admite hint ausente para que el selector pinte el valor una sola vez, sin duplicación.
- Panel inferior blanco sin tinte/elevación, radio 28, cabecera persistente con cierre y opciones neutras/radio 18; elección activa carbón/check blanco. Cuerpo con cover/stagger, scroll, escala de texto heredada, movimiento reducido y áreas táctiles adaptables. Cerrar teclado antes de abrir; Semantics de botón/acción y selección, iconos decorativos. Opciones no incluyen datos ficticios: enums reales y No lo sé.
- AppSelectOption envuelve la elección nullable: cancelar no limpia Sexo, escoger No lo sé sí lo cambia a desconocido. Callback al ViewModel solamente tras elección y con widget vigente; sin cambios de dominio, SDK o backend. Estado local de apertura/foco no reinicia entrada de formulario.
- Validación: formato y análisis sin incidencias; 15 pruebas pertinentes de selector/mascotas/Perfil/arquitectura aprobadas, incluidos cancelar sin cambio, elegir null, bloqueo al deshabilitar y navegación/guardado normal/pequeña con texto 2. Renders con fuentes reales de formulario/panel/opción seleccionada revisados en normal y 320x350; variante seleccionada añade dos ejecuciones de navegación aprobadas. Sin repetir SQL ni suite completa: último total completo previo 140. Sin compilación/instalación nueva ni fluidez Android acreditada.
- Actualizadas REGLAS_UI_UX y DISENO_UI. No se amplía alcance ni se cambian estados GitHub en esta corrección visual. Siguiente paso: Hot Restart y revisar Especie/Sexo en el dispositivo; no hay plugin nativo nuevo para este selector.

## Carga de contenido mediante skeleton, 9 de octubre de 2026

- Usuario rechaza el texto visible Cargando mascotas y cualquier indicador circular central. Sustituido por PetSkeleton en listado/ficha/editor: formas neutras que anticipan el contenido con LoadingShimmer compartido, sin registros/nombres simulados ni demoras artificiales. SkeletonFormFields en core comparte placeholders de campos/botón entre mascotas y Perfil; retirado también Cargando tu perfil visible. Solo labels accesibles describen la carga.
- En refresh explícito con datos de la misma cuenta se conserva listado/ficha y se superpone línea fina de 2 píxeles, sin cambiar posiciones. PetRefreshProgress pausa la animación con movimiento reducido; skeleton respeta el comportamiento estático del shimmer existente. Cambio de cuenta/dependencia oculta datos anteriores; error sigue con reintento y vacío solo tras consulta exitosa. No se modifica dominio/SDK/persistencia.
- Registrada ADR-011, actualizados AGENTS, normas UI/diseño y enlace desde ADR-006. Comprobación automática nueva rechaza Text de carga directo/ternario simple e indicadores circulares, manteniendo labels de accesibilidad. Se conserva regla de etiquetas fijas y shimmer real en botones.
- Validación: formato/análisis sin incidencias. 19 pruebas pertinentes de carga/mascotas/Perfil/navegación/arquitectura aprobadas y una prueba adicional de Perfil pendiente con texto 2/movimiento reducido aprobada (20 en total). Se comprueba skeleton -> error -> reintento -> vacío confirmado, retención durante refresh y máscara al cambiar identidad, sin texto visible ni spinner. Capturas normal/pequeña de mascotas_loading/detail_loading/editor_loading y harness general aprobados; revisados placeholders de listado/ficha y Perfil con fuentes reales. Corregidos harnesses para mantener consulta pendiente y avanzar frames acotados, sin pumpAndSettle sobre shimmer indefinido; no afecta runtime de producto.
- Sin repetir suite completa ni SQL porque no cambian contratos de datos; sin build/instalación/validación remota nuevos. No hay acciones GitHub, despliegue o commit. Fluidez/percepción Android pendiente de revisión del usuario. Siguiente paso: Hot Restart y comprobar cargas iniciales/refresco con conexión lenta; activación SQL de mascotas sigue según CONFIGURACION.

## Ficha ampliada y fotos privadas — 9 de octubre de 2026

- Solicitud actual: retorno superior, fotos de mascota, tipo concreto en Otra especie y tamaño horizontal. PetScreenShell retira centrado vertical y fija retorno bajo SafeArea fuera de scroll/reveals; contenido alineado arriba. Tipo requerido 1–60 caracteres para other, descartado en perro/gato; tamaño opcional Pequeño/Mediano/Grande en chips horizontales neutros. Ficha/listado muestran detalle/tamaño reales.
- Galería privada completa en registro/edición: hasta tres imágenes, selección/cancelación/preview/retirada, ficha con fotos y primera confirmada como portada. Cliente prepara JPEG máximo1280 conservando proporción y eliminando EXIF/GPS; original nunca público. Fuente nativa encapsulada, marcador cuenta/mascota para recuperación Android como borrador, sin auto-upload; Perfil no consume lostData sin su marcador. Photos ViewModel autoDispose con guardas de identidad/generación y keepAlive acotado.
- Guardado confirma mascota antes de subir fotos; error conserva bytes/UUID de fotos pendientes y mascota ya confirmada, sin segunda creación ni falso toast. Reservas incompletas visibles/retirables; consulta recupera confirmación de archivos completos. No se implementa cola offline persistente ni cámara. Estado del listado se invalida al confirmar metadatos y al retirar fotos.
- Fuentes SQL nuevas019–025, plan006, migración20261009000600_pet_gallery y patch generado database/patchs/006_patch_pet_gallery.sql. RPC v2 para tipo/tamaño con versiones/reintento y permisos anteriores revocados; fotos privadas mediante reserva/publish/remove con dueño auth.uid(), límite3, bucket JPEG2MiB y guardas restrictivas Storage. Sin ALTER de storage.objects ni cambios de SQL previo. Regeneración de006 aún no aplicada ajusta únicamente trazabilidad del encabezado; generador conserva contenido idéntico de los planes anteriores.
- Validación: suite completa Flutter de 152 pruebas aprobada, incluida arquitectura, normalización/EXIF, recuperación simulada, guardado parcial/reintento estable/capacidad/cancelación/cambio de cuenta, contrato HTTP Storage/RPC y navegación normal/320x350 texto 2. Capturas con fuentes reales revisadas: formulario, tipo/tamaño, ficha y cargas. Nueve pruebas PostgreSQL locales finales aprobadas, incluido caso explícito de política permisiva ajena. Tras guardas finales de fuentes, 18 pruebas Flutter pertinentes aprobadas. Formato final y flutter analyze sin incidencias; siete pruebas de foto de Perfil aprobadas tras el ajuste de recuperación. Regeneración SQL repetida comprueba igualdad de migraciones; git diff --check sin errores de whitespace.
- ADR-012, guía, arquitectura, diseño, configuración, README datos y avance local de #30 actualizados. GitHub no modificado, sin commit/push/PR/deploy; instantánea previa del Project conservada. HU-04.1 sigue parcial: sanitización/miniaturas públicas en servidor y demo Android/Storage pendientes. MIME/size de metadata no demuestra bytes seguros de cliente malicioso; originales privados por diseño.
- Siguiente paso: aplicar TODO patch006 después de005 en Supabase de desarrollo y ejecutar app actualizada. No aplicado remotamente aquí; no nueva compilación/instalación Android ni apertura real de galería acreditadas. Bloqueo Java/Gradle y APK previo sin plugin permanecen hasta compilar desde entorno funcional. Demo con dos cuentas, reinicio real y peticiones directas necesaria antes de cerrar #28/#29/#30.

## Diagnóstico de símbolos de fotos en el editor — 9 de octubre de 2026

- Captura del usuario muestra petPhotoRepositoryProvider y AppBootstrap.petPhotoRepository como indefinidos en main.dart. Releídos archivos actuales en codex/pets-registration: provider declarado/importado, propiedad requerida declarada e inicializada tanto con Supabase como sin configuración. flutter analyze --no-pub ejecutado de nuevo: sin incidencias. No se reproduce el error en archivos guardados ni se modifica inyección/SQL.
- Diagnóstico del editor probablemente desactualizado o con buffers antiguos; su estado interno no se ha inspeccionado. Siguiente paso: recargar los archivos modificados y usar Dart: Restart Analysis Server en el IDE, conservando ediciones propias sin guardar. No se ejecuta build ni se repiten pruebas de funcionalidad sin cambios de código.

## Paleta móvil alineada con el mockup, 9 de octubre de 2026

- Por instrucción explícita del usuario, la referencia cromática es mockups/Entre Huellas_ personajes 3D premium.png: #FFFFFF, #111111, #F5F5F7, #6E6E73 y #E5E5EA. REGLAS_UI_UX y DISENO_UI actualizados; retiradas asociaciones anteriores entre colores de marca y paleta de UI. El rojo contextual de error conserva ADR-005.
- AppTheme sustituye la generación por semilla por un ColorScheme.light con roles neutros explícitos, incluidos contenedores, colores fijos y superficies. Eliminados tokens cromáticos heredados; acciones, texto secundario y foco de acceso/Inicio/Perfil/mascotas alineados con el mockup. PetSizeSelector reutiliza AppColors y desactiva el tinte Material que afectaba al tamaño seleccionado.
- Validación: dart format lib y del harness; flutter analyze --no-pub sin incidencias; suite completa secuencial, 154 pruebas aprobadas. Harness de mascotas normal/pequeño con CAPTURE_PETS: 2 pruebas aprobadas; harness general de capturas: 1 prueba aprobada. Capturas de tamaño al registrar/editar ampliadas y revisadas, incluyendo 320x350 con texto a escala 2; selección activa neutra y controles desplazables. Revisadas también superficies de Inicio, acceso y Perfil. No se añadieron pruebas que repitan constantes estéticas.
- Conservados cambios locales previos en codex/pets-registration. Sin cambios de backend, commit, publicación ni instalación Android. Capturas con fixtures no acreditan dispositivo real; los assets de marca e ilustración conservan sus archivos originales y no definen colores de controles.
- Siguiente paso: Hot Restart en la ejecución Flutter para aplicar el tema y comprobar el selector de tamaño en Android. La compilación/instalación nativa pendiente del incremento previo sigue fuera de esta corrección cromática.

## Componentes con etiqueta interior — 9 de octubre de 2026

- Solicitud explícita: campos de texto y selección con etiqueta dentro del marco, según referencias Nombre/Descripción vacíos y con texto; icono izquierdo opcional. Creado AppFieldSurface compartido y AppTextField de core; AppSelectField adopta el mismo marco. Etiqueta persistente arriba, contenido debajo, sin label externo ni interrupción del borde. Paleta clara del mockup conservada.
- Integrados en registro/edición de mascotas y Perfil. Descripción/rasgos multilínea; campos opcionales siguen admitiendo vacío. Correo conserva selección y solo lectura. Tamaño/fotos mantienen sus controles propios. AppTextField conserva teclado, capitalización, autofill, callback de envío, controller recibido y foco con disposición propia. Error contextual y ShakeField, deshabilitación y acciones del ViewModel conservados; sin cambios de dominio, SQL o persistencia. SkeletonFormFields adapta geometría a etiqueta interior.
- REGLAS_UI_UX y DISENO_UI registran la dirección autorizada y los componentes. Alcance de integración: mascotas/Perfil; acceso conserva sus inputs actuales. No se amplía el MVP.
- Validación final: formato de archivos modificados y flutter analyze --no-pub sin incidencias. Suite completa secuencial: 156 pruebas aprobadas. Dos pruebas nuevas verifican escritura, etiqueta accesible, multilinea, selección sin icono, limpieza externa, error, bloqueo, disposición y texto ampliado. Harness CAPTURE_FIELDS: 2 pruebas aprobadas; navegación CAPTURE_PETS: 2 aprobadas; harness general: 1 aprobado. Capturas vacío/contenido/error/selección, mascotas y Perfil revisadas en normal y 320x350 con texto a escala 2. El primer harness dejó un SemanticsHandle activo; corregida su disposición y repetida la suite completa con éxito.
- Conservado trabajo local previo en codex/pets-registration. Sin commit, GitHub, despliegue ni instalación Android. Capturas usan fixtures y no acreditan teclado/fluidez en dispositivo real. Siguiente paso: Hot Restart y comprobar los nuevos campos al registrar/editar mascota y Perfil en Android.

## Skeleton sustituido sin repetir entrada — 9 de octubre de 2026

- Corrección solicitada por el usuario: datos reales después del skeleton no deben volver a ejecutar stagger. PetScreenShell conserva una etapa constante para cover inicial y ContentReveal mantiene/completa el timeline al resolver la carga, sin nueva cortina ni stagger. Aplicado a ficha y edición de mascotas y entrada de Perfil. PetsSection evita el stagger heredado en datos/vacío/error después de observar skeleton. Entrada inicial de contenido disponible, navegación real, cabeceras y movimiento reducido conservados.
- Una respuesta rápida completa el stagger al sustituir skeleton; la cortina inicial que ya estuviera en curso termina sin reiniciarse. Reintentos/refresh/cambio de cuenta no recrean entradas ni exponen información previa. Sin demoras artificiales, cambios de repositorios/ViewModels, backend o persistencia.
- ADR-006/011 y normas UI/diseño actualizados para distinguir estado de consulta de etapa de navegación. Trabajo local conservado en codex/pets-registration, sin commit/GitHub/deploy.
- Validación: formato de archivos modificados; flutter analyze --no-pub sin incidencias; 23 pruebas pertinentes aprobadas (8 nuevas para respuestas rápidas/lentas a datos/vacío/error, interacción inmediata, reintento y entrada de contenido disponible con/sin movimiento reducido; además stagger, carga, navegación y arquitectura). Harness CAPTURE_PETS: 2 pruebas aprobadas; capturas normal/pequeña con texto 2 regeneradas y revisadas. Comprobaciones temporales verifican opacity completa, ausencia de blur y ausencia de reinicio del cover antes de esperar a que terminen efectos.
- Sin build/instalación Android; percepción/fluidez en dispositivo pendiente. Siguiente paso: Hot Restart y comprobar abrir ficha/edición con carga lenta: una entrada inicial y sustitución directa del skeleton por información real.

## Continuidad real de carga de mascotas — 9 de octubre de 2026

- Usuario sigue observando skeleton que se oculta/reaparece antes de los datos. Causas locales identificadas: cover inicial sobre placeholder visible (la corrección previa solo evitaba reiniciar la animación al resolver) y consulta de galería iniciada al montar el contenido después de metadatos. No se afirma una traza capturada en Android.
- AuthStageTransition permite omitir/cancelar cover en cargas; PetScreenShell lo desactiva mientras espera. ContentReveal omite stagger desde que observa skeleton, y Home omite cover/stagger para Mis mascotas. Shimmer continuo y transición de ruta conservados; acceso y contenido disponible desde inicio conservan sus entradas. Excepción autorizada documentada en ADR-006/011 y REGLAS_UI_UX.
- ViewModels de ficha/editor coordinan metadatos y fotos en paralelo antes de publicar datos de pantalla. ensureInitialized comparte el Future de fotos por ciclo de identidad/mascota; galería lo reutiliza al montar, con reintento de foto explícito conservado. Sin segunda consulta al montar ni carga global seguida de skeleton local de galería. El skeleton de editor reserva también el bloque de foto, reduciendo salto de posición respecto al formulario real. Sin timers ni retrasos artificiales.
- Validación: suite completa secuencial, 168 pruebas aprobadas, y análisis sin incidencias. Cuatro regresiones nuevas de ficha/editor normal/pequeño comprueban el mismo elemento skeleton durante 20 frames y mientras solo han llegado metadatos, con una única consulta de fotos al mostrar galería. Test de entrada ampliado exige placeholder completamente visible sin cover desde el montaje. Tras ajustar geometría de foto, seis pruebas pertinentes y análisis final aprobados. Capturas de navegación normal y 320x350 texto 2 regeneradas y revisadas.
- Conservados cambios locales en codex/pets-registration. Sin SQL, publicación, commit/GitHub ni nueva instalación Android. Pruebas/capturas no acreditan rendimiento en dispositivo. Siguiente paso: Hot Restart y observar ficha/edición con conexión lenta: skeleton continuo, seguido del contenido con galería ya consultada.

## Registrar mascota con expansión desde origen — 9 de octubre de 2026

- Por solicitud explícita del usuario, botón Registrar mascota abre /home/pets/new con OriginPageTransition compartido, igual que Crear cuenta. PetsSection captura los límites reales del FilledButton relativos al Navigator y router compone CustomTransitionPage: apertura 320 ms, cierre 260 ms, inmediato con movimiento reducido. Regreso conserva Mis mascotas y guardado mantiene la ficha confirmada. No se introduce otra cortina sobre el skeleton.
- ADR-006, norma UI y diseño actualizados. Validación: formato de archivos modificados, flutter analyze --no-pub sin incidencias; ocho pruebas pertinentes aprobadas (navegación completa normal/pequeña, rectángulo real del botón, apertura/contracción/reapertura, transición compartida/movimiento reducido y arquitectura). Capturas de origen inicial/intermedio y formulario final revisadas, incluido 320x350 con texto 2. Ajustado harness para identificar subclases del botón y avanzar el frame que monta la ruta, sin cambios de producto por esos ajustes de pruebas.
- Cambios locales previos conservados en codex/pets-registration, sin commit/GitHub/deploy. Sin nueva instalación Android; percepción/fluidez de dispositivo no acreditada por el harness. Siguiente paso: Hot Restart y abrir/cerrar Registrar mascota desde Mis mascotas.

## Acciones de confirmación iguales y error de eliminación en toast — 9 de octubre de 2026

- Usuario solicita Cancelar/Eliminar mascota del mismo tamaño intermedio y rechaza el texto de error bajo la tarjeta tras borrar. PetDeletionDialog comparte fuente 14/peso 600, mínimo 52, radio 18 y padding 12. Ambas acciones tienen ancho/alto iguales; fila en tamaño normal y apiladas con altura común suficiente al ampliar texto. Se conserva contraste neutro/danger y confirmación obligatoria.
- PetsSection retira texto/bloque de error bajo mascota y usa el toast superior existente con icono de error. Fallo conserva tarjeta y reintento al deslizar; conflicto ofrece Actualizar lista dentro del toast. ConfirmationToastHost admite acción opcional y noticeId por resultado para repetir errores consecutivos, conservando dismiss, expiración, semántica y limpieza al desmontar/cambiar identidad. No introduce SnackBar ni cambia permisos/persistencia.
- ADR-013 documenta la ampliación autorizada de feedback; AGENTS, ADR-005, norma UI y diseño actualizados. Validación final: formato, flutter analyze --no-pub sin incidencias; suite completa secuencial de 169 pruebas aprobada. Harness CAPTURE_PETS normal/320x350 texto 2 aprobado; revisadas confirmación, acciones con texto ampliado y error exclusivo en toast. Pruebas verifican igualdad de tamaños, cancelación, fallo/reintento, aviso repetido, acción y disposición. Durante los ajustes del harness se descartó una ejecución que mezcló módulos anteriores con un selector nuevo; suite completa repetida después de finalizar los cambios, aprobada.
- Conservado trabajo local previo en codex/pets-registration. Sin SQL, GitHub, commit, despliegue ni nueva instalación Android. Pruebas/capturas no acreditan dispositivo real. Siguiente paso: Hot Restart y revisar confirmación/error de eliminación en Android.

## Diagnóstico remoto de eliminación y acciones compactas — 9 de octubre de 2026

- Usuario sigue sin poder eliminar y solicita menos padding/alineación inferior derecha. Diagnóstico directo del proyecto configurado: begin_pet_deletion y finish_pet_deletion responden HTTP404/PGRST202 (función no disponible en caché de esquema). Control create_pet_v2 responde HTTP401/42501, confirmando función existente protegida para rol anónimo. Se usó clave pública y UUID nulo, sin sesión de usuario ni eliminación de datos reales. El fallo está antes de iniciar el proceso de eliminación; no es consecuencia del tamaño de botones.
- Verificado/generado parche007 mediante Build-PetDeletionPatch.ps1: migración idéntica a fuentes, sin modificaciones de SQL. Falta activar database/patchs/007_patch_pet_deletion.sql completo en Supabase después de006 (o refrescar caché si ya fue aplicado). CONFIGURACION documenta aplicación/verificación. No se dispone de conexión administrativa aquí y NO se desplegó el parche; diagnóstico no afirma eliminación real exitosa.
- Botones ahora tienen padding8, separación8, mínimo táctil48 y ancho compacto común calculado desde etiqueta. Grupo abajo a la derecha, fila de ancho mínimo; con texto ampliado se apilan a la derecha sin truncar y conservan iguales dimensiones. Norma UI/diseño/ADR013 actualizados.
- Validación: formato/análisis sin incidencias, ocho pruebas Flutter pertinentes aprobadas incluyendo tamaño/alineación, cancelación/fallo/reintento y arquitectura; capturas normales y 320x350 texto2 revisadas. Prueba PostgreSQL local de eliminación aprobada, incluyendo aislamiento, conflicto/versiones, retirada de archivos, reintentos y repetición del parche. Prueba local no acredita servidor remoto.
- Conservado trabajo local previo en codex/pets-registration, sin commit/GitHub/deploy/instalación Android. Siguiente paso requerido para eliminar: aplicar007 en SQL Editor de Supabase y comprobar con el propietario. Hot Restart solo aplica ajuste visual.

## Parche de archivo/restauración y borrado definitivo — 9 de octubre de 2026

- Usuario acepta archivar habitualmente, borrar registros sin historial y bloquear operaciones cuando hay casos activos; solicita el patch. Entregado008_patch_pet_archiving.sql, generado desde fuentes030–033/plan008 y migración20261009000800_pet_archiving. Requiere007; SQL aplicado previo conservado.
- archived_at mantiene ficha/fotos. archive_pet/restore_pet con dueño obtenido en servidor, versión, bloqueo de fila y reintento sin escritura duplicada. Evolución de begin/finish_pet_deletion bloquea historial antes de limpiar fotos. case_history_at irreversible/active_case_count son de servidor, con constraints y trigger; no hay escritura cliente. ADR-014 establece mantenimiento atómico obligatorio por S3 y tratamiento futuro de cascadas de baja de cuenta; no se simulan casos/adopciones.
- Build-RunAll incorpora008 y se regeneró por script. Regeneración repetida comprueba igualdad de migración y fuentes. Once pruebas PostgreSQL locales aprobadas: archivo/restauración, RLS/grants/otra cuenta/anónimo, versión/reintentos, fotos conservadas, historial inmutable/caso activo, retirada segura y bootstrap repetible. Diff check sin errores. Sin cambios Flutter, por lo que no se repiten sus pruebas ni renders.
- Documentados README datos, CONFIGURACION, arquitectura y alcance en guía. Cambios locales previos conservados en codex/pets-registration, sin commit/GitHub/deploy. Parche NO aplicado remotamente; diagnóstico previo muestra007 no disponible en Supabase. El parche backend no cambia por sí solo Eliminar ni los listados actuales de la app.
- Siguiente paso: aplicar007 y008 completos en desarrollo, verificar RPC con propietario y otra cuenta; luego integrar Archivar/Restaurar, filtrado activo/archivado y feedback mediante las capas existentes en Flutter. Antes de implementar casos, mantener/backfill de indicadores en servidor; no habilitar borrado sobre casos externos sin esa integración.

## Mis mascotas: vacío destacado y registro compacto — 9 de octubre de 2026

- Usuario solicita vacío con icono mayor y botón debajo; con registros, acción mínima en esquina. PetsSection retira botón ancho superior. Vacío confirmado ofrece huella88, texto existente y Registrar mascota centrado debajo; listado usa + Mascota neutro/compacto a la derecha. Elegida etiqueta Mascota para conservar claridad, con tooltip/nombre accesible Registrar mascota. Cabecera adapta texto ampliado sin truncar.
- PetRegistrationButton comparte estilo/acción y OriginPageTransition desde botón real en ambas variantes. Sin cambios de dominio/backend ni integración adicional de archivado; los datos siguen reales, refresh retenido y cambio de identidad protegido. No se muestra vacío mientras espera/error.
- Validación: formato y flutter analyze --no-pub sin incidencias; nueve pruebas pertinentes aprobadas, incluyendo recorrido completo normal/320x350 texto2, CTA bajo huella, acción compacta/derecha, rectángulos de origen, cancelación y recuperación/arquitectura. Capturas empty/list/add_compact y etapas de apertura regeneradas/revisadas. Sin suite completa ni SQL repetidos por ajuste visual localizado.
- Norma UI y diseño actualizados, sin ampliación del MVP. Trabajo local previo conservado en codex/pets-registration; sin commit/GitHub/deploy/instalación Android. Siguiente paso: Hot Restart para revisar vacío/listado y ambas aperturas en dispositivo. Activación remota de parches007/008 e integración de archivado siguen pendientes del incremento previo.

## Deslizamiento continuo y confirmación después del retorno — 9 de octubre de 2026

- Usuario solicita sustituir panel fijo de Eliminar por arrastre libre a izquierda, color rojo progresivo y retorno antes del modal al soltar. SwipePetCard usa desplazamiento en píxeles sin tope izquierdo, radio de tarjeta conservado y color neutro->danger; textos/iconos adaptan contraste, fotos conservan su imagen. Sin botón revelado ni posición abierta permanente.
- Umbral de intención40% del ancho, limitado96–180. Recorrido corto/derecha/cancelación vuelve sin modal. Retorno220ms easeOutCubic y endOfFrame antes del callback garantizan que el modal vea la posición original ya pintada. Movimiento reducido salta retorno, manteniendo seguimiento del dedo. Pulsación larga y CustomSemanticsAction abren la misma confirmación. onDelete Future bloquea duplicados durante retorno/modal/operación; cancelación del puntero y desmontaje no abren confirmaciones tardías. No se invoca borrado hasta aceptar el modal existente.
- Validación: formato y análisis sin incidencias; diez pruebas pertinentes aprobadas (dos nuevas de swipe con/sin movimiento reducido; navegación normal/320x350 texto2; eliminación/reintentos/cuenta; arquitectura). Se verifica salida completa del ancho, tinte progresivo, posición al invocar confirmación, cancelación, bloqueo, long press y disposición. Capturas swipe_partial/swipe y modal regeneradas/revisadas. Pruebas detectaron retorno aún no pintado y cancelación tratada por Flutter como fin del drag; corregidos endOfFrame y Listener antes de validación final.
- ADR006, norma UI y diseño actualizados. Conservado trabajo previo en codex/pets-registration; sin SQL, commit/GitHub/deploy/instalación Android. No se revalida backend ni se afirma rendimiento de dispositivo con capturas. Siguiente paso: Hot Restart y probar drag corto/largo, Cancelar/confirmar y movimiento reducido en Android.

## Tinte de todo el contenido durante swipe — 9 de octubre de 2026

- Por corrección del usuario, rojo progresivo del swipe cubre también textos, iconos y foto. ColorFiltered srcATop sobre contenido completo, con intensidad ligada al recorrido; retorno restaura colores. Nodo del filtro estable a intensidad0 en reposo para no remontar imagen y provocar parpadeos. No altera fotos almacenadas ni flujo de confirmación.
- Validación: formato/análisis sin incidencias; cuatro pruebas pertinentes aprobadas (swipe con/sin movimiento reducido y navegación normal/pequeña). Prueba incluye texto/Icon/Image, verifica filtro común, cambios/restauración y mismo elemento de imagen. Capturas de tinte parcial/completo regeneradas y revisadas, normal y320x350 texto2.
- ADR006, norma UI y diseño actualizados. Conservado trabajo local previo; sin SQL/GitHub/commit/deploy/instalación Android. Siguiente paso: Hot Restart y revisar con una mascota que tenga foto; fluidez del dispositivo no acreditada por harness.

## Swipe al70% y confirmación desde origen — 9 de octubre de 2026

- Por corrección explícita del usuario, desplazamiento máximo a izquierda70% del ancho de tarjeta. Se mantienen tinte completo, umbral de intención, retorno antes de confirmar, cancelación y bloqueo de duplicados. SwipePetCard entrega el rectángulo restaurado relativo al Navigator raíz.
- Modal de eliminación sin cover/stagger: OriginDialogTransition transforma superficie desde tarjeta a diálogo en320ms. PetCardContent comparte el contenido real del origen; su copia visual se desvanece primero, luego aparece destino desde65% de la animación. Layout final estable, interacción al terminar, reversa al cerrar y movimiento reducido inmediato. OriginPageTransition comparte aparición tardía del contenido para las aperturas existentes. Cabecera del modal adapta cierre/título con texto ampliado; acciones conservan tamaños iguales y alineación derecha.
- Validación: formato y análisis final sin incidencias; doce pruebas finales pertinentes aprobadas (transiciones de página/modal, reversa, opacidades, origen restaurado, límite70%, cancelación, navegación normal/320x350 texto2 y arquitectura). Suite general de173 aprobada antes del último ajuste de copia visual/cabecera; después se ejecutaron las doce comprobaciones pertinentes. Capturas normal/pequeña regeneradas y revisadas; en tamaño extremo el modal permite scroll hasta acciones. No acredita percepción/rendimiento Android.
- ADR006, norma UI y diseño actualizados. Trabajo local previo conservado; sin SQL, commit/GitHub/deploy/instalación Android. Siguiente paso: Hot Restart y comprobar gesto/apertura/cierre en dispositivo. Activación remota de007/008 e integración de archivado continúan pendientes del incremento anterior.

## Rojo más intenso y texto rojizo progresivo — 9 de octubre de 2026

- Usuario observa swipe demasiado tenue y texto sin cambio rojizo. Fondo ahora progresa a #C12F3D con easeOutCubic para intensificarse antes. Se sustituye selección negro/blanco según luminancia por interpolación explícita de texto/iconos a #FFE3E6 entre8–40% del recorrido de intención. Filtro compartido de fotos/contenido aumenta de22% a32%, conservando nodo de imagen y restauración completa al retornar. Límite70%, confirmación y paleta neutra general conservados.
- Validación: formato y análisis sin incidencias; cuatro pruebas pertinentes aprobadas tras ajuste final (swipe con/sin movimiento reducido, navegación normal/pequeña). Se comprueban cambio progresivo de texto, destino rojizo de texto/icono, rojo final, filtro estable y recuperación de colores. Capturas regeneradas; render de swipe parcial revisado con texto/iconos claros sobre rojo más intenso. Diff check sin errores. No se repite suite general por ajuste localizado.
- ADR006, norma UI y diseño actualizados. Trabajo local previo conservado; sin backend, commit/GitHub/deploy/instalación Android. Siguiente paso: Hot Restart y revisar el gesto con foto en dispositivo; fluidez/percepción Android sigue pendiente.

## Tarjeta de mascota más compacta — 9 de octubre de 2026

- Usuario solicita acercar nombre y texto secundario y reducir altura. PetCardContent usa separación2 en lugar de4 y alturas de línea explícitas1.2/1.25, evitando espacio heredado excesivo. Padding vertical14 en lugar de20; horizontal20/foto56 conservados. Sin altura fija, mantiene crecimiento con texto ampliado. Copia del origen comparte composición.
- Validación: formato/análisis sin incidencias; dos pruebas de navegación completas aprobadas en tamaño normal y320x350 texto2. Capturas de listado regeneradas y revisadas; sin recortes/overflow en el flujo. Norma UI/diseño actualizados. Sin nuevas pruebas específicas por cambio visual reversible ni suite completa repetida.
- Trabajo previo conservado, sin backend/commit/GitHub/deploy. Siguiente paso: Hot Restart y revisar densidad de tarjetas con foto/nombres largos en Android; render de pruebas no acredita revisión en dispositivo.

## Cambio rápido de texto y cierre sin desplazamiento aparente — 9 de octubre de 2026

- Usuario solicita color del texto casi instantáneo y señala movimiento ligero al terminar cierre. Intervalo de color reducido a32–36% del recorrido de intención. OriginDialogTransition omite copia del origen al cerrar y desvanece overlay durante último18%, revelando tarjeta real inmóvil. Material.animationDuration cero elimina interpolación adicional de forma/color sobre morph. Apertura conserva copia de origen; límite70%, cancelación y movimiento reducido conservados.
- Validación: formato/análisis sin incidencias; seis pruebas pertinentes aprobadas (modal, swipe y navegación normal/pequeña), más repetición de dos pruebas de swipe tras ajuste final del intervalo. Prueba de cierre comprueba ausencia de copia, overlay final invisible, rectángulo de origen y Material sin animación implícita. No se afirma reproducción/verificación en Android ni suite general nueva.
- ADR006, norma UI y diseño actualizados. Trabajo previo conservado; sin backend/commit/GitHub/deploy. Siguiente paso: Hot Restart y comprobar cierre/retorno y percepción del cambio de color en Android.

## Tinte suave desde el inicio del swipe — 9 de octubre de 2026

- Usuario sustituye cambio rápido por transición suave que comienza apenas desliza. Texto/iconos y filtro de foto ahora comparten colorProgress easeOutCubic con el fondo desde recorrido0; eliminado intervalo32–36% que causaba cambio brusco. Sin animaciones temporales adicionales por frame; color sigue gesto y retorno. Se conservan tonos, límite70%, nodo estable de imagen y corrección de cierre.
- Validación: formato y análisis sin incidencias; cuatro pruebas pertinentes aprobadas (swipe con/sin movimiento reducido y navegación normal/pequeña). Sin nuevas pruebas por ajuste visual reversible ni suite general repetida. Documentación de diseño/norma/ADR006 actualizada.
- Trabajo previo conservado; sin backend/commit/GitHub/deploy. Siguiente paso: Hot Restart y revisar suavidad/tinte con foto en Android; percepción en dispositivo pendiente.

## Eliminación solo por swipe y registro circular — 9 de octubre de 2026

- Usuario elimina confirmación por pulsación larga y pide acceso solo por swipe izquierdo. SwipePetCard retira onLongPress y CustomSemanticsAction alternativa. Prueba mantiene pulsado sin confirmar y después verifica que swipe sí confirma; bloqueo/cancelación y movimiento reducido conservados.
- Usuario sustituye + Mascota por círculo negro con + blanco como referencia adjunta. PetRegistrationButton compacto: CircleBorder,56, fondo #111111, icono26 blanco, sin etiqueta visible; tooltip/nombre accesible Registrar mascota y origen real de transición conservados. Vacío mantiene botón completo. Etiqueta completa permite ajustar líneas con texto ampliado.
- Validación: formato/análisis sin incidencias; pruebas de swipe con/sin movimiento reducido y navegación normal/pequeña aprobadas. La comprobación detectó overflow de etiqueta completa con texto2 durante cambio de composición: corregido con Flexible y repetidas ambas pruebas de navegación. Captura normal del círculo revisada; navegación/origen y pulsación larga sin confirmación verificados. No acredita percepción Android.
- Norma UI, diseño y ADR006 actualizados. Trabajo previo conservado; sin backend/commit/GitHub/deploy. Siguiente paso: Hot Restart y revisar círculo/registro y eliminación exclusivamente mediante swipe en Android.

## Cabecera estable al aparecer el botón circular — 9 de octubre de 2026

- Usuario detecta que Mis mascotas baja ligeramente cuando aparece +. La cabecera antes pasaba de Text solo a Row centrado de56: cambiaba posición vertical del título. _PetsHeader mantiene Row y espacio56 de acción en carga/vacío/listado normal; con texto ampliado mantiene título arriba y botón debajo. Se conserva alineación derecha y acción solo con mascotas confirmadas.
- Validación: formato/análisis sin incidencias; navegación normal/pequeña aprobada, capturas regeneradas. Añadida comprobación de posición relativa de Mis mascotas entre vacío y listado tras registro; ambas pruebas repetidas y aprobadas. Norma/diseño actualizados; sin backend/commit/GitHub/deploy.
- Siguiente paso: Hot Restart y comprobar cabecera al terminar carga/registrar en Android. Validación en dispositivo pendiente.

## Ajuste de ficha solicitado, 9 de octubre de 2026

- Retorno circular glass con chevrón, reutilizando GlassSurface extraído a core; editor conserva retorno previo. Eliminado «Ficha de mascota»: nombre como encabezado y fotos encima, hasta280 según ancho. Huella visible solo sin fotos y sin error de consulta. Skeleton de ficha actualizado. Alcance visual de HU-03.2 (issue #29) y HU-04.1 (issue #30), sin cambios de backend.
- Validación: flutter analyze --no-pub sin incidencias; formato de lib/test correcto. Arquitectura, navegación con capturas, carga, fotos y Home:18 pruebas aprobadas en el primer pase; ampliación posterior de carga/identidad con y sin foto, normal/320×350 texto2:8 pruebas aprobadas. Renders pets_detail_normal/small revisados; fixtures exclusivos de pruebas.
- Limitación: fotos en pruebas de identidad son metadatos sustituidos; no acreditan descarga privada ni rendimiento del blur en Android. Siguiente paso: revisar ficha con fotografías reales y retorno en dispositivo. No se desplegó ni publicó.

## Ficha: fotos compactas y retorno flotante — 9 de octubre de 2026

- Corrección solicitada: fotos de ficha reducidas de280 a160; skeleton acompaña tamaño. PetScreenShell usa Stack en ficha para superponer retorno glass sobre scroll completo, eliminando el corte bajo cabecera. Insets conservan posición segura del botón y espacio inicial del contenido.
- Validación: flutter analyze --no-pub sin incidencias; formato de archivos modificados correcto;14 pruebas aprobadas de carga/identidad, navegación y arquitectura. Capturas de navegación normal/320×350 texto2 regeneradas y revisadas. Prueba con metadatos de foto confirma desplazamiento detrás del botón fijo.
- Pendiente: comprobar blur/fotografías privadas reales y zona de estado en Android. Sin cambios de backend ni publicación. Siguiente paso: revisar en dispositivo el nuevo tamaño y continuidad al desplazar.

## Ficha: huella y foto con igual tamaño — 9 de octubre de 2026

- Huella sustitutiva y foto comparten el cálculo de tamaño (hasta160) y espacio20 hasta el nombre. La identidad conserva posición entre mascota con/sin foto; sin cambios de operaciones o backend.
- Validación: formato correcto, flutter analyze --no-pub sin incidencias y10 pruebas aprobadas de carga/identidad y navegación. Capturas normal/320×350 texto2 regeneradas y revisadas.
- Pendiente: revisión de fotos reales en Android. Siguiente paso: comprobar ambos estados en dispositivo; sin publicación.

## Navegación glass general y Tamaño a ancho completo — 9 de octubre de 2026

- GlassNavigationButton compartido en core para retorno/cierre de pantallas. PetScreenShell usa siempre retorno flotante glass: ficha, Registrar y Editar. Perfil y cierre de acceso reutilizan el mismo acabado; destinos/callbacks conservados. ADR-015, AGENTS, REGLAS_UI_UX, DISENO_UI y ARQUITECTURA registran la regla general autorizada.
- Tamaño reparte el ancho completo en tres columnas iguales y gaps8, sin scroll horizontal. Iconos y texto se apilan con poco ancho/texto ampliado; etiquetas multilínea explícitas evitan el fade heredado de ChoiceChip. Selección/deselección y bloqueo conservados.
- Validación: formato lib/test correcto y flutter analyze --no-pub sin incidencias.22 pruebas aprobadas de arquitectura, carga, navegación de mascotas/Perfil y acceso; harness general de renders aprobado. Navegación de mascotas repetida tras ajustar texto:2 pruebas aprobadas, incluyendo extremos y anchos iguales. Renders de formulario/Tamaño/edición, registro de acceso y Perfil normal/320×350 texto2 revisados.
- Limitación: fixtures de pruebas; no acreditan blur/rendimiento ni fotos privadas reales en Android. Siguiente paso: Hot Restart y comprobar registro/edición/desplazamiento en dispositivo. Sin backend, publicación ni despliegue.

## Confirmación al salir de Registrar/Editar — 9 de octubre de 2026

- Salida por retorno glass/Atrás protegida solo ante cambios sin guardar. Registro vacío, edición intacta/restaurada y guardado confirmado salen sin aviso. Campos y fotos pendientes cuentan; seguir/dismiss conserva borrador, confirmar descarta pendiente sin alterar datos guardados. PopScope bloquea salida durante guardado/procesamiento y evita modales duplicados.
- Validación:26 pruebas aprobadas de salida, navegación, estado de mascotas/fotos, carga y arquitectura; las4 pruebas de salida se ampliaron después y aprobaron bloqueo durante guardado/fallo y recuperación. Análisis Flutter sin incidencias y formato correcto. Capturas de confirmación/acciones normal y320×350 texto2 revisadas; fixtures locales.
- Pendiente: comprobar interacción de Atrás/teclado/gesto predictivo en Android real. Siguiente paso: Hot Restart y probar continuar/descartar desde ambos formularios. Sin backend ni despliegue.

## Detalles con expansión desde su tarjeta — 9 de octubre de 2026

- Solicitud del usuario: abrir una mascota existente con la misma expansión de origen que Registrar mascota. PetsSection captura límites de la tarjeta y router reutiliza OriginPageTransition (320ms apertura/260ms retorno); movimiento reducido sin expansión. Guardado confirmado y entradas sin origen conservan su comportamiento. Ajuste visual de HU-03 / RF-03, sin cambios de alcance ni backend.
- Validación: formato lib/test correcto; flutter analyze --no-pub sin incidencias;8 pruebas aprobadas de navegación normal/320×350 texto2, arquitectura y transición compartida con movimiento reducido. El recorrido comprueba Rect real y transición inversa. Capturas de inicio/fase intermedia/retorno y ficha normal/pequeña regeneradas y revisadas con fixtures de pruebas.
- Pendiente: comprobar fluidez en Android real; renders no acreditan rendimiento de dispositivo. Siguiente paso: Hot Restart y abrir/volver desde una tarjeta en Mis mascotas. Sin publicación, despliegue ni acciones en GitHub.

## Registro/edición pulidos y campos obligatorios — 9 de octubre de 2026

- Selector de fotos ampliado a160, igual que ficha, con selección/retirada existentes; skeleton acompaña. Nombre/especie/tamaño/edad/rasgos obligatorios; sexo opcional, Macho inicial y No lo sé disponible. Especie comienza en Seleccionar, fuera de las opciones seleccionables. Rasgos o descripción tiene contador interior0/200 y límite coherente de200 puntos de código Unicode.
- Dominio y ViewModel validan todos los campos antes de escribir. Campos inválidos usan ShakeField/borde danger del login, sin errorText debajo. Toast superior explica validación, guardado y fotos del editor; conflicto mantiene Ver ficha actual. Nuevos intentos repiten feedback por errorId; edición limpia el campo editado y conserva borrador. Corregido overflow de tamaño con borde danger/texto ampliado. ADR-016, reglas, guía y arquitectura documentan la autorización específica; otras funcionalidades conservan feedback anterior.
- Fuentes034–035/plan009 generan migración20261009000900_pet_required_fields.sql y patch009; run_all regenerado mediante scripts. Guard servidor exige metadatos completos al crear/editar sin inventar datos anteriores, conservando consultas y archivo/restauración/eliminación de mascotas antiguas. SQL aplicado anterior intacto.
- Validación: formato lib/test sin cambios pendientes y flutter analyze --no-pub sin incidencias. Suite completa Flutter:187 pruebas aprobadas. Incluye dominios/estado, formulario normal/320×350 texto2, movimiento reducido, validación múltiple/repetida, counter/Unicode/IME, placeholder, fotos, salida y arquitectura. SQL local PGlite:12 pruebas aprobadas, incluido contrato nuevo con permisos/reintentos/límites/filas antiguas y repetición. Renders de formulario, selector/foto pendiente, contador y errores normales/pequeños revisados con fixtures de pruebas; navegación con capturas regenerada.
- Limitaciones: migración009 no aplicada en Supabase remoto; pruebas locales no acreditan galería nativa/rendimiento Android ni persistencia remota. Siguiente paso: aplicar patch009 completo en desarrollo cuando se autorice despliegue y revisar con Hot Restart en Android campos vacíos, edad inválida, fotos y guardado/reintento. Sin commit, publicación, acciones GitHub ni despliegue.

## Fotos del editor pendientes hasta guardar — 9 de octubre de 2026

- Usuario comunica que el patch009 ya está aplicado; aplicación remota reportada por el usuario, sin verificación independiente de esta sesión. La corrección de fotos no requiere otro patch.
- Selección ya preparaba bytes localmente; corregida retirada que borraba remotamente antes de confirmar. PetPhotosState separa fotos confirmadas, selecciones nuevas y retiradas pendientes. Galería editable muestra borrador, ficha mantiene confirmadas; quitar una selección nueva no llama al servidor. Descartar restaura vista confirmada sin escrituras. Retiradas solas habilitan Guardar y activan confirmación de salida.
- Tras validar/confirmar metadatos, Guardar ejecuta retiradas y luego subidas para permitir reemplazar con tres plazas ocupadas. Operaciones confirmadas limpian su pendiente; fallos/reintentos conservan IDs restantes y no anuncian éxito parcial. Protección de cuenta/generación y bloqueo durante trabajo real conservados. ADR-017, arquitectura, diseño y guía actualizados; sin cambios SQL.
- Validación: suite completa Flutter193 pruebas aprobadas; incluye seis escenarios nuevos de borrador (cancelación, reemplazo al límite, retirada fallida/respuesta perdida/reintento, validación, fallo de metadatos y cambio de cuenta). Salida ampliada en edición normal/320×350 texto2 comprueba X, Guardar habilitado por retirada sola, seguir/descartar y foto remota intacta. Formato de lib/test correcto (243 archivos sin cambios) y flutter analyze --no-pub sin incidencias; git diff --check correcto.
- Limitación: Guardar coordina varias operaciones entre metadatos y Storage, sin transacción única; un fallo después de confirmar puede dejar cambios parciales y descartarlos no revierte lo ya confirmado. Pruebas con sustitutos no acreditan galería/Storage Android real. Siguiente paso: Hot Restart y comprobar elegir/quitar/reemplazar/cancelar antes de guardar, y reintento con red interrumpida. Sin commit, publicación ni despliegue.

## Archivo/restauración integrados en Flutter — 9 de octubre de 2026

- Solicitud: completar la integración pendiente de archivo/restauración del feature de mascotas antes de pasar a zonas. Rama real feature/pets-registration, un commit por delante del tracking y cambios locales existentes conservados. No se cambió rama, no se realizaron commit/push/GitHub ni despliegues.
- Pet/PetDto incorporan archivedAt/caseHistoryAt/activeCaseCount. PetRepository/PetDataSource/SupabasePetDataSource exponen archive/restore con ID/versión y respuesta confirmada. ArchivePet/RestorePet verifican actor y resultado; DeletePet bloquea casos activos/historial antes de retirar archivos. Fallos SQL pet_active_case/pet_has_case_history se normalizan sin mensajes del SDK.
- Mis mascotas separa Activas/Archivadas mediante filtros de servidor y RLS por dueño, con vacío propio, skeleton/error/reintento y refresh conservado. Ficha ofrece Archivar con confirmación/cancelación y Restaurar conservando datos/fotos. Edición de archivadas sigue disponible; eliminar permanece exclusivamente por swipe con las guardias del contrato. Éxitos usan toast superior compartido; errores de archivo/restauración son contextuales, con Actualizar ficha ante conflicto.
- PetLifecycleViewModel autoDispose por mascota bloquea duplicados y descarta resultados tardíos por generación/identidad, con keepAlive limitado a escritura. Edición y navegación/Atrás se bloquean durante la RPC. Archivo/restauración invalida ambos listados/ficha/editor sin retirar fotos; guardado y eliminación invalidan también Archivadas. La confirmación reutiliza OriginDialogTransition, admite scroll y adapta acciones con texto ampliado.
- Validación final: formato lib/test correcto (250 archivos sin cambios), flutter analyze --no-pub sin incidencias; suite completa secuencial Flutter: **202 pruebas aprobadas**. Nueve pruebas nuevas cubren archivo/restauración, conservación de metadatos/foto/historial, listas aisladas, respuesta perdida y reintento, actor/casos activos/historia/versiones, fallo/duplicados, cambio de cuenta, recorrido normal/320×350 texto2 y adaptador HTTP del SDK con filtros/RPC/fallos protegidos. Ajustado harness previo para esperar expiración del toast antes de pulsar una acción cubierta y seleccionar el chip completo. npm test en database/tests: **12 pruebas SQL locales aprobadas**, incluido archivo/restauración/RLS/grants/concurrencia por versión/reintentos/fotos e historial. git diff --check correcto.
- Capturas CAPTURE_PETS de registro/edición/navegación y archivo: **8 pruebas de render aprobadas**. Revisadas confirmación normal/pequeña y acciones alcanzables por scroll, lista Archivadas normal/pequeña, estado archivado/restaurado y error contextual. Fixtures solo de pruebas, sin datos simulados en producto.
- Diagnóstico remoto sin sesión, clave publicable y UUID nulo: archive_pet y restore_pet responden HTTP401/42501. Confirma RPC disponibles y rechazo anónimo; no acredita funcionamiento con propietario/otra cuenta ni todas las políticas. No se necesitó nuevo SQL ni se alteraron mascotas reales. No se ejecutó build/instalación Android ni operación remota autenticada.
- Siguiente paso: Hot Restart; abrir ficha → Archivar → comprobar Activas/Archivadas → consultar ficha/fotos → Restaurar, y repetir con fallo de red. Verificar aislamiento con dos cuentas reales y guardias de historial al integrar casos S3. Esta integración completa el pendiente de ciclo de vida; no cierra automáticamente HU/issues ni todos los criterios de S2/HU-04 (cámara, principal/miniaturas y sanitización pública en servidor continúan fuera de este incremento).

## Selector unido Activas/Archivadas — 9 de octubre de 2026

- Usuario solicita reemplazar los chips por el diseño de cápsula de su segunda imagen. PetsSection compone PetListFilter: superficie gris #E5E5EA, segmentos iguales, selección carbón/texto blanco, sin check ni bordes individuales. Indicador se desliza320ms/easeInOutCubic con movimiento reducido inmediato y RTL respetado; acciones/semántica selected y bloqueo durante eliminación conservados.
- Etiquetas14/600 con tipografía real del tema, área táctil mínima48 y padding6. Medición con TextPainter de la misma tipografía permite apilar los segmentos dentro de la cápsula al ampliar texto si no caben; sin reducir ni truncar etiquetas. Sin cambios de consultas, dominio o backend. Normas UI y diseño actualizados.
- Validación: formato lib/test correcto (251 archivos sin cambios), flutter analyze --no-pub sin incidencias, **13 pruebas pertinentes aprobadas** de archivo/restauración, navegación normal/pequeña y arquitectura, con CAPTURE_PETS. Renders finales de lista normal y320×350 texto2 revisados: horizontal en tamaño normal, vertical solo cuando las etiquetas ampliadas no caben; ambos estados y acciones mantienen su recorrido. git diff --check correcto. No se repitió suite completa ni SQL al ser un ajuste de presentación.
- Trabajo previo conservado en feature/pets-registration. Sin commit/push/deploy/build Android. Siguiente paso: Hot Restart y revisar selección Activas/Archivadas en Android; renders no acreditan fluidez en dispositivo.

## Texto sincronizado con el indicador del filtro — 9 de octubre de 2026

- Usuario solicita que el texto cambie de color mientras se desplaza el indicador. PetListFilter reemplaza AnimatedAlign aislado por un único TweenAnimationBuilder que controla posición y Color.lerp de ambas etiquetas entre carbón/blanco. Mantiene320ms/easeInOutCubic, reorientación desde progreso actual, layout adaptado/RTL, selección semántica y movimiento reducido inmediato.
- Validación: **11 pruebas pertinentes aprobadas** de archivo/navegación y arquitectura con CAPTURE_PETS; las dos pruebas existentes de recorrido normal/320×350 texto2 verifican que ningún texto cambie de golpe al pulsar, ambos colores sean intermedios durante desplazamiento y terminen con los colores correctos. Renders intermedios normales/pequeños revisados. Formato lib/test correcto (251 archivos sin cambios), flutter analyze --no-pub sin incidencias y git diff --check correcto. Sin repetición de suite completa/SQL por cambio solo visual.
- Trabajo local previo conservado; sin commit/push/deploy/build Android. Siguiente paso: Hot Restart y alternar Activas/Archivadas para revisar percepción de la transición en Android real.

## Morph del origen al registrar mascota — 9 de octubre de 2026

- Usuario solicita continuidad del botón al expandirse y regresar, tipo apertura de aplicaciones. Corregida superficie que comenzaba blanca y solo conservaba el Rect: PetRegistrationButton aporta OriginPageSource con carbón, radio real y contenido compartido. Botón completo/círculo + conservan identidad al iniciar; superficie interpola forma/color y la copia desaparece durante45% inicial antes del destino desde65%. Retorno invierte y recupera el botón. Copia sin interacción/semántica y destino bloqueado durante transición; movimiento reducido/duraciones320–260ms conservados.
- Cambio de presentación/inyección de ruta, sin dominio/backend. Trabajo previo preservado en feature/pets-registration. ADR-006, reglas UI y diseño actualizados.
- Validación: flutter analyze --no-pub sin incidencias;16 pruebas pertinentes aprobadas (transiciones página/modal, navegación normal/pequeña, salida del editor y arquitectura). Test nuevo comprueba identidad, color/forma/Rect, reversa y bloqueo de acciones. Navegación con CAPTURE_PETS repetida tras precisar frames de salida:2 pruebas aprobadas. Formato de los5 archivos Dart modificados correcto; git diff --check correcto. Capturas revisadas de inicio/morph y regreso normal/320×350 texto2 con fixtures, sin overflow.
- Limitación: no se ejecutó build ni revisión de fluidez en Android físico. Siguiente paso: Hot Restart y abrir/cerrar desde Registrar mascota y círculo + para revisar percepción en dispositivo. Sin commit/push/GitHub ni despliegue.

## Zonas de interés — HU-02.1 / RF-02,16 — 9 de octubre de 2026

- Rama creada a petición del usuario: `feature/interest-zones`, desde `feature/pets-registration`, árbol limpio al iniciar. Se conserva la app y trabajo previo; sin commit/push/PR, cambios en GitHub ni despliegue remoto.
- Primer incremento de HU-02 (issue#26 separado de HU-02.1): Perfil abre Zonas de interés, ruta autenticada con listado propio, vacío/error/reintento, selección manual, nombre1–60 Unicode y radio100–50000m. Edición/eliminación con confirmación; cancelar no escribe. Lima es encuadre de exploración inicial, no ubicación inferida. Alternativa de coordenadas valida en dominio; no pide GPS ni seguimiento continuo. HU-02.2/preferences permanece pendiente como segundo incremento.
- Clean Architecture/MVVM: entidades/ZonePoint, casos ListInterestZones/SaveInterestZone/DeleteInterestZone, contrato de repositorio, DTO/fuente SDK y composición en bootstrap/main. Fuente filtra propietario/proyección y usa RPC; fallos se normalizan sin mensajes del SDK. ViewModel autoDispose mantiene UUID por borrador, bloquea duplicados y descarta respuestas por cuenta/generación; keepAlive solo durante escritura. Refresh mantiene contenido/edición y muestra progreso fino; error/cambio de identidad oculta contenido anterior y limpia el toast.
- SQL036–039, plan010, migración20261009001000_interest_zones.sql y patch010 generados mediante scripts; run_all regenerado. RLS restrictiva por dueño, lectura limitada, sin DML directo/anónimo. RPC autorizadas con bloqueo/versión y reconocimiento del reintento idéntico. Eliminación conserva tombstone para impedir resurrección por envío antiguo. Trim Unicode coherente con Dart y límites de coordenadas/radio protegidos en servidor. Artefactos nuevos preparados, no aplicados; migraciones anteriores intactas.
- UI mantiene componentes compartidos: glass flotante, cover seguido de stagger por etapa, shimmer con etiqueta estable, éxito confirmado en toast superior y errores contextuales. Consultar versión actual pide descarte. Regreso al inicio del scroll al cambiar etapa sin repetir efectos por editar. Mapa flutter_map8.3.2/latlong2 con selección/círculo métrico, fuente conservada, reintento y fallos tardíos aislados por intento; OSM desarrollo con atribución/User-Agent/caché HTTP, sin precarga ni mapas offline. ADR-018 documenta servicio sustituible y límites.
- Validación: suite completa secuencial Flutter **212 pruebas aprobadas**; comprobaciones finales pertinentes **16 aprobadas** tras los últimos ajustes. Incluye límites/Unicode, borrador/ID/reintentos, guardado/edición/eliminación, dobles envíos, cambios de identidad, recuperación tras error con misma cuenta, refresh conservado, adaptador HTTP Supabase, mapa con fallo/reintento/selección/recentrado, rutas protegidas desde Perfil y normal/320×350 texto2. Formato lib/test y análisis sin incidencias; git diff --check correcto.
- SQL local PostgreSQL/PGlite: **13 pruebas aprobadas**, incluida nueva cobertura de permisos entre cuentas/anónimo, política amplia frente a guard restrictivo, límites, conflictos, reintentos de creación/edición/eliminación, rechazo de recreación tras eliminar y repetición de patch/run_all conservando filas, fechas, versiones y tombstones.
- Renders CAPTURE_ZONES con tipografía real revisados en build/ui-preview/zones: vacío, editor, fallo de guardado, listado y modal de descarte, normales/pequeños. Fixtures solo de pruebas; descargas de teselas sustituidas/bloqueadas no acreditan cartografía real ni disponibilidad del proveedor. Documentación de arquitectura, diseño, guía/backlog y configuración actualizada; snapshot GitHub Ready no sincronizado ni cerrado.
- Limitaciones: no se aplicó patch010 en Supabase, no hubo operaciones remotas autenticadas ni build/instalación Android. No se acreditó persistencia real tras reiniciar ni fluidez/cartografía en dispositivo. La dependencia de mapa/caché requiere reconstruir para registrar plugins; Hot Restart solo no sustituye un binario actualizado.
- Siguiente paso: aplicar patch010 completo en desarrollo cuando se autorice; reconstruir/instalar Android, abrir Perfil → Zonas de interés y comprobar dos zonas, radio, cancelar, reinicio, red interrumpida/reintento y aislamiento A/B. Después implementar HU-02.2 / issue#27 (tipos/canales/desactivación), sin afirmar entrega push hasta HU-12/S5.

## Verificación tras apagado — 10 de octubre de 2026

- Revisado a petición del usuario: el desarrollo de HU-02.1 sigue guardado localmente en `feature/interest-zones`, con cambios pendientes de commit. La implementación, pruebas, SQL y documentación están presentes; el feature todavía no está cerrado.
- Validación repetida: formato de 272 archivos sin cambios, `flutter analyze --no-pub` sin incidencias y suite completa `flutter test --no-pub --concurrency=1`: **212 pruebas aprobadas**. `npm test` en database/tests: **13 pruebas aprobadas**. `git diff --check` correcto; generación de patch010 confirma correspondencia con las fuentes.
- Pendientes conservados: aplicar patch010 en Supabase de desarrollo, reconstruir y comprobar el recorrido en Android con cuentas reales y persistencia tras reinicio. HU-02.2/preferences sigue sin implementar. Sin commit/push/despliegue durante esta verificación.

## Backlog GitHub y parche de zonas — 10 de octubre de 2026

- El usuario confirma haber ejecutado patch010 en Supabase y autoriza actualizar GitHub. Aplicación registrada como confirmación del usuario, sin atribuirle una verificación remota autenticada realizada por el agente.
- Issue #26 (HU-02.1) y épica #2 (HU-02) actualizados de Ready a In progress, en etiqueta y Status nativo de Projects. Cuerpos de issues incluyen implementación, 212 pruebas Flutter/13 SQL locales, parche reportado y pendientes. Ambos permanecen abiertos; #27 (HU-02.2) sigue en Backlog, sin implementación. Índice y fichas locales sincronizados.
- Siguiente paso: reconstruir/instalar Android y demostrar persistencia tras reinicio, dos zonas/radio/edición/eliminación/cancelación, reintento con red interrumpida y aislamiento A/B contra Supabase real; integrar el código antes de Done. No se repitieron pruebas de código por esta actualización documental. Sin commit/push ni despliegue adicional.

## Preferencias de alertas — HU-02.2 / RF-02,16 — 10 de octubre de 2026

- Usuario autoriza desarrollar la siguiente funcionalidad. Creada `feature/alert-preferences` desde `feature/interest-zones`, commit5bcb543 guardado por el usuario y árbol limpio al iniciar. Trabajo de zonas conservado. Este incremento queda local, sin commit/push/PR ni cambios en GitHub o despliegue remoto.
- Perfil abre ruta privada `/home/alert-preferences`. Configuración por cuenta: recepción general, tipos mascotas perdidas/encontradas y novedades de casos (avistamientos/cierre); canales bandeja/push. Cuenta sin fila confirmada inicia pausada, tipos/bandeja seleccionados y push desmarcado; consulta no escribe. Pausar conserva elecciones. Activar exige tipo/canal. La pantalla explica disponibilidad futura de recepción; no solicita GPS/permisos, no registra tokens ni envía. HU-12/S5 mantiene entrega real.
- Clean Architecture/MVVM en features/alert_preferences: entidad/contrato/fallos y ReadAlertPreferences/SaveAlertPreferences independientes de plataforma; DTO/fuente SDK/repositorio e inyección declarativa/bootstrap/main. Respuesta de otra cuenta o selección/version incompatible no confirma guardado; errores externos se normalizan sin mensajes del SDK.
- ViewModel autoDispose conserva selección/versión tras fallo, bloquea dobles envíos y edición durante operación; keepAlive limitado a guardado. Generación/identidad descarta resultados tardíos y permite recuperación tras error de sesión con la misma cuenta. Refresh explícito conserva contenido con progreso fino, pide confirmar descarte si hay borrador y lo conserva ante fallo. Conflicto exige consulta actual; salir/descartar pide confirmación. Error/cambio de cuenta oculta datos anteriores y limpia éxito.
- UI conserva glass flotante, cover/stagger por entrada, skeleton inicial y LoadingShimmer con etiqueta estable. Fallos contextuales junto a guardar y éxito en toast superior confirmado, sin SnackBar. Extraído modal de descarte a core con wrapper compatible de zonas, sin imports de presentación entre funcionalidades. Revisión de capturas con fuentes reales en build/ui-preview/preferences: carga, error de consulta, selección, canales, fallo de guardado, éxito y descarte/acciones en390×844 y320×350 texto2. Acciones alcanzables por scroll, sin reducir tipografía. Fixtures solo de pruebas.
- SQL040–043/plan011 generan migración20261010001100_alert_preferences.sql, patch011 y run_all mediante scripts. owner_id como clave estable, FK/cascade, restricciones de tipos/canales, RLS restrictiva y proyección/grants limitados; sin DML directo/anónimo. RPC obtiene actor de auth.uid(), bloquea cuenta/fila, valida versión y reconoce respuesta perdida por cuenta/versión/selección idéntica; no-op conserva fechas/versiones. Comandos antiguos/incompatibles producen conflicto. Migraciones previas intactas, nuevo patch todavía no aplicado remotamente.
- Validación final: formato lib/test correcto (**290 archivos sin cambios**), `flutter analyze --no-pub` sin incidencias; **21 pruebas pertinentes aprobadas**, con CAPTURE_PREFERENCES, y suite completa secuencial Flutter: **219 pruebas aprobadas**. Siete pruebas nuevas cubren dominio/ausencia/fallos/límites, guardado/reintentos/pausa, duplicados, cuenta/disposición, refresh/conflicto/recuperación, dos tamaños y adaptador HTTP del SDK. Navegación existente ampliada con ruta protegida, cancelar salida y descartar antes de volver; arquitectura y zonas conservadas.
- `npm test` en database/tests: **14 pruebas SQL locales aprobadas**, incluida cobertura de cuentas A/B/anónimo/sin sesión, columnas/grants, política amplia frente a guard restrictivo, límites/nulos/versión, reintentos/conflictos, pausa sin pérdida y cascade. Nuevo test aplica patch011 sobre esquema de zonas, lo repite y comprueba que run_all/patch conservan valores/fechas/versiones. Generación repetida de patch011 confirma contenido idéntico a fuentes; git diff --check correcto.
- Documentación de arquitectura/diseño/configuración/guía/backlog/SQL actualizada y ADR-019 registra catálogo, defaults y contrato futuro de HU-12. Ficha local distingue implementación y snapshot remoto; no se marca Done ni se cierran criterios por estas pruebas.
- Limitaciones: no se aplicó patch011 en Supabase ni se realizaron operaciones remotas autenticadas, build/instalación Android o prueba real tras reinicio. Siguiente paso: ejecutar patch011 completo en desarrollo, actualizar app y abrir Perfil → Preferencias de alertas; guardar/reabrir/reiniciar, pausar/reactivar conservando selección, provocar fallo/reintento, editar en dos dispositivos y comprobar aislamiento A/B. Integrar código y demostrar criterios antes de cerrar HU-02.2. Recepción push/bandeja efectiva queda para HU-12.

## Confirmación de aplicación de parches — 10 de octubre de 2026

- El usuario confirma que ya ejecutó los parches en Supabase; se registra patch010 (zonas, confirmado previamente) y patch011 (preferencias). Aplicación reportada por el usuario; no se atribuye al agente una ejecución o verificación remota autenticada.
- Rama comprobada: feature/alert-preferences, árbol limpio antes de esta actualización documental. La implementación de preferencias ya está guardada en Git por el usuario; no se realizaron nuevos commit/push ni cambios de GitHub.
- Se actualizan guía, ficha HU-02.2 y documentación SQL. Próximo paso: actualizar la app en Android y comprobar Perfil → Preferencias de alertas; guardar, cerrar/reabrir, reiniciar, pausar/reactivar sin perder selección, fallo/reintento y aislamiento entre dos cuentas. Recepción efectiva de alertas sigue pendiente de HU-12. Estos criterios no se consideran demostrados por la sola aplicación del parche.
- Validación documental: git diff --check. No se repiten pruebas Flutter/SQL porque no se modificaron código ni fuentes/migraciones aplicadas; se conserva la evidencia previa de219 Flutter y14 SQL locales aprobadas.

## Actualización autorizada del Project — 10 de octubre de 2026

- Revisado el avance guardado y los 51 items del Project3. Preferencias #27 de Backlog a In progress; fotos #30 y épica #4 de Ready a In progress; retirada #31 de Backlog a In progress. Se corrige clasificación de trabajo sin iniciar cuando ya existe implementación parcial. Actualizados cuerpo de issues, etiqueta y Status nativo; #2/#26 mantienen In progress con seguimiento actualizado.
- Zonas y preferencias publicadas por el usuario en ramas feature/interest-zones y feature/alert-preferences; commits remotos5bcb543/006ebc6 comprobados mediante API. Patch010/011 reportados como aplicados. Fotos con galería/carga/retiro/borrador existentes; pendientes cámara, principal explícita/regla de reemplazo, miniaturas/sanitización pública servidor y demo real. PR53 abierto de mascotas conserva plantilla; no se editó ni se considera aceptación completa.
- Verificación posterior:51 tarjetas con una única etiqueta de estado coincidente con Status. Totales34 Backlog (26 historias/8 épicas) y17 In progress (13 historias/4 épicas);0 Ready/In review/Done. Issues actualizados abiertos, sin casillas marcadas ni cierres. Se sincronizaron seis fichas locales, índice y BACKLOG_MVP conservando cambios documentales previos.
- Validación documental: git diff --check. Sin cambios de código/SQL ni repetición de pruebas; evidencia previa219 Flutter/14 SQL locales. No se realizaron commit/push, merge, despliegue o envío de mensajes fuera de la actualización autorizada de issues/Projects.
- Siguiente paso: demostrar en Android/Supabase autenticados guardar/reabrir/reiniciar, permisos entre cuentas y reintentos de zonas/preferencias; completar criterios de fotos y preparar integración/revisión antes de Done.

## Validación de HU-02 reportada por el usuario — 10 de octubre de 2026

- El usuario confirma que ya validó el flujo y funciona correctamente. Se registra como validación realizada por el usuario, adicional a los parches aplicados y pruebas locales previas; no como una ejecución remota del agente.
- HU-02.1/#26 (zonas) y HU-02.2/#27 (preferencias) están implementadas; las subhistorias son el desglose de HU-02, no desarrollo adicional. Falta integrar las ramas en main y reflejar la aceptación/cierre en el seguimiento. Esta consulta sobre el siguiente feature no realiza merge ni cierre de issues.
- Siguiente incremento recomendado: completar HU-04.1/#30 y HU-04.2/#31 (cámara/permisos, foto principal/regla de reemplazo y procesamiento público/miniaturas sin EXIF), en feature/pet-photo-management. Después HU-05/#5, publicación de mascota perdida, que depende de fichas y fotos. Push/bandeja real permanece en HU-12.

## Continuación de fotos — HU-04.1/#30 y HU-04.2/#31, 10 de octubre de 2026

- Usuario autoriza continuar pendientes antes de casos. Rama nueva codex/pet-photos desde feature/alert-preferences; se conservan los cambios documentales previos de parches/Projects/validación reportada por el usuario. Esta tarea no hace commit/push/PR, cambios GitHub, merge, aplicación SQL ni despliegue.
- Cámara y galería como alternativas, con error de cámara que no bloquea galería y recuperación/normalización por cuenta. Añadida descripción de cámara iOS; Android usa el plugin ImagePicker existente. Principal mediante estrella y semántica selected: selección/retirada/nuevas fotos siguen como borrador hasta Guardar, descartables sin escritura. Fallos conservan pendientes; ViewModel usa versión de selección/CAS y ofrece consulta explícita ante conflicto. Lista usa miniatura principal; ficha indica imagen principal confirmada.
- Edge pet-photo-process preparada: Auth.getUser y autorización por mascota antes de leer imagen; cuerpo acotado aun sin Content-Length, validación JPEG/dimensiones y decode completo antes de reservar. magick-wasm0.0.44 fijado con lock genera imagen/miniatura JPEG limpias (1280/320); elimina EXIF/GPS, limita resolución/caché/disco y normaliza fallos. SDK/configuración de servidor encapsulados fuera de Flutter; no keys de servidor en app. Cliente invoca Edge con sesión y bytes normalizados.
- SQL044–047/plan012, migración20261010001200_pet_photo_processing.sql y patch012 generados con scripts, run_all ampliado. Ambos buckets nuevos privados, confirmación/reserva exclusiva de servicio, antigua publicación/carga cliente bloqueadas, hash por UUID, tombstone para no revivir fotos retiradas, principal única/versionada y reemplazo por publicada más antigua. Storage permite borrar solo tras iniciar retirada/baja, con SELECT de metadata necesario para limpieza. Políticas restrictivas protegen contra otra permisiva. Baja elimina/verifica los tres buckets. SQL previamente aplicado intacto.
- Fotos existentes conservan privacidad y lectura antigua, sin inventar processed_at. S3 solo podrá exponer derivados verificados mediante proyección pública autorizada: no hay publicación de mascotas sin caso. Conversión/reemplazo seguro de fotos históricas antes de exposición pendiente de ese recorrido explícito. Guardado/Storage no es transacción distribuida; caída abrupta puede dejar archivos privados incompletos/huérfanos, que requieren revisión/limpieza operativa.
- Validación: formato lib/test correcto,291 archivos sin cambios; flutter analyze --no-pub sin incidencias. Suite Flutter completa secuencial:225 pruebas aprobadas; pruebas nuevas de cámara denegada con galería operativa, principal/borrador/descarte/fallo/reapertura, interfaz y adaptador HTTP Edge. Capturas con fuentes reales del componente normal390×844 y pequeña320×350 texto2 en build/ui-preview/photos revisadas; suite conserva navegación/editor/cargas/arquitectura.
- npm test en database/tests:15 pruebas aprobadas, incluyendo upgrade/repetición de patch012/run_all, A/B/anónimo/servicio, columnas/RPC/grants, derivación incompleta, hash/reintento, política amplia, CAS/principal/reemplazo, retirada fallida/tombstone y baja de mascota con derivados. PGlite usa metadata Storage simulada.
- Deno2.2.12 local: check y7 pruebas aprobadas con WASM real y HTTP SDK sustituido. Bytes de EXIF/GPS rechazados/eliminados de ambas salidas, archivos truncados/manipulados/excesivos,1280², outputs deterministas, Auth/propiedad, falla de Storage y reintento con UUID/hash. Medición local del último run:1280×640 aproximadamente121ms; dos1280² aproximadamente228ms y RSS223MiB. Son fixtures uniformes locales, no prueba de las cuotas ni rendimiento del runtime hosted.
- APK debug con configuración local intentado: Gradle falla antes de compilar con java.io.IOException: Unable to establish loopback connection. No se generó ni instaló APK de este incremento; iOS no compilado. SQL012/Edge no aplicados/desplegados; demo Android/Supabase, denegación real de cámara, bytes descargados y cuotas hosted pendientes. Historias siguen abiertas y no se marcan Done por pruebas locales.
- ADR-020 y documentación de configuración/arquitectura/diseño/guía/backlog/SQL actualizadas. Siguiente paso concreto: activar conjuntamente patch012 y Edge según supabase/functions/pet-photo-process/README.md, recompilar desde entorno Android funcional, demostrar cámara/galería/principal/retiro/reinicio/aislamiento y decoder en hosted; integrar/revisar antes de cerrar#30/#31/#4. Después HU-05/#5, publicar mascota perdida.

- Comprobación final: la rama creada codex/pet-photos fue renombrada a feature/pet-photos durante el trabajo (reflog comprobado); el código continúa en esta rama actual, sin nuevo commit. Formato/análisis y regeneración idéntica de patch012 comprobados; git diff --check correcto con tratamiento CRLF de Windows. Los nombres de rama en los registros anteriores describen el inicio del incremento.

## Patch012 aplicado según el usuario — 10 de octubre de 2026

- El usuario confirma ejecución del patch012 en Supabase; se registra aplicación reportada, sin atribuir al agente ejecución SQL o validación remota.
- Activación restante: preparar/incluir magick.wasm y desplegar la Edge Function pet-photo-process en el mismo proyecto, actualizar la app y probar cámara/galería, principal, retirada/reinicio y aislamiento. El patch configura datos/permisos; no instala el procesamiento Edge. Las cargas nuevas requieren esa función.
- Rama comprobada: feature/pet-photos; se conserva el trabajo local existente. Esta respuesta no ejecuta despliegue, cierre GitHub, commit/push ni build adicional. Procedimiento en supabase/functions/pet-photo-process/README.md; evidencia previa se conserva.

## Preparación de funciones para Dokploy — 10 de octubre de 2026

- Usuario aporta docker ps, docker ps -a y Compose de Entre Huellas: no existe servicio functions. Se corrige la orientación previa de deploy por project-ref (solo Supabase administrado). No se requiere ejecutar magick.wasm manualmente.
- Preparados supabase/self-hosted: servicio edge-runtime1.76.2, volumen persistente de archivos/caché, router restringido a pet-photo-process con import map explícito y worker aislado. El handler conserva Auth.getUser/propiedad. Solo transmite al worker las tres variables Supabase requeridas. Límite inicial256MiB/60s requiere medición real.
- Generador Build-PhotoBundle.ps1 produce tar.gz con código/lock/WASM y, opcionalmente, Compose completo a partir del aportado por el usuario; resultados en work/dokploy-photos, ignorados por Git. Contenido inspeccionado: sin claves ni configuración cliente, sin node_modules/pruebas/cachés. Conserva los servicios del Compose recibido y añade functions y functions-deno-cache.
- Validación local nueva: Deno format/check del router correctos,3 pruebas aprobadas (rutas/sesión antes de worker, transmisión de cuerpo/sesión y rechazo del handler, preflight/fallo de arranque sin detalles privados). docker compose config --no-interpolate --quiet aprueba el Compose preparado. No acredita arranque real de Edge Runtime: Docker Engine local no está disponible y no se ejecutaron comandos remotos.
- Siguiente paso: leer mounts de Kong y sección functions-v1 de su fuente en el servidor; ubicar el volumen correcto y comprobar/adaptar ruta preservando Authorization. Después copiar paquete, activar servicio en Dokploy y demostrar subida/aislamiento/EXIF/principal/retiro con Android y sesiones reales. No se modificaron servicios remotos ni se cerraron historias.

- Diagnóstico remoto aportado por el usuario: Kong monta /etc/dokploy/compose/entrehuellas-supabase-bmcwgm/files/volumes/api/kong.yml; su ruta functions-v1 ya envía /functions/v1/ a http://functions:9000/, strip_path true y cors. No necesita cambio de Kong. Se entrega procedimiento concreto de copia del paquete al volumen hermano functions y activación del Compose en Dokploy. Copia, despliegue, arranque y prueba de foto autenticada aún no acreditados; el agente no ejecuta acciones remotas.

- Activación remota acreditada por salidas aportadas por el usuario: magick.wasm de15MiB presente en el volumen esperado; contenedor entrehuellas-supabase-bmcwgm-functions-1 Up24seconds. POST anónimo al endpoint público /functions/v1/pet-photo-process devuelve HTTP401 y {"code":"unauthorized"} a través de Kong. Confirma arranque del router y conectividad externa; no prueba creación del worker, importación de dependencias, decodificación WASM ni operaciones SQL/Storage autenticadas. Siguiente paso: guardar una foto nueva desde la app y verificar reapertura/derivados y logs si falla. Las pruebas completas de aislamiento, EXIF/GPS y ciclo de vida siguen pendientes. Acciones de copia/despliegue ejecutadas por el usuario, no por el agente.

## Corrección de WASM en el worker de Dokploy — 10 de octubre de 2026

- Primera subida real falla con toast de fotos; logs del usuario prueban NotFound de magick.wasm en /var/tmp/sb-compile-edge-runtime. Faltaba staticPatterns al crear el worker: el montaje existía pero el archivo no se incorporaba al FS virtual de la función. El401 anterior solo ejercitaba el router.
- Corregido supabase/self-hosted/main/index.ts para incluir explícitamente el WASM de la función en staticPatterns. Verificado contra ejemplo e implementación ESZIP oficiales de edge-runtime v1.76.2: patrones glob admiten rutas absolutas y añaden datos estáticos al paquete virtual. La lectura relativa al módulo en processor.ts se conserva; no cambian Flutter, SQL aplicado, permisos ni Kong.
- Formato/check Deno correctos y10 pruebas aprobadas (3 procesador real,4 handler,3 router). Regenerado work/dokploy-photos/entrehuellas-functions.tar.gz con la corrección. Docker Engine local no disponible: estas pruebas no confirman arranque ESZIP; pendiente reemplazar main/index.ts en el servidor, reiniciar solo functions y repetir guardado de una foto. No se ejecutó el reemplazo/reinicio remoto desde el agente.

- Tras la instrucción de actualización y reinicio, el usuario confirma que ahora la app permite guardar la foto. Se registra éxito de guardado reportado por el usuario: el fallo de WASM observado dejó de bloquear ese intento. Falta comprobar reapertura/reinicio y los criterios restantes (cámara/permisos, principal/retiro, aislamiento A/B y EXIF/GPS de derivados descargados); no se cierran automáticamente HU-04/#30/#31/#4 ni se atribuye al agente ejecución o inspección remota adicional.

## Fichas de funcionalidades — 10 de octubre de 2026

- Por solicitud del usuario, añadidos docs/funcionalidades/README.md y8 fichas: acceso/recuperación, onboarding, inicio/navegación, perfil/avatar, mascotas, fotos de mascotas, zonas y preferencias de alertas. Cubren los7 módulos Flutter existentes y separan fotos por su alcance servidor/Storage.
- Cada ficha describe qué hace, recorrido, reglas/campos, persistencia/privacidad, errores/reintentos, dependencias y validación pendiente, con enlaces de trazabilidad HU/RF/issues. Fotos incluye procesamiento automático, papel del WASM, principal/borradores, privacidad, activación Dokploy y corrección del FS virtual; el éxito real reportado por el usuario se distingue de los criterios aún pendientes.
- Índice enlazado desde README, ARQUITECTURA y GUIA_MVP. AGENTS registra actualización de la ficha en cada incremento, cumpliendo la instrucción persistente del usuario. No cambia alcance del MVP, estado GitHub ni código de aplicación/servidor en esta tarea.
- Validación documental: enlaces locales y cobertura de módulos comprobados, diff sin errores de whitespace. No se repiten suites Flutter/SQL/Deno porque solo cambian documentos. Siguiente paso funcional conserva cierre de verificaciones de fotos y después HU-05; la documentación debe acompañar cada entrega futura.

## Rama para casos de mascotas perdidas — 10 de octubre de 2026

- Por solicitud del usuario, creada y seleccionada `feature/lost-pet-cases` desde `feature/pet-photos`, commit `f8f7965`, con árbol limpio al iniciar. Conserva las implementaciones de mascotas, fotos, zonas y preferencias; no parte del main local todavía sin integrar esos incrementos.
- Siguiente funcionalidad: S3, HU-05 / RF-05, issue #5. Alcance: publicación autorizada con fotos, fecha/hora y lugar manual, vista previa/proyección pública con zona aproximada, un caso perdido activo por mascota e idempotencia; conservar formulario ante fallo y confirmar únicamente publicación persistida.
- Esta preparación crea la rama y registra el relevo; HU-05 aún no está implementada. Sin commit/push, merge, cambios GitHub ni despliegue. Se mantienen pendientes de validación de fotos en Android/Supabase; el guardado real fue confirmado por el usuario, sin acreditar todos los criterios de HU-04.
- Validación: rama/base comprobadas y `git diff --check`; no se modificó código ni SQL y no se repiten suites. Siguiente paso: implementar HU-05 según `docs/backlog/005-HU-05.md`, acompañada de su ficha en `docs/funcionalidades`, permisos y pruebas de concurrencia/reintentos/privacidad.

## Publicación de mascotas perdidas — HU-05 / RF-05 — 10 de octubre de 2026

- Implementación local autorizada en `feature/lost-pet-cases`, sobre `f8f7965`. Conservado el relevo documental previo. Sin commit/push/PR, merge, actualización GitHub, aplicación SQL ni despliegue. Issue #5 es independiente del identificador HU-05 y permanece abierto con snapshot remoto Backlog.
- Reportar → Mascota perdida consulta mascotas activas propias y ficha/fotos actuales. Permite elegir fotos públicas, fecha/hora de desaparición, punto manual o coordenadas y referencia privada. Vista previa explícita antes de publicar; solo respuesta confirmada abre Caso publicado → Ver ficha pública. Mis casos recupera publicaciones persistidas, incluidas las de respuesta perdida. Encontradas/exploración/QR/cierre/alertas siguen sus historias posteriores.
- Clean Architecture/MVVM en lost_cases: dominio/casos de uso/contrato independientes de SDK, fuente Supabase y DTO/repositorio con normalización de fallos, providers declarativos e inyección bootstrap/main. Mapa visual extraído a core con export compatible en zonas. ViewModels autoDispose descartan resultados tras cambio de cuenta/disposición, recuperan misma cuenta después de error de sesión y bloquean dobles envíos. Respuesta ambigua conserva UUID/comando exacto y bloquea edición hasta confirmar; rechazos conocidos permiten corregir. Borrador en memoria; persistencia offline pendiente de HU-15.
- UI con retorno glass flotante, cabecera fuera del cover/stagger y scroll al inicio por cambio discreto de etapa. Campos con validación contextual/shake; sin extender el toast del editor de mascotas al reporte. Publicar conserva etiqueta con shimmer durante trabajo real. Consultas con skeleton inicial; refresh conserva contenido con progreso fino y fallo contextual. Renders con tipografía real revisados en `build/ui-preview/cases`: carga, fallo de consulta, vacío, formulario, preview, fallo de publicación, acciones, confirmado y ficha pública, en390×844 y320×350 texto2. Fixtures sin fotos/cartografía real no acreditan descarga ni rendimiento Android.
- SQL048–051/plan013 generan migración `20261010001300_lost_cases.sql`, `patchs/013_patch_lost_cases.sql` y run_all con scripts. RPC obtiene actor de auth.uid(), bloquea mascota y valida propiedad/versión/disponibilidad/campos/fotos procesadas. Índice único parcial impide otro perdido activo; reintento idéntico devuelve el mismo caso. Publicación/evento/historial/contador/versión se actualizan en una transacción; archivo y eliminación respetan esos indicadores. Migraciones previas intactas; la013 nueva todavía no se ha aplicado remotamente.
- Tabla fuente privada y evento sin DML cliente. Proyección pública solo de caso activo, ficha permitida, fecha y centro de celda de0.01 grados; punto y referencia exactos no se proyectan. Solo derivados elegidos/publicados/verificados admiten lectura pública; originales/fotos restantes conservan privacidad. Buckets privados, guards de escritura independientes para anónimo y URLs firmadas300s; enlaces existentes pueden sobrevivir ese plazo tras revocar nuevos accesos. Rutas contienen UUID técnicos, sin perfil/ubicación. ADR-021 registra límites, retirada vigente de fotos y PostGIS/cercanía diferidos a HU-07.
- Validación final: formato lib/test **313 archivos sin cambios**, `flutter analyze --no-pub` sin incidencias; suite completa secuencial `flutter test --no-pub --concurrency=1`: **234 pruebas aprobadas** (log local en build/lost-cases-tests.log). **9 pruebas nuevas** de dominio, reintento ambiguo/dobles envíos, sesión/resultado tardío/recuperación, refresco retenido, lectura actual de mascota, error frente a ausencia, dos tamaños, entrada real/descartar/rutas protegidas y adaptador HTTP del SDK. Capturas finales aprobadas; comprobaciones arquitectónicas existentes incluyen el módulo nuevo.
- `npm test` en database/tests: **16 pruebas SQL locales aprobadas**. Nueva cobertura de A/B/anónimo, rechazo de NaN/futuro/selección inválida/foto no procesada, único activo, conflicto y reintento sin duplicar evento, historial/contador, archivo/borrado protegidos, proyección sin campos privados, bytes elegidos y guards contra políticas amplias incluso con grants de escritura anónima. Repetición de patch/run_all conserva casos/eventos. PGlite representa metadata de Storage y serializa comandos; no acredita concurrencia con conexiones PostgreSQL independientes ni bytes remotos.
- Documentación de arquitectura/diseño/guía/backlog/configuración/SQL y ficha [Casos perdidos](funcionalidades/casos-perdidos.md) actualizada y enlazada. Regeneración de patch013 verifica correspondencia con fuentes; enlaces locales nuevos comprobados y `git diff --check` correcto.
- Pendiente: aplicar patch013 completo sobre012 en desarrollo, actualizar/reconstruir Android y demostrar publicación/reapertura/reinicio, selección manual sin GPS, permisos A/B/anónimo, doble publicación concurrente, fallo/reintento y Storage real con originales privados. No se ejecutó build/instalación Android ni verificación remota autenticada; no se cierra HU-05 por evidencia local. Siguiente paso concreto: seguir la sección HU-05 de CONFIGURACION, probar Reportar → Mascota perdida y Mis casos, y después continuar HU-06 (mascota encontrada).

- Comprobación posterior: Mis casos muestra nombre de mascota y estado de búsqueda, sin identificadores técnicos en las filas. Fuente SDK consulta proyección propia limitada con pet_name; adaptador comprobado. Pruebas finales pertinentes **14 aprobadas** (casos/SDK/arquitectura), más repetición del test SDK con consulta de lista, formato y análisis correctos. Se conserva la evidencia de la suite completa234 y16 SQL.

## Confirmación de patch013 y siguiente funcionalidad — 10 de octubre de 2026

- El usuario confirmó que ejecutó patch013. Aplicación informada por el usuario, sin verificación remota del agente. La demo Android/Supabase y las comprobaciones reales de publicación, permisos, reintentos y Storage siguen pendientes; esta confirmación no cierra HU-05.
- Siguiente incremento del sprint S3: **HU-06 / RF-06 — Publicar una mascota encontrada**, issue **#6**. Publicación sin propietario conocido ni perfil de mascota previo, con fotos seguras, rasgos, fecha/hora, zona manual y custodia opcional; ubicación pública aproximada, vista previa y reintentos idempotentes. No asigna propietario ni vincula por similitud visual.
- Rama actual feature/lost-pet-cases y cambios conservados. Consulta y actualización documental; no se inicia HU-06 ni se crea otra rama, commit, publicación o despliegue.

## Publicación de mascotas encontradas — HU-06 / RF-06 — 10 de octubre de 2026

- Trabajo autorizado en `feature/found-pet-cases`, creada conservando HU-05 y sobre el commit existente `2846b51`. No se hizo commit/push/PR, merge, cambio GitHub, aplicación SQL ni despliegue remoto en este incremento. Patch013 ejecutado según la confirmación anterior del usuario; no se reescribieron fuentes/migraciones aplicadas.
- Reportar activa Mascota encontrada y Mis encontrados. Formulario Reportar hallazgo sin consultar mascotas propias, con especie/rasgos/fotos/fecha/hora/lugar manual obligatorios, tamaño/sexo/custodia opcionales, referencia privada, vista previa pública y confirmación. No se crea mascota ni se infiere propietario/vínculo. Ficha pública y listado Mis reportes recuperan publicaciones; pendientes se distinguen de activos y requieren confirmar su descarte.
- Clean Architecture por found_cases, ViewModels autoDispose con casos de uso/contratos, DTO/data source/repositorio e inyección bootstrap/main. Galería/normalización y CaseScreenShell pasan a core con compatibilidad de imports previos. Borrador local en memoria, recuperación nativa de selección interrumpida con marcador separado; persistencia offline sigue HU-15. Respuesta ambigua congela UUID/comando/bytes y bloquea edición/doble envío; cambios de identidad y disposición descartan resultados tardíos, y sesión igual recupera tras error.
- SQL052–055/plan014 generan `supabase/migrations/20261010001400_found_cases.sql`, patch014 y run_all. Reportero autorizado, pet_id nulo protegido por restricción, fotos elegidas/UUID/hash verificadas solo por servicio, fecha/punto/campos/permisos comprobados en servidor. Creación/cuota se serializan por actor; publicación/evento deduplicados por UUID y confirmados atómicamente. Pendientes privados, proyección sin perfil/punto exacto/referencia, celda aproximada0.01 y solo derivados activos seleccionados. RLS/grants/guards separan filas/columnas/bytes y resisten políticas amplias. Firmas300s con límites registrados en ADR-022.
- Descarte comprueba ausencia en ambos buckets antes de marcar discarded/liberar cuota. Conserva tombstones privados para rechazar resurrección y limpiar workers tardíos; la lista oculta descartados limpios y muestra limpieza pendiente si aparecen bytes. El handler limpia escritura parcial al detectar foto retirada; errores permiten repetir limpieza autorizada. Límites10 drafts por cuenta/30 reservas de foto por draft, sin limpieza automática ni metadatos inventados.
- Endpoint existente `pet-photo-process` ampliado con x-found-case-id incompatible con x-pet-id. Auth/propiedad antes de decodificar; mismo procesador real orienta/decodifica/elimina EXIF/GPS, con buckets propios privados found-photo-renditions/found-photo-thumbnails, sin almacenar originales. Contrato/rutas de fotos de mascotas conservados. Paquete self-hosted actualizado preparado en `work/dokploy-photos/entrehuellas-functions.tar.gz`; sin Edge Function nueva ni cambio del router/despliegue.
- Validación Flutter: formato lib/test334 archivos sin cambios; análisis sin incidencias. Suite completa secuencial **245 pruebas aprobadas** en build/found-cases-tests.log; refinamiento posterior de lista/tombstones/descarte validado por **16 pruebas pertinentes** (casos encontrados/SDK/arquitectura). Las **11 pruebas nuevas** cubren dominio/metadata/bytes, cancelación/límite, reintento congelado/doble envío, identidad tardía/recuperación, refresh retenido, rutas reales/protección/descartar, pendientes/limpieza, dos tamaños y SDK. Renders con fuentes reales revisados en build/ui-preview/found-cases,390×844 y320×350 texto2, con repintado completo para captura fiable; datos/fotos/cartografía de fixture no acreditan bytes remotos ni rendimiento Android.
- SQL: **17 pruebas locales aprobadas** por npm test, incluido upgrade/repetición de patch/run_all sin alterar publicaciones/eventos, A/B/anónimo, ausencia de mascota/inferencia, campos/punto/fecha, atestación/hash, exposición aproximada, políticas amplias/grants de escritura, descarte/reintentos y ledger ante bytes tardíos. PGlite representa metadata de Storage y ejecuta comandos seriales; falta concurrencia con conexiones PostgreSQL independientes.
- Deno2.2.12: formato/check correctos y **14 pruebas aprobadas** (3 procesador real,8 handler,3 router). Casos sin pet, autorización antes de bytes, contexto incompatible, buckets propios, reintento/hash, falla Storage y limpieza de escritura parcial retirada. Mantiene eliminación real de EXIF/GPS y pruebas del contrato de mascotas. Paquete regenerado tras el último cambio del handler y migración/patch comprobados contra sus fuentes.
- Documentación de funcionalidad/index/backlog/guía/arquitectura/diseño/configuración/SQL/Edge e inicio/fotos actualizada; [ADR-022](decisiones/022-publicacion-casos-encontrados.md) y [Casos encontrados](funcionalidades/casos-encontrados.md) registran decisiones, permisos, recorrido y límites. Issue#6 permanece abierto con snapshot remoto Backlog; implementación local no cierra historia.
- Pendiente: aplicar patch014 completo y actualizar el handler existente en Supabase self-hosted, actualizar/reconstruir Android y demostrar publicación de una cuenta sin mascotas, reinicio/reapertura, GPS/cámara denegados, permisos A/B/anónimo y bytes privados/públicos reales, fallo/reintento concurrente y limpieza real. No se ejecutó build/instalación Android ni verificación remota autenticada. Siguiente paso concreto: activación/demo de HU-06 según CONFIGURACION; siguiente funcionalidad de S3 es HU-07 / RF-13 (exploración lista/mapa/filtros/cercanía).

- Revisión final: título de lista Mis reportes mantiene palabras completas con texto2; repetición de las2 pruebas de renders aprobada tras el ajuste. Formato334 archivos sin cambios/análisis limpio y16 pruebas pertinentes aprobadas; enlaces locales nuevos19 y hashes de las4 fuentes del plan014 comprobados, git diff --check correcto.


## Corrección de feedback de reportes y activación informada — 10 de octubre de 2026

- El usuario confirmó ejecución de patch014, subida del paquete y comandos de copia/extracción en el servidor. Evidencia informada por el usuario; no se verifica remotamente desde el agente ni se da por confirmado el reinicio de functions/publicación autenticada. No requiere repetir SQL/paquete por esta corrección de presentación.
- Se conserva feature/found-pet-cases y todo el trabajo local anterior. La captura corresponde a HU-05: rechazo photosUnverified bajo Publicar caso. Error movido al toast superior, con texto breve; fotos antiguas no se reprocesan por actualizar el handler.
- Reportes perdidos/encontrados: validación/operación/consulta/refresco/fotos y éxito confirmado usan toast superior compartido, sin mensajes dentro del contenido ni debajo de campos/acciones. Se conservan invalid/ShakeField, reintentos, datos de publicación e instrucciones de privacidad. Un nuevo toast sustituye el visible; eliminación del host anterior no retira el aviso nuevo. ADR-023 actualiza normas, AGENTS y fichas. La decisión deja de limitar el toast a excepciones; no se declara migrada toda la UI antigua.
- Pruebas de rechazo photosUnverified expresamente en ambas dimensiones, ubicación fuera del scroll, cierre, repetición y expiración; captura incluye ahora overlay. Protección estática contra errorText/Text(FailureLabel) en pantallas de reportes. Renders390×844 y320×350/texto2 revisados; se acortó el aviso de fotos y corrigió apilamiento de avisos encontrado visualmente. Fixtures no prueban fotos/permisos remotos.
- Validación final: formato lib/test335 archivos; análisis sin incidencias; **28 pruebas pertinentes aprobadas** (reportes perdidos/encontrados, arquitectura y toast), más **4 pruebas de renders aprobadas** tras corregir el apilamiento. git diff --check correcto. Aviso único revisado en320×350/texto2 y390×844. No se cambia SQL/Edge ni se realiza commit/push/build Android/despliegue. Siguiente paso: recargar/reconstruir app y probar fotos/publicación autenticada; HU-07 sigue después de la demo de HU-06.


## Espera de publicación de perdido — 10 de octubre de 2026

- El usuario mostró shimmer prolongado al publicar HU-05 y posteriormente toast de fallo genérico. La espera terminó con fallo; captura no identifica causa remota. Se comprobó que la RPC/espera cliente no tenían límite explícito.
- SupabaseLostCaseDataSource limita publicación a30s; CaseEditorViewModel aplica respaldo35s, dominio distingue timedOut. Resultado ambiguo conserva comando/UUID, bloquea modificación, permite reintentar/consultar Mis casos y no considera cancelada la escritura remota. Respuesta tardía no reemplaza un resultado posterior. Error mediante toast superior; diagnóstico seguro solo código/tipo, sin payload ni datos SDK sensibles.
- Emulador5554 disponible; inspección de logs no encontró excepción Flutter de publicación. Auth/settings respondió200 y consulta anónima de lost_cases401/code42501 en menos de1s desde este equipo, coherente con permisos privados; no se usó sesión/credenciales de usuario ni se ejecutó publicación remota por el agente. No acredita conectividad del emulador o éxito de RPC autenticada.
- Se intentó sincronizar por attach/hot reload. Posteriormente la sesión de depuración perdió el isolate principal (Could not prepare isolate); se recompiló/reabrió la app. Gradle falló inicialmente con Unable to establish loopback connection/UnixDomainSockets Invalid argument en Windows. La compilación se completó usando un directorio Unix-domain ausente solo en JAVA_TOOL_OPTIONS de ese proceso, provocando el fallback TCP del JDK; no se cambió configuración permanente ni archivos Gradle. APK debug construido e instalado correctamente en emulator5554, VM/app iniciadas. El borrador en memoria de la ejecución previa se pierde; consultar Mis casos antes de recrear. No se cambió SQL/Edge ni se desplegó backend. Pendiente diagnóstico del siguiente intento autenticado del usuario para identificar la causa del fallo remoto.
- Validación: formato y análisis sin incidencias; **16 pruebas pertinentes aprobadas** (perdidos/SDK/arquitectura), incluido Future sin respuesta, doble envío, timeout, comando idéntico al reintentar y respuesta tardía ignorada. Se conserva feature/found-pet-cases y trabajo anterior, sin commit/push.

- Escucha temporal de Logging en la VM sin nuevos diagnósticos de publicación durante el intervalo posterior a recuperar la app. La pregunta de resultado del reintento queda pendiente; no se afirma resuelto el fallo remoto. Flutter run se desacopla dejando la app ejecutándose.

## Diagnóstico de bloqueos de publicación — 10 de octubre de 2026

- El usuario confirmó repetición del fallo y aportó `Publication response deadline exceeded`. Perfil temporal de red en el emulador: conexión/envío completos en aproximadamente230ms, cuerpo304bytes y ninguna respuesta HTTP. No se registraron headers, credenciales, cuerpo ni datos del reporte en archivos/salida del diagnóstico.
- Con la misma sesión, consulta privada responde200 en aproximadamente1s y RPC con IDs nulos responde400/23514 sin escribir. Repetición del comando exacto que el usuario autorizó al publicar (mismo UUID para deduplicación) desde el equipo también venció a40s; consulta del UUID devuelve cero filas en ese momento. Probes garantizados sin publicación: mascota inexistente responde403/42501 en618ms y misma mascota con versión-1 vence a15s. Esta evidencia acota la espera al acceso bloqueante de la mascota; no acredita publicación.
- El usuario ejecutó diagnóstico ampliado: varios backends PostgREST14.12 esperando `Lock / tuple` y una cadena de `blocked_by`. Primer script tenía dos resultados y SQL Editor mostró solo el último; reemplazado por una única tabla con candidatos de origen, sin texto SQL ni datos de cuenta. Las capturas no identifican todavía un origen estable: un candidato está también esperando tuple y los estados cambian entre lecturas.
- Preparada recuperación operacional `database/tests/cancel_stalled_lost_case_publications.sql`: cancelación de consulta, limitada a PIDs observados, aplicación PostgREST y publicación activa esperando Lock. No termina conexiones ni forma parte de migraciones. Resultado de ejecución por el usuario pendiente; el agente no ejecutó cancelación remota ni eliminó datos.
- Plan015/fuente056/patch015 añade lock_timeout5s local a publish_lost_case. Preserva search_path, SECURITY DEFINER, validación, RLS/grants, orden de bloqueo, escritura atómica e idempotencia; no modifica SQL aplicado. run_all regenerado por su script, con límite reaplicado después de las definiciones previas. No libera RPC antiguas: requiere recuperación operacional separada. La app mapea55P03 a busy y lo muestra solo en toast superior; rechazo confirmado permite editar/reintentar, mientras timeout cliente conserva comando congelado.
- Validación: formato correcto, análisis sin incidencias, **16 pruebas Flutter pertinentes** y **18 SQL locales aprobadas**. SDK cubre55P03 sin propagar detalles privados; SQL verifica configuración local/restauración, permisos conservados, repetición de patch/run_all y ausencia de escritura al rechazar. PGlite no prueba concurrencia con conexiones independientes. git diff --check corregido tras retirar línea final vacía documental.
- Pendiente aplicar patch015, obtener resultado de cancelación/diagnóstico y confirmar una publicación real/reapertura. No se cerró HU-05/#5 ni se hizo commit/push/despliegue remoto. Se conserva feature/found-pet-cases y todo el trabajo anterior.

- El usuario confirmó `cancellation_requested=true` para PIDs474663 y476153. Es aceptación de señales de cancelación, no evidencia de que desapareció toda la cadena ni de publicación confirmada. Pendiente salida posterior del diagnóstico y confirmación de aplicación de patch015; no se solicita un nuevo envío mientras esa comprobación falta. El cambio Flutter se recargó correctamente (22 bibliotecas) y la sesión de depuración se desacopló conservando la app; perfil HTTP temporal desactivado y limpiado.

- Confirmación posterior del usuario: patch015 aplicado completo. Diagnóstico conserva PID473812 de PostgREST en idle in transaction, identificado como raíz, y PID475133 con blocked_by473812. Cancelar consultas no cerró esa transacción. Preparado `database/tests/release_idle_lost_case_blocker.sql`: solicita terminar únicamente PID473812 si sigue siendo PostgREST de esta base, idle in transaction, sin bloqueadores propios y bloqueando otra sesión; si cambió el estado no actúa. Terminar revierte trabajo no confirmado de esa sesión. Es recuperación operacional separada; no se amplía a otros PIDs ni se cambia esquema/permisos. Pendiente ejecución por el usuario, diagnóstico sin cadena y consulta/publicación real. No se ejecutó terminación remota desde el equipo; comprobación local limitada a revisión del SQL y git diff --check, sin nueva modificación Flutter ni repetición innecesaria de suites.

- Nueva salida del usuario conserva cadena con PID476066 idle in transaction (aborted), PID475133 idle in transaction/begin y PID473812 activo; no acredita terminación previa ni limpieza. Los estados cambiantes impiden escoger un PID estable para repetir cierres. Preparado `supabase/self-hosted/restart-rest-connections.sh` para reiniciar únicamente un contenedor rest/PostgREST del proyecto Compose entrehuellas-supabase-bmcwgm, con rechazo si faltan/sobran coincidencias o imagen inesperada. Restablece conexiones del servicio e interrumpe operaciones API pendientes; no reinicia PostgreSQL ni otros servicios, no altera esquema ni reaplica patches. Recuperación recomendada, no causa definitiva acreditada. Pendiente ejecución remota y diagnóstico limpio seguido de consultar Mis casos/reintentar una sola vez si no existe publicación. No se ejecutó reinicio de servidor desde el equipo.

## Reconsulta de fotos en Android — 10 de octubre de 2026

- El usuario objetó la sucesión de consultas/cierres y la propuesta de reiniciar servicios de Dokploy. Se retiran esas indicaciones como siguiente paso del incidente: no pedir nuevas consultas SQL, cierres ni reinicios sobre la misma evidencia incompleta. Los scripts operacionales conservados documentan propuestas anteriores, no instrucciones vigentes ni prueba de recuperación. Patch015 aplicado por el usuario; no se revierte ni reescribe SQL aplicado.
- Captura posterior del usuario: toast No se pudieron consultar las fotos en Editar mascota. Comprobación con la sesión del emulador, sin publicar/guardar/eliminar: list_pet_photos responde200/647ms con dos fotos; firma de original y derivados responde200/302–320ms. Solo se emiten códigos/tiempos/conteos; no se guardan tokens, payloads, identidades ni URLs firmadas.
- Ejecutada la misma reconsulta initialize(true) del ViewModel existente en la VM del emulador: perfil de red confirma list_pet_photos y todas las firmas200; render posterior muestra fotos y desaparición del estado de error/bordes rojos. No se cambiaron metadatos ni se hizo Guardar. Captura local ignorada por Git en build/photos-current.png. Perfil temporal desactivado y limpiado al terminar. No se modificó Flutter ni se reinició/reconfiguró Dokploy/Supabase.
- La recuperación de lectura no demuestra publicación: una comprobación con versión imposible y parámetros inválidos, sin posibilidad de insertar caso, sigue venciendo a10s. Causa definitiva y publicación real permanecen pendientes. Compose local solo referencia POSTGRES_HOST/POSTGRES_PORT por variables; no demuestra el destino efectivo de las conexiones desplegadas. No se solicita al usuario otra tanda de diagnósticos ni reinicio. Validación de esta intervención: lectura HTTP autenticada real, reconsulta Android y captura; git diff --check. Suites anteriores16 Flutter/18 SQL no se repiten porque solo se actualiza documentación.

## Aviso de fotos durante Guardar — 10 de octubre de 2026

- El usuario precisó que el aviso aparece al guardar la foto. La lectura recuperada anteriormente no resuelve ese incidente. Se elimina la inferencia de operación a partir de fotos pendientes: PetPhotosState conserva explícitamente load/choose/save para el fallo, de modo que un guardado fallido no se presenta como una consulta fallida cuando se consumen borradores. Los errores de galería de detalle también usan el toast compartido, sin bloque de error contextual. Se mantienen shake, reintento de lectura y IDs estables de guardado.
- La fuente Supabase registra únicamente operación, familia de excepción y código normalizado; nunca mensajes SDK, fotos, rutas ni credenciales. StorageException se traduce por código a fallo de dominio, incluyendo rechazo de permisos. No se añade patch, cierre de sesión SQL ni reinicio de Dokploy.
- Validación: análisis sin incidencias y **23 pruebas Flutter pertinentes aprobadas**, incluyendo recuperación de consulta, aviso de guardado sin borradores, rechazo de firma Storage403, reintentos y arquitectura. Recarga en caliente rechazó el nuevo campo de estado; reinicio de la app de desarrollo aplicado tras comprobar formulario sin cambios ni fotos pendientes. Galería real del emulador vuelve a mostrar dos fotos; lista y firmas respondieron200. Esto no acredita subida ni Guardar.
- Siguiente paso: capturar el intento de guardar la foto del usuario con el registro activo. Causa del fallo remoto y guardado confirmado siguen pendientes. Se conserva feature/found-pet-cases y los cambios anteriores, sin commit/push ni despliegue remoto.

- Revisión posterior tras reclamación del usuario: estado real de Android conservaba issue=unavailable/failedOperation=save, sin subidas, retiradas ni selección de principal pendientes. Esto confirma feedback de guardado, pero no identifica el paso que lanzó el fallo ni permite repetir el comando anterior desde ese estado. Lectura del mismo ViewModel respondió200 en lista/firmas y conservó dos fotos. Revisión del diff identifica selector compartido y ampliación del handler para HU-06; paquete local y fuente del handler tienen el mismo SHA256. **11 pruebas locales del procesador/handler aprobadas**, incluidas operaciones de mascotas y encontrados. No prueban el worker desplegado ni resuelven el guardado del usuario. No se ejecutó escritura remota, nuevo patch ni reinicio; no se revierte código a ciegas. La causa remota sigue pendiente y la lectura no se presenta como reparación. Perfil temporal de red desactivado y limpiado al terminar la revisión.

## Causa capturada y corrección del guardado de fotos — 10 de octubre de 2026

- HU-03.2/#29 y HU-04/#30/#31, rama feature/found-pet-cases; conservado todo el trabajo previo. El nuevo intento del usuario se capturó con breakpoint temporal en el catch de savePendingChanges: excepción real **CircularDependencyError** de Riverpod, cadena correspondiente a PetDetailViewModel. No era una respuesta del SDK en ese punto. Breakpoint retirado y ejecución reanudada.
- PetDetailViewModel observa el notifier de fotos; la invalidación de la ficha desde ese mismo notifier introducía dependencia inversa. Tras retirada o principal confirmadas, los pendientes se consumían y luego la invalidación fallaba, impidiendo confirmar el editor y mostrando toast de guardado. Eliminadas esas dos invalidaciones: galería conserva actualización de estado/listado, editor conserva coordinación de refresco de ficha. Sin cambios visuales, SQL, Edge, despliegue ni reinicio del backend.
- Tres pruebas nuevas mantienen ficha, editor, galería y listado observados durante retirada, principal y reemplazo. **Las tres fallaron antes de la corrección y pasan después**. Suite pertinente **34 pruebas aprobadas** (fotos, principal/cámara, feedback, salida del editor, adaptador SDK y arquitectura); flutter analyze --no-pub sin incidencias, formato de los dos archivos modificado correcto y git diff --check sin errores.
- Cambio cargado con hot reload en emulator-5554: una biblioteca actualizada, sin reiniciar ni perder formulario/sesión. Antes de reconsultar se verificó ausencia de borradores, retiradas o principal pendientes y busy=false. Esto corrige el error local capturado; falta confirmar el siguiente guardado integrado y no acredita todos los criterios remotos HU-04. Sin commit/push ni acciones GitHub.
- Siguiente paso: probar cambio/adición de foto y Guardar cambios en la app ya actualizada, comprobar salida y reapertura. La ficha de fotos registra la causa y corrección; no repetir patches ni redeploy para este fallo de Riverpod.


## Reutilización real de reveal, confirmaciones y fotos del reporte — 10 de octubre de 2026

- Rama feature/found-pet-cases y trabajo previo conservados. El usuario detectó reveal repetido de Mascota perdida, confirmaciones inconsistentes y sobrecarga por coordenadas/fotos verticales. Causa del reveal: resolver carga cambiaba stage initial a editing; AuthStageTransition creaba nueva clave/cortina y perdía el historial de skeleton de ContentReveal. Ahora pasar de enabled=false a contenido conserva el subárbol, sin cover/stagger nuevo; vista previa/confirmación siguen animándose. Dos regresiones con respuesta50ms/2000ms fallan antes de la corrección y pasan después.
- Confirmaciones completas centralizadas en core/confirm_action_dialog.dart a partir del diálogo de eliminación existente: ruta, superficie/transición, cabecera/cierre, scroll y botones iguales dentro de la pareja, a la derecha y adaptables al ancho/texto. Descartar reporte/zona/preferencias y salir/eliminar/archivar mascota delegan en el mismo componente; wrappers solo aportan contenido/semántica/origen y carácter destructivo. Test arquitectónico impide crear rutas booleanas de confirmación fuera del componente. Ocho comprobaciones de cancelar/confirmar y geometría en390×844 y320×350 texto2; renders con fuentes reales revisados.
- Por instrucción del usuario, reporte perdido elimina entradas/lectura numérica de coordenadas y método textual del ViewModel; lugar mediante toque de mapa, sin GPS, con contrato de punto privado intacto. PhotoGalleryStrip/PhotoGalleryTile extraídos de PetPhotoGallery y reutilizados por ficha/editor de mascotas y formulario/vista previa de perdido: fotos cuadradas112–160, scroll horizontal, separación10/radio22. Selección pública se mantiene en el ViewModel del reporte; estrella identifica principal y casilla accesible selecciona publicación, sin etiquetas estrechas sobre imagen con texto2. Ninguna selección de reporte modifica las fotos privadas.
- Validación: conjunto afectado de12 archivos de prueba, **83 pruebas aprobadas**; después del ajuste final de accesibilidad de selección, suite pertinente de perdidos/fotos/salida/feedback/arquitectura **37 pruebas aprobadas**. Dos pruebas nuevas del reporte cubren ausencia de campos numéricos, deslizamiento/selección de tercera foto, actualización desde mapa y vista previa de solo elegidas, en ambos tamaños. Renders finales form/galería/vista previa y diálogos revisados; fixtures sin bytes de fotos/cartografía reales no prueban descargas ni backend. Formato lib/test:339 archivos sin cambios. `flutter analyze --no-pub` final sin incidencias; `git diff --check` correcto con tratamiento CRLF de Windows.
- Actualizadas reglas/diseño/guía y fichas de funcionalidades intervenidas. No se modifican SQL, Edge, permisos ni persistencia. Sin commit/push/despliegue ni nueva instalación/recarga Android en esta intervención; pendientes revisión integrada con fotografías/teselas reales y resolución del fallo remoto de publicación previamente documentado. Siguiente paso: cargar estos cambios y verificar Reportar → Mascota perdida, seleccionar fotos deslizando, marcar mapa, revisar y confirmar salida; no repetir patches o reinicios de backend para estas correcciones visuales.


## Vista previa con foto protagonista y descripción expandible — 10 de octubre de 2026

- Por imagen e instrucción del usuario, se adapta la vista previa de publicación de perdidos/encontrados a una composición inmersiva: fotografías a ancho completo deslizables con indicadores, nombre/especie destacado sobre imagen y panel inferior glass con datos disponibles y acciones reales. Rama feature/found-pet-cases y todos los cambios previos conservados. La ficha pública y la galería del formulario mantienen sus componentes existentes.
- CasePublicationPreview de core es único para ambos reportes; compone GlassSurface existente y las acciones del ViewModel con primaryActionButtonStyle/LoadingShimmer existentes. CaseScreenShell conserva GlassNavigationButton, toast, scroll y cover→stagger; vista previa cambia únicamente su composición a borde completo. Cabecera flotante glass permanece fuera del efecto y legible al desplazar el panel. No se crean favoritos/precio/peso/venta ni se inventan datos de encontrados.
- ExpandableDescription compartido mide si el texto supera dos líneas y habilita tocar texto/indicación para expandir/contraer. La altura cambia suavemente320ms/easeInOutCubic, sin nuevo reveal y conservando foto/estado. Movimiento reducido presenta texto inmediato: se evita AnimatedSize con duración cero porque las pruebas de layout revelaron una aserción de RenderAnimatedSize; ambas variantes pasan con la composición final. No cambia validación, dominio, RPC, permisos, procesamiento de fotos ni persistencia.
- Validación final: **42 pruebas Flutter aprobadas** en vista previa/perdidos/encontrados/carga/arquitectura; log local build/preview-final-tests.log. Cuatro pruebas nuevas comprueban pager y selección mantenida, alturas contraída/intermedia/expandida, contracción, ausencia de cover repetido, publicación alcanzable mediante scroll, texto2 y movimiento reducido en390×844 y320×350. Las pruebas de reporte verifican que el preview perdido recibe solamente las fotos elegidas; se conservan pruebas de publicación/reintentos/sesión/errores de ambas funcionalidades.
- Capturas de variantes contraída/intermedia/expandida en build/ui-preview/publication-preview revisadas con fuentes reales; imagen ilustrativa existente y segunda imagen uniforme como fixtures, sin incorporarlas como datos de producto. Renders de flujos en build/ui-preview/cases y found-cases revisados; sus fixtures de bytes/teselas no acreditan acceso remoto. Formato lib/test:342 archivos sin cambios; flutter analyze --no-pub sin incidencias; git diff --check correcto con tratamiento CRLF.
- ADR-024 documenta la aprobación específica del usuario, composición compartida y accesibilidad. Reglas/diseño/guía/arquitectura y fichas de perdidos/encontrados actualizadas; composición anterior de tiles en vista previa sustituida, galería del formulario conservada. Sin commit/push/despliegue ni build/recarga Android en esta intervención. Pendiente cargar el código actualizado y revisar con fotos reales los dos previews, descripción larga y publicación; el fallo remoto previo de publicación de perdido sigue pendiente y esta corrección visual no lo resuelve.


## Franja inferior y continuidad del scroll — 10 de octubre de 2026

- El usuario muestra una franja blanca que corta Referencia privada del lugar antes del indicador del gesto, y señala repetición en varias pantallas. Causa localizada: SafeArea(bottom:true) envolvía el viewport, reservando el inset fuera del scroll sobre Scaffold blanco. Se conservan rama feature/found-pet-cases y todo el trabajo previo.
- ScrollSafeArea de core unifica viewport completo y estilo de barra del sistema transparente/divisor transparente/sin contraste opaco. Inset inferior pasa al padding final y a acciones flotantes; teclado usa padding efectivo para no duplicarlo. Adoptado en CaseScreenShell, PetScreenShell, AppPageLayout, perfil, zonas, preferencias e Inicio. Home conserva navegación por encima del gesto; acceso conserva anclaje descontando inset del cálculo. Preview extiende foto al borde y mantiene panel/acciones seguros. Modales y onboarding conservan sus áreas específicas.
- Validación: **6 regresiones nuevas aprobadas** de viewport/píxeles inferiores y acción final en reporte/mascota/acceso, con inset34 y teclado; **89 pruebas de flujos afectados aprobadas** en14 archivos. Renders de preview con insets reales simulados24/34 y390×844/320×350 texto2/movimiento reducido: **4 pruebas aprobadas**, capturas revisadas en build/ui-preview/publication-preview. Estos4 casos forman parte de la cobertura de preview y se repitieron para la revisión visual; no se presentan como89+4 pruebas distintas.
- Formato lib/test:344 archivos sin cambios; flutter analyze --no-pub sin incidencias; git diff --check correcto con tratamiento CRLF. Logs locales insets-regression-tests.log, insets-flow-tests.log e insets-render-tests.log en build. Tests de píxeles comprueban la continuidad Flutter, no la barra nativa del SO.
- ADR-025, reglas/diseño/guía/arquitectura, índice y fichas intervenidas actualizados. Sin cambio de dominio, SQL, Edge, dependencias, configuración nativa, commit/push/despliegue o instalación/recarga Android. Pendiente cargar el código y revisar scroll hasta el borde, navegación por gestos/tres botones, teclado y contraste de indicador en Android; iOS real no probado. Esta corrección no confirma solución del incidente remoto de publicación de perdido.


## Ficha pública consistente y formulario simplificado — 10 de octubre de 2026

- Por instrucción del usuario se retiran Volver a consultar fotos y Mis casos del formulario de perdida. Se conserva Editar mascota y fotos y la recuperación Consultar Mis casos exclusivamente cuando un envío tiene resultado ambiguo. El acceso normal a las listas sigue desde Reportar.
- Causa de la diferencia visual: el incremento anterior cambió la vista previa pero mantuvo las fichas públicas antiguas. Corregido en perdidos y encontrados: CasePublicContent/FoundPublicContent delegan en el renderer usado por su preview y CasePublicationPreview de core. Comparten pager de fotografías protagonistas, panel GlassSurface, datos y ExpandableDescription. CaseScreenShell permite cabecera Ficha pública; acciones de publicación/edición y advertencia preventiva permanecen en preview. La ficha conserva estado activo, consulta y refresh con progreso fino superpuesto. Se elimina el layout duplicado anterior, sin cambios de dominio, RPC o persistencia.
- Validación final: **42 pruebas Flutter aprobadas** en lost_cases_test, found_cases_test, case_publication_preview_test, content_reveal_test y architecture_test. Las regresiones normal/pequeña con texto ampliado comprueban renderer común, PageView, título público, ausencia de Publicar/Editar en ficha, opciones retiradas y consulta final alcanzable sin overflow. Capturas públicas y acciones revisadas en build/ui-preview/cases y found-cases; los casos públicos usan fixtures sin fotos, la interacción fotográfica y expansión se cubren en el componente compartido. Log build/public-sheet-tests.log. Formato de Dart aplicado; flutter analyze --no-pub sin incidencias (build/public-sheet-analyze.log); git diff --check correcto con tratamiento CRLF.
- ADR-024, reglas/diseño/guía e índice/fichas de funcionalidad actualizados. Rama feature/found-pet-cases y trabajo previo conservados. Sin commit/push/despliegue ni instalación/recarga Android. Pendiente cargar cambios y comprobar fichas con fotografías reales en Android. No confirma cierre de HU-05/HU-06 ni solución del incidente remoto de publicación.


## Ubicación visible, fecha destacada y retiro de título glass — 10 de octubre de 2026

- Por corrección explícita del usuario se elimina la cápsula glass Ficha pública/Vista previa pública de las vistas inmersivas; se conserva el retorno compartido. El título habitual permanece en cargas/errores/formularios. Fecha de desaparición/hallazgo pasa de14 a20px con negrita y ajuste por texto ampliado.
- La unificación visual anterior había omitido la representación de la ubicación y dejado solo privacidad. Corregido en la composición compartida: Zona de desaparición/Zona del hallazgo con ZoneMapPicker existente, círculo aproximado de1000m, modo lectura sin gestos/selección ni marcador de punto exacto. Preview entrega la proyección aproximada existente; ficha entrega coordenadas públicas de su entidad. No se accede a referencia ni punto privado desde esta vista, no se inventa dirección y no se solicita GPS/geocodificación. Formulario conserva su selección manual. Mapa comparte fuente/atribución y reintento; sus errores pasan a toast superior sin texto debajo ni invitación a escribir coordenadas.
- Validación local: **50 pruebas Flutter aprobadas** en perdidos, encontrados, preview compartido, reveal, arquitectura, zonas y mapa. Regresiones confirman coordenadas públicas entregadas al mapa, solo lectura/sin marcador exacto, ausencia del título glass, fecha20/negrita, acciones alcanzables y layouts normal/pequeño con texto ampliado y movimiento reducido. Log build/public-location-tests.log; flutter analyze --no-pub sin incidencias en public-location-analyze.log. Formato de archivos intervenidos sin cambios pendientes; git diff --check correcto con CRLF. Capturas revisadas en build/ui-preview/cases, found-cases y publication-preview; cartografía vacía/transparente en fixtures de pruebas no acredita descarga de teselas reales.
- ADR-024, reglas/diseño/guía e índice/fichas actualizados. Sin cambios de dominio, permisos, SQL o despliegue; trabajo previo conservado. Pendiente cargar versión en Android y comprobar fotos/cartografía reales, scroll y zona aproximada. El incidente remoto de publicación permanece separado y no se afirma resuelto.


## Mis casos con la UI/UX de mascotas y eliminación — 10 de octubre de 2026

- Causa señalada por el usuario: Mis casos/Mis reportes usaban ListTile y acciones grandes inferiores, en lugar de las tarjetas, selector y swipe aprobados de Mis mascotas. Corregido mediante extracción real a core: EntityCardContent/EntityCardSurface, SwipeActionCard, TwoOptionFilter, CollectionHeader/CollectionAddButton. Mascotas conserva wrappers de compatibilidad que delegan en la implementación común; ambas listas de casos usan los mismos componentes, radio22, imagen/tipografía/espaciado, selector adaptable y acción+56. No se importan widgets entre funcionalidades. Se conserva shell/retorno, entrada/reveal y scroll; Abiertos/Resueltos no reinicia toda la pantalla. Borradores encontrados conservan descarte/limpieza con superficie compartida, sin enlace público vacío.
- Eliminar por swipe usa confirmActionDialog y animación de origen existentes. Cancelar conserva registro; al confirmar, ViewModel→DeletePublishedLostCase/DeleteFoundPublication→repositorio→fuente→RPC. Shimmer y bloqueo evitan operaciones duplicadas; error conserva tarjeta y muestra toast/reintento; éxito retira tarjeta e invalida su consulta. Cambios de cuenta ignoran respuestas anteriores. Consultas de lista entregan portada firmada de los derivados seleccionados/verificados disponibles, sin datos simulados.
- Datos: fuentes057(tombstone),058(RPC),059(visibilidad),060(permisos), plan/migración016. Operaciones owner-only/idempotentes para active/resolved; borradores mantienen descarte previo. deleted_at oculta publicación y listas conservando ID/auditoría. Perdido activo libera active_case_count una sola vez, conserva case_history_at/ficha/fotos, respeta orden mascota→caso y permite publicar una nueva pérdida. Consultas permiten al dueño consultar resueltos no eliminados; terceros solo activos. Derivados encontrados se conservan privados como historial, sin purga física en este incremento. URLs ya firmadas tienen vigencia300s existente; no se afirma revocación inmediata. No se introduce GPS ni nuevas columnas públicas privadas.
- Validación final: **53 pruebas Flutter aprobadas** en colecciones, perdidos/encontrados, SDK, mascotas/eliminación/swipe, Inicio, arquitectura y reveal (build/case-collection-tests.log). **10 pruebas de render/confirmación aprobadas** en build/case-collection-render-tests.log: dos de colección repiten las incluidas en53 y ocho del diálogo compartido; total **61 casos distintos**. Normal390×844 y pequeño320×350 texto2 verifican filtros, navegación, cancelar/confirmar, accesibilidad por scroll, conservación ante error, doble envío y cambio de identidad. Capturas con fuentes reales revisadas en build/ui-preview/case-collections; fixture sin portadas no confirma descarga Android, cubiertas comprobadas en SQL/DTO/SDK.
- **19 pruebas SQL/PGlite aprobadas** (database/tests/case-collection-final-tests.log), incluido dueño/otra cuenta/anon, escritura directa denegada, retiro activo/resuelto, reintentos, contador/fotos/historial conservados, publicación nueva tras eliminación, consulta propia de resueltos y repetición de016/run_all sin pérdida de datos. Generadores verifican migraciones anteriores y regeneran run_all, sin modificar fuentes aplicadas;016 se prepara localmente antes de su primera aplicación. flutter analyze --no-pub sin incidencias (case-collection-analyze.log), Dart formateado y git diff --check correcto con CRLF.
- ADR-026, reglas/diseño/arquitectura/guía, configuración e índice/fichas actualizados. Rama feature/found-pet-cases y trabajo previo conservados. Sin commit/push/despliegue/recarga Android. **Activación pendiente: aplicar migración016 sobre013/014/015 y cargar la app actualizada**, luego confirmar portadas y eliminación autenticada en Android/Supabase. Historias HU-05/HU-06 no cerradas por evidencia local; incidente remoto de publicación separado.

## Revisión de código, arquitectura y reutilización — 11 de octubre de 2026

- Solicitud del usuario: analizar el estado actual del código, arquitectura, patrones y duplicación. Rama `feature/found-pet-cases`, incluidos cambios locales previos modificados/no rastreados, conservados. Revisión transversal de HU-01/02/03/04/05/06; sin cierre de historias/issues, commit/push ni acciones remotas. Informe: [revisión completa](revisiones/2026-10-11-codigo-arquitectura-patrones.md).
- Hallazgos: eliminación de caso perdido no sincroniza contador/versión en consumidores de mascotas todavía observados; onboarding importa presentación de Auth y la comprobación de arquitectura no detecta cruces entre funcionalidades; fotos de mascotas conservan colecciones/bytes mutables; marcas de validación de fotos/punto no se consumen completamente en reportes; refresh de listas desplaza contenido y casos no reutiliza la pausa por movimiento reducido de mascotas. Encontrados conserva galería propia y no define deadline de publicación/descarte equivalente al perdido. Duplicación menor de UUID, fechas, preparación de imágenes, proyección aproximada y coordinación de lectura documentada con propuestas específicas, sin clases base genéricas.
- Validación: formato lib/test **354 archivos, 0 cambios**; `flutter analyze --no-pub` sin incidencias. Suite completa **280 aprobadas, 2 fallidas**, repetida para obtener diagnóstico con mismo resultado: `pets_navigation_test.dart` variantes normal/pequeña buscan la clave retirada `pet-deletion-actions` en línea553. Log `apps/mobile/build/review-20261011-tests.log`. **19 pruebas SQL/PGlite aprobadas** mediante `node --test database/tests/run_all.test.mjs`; el primer intento de npm desde database no encontró package.json y se sustituyó por el runner correcto.
- Dos probes locales en `apps/mobile/build/review_20261011_probe_test.dart` confirman lista de mascotas obsoleta tras borrar caso y mutación externa del estado/bytes de fotos; pasan porque verifican esos comportamientos actuales, **no porque estén corregidos**. Archivo en build ignorado, sin añadir pruebas defectuosas a la suite versionada. `git diff --check` sin errores de whitespace, con avisos de conversión LF/CRLF existentes.
- Sin cambios de producción, esquema, permisos, guías de alcance o fichas funcionales: es análisis, no incremento implementado. Solo informe y relevo de estado. No se ejecutaron build/instalación Android, renders nuevos, pruebas remotas ni concurrencia con PostgreSQL independiente. Deno no disponible en PATH; handler/procesador no ejecutados en esta revisión. PGlite no acredita Storage/Edge/RLS remotos ni resuelve el incidente previo de publicación.
- Siguiente paso: actualizar finders de la prueba de navegación conservando sus verificaciones; después corregir sincronización casos→mascotas mediante contratos/inyección y ampliar pruebas de fronteras. Seguir con inmutabilidad, validación/progreso compartido y política de espera de encontrados; priorización y referencias en el informe. Activación pendiente de016 y demo remota mantienen su estado anterior.

## Corrección de consistencia y feedback global — 11 de octubre de 2026

Solicitud del usuario: resolver inconsistencias/duplicación de la revisión actual y usar toast superior para todos los errores/validación/resultados, sin texto bajo inputs ni loaders convencionales. Se conserva el árbol previo de feature/found-pet-cases. No se publicó, desplegó ni actuó en GitHub.

Implementado localmente:
- Feedback global en acceso/registro/OTP/recuperación, entrada/onboarding, perfil, mascotas/ciclo de vida, zonas, preferencias y reportes. APIs de campos sin errorText/helperText; invalid/shake/semántica y reintentos conservados. Toast con altura acotada al overlay/teclado, scroll visible y cierre por superficie para texto ampliado.
- LoadingShimmer/skeleton inicial y ContentRefresh compartido sobre contenido conservado, sin indicadores circulares/lineales. Semántica de contenido separada de acciones; movimiento reducido respetado.
- Sin dependencia onboarding→presentación de auth. Notificación de dominio por cuenta/mascota tras publicar/eliminar perdido confirmado; listas/detalle observados vuelven a leer versión/contador. Suscripciones liberadas.
- Estado y bytes de fotos inmutables; galerías, marcas de fotos/mapa, fechas, IDs, proyección pública, preparación de fotos y finalización de lecturas compartidas. Sin bases genéricas ni reglas de publicación en pantallas.
- Publicación/descarte en editor encontrado con90s global y30s por peticiónSDK, conservando solicitud congelada ante timeout; SQL061/plan017/migración20261011001700 generados para lock_timeout5s. Fuentes/migraciones anteriores comprobadas sin reescribir historial; run_all regenerado.
- Tests de arquitectura amplían fronteras a core y entre funcionalidades; CI backend preparado para SQL/Edge. Edge copia Uint8Array de entrada para compatibilidad de tipos con Deno2.9 sin omitir type checking. Fichas/normas/guía actualizadas; decisiones ADR-027/028.

Validación real:
- dart format:368 archivos, verificación final sin cambios. flutter analyze --no-pub: sin incidencias.
- flutter test --no-pub:291 aprobadas; incluye navegación, cambio de identidad, reintento, arquitectura, sincronización, inmutabilidad y timeout. Tras últimos ajustes de utilidades/selectores:37 pruebas relevantes aprobadas; SDK/validación ampliados:4 aprobadas.
- PostgreSQL local en memoria:20 pruebas aprobadas de permisos/invariantes/repetición; SQL061 no cambia grants, security definer ni search_path y no contamina lock_timeout de sesión. No prueba contención concurrente remota.
- Deno2.9.6: prepare-wasm y check index.ts aprobados;11 pruebas processor_test/handler_test aprobadas con comprobación de tipos. Sin despliegue.
- Capturas normales390×844 y pequeñas320×350 texto2 revisadas en build/ui-preview (casos, encontrados, preferencias y campos). Toast largo ofrece scroll visible; regresión comprueba límite de altura/scroll/cierre. Geometría/semántica de refresh y movimiento reducido probados. Capturas usan sustitutos, sin datos remotos.
- git diff --check sin incidencias. Logs locales ignorados en apps/mobile/build/consistency-*.log.

Bloqueos/límites: APK debug intentado dos veces, falla en Gradle con java.io.IOException: Unable to establish loopback connection; preferIPv4Stack no lo resolvió. No hay APK nuevo ni prueba Android autenticada de este incremento. Migración017 no aplicada; validaciones remotas de incrementos anteriores siguen pendientes. CI está preparado, no ejecutado en GitHub. Los diagnósticos iniciales y su seguimiento están en docs/revisiones/2026-10-11-codigo-arquitectura-patrones.md.

Siguiente paso: resolver conexión local de Gradle para compilar/instalar, activar017 en desarrollo tras los incrementos previos y verificar publicación/descarte bajo bloqueo real, sincronización al eliminar reporte y flujos de feedback en Android autenticado. No cerrar HU por evidencia exclusivamente local.

## Diagnóstico de Mis casos — PGRST202, 11 de octubre

El usuario aporta logs lost_cases con PGRST202. La consulta actual usa public.list_my_lost_case_cards() sin argumentos; el contrato, SQL y grants coinciden en el incremento016. PostgREST define este código como función/signatura ausente en caché o inexistente en base. El estado registrado mantiene016 pendiente de activación, por lo que falta de migración es la hipótesis principal; no se ha comprobado la base remota. Se prepara database/tests/diagnose_case_collection_rpcs.sql, de solo lectura, para comprobar ambas RPC de listas y permisos sin consultar datos personales. Si faltan, aplicar completa migración016 tras sus requisitos; si existen, comprobar caché/esquema y recargar PostgREST. No se aplicó SQL ni se reinició el servidor. La migración017 de lock_timeout no crea estas listas.

## Corrección de skeleton en ficha/vista previa — 11 de octubre de 2026

El usuario señala skeleton incorrecto al ver ficha/vista previa de casos. Se confirmó que las dos fichas montaban SkeletonFormFields (inputs/botón), sin shimmer propio, antes de la composición inmersiva aprobada. Las fotos remotas carecían de estado explícito de carga.

Corrección local: CasePublicSkeleton compartido para perdidos/encontrados, con composición de foto/nombre/panel GlassSurface/datos/mapa y LoadingShimmer. Las fichas mantienen modo inmersivo durante carga inicial, sin cabecera de formulario ni textos de carga. CasePreviewGeometry comparte geometría con el contenido real y la altura del mapa usa la constante de ZoneMapPicker. Navegación glass fuera del efecto. CasePhotoView comparte foto local/remota y shimmer hasta primer fotograma, conserva semántica de foto perdida y delega errores al toast existente. No sustituye refresh conservado ni oculta datos durante un refresh explícito.

Validación:52 pruebas relevantes aprobadas (casos perdidos/encontrados, preview, arquitectura, reveal y6 regresiones nuevas de carga/fotos). Test de preview encontrado decodifica/precachea bytes locales fuera de FakeAsync antes de esperar el fin de animaciones; no se elimina el shimmer para acomodar pruebas. Formato372 archivos sin cambios. Capturas normales390×844 y pequeñas320×350 texto2 en build/ui-preview/case-loading, posición inicial y mapa tras scroll. Se revisan fotos de carga/fotograma/fallo, semántica y navegación. No se compila APK de nuevo: permanece el bloqueo Gradle previamente acreditado. Sin despliegue ni modificación de SQL; PGRST202 requiere aún verificar migración016/caché en servidor.

Verificación final de esta corrección: flutter analyze --no-pub sin incidencias;6 regresiones de carga/foto repetidas con fuentes de captura cargadas, todas aprobadas. Navegación glass y formas de skeleton revisadas en renders finales. git diff --check sin incidencias.

## Apertura de fichas y retirada de consulta manual — 11 de octubre de 2026

El usuario solicita eliminar Volver a consultar de cualquier pantalla y coherencia al abrir mascotas/casos. Diagnóstico confirmado: ruta de mascota usaba OriginPageTransition desde Rect de tarjeta; rutas de detalle perdido/encontrado usaban NoTransitionPage y las tarjetas no propagaban origen.

Implementado: entityDetailPage en app/navigation comparte apertura320ms/retorno260ms y movimiento reducido, conserva entrada directa si no hay tarjeta. Mis casos/Mis reportes capturan el Rect real mediante ManagedCaseCollection y lo pasan por extra; mascotas delega en la misma composición preservando guardado/inspección. No se introducen imports de app desde funcionalidades. Eliminadas las cuatro acciones permanentes Volver a consultar de listas y fichas. Reintentar solo ante error de consulta/actualización; permanecen invalidaciones tras mutaciones confirmadas. Escaneo de arquitectura impide reintroducir el texto en lib. ADR-029, normas/diseño/arquitectura/guía y fichas actualizadas.

Validación:40 pruebas relevantes aprobadas inicialmente y suite completa301 aprobadas posteriormente, incluyendo4 regresiones de apertura real de casos desde tarjeta y retorno durante skeleton. Verifican origen, animación, vuelta a la misma tarjeta/posición y movimiento reducido con texto2. Mascotas mantiene navegación, guardado, inspección, edición y cierre. Capturas normales390×844 y pequeñas320×350 texto2 revisadas en build/ui-preview/case-navigation; renders de fichas de casos regenerados sin acción permanente. Formato374 archivos sin cambios y git diff --check sin incidencias. Evidencia local en build/navigation-consistency-full.log.

Limitaciones: sin APK nuevo por bloqueo Gradle previamente registrado y sin comprobación Android autenticada. No se cambia ni despliega SQL; PGRST202 sigue requiriendo comprobar016/caché del servidor. Siguiente paso: cargar esta versión desde un entorno Android funcional y verificar apertura/retorno y reintento ante fallo real.


## Ficha con panel expandible y badge — 11 de octubre de 2026

Solicitud del usuario: badge Desaparición fuera del panel de datos, indicador para abrir por toque/arrastre, mapa oculto hasta expandir y nombre legible sobre fotos, con salto de línea/elipsis. Implementado en CasePublicationPreview compartido por ficha pública/vista previa de perdidos y encontrados (badge Encuentro). Fondo fotográfico conserva pager; datos se desplazan dentro de DraggableScrollableSheet y el mapa público solo se monta al abrir. Nombre con sombra leve/dos líneas, badge al lado o debajo según texto, indicador táctil48, apertura320ms y gesto sin snap con movimiento reducido. CaseScreenShell acota los datos inmersivos a viewport; formularios/skeleton conservan comportamiento existente. ADR-030, norma UI, diseño, guía y fichas funcionales actualizados. Sin cambios de persistencia/permisos, commit, push ni despliegue; conservado todo el trabajo local previo en feature/found-pet-cases.

Validación: formato de los archivos modificados, flutter analyze --no-pub sin incidencias y50 pruebas relevantes aprobadas (23 de perdidos/encontrados,27 de componente/arquitectura/carga/navegación/consistencia). Las4 pruebas del componente se repitieron tras añadir comprobación de cierre por arrastre: mapa ausente al inicio y tras contraer, apertura por toque/arrastre, pager preservado, nombre largo, descripción expandible, acciones alcanzables, tamaños390×844/320×350 texto2 y movimiento reducido. Capturas regeneradas y revisadas en build/ui-preview/publication-preview con imagen de prueba; teselas transparentes sustituidas en pruebas del componente. git diff --check correcto.

Pendiente: revisión en Android autenticado con fotografías y teselas reales; no se generó APK ni se cierra HU-05/HU-06. Siguiente paso: comprobar gesto/apertura/cierre sobre dispositivo y contraste del nombre sobre fotos reales.


## Corrección: ficha anclada abajo y sombra reducida — 11 de octubre de 2026

El usuario precisa que el bloque debe permanecer al inferior, sin aspecto centrado, y solicita menos sombra. CasePublicationPreview baja el resumen de ficha sin acciones al36% (vista previa46%) y usa SliverLayoutBuilder para que el glass cubra el espacio restante hasta el margen seguro inferior aun con contenido corto. Sombra del nombre reducida de40%/blur8/offset2 a20%/blur3/offset1. Se conserva texto ampliado, nombre en dos líneas/elipsis y apertura/mapa. Fichas funcionales, diseño y ADR-030 actualizados.

Validación: dart format correcto, flutter analyze --no-pub sin incidencias y27 pruebas de componente/perdidos/encontrados aprobadas. Capturas390×844 y320×350 texto2 regeneradas; render normal revisado. Sin APK/despliegue ni confirmación en Android real. Siguiente paso: revisar el anclaje y contraste con las fotos reales del usuario en Android.


## Consistencia de efectos: Casos reutiliza Mascotas — 11 de octubre de 2026

El usuario declara terminada la UI de Mascotas y solicita replicar/reutilizar sus animaciones y efectos en Casos. Diagnóstico: Registrar mascota consumía OriginPageSource/OriginPageTransition; rutas de nuevos casos usaban NoTransitionPage. CaseScreenShell duplicaba el contenedor con otros insets/separaciones. Varias partes de found/lost no estaban en stagger; fotos/tamaño encontrados eran alternativas distintas. ManagedCaseCollection asignaba orden por fila sobre un count fijo.

Implementado: entityEditorPage común y captura del mismo origen desde controles de Inicio/listas; EntityScreenShell extraído del shell de mascotas y adaptadores compatibles; todas las entradas de campos/galería/mapa/coordenadas/custodia/acciones en secuencia existente; cabecera y lista como grupo; PhotoAddTile/SizeChoiceSelector extraídos y usados por mascotas/encontrados. Contador/íconos/espacios de inputs y shimmer/validación de acciones compartidos. Se preserva la UI aprobada de Mascotas, el panel inmersivo y las reglas de publicación/descarte, sin SQL ni imports entre presentaciones. ADR-031/norma/diseño/arquitectura/guía/fichas actualizados. Conservada rama feature/found-pet-cases y cambios locales previos; sin commit, push o despliegue.

Validación: formato15 archivos sin cambios, flutter analyze --no-pub sin incidencias y suite completa flutter test --no-pub:309 aprobadas en build/case-ui-consistency-full.log.8 regresiones de creación desde Inicio y+ repetidas tras reforzar confirmación de salida con scroll (build/creation-effects.log), sin warnings de hit test. Comprueban origen/radio, apertura/retorno, movimiento reducido/texto2, inputs dentro del stagger y timeline conservado al editar. Regresiones de Mascotas incluidas (registro/consulta/edición/reentrada/carga/fotos/tamaño). Capturas de apertura/formulario/cierre normales390×844 y pequeñas320×350 revisadas en build/ui-preview/case-creation. Sin acreditación de fotos/teselas reales; adaptadores/repositorios sustituidos.

El acceso Registrar mascota desde un reporte perdido sin mascotas también reutiliza CollectionAddButton y su fuente visual. Tras ese último ajuste,20 pruebas de perdidos/creación aprobadas en build/creation-effects-final.log.

Pendiente: revisión Android autenticada; no se generó APK ni se desplegó backend. Siguiente paso: verificar la misma secuencia desde Reportar y+ en Android con fotos reales y mapa conectado.


## Reportes: inputs separados de fecha y hora — 11 de octubre de 2026

Implementado pedido de dos inputs Fecha/Hora con AppFieldSurface compartido (normal lado a lado; texto2 apilado), pickers independientes, estado parcial en ViewModels y timestamp solo tras elegir ambos. Cambiar fecha conserva hora y viceversa; no se inventan valores al confirmar un único picker. Bloqueos de envío/respuesta ambigua conservados. Timestamp existente conserva timezone/segundos sin reescribirlo al editar otros campos. ADR-032/diseño/guía/fichas actualizados; sin cambios de SQL ni operaciones remotas.

Validación:40 pruebas de reportes/creación/arquitectura aprobadas antes de añadir cobertura específica;28 de reportes/inputs incluyendo3 nuevas de estado/geometría y2 de ViewModels aprobadas después. Otras8 pruebas de creación aprobadas al regenerar capturas de fecha/hora normales y pequeñas en build/ui-preview/case-creation; render normal revisado. flutter analyze --no-pub sin incidencias y formato correcto. Límites: repositorios sustituidos y mapas del test sin teselas reales; pickers y flujo Android autenticado pendientes.

Revisión de edición: contratos LostCaseRepository/FoundCaseRepository y SQL de casos permiten publicar/leer/listar/eliminar (encontrados además preparar/descartar), sin actualización de casos publicados. Editar reporte actúa únicamente sobre el borrador antes de publicar. Se recomendó al usuario permitir edición de información por autor en casos abiertos, con historial/versionado y misma ficha; no se implementó ni se declaró aprobado ese incremento. Siguiente paso de producto: acordar campos/reglas de edición publicada si el usuario la solicita.


## Corrección de controles inconsistentes en Hallazgo — 11 de octubre de 2026

La revisión anterior de efectos no eliminó controles propios de implementación y se corrigió por instrucción del usuario. Hallazgo retira Latitud/Longitud, Usar coordenadas, Punto seleccionado numérico, Recuperar foto interrumpida y Mis encontrados permanente en el formulario. Eliminados controladores _lat/_lon y chooseCoordinates del ViewModel; coordenadas siguen en el estado y dominio por selección del mapa. CaseLocationFields compartido renderiza ubicación/referencia/privacidad/validación/stagger en ambos reportes. Etiqueta pública de fotos unificada y separación20 de acciones coherente. Se preservan custodia y datos de mascota encontrada, selección de mascota propia en perdido, fotos/cámara y recuperación ante envío ambiguo. Sin nuevos SQL/contratos, acceso remoto o recuperación automática inventada.

Validación:50 pruebas de lost/found/creation/architecture/preview/consistency aprobadas en build/report-form-consistency.log. Las8 de creación ahora impiden controles técnicos y navegación permanente extra, comprueban componente compartido y mapa→estado, texto2/movimiento reducido y regreso. flutter analyze --no-pub sin incidencias. Capturas de creación/fecha-hora regeneradas; renders de hallazgo normal/pequeño revisados. Formato y diff comprobados. Rama/trabajo existente conservados; sin commit/push/despliegue.

Pendiente: revisión Android autenticada con fotos/teselas reales. El fallo de teselas400 del entorno de tests es esperado y no se presenta como mapa real funcional. Siguiente paso: revisar ambos formularios en Android y mantener el bloque compartido para futuros cambios. ADR-033/norma/diseño/arquitectura/guía/fichas actualizados.

## Recursos de mascotas para landing — 11 de octubre de 2026

Por solicitud del usuario, se generaron tres ilustraciones con imagegen a partir del mockup de identidad: ambos saludando, perrito explorando y gatito curioso. Archivos y prompts en [mockups/landing-mascotas-v1](../mockups/landing-mascotas-v1/README.md). Se conservaron los cambios locales existentes. Validación: revisión visual de personajes y comprobación de PNG con canal alfa/fondo transparente. No se modificó código; no corresponde ejecutar Flutter. Sin bloqueo de generación. Siguiente paso: componer la landing con estos recursos y revisar contraste/escala sobre sus fondos reales; no se afirma implementación de landing ni cierre de HU.

### Escenas narrativas de mascotas para landing — 11 de octubre de 2026

Nueva solicitud del usuario: representar la finalidad de recuperación colaborativa. Tres variantes de los personajes aprobados generadas con imagegen: búsqueda conjunta, ayuda ante hallazgo y reencuentro/regreso a casa. Archivos y prompts en [landing-mascotas-v2](../mockups/landing-mascotas-v2/README.md). Revisadas visualmente y comprobado PNG con alfa; sin cambios de código ni pruebas Flutter aplicables. Pendiente composición y revisión sobre fondos reales de landing; no añade funciones ni cierra historias.

### Mockup visual de landing — 11 de octubre de 2026

Por solicitud del usuario se generó con imagegen un mockup de página completa inspirado en su referencia, adaptado a recuperación colaborativa y personajes de Entre Huellas. [Imagen y prompt](../mockups/landing-concepto-v1/README.md). Revisión visual de composición/jerarquía completada; textos pequeños generados requieren corrección al implementar. No hay web interactiva/publicación ni código modificado. Siguiente paso: revisión del concepto por el usuario y eventual implementación responsive con copy real, accesibilidad y acciones comprobables; no se cierra HU.

### Landing concepto v2: posiciones de referencia — 11 de octubre de 2026

Nueva revisión visual solicitada por el usuario para aproximar distribución/formato de su referencia: hero centrado, tarjetas de personajes con poses y alturas distintas, bloques alternados, degradados aurora y cierre con mascotas grandes. [Mockup y prompt](../mockups/landing-concepto-v2/README.md), generado con imagegen, conservando v1. Revisión visual completada; banner emocional interpretado en dos columnas. Pendiente aprobación del concepto y eventual maquetación con textos/enlaces reales, responsive y accesibilidad. Solo imagen conceptual: sin código, despliegue, funciones nuevas ni cierre de HU.

## Búsquedas propias/comunitarias y avisos vinculados — 11 de octubre de 2026

Implementado el modelo autorizado por el usuario: Mascota perdida permite Mi mascota u Otra mascota posiblemente perdida, sin crear una ficha propia para la segunda. Mascota encontrada registra La vi o La encontré y está conmigo sobre una búsqueda abierta; desde la ficha se preselecciona su destino. Fotos opcionales en avisos, obligatorias en búsquedas comunitarias. Avisos consultables desde la búsqueda y sin cierre automático. Solo el autor confirma Ya fue recuperada; servidor actualiza estado/historial y contador de mascota de forma atómica e idempotente. Registros anteriores conservados como legacy_found, sin reinterpretación. UI reutiliza campos, efectos, toast, skeleton/shimmer y navegación compartidos; títulos breves y secuencia stagger ajustados a los campos reales.

Persistencia y permisos versionados en fuentes062–065/plan018/migración20261011001800_recovery_report_links.sql, generada con Build-RunAll. RPC validan propósito/destino abierto, instantánea de metadatos, fotos verificadas y autor; publicación anterior revocada para clientes. Proyecciones públicas no exponen coordenadas exactas ni referencia. Reintento estable, destino cerrado permite refrescar búsquedas sin perder UUID/fotos; publicaciones confirmadas invalidan avisos y cierre invalida listas/ficha de mascota. ADR-034, guía, arquitectura, configuración y ficha busquedas-y-avisos documentan activación y alcance.

Validación local: suite completa Flutter318 pruebas aprobadas en build/recovery-flutter.log; suite SQL21 aprobadas en build/recovery-sql.log (permisos entre usuarios/anon, destinos, fotos opcionales, no cierre automático, confirmación idempotente, privacidad y repetición del bundle). Análisis final sin incidencias en build/recovery-analyze-final.log. Recorridos de UI normales y pequeños con texto ampliado cubren búsqueda de otra mascota sin fichas propias, aviso vinculado sin foto y confirmación separada. La revisión final de títulos/stagger detectó y corrigió acceso nullable antes de entregar. Formato y diff comprobados.

Tras los últimos ajustes visuales:24 regresiones de flujo/avisos/efectos aprobadas en build/recovery-final.log y análisis sin incidencias; capturas regeneradas y título pequeño revisado sin cortes dentro de palabras.

Trazabilidad: HU-05/RF-05 y HU-06/RF-06; partes app de HU-10/RF-11 y confirmación HU-13/RF-07 adelantadas por autorización explícita. No se declaran historias cerradas; edición de casos publicados, revisión/moderación completa, exploración/paginación, QR/web/push permanecen fuera de este incremento.

Pendiente: aplicar018 en Supabase tras001–017 y pipeline previo de fotos; activar cliente junto con SQL y verificar caché de esquema/RPC. No se desplegó backend ni se generó APK. Android autenticado con fotos/teselas reales y carreras con conexiones independientes pendientes; repositorios/imagenes de UI sustituidos y PGlite secuencial no acreditan esas condiciones. Siguiente paso: activación en desarrollo y comprobación de ambos recorridos entre cuentas reales. Sin commit/push; trabajo previo conservado.


## Mi mascota/Otra mascota sin recargar el formulario — 11 de octubre de 2026

Corregida la sustitución de ruta que desmontaba el editor y repetía skeleton/carga. LostReportScreen compone ambos editores/ViewModels en app, conservando cabecera/selector y cada borrador de la visita. Alternar no cambia la ruta, descarta datos ni consulta otra vez mascotas. Cuerpo con fade180ms y movimiento reducido inmediato, sin repetir cover/stagger; entrada inicial y pasos revisión/confirmación conservados. Skeleton limitado a datos iniciales pendientes, con selector visible. Controllers se restauran desde estado; envío/fotos/respuesta ambigua bloquean alternar. Salir considera datos de ambas opciones y usa confirmación/descarte existentes. Sin nuevo SQL o despliegue; activación018 del incremento anterior sigue siendo necesaria si aún no fue aplicada.

Validación: suite completa Flutter320 pruebas aprobadas en build/report-switch-full.log, incluidas2 nuevas regresiones de ambas entradas con datos/UUID/fecha parcial conservados, ruta y elemento del selector estables, ningún skeleton durante cambio y consultas no repetidas; normal390×844 y pequeño320×350 texto2/movimiento reducido. flutter analyze --no-pub sin incidencias en build/report-switch-analyze.log. Formato/diff comprobados; reglas de capas y regresiones existentes de salida/creación incluidas. ADR-035, diseño/norma/arquitectura/guía y fichas actualizados.

Limitaciones: estado conservado durante la visita, sin persistencia offline; repositorios sustituidos/mapas sin teselas reales en tests. Pendiente revisión Android autenticada con red/fotos reales. Siguiente paso: verificar alternancia y salida en Android sobre backend018 activo. Rama y trabajo previo conservados; sin commit/push/APK/despliegue.

Revisión visual final:10 pruebas de creación/alternancia aprobadas en build/report-switch-visual.log; capturas normales/pequeñas regeneradas y revisadas en build/ui-preview/case-creation. Con texto2 la cabecera ocupa más altura y el resto continúa en scroll, sin overflow. Las teselas400 son la limitación conocida del entorno de tests.


## Alternancia inmediata sin transición — 11 de octubre de 2026

Por corrección explícita del usuario se retira AnimatedSwitcher/fade del cuerpo Mi mascota/Otra mascota. Cambio inmediato sin transición entre opciones; se conservan selector, ruta y borradores. ADR-035, diseño/norma y fichas actualizados. Validación:2 regresiones de alternancia aprobadas en build/report-switch-instant.log, formato correcto y flutter analyze --no-pub sin incidencias en build/report-switch-instant-analyze.log. Sin SQL/despliegue; revisión Android real pendiente. Siguiente paso: comprobar la alternancia inmediata en Android.


## Reportar minimalista y Mis reportes unificado — 12 de octubre de 2026

Por instrucción del usuario se retira Cerrar del panel Reportar y se separa creación de consulta. Panel con dos filas neutras con icono/nombre/explicación breve/chevrón, sin párrafo largo ni enlaces Mis casos/Mis búsquedas y avisos intercalados. Cierre por gesto/barrera/Atrás. Inicio ofrece Reportar/Mis reportes/Mis mascotas. Mis reportes combina búsquedas propias/comunitarias, avisos y registros anteriores en una colección con tipo real, filtro Abiertos/Resueltos, ficha y swipe de eliminación. Envíos pendientes y limpieza conservan descarte real; + abre el mismo panel. Cabecera/tarjetas/filtro/diálogo/componentes y apertura desde opción comparten implementación con Mascotas. Se conserva alternancia inmediata del formulario según ADR-035.

RecoveryReport/ListRecoveryReports/RemoveRecoveryReport colaboran por dominio y providers declarativos, reutilizando contratos/casos de uso existentes; ViewModel coordina estado, refresh conservado, cuenta, errores y retiro. app/router inyecta callback del panel, sin imports cruzados de presentation/data. Claves compuestas evitan mezclar UUID iguales entre tablas; ambas lecturas deben completar para confirmar datos. Al volver de ficha/registro se refresca sin ocultar consulta previa. No nuevo SQL/Edge/esquema, sin despliegue. Activación018 del flujo anterior sigue siendo requisito si aún no se aplicó. No se declara cronología global: contratos actuales no incluyen fechas comunes de orden.

Validación:323 pruebas Flutter de suite completa aprobadas en build/report-menu-full.log;25 de navegación/creación/colección/arquitectura y nueva consulta en build/report-menu-regression.log. Las3 nuevas cubren lista combinada, UUID compartido/eliminación dirigida, refresh fallido conservado, cambio de identidad con respuesta tardía y navegación normal390×844/pequeña320×350 texto2. Sin Cerrar ni enlaces anteriores en panel; creación desde etiqueta accesible en texto ampliado. flutter analyze --no-pub sin incidencias en build/report-menu-analyze.log. Tras ajuste final de color/peso tipográfico,3 pruebas repetidas con captura en build/report-menu-visual-final.log; formato13 archivos correcto y diff comprobado. Renders con fuentes reales en build/ui-preview/report-menu, revisados normal/pequeño: modalidad pequeña usa scroll sin overflow.

ADR-036, ficha Mis reportes e índice, Inicio/búsquedas y norma/diseño/arquitectura/guía actualizados. Trazabilidad HU-05/RF-05 y HU-06/RF-06, sin historia cerrada ni exploración/QR/web/push nuevos. Límite: repositorios sustituidos, fotos de prueba vacías y mapas sin teselas reales; prueba Android autenticada/operación remota pendiente. Siguiente paso: verificar panel/consulta y retorno de fichas en Android con backend018 activo. Sin commit/push/APK/despliegue; trabajo previo conservado.


## Avisos solo desde ficha y Reportar directo — 12 de octubre de 2026

Implementada decisión explícita del usuario: Mascota encontrada sale de Reportar. Inicio/navegación/+ de Mis reportes abren directamente Mascota perdida (Mi mascota/Otra mascota), sin panel intermedio. Ficha de búsqueda abierta mantiene La vi o la encontré y abre aviso vinculado; formulario presenta destino estático, sin seleccionar catálogo ni permitir reasignación. Ruta sin vínculo/origen válido vuelve a Inicio. Listado histórico de encontrados conserva consulta/descarte y + crea pérdida. Mis reportes unificado conserva consulta y refresco al volver.

ReadRecoverySearch usa contratos de dominio de los dos orígenes, consulta solo proyección del destino y comprueba ID/estado/kind comunitario; ViewModel no carga list_open_recovery_searches, no conserva catálogo ni selectTarget/refreshTargets. Destino cerrado: toast superior/Volver a la ficha, datos/UUID/fotos conservados hasta salida confirmada; bloqueados cambios y reenvío, sin reasignación. Confirmación de recuperación por autor permanece separada. Aperturas mantienen geometría/origen del control y efectos compartidos; selector Mi mascota/Otra mascota sigue inmediato. Fronteras de capas conservadas, providers declarativos y callback de navegación en composición. No nuevos SQL/Edge/permisos o despliegue;018 sigue siendo requisito si falta aplicarla.

Validación local:324 pruebas de suite Flutter completa aprobadas en build/detail-only-full.log;40 pruebas de creación, navegación, reportes, recuperación y arquitectura en build/detail-only-test.log;15 con capturas/avisos vinculados en build/detail-only-visual.log. Dos regresiones nuevas (build/bound-notice-test.log) preparan catálogo1000+, comprueban cero consultas de catálogo y exactamente una lectura del destino en ambos orígenes, publicación rechazada por cierre con borrador conservado y ningún segundo envío. Análisis sin incidencias en build/detail-only-analyze.log. Prueba de ruta de aviso sin contexto también comprobada en sesión iniciada en build/detail-only-final.log. Formato18 archivos y diff comprobados. Capturas de avisos normal/pequeño con fuentes reales regeneradas/revisadas en build/ui-preview/case-creation; campos accesibles mediante scroll/texto2/movimiento reducido.

ADR-037 y guía/norma/diseño/arquitectura/fichas actualizados, sustituyendo elección genérica de ADR-034 y panel de ADR-036. HU-05/RF-05 y HU-06/RF-06, sin historias cerradas. Explorar es destino previsto para consultar casos; su lista/mapa/filtros públicos de HU-07/RF-13 siguen pendientes y no se entregan en esta corrección. Repositorios/fotos sustituidos y teselas400 del entorno de tests no acreditan Android/Supabase real. Siguiente paso: verificar en Android autenticado apertura desde ficha y rechazo tras cierre con018 activo; completar Explorar en su incremento. Sin commit/push/APK/despliegue; trabajo previo conservado.


## Mascota perdida: formulario único — 12 de octubre de 2026

Implementada propuesta aceptada por el usuario. Se retiran las pestañas Mi mascota/Otra mascota. Mascota a reportar permite escoger ficha o No está en mis mascotas: resumen de datos disponibles/fotos propias frente a descripción/fotos sin registrarla como propia. Un solo bloque CaseReportFields renderiza fecha/hora/mapa/referencia/revisión, también reutilizado por los editores y avisos. Cambiar origen conserva fecha parcial, hora, punto y referencia del mismo reporte; no mezcla descripción/fotos de mascota ni identidades. Selector/ruta estables, sin recarga de catálogo/skeleton/reveal al alternar; bloqueo por operación/respuesta ambigua y descarte de ambos borradores conservados. Vista previa y contratos de publicación siguen existentes. Panel de opciones con título corto Mascota para texto ampliado.

Composición en app y acciones restoreReportDetails en ViewModels; core recibe datos/callbacks sin importar features. Fronteras conservadas, sin cambio de reglas, SQL nuevo ni despliegue. ADR-038 sustituye la interfaz de ADR-035; guía, arquitectura, diseño y fichas de búsquedas/casos perdidos/índice actualizados. Trazabilidad HU-05/RF-05 y búsqueda comunitaria de HU-06/RF-06, sin historia cerrada.

Validación local:324 pruebas de suite completa aprobadas en build/unified-report-full.log; análisis sin incidencias en build/unified-report-analyze.log; formato398 archivos sin cambios en build/unified-report-format.log. Las4 pruebas de selección y recorrido end-to-end local pasan en build/unified-report-final-targeted.log; renders actualizados por las2 pruebas de selección en build/unified-report-visual-final.log. Comprueban un solo bloque fecha/mapa, ausencia de pestañas, identidad del selector/ruta, conservación de UUID/fecha parcial/punto/referencia/rasgos sin nueva consulta de catálogo y validación en toast. Recorrido sin fichas registradas publica búsqueda, agrega aviso vinculado y confirma recuperación por autor. Pruebas existentes de arquitectura, navegación, creación y preview incluidas en suite. Un test previo requería formato; ajuste exclusivamente de formato en supabase_lost_cases_test.dart.

Capturas con fuentes reales revisadas en build/ui-preview/unified-report:390×844 y320×350/texto2/movimiento reducido, resumen/descripcion y acciones alcanzables mediante scroll. Repositorios sustituidos y teselas HTTP400 del entorno de tests; no acreditan fotos/Storage/Supabase/cartografía real ni rendimiento Android. Pendiente verificar en Android autenticado selección de fichas/fotos, cambio de origen y publicación con backend018 activo. Siguiente paso: esa verificación real; no se generó APK ni se hizo commit/push/despliegue. Trabajo previo conservado.

## Retirada del texto bajo los mapas — 15 de octubre de 2026

Por instrucción explícita del usuario, retirados por completo el texto de atribución y su botón/enlace de ZoneMapPicker, compartido por zonas y reportes. Eliminados import y constantes de atribución sin consumidores. El proveedor actual de teselas no cambia. Configuración y ficha de zonas actualizadas; pendiente resolver las condiciones de atribución del proveedor antes de distribuir, sin declarar conformidad por esta modificación visual.

Validación local: formato de los dos archivos Dart correcto, flutter analyze --no-pub sin incidencias y 14 pruebas existentes de mapa, arquitectura y vista previa aprobadas. Cubren selección, recentrado, reintento y vista previa normal/pequeña con movimiento reducido. git diff --check correcto. No se ejecutó Android autenticado ni se generó APK; siguiente paso: revisar el resultado en la app. Sin commit, push ni despliegue.

## README para incorporación de colaboradores — 15 de octubre de 2026

Actualizado README raíz con icono existente, badges informativos de stack/estado, requisitos fijados en el workflow, clonación, dependencias, enlace a la plantilla config/supabase.local.example.json, creación del archivo local y ejecución Android/VS Code. Los valores del entorno se compartirán internamente por el responsable; solo configuración pública en el cliente, sin secretos en Git. Aclarada la validez OTP de ejemplo y la diferencia entre configuración cliente y activación del backend. Añadidos flujo de ramas/PR, fronteras por funcionalidad, comprobaciones, mapa del repositorio y enlaces de documentación. Retiradas afirmaciones antiguas de README sobre acceso y onboarding omitible; no cambia el alcance funcional ni se cierra ninguna historia.

Validación documental: referencias locales, anclas internas, bloques de código, JSON de ejemplo con valores Supabase vacíos y exclusión Git del archivo local comprobados; git diff --check correcto. No se ejecutaron pruebas Flutter ni builds por tratarse de documentación; render de GitHub y disponibilidad remota de badges no comprobados. No se modificaron credenciales, configuración ni fichas funcionales en este incremento. Trabajo local previo conservado. Siguiente paso: revisar el README en GitHub cuando se autorice su publicación; sin commit, push ni despliegue en esta tarea.

## Explorar: lista filtrada y paginada — 15 de octubre de 2026

El usuario confirma que validó la rama actual feature/found-pet-cases y autoriza continuar con el siguiente incremento. Esa confirmación se registra como validación del usuario sobre el trabajo anterior; no se atribuyen a esta sesión despliegues ni escenarios remotos no observados. Árbol inicial limpio, commit73f76f2; creada rama local feature/explore-case-list. Sin commit/push/PR o despliegue en esta tarea.

Implementada HU-07.1 / RF-13 / issue #32: Explorar recibe listado real desde la composición de app, con filtros por tipo/especie/estado/período/distancia a un centro manual. Consulta por zona sin GPS, apertura de fichas existentes, refresh al volver y páginas de20. Perdidas comprende búsquedas propias/comunitarias; Encontradas incluye avisos con custodia/anteriores, que conservan etiqueta Reporte anterior; Avistamientos tiene filtro separado. Resueltos conservan visibilidad exclusiva del autor. No se amplía publicación de datos privados ni permisos de fotos. HU-07.2 / issue #33 (mapa de resultados) sigue pendiente; el mapa del filtro selecciona únicamente el centro.

Módulo explore con dominio/casos de uso/contratos, DTO/fuentes/repositorio, ViewModel/estado/widgets y providers declarativos. Bootstrap/main inyectan implementaciones; router compone ExploreSection con HomeScreen, sin importar presentation/data entre funcionalidades. Se reutilizan tarjetas, cabecera, campos/selectores, ZoneMapPicker, shake/toast, skeleton/LoadingShimmer/ContentRefresh y cover→stagger. No repite entrada al filtrar/refrescar/paginar. Cursor asociado a filtros, ventana temporal y orden publicación/origen/UUID; bloqueo de dobles solicitudes, reintento de misma página, distinción error/vacío y protección ante cambio de cuenta/respuestas tardías.

SQL066–069/plan019, migración y patch019 generados; Build-RunAll actualizado sin modificar migraciones anteriores. PostGIS en extensions con comprobación de esquema e índices GiST; ST_DWithin/ST_Distance solo sobre puntos públicos aproximados. RPC explore_cases autenticada con proyección explícita y visibilidad reutilizada. No nueva Edge. Dependencias de tests fijadas a PGlite0.5.10 y extensión PostGIS0.2.10: geometría real en WASM, sin simular funciones; paquete experimental limitado a pruebas.

Validación: suite completa Flutter **331 pruebas aprobadas** en build/explore-full.log; **22 pruebas SQL aprobadas** en database/tests/explore-full.log. Análisis sin incidencias en build/explore-analyze-release.log; formato414 archivos sin cambios en build/explore-format.log. Las7 nuevas pruebas Flutter cubren validación y DTO/fallos, cursores/reintentos/doble solicitud/UUID por origen, refresh/filtro, cuentas y recuperación tras error de sesión, estados skeleton/error/vacío/datos y navegación normal390×844/pequeña320×350 texto2 con movimiento reducido. Otras2 regresiones de retorno desde Perfil adaptadas a Explorar real y aprobadas. Capturas con fuentes reales en build/ui-preview/explore, revisadas normales/pequeñas; contenido y acciones alcanzables mediante scroll. Pruebas visuales enfocadas en build/explore-visual.log.

SQL prueba combinación de orígenes con fechas empatadas, filtros, distancia pública frente a ubicación exacta distinta, exclusión de borrados/resueltos de terceros, permisos A/B/anónimo, cursor inválido y publicación entre páginas. Upgrade018→019 y repetición del patch y run_all comprobados también en database/tests/explore-upgrade.log. ADR-039, guía/backlog, arquitectura, configuración/diseño e índice/fichas de Explorar/Inicio actualizados.

Pendiente: activar019 sobre backend001–018 con fotos operativo; demo Android autenticada con miniaturas/Storage/teselas reales y volumen representativo. Repositorios sustituidos en UI y PostGIS local no acreditan estas condiciones, rendimiento hosted ni concurrencia multiconexión. El proveedor de mapas mantiene sus condiciones pendientes previamente registradas antes de distribución. No se generó APK ni se cierra HU-07.1 por evidencia local. Siguiente paso: aplicar/verificar019 en desarrollo; después HU-07.2 con los mismos filtros/contrato público.


## Explorar en grilla con foto protagonista — 15 de octubre de 2026

Por preferencia explícita del usuario, las filas se sustituyen por cards fotográficas de inspiración Apple. ExploreCaseGrid usa dos columnas desde300px de contenido y texto normal, una en ancho reducido/texto ampliado. Imagen vertical4:5, datos debajo, radio22/superficie compartida y alturas naturales igualadas por fila, sin truncar texto. La card completa abre la misma ficha con su rectángulo como origen. Skeleton inicial y de consulta nueva reproducen cuatro cards; CasePhotoView compartido gobierna carga/fallo de imágenes y ausencia de foto conserva un icono neutro, sin datos inventados.

Cambio limitado a presentación: filtros, páginas, refresh, ViewModel, privacidad y contrato019 conservados; sin SQL ni despliegue nuevos. Se conserva el trabajo previo de feature/explore-case-list. ADR-040, norma UI/UX, diseño, guía y ficha/índice de Explorar actualizados.

Validación:18 pruebas de Explorar, arquitectura y navegación desde Perfil aprobadas en build/explore-grid-tests.log. Se adaptaron las pruebas visuales existentes con tres tarjetas (fila impar), dos imágenes locales de fixture y una sin foto: dos columnas en390×844, una en320×350/texto2/movimiento reducido, lectura mediante scroll, estados skeleton/error/vacío, filtro y apertura de ficha. Capturas revisadas en build/ui-preview/explore; el asset de fixture solo se inyecta en caché del test, no en producción. Análisis sin incidencias en build/explore-grid-analyze-final.log y formato415 archivos sin cambios en build/explore-grid-format.log. Tras ajustar el encuadre de las capturas, las2 pruebas visuales se repitieron y aprobaron en build/explore-grid-renders.log. No se repitió SQL al no cambiar backend; suite previa de22 sigue siendo la evidencia de019.

Pendiente: verificar la grilla con fotos reales en Android autenticado y backend019 activo; los renders no acreditan Supabase/Storage ni rendimiento nativo. No se generó APK ni se hizo commit/push/despliegue. Siguiente paso: esa comprobación y después HU-07.2, mapa de resultados.


## Cards de Explorar más compactas — 15 de octubre de 2026

Por corrección explícita del usuario, la imagen pasa de4:5 vertical a4:3 horizontal: aprovecha el ancho y reduce su altura dentro de la grilla. Retirada la fecha visible de la tarjeta y movido Abierto/Resuelto a un badge neutro en la esquina superior derecha de la imagen. Nombre/tipo/especie y distancia opcional permanecen debajo. La fecha sigue en el modelo, filtros y ficha; navegación, columnas adaptables, texto ampliado y contratos conservados. Skeleton adopta la misma proporción horizontal.

Validación:18 pruebas de Explorar/arquitectura/retorno desde Perfil aprobadas en build/explore-compact-grid-tests.log. Renders normales390×844 y pequeños320×350/texto2/movimiento reducido regenerados y revisados en build/ui-preview/explore con fotografías de fixture; badge legible y sin overflow. Análisis y formato en build/explore-compact-grid-analyze.log y build/explore-compact-grid-format.log. ADR-040, norma UI, diseño y ficha de Explorar actualizados. Cambio solo de presentación, sin SQL/activación adicionales.

Pendiente revisión Android autenticada con fotos reales y backend019 activo. Sin APK, commit/push o despliegue en esta corrección. Siguiente paso: verificar el ajuste en la app.


## Cards amplias fuera del ancho de la grilla — 15 de octubre de 2026

El usuario pide cards mayores incluso superando el ancho disponible. Se adopta una grilla horizontal de dos columnas con cada card al76% del viewport de contenido y separación14; queda una completa y parte de la siguiente como indicio de continuidad. Desplazamiento horizontal común para todas las filas, scroll vertical/paginación conservados. Con ancho inferior a300px o texto ampliado se mantiene una columna del ancho disponible. Foto4:3/badge y datos breves conservados. Cambio solo en presentación; sin SQL ni alteración de filtros/permisos. Trabajo local anterior conservado.

Validación:18 pruebas de Explorar/arquitectura/navegación aprobadas en build/explore-wide-grid-tests.log. Las2 regresiones visuales se amplían con cards más anchas que media pantalla y gesto horizontal que permite ver completa la segunda card; resultados en build/explore-wide-grid-renders.log. Capturas con fixture local en build/ui-preview/explore, incluida normal-horizontal. Análisis en build/explore-wide-grid-analyze.log; norma/diseño, ADR-040 y ficha de Explorar actualizados.

Pendiente revisión Android autenticada con backend019/fotos reales; no se acredita rendimiento nativo por los renders. Sin APK/commit/push/despliegue. Siguiente paso: comprobar el tamaño y gesto en la app.


## Grilla vertical y cards junto a los bordes — 15 de octubre de 2026

El usuario aclara con captura que buscaba acercar las cards a los bordes laterales, conservar scroll vertical y reducir el tamaño de la variante anterior. Retirado el SingleChildScrollView horizontal y el ancho76%. Dos columnas completas aprovechan margen lateral12, separación14 e imagen4:3; con ancho inferior a280 o texto ampliado se usa una columna. HomeScreen aplica margen12 solo al contenido de Explorar, y la cabecera/filtros añaden12 internos para conservar alineación24 con la marca. Las otras secciones conservan su layout.

Validación:18 pruebas de Explorar/arquitectura/retorno desde Perfil aprobadas en build/explore-edge-grid-tests.log; después del ajuste de alineación,2 regresiones visuales aprobadas en build/explore-edge-grid-renders.log. Las pruebas existentes verifican columnas completas a12px de los bordes, ausencia de scroll horizontal, gesto vertical, vista normal390×844 y pequeña320×350/texto2/movimiento reducido, filtro y apertura de ficha. Capturas de fixture regeneradas/revisadas en build/ui-preview/explore. Análisis en build/explore-edge-grid-analyze.log y formato en build/explore-edge-grid-format.log. ADR-040, norma UI/UX, diseño y ficha actualizados para sustituir la interpretación horizontal anterior.

Sin SQL, cambios de contratos, APK, commit/push ni despliegue. Pendiente comprobar el ajuste en Android autenticado con backend019 y fotos reales.


## Filtros flotantes reutilizables — 15 de octubre de 2026

Por solicitud y captura del usuario, retirado ExpansionTile de Filtrar casos. El control abre panel modal por encima de la grilla, sin alterar rectángulos/scroll de los resultados. Core incorpora FilterPopover<T> (ruta modal propiedad del control), FilterChoiceGroup<T> (opciones adaptables e indicador único) y SelectionPillSurface extraída de TwoOptionFilter, que conserva su animación/semántica y usa la misma superficie. Cápsulas grises, selección negra y objetivos48, título Filtros/X glass, cover→stagger del cuerpo y movimiento reducido respetado.

ExploreFilters mantiene un borrador visual dentro del panel: cerrar por X/fuera/Atrás descarta edición; Aplicar confirma una sola vez y usa el callback del ViewModel existente. Abrir/cambiar opciones no consulta servidor. Centro manual incompleto conserva shake/toast dentro del ciclo de vida del panel sin aplicar. La ruta se retira al desaparecer el propietario/cuenta y no entrega resultados tardíos. Sin SQL, SDK, cambios de dominio o nuevos permisos.

Validación: suite completa Flutter **332 pruebas aprobadas** en build/filter-popover-full.log. Tras ajustar medición tipográfica/distribución y título corto, **19 regresiones** de Explorar/arquitectura/retorno desde Perfil aprobadas en build/filter-popover-visual-final.log. Cubren cards fijas al abrir/cerrar/aplicar, cero consultas hasta confirmar, cancelación/restauración de selección, Atrás, limpieza al retirar propietario y recorrido de ficha. Capturas con fixture revisadas en build/ui-preview/explore: normal390×844 y pequeño320×350/texto2/movimiento reducido, panel superior y scroll hasta Aplicar. Análisis sin incidencias en build/filter-popover-analyze-final.log. Formato en build/filter-popover-format.log.

ADR-041, norma UI, diseño/arquitectura, guía y ficha de Explorar actualizados. No se repitió SQL al permanecer idéntico. Sin APK, commit/push o despliegue; pendiente comprobar panel/filtros y fotos reales en Android con019 activo.


## Explorar: filtros integrados, cards claras y búsqueda por zona — 15 de octubre de 2026

El usuario corrige la dirección visual con captura: quitar texto Mascota perdida bajo la foto, alinear/separar la grilla y desplegar filtros ahí mismo, sin popup. Confirma además buscar ciudad/dirección, elegir lugar en mapa y ajustar radio. Se conserva feature/explore-case-list y todo el trabajo anterior.

Implementado FilterExpansion<T> en core, sustituyendo la ruta modal FilterPopover (retirada). Reutiliza cápsulas SelectionPillSurface/FilterChoiceGroup; apertura dentro del scroll, cerrar descarta edición y Aplicar confirma/colapsa y vuelve al control. Cover→stagger sin reiniciar por edición; movimiento reducido monta directamente, corrigiendo la mutación de layout observada con AnimatedSize de duración cero. Separación16 entre filtros y grilla. Cards con nombre/especie debajo, sin frase Mascota perdida ni especie duplicada en registros sin nombre; tipo corto y estado en badges, columnas/altura por fila y márgenes conservados.

Zona de búsqueda: Todas las zonas/Por ubicación. AppTextField de ciudad/dirección y búsqueda explícita por botón/teclado, hasta5 resultados; elegir resultado centra mapa, tocarlo ajusta centro y slider1–50km cambia círculo/radio. ZoneMapPicker.fitRadius es opt-in y encuadra centro/radio; los usos anteriores conservan comportamiento. SearchPlace/SearchPlaces/PlaceSearchRepository en dominio; DTO/fuente Photon/caché/fallos en data; PlaceSearchViewModel autoDispose y widgets en presentación. Providers declarativos y composición en bootstrap/main. http pasa de dev a ejecución sin cambiar versión resuelta. No nuevo SQL ni permisos:019 consulta proximidad sobre puntos públicos aproximados. Sin GPS/permiso de ubicación.

Geocodificador inicial Photon demo, endpoint HTTPS reemplazable con PLACE_SEARCH_URL, caché en memoria5min/30 consultas y timeout12s, sin autocomplete o reintento automático. Atribución enlazada junto al buscador, sin restituir el bloque retirado bajo mapas. Texto de búsqueda se consulta al proveedor; no se envían sesiones/tokens o puntos privados de casos. El servidor demo permite uso razonable sin garantías: revisar instancia/proveedor antes de distribución o volumen mayor. Se detectó403 con cliente Dart sin identificación y se corrigió usando User-Agent real EntreHuellas/0.1, sin imitar navegadores.

Validación: suite completa Flutter **336 pruebas aprobadas** en build/explore-inline-full.log; **28 pruebas enfocadas** de Explorar, geocodificación, arquitectura y zonas aprobadas en build/explore-inline-verified-final.log. Las4 pruebas nuevas cubren normalización/límites/GeoJSON/UTF8, errores frente a vacío, caché, solicitudes duplicadas, cambio de identidad/respuestas tardías y recuperación. Renders/recorridos existentes verifican cero diálogos, edición sin consultas de casos, cancelación/aplicación/restauración, ciudad seleccionada y centro/radio25km entregados al caso de uso. Capturas normales390×844/pequeñas320×350 texto2/movimiento reducido revisadas en build/ui-preview/explore; teselas400 esperadas del entorno y fotos de fixture no acreditan cartografía/fotos reales. La notificación temporal de fallo de teselas se descarta explícitamente en la prueba antes de tocar Aplicar.

Después de la identificación HTTP, fuente/repositorio/caso de uso reales ejecutados con Dart devolvieron **5 resultados válidos** para Miraflores Lima Peru en build/explore-place-live.log. Las4 pruebas del buscador se repiten en build/explore-place-final-tests.log tras ese ajuste. Análisis sin incidencias en build/explore-inline-analyze-final.log; formato en build/explore-inline-format.log. Dependencias resueltas offline; sin actualización de versiones. ADR-042 sustituye la parte modal de041; norma UI, diseño/arquitectura, configuración, guía y ficha actualizados.

Pendiente: Android autenticado con backend019, fotos y teselas reales, cobertura de direcciones del proveedor y rendimiento nativo. La prueba HTTP no acredita disponibilidad futura ni un servicio de producción. Sin APK, commit/push, modificación remota de Supabase o despliegue. Siguiente paso: verificar este recorrido en la app.

## Reportar: buscador previo al mapa y sugerencias de Perú —20/10/2026

Por instrucción del usuario, se reutiliza places antes del mapa en pérdida
propia/comunitaria y avisos de hallazgo. Elegir sugerencia actualiza el punto
privado mediante su ViewModel y centra ZoneMapPicker; después permite ajuste
manual. Búsqueda opcional, referencia privada independiente, sin GPS ni cambios
de precisión pública/permisos. App compone el slot compartido; ViewModel de
búsqueda aislado de Explorar mediante ProviderScope local/autoDispose.

Toda consulta textual compartida (Explorar, reportes y Ciudad del perfil) pide
countrycode=PE y comprueba país PE de cada respuesta. País ausente/otro se
descarta; respuestas válidas extranjeras dan vacío, malformadas conservan fallo.
Mapa manual libre; no es restricción territorial de publicación. Sin SQL,
configuración o despliegue nuevos. ADR-107 y fichas actualizadas; sin ampliar HU.

Validación: formato correcto, análisis Flutter completo sin incidencias y72
pruebas aprobadas:24 places/arquitectura/creación por rutas reales y48 de
Explorar/perfil/perdidos/encontrados. Incluye sugerencias extranjeras o sin país,
modo Ciudad, selección que centra mapa, ajuste posterior y referencia conservada.
Renders390×844/texto1 y320×350/texto2 revisados sin overflow; las capturas no
acreditan teselas reales (red bloqueada por harness). Consulta real Tacna/PE:
cinco sugerencias PE. No se publicó ni desplegó. Siguiente paso: comprobar en
Android sugerencias reales, teclado, mapa y reintento con conectividad variable.

## Buscador: sugerencias superpuestas y lista continua —20/10/2026

Por corrección del usuario con dos capturas, PlaceSearchFields muestra un panel
único continuo sobre el contenido, sin cápsulas individuales ni desplazar
mapa/radio/campos durante consulta o resultados. OverlayPortal anclado al campo,
ancho compartido, filas mínimo48, máximo320 con scroll y límites de teclado/área
segura; apertura arriba cuando falta espacio abajo. Común a Reportar, Explorar
y Ciudad del perfil, con la política Perú/casos de uso/persistencia conservados.
AppTextField admite FocusNode externo sin disponerlo. Seleccionar/tocar fuera,
Escape/retorno y desmontar limpian el panel; tocar fuera invalida pendientes y
no consume la acción exterior. Toast/skeleton/shimmer existentes conservados.
ADR-108, ficha/índice y documentación de diseño/arquitectura actualizados.

Validación:50 pruebas aprobadas en build/place-overlay-final-tests.log (4 nuevas
para geometría de consulta/resultados, selección/scroll normal y pequeño,
teclado300/apertura arriba, cierre exterior/respuesta tardía y desmontaje;
regresiones de places/Explorar/Reportar/Perfil/arquitectura). Renders390×844/texto1
y320×350/texto2 en build/ui-preview/place-overlay revisados sin overflow y con
lista continua. Formato limpio; análisis completo sin incidencias. Sin despliegue.
Siguiente paso: revisar en Android teclado real, scroll del formulario y panel.

## Buscador: cancelar consultas antiguas y priorizar el último texto —20/10/2026

Por petición del usuario ante demora6–9s, debounce de600 a300ms y retirada de la
cola que esperaba la petición anterior. Editar cancela inmediatamente; última
consulta empieza tras300ms sin esperar la anterior. Cancelación por operación
independiente de Flutter/HTTP, transmitida por caso de uso/repositorio a fuente
AbortableRequest. Selección/cierre/cambio de cuenta/disposición cancelan trabajo.
Consultas activas idénticas se deduplican; generaciones protegen contra respuestas
y errores tardíos. Caché30/5min no acepta respuestas canceladas. Cliente inyectado,
PE/filtro recibido, Ciudad/dirección y overlay conservados; sin nueva dependencia,
SQL, proveedor ni despliegue. ADR-109 y ficha compartida actualizados.

Validación:54 pruebas aprobadas en build/place-speed-final-tests.log;4 nuevas
comprueban300ms sin esperar respuesta antigua en ambos modos, cancelación HTTP,
cacheo tras aborto y limpieza/desmontaje. Regresión de places/overlay/arquitectura,
Explorar, Reportar y Perfil. Formato limpio y análisis Flutter completo sin
incidencias en build/place-speed-analysis.log. Medición real adicional Chiclayo/PE:
HTTP200, cero redirecciones, conexión0,25s y primer byte/total9,75s. Mediciones
previas con/sin PE5,6–8s. El incremento elimina espera acumulada del cliente; no
acredita latencia inferior3s del proveedor ni rendimiento en Android. Siguiente
paso: medir en Android con la red del usuario; si persiste la lentitud, evaluar
la latencia/disponibilidad del proveedor con evidencia de ese entorno.

## Buscador: restaurar600ms y evitar errores por respuestas tardías —20/10/2026

Por nueva instrucción del usuario, restaurado debounce600ms. Cancelación de
consultas anteriores y descarte tardío se conservan. Diagnóstico con cliente Dart
real: fuente Tacna/Lima vencía a12s; GET anterior y AbortableRequest devolvieron
HTTP200/mismos1705 bytes a13,95/13,88s. `tacn` sí devuelve cinco sugerencias
Tacna/PE a13,42s y `tacna` a14,37s: el corte12s impedía recibirlas. Fuente ahora
permite20s con aborto al vencer; no exige nombre completo ni añade comodines.
Consulta sin PE también tardó15,87s. Sin cambiar proveedor, mapa, overlay,
permisos o alcance. ADR-110 sustituye300ms/timeout12s de ADR-109; ficha actualizada.

Validación:57 pruebas aprobadas en build/place-timeout-prefix-tests.log. Tres
nuevas verifican respuesta parcial válida después15s en modo dirección/Ciudad y
aborto ante proveedor sin respuesta a20s; prueba de concurrencia adaptada a600ms.
Regresiones de places/overlay/arquitectura/Explorar/Reportar/Perfil aprobadas.
Análisis completo sin incidencias en build/place-timeout-prefix-analysis.log;
formato correcto. Diagnóstico temporal retirado tras usar fuente/cliente reales.
No se desplegó. La corrección recupera respuestas válidas, no acelera el servidor
ni garantiza3s. Siguiente paso: revisión Android/red del usuario y, si persiste
latencia, evaluar proveedor/cobertura/condiciones con evidencia de ese entorno.
