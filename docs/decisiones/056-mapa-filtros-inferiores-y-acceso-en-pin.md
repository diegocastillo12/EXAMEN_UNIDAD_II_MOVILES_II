# ADR-056: filtros inferiores y acceso al caso junto al pin

Estado: aceptada por instrucción del usuario, 16 de octubre de 2026.

## Motivo

El usuario prefiere dedicar el panel inferior del mapa a preparar y aplicar filtros. Propone abrir el caso mediante una etiqueta compacta junto al pin, tomando como referencia la distribución de aplicaciones de movilidad.

## Decisión

Se mantiene `/home/explore-map`, expansión desde Mapa y retorno glass de ADR-055. El panel inferior deslizable contiene los filtros reales de tipo, especie, estado, fecha, ciudad/dirección, ubicación actual, centro del mapa y radio. `ExploreFilterEditor` y `ExploreFilterSelection` se extraen del editor existente para reutilizarlos en la lista y en el mapa, sin duplicar campos ni validaciones. Router sigue componiendo el buscador de places mediante un slot.

Los campos son un borrador. Ningún cambio ni petición de GPS consulta casos hasta Aplicar filtros. El botón se mantiene fijo abajo cuando hay altura suficiente; con panel reducido/texto ampliado pasa al scroll para evitar desbordamientos y conservar acceso. Aplicar actualiza la consulta compartida y reduce el panel al 42% para volver a mostrar el mapa. No se inserta un segundo mapa en el formulario: Usar centro del mapa toma el centro visual y lo deja pendiente de aplicar.

El mapa empieza sin caso seleccionado. Pulsar un pin reduce los filtros al 14%, ajusta la cámara para dejar visible la etiqueta y muestra nombre/Abrir caso junto a ese punto público. La etiqueta reutiliza EntityCardSurface y abre la ficha existente con su transición desde origen. No genera un cartel PDF ni habilita acciones de autor a terceros. Coincidencias mantienen un pin agrupado y controles anterior/siguiente dentro de la etiqueta; se muestra un solo caso por vez. Tocar el fondo descarta la selección; aplicar otra consulta retira la etiqueta anterior.

ExploreState conserva el texto real del lugar y el nombre del centro como metadatos de presentación por cuenta, separados del contrato de consulta. Sobreviven a refresh/paginación/retorno y actualizan la cápsula de Ubicación de la lista. GPS/punto manual no se escriben como texto sintético en el buscador. LocateForFilter invoca el caso de uso existente, deduplica por generación, traduce errores a feedback seguro y descarta resultados de otra cuenta/consulta. El repositorio continúa validando coordenadas/radio al consultar.

ZoneMapPicker admite un controlador visual externo y notificación de toque de fondo, sin operaciones de producto ni llamadas de datos desde core. Su propietario libera el controlador. No hay búsqueda por pan/zoom, nuevo SDK, persistencia SQL, exposición de coordenadas privadas ni cambio de permisos/RPC019. Shimmer solo señala trabajo real; errores/validación permanecen en toast compartido.

Esta decisión sustituye la ficha inferior y selección inicial de ADR-055. Conserva su pantalla inmersiva, insets, tamaños del panel, movimiento reducido y navegación. Es un refinamiento de HU-07.2/RF-13/issue #33; no amplía el MVP ni cierra la historia.

## Validación

Pruebas de ruta/gesto: editar no consulta, Aplicar consulta una vez, seleccionar pin y abrir ficha, volver al mapa/lista conservando la consulta, grupos y cámaras sin editar filtros. Pruebas de GPS: no consulta casos, deduplicación, fallo con borrador/consulta preservados y descarte de respuesta de otra cuenta. Renders normal/pequeño con texto ampliado y movimiento reducido usan teselas neutras; no validan cartografía real. ESTADO registra análisis/suite finales. Revisión Android pendiente; sin APK ni publicación.
