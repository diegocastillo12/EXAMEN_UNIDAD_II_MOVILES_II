# ADR-084: mapa móvil claro con CARTO Positron

Fecha:19 de octubre de2026, America/Lima. Estado: implementado localmente.

El usuario solicita que la cartografía móvil adopte la referencia clara aportada,
con calles blancas y etiquetas discretas, conservando los pines del logo. Tras
explicar los requisitos de CARTO, configura su clave y confirma continuar con
el crédito discreto solicitado. Esta autorización sustituye ADR-054 únicamente
para los mapas que usan CARTO; no añade créditos al buscador Photon.

Se conserva flutter_map y ZoneMapPicker compartido. MAP_TILE_URL local apunta a
las teselas raster light_all (Positron). No se versiona la clave ni se cambia el
proveedor predeterminado de ejecuciones sin configuración. El ejemplo versionado
usa un marcador sin credencial. Cambiar dart-defines exige reiniciar la ejecución
o recompilar; hot reload no incorpora la nueva URL.

MapConfig reconoce el host CARTO sin exponer la URL. ZoneMapPicker muestra
MapAttribution arriba a la derecha, con espacio para el retorno, enlaces separados
a OpenStreetMap y CARTO, objetivos táctiles de48 y texto adaptable. El crédito
permanece fuera del panel inferior de filtros y el reintento aparece debajo,
sin solaparse cuando el texto crece. Fallos al abrir enlaces usan toast superior.
No se modifican pines, consultas, radios, coordenadas privadas/públicas o permisos.

Condiciones comprobadas: [basemaps](https://www.carto.com/basemaps/) y
[atribución](https://carto.com/attribution/). La clave es configuración cliente
visible en las solicitudes; restringir su uso desde el proveedor según entorno.
Se mantienen caché del SDK, panBuffer0 y ausencia de descarga masiva/offline.
No añade HU/RF ni cierra historias; ajuste visual sobre HU-07/RF-13 y los mapas
compartidos existentes. Validación y revisión Android pendiente en ESTADO.
