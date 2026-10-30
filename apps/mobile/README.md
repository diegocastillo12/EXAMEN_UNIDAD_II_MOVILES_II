# Entre Huellas: aplicación Flutter

Aplicación de recuperación colaborativa de mascotas. Android es la plataforma prioritaria; se conservan las demás plataformas del proyecto existente.

## Arquitectura

Clean Architecture por funcionalidad con MVVM en presentación. Las pantallas consumen ViewModels; las operaciones se expresan como casos de uso; los repositorios y adaptadores concentran el acceso a Supabase. Riverpod gestiona estado e inyección y go_router la navegación.

Esta separación permite probar las reglas y estados sin un servidor y preparar la coordinación futura de datos remotos, borradores y envíos pendientes. La justificación completa está en [ADR-001](../../docs/decisiones/001-arquitectura-aplicacion.md). Los límites obligatorios se describen en [REGLAS_ARQUITECTURA.md](../../docs/REGLAS_ARQUITECTURA.md) y el árbol de componentes en [ARQUITECTURA.md](../../docs/ARQUITECTURA.md).

## Desarrollo

Flutter 3.35.3 / Dart 3.9.2. Desde esta carpeta:

```powershell
flutter pub get --enforce-lockfile
flutter run -d chrome
```

Para conectar Supabase, completar `config/supabase.local.json` con URL y clave publicable siguiendo [CONFIGURACION.md](../../docs/CONFIGURACION.md). Ese archivo está ignorado por Git. En VS Code, seleccionar **Entre Huellas - desarrollo local** y ejecutar con F5; el perfil **Entre Huellas - sin Supabase** permite explorar la app sin configuración.

En VS Code, Run/Debug de `main.dart` utiliza el perfil local mediante `templateFor`. Se puede seguir usando el botón de ejecución de Dart/Flutter y elegir el emulador; para cargar cambios del JSON hay que detener e iniciar la app de nuevo.

Por terminal, el arranque configurado es:

```powershell
flutter run --dart-define-from-file=config/supabase.local.json
```

El mapa claro usa CARTO Positron cuando `MAP_TILE_URL` del JSON local apunta a
`https://basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=TU_API_KEY`.
Sustituir el marcador por la clave de mapas de CARTO; no versionar el archivo local.
La app muestra los créditos enlazados del proveedor y conserva los pines de marca.
Detener e iniciar la ejecución tras cambiar la URL; hot reload no actualiza
dart-defines. Sin este valor se conserva el mapa OSM estándar de desarrollo.

## APK y distribución

La [guía de distribución Android](../../docs/funcionalidades/distribucion-android.md)
explica la preparación de firma y los cinco secrets. `.github/workflows/flutter.yml`
valida y publica una prerelease con APK firmado por cada push a `main`.
Las releases sin firma propia fallan; debug conserva su configuración habitual.

## Comprobaciones locales

El icono del launcher Android utiliza los originales de `logo`. Regeneración e instrucciones de instalación en [logo/README.md](../logo/README.md).

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub --dart-define=AMBIENT_BACKGROUND_MOTION=false
```

Las nubes del fondo tienen movimiento ambiental continuo. Las regresiones y
capturas lo fijan con `AMBIENT_BACKGROUND_MOTION=false` para esperar solo las
transiciones de contenido. En la app está activado por defecto y se detiene
con movimiento reducido o al quedar la ruta fuera de TickerMode.

La base implementa navegación, arranque, sesión, ingreso y registro por correo. Perfil y recuperación siguen dentro de HU-01. Consultar [ESTADO.md](../../docs/ESTADO.md) para resultados de pruebas y pendientes de Android/Supabase.

El formulario de acceso sigue el mockup de login y conecta correo/contraseña y Google mediante casos de uso y repositorios. El SQL de perfiles se prepara desde [database](../../database/README.md); aplicar y validar en desarrollo siguiendo [CONFIGURACION.md](../../docs/CONFIGURACION.md). Crear cuenta, confirmación por OTP y recuperación de contraseña están implementados localmente. Registro y recuperación usan seis casillas y códigos verificables aunque el correo se lea en otro equipo. Recuperación incluye solicitar/reenviar código, verificarlo para abrir el formulario de contraseña nueva y cerrar la sesión de recuperación al completar/cancelar. El editor de perfil y la validación remota aún están pendientes.
