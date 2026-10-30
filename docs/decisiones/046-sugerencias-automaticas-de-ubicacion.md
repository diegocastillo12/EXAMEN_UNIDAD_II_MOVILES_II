# ADR-046: sugerencias de ciudad o dirección al escribir

Estado: aceptada por instrucción explícita del usuario, 15 de octubre de 2026.

## Decisión

Zona consulta sugerencias al escribir ciudad/dirección sin pulsar Buscar ubicación. Se retira ese botón; el teclado permite búsqueda inmediata cuando no hay otra en curso. El campo permanece editable durante la consulta. Seleccionar un resultado sigue confirmando el centro; escribir no selecciona automáticamente ni aplica filtros de casos.

PlaceSearchViewModel gestiona una pausa reiniciable de600ms y mínimo3 caracteres normalizados (máximo120). Una petición activa a la vez, con una sola consulta automática pendiente reemplazable por la más reciente. Una edición invalida inmediatamente las respuestas anteriores y retira sus sugerencias. Limpiar, seleccionar, cambiar identidad o desmontar cancela temporizadores/cola e invalida respuestas. No se afirma cancelación física del HTTP en curso; se descarta su resultado y se conserva la serialización hasta finalizar/timeout.

Carga real con skeleton/shimmer, sin bloquear escritura. Vacío de sugerencias automáticas queda sin lista y sin toast por cada pausa; búsqueda explícita sin resultados conserva su aviso. Fallos conservan toast superior, teclado como reintento y selección manual en mapa. Permanecen caché5min/30 consultas, cinco resultados y timeout12s.

El proveedor actual [Photon](https://github.com/komoot/photon) declara soporte search-as-you-type. Su demo permite uso razonable sin límites numéricos garantizados y puede limitar/bloquear uso excesivo; la pausa, serialización y caché reducen solicitudes, sin acreditar capacidad para distribución. Sigue pendiente revisar proveedor/instancia antes de volumen mayor. Se consulta el texto al proveedor mientras se escribe, después de la pausa; sin enviar sesión, tokens ni datos privados de casos.

Sustituye la búsqueda exclusivamente explícita y ausencia de autocomplete de ADR-042. Sin nuevos SDK, permisos, SQL ni contratos de dominio.

## Validación

Formato Dart y revisión de temporizadores/cola/generaciones. Recorrido existente adaptado a esperar600ms en lugar de enviar la acción Buscar; no ejecutado por instrucción del usuario. Sin nuevas pruebas, renders, build o consultas reales del proveedor. Pendiente Android: escritura rápida, cambios durante HTTP, selección, cierre/cuenta, fallos/reintentos y resultados reales.
