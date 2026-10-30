# Revisión del código, arquitectura y reutilización — 11 de octubre de 2026

Revisión del árbol de trabajo de `feature/found-pet-cases`, incluidos cambios locales modificados y no rastreados. Solicitud: analizar el estado actual, sin implementar correcciones ni publicar. Se conservó el trabajo previo.

## Diagnóstico

La base de Clean Architecture por funcionalidad está establecida: contratos y casos de uso de dominio, SDK encapsulado en fuentes, composición en bootstrap/main y ViewModels de presentación. Hay reutilización real de inputs, shimmer, reveal, navegación glass, confirmaciones, tarjetas, filtros, swipe y vista previa pública. No se justifica reconstruir la app ni añadir clases base genéricas.

Los problemas principales son sincronización entre funcionalidades, fronteras que las comprobaciones actuales no detectan y reutilización incompleta de comportamientos compartidos. Una suite de arquitectura aprobada no demuestra por sí sola que todas las reglas se cumplan.

Inventario: 289 archivos Dart en lib y 65 en test. Se revisaron las normas, estado, arquitectura, criterios S2/S3, imports entre funcionalidades, componentes compartidos, flujos de fotos/casos, SQL de casos y configuración de CI. Es revisión estática y validación local; no una auditoría exhaustiva de seguridad ni demo remota.

## Hallazgos que conviene corregir

### R01 — P2: eliminar un caso perdido no actualiza los consumidores de mascotas

Ubicación: [MyCasesViewModel.delete](../../apps/mobile/lib/features/lost_cases/presentation/view_models/case_read_view_model.dart), líneas 58–81; [PetListViewModel / PetDetailViewModel](../../apps/mobile/lib/features/pets/presentation/view_models/pet_list_view_model.dart); [delete_lost_case](../../database/functions/058_case_collection_commands.sql).

SQL decrementa active_case_count y aumenta version de la mascota al eliminar el caso activo. El ViewModel retira el caso de su lista e invalida su consulta pública, pero no notifica a los consumidores de la mascota modificada. Un listado o ficha todavía observado puede conservar la versión y contador anteriores. La siguiente edición/operación de ciclo de vida puede partir de datos obsoletos y provocar un conflicto evitable.

Confirmado con una prueba de diagnóstico usando ProviderContainer y repositorios sustitutos: se mantuvo observada la lista, se representó la actualización transaccional del servidor y se llamó a delete; la lista de casos quedó vacía y la mascota conservó contador 1/version 2 frente a contador 0/version 3 del repositorio. No demuestra una llamada remota, sí la falta de sincronización local.

Corrección propuesta: notificar el cambio de la mascota mediante un contrato/señal de invalidación compuesta en inyección; cubrir listado, ficha y consumidores afectados. Evitar importar presentación de pets dentro de lost_cases para resolverlo. Revisar también publicación: invalida listMyPetsProvider, pero no el consumidor de readPetProvider para una ficha observada.

### R02 — P2: onboarding depende de presentación de otra funcionalidad

Ubicación: [entry_view_model.dart](../../apps/mobile/lib/features/onboarding/presentation/view_models/entry_view_model.dart), líneas 2 y 15; [entry_screen.dart](../../apps/mobile/lib/features/onboarding/presentation/screens/entry_screen.dart), líneas 6 y 16.

EntryViewModel importa/observa AuthViewModel; EntryScreen importa/consume LoginViewModel para cerrar sesión. La norma prohíbe importar presentación de otra funcionalidad: la colaboración debe expresarse mediante contratos/casos de uso inyectados. Cambiar el estado del login o su ViewModel puede obligar a cambiar onboarding.

Corrección propuesta: coordinar arranque, sesión, comprobación de onboarding y salida desde el ViewModel de entrada usando casos de uso declarativos. La pantalla observa ese estado y sus acciones. La dependencia de un dominio ajeno necesaria para la colaboración no es, por sí sola, una infracción.

### R03 — P2: el test de arquitectura no detecta esa frontera

Ubicación: [architecture_test.dart](../../apps/mobile/test/architecture_test.dart), líneas 126–180.

El test distingue domain/data/presentation/providers por segmentos de ruta, pero no compara funcionalidad origen/destino. Permite presentation de onboarding → presentation de auth; ambas son presentación. Además, el escaneo de dependencias parte de lib/features y no revisa las dependencias salientes de core. Actualmente pasa pese a R02.

Corrección propuesta: verificar funcionalidad y capa destino, resolver las rutas y mantener pruebas de la propia comprobación con ejemplos válidos e inválidos. Extender el análisis a core según su responsabilidad; bootstrap/main conservan su papel legítimo de composición. No convertir todo import entre funcionalidades en prohibido.

### R04 — P2: faltan marcas de validación para fotos y ubicación

Ubicación: [found_editor_screen.dart](../../apps/mobile/lib/features/found_cases/presentation/screens/found_editor_screen.dart), líneas 363–397 y 443–481; [case_editor_screen.dart](../../apps/mobile/lib/features/lost_cases/presentation/screens/case_editor_screen.dart), bloque ZoneMapPicker; validación en los casos de uso de publicación.

PublishFoundCase produce FoundField.photos y FoundField.point, y el ViewModel los guarda en invalidFields. La pantalla no consume esos dos indicadores para marcar/sacudir sus controles: la galería es un Row propio y el mapa/coordenadas no pasan por el wrapper de ShakeField. El toast genérico pide revisar campos marcados que, en estos casos, no están marcados. En perdido la selección de fotos sí usa la marca, pero el mapa tampoco consume CaseField.point.

Corrección propuesta: conectar errorId/invalidFields a las superficies de foto y ubicación mediante componentes compartidos; conservar explicación en toast y ausencia de mensajes debajo. Verificar envío sin fotos y sin punto, recuperación al corregir y movimiento reducido.

### R05 — P2: dos pruebas de navegación quedaron desactualizadas

Ubicación: [pets_navigation_test.dart](../../apps/mobile/test/pets_navigation_test.dart), línea 553 y búsquedas posteriores; [confirm_action_dialog.dart](../../apps/mobile/lib/core/presentation/widgets/confirm_action_dialog.dart).

Las variantes normal y pequeña buscan pet-deletion-actions, clave que ya no existe tras la extracción del diálogo. Ambas fallan en getBottomRight antes de verificar el resto del recorrido de cancelación/error/eliminación. La centralización funciona en las pruebas específicas del diálogo, pero la regresión integrada quedó rota.

Corrección propuesta: actualizar los finders al componente compartido, conservando las comprobaciones de geometría y comportamiento. No devolver layout duplicado ni eliminar las verificaciones para obtener verde.

### R06 — P2: los datos de fotos de mascotas no son realmente inmutables

Ubicación: [PetPhotosState](../../apps/mobile/lib/features/pets/presentation/view_models/pet_photos_view_model.dart), líneas 10–26; [PetPhotoDraft](../../apps/mobile/lib/features/pets/domain/entities/pet_photo.dart), líneas 24–27. Comparación: FoundEditorState usa colecciones no modificables y FoundPhotoDraft copia/protege bytes.

PetPhotosState almacena directamente listas/sets recibidos; final impide reasignar la referencia, no modificar su contenido. PetPhotoDraft conserva el Uint8List mutable recibido. Se confirmó con una prueba de diagnóstico que añadir a la lista original modifica el snapshot y que cambiar el buffer modifica los bytes del borrador sin emitir estado nuevo.

Consecuencia: el contrato de estado inmutable no está garantizado y el contenido asociado a un UUID estable puede alterarse desde otro consumidor. No se observó corrupción real en Android durante esta revisión.

Corrección propuesta: copiar y proteger colecciones/buffers en sus límites, siguiendo la solución ya usada en encontrados. Extraer PetPhotosState a presentation/state al intervenirlo, sin trasladar lógica de Riverpod al dominio.

### R07 — P2: refresh de casos perdió parte del patrón existente

Ubicación: [my_cases_screen.dart](../../apps/mobile/lib/features/lost_cases/presentation/screens/my_cases_screen.dart), línea 55; [my_found_cases_screen.dart](../../apps/mobile/lib/features/found_cases/presentation/screens/my_found_cases_screen.dart), línea 59; ambas fichas de casos. Referencia: [PetRefreshProgress](../../apps/mobile/lib/features/pets/presentation/widgets/pet_skeleton.dart), líneas 7–34.

Las listas insertan LinearProgressIndicator dentro de Column y desplazan el contenido al refrescar, en vez de superponerlo según ADR-011. Las fichas sí usan overlay, pero los cuatro indicadores omiten el control de TickerMode/movimiento reducido y la etiqueta semántica presentes en PetRefreshProgress.

Corrección propuesta: extraer la responsabilidad de progreso superpuesto a core, configurable por etiqueta accesible, y delegar desde mascotas/casos. Verificar geometría estable y ticker detenido con disableAnimations.

### R08 — P2: encontrados no adopta un límite explícito de espera de publicación

Ubicación: [FoundEditorViewModel.publish/discard](../../apps/mobile/lib/features/found_cases/presentation/view_models/found_editor_view_model.dart), líneas 174–249; [SupabaseFoundCaseDataSource](../../apps/mobile/lib/features/found_cases/data/data_sources/supabase_found_case_data_source.dart); [SQL053](../../database/functions/053_found_case_commands.sql).

Perdido tiene deadline cliente, fallo timedOut y lock_timeout versionado. Encontrado no aplica un deadline propio al preparar, procesar fotos, publicar o descartar; sus RPC toman bloqueos de fila y prepare_found_case toma además advisory lock sin lock_timeout explícito. Mientras el Future no termine, busy bloquea salida y reintento. Los límites efectivos pueden depender del transporte/proxy/servidor, que no se comprobaron aquí.

Corrección propuesta: definir una política de espera para encontrado y cada etapa de limpieza, conservando UUID/bytes y estado ambiguo. No desbloquear una solicitud para editar/recrear después de timeout sin reconciliación; un timeout no cancela ni prueba rollback remoto. Añadir una migración nueva para límites de servidor si corresponde. Este riesgo se identifica por código; no se reprodujo un bloqueo remoto de encontrado.

## Duplicación y reutilización incompleta

### R09 — P3: galería propia en el formulario de encontrados

[found_editor_screen.dart](../../apps/mobile/lib/features/found_cases/presentation/screens/found_editor_screen.dart), líneas 363–397, dispone cada foto en un Row vertical, tamaño fijo 160 y botón de retirada separado. No usa PhotoGalleryStrip/PhotoGalleryTile, que ya gobiernan galería horizontal, geometría adaptable y selección en mascotas/perdidos. La vista previa pública de ambos reportes sí reutiliza CasePublicationPreview correctamente.

Propuesta: adaptar tiles compartidos para imágenes locales y retirada; mantener sus diferencias reales de negocio (encontrado agrega bytes, perdido selecciona fotos existentes). La presencia de coordenadas numéricas en encontrado y su ausencia en perdido también constituye una diferencia de interacción a revisar; la orden de retirarlas fue específica para perdido y no se interpreta aquí como autorización para eliminar la alternativa de encontrado.

### R10 — P3: utilidades y coordinación repetidas

- UUIDv4: newPetId en pets/domain/entities/pet.dart y _newId en InterestZonesViewModel repiten el algoritmo. Encontrados importa el helper de mascotas solo para generar IDs de casos/fotos. Extraer una utilidad Dart independiente o generador inyectable con nombre neutral, preservando ID por borrador/reintento.
- Fechas: caseDateLabel y foundDateLabel repiten el mismo formato. Un formatter compartido de presentación evita divergencia.
- Imágenes: preparePhoto y prepareProfilePhoto repiten límites, detección/decodificación, orientación, saneamiento, fondo y JPEG. Perfil necesita recorte512, mascotas/casos conservan proporción1280; compartir validación/saneamiento y configurar transformación, sin imponer resultados idénticos.
- Lectura de casos: listados y fichas de perdidos/encontrados repiten retry, generación, contenido conservado, errores y borrado. Descartar en encontrados tiene semántica propia y no debe mezclarse con eliminación. Compartir componentes/piezas de coordinación demostradas; no una clase base universal de ViewModels.
- Proyección de privacidad: los dos editores calculan la zona aproximada dentro de widgets y duplican la fórmula de SQL. Preparar la proyección de preview fuera del widget, con política de dominio probada; el servidor sigue siendo autoridad para lo publicado.
- Caso activo: CaseEditorViewModel.preview decide la regla activeCaseCount > 0 directamente en presentación. Llevar esa prevalidación a una operación de dominio, conservando validación y bloqueo del servidor. No es un bypass de permisos: SQL también impide el segundo caso activo.

No toda repetición merece extracción: contratos independientes, validaciones cliente/servidor y migraciones históricas requieren conservar responsabilidades y compatibilidad. Los wrappers actuales de tarjetas, shells y diálogos que delegan a core son reutilización válida, no copias de implementación.

## Comprobaciones y límites

| Comprobación | Resultado |
| --- | --- |
| dart format --output=none --set-exit-if-changed lib test | 354 archivos, 0 cambios |
| flutter analyze --no-pub | Sin incidencias |
| flutter test --no-pub | 280 aprobadas, 2 fallidas; repetido para capturar diagnóstico, mismo resultado |
| Fronteras de architecture_test.dart | Aprobadas dentro de la suite; limitación descrita en R03 |
| node --test database/tests/run_all.test.mjs | 19 aprobadas |
| Probes locales de sincronización e inmutabilidad | 2 aprobadas; confirman comportamientos defectuosos actuales, no una corrección |

Log de Flutter: apps/mobile/build/review-20261011-tests.log. Probes reproducibles: apps/mobile/build/review_20261011_probe_test.dart; ambos en build ignorado. La ejecución inicial npm test desde database no encontró package.json; se ejecutó después el runner real de database/tests y pasó.

No se ejecutaron build Android, instalación, renders nuevos, llamadas remotas, concurrencia con conexiones PostgreSQL independientes ni pruebas Deno del handler/procesador (deno no disponible en PATH). PGlite valida el fixture SQL, no el servicio Storage/Edge desplegado ni los permisos remotos. No se cerraron HU/issues ni se resolvió el incidente remoto documentado.

CI versionado: el workflow actual comprueba Flutter y solo se dispara por cambios Flutter/workflow. SQL y Edge tienen pruebas locales pero carecen de una comprobación equivalente en ese workflow; un cambio solo en database/supabase no queda validado automáticamente allí. Preparar cobertura de CI de esos componentes al abordar su validación.

## Orden sugerido

1. Recuperar la suite completa actualizando la prueba de navegación.
2. Corregir sincronización de mascotas tras operaciones de casos y añadir regresiones que esperen datos nuevos.
3. Corregir la dependencia onboarding/auth y ampliar la comprobación de fronteras.
4. Garantizar inmutabilidad y completar marcas de validación/progreso compartido.
5. Definir esperas/reconciliación de encontrados y validar SQL/Edge en su runtime.
6. Reutilizar galería y extraer utilidades pequeñas; consolidar coordinación solo donde aporte claridad.

Esta revisión no modifica código de producción ni propone ampliar el MVP. Las fichas de funcionalidades conservan su implementación/activación actual; los hallazgos pendientes se registran aquí y en ESTADO.

## Corrección posterior solicitada por el usuario — 11 de octubre

Los hallazgos anteriores describen la revisión inicial. El usuario autorizó después su solución y extendió feedback en toast/shimmer a toda la app. Se conservó el trabajo previo y no se publicó ni desplegó.

| Hallazgo | Corrección y evidencia |
| --- | --- |
| R01 | NotifyPetChanged/PetChanges notifican tras publicar/eliminar confirmado. Lista/archivadas/detalle se suscriben por identidad y liberan suscripciones. Regresión confirma contador/version nuevos; un fallo conserva versión. |
| R02 | Entrada consume contrato de sesión y CheckOnboarding; salida usa SignOut en EntryExitViewModel. Ya no importa presentación de auth. Flujos de acceso/onboarding aprobados. |
| R03 | Escaneo de todo lib, incluido core; prueba de reglas rechaza presentation/data entre funcionalidades y core→features. Escaneo de feedback impide errorText/helperText y loaders convencionales. |
| R04 | ValidationSurface compartida para fotos/mapas, con danger, semántica y ShakeField; campos invalid y feedback en toast. Flujos/render normales y pequeños aprobados. |
| R05 | Pruebas localizan las acciones reales del diálogo compartido, sin depender del antiguo pet-deletion-actions. Navegación aprobada en ambos tamaños. |
| R06 | PetPhotosState copia/protege colecciones; PetPhotoDraft copia/protege bytes. Regresión rechaza mutación externa. Estado separado del ViewModel. |
| R07 | ContentRefresh/LoadingShimmer comparten refresh en mascotas/casos. Sin LinearProgressIndicator, cambio de geometría ni pérdida de semántica del contenido. Pruebas de acciones/semántica/posición y movimiento reducido. |
| R08 | Editor encontrado acota operación90s; SDK acota cada petición30s y detiene la secuencia tras timeout. Reintento conserva mismo objeto/IDs/bytes; respuestas tardías no sustituyen estado. SQL061/plan017 limita bloqueos5s. Pruebas VM/SDK y SQL aprobadas; activación remota pendiente. |
| R09 | Fotos encontradas reutilizan PhotoGalleryStrip/PhotoGalleryTile, conservando quitar y selección real. Render normal/pequeño revisado. |
| R10 | UUID/fecha/proyección de coordenadas/preparación de fotos/finalización de lecturas reutilizadas. Preview en estado y validación de mascota en dominio. Adaptadores mantienen fallos propios y contextos nativos de recuperación distintos. Sin clases base genéricas. CI SQL/Edge preparado. |

[ADR-027](../decisiones/027-feedback-global-toast-shimmer.md) y [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) versionan las decisiones. Validación actual: formato368 archivos, análisis sin incidencias, suite Flutter291 aprobadas, SQL20 y Edge11. Tras ajustes finales de utilidades/selectores:37 pruebas de fotos/validación/casos/arquitectura y4 de SDK/validación aprobadas. Se comprobaron capturas390×844/320×350 texto2, cierre/scroll del toast, reintentos y contenido conservado.

Intentos de APK debug bloqueados por java.io.IOException: Unable to establish loopback connection en Gradle, incluso con preferIPv4Stack; no se acredita APK nuevo ni ejecución Android autenticada. Pruebas con repositorios/HTTP sustituidos y PostgreSQL en memoria no demuestran contención real, permisos de servidor desplegado ni rendimiento físico. No se aplicó migración017 ni se ejecutó CI en GitHub.
