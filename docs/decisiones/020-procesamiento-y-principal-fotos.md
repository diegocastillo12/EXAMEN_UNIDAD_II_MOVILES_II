# ADR-020: procesamiento protegido y foto principal de mascotas

Fecha: 10 de octubre de 2026. Estado: implementada localmente; activación y validación integrada pendientes. HU-04.1 / issue #30, HU-04.2 / issue #31, RF-03, S2. Amplía ADR-012 y ADR-017, sin alterar las fronteras de arquitectura ni el alcance público del MVP.

## Decisión

La galería permite elegir cámara o galería y una principal mediante estrella. Selecciones, retiradas y principal permanecen como borrador hasta Registrar/Guardar. Descartar no escribe. La principal de fotos confirmadas se conserva por mascota; al retirar la principal se elige la publicada más antigua (created_at/id), o ninguna si no quedan fotos. Listado usa la miniatura de la principal; ficha usa la imagen limpia. Las fotos históricas siguen privadas y visibles con su ruta anterior, sin inventar una verificación de servidor.

El dominio continúa expresando operaciones mediante ManagePetPhotos y PetPhotoRepository. PetPhotoOrigin no conoce ImagePicker. ViewModel conserva pendientes, versión de selección, errores y protección de cuenta/disposición. Data encapsula selector, SDK, DTO y llamada Edge; presentación no obtiene repositorios ni acceso a Storage. Se conservan ADR-016 para feedback, componentes/reveals existentes y pruebas arquitectónicas.

## Procesamiento y acceso

`pet-photo-process` valida la sesión con Auth.getUser y la propiedad antes de leer/decodificar. Flutter envía JPEG normalizado, hasta 2 MiB y 1280 por lado; galería/cámara convierten formatos soportados en cliente. Servidor acota el cuerpo incluso sin Content-Length, verifica cabecera/dimensiones y decodifica completamente con magick-wasm 0.0.44. Autoorienta, elimina perfiles/comentarios y recodifica JPEG: imagen hasta 1280 y miniatura proporcional hasta 320 (máximo 256 KiB). Entradas inválidas no reservan plaza. Límites de decoder: ancho/alto1280, caché64 MiB y disco0. WASM se prepara desde dependencia y lock versionados; no se obtiene código remoto en cada petición.

La clave de servidor permanece en Edge; Flutter conserva clave publicable/sesión. `verify_jwt=false` permite validar explícitamente mediante Auth las sesiones con claves actuales: no vuelve público el procesamiento. CORS acepta encabezados de sesión/IDs sin cookies; no sustituye autorización.

Dos buckets **privados**, pet-photo-renditions y pet-photo-thumbnails, admiten escritura solo de servidor. RLS restrictiva evita que políticas permisivas ajenas permitan insertar/modificar derivados o leer archivos de otra cuenta. El dueño puede leer y retirar sus archivos. Durante retirada/baja se permite SELECT de metadata necesaria para que Storage DELETE funcione. No hay bucket público ni se publican fotos de mascotas sin caso: S3 debe exponer únicamente derivados verificados mediante el contrato público autorizado. Nunca exponer directamente pet-photos ni convertir buckets privados en públicos.

SQL044–047/plan012 añaden processed_at, hash de entrada, principal, versión independiente de selección y tombstones privados. Solo servicio ejecuta prepare/complete: cliente no puede afirmar procesamiento ni reutilizar publish/reserve antiguos. UUID+SHA256 fijan el contenido de cada reintento. Publicación interna exige ambas salidas; UUID retirado no puede revivir con una carga tardía. Principal usa bloqueo del padre, índice único y CAS de versión; reconoce respuesta perdida inmediata y rechaza conflictos. No se modifica la versión de metadatos de la mascota por elegir portada.

## Fallos y transición

SQL012 y Edge deben activarse juntos antes de usar la nueva app. La app antigua conserva lectura pero no puede subir por el circuito antiguo después del patch: es una restricción deliberada para impedir saltar la validación. Las fotos anteriores tienen processed_at nulo, siguen privadas y **no son aptas para exposición pública**. Se pueden retirar/reemplazar; su conversión antes de publicar un caso requiere procesamiento explícito, nunca una actualización SQL que declare bytes seguros sin leerlos.

Guardar continúa siendo una secuencia de operaciones según ADR-017, no una transacción distribuida. Reintentar conserva IDs y confirma solo respuestas válidas. Retirada marca removing antes de borrar los tres posibles archivos; finish rechaza archivos restantes y conserva estado para reintento. Baja de mascota limpia los tres buckets y valida ausencia en servidor. Si el worker termina abruptamente tras una escritura puede quedar un archivo privado sin confirmación o huérfano tras una retirada concurrente: no se hace público, pero debe comprobarse y limpiarse operativamente. No se introduce un worker ni una promesa de atomicidad/limpieza automática.

## Evidencia y límites

225 pruebas Flutter, 15 SQL/PGlite y pruebas Deno del decoder/handler aprobadas; renders normal/pequeño con texto2. PGlite usa metadata de Storage simulada; Deno ejecuta WASM real con EXIF/GPS y SDK HTTP sustituido. Estas pruebas no prueban Storage/Auth remotos ni la cuota hosted. La documentación de Supabase indica 256 MiB y 2 segundos CPU: [límites](https://supabase.com/docs/guides/functions/limits), [procesamiento WASM](https://supabase.com/docs/guides/functions/examples/image-manipulation), [empaquetado](https://supabase.com/docs/guides/functions/wasm).

Activación y demo Android/Supabase pendientes, sin cierre de historias. El intento de APK falla antes de compilar por la conexión loopback de Java/Gradle. No afirmar que el rendimiento local acredita la cuota real; la aceptación requiere medirlo en desarrollo y comprobar cámara/permisos, bytes descargados de ambos derivados y aislamiento entre cuentas.
