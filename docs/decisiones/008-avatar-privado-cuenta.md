# ADR-008: foto de perfil privada y correo de solo lectura

Fecha: 8 de octubre de 2026. Estado: aceptada por petición explícita del usuario.

## Alcance y decisión

El usuario solicita subir una foto de perfil y visualizar el correo sin editarlo. Es una ampliación explícita de HU-01.7 / RF-01, distinta de las fotografías públicas de mascotas de S2. El correo se proyecta únicamente desde la identidad actual de Supabase Auth; no se copia a public.profiles ni se añade una operación para modificarlo.

La foto se selecciona desde galería mediante image_picker, se normaliza a JPEG cuadrado 512 × 512 con orientación aplicada y píxeles copiados a una imagen nueva sin EXIF/GPS. Se limita entrada a 10 MiB y dimensiones a 4096/16 millones de píxeles, y salida a 2 MiB. image/shared_preferences ya existían como dependencias transitivas; se declaran directas para su uso en fuentes de datos. SDK, selección, procesamiento y almacenamiento permanecen en data_sources/repositorios, con casos de uso y ViewModels en sus capas correspondientes.

## Almacenamiento y autorización

Bucket privado profile-avatars, MIME image/jpeg y límite 2097152 bytes. Cada cuenta utiliza exclusivamente `<auth.uid()>/avatar.jpg`, con upsert: reintentos del mismo payload no crean otro objeto. Políticas propias de lectura/insert/update y guardas restrictivas para impedir que políticas permisivas de otros buckets expongan avatares. Anónimos no acceden a este bucket. No se publican imágenes mediante getPublicUrl.

Lectura mediante URL firmada de una hora para la cuenta actual; el avatar propio prevalece sobre foto externa de Google. Sin foto/configuración del bucket se conservan las consultas de nombre/ciudad/correo y el respaldo de Google/iniciales. Subida solo se confirma después de upload y lectura firmada autorizada; una respuesta perdida puede haber aplicado la operación y se permite reintentar el mismo objeto. No afirmar que un fallo garantiza reversión del archivo remoto.

Fuentes SQL 010–011 por tipo de objeto; plan 003 genera migración nueva, manteniendo inmutables 001–009 y sus migraciones. run_all se amplía desde el generador con operaciones repetibles y pruebas de Storage mínimas en PostgreSQL local. La configuración real de bucket/políticas y los bytes servidos se verifican en Supabase por separado.

## Estado, recuperación y UI

Avatar/cámara y Añadir/Cambiar foto abren galería; el botón conserva etiqueta y usa LoadingShimmer durante selección/subida. Cancelar no sube nada. Un fallo conserva bytes en el estado de pantalla para reintentar. Cambiar cuenta invalida resultados anteriores y descarta selección en memoria. El ViewModel autoDispose mantiene una referencia temporal solo durante la operación confirmada: cerrar el editor permite terminar la subida y actualizar la cabecera de la misma cuenta, sin recrear el toast de la pantalla cerrada; la referencia se libera en finally. El éxito actualiza avatar sin sobrescribir nombre/ciudad todavía editados y usa el toast propio de ADR-007.

Antes de abrir galería se guarda el propietario de la selección pendiente. retrieveLostData solo devuelve la imagen a esa cuenta; otra identidad la descarta. Una selección recuperada se muestra como vista previa y requiere Guardar foto recuperada o Descartar, nunca sube automáticamente. Este marcador de propietario es local y no sustituye autorización del servidor ni onboarding por cuenta. No es una cola offline persistente de subidas.

## Validación y límites

Pruebas de correo de solo lectura, cancelación/duplicados/reintento/identidad, procesamiento JPEG/EXIF, recuperación por propietario y contrato HTTP de Storage. SQL prueba bucket/limites/políticas repetidas con cuentas distintas y políticas permisivas ajenas. Revisar normal/pequeño con texto ampliado, error/carga y campos accesibles por scroll.

La foto necesita aplicar la migración en desarrollo y una compilación nueva para instalar el plugin nativo; Hot Restart no lo instala. El build y la subida real en Android/Supabase no se consideran acreditados por pruebas de widget, HTTP sustituido o PGlite. Cuenta/baja requerirá limpieza de archivos cuando se implemente ese flujo; no se agrega en este incremento.

Revisión de UI autorizada en ADR-009: avatar como único control habitual, LoadingShimmer sobre él y errores de foto en toast compartido con icono de error. Se retiran botón duplicado y texto permanente; recuperación excepcional conserva confirmación explícita y reintento desde avatar conserva bytes. Sustituye la composición y feedback contextual de foto descritos arriba; contrato de almacenamiento sin cambios.
