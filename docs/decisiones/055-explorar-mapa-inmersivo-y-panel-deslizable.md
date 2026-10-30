# ADR-055: mapa de Explorar en pantalla propia y ficha deslizable

Estado: aceptada por instrucción explícita del usuario, 16 de octubre de 2026.

## Motivo

El mapa integrado en el scroll de Explorar dejaba espacio sin aprovechar y una sola ficha ocupaba media grilla. El usuario solicita una pantalla que se expanda desde Mapa y una ficha inferior deslizable, tomando como referencia la distribución de aplicaciones de movilidad.

## Decisión

- `/home/explore-map` es una ruta protegida por sesión/onboarding. Reutiliza `entityEditorPage`, `OriginPageSource` y `OriginPageTransition`: origen en los límites reales de la opción Mapa, expansión/retorno y movimiento reducido existentes. `TwoOptionFilter` expone el contexto de la opción pulsada mediante callback opcional, sin conocer rutas o funcionalidades.
- Explorar conserva su lista debajo. Mapa observa el mismo `ExploreViewModel`, consulta, páginas y cursor. Abrir/cerrar no dispara búsquedas nuevas ni persiste una vista duplicada en el ViewModel; se retiran `mapSelected` y su operación. Volver de una ficha refresca los resultados como antes.
- El mapa llena el viewport, incluido el fondo tras los controles superiores, sin cabecera/franja opaca ni navegación inferior de Home. Retorno con `GlassNavigationButton`, respetando insets. La entrada usa la expansión compartida solicitada; no se vuelve a revelar el mapa al arrastrar, seleccionar o actualizar.
- `DraggableScrollableSheet` comparte el espacio con el mapa, inicialmente al 42%, con mínimos/máximos del 14/90% y ajuste a esos tres tamaños. Scroll propio y tirador persistente con acciones accesibles para ampliar/reducir. Nunca cubre el retorno al expandirse.
- La primera ubicación cargada tiene una ficha inicial. Elegir un marcador cambia la selección y recupera el panel si estaba reducido. La ficha ocupa todo el ancho mediante `PublicCaseGrid` en modo de una columna y foto con proporción 2:1. Se reutilizan foto, superficie, nombre, estado, distancia y apertura existentes.
- Coincidencias de coordenadas públicas se mantienen agrupadas: se muestra una ficha por vez y controles Anterior/Siguiente cuando hay varias. Los marcadores y la aclaración de ubicación aproximada conservan el alcance público. No se inventan nombres ni coordenadas precisas.
- Se conserva paginación explícita en el panel, toast/reintento de errores y shimmer durante trabajo real. `ZoneMapPicker` admite radio de borde y padding de cámara para encajar la búsqueda por encima del panel; su reintento se superpone al mapa para no desbordar el viewport. Sin ubicación disponible no se muestra un mapa con un centro inventado.

No cambia dominio, contratos de datos, RPC019, privacidad, permisos o SQL. HU-07.2/RF-13/issue #33: refinamiento de presentación, sin ampliar el MVP. Sustituye la vista de mapa integrada, selección local de vista y grilla inferior de ADR-052; mantiene sus reglas de datos.

## Validación

Pruebas de navegación comprueban origen exacto, conservación de consulta, ausencia de consultas al abrir/cerrar, detalle/retorno y expansión real del panel. Pruebas de mapa normal/pequeño con texto ampliado verifican selección agrupada de una ficha, apertura de cada origen y navegación sin editar la búsqueda. Renders con teselas neutras de prueba: no validan el servicio cartográfico real. ESTADO registra la suite y el análisis finales. Revisión Android pendiente; no se genera APK ni se publica.
