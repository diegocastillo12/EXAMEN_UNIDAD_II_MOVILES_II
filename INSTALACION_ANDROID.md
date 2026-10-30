# Entre Huellas: configurar, publicar e instalar el APK

Guía operativa del equipo, actualizada el 24 de octubre de 2026.
Todos los comandos PowerShell de esta guía parten de la **raíz del repositorio**,
la carpeta donde están `README.md`, `apps` y este archivo, salvo indicación expresa.

## Qué necesitas hacer según tu caso

| Quieres… | Empieza en… |
| --- | --- |
| Configurar la primera distribución automática | Paso 1 y continúa hasta el 7 |
| Instalar un APK ya publicado | Paso 7; no necesitas Flutter ni el JSON |
| Publicar una actualización | Paso 8; reutiliza la firma existente |
| Ejecutar el código durante desarrollo | [README: primeros pasos](README.md#primeros-pasos) |
| Compilar un APK en tu equipo | Sección «Compilar localmente» |

La automatización está en [.github/workflows/flutter.yml](.github/workflows/flutter.yml).
Cada push a `main`, incluido integrar un PR, valida el código y, si pasa,
compila un APK universal firmado y publica una **prerelease** con APK y checksum.
Las PR solo validan. También se puede ejecutar manualmente desde `main`.

Esto distribuye Android mediante GitHub Releases. El backend Supabase debe estar
disponible por separado: generar el APK no crea tablas, RLS, buckets ni servicios.
La web y Google Play tienen su propia preparación. Firebase/push sigue pospuesto.

## 1. Preparar accesos y herramientas

Para configurar esta primera entrega necesitas:

- Permisos en el repositorio para guardar Actions secrets e integrar cambios a `main`.
- Acceso a la URL y a una clave publicable del proyecto Supabase elegido.
- La URL de mapas Positron con una clave cliente válida para esa distribución.
- PowerShell y JDK 17 o Android Studio para generar la firma.

Si **solo compilas mediante GitHub**, no hace falta instalar Flutter ni Android SDK
en tu equipo para ese build: el runner los prepara. Para desarrollar o compilar
localmente sí se necesita Flutter 3.35.3, Android SDK y licencias aceptadas;
consulta [el README](README.md#primeros-pasos).

No necesitas comprar un certificado ni crear una cuenta de Google Play para
distribuir este APK directamente. La contraseña de firma la eliges tú;
no es tu contraseña de Supabase, de GitHub ni de acceso a la aplicación.

## 2. Generar la firma definitiva una sola vez

Si ya distribuiste APK con una firma propia, **reutiliza esa firma** y ve al
apartado de exportación más abajo. Para una primera firma, ejecuta:

```powershell
.\apps\mobile\scripts\Setup-AndroidSigning.ps1
```

Si PowerShell bloquea scripts por su política de ejecución, puedes ejecutar solo
este proceso así, sin cambiar la política global del equipo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\apps\mobile\scripts\Setup-AndroidSigning.ps1
```

El programa `keytool` te pedirá:

1. Una contraseña para el almacén y su confirmación. Guárdala en un gestor de contraseñas.
2. Los datos del titular del certificado: nombre, unidad/equipo, organización,
   ciudad, región y código de país de dos letras. Completa los que correspondan
   a tu equipo y confirma los datos cuando te lo pregunte.
3. La contraseña de la clave. Si ofrece pulsar Enter para usar la misma del
   almacén, puedes hacerlo; en ese caso repetirás esa contraseña en dos secrets.

La contraseña puede no mostrar caracteres mientras escribes: es normal.
El alias predeterminado es **`entrehuellas`**.

Al terminar tendrás estos archivos privados:

| Archivo | Para qué sirve |
| --- | --- |
| `apps/mobile/android/keystore/entrehuellas-release.jks` | Firma con la que Android reconocerá tus actualizaciones |
| `apps/mobile/build/android-signing/keystore-base64.txt` | Representación de esa misma firma para guardarla como secret |

Respalda el JKS, el alias y ambas contraseñas fuera del repositorio. La carpeta
`build` es temporal: puede desaparecer con una limpieza. Base64 también es privado;
codificar un archivo en Base64 no lo cifra. Estos archivos están ignorados por Git.

El script no sobrescribe un JKS existente. Si necesitas volver a obtener el Base64
de la firma predeterminada, ejecuta:

```powershell
.\apps\mobile\scripts\Setup-AndroidSigning.ps1 -ExportOnly
```

Si tu firma existente está en otro lugar o tiene otro alias:

```powershell
.\apps\mobile\scripts\Setup-AndroidSigning.ps1 -ExportOnly -KeystorePath 'C:/ruta/tu-firma.jks' -KeyAlias 'tu-alias'
```

Usa tu JKS real. El archivo `build/android-signing-validation/validation-only.jks`
y cualquier APK `validation-only` pertenecen a las comprobaciones locales;
no son la firma definitiva ni una entrega conectada al backend.

## 3. Completar el JSON para distribución

Se utiliza `apps/mobile/config/release.local.json`,
un archivo **local e ignorado por Git**. Si todavía no existe en tu copia,
créalo desde la plantilla, sin sobrescribir uno existente:

```powershell
if (-not (Test-Path 'apps/mobile/config/release.local.json')) {
    Copy-Item apps/mobile/config/release.local.example.json apps/mobile/config/release.local.json
}
notepad apps/mobile/config/release.local.json
```

La estructura de la plantilla es esta; reemplaza los marcadores con tus valores:

```json
{
  "SUPABASE_URL": "https://TU_PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_TU_CLAVE_PUBLICABLE",
  "EMAIL_OTP_VALIDITY_MINUTES": 15,
  "PUBLIC_CASE_WEB_URL": "https://entrehuellas.app",
  "PUBLIC_CASE_WEB_READY": false,
  "MAP_TILE_URL": "https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=TU_CLAVE_CARTO"
}
```

| Campo | Qué colocar y dónde obtenerlo |
| --- | --- |
| `SUPABASE_URL` | Origen HTTPS de tu proyecto. En Supabase, abre el proyecto y consulta **Connect** para obtener URL y configuración cliente. No añadas `/rest/v1` ni otras rutas. |
| `SUPABASE_PUBLISHABLE_KEY` | Clave del mismo proyecto que comience por `sb_publishable_`. Puedes consultarla en **Connect** o **Settings → API Keys**. Este cliente exige ese tipo de clave. |
| `EMAIL_OTP_VALIDITY_MINUTES` | Duración real de los códigos configurada en Auth. El `15` es una referencia; este campo solo informa en pantalla, no cambia el servidor. Si no está confirmado, puedes quitar el campo y su coma correspondiente. |
| `PUBLIC_CASE_WEB_URL` | Dominio real donde funcionará la web pública. El dominio de la plantilla es la referencia del proyecto, no una confirmación de disponibilidad. |
| `PUBLIC_CASE_WEB_READY` | Mantén `false` mientras no hayas comprobado fichas/QR públicos autorizados en ese dominio. Usa `true` solo tras validarlos. Debe ser un booleano, sin comillas. |
| `MAP_TILE_URL` | URL CARTO Positron con la clave cliente autorizada para el entorno. Pide ese dato al responsable de cartografía; reemplaza `TU_CLAVE_CARTO` y conserva `{z}/{x}/{y}`. No pongas una credencial de backend en la URL. |

Usa JSON válido: comillas dobles, sin comentarios ni coma al final del último campo.
Puedes comprobar su sintaxis sin imprimir valores:

```powershell
try {
    $null = Get-Content -Raw apps/mobile/config/release.local.json | ConvertFrom-Json -ErrorAction Stop
    Write-Host 'Sintaxis JSON correcta'
} catch {
    throw 'No se pudo leer el JSON: revisa la ruta, comillas, comas y booleanos.'
}
```

Ese comando comprueba sintaxis; el workflow además valida campos y marcadores.
No incluyas `service_role`, `sb_secret_`, contraseñas SQL o cuentas de servicio.
La clave publicable está prevista para clientes; permisos, RLS y sesión protegen
los datos. Consulta la [documentación de claves de Supabase](https://supabase.com/docs/guides/api/api-keys).

Quien instala el APK **no recibe ni configura este JSON**. Flutter incorpora
sus valores al compilar; excluirlo de Git no los vuelve secretos dentro del APK.
`supabase.local.json` sigue siendo la configuración independiente de desarrollo.

## 4. Guardar los cinco secrets en GitHub

Abre [el repositorio](https://github.com/srg-cp/entrehuellas) en el navegador:

1. Entra en **Settings** del repositorio, no en los ajustes de tu cuenta.
2. Ve a **Secrets and variables → Actions**.
3. En la pestaña **Secrets**, pulsa **New repository secret**.
4. Copia uno de los nombres de la tabla en **Name** y su contenido en **Secret**.
5. Pulsa **Add secret**. Repite hasta tener los cinco.

| Name exacto | Contenido de Secret |
| --- | --- |
| `MOBILE_CONFIG_JSON` | Todo el JSON del paso 3, desde `{` hasta `}`, con los valores reales; no la ruta del archivo |
| `ANDROID_KEYSTORE_BASE64` | Todo el contenido de `apps/mobile/build/android-signing/keystore-base64.txt`, sin comillas o saltos añadidos; no el JKS binario ni su ruta |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña del almacén elegida en el paso 2 |
| `ANDROID_KEY_ALIAS` | `entrehuellas` si generaste con el valor predeterminado, o el alias de tu firma existente |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave; si elegiste la misma del almacén, vuelve a escribirla aquí |

Para copiar los archivos puedes abrirlos con Notepad y usar Ctrl+A / Ctrl+C;
pégalos directamente en GitHub. No los pegues en chat, issues, PR o YAML.
Cuando guardas un secret, GitHub muestra su nombre y permite actualizarlo;
no permite volver a leer su valor. Por eso necesitas tus propios respaldos.

No crees estos valores en **Variables**. Este workflow lee **Secrets de repositorio**.
Tampoco necesita un secret personal llamado `GITHUB_TOKEN`: GitHub lo proporciona
automáticamente y el job de publicación solicita `contents: write`.

Si no ves Settings o no puedes añadir secrets, debe hacerlo quien administre
los permisos del repositorio. Guía oficial: [secrets de Actions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets).

## 5. Integrar la automatización y comprobar la primera ejecución

Estos cambios deben estar integrados en `main` para activar la publicación
por push. Si todavía están en una rama de trabajo, prepara/revisa el commit y
su PR conforme al [flujo del equipo](README.md#trabajo-en-equipo); no incluyas
archivos ignorados ni fuerces su subida con `git add -f`.

Puedes comprobar que los archivos privados siguen ignorados:

```powershell
git check-ignore apps/mobile/config/release.local.json apps/mobile/android/keystore/entrehuellas-release.jks apps/mobile/android/key.properties apps/mobile/build/android-signing/keystore-base64.txt
git status --short
```

El primer comando debe listar esas rutas. Los archivos privados no deben aparecer
como cambios para incluir en el commit. El workflow, scripts y ejemplos sí se versionan.

Después de integrar el PR a `main`:

1. Abre [Actions](https://github.com/srg-cp/entrehuellas/actions).
2. Selecciona **Flutter** y la ejecución correspondiente al commit integrado.
3. El job **validate** debe terminar correctamente: dependencias, pruebas de
   configuración, formato, análisis y pruebas Flutter.
4. Luego **release** prepara los archivos privados, compila, verifica la firma,
   guarda el artifact y publica la prerelease.
5. Espera a que **release** termine en verde antes de buscar la descarga.

Si `validate` falla, se bloquea la publicación. Si falta un secret o no es válido,
`release` se detiene; consulta el primer paso con error, sin compartir sus valores.

## 6. Ejecutarlo manualmente o repetirlo

Si ya tienes el workflow integrado pero añadiste/corregiste secrets después:

1. Entra en **Actions → Flutter → Run workflow**.
2. Selecciona la rama **main**.
3. Pulsa **Run workflow** y espera `validate` y `release` en verde.

Esta es la opción recomendada cuando quieres un APK nuevo sin cambiar código.
Cambiar un secret por sí solo no lanza un build ni modifica APK ya publicados.

Si no aparece el botón, comprueba permisos de escritura, que el workflow tenga
`workflow_dispatch` integrado en la rama predeterminada y que Actions esté habilitado.
La publicación solo ocurre desde `main`, aunque el selector muestre otras ramas.
Referencia: [ejecución manual de workflows](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow).

Para recuperar una ejecución fallida también puedes usar **Re-run failed jobs**.
Un reintento del mismo run conserva su número y reemplaza los adjuntos de su
prerelease. Un Run workflow nuevo crea otro número de build.

## 7. Descargar e instalar en Android

Abre [Releases](https://github.com/srg-cp/entrehuellas/releases) y busca
**Android build N**, con etiqueta `android-build-N` y marca **Pre-release**.
Elige el número de build mayor: ejecuciones simultáneas pueden terminar en otro orden.
Estas prereleases no se marcan como la release estable «Latest».

En **Assets**, descarga **`entre-huellas-android.apk`**. Los enlaces
«Source code (zip/tar.gz)» son código fuente, no la aplicación instalable.
También se adjunta `SHA256SUMS.txt`; para comprobar una descarga en Windows:

```powershell
Get-FileHash 'C:/ruta/de/descarga/entre-huellas-android.apk' -Algorithm SHA256
```

Compara el hash con el de `SHA256SUMS.txt`; mayúsculas/minúsculas no cambian el valor.

En el teléfono:

1. Descarga o transfiere el APK completo y ábrelo desde Archivos o el navegador.
2. Si Android lo solicita, permite instalar aplicaciones desde **esa fuente**.
   El nombre y la ubicación del ajuste varían según el teléfono.
3. Confirma la instalación, abre **Entre Huellas** y usa tu propia cuenta.
4. Comprueba acceso/códigos, retorno de Google, fotos/cámara, ubicación/mapas y
   los reportes que vayas a utilizar. Comprueba QR si lo habilitaste.

El APK comprobado localmente tiene mínimo Android API 24 (Android 7.0),
target API 36 y soporta ARM32, ARM64 y x86_64. Esa es evidencia del build
actual; revísala si se actualizan Flutter, dependencias o configuración Android.
El teléfono necesita conexión al backend para las operaciones remotas.

Si el repositorio es privado, descargar desde Releases exige acceso al repositorio.
Una vez obtenido, puedes transferir el APK a los testers autorizados; no necesitan
acceso al código, Flutter, el JSON ni la firma privada para instalarlo.

## 8. Publicar futuras versiones y actualizar instalaciones

Con la configuración inicial terminada, el proceso habitual es:

1. Desarrollar y revisar el cambio mediante PR.
2. Integrarlo en `main`.
3. Esperar la validación y publicación automáticas.
4. Descargar el APK de mayor build y distribuirlo al grupo de prueba.

**Conserva el mismo JKS, alias e identificador Android**
(`com.example.flutter_application_entrehuellas`). No generes otra firma por versión.
El workflow incrementa `versionCode` como `10000 + github.run_number`;
no hace falta modificar el JSON para cada build. El nombre visible de versión,
por ejemplo `0.1.0`, procede de `apps/mobile/pubspec.yaml` y se cambia cuando
corresponda al versionado del producto.

El usuario instala el APK nuevo sobre el anterior. Firma e identificador iguales,
y un número mayor, permiten actualizar conservando los datos locales.
Una instalación anterior con firma **debug** no se actualiza con la firma nueva:
puede requerir desinstalarla, lo que elimina sus datos locales. No sugieras
desinstalar una app con información pendiente sin revisar primero esa información.

No hay actualizador automático dentro de la app. Para corregir configuración
cliente, actualiza el JSON local y el secret `MOBILE_CONFIG_JSON`, genera otro
build e instala ese APK. Mantén ambos valores sincronizados.

## Compilar localmente (opcional)

Este apartado no es necesario si utilizas Actions. Requiere Flutter/Android SDK,
la configuración del paso 3 y tu JKS definitivo.

Desde la raíz, prepara el archivo de firma sin sobrescribir uno existente:

```powershell
if (-not (Test-Path 'apps/mobile/android/key.properties')) {
    Copy-Item apps/mobile/android/key.properties.example apps/mobile/android/key.properties
}
notepad apps/mobile/android/key.properties
```

Completa estos datos con tus valores reales; la ruta debe usar `/`:

```properties
storeFile=C:/ruta/absoluta/al/proyecto/apps/mobile/android/keystore/entrehuellas-release.jks
storePassword=TU_CONTRASENA_DEL_ALMACEN
keyAlias=entrehuellas
keyPassword=TU_CONTRASENA_DE_LA_CLAVE
```

Es formato Java properties: escapa `\` como `\\` si está en la contraseña
y los espacios iniciales como `\ `. También se puede firmar con variables de
entorno, como describe la [ficha técnica](docs/funcionalidades/distribucion-android.md).

Desde `apps/mobile`, resuelve dependencias y compila:

```powershell
Set-Location apps/mobile
flutter pub get --enforce-lockfile
flutter build apk --release --dart-define-from-file=config/release.local.json --build-number=10001
```

El `10001` es un ejemplo: usa un número mayor que el instalado y coordínalo con
CI para no impedir después sus actualizaciones. El APK queda en
`apps/mobile/build/app/outputs/flutter-apk/app-release.apk` respecto a la raíz.
Una release sin firma configurada falla deliberadamente; debug mantiene su firma
de desarrollo. Referencia: [distribución Android con Flutter](https://docs.flutter.dev/deployment/android).

## Problemas frecuentes

| Síntoma | Qué revisar |
| --- | --- |
| El script dice que el keystore ya existe | Respalda y reutiliza ese JKS; usa `-ExportOnly`. No lo borres para generar otra firma. |
| No encuentra `keytool` | Instala/configura JDK 17 o Android Studio; el script busca keytool en PATH y en la ubicación habitual de Android Studio en Windows. |
| `Missing GitHub Actions secrets/environment` | Crea el secret indicado con el nombre exacto, en el repositorio y en la pestaña Secrets. |
| JSON inválido o marcadores `TU_`/`API_KEY` | Corrige el archivo y vuelve a guardar el JSON completo en `MOBILE_CONFIG_JSON`. |
| Alias/contraseña incorrectos o Base64 inválido | Confirma que Base64, alias y ambas contraseñas pertenecen al mismo JKS; vuelve a exportar el original. |
| `Release signing is missing` al compilar localmente | Completa `apps/mobile/android/key.properties` o las variables ANDROID_*; los secrets de GitHub no se descargan a tu PC. |
| Actions falla por pruebas, análisis o formato | Corrige el error de validación antes de publicar; no omitas el job. |
| Error 403 o permisos al crear release/tag | Revisa políticas de Actions y tags con el administrador; el job ya solicita `contents: write`. No pegues un PAT en el YAML. |
| APK compilado pero publicación fallida | El artifact `android-N-intento` permanece 14 días en la ejecución; se descarga como ZIP con APK y checksum. Corrige permisos y reintenta. |
| La app no se instala o no actualiza | Comprueba Android compatible, descarga completa, firma del APK anterior y número de versión. No instales un build anterior sobre uno posterior. |
| Abre pero no conecta o no llegan códigos | Revisa proyecto Supabase, Auth/correo, conectividad y activación del backend con [CONFIGURACION.md](docs/CONFIGURACION.md); no reapliques todo el SQL. |
| No se ven los mapas | Revisa la clave cliente/URL Positron y las condiciones del proveedor; corrige el secret y genera un APK nuevo si cambias la configuración. |
| Java se queda sin memoria al compilar localmente | CI ya limita heap a 3 GB y 2 workers. Revisa memoria/procesos de tu equipo y el diagnóstico en [ESTADO](docs/ESTADO.md); no desactives R8 o firma para eludirlo. |

## Estado de la preparación

### Configuración inicial completada —24/10/2026

El usuario confirmó en este chat que generó su firma definitiva, guardó los
**cinco secrets de repositorio en GitHub** y completó `key.properties` con sus
datos reales para compilar localmente. Se comprobó la existencia local del JKS,
Base64, JSON de release y `key.properties`; este último está ignorado y no
versionado. No se leyeron ni se incluyen aquí contraseñas o valores de los secrets.
La confirmación de carga en GitHub procede del usuario; no es una auditoría
remota ni una comprobación de que las contraseñas coincidan.

### Inventario: origen y ubicación de cada dato

Las rutas siguientes son relativas a la raíz del repositorio. Los archivos
privados están ignorados por Git. En GitHub, los cinco valores se mantienen en
**repositorio → Settings → Secrets and variables → Actions → Secrets**.

| Secret de GitHub | Origen / copia local para uso operativo | Cómo mantenerlo o recuperarlo |
| --- | --- | --- |
| `MOBILE_CONFIG_JSON` | Contenido completo de `apps/mobile/config/release.local.json`; para el mismo entorno se pueden reutilizar los valores cliente de `supabase.local.json` | Editar el JSON y actualizar el secret con todo su contenido. Generar otro APK para aplicar los cambios. |
| `ANDROID_KEYSTORE_BASE64` | Contenido de `apps/mobile/build/android-signing/keystore-base64.txt`, obtenido del JKS definitivo en `apps/mobile/android/keystore/entrehuellas-release.jks` | Si se pierde el TXT o se limpia `build`, regenerarlo desde el mismo JKS con `Setup-AndroidSigning.ps1 -ExportOnly`. No generar otra firma. |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña elegida al crear el JKS; copia operativa en la propiedad `storePassword` de `apps/mobile/android/key.properties` | Respaldar en un gestor de contraseñas. GitHub no permite leer de vuelta el secret; el JKS/Base64 no recupera una contraseña olvidada. |
| `ANDROID_KEY_ALIAS` | Alias de la clave; valor usado en este recorrido: `entrehuellas`. Copia operativa en `keyAlias` del mismo `key.properties` | Mantenerlo junto al respaldo del JKS y usar el mismo alias en local y GitHub. |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave; copia operativa en `keyPassword` de `key.properties` | Si se eligió Enter durante la creación, coincide con la del almacén. Guardarla igualmente en el gestor y en este secret separado. |

`key.properties` también contiene `storeFile`, la ruta al JKS local; esa ruta
no es un secret adicional de GitHub. El runner prepara su propia ruta temporal.
GitHub compila con sus secrets y no descarga el `key.properties` de tu equipo.
No se centralizan ni duplican estas contraseñas en `.env.local`.

**Respaldo privado:** conservar JKS, alias y ambas contraseñas fuera del
repositorio, con contraseña/nota en el gestor elegido por el responsable.
La ubicación de ese respaldo no se registra en este documento público ni se ha
confirmado en esta sesión. La carpeta `build` y el `key.properties` operativo no
sustituyen ese respaldo. No pegar valores reales en Markdown, YAML, PR o chat.

### Pendientes de activación y validación

- Confirmar que el respaldo privado de firma y contraseñas esté realizado.
- Confirmar que la configuración versionada del workflow esté integrada en `main`.
- Ejecutar **Actions → Flutter → Run workflow → main** y verificar `validate`
  y `release` en verde con la firma/secrets definitivos.
- Descargar e instalar el APK resultante y comprobar recorridos con backend real.

No hace falta repetir la generación de firma ni volver a crear los cinco secrets
si ya están correctos. Las copias locales y GitHub no se sincronizan: cualquier
cambio debe actualizarse en los lugares que lo consumen. Ninguna ejecución de
Actions o release con la firma definitiva queda acreditada por este registro.

### Evidencia histórica de infraestructura —22/10/2026

La infraestructura se comprobó localmente entonces: 518 pruebas Flutter y 5 Python,
formato/análisis, actionlint, exportación de firma y rechazo de release sin firma.
Se compiló un APK universal con JDK 17 y firma desechable verificada con apksigner.
Ese APK usó configuración ficticia y **no es el APK real para distribuir**.

Esa prueba histórica usó firma desechable; no comprueba los secrets definitivos
cargados posteriormente. El estado actual y los pendientes están arriba.
La evidencia y los límites están en [ESTADO](docs/ESTADO.md) y en la
[ficha técnica de distribución](docs/funcionalidades/distribucion-android.md).
