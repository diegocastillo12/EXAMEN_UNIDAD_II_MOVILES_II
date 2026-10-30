# ADR-034: búsquedas propias/comunitarias y avisos vinculados

Estado: aceptado por instrucción explícita del usuario. Fecha: 11 de octubre de 2026.

## Motivo y alcance

El usuario redefine los recorridos: Mascota perdida abre la búsqueda de una mascota propia o una que un ciudadano considera posiblemente perdida; Mascota encontrada avisa en un caso abierto, con La vi o La encontré y está conmigo. El aviso nunca confirma automáticamente la recuperación. Se adelanta parte del flujo app de HU-10/RF-11 y parte de HU-13/RF-07; no se cierran historias, no se implementan QR/web, push, revisión/moderación completa ni exploración geográfica de HU-07. HU-05/RF-05 y HU-06/RF-06 conservan trazabilidad, distinta de issues #5/#6/#10/#13.

## Decisión

- Mi mascota conserva publicación de lost_cases, propiedad, versión, fotos verificadas y único caso activo por mascota. Otra mascota abre una búsqueda possibly lost sin crear pets ni atribuir propiedad. Nombre/especie de referencia deriva de datos reales del reporte; no se inventa un nombre o edad.
- found_cases conserva el almacenamiento privado y la infraestructura de fotos existente. report_kind distingue possible_loss, sighting y with_reporter; legacy_found conserva los registros anteriores sin reclasificarlos ni inventar vínculos. target_lost_case_id o target_community_case_id identifica una sola búsqueda de origen; una búsqueda comunitaria no apunta a otra búsqueda. La interfaz usa los términos de producto, no los nombres físicos de tablas.
- La ruta de aviso inyecta FoundEditorContext mediante providers declarativos y ProviderScope en app/router. El ViewModel observa el contexto con dependencies explícitas; cada recorrido conserva su borrador/identidad. El selector lista búsquedas abiertas de ambos orígenes. Desde ficha se precarga el vínculo. El aviso tiene tipo, descripción, fecha/hora, punto y referencia privados y foto opcional. Búsqueda comunitaria mantiene foto requerida.
- Servidor deriva especie/tipo/tamaño/sexo de la búsqueda objetivo, incluida la descripción de tipo de60 caracteres de mascotas; el autor del aviso no puede cambiar esos datos del caso. Valida destino abierto bajo bloqueo, propietario del envío, forma de vínculo, fecha/punto/textos, IDs y fotos procesadas. No actualiza la búsqueda al publicar un aviso. El endpoint antiguo de publicar hallazgo independiente deja de ser ejecutable por clientes; registros anteriores siguen consultables como reportes anteriores.
- Confirmar recuperación es una operación aparte del autor de la búsqueda, con historial e idempotencia. En mascota propia, status/evento/contador/versión cambian atómicamente y una sola vez. En comunitaria se cambia estado y se registra evento. No cambia mascotas ajenas ni infiere entrega/propiedad. Después de cerrar no se admiten avisos nuevos; reintentos idénticos de un aviso ya publicado no duplican datos.
- Las fichas listan avisos vinculados con consulta de datos y fotografías públicas aproximadas; datos exactos/actor privado no forman parte del JSON público. Al cerrar, terceros dejan de leer avisos/fotos; autor de búsqueda y autor del aviso conservan acceso autorizado. URLs ya firmadas conservan TTL300s. Resúmenes de avisos reflejan la búsqueda cerrada, sin cambiar un aviso en una recuperación.
- UI conserva EntityScreenShell, cover/stagger, origen de botón, campos/galería/tamaño/mapa compartidos, skeleton/shimmer y toast. Ante destino cerrado se permite releer búsquedas conservando fotos y UUID del borrador. Publicación confirmada invalida avisos de la ficha; resolución invalida listas/metadatos afectados.

## Persistencia y activación

Fuentes062–065, plan018 y migración20261011001800_recovery_report_links.sql, generados con Build-Migration/Build-RunAll. Requiere esquema001–017 (en particular013/014/016/017) y procesamiento de fotos anterior activo. No se modifica SQL aplicado ni se requiere nueva Edge Function: se reutilizan los buckets y la preparación/confirmación existentes. Activación remota no ejecutada ni autorizada por este documento.

## Validación y límites

Pruebas SQL en PostgreSQL/PGlite con dos cuentas y anon: búsquedas sin pets, avisos a ambos orígenes, foto opcional, tipo largo preservado, destinos inexistentes/cerrados, payload conflictivo, deduplicación, grants/RLS y privacidad, cierre autorizado/contador/historial y repetición. Pruebas Flutter cubren selección de recorrido sin mascota propia, aviso precargado, publicación sin foto, conservación por error/identidad y confirmación explícita en pantallas normal/pequeña. Resultados finales y evidencias en ESTADO. Concurrencia multi-conexión real, fotos/teselas/Android autenticados y activación de Supabase pendientes.
