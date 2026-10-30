# ADR-107: buscador en reportes y sugerencias de Perú

Fecha:20/10/2026. Estado: aceptada por instrucción del usuario.

## Decisión

Reportar muestra el buscador compartido de places antes del mapa, tanto para
pérdida propia/comunitaria como para avisos de hallazgo vinculados. Seleccionar
una sugerencia actualiza el punto privado mediante el ViewModel del reporte y
centra ZoneMapPicker; después se puede ajustar tocando el mapa. Es opcional y
no sustituye ni rellena la referencia privada. No solicita GPS.

Toda búsqueda textual compartida (Explorar, reportes y Ciudad del perfil) pide
`countrycode=PE` a Photon y descarta respuestas cuyo código de país falte o sea
distinto de PE, sin basarse en etiquetas traducidas ni rectángulos geográficos.
La navegación y selección manual del mapa siguen libres. No es una restricción
territorial de publicación ni una validación oficial de ciudades/direcciones.

## Arquitectura y consecuencias

App compone PlaceSearchFields mediante un slot de presentación compartido;
core y las presentaciones de reportes no importan la presentación de places.
El buscador del reporte tiene un ViewModel autoDispose en un ProviderScope local,
para no compartir sugerencias con Explorar que permanezca bajo la ruta.
Reutiliza casos de uso, fuente, caché, toast, shimmer y debounce existentes.
Conserva bloqueo durante envío, validación del punto, precisión pública y
permisos; sin SQL, credenciales, SDK, dependencias o activación de backend nuevos.

El filtro está en la fuente HTTP compartida. Una respuesta válida de otro país
se convierte en lista vacía; una respuesta malformada mantiene el fallo previo.
No amplía historias ni modifica sus cierres. Trazabilidad: HU-05/RF-05/issue #5,
HU-06/RF-06/issue #6, HU-07/RF-13 y HU-01.7/RF-01.

Contrato contrastado con la [documentación oficial de Photon](https://github.com/komoot/photon/blob/master/docs/api-v1.md#filter-results-by-country-code).
Consulta de lectura real de Tacna con PE devolvió cinco sugerencias con país PE.
Validación local y revisión Android pendiente se registran en ESTADO y en la
[ficha compartida](../funcionalidades/ubicaciones-buscador.md).
