# ADR-099: pines individuales y resumen fotográfico del mapa

Estado: aceptada por instrucción del usuario. Fecha:19/10/2026, America/Lima.
Trazabilidad: HU-07.1/HU-07.2, RF-13, issues #32/#33.

## Contexto

El usuario aclara que el dato solicitado era el tipo de mascota, no su raza.
Pide ampliar la foto, separar los pines coincidentes para evitar el selector
1 de2/2 de2 y retirar del resumen Abierto y el conteo de casos/ubicaciones.

## Decisión

El dato con icono de mascota muestra la especie ya disponible en la proyección
pública: Perro, Gato u Otra especie; un valor ausente/desconocido se presenta
como Tipo no registrado. No se añade captura, persistencia o inferencia de raza.
Foto a ancho completo y proporción4:3 adaptable al ancho; sustituye altura136px.
Mantener nombre, tamaño, fecha y Ver ficha. Se retiran del panel las líneas de
estado (Abierto/Resuelto) y casos consultados · Ubicaciones aproximadas.
El estado sigue disponible en la ficha completa. Paginación/reintento permanecen.

Cada caso tiene un pin propio de48px. ExploreMapPins proyecta las coordenadas
públicas a píxeles usando la cámara y separa los objetivos que se solapan,
con paso56px y preferencia horizontal. El orden por identidad compuesta evita
redistribuirlos por selección u orden de la respuesta. Zoom/rotación actualizan
la colocación visual; no cambian coordenadas, consulta, centro o radio enviados
al backend. No hay agrupación, contador ni selector anterior/siguiente. El pin
seleccionado identifica directamente el caso y abre su ficha correspondiente.

ZoneMapPicker ofrece un slot visual markerLayer para esta capa dependiente
de cámara; sus mapas de edición y consumidores con markers conservan el camino
existente. Core no importa funcionalidades. No hay dependencias nuevas ni cambios
de dominio, repositorios, SDK, SQL o permisos. Los filtros permanecen en Explorar.
Se conservan panel42–90%, CTA adaptable, scroll, retorno glass y movimiento reducido.

## Consecuencias y validación

Sustituye agrupación/contador de ADR-052/062, raza y altura fija de ADR-062,
y selector/estado/conteo de ADR-097. Las coordenadas públicas siguen aproximadas;
la separación de iconos es visual y no indica ubicaciones físicas diferentes.
En concentraciones mayores se utiliza más espacio visual alrededor del origen;
la disponibilidad de pines depende del viewport y la consulta paginada existente.

22 pruebas aprobadas: mapa, preview público, arquitectura y ZoneMapPicker.
Incluyen coincidencia exacta y cercanía, rectángulos táctiles separados, apertura
individual, zoom12/18, giro45°, especie/fallback y conservación de filtros,
paginación y retorno. Capturas390×844 y320×350/texto2/movimiento reducido con
fixtures revisadas, incluido panel expandido. Análisis completo y formato sin
incidencias. No hay nueva verificación de Android, build APK o despliegue.
