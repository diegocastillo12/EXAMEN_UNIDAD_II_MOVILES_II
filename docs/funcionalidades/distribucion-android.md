# Distribución Android por GitHub Releases

Corrección local28/10: la preparación abortada por symlinks de Windows dejó
sin GeneratedPluginRegistrant a Android; --no-pub conservaba ese estado.
Se regenera e instala con FLUTTER_WINDOWS=false (entorno del proceso) y
`flutter run -d emulator-5554 --dart-define-from-file=config/supabase.local.json`.
Configuración local válida, auth/settings200 y nuevo proceso sin error de canal
shared_preferences. Login real pendiente del usuario, sin cambios de permisos.

Evidencia local28/10/2026: APK debug compilado e instalado por
`flutter run --no-pub -d emulator-5554` (apps/mobile), inicio de sesión visible
en Android15/API35. Flutter3.47.2/Dart3.13.2, JBR21, Gradle8.14, AGP8.11.1,
Kotlin2.2.20 y NDK28.2.13676358. Esta evidencia no valida firma release,
pipeline ni backend: falta config/supabase.local.json en esta copia. Las
comprobaciones funcionales y de release siguen pendientes.

Para ejecutar la configuración de principio a fin, seguir la
[guía operativa de la raíz](../../INSTALACION_ANDROID.md): generación de firma,
origen de los valores, cinco secrets, primera ejecución, instalación y actualizaciones.
Esta ficha mantiene el contrato técnico y los límites de la funcionalidad.

Infraestructura de entrega del MVP, 22/10/2026. No cierra HU ni acredita
funcionalidades remotas. Conserva el identificador Android existente
`com.example.flutter_application_entrehuellas`, sin migrar instalaciones.

## Qué hace y recorrido

Cada push a `main` ejecuta formato, análisis y pruebas Flutter. Si pasan,
compila un APK universal firmado y publica una **prerelease** con APK y SHA-256.
Incluye cambios de cualquier carpeta, según la petición de publicar cada push.
Las PR ejecutan validación cuando cambian archivos móviles/workflow y nunca
acceden a la firma. Run workflow permite repetir manualmente desde `main`.
Flutter está fijado en 3.35.3; el runner Android usa JDK 17.
CI limita Gradle a3 GB de heap y2 workers mediante GRADLE_OPTS, conservando
la configuración de desarrollo existente y evitando su heap de8 GB en el runner.

Etiqueta: `android-build-N`, donde N es `github.run_number`; versionCode:
`10000 + N`. `versionName` procede de `apps/mobile/pubspec.yaml`.
No reiniciar el contador del workflow ni reutilizar números inferiores para
versiones posteriores. Un reintento del mismo run conserva etiqueta/número y
reemplaza adjuntos; un run manual nuevo crea otra versión instalable.
Si en el futuro se cambia de workflow/contador, ajustar la base del número.
Cada run usa su etiqueta propia; los builds pueden terminar en distinto orden
si hay varios pushes rápidos. Comparar el número de build antes de descargar.

## Preparación inicial: firma (en tu equipo)

Desde la raíz del repositorio, ejecutar en PowerShell:

```powershell
./apps/mobile/scripts/Setup-AndroidSigning.ps1
```

Pide interactivamente la contraseña y los datos del certificado; no requiere
comprar certificado ni una cuenta de Google Play. Alias por defecto: `entrehuellas`.
Genera `apps/mobile/android/keystore/entrehuellas-release.jks` y exporta su
Base64 a `apps/mobile/build/android-signing/keystore-base64.txt`, ambos ignorados.
No sobrescribe un keystore existente. Si ya distribuiste con otra firma,
reutilizar esa firma: no generar una nueva para actualizar esas instalaciones.
Para exportar una firma existente:

```powershell
./apps/mobile/scripts/Setup-AndroidSigning.ps1 -ExportOnly -KeystorePath 'C:/ruta/firma.jks' -KeyAlias 'tu-alias'
```

Respaldar JKS, alias y contraseñas en un lugar privado y duradero. Perder la
firma impide actualizar directamente esos APK. La app instalada anteriormente
con firma debug puede requerir desinstalación para instalar esta firma nueva;
esto elimina datos locales de esa instalación.

## Preparación inicial: configuración y secrets

Copiar `apps/mobile/config/release.local.example.json` a
`apps/mobile/config/release.local.json` (ignorado). Completar:

- `SUPABASE_URL`: URL HTTPS del proyecto que usarán los usuarios.
- `SUPABASE_PUBLISHABLE_KEY`: clave `sb_publishable_` del mismo proyecto.
- `MAP_TILE_URL`: URL Positron con la clave pública/restringida de CARTO válida
  para esa distribución. Ninguna credencial de backend en esta URL.
- `PUBLIC_CASE_WEB_URL`: dominio web real para fichas/QR.
- `PUBLIC_CASE_WEB_READY`: dejar `false` hasta verificar publicación y permisos
  QR en ese dominio; cambiar a `true` solo después. No activa/despliega la web.
- `EMAIL_OTP_VALIDITY_MINUTES`: duración acorde a la configuración Auth del entorno.

En GitHub → repositorio → **Settings → Secrets and variables → Actions →
New repository secret**, crear exactamente estos cinco secrets:

| Secret | Contenido |
| --- | --- |
| `MOBILE_CONFIG_JSON` | JSON completo de `config/release.local.json`, con llaves y valores reales |
| `ANDROID_KEYSTORE_BASE64` | Contenido completo de `build/android-signing/keystore-base64.txt`, sin saltos adicionales |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña del almacén JKS |
| `ANDROID_KEY_ALIAS` | `entrehuellas`, o alias de la firma existente |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave; si coincide con la del almacén, repetirla |

No pegarlos en el YAML, issues, chat ni archivos versionados. No se necesita
PAT: la publicación usa `GITHUB_TOKEN` con `contents: write` solo en el job de
release. El código rechaza claves desconocidas y exige una clave publicable;
no incluir `service_role`, `sb_secret_`, contraseñas SQL ni cuentas de servicio.
Los valores de configuración cliente pueden extraerse del APK; la autorización
depende de sesión, RLS y funciones protegidas. Los secrets evitan versionar los
archivos; no convierten la configuración cliente en un secreto dentro del APK.

Después de integrar estos cambios en `main`, revisar **Actions → Flutter**.
Descargar `entre-huellas-android.apk` desde **Releases**, habilitando instalación
desde esa fuente en Android. Si el repositorio es privado, el enlace requiere
acceso al repositorio; no cambiar visibilidad solo para compartir un APK.
El APK no incorpora un actualizador automático. Instalar manualmente versiones
posteriores con mismo identificador/firma y versionCode mayor conserva la app.
No configura Google Play; ese canal requiere su preparación y AAB aparte.

## Compilación local opcional

Copiar `apps/mobile/android/key.properties.example` a `key.properties` en el
mismo directorio. Completar ruta absoluta del JKS con `/`, alias y contraseñas.
El formato Java properties requiere escapar `\` como `\\` si aparece en una
contraseña y espacios iniciales como `\ `. Alternativamente usar las variables
de entorno ANDROID_* de la tabla/flujo, con `ANDROID_KEYSTORE_PATH` para la ruta.
No se usa firma debug como fallback: una release sin firma configurada falla.
El desarrollo debug no exige secretos.

Desde `apps/mobile`:

```powershell
flutter build apk --release --dart-define-from-file=config/release.local.json --build-number=10001
```

Usar un número mayor que el instalado; coordinarlo con el contador de CI.
Salida local: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`.

## Errores, reintentos, persistencia y permisos

Falta de secrets/configuración inválida: falla antes de compilar, indicando solo
nombres, sin imprimir valores. Clave/contraseña/certificado inválidos: Gradle
rechaza firma y no publica. R8 y firma se ejecutan en modo release; apksigner
comprueba integridad antes de adjuntar el APK. El runner borra configuración/JKS
al finalizar incluso con fallo; solo distribuye APK y checksum.
Si falla GitHub Releases después del build, el artifact Android permanece 14 días;
corregir permisos y reintentar el job. Una etiqueta creada por el flujo apunta al
SHA compilado. Políticas de organización o protección de tags pueden impedirlo.

No se modifican Supabase, migraciones, RLS, permisos de usuario ni web. Requiere
backend accesible y funciones/Storage/Auth ya activados para los recorridos usados.
Firebase/push siguen pospuestos según ADR-068; no requieren google-services.json.
La firma de Android aquí no reemplaza configurar redirect OAuth en Supabase.

## Validación y pendientes

Actualización24/10: el usuario confirma firma definitiva generada, cinco secrets
de repositorio guardados y `key.properties` local completado. Comprobada existencia
local de JKS, Base64, JSON y properties; sin leer sus valores. `key.properties`
ignorado y no versionado. El
[inventario operativo](../../INSTALACION_ANDROID.md#estado-de-la-preparacion)
relaciona cada secret con su origen/archivo/propiedad local, respaldo y mantenimiento,
sin incluir credenciales. La carga en GitHub procede de confirmación del usuario;
no se inspecciona ni se certifica su correspondencia remota.

Evidencia histórica22/10:518 pruebas Flutter y5 Python, formato/análisis/actionlint,
exportación Base64 y rechazo Gradle sin firma aprobados. APK universal release
compilado con JDK17/heap3 GB/2 workers y firma v2 verificada con certificado
desechable. Solo configuración ficticia; ese APK de validación no se distribuye.
La evidencia local y sus límites se registran en `docs/ESTADO.md`. Pendientes
externos: confirmar respaldo privado e integración a main, ejecutar Actions real y
probar el APK firmado en dispositivo con backend real: login/códigos/recuperación,
Google y retorno a la app, fotos/cámara, ubicación/mapa, reportes y QR autorizados.
La distribución automática no implica que el MVP completo esté validado.

Referencias: [Flutter Android](https://docs.flutter.dev/deployment/android),
[GitHub Secrets](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets),
[GitHub CLI releases](https://cli.github.com/manual/gh_release_create).
