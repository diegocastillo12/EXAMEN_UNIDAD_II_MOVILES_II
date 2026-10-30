# ADR-104: cartografía global para móvil y web

Fecha:20/10/2026. Estado: aceptado por instrucción explícita del usuario.
Trazabilidad: HU-07.2 / RF-13 / issue #33 y mapas existentes de ubicación/casos.

## Decisión

Todos los mapas de móvil y web, actuales y futuros, comparten una cartografía
clara. La elección final del usuario es el punto medio entre el mapa original
de Reportar y el acabado de Explorar:50% de color original y50% del filtro
anterior de Explorar. Conserva algo de color, aclara suavemente y aporta una
calidez mínima. Sustituye el filtro exclusivo de Explorar de ADR-103 y las
notas que dejaban sin filtro los demás mapas.

Usar CARTO Positron raster light_all con etiquetas, ya configurado en móvil.
La web recibe la misma URL pública mediante NUXT_PUBLIC_MAP_TILE_URL; valor
local en .env ignorado y ejemplo sin credencial. La clave de teselas es visible
en solicitudes del navegador, como en móvil; jamás usar credenciales Supabase
o de servidor en esa variable. Configurar la URL en el entorno de despliegue.
No registrar ni versionar claves. Conservar condiciones y restricciones del
proveedor; no generar una clave ni contratar servicios desde este incremento.
[Documentación de CARTO](https://github.com/CartoDB/basemap-styles).

Solo transformar las teselas. Pines, áreas/radios, selección, créditos y
controles quedan fuera del filtro. Cada recorrido conserva sus datos, permisos,
encuadre y herramientas. No trasladar el panel50–90% de Explorar a otros mapas
ni añadir rutas/seguimiento por la referencia visual.

Matriz sRGB móvil (offsets en0–255):

```text
.597796 .328992 .033212 0 10.2
.097796 .828992 .033212 0 10.2
.097796 .328992 .533212 0  8.2
0       0       0       1  0
```

## Implementación y fronteras

- Flutter: MapStyle en core/presentation, aplicado obligatoriamente por
  ZoneMapPicker. Retirar la matriz local de Explorar y el override opcional.
  Todos los consumidores existentes comparten el mismo adaptador.
- Nuxt: LocationMap compartido en app/components encapsula Leaflet y sus
  teselas; SightingMap adapta únicamente las coordenadas al contrato de producto.
  maps.css filtra solo leaflet-tile-pane mediante map-style.svg local. SVG usa
  sRGB y offsets normalizados dividiendo por255, sin data URI ni script.
- Mantener CSP restrictiva: permitir imágenes de CARTO en vez de OSM; no
  habilitar data:, unsafe-inline o dominios arbitrarios. Sin SDK cliente de
  Supabase ni llamadas nuevas de negocio desde componentes.
- Créditos enlazados de OpenStreetMap/CARTO fuera del filtro; conservar selección
  manual, reintento de teselas, limpieza de listeners y alternativa ante GPS.
  Si falta configuración web, el fallo usa el reintento existente, sin cambiar
  silenciosamente a otra apariencia/proveedor.

El fallback móvil sin MAP_TILE_URL conserva OSM de desarrollo de ADR-084, pero
recibe la matriz global. La referencia visual se valida con Positron configurado,
no con ese fallback. No ampliar permisos ni escribir SQL.

## Validación

Comprobaciones arquitectónicas rechazan mapas por funcionalidad fuera de los
adaptadores y comparan numéricamente las matrices de móvil/web. QA de navegador
comprueba filtro realmente pintado sobre tesela de fixture, créditos, selección,
CSP/hidratación y responsive. Pruebas Flutter conservan mapa, errores/reintento y
consulta. Resultados, pendientes y activación en ESTADO y la ficha compartida.
