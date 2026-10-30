# ADR-018: zonas manuales privadas y mapa de selección

Fecha: 9 de octubre de 2026, America/Lima. Estado: adoptada para HU-02.1 / RF-02,16 (issue #26), dentro del desarrollo autorizado en `feature/interest-zones`.

## Contexto y decisión

El siguiente incremento de S2 permite guardar zonas con su radio sin GPS permanente. Se implementa primero HU-02.1; HU-02.2 configura preferencias en un incremento posterior. Las zonas son preferencias privadas de una cuenta, independientes de la ficha de mascota y de las coordenadas públicas de casos/QR.

`features/interest_zones` conserva presentación MVVM, casos de uso de dominio independientes y repositorio con fuente Supabase. Perfil abre una ruta autenticada con listado y editor. El formulario exige nombre de 1–60 puntos de código Unicode, punto explícito y radio de 100–50000 metros. La latitud se limita a −85..85 para la proyección del mapa; longitud −180..180; se rechazan valores no finitos. Los mismos límites se validan en SQL. Son parámetros de este incremento, no una ampliación a seguimiento GPS.

La selección usa `flutter_map` 8.3.2 y `latlong2`: arrastra/zoom y toque para definir el centro; círculo en metros, indicador de punto y radio. Lima es solo el encuadre inicial, nunca ubicación inferida ni punto guardado automáticamente. Coordenadas introducidas manualmente permiten uso accesible y recuperación cuando el servicio de mapas falla. No se solicita permiso de ubicación ni se obtiene la posición del dispositivo.

Se elige el cliente de mapa por ser Flutter multiplataforma, admitir capas de punto/círculo y permitir cambiar proveedor de teselas. Se descarta vincular este incremento a un SDK nativo y a permisos GPS obligatorios. Las teselas OSM estándar son la configuración inicial de desarrollo; no se garantiza disponibilidad ni se contrata hosting. Se conserva atribución visible/enlace, User-Agent de la aplicación, caché HTTP incorporada y ausencia de descargas masivas/offline o precarga alrededor del viewport (`panBuffer: 0`). `MAP_TILE_URL`, `MAP_ATTRIBUTION` y `MAP_ATTRIBUTION_URL` permiten sustituir el servicio y su atribución al compilar. Antes de distribución pública se debe comprobar adecuación del proveedor y su política para el volumen previsto.

Fuentes: [documentación oficial de flutter_map](https://docs.fleaflet.dev/), [política oficial de teselas OSM](https://operations.osmfoundation.org/policies/tiles/). El renderizador de mapa pertenece a presentación: solicita solo imágenes de cartografía y emite coordenadas al ViewModel; no accede a Supabase ni decide persistencia. La fuente se conserva por instancia y se reemplaza al reintentar; la capa libera el cliente al desmontarse. No se cambia una frontera de arquitectura.

## Persistencia y reintentos

Fuentes SQL 036–039, plan 010, migración `20261009001000_interest_zones.sql` y patch generado. `interest_zones` habilita RLS; el cliente solo lee la proyección propia y ejecuta RPC. Una política restrictiva conserva el aislamiento aunque se añada una política permisiva amplia. No hay grants de escritura directa ni acceso anónimo.

`save_interest_zone` obtiene el actor de `auth.uid()`, usa UUID estable por borrador y versión esperada (0 al crear). Bloqueo transaccional de la clave y de fila serializa las operaciones; un reintento idéntico de la versión siguiente devuelve el resultado sin incrementar versión/fechas. Un comando incompatible recibe conflicto. `delete_interest_zone` conserva una marca de eliminación privada; reconoce el reintento exacto y evita que un envío antiguo recree la zona. Borrar la cuenta elimina sus zonas mediante FK. No se implementa aún la cola offline persistente de S6.

La UI anuncia éxito únicamente tras respuesta del servidor; errores permanecen contextuales. Borrador e ID se conservan al fallar; consultar versión actual pide descartar el borrador. Estado por cuenta, generación y autoDispose descartan respuestas tardías. El refresh mantiene contenido y edición, con progreso fino; cambio/error de identidad oculta datos anteriores y limpia el aviso. Se mantienen cover/stagger, glass compartido, shimmer y movimiento reducido.

## Validación y límites

Pruebas Flutter de dominio, estado, adaptador HTTP Supabase, mapa con fuente sustituida y navegación Perfil/ruta protegida. Renders normales y 320×350 con texto2 revisados con fuentes reales y fixtures exclusivas de pruebas. SQL local PostgreSQL/PGlite verifica aislamiento, grants, límites, repetición de scripts y RPC, versiones y eliminación con reintentos.

Estas pruebas no acreditan teselas reales, rendimiento Android ni permisos/persistencia en Supabase remoto. La migración no se ha desplegado en esta tarea. No se introduce PostGIS ni consultas de casos: S3 conserva la decisión de consultas geográficas y publicación de coordenadas aproximadas en servidor.
