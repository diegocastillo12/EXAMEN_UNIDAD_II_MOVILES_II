# Fotos de mascotas: cámara, galería, principal y procesamiento

**Auditoría de seguimiento18/10:** HU-04/#4 y derivadas #30/#31 en Done: cámara/galería, procesamiento/miniaturas y principal/retirada implementados e integrados.012/WASM/guardado confirmados y fuentes/pruebas concretas verificadas. Las notas antiguas de cámara/principal todavía por implementar quedan sustituidas; se conservan límites de QA sin atribuir una nueva demo a esta auditoría.

Módulo: `pets`; servidor: `pet-photo-process`. HU-04 / RF-03;
[#30](../backlog/030-HU-04.1.md) y [#31](../backlog/031-HU-04.2.md).

## Qué hace y cómo se usa

En Registrar/Editar se seleccionan hasta tres fotos desde galería o cámara.
Cancelar la selección no añade una foto; denegar cámara no bloquea galería.
El botón de cámara se oculta al llegar al límite. Una selección nativa
interrumpida se recupera solo para la cuenta correspondiente.

La estrella elige la principal. Añadir, retirar o cambiar principal modifica
el borrador; el servidor se actualiza al pulsar Registrar mascota/Guardar cambios.
Descartar antes de guardar conserva las fotos confirmadas. Un fallo conserva
los pendientes para reintentar. Retirar la principal confirmada elige como
reemplazo la publicada más antigua. La principal se usa como portada de la mascota.

## Qué sucede al guardar

1. Flutter normaliza la imagen a JPEG, con dimensión máxima1280 y cuerpo hasta2MiB.
2. Envía bytes, ID de mascota e ID estable de foto a la función, usando su sesión.
3. El servidor comprueba la sesión y propiedad antes de leer/decodificar la imagen.
4. Valida tamaño, dimensiones y JPEG real. `magick.wasm` decodifica, corrige
   orientación y elimina EXIF/GPS; genera JPEG de hasta1280 y miniatura de hasta320.
5. Reserva por UUID/hash, guarda ambos derivados privados y confirma publicación
   solo cuando sus archivos cumplen los requisitos.
6. La app obtiene acceso firmado y muestra la foto confirmada.

`magick.wasm` es el motor de imágenes que ejecuta el servidor automáticamente.
No es un botón de Flutter ni un programa que el usuario deba ejecutar por foto.
El nombre interno published no implica acceso público: ambos buckets son privados.

## Persistencia, concurrencia y eliminación

El mismo UUID y contenido reconocen reintentos; otro contenido con el mismo ID
se rechaza. Principal única y versión independiente evitan sobrescribir una
selección concurrente; el conflicto permite consultar las fotos actuales.
Antes de borrar bytes se marca retirada; después se limpian los buckets y se
confirma. La marca histórica impide revivir una foto eliminada mediante reintento.

No existe transacción distribuida entre PostgreSQL y Storage. Una interrupción
puede dejar archivos privados incompletos que requieren revisión operativa.
Las fotos históricas no se convierten automáticamente ni reciben processed_at
inventado. Su eventual exposición en casos requiere derivados verificados y
una proyección pública autorizada.

## Activación en Dokploy

Requiere patch012 y el servicio functions con código, dependencias y WASM.
Kong envía `/functions/v1/` al servicio. El router incluye el WASM con staticPatterns
al crear el worker; copiar el archivo sin incluirlo en ese FS virtual no basta.
Las claves de servidor permanecen allí; Flutter usa sesión y clave publicable.

El procedimiento mantenido está en [supabase/self-hosted](../../supabase/self-hosted/README.md),
con generador de paquete, Compose y corrección del fallo NotFound observado.
Hot reload solo actualiza Flutter; no instala ni actualiza el servidor.

## Validación y lo pendiente

El usuario confirma patch012 aplicado, archivo instalado, servicio encendido,
HTTP401 anónimo y guardado desde la app tras corregir la inclusión del WASM.
Las pruebas locales de procesador real/handler/router suman10 aprobadas; los
resultados Flutter/SQL del incremento constan en [ESTADO](../ESTADO.md).

Ese guardado no acredita por sí solo todos los criterios: faltan comprobaciones
reales de reapertura, cámara/permisos, principal/retiro, usuarios A/B, EXIF/GPS de
archivos descargados y recursos bajo imágenes de detalle. Las historias no se
cierran automáticamente. Decisiones: [ADR-017](../decisiones/017-borrador-fotos-mascotas.md)
y [ADR-020](../decisiones/020-procesamiento-y-principal-fotos.md).

## Publicación seleccionada desde HU-05

El nuevo reporte permite seleccionar de una a tres fotos para publicar. Solo derivados verificados de fotos elegidas en casos activos admiten lectura pública mediante RLS, manteniendo buckets/originales privados. Fotos antiguas sin procesamiento deben volver a guardarse antes de publicar. Retirar una foto revoca nuevas lecturas públicas de esa foto y puede reducir la galería del caso; URLs ya firmadas duran hasta cinco minutos. Patch013 ejecutado según confirmación del usuario; validación remota pendiente; [Casos perdidos](casos-perdidos.md) y ADR-021 precisan el contrato.

## Reutilización segura para encontrados — HU-06

El selector/normalizador local pasa a core con wrappers compatibles y marcador de recuperación separado por contexto. El mismo procesador Edge acepta x-found-case-id para fotos de reportes sin perfil de mascota: autorización del reportero, buckets privados propios y atestación de derivados antes de publicar. Fotos de mascotas conservan rutas, reservas y portada previas. Requiere patch014 y handler actualizado; [Casos encontrados](casos-encontrados.md) y ADR-022 detallan publicación, privacidad y limpieza de pendientes.

## Recuperación de consulta — 10 de octubre de 2026

Tras aviso de consulta fallida en Editar mascota, comprobación autenticada real de lista y firmas respondió200. Reconsulta del ViewModel en Android recuperó galería y limpió error/toast/invalid sin Guardar ni modificar metadata. No se reinició ni reconfiguró Dokploy/Supabase. Esta lectura correcta no acredita subida nueva, procesamiento ni publicación de un caso; el fallo previo no quedó capturado y su causa no se afirma resuelta. Evidencia en ESTADO; no requiere otro patch de fotos.

El usuario aclaró después que el aviso aparece al guardar. El estado conserva la operación fallida (consulta, selección o guardado) y el toast se decide por esa operación, sin inferirla de los borradores restantes. Los errores de la galería de detalle usan también el toast superior. El diagnóstico técnico registra solo operación/tipo/código; los rechazos Storage se traducen a fallos de dominio. Pruebas locales cubren aviso de guardado sin borradores, recuperación de consulta y firma Storage403; análisis limpio y23 pruebas pertinentes aprobadas. Cambio cargado en Android, lectura real correcta; guardado de la foto del usuario y causa remota siguen pendientes de captura. Sin nuevo patch ni cambios en Dokploy.

Revisión posterior: Android conservaba fallo de guardado sin operaciones de fotos pendientes; no acredita éxito ni permite reconstruir el comando previo. Procesador y handler pasan11 pruebas locales, incluidos contratos de mascotas conservados tras HU-06. El paquete local coincide con la fuente del handler; esto no confirma qué código ejecuta Dokploy. No se declara reparación del guardado ni se altera el backend durante esta revisión.

## Corrección del ciclo de actualización al guardar — 10 de octubre de 2026

El intento del usuario se capturó en Android: `CircularDependencyError` en
`savePendingChanges`, con la ficha como dependencia circular. La galería
invalidaba la ficha, que a su vez observa el notifier de fotos. Tras confirmar
una retirada o principal, esa invalidación lanzaba un error local y mostraba
fallo de guardado incluso con los pendientes ya consumidos.

La galería actualiza su estado y el listado; el editor coordina la actualización
de la ficha al terminar el guardado. Se eliminan las dos invalidaciones inversas,
conservando inicialización, validación, borradores, reintentos y contratos remotos.
Tres pruebas con ficha, editor y listado observados reproducían el fallo antes
de corregirlo y pasan después: retirada, principal y reemplazo. Las34 pruebas
pertinentes y análisis pasan; cambio cargado mediante hot reload sin reiniciar
Android. Falta confirmar un nuevo guardado integrado tras esta corrección;
no modifica SQL, Storage ni el handler.


## Galería compartida con reportes — 10 de octubre de 2026

Se extraen PhotoGalleryStrip y PhotoGalleryTile a core desde PetPhotoGallery, conservando scroll horizontal, geometría, retirada/principal y borradores. La ficha de mascota y el reporte perdido usan la misma regla de tamaño112–160. El reporte solo selecciona fotos ya guardadas para exposición pública; sus casillas no modifican ni suben fotos de la mascota. No cambia el contrato de fotos, SQL o Edge. Validación local y pendientes en ESTADO.

## Corrección de consistencia — 11 de octubre de 2026

PetPhotosState protege colecciones y PetPhotoDraft protege una copia de bytes. La preparación de imágenes comparte limpieza/límites/orientación con perfil y reportes, preservando la recuperación por contexto. Feedback de error solo en toast.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.


## Casos con la referencia aprobada de Mascotas — 11 de octubre de 2026

Por instrucción del usuario, la UI de Mascotas se conserva y se reutiliza en Casos. EntityScreenShell y entityEditorPage extraen su contenedor/apertura existentes: mismos márgenes, navegación glass y cover→stagger, fuente visual del botón y retorno. Registrar perdido/encontrado desde Reportar o+ usa esa misma transición; todos los campos, fotos, instrucciones y acciones participan del timeline existente, sin reiniciarlo por edición/teclado/selección. PhotoAddTile y SizeChoiceSelector comparten las implementaciones aprobadas; Encontrados conserva tamaño/sexo/custodia opcionales y los contratos del reporte. Listados usan cabecera/grupo de contenido con entrada compartida, sin count por registro. No se altera el panel de ficha inmersiva solicitado en ADR-030. Véase [ADR-031](../decisiones/031-casos-reutilizan-ui-mascotas.md).

Validación local: suite completa309 pruebas aprobadas;8 regresiones nuevas repetidas tras reforzar el descarte en tamaños390×844/320×350 texto2 y movimiento reducido. Renders revisados en build/ui-preview/case-creation. Pendiente revisar Android autenticado con fotos/teselas reales; la aprobación visual no cierra historias ni confirma backend remoto.
