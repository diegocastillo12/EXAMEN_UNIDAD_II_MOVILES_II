# ADR-021: publicación de casos perdidos y proyección pública

Fecha: 10 de octubre de 2026, America/Lima. Estado: aceptada para la implementación local de HU-05 / RF-05 (issue #5), con activación y validación remotas pendientes.

## Contexto

Publicar una búsqueda necesita integrar la ficha privada, los derivados verificados de ADR-020 y el historial protegido de ADR-014. La ubicación exacta no debe formar parte de la ficha pública. Un fallo de red no debe permitir duplicar una búsqueda ni confirmar éxito sin respuesta válida.

## Decisión

`lost_cases` guarda fuente privada, solicitud original y una copia de nombre, especie/tipo, tamaño, sexo opcional, edad y rasgos de la mascota. El usuario revisa esos campos y elige de una a tres fotos antes de consentir su publicación. No se proyectan referencia del lugar, punto exacto, cuenta, correo, documentos ni información de salud. Los campos libres y fotografías deben revisarse para evitar datos personales en su contenido; la eliminación de EXIF no elimina información visible dentro de una foto.

`publish_lost_case` obtiene el actor de `auth.uid()`, bloquea primero la mascota y valida propiedad, versión, disponibilidad, campos y fotos procesadas. El UUID pertenece al borrador. Repetir el mismo UUID con la misma solicitud normalizada devuelve el caso existente; cambiar la solicitud produce conflicto. Un índice parcial limita a un caso perdido activo por mascota. Publicación, evento, historial permanente y contador activo se escriben en una transacción. No hay comandos cliente para modificar eventos o indicadores.

La proyección pública se obtiene exclusivamente con `read_public_lost_case(id)`: caso activo, campos permitidos y fotos elegidas que sigan publicadas/verificadas. La tabla base solo permite lectura propia; anónimo no tiene SELECT. La zona pública es el centro de una celda de 0.01 grados, calculada con floor para ambos hemisferios; longitud limitada a179.995 en el extremo180. Es una aproximación variable con latitud, de alrededor de1.1km en latitud, **no una garantía de anonimato geográfico**. El texto de referencia del lugar nunca se publica. En HU-07 se incorporarán PostGIS y consultas de cercanía; HU-05 no consulta distancias ni requiere esa extensión todavía.

Los buckets permanecen privados. RLS permite SELECT de derivados solo cuando `is_public_case_rendition` confirma foto seleccionada, procesada y asociada a un caso activo. Originales, fotos sin seleccionar y derivados no verificados conservan privacidad. Guards independientes para INSERT/UPDATE/DELETE anónimos impiden convertir esa lectura en escritura incluso con otra política permisiva. Las rutas de bytes contienen UUID técnicos de cuenta/mascota/foto; no son perfiles públicos ni incluyen coordenadas o nombres. Esta exposición de identificadores opacos se limita a las fotos publicadas deliberadamente.

La fuente de datos pide URLs firmadas por300s bajo esos permisos. Desactivar el caso o retirar una foto revoca nuevos accesos, pero una URL ya firmada puede sobrevivir hasta su vencimiento y las copias descargadas no pueden recuperarse. No convertir los buckets a públicos. [Storage privado y URLs firmadas](https://supabase.com/docs/guides/storage/buckets/fundamentals), [control de acceso](https://supabase.com/docs/guides/storage/security/access-control).

## Presentación y reintentos

Clean Architecture por `lost_cases`, MVVM y casos de uso; SDK encapsulado en fuente de datos, mapeo de DTO/fallos en repositorio. Los casos de uso de mascotas/fotos se inyectan mediante sus contratos existentes. El mapa compartido se extrae a core manteniendo export compatible para zonas; no hay imports de presentation entre funcionalidades.

Entrada desde Reportar; etapas formulario → vista previa → confirmación persistida. Sin GPS ni permisos nuevos: mapa o coordenadas manuales siempre disponibles. Carga inicial skeleton; actualizaciones explícitas de las consultas conservan contenido con progreso fino y error contextual. Cambiar identidad oculta el contenido anterior y descarta respuestas tardías. Proveedores autoDispose; guardado retiene recursos solo mientras está en curso.

Una respuesta ambigua congela la solicitud exacta: permite reintentar y consultar Mis casos. Un rechazo conocido permite editar, volver a consultar mascota/fotos y reintentar. Salir de un borrador pide confirmación; tras respuesta ambigua advierte que el caso pudo persistir. El borrador no sobrevive al reinicio de la app: persistencia offline es HU-15. Mis casos permite encontrar una publicación cuyo acuse se perdió. No se crea una cola ni se confirma publicación offline.

## Consecuencias y validación

Fotos históricas sin verificación necesitan reemplazo/guardado procesado por ADR-020; no se marcan válidas ficticiamente. Los metadatos públicos son copia de la ficha al publicar; el acceso a fotos usa su estado vigente y una retirada puede dejar la ficha pública sin esas imágenes. Cierre autorizado, actualización atómica del contador y nuevos eventos corresponden a HU-13; `status` no tiene UPDATE cliente. HU-06/HU-07, QR/cartel, avistamientos y alertas no se incorporan aquí.

Fuentes048–051/plan013 generan migración y patch013. Pruebas locales cubren permisos entre cuentas/anónimo, índices, reintentos, conflicto, protección de historial, proyección, lectura de bytes y repetición. PGlite no acredita concurrencia con sesiones PostgreSQL independientes ni Storage remoto. La activación requiere aplicar patch013 completo sobre012 y probar con dos cuentas reales, dos envíos simultáneos, reinicio y red interrumpida. No se cierra HU-05 por pruebas locales.
