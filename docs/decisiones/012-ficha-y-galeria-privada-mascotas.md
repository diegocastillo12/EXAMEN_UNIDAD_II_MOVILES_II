# ADR-012: ficha ampliada y galería privada de mascotas

Fecha: 9 de octubre de 2026. Estado: aceptada para la ampliación solicitada por el usuario.

## Alcance y presentación

Amplía ADR-010: flecha de retorno fija bajo SafeArea, fuera del scroll y de los efectos de entrada; título y contenido alineados arriba. «Otra especie» requiere tipo concreto de 1–60 puntos de código, con trim Unicode. Perro/gato descartan ese detalle. Tamaño opcional small/medium/large, tres controles horizontales Pequeño/Mediano/Grande; tocar el seleccionado lo devuelve a desconocido. No imponer un tamaño ficticio.

Registro y edición permiten seleccionar hasta tres fotos de galería, consultar miniaturas y retirar fotos. Ficha muestra fotos confirmadas, listado usa la primera confirmada como portada; sin foto conserva el icono. Superficies neutras y acción carbón, shared shimmer durante trabajo real; errores contextuales según ADR-005. El toast de mascota guardada solo aparece después de confirmar metadatos y todas las fotos seleccionadas. No ampliar la excepción de errores de avatar a la galería de mascotas.

## Capas, reintento y privacidad

PetPhotoRepository y ManagePetPhotos expresan operaciones de selección, recuperación, consulta, subida y retirada, sin Flutter/SDK en dominio. PetPhotosViewModel autoDispose coordina estado por mascota/cuenta; bootstrap inyecta fuentes nativa y Supabase. SDK, SharedPreferences y procesamiento se encapsulan en data. Guardas por generación/cuenta descartan respuestas tardías; keepAlive acotado durante operaciones.

Cada selección recibe UUID estable. Primero se confirma la mascota, después cada foto; ante error quedan pendiente sus bytes/IDs en el editor y no se vuelve a crear la mascota. Un reintento reserva/sube/confirma el mismo ID; las fotos ya confirmadas no se repiten. Borradores aún en memoria no forman una cola offline persistente. Si Android destruye la actividad del selector, un marcador de cuenta/mascota permite recuperar la selección como borrador explícito, sin subir automáticamente; el selector de Perfil no consume datos perdidos sin su propio marcador. Al perder el proceso después de reservar, la consulta intenta confirmar objetos completos; reservas sin archivo permanecen retirables y cuentan para el límite.

Cliente normaliza a JPEG, conserva proporción, máximo 1280 píxeles por lado y elimina EXIF/GPS al componer una imagen nueva. Entrada limitada antes de decodificar; bucket privado pet-photos admite JPEG de hasta 2 MiB. Ruta owner/pet/photo.jpg, URLs firmadas por una hora. Reserva requiere dueño y bloquea la mascota para aplicar el límite de tres; confirmación comprueba objeto/ruta/MIME/tamaño; retirada de metadata exige borrar primero el archivo. RLS restrictiva impide acceso a otra cuenta aun con políticas Storage permisivas ajenas. Roles cliente solo consultan metadata propia, sin escrituras directas.

Estas son fotos privadas del dueño, no recursos públicos del QR/casos. La validación de MIME/tamaño del servicio y metadata no demuestra contenido seguro ante cliente malicioso: sanitización de bytes y miniaturas públicas en servidor, cámara y pruebas del runtime quedan pendientes de HU-04.1 / #30. No marcar esa historia Done por este incremento. Galería privada completa el recorrido solicitado sin exponer originales públicamente.

## Datos y verificación

Fuentes nuevas 019–025, plan 006 y migración/patch generados; no se reescribe SQL anterior. create_pet_v2/update_pet_v2 incluyen tipo/tamaño y conservan deduplicación/versionado; permisos anteriores create_pet/update_pet se revocan para impedir bypass de la validación nueva. Filas históricas other pueden mantener detalle null hasta su próxima edición. Aplicar patch 006 después de 005 y ejecutar la app actualizada; clientes anteriores no escriben mediante las RPC retiradas.

Pruebas locales de permisos entre cuentas/anónimo, reserva/límite/confirmación/retirada/reintento, campo requerido y tamaños; SDK HTTP y normalización/EXIF, recuperación nativa simulada y guardado parcial, UI normal/pequeña con texto ampliado. PostgreSQL local y sustitutos no acreditan ejecución remota Supabase ni apertura/fluidez de galería Android. El patch y la demo con dos cuentas siguen pendientes de activación remota.
