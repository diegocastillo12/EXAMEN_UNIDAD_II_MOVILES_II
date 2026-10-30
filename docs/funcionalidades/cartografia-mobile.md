# Cartografía móvil compartida

Excepción de posición20/10, ADR-106: Explorar compone MapAttribution.compact
fuente8/objetivos48 justo sobre el panel, derecha, acompañando su gesto. Los
demás mapas conservan crédito superior/fuente10. Enlaces/reintento y paleta
global compartidos; no se permite ocultar la atribución sin reemplazo.

Regla vigente20/10: [cartografía compartida móvil/web](cartografia-compartida.md)
y ADR-104. ZoneMapPicker aplica MapStyle a todas las teselas: mezcla50/50 entre
color original de Reportar y acabado anterior de Explorar. Pines/radios/créditos
sin filtrar; configuración/proveedor de las notas siguientes conservados.

Implementación local19/10/2026: CARTO Positron mediante MAP_TILE_URL, referencia
clara del usuario y pines de marca conservados. Ajuste de HU-07/RF-13, sin historia
nueva ni cierre de las existentes. [ADR-084](../decisiones/084-mapa-mobile-claro-carto-positron.md).

- **Recorrido:** Explorar y selectores/mapas de lectura comparten ZoneMapPicker;
  reciben la misma cartografía configurada. Pan/zoom, selección, radio, grupos y
  apertura de fichas mantienen las operaciones anteriores.
- **Reglas:** estilo raster light_all con etiquetas; crédito legible superior
  derecho con enlaces independientes a OpenStreetMap y CARTO. Texto ampliado
  permite ajuste de líneas; retorno separado y reintento debajo del crédito.
- **Persistencia y permisos:** no cambia Supabase ni se envían tokens de sesión
  al proveedor. La clave de teselas queda en configuración local ignorada por Git;
  el proveedor recibe solicitudes de cartografía desde el dispositivo.
- **Errores:** teselas fallidas conservan toast y Reintentar mapa, sin cambiar la
  ubicación seleccionada. Enlaces sin navegador muestran toast y admiten otro toque.
- **Activación:** config/supabase.local.json contiene MAP_TILE_URL con clave válida;
  iniciar Flutter con --dart-define-from-file=config/supabase.local.json. Reinicio
  completo o recompilación tras cambiar configuración. Sin define sigue OSM estándar.
- **Evidencia y pendientes:** descarga HTTPS real de tesela Positron confirmada
  con200/image/png e inspección visual. Comprobaciones Flutter en ESTADO. Sin
  Android conectado; falta revisión del estilo y de los créditos en dispositivo.
