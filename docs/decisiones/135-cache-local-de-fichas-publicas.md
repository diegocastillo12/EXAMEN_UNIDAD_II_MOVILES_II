# ADR-135: caché privada de fichas públicas consultadas

Fecha:24/10/2026. Estado: aceptada para HU-15.3/RF-32/#49, Android primero.

## Contexto

Guardar un favorito en Supabase no conserva una ficha para consultar sin red.
La historia requiere recuperar casos consultados tras reiniciar, informar su
antigüedad, separar cuentas y respetar las respuestas posteriores del servidor.

## Decisión

`offline_cases` contiene entidad, contrato y casos de uso de consulta/caché;
presentación existente colabora mediante dominio/providers. Data implementa
SQLite/Drift separado de borradores/cola. Main inyecta el repositorio y router
compone la sección local mediante un slot de Guardados, sin imports cruzados
de data/presentation. No hay SQL, servicio ni permisos nuevos de servidor.

La consulta intenta primero la operación existente del servidor, con un límite
de ocho segundos. Solo indisponibilidad/timeout permite recuperar la copia de
esa cuenta/origen/UUID. Ausencia confirmada, cierre o rechazo de autorización
elimina la copia y no permite recuperarla por un fallo de red posterior. La
respuesta de autenticación inválida de PostgREST se clasifica como rechazo.
Las consultas superadas y las fotos tardías no deben resucitar copias retiradas.

Se serializa una lista explícita de campos públicos y coordenadas aproximadas,
sin contactos, perfiles, referencias privadas, permisos de actuación o URLs
firmadas. Hasta tres fotos de2MiB se descargan en paralelo con plazo de tres
segundos, MIME de imagen autorizado y sin redirecciones. Los bytes se guardan
en la misma escritura atómica que la ficha. Si falla la descarga, solo se
conservan bytes previos de la misma foto; una foto no descargada tiene placeholder.

La base `case_cache.sqlite` reside en soporte privado y queda excluida de backup
y transferencia Android, incluidos auxiliares. Retención global de hasta30 fichas
y32MiB de payload, expulsando las más antiguas. Logout/cambio de cuenta oculta
las copias de la cuenta anterior; no crea autenticación ni autoriza acceso por
una identidad recibida del contenido. Desinstalar/borrar datos elimina la base.

La ficha offline lleva fecha y aviso de desactualización, acción Actualizar,
fotos locales y campos públicos. Contacto, compartir, acciones autorizadas y
mapa remoto no se montan en ese modo. No se descargan teselas ni se presenta un
mapa vacío como evidencia cartográfica. Las rutas/transiciones existentes se
conservan. Los errores de almacenamiento usan toast y permiten reintento.

## Consecuencias y límites

No se puede conocer una revocación mientras el dispositivo carece de conexión;
se informa que la copia puede estar desactualizada y se revalida al consultar
con conexión/Actualizar. La caché no implementa favoritos offline, publicación
offline adicional, contactos offline, mapas descargados ni soporte offline de
Nuxt. No modifica los consentimientos ni amplía las proyecciones del backend.

La evidencia técnica y lo pendiente se mantienen en
[fichas sin conexión](../funcionalidades/fichas-sin-conexion.md) y ESTADO;
la implementación no cierra por sí sola el issue ni la épica.
