# Lista de favoritos sin conexión para examen U2

## Estado vigente del punto3 —30/10/2026

Puntos1–2 demostrados por el usuario: JSON legible inicialmente; después sobre
cifrado ADB y lista local en modo avión. Evidencia conservada en build/exam-evidence
antes de activar protección. Las secciones siguientes se conservan como historial.

AndroidManifest desactiva backup y reglas XML excluyen todos los dominios de
datos tanto en respaldo cloud como transferencia entre dispositivos. Guardados
se compone con SecureRouteSurface: FLAG_SECURE, recientes deshabilitado API33+,
datos sin montar hasta confirmar protección. Leases evitan liberar otra ruta y
se limpian incluso al cancelar antes de terminar adquisición. Perfil permanece
capturable tras volver de Guardados. [ADR140](../decisiones/140-proteccion-y-borrado-local-examen-u2.md).

En Perfil, debajo de los accesos de gestión de cuenta y antes de Cerrar sesión,
Borrar datos de este teléfono solicita confirmación para borrar las listas offline
de todas las cuentas del dispositivo y sus claves. No borra favoritos remotos,
cuenta, cachés independientes ni borradores; el diálogo explica su alcance.
Caso de uso ClearOfflineLists, ViewModel propio y fuente con cola serial:
claves eliminadas primero; carpeta offline_saved_cases y temporales después.
No hay resurrección de archivo por un guardado anterior en curso; errores no
confirman éxito, reintento e idempotencia. Sesión observada y estados separados
al cambiar identidad. Feedback por toast superior, sin textos de error inline.

Evidencia del punto3:
1. Abrir Guardados y luego recientes (cuadrado del emulador): tarjeta de app
   vacía/negra. Capturar recientes para el PDF. La cámara del emulador/captura
   Android debe bloquear u ocultar Guardados; una captura de Windows no es ese test.
2. Volver a Inicio y abrir avatar → Perfil. Bajar a Borrar datos de este teléfono,
   confirmar y capturar el aviso de eliminación desde Perfil, fuera de Guardados.
3. Ejecutar Inspect-OfflineSavedList.ps1: se imprime el comando find mediante
   run-as y no se encuentra cases.json. Capturar esa terminal.
4. Capturar código de allowBackup/reglas, SecureScreenProtection.kt y borrado en
   SavedListFileSource/OfflineListCipher. Archivo y claves no son datos remotos.

24 pruebas Flutter y6 nativas reales aprobadas; análisis limpio. UI de acción a
390×844 y320×844/texto200% revisada. Tests de borrado nativo usan namespace de test,
sin eliminar clave real del usuario. Demo/capturas reales y aceptación del punto3
pendientes. No se afirma ensayo cloud/transfer ni que puntos4–5 estén entregados.

## Estado vigente del punto2 —30/10/2026

La sección histórica inferior documenta el punto1 ya demostrado por el usuario.
Ahora cases.json contiene un sobre version2 AES-256-GCM, no los datos legibles.
El JSON de negocio se cifra antes de cualquier escritura, incluyendo temporales.
AndroidKeyStore genera/custodia la clave por cuenta; IV96 nuevo por operación,
tag128 y AAD de versión/propósito/cuenta. Sin claves exportadas ni persistidas
en Dart. El guardado y fallback conservan sus casos de uso y UI.

Canal de plataforma en app inyectado como SavedListCipher en la fuente de datos;
código de Keystore separado en OfflineListCipher.kt. MainActivity solo transporta
operaciones a un ejecutor serial. Fuente rechaza archivos anteriores en claro:
no los migra ni interpreta como cifrados. [ADR139](../decisiones/139-cifrado-lista-offline-android-keystore.md).

16 pruebas Flutter aprobadas, análisis limpio y3 pruebas instrumentadas reales
Android aprobadas. Las simulaciones de cifrado en pruebas Flutter no validan AES.
APK compilado; desinstalación/reinstalación SIN conservar datos realizada. Evidencia
previa en build/exam-evidence/point1. Login/copia local anterior eliminados; favoritos
del servidor no se modifican. Red reactivada para el nuevo login del usuario.

Para las capturas del punto2: iniciar sesión, ir a Guardados, guardar nuevamente
los favoritos, ejecutar el mismo Inspect-OfflineSavedList.ps1 y comprobar que
aparecen version2/algorithm/sealed sin nombres/rasgos legibles. El script muestra
también el IV público; repetir guardado debe cambiarlo. Activar modo avión,
deshabilitar Wi-Fi y refrescar para demostrar descifrado en la app. Capturar
la lista local y el código nativo de generación/cifrado/descifrado. Esa demo
real sigue pendiente. Otras cachés no se declaran cifradas y puntos3–5 pendientes.

## Historial del punto1

Incremento académico autorizado30/10/2026: punto1 del examen tipo4. No cambia
el alcance de las HU ni cierra historias. Android, en la lista real Guardados →
Favoritos de tu cuenta (pantalla principal de este listado). No es una demo
aislada. El login y el backend siguen funcionando como antes.

## Recorrido y campos

Con internet y una cuenta de prueba: marcar como favoritos casos de prueba desde
Compartir en sus fichas. Abrir Guardados, comprobar la lista y pulsar Guardar sin
conexión. Guarda exactamente los registros ya cargados; Ver más permite incluir
más páginas antes del guardado. Toast superior solo al terminar. Se bloquean
envíos repetidos y se usa LoadingShimmer durante la escritura.

Al fallar la consulta remota, inicialmente o al refrescar, se lee la última
lista guardada de esa cuenta. Aviso de estado offline y sin fotos; consulta
de fichas deshabilitada en este listado local porque el JSON no contiene la ficha
completa ni concede permisos de consulta. La caché anterior de fichas consultadas
permanece independiente. Al recuperar red, Reintentar recupera datos actuales.

Archivo privado UTF8 `files/offline_saved_cases/<cuenta>/cases.json`, esquema1:
cuenta, fecha UTC de guardado y tarjetas públicas (identificador, tipo, origen,
estado, especie, nombre, rasgos, fecha y coordenadas/distancia de la proyección
pública ya autorizada). Sin teléfonos, perfil, tokens ni URLs firmadas de fotos.
El JSON está deliberadamente en texto claro para la evidencia del punto1;
no acredita protección criptográfica. No introducir datos personales reales
para la demostración académica. AES-GCM/Keystore corresponden al punto2, pendiente.

## Arquitectura, errores y límites

Dominio: SavedListFileRepository, SaveListOffline y ReadListOffline.
Data: SavedListFileSource encapsula archivo privado/path_provider; DTO con campos
permitidos y repositorio que traduce fallos. Main inyecta implementación mediante
providers declarativos. ViewModel ejecuta casos de uso; UI usa estilo de botón y
toast compartidos. Escritura temporal + rename tras flush; archivo por cuenta,
validación del identificador y tope4MB de lectura. Ausencia no equivale a backend
vacío confirmado; error de lectura permite conservar el manejo previo y reintentar.
No se borra nada del backend ni se conceden permisos adicionales al guardar.

## Evidencias y comandos

Desde apps/mobile:

```powershell
$env:FLUTTER_WINDOWS='false'
flutter run -d emulator-5554 --dart-define-from-file=config/supabase.local.json
```

Después del guardado, activar modo avión en el emulador y refrescar Guardados.
Capturar la lista con aviso Sin conexión. En otra terminal desde apps/mobile:

```powershell
.\scripts\Inspect-OfflineSavedList.ps1
```

El script usa `adb shell run-as` para localizar el archivo privado y mostrarlo
con cat; requiere APK debug y SDK en LOCALAPPDATA. Si hay varias cuentas exige
elegir explícitamente una con -Account. Capturar comando y JSON legible.
Estas capturas deben hacerse antes de la protección de pantalla del punto3.

## Validación

15 pruebas de archivo real, ViewModel, interfaz y arquitectura aprobadas; archivo
legible, reemplazo, aislamiento por cuenta, omisión de enlaces firmados, fallback
en refresh y nueva instancia, recuperación de red y ausencia de copia sin falso
vacío. Interfaz390×844 y320×844/texto200% sin overflow, con fixtures solo en tests;
no son evidencias de uso real. Análisis de archivos modificados sin incidencias.
Pendiente evidencia real del usuario: guardar casos de prueba en emulador,
modo avión y salida ADB. No se implementan ni acreditan puntos2–5 por arrastre.
APK debug construido e instalado en emulator-5554 sin desinstalar ni borrar
sesión/datos; actividad iniciada. Script PowerShell validado sintácticamente.
