# ADR-045: zona de búsqueda independiente de los filtros de casos

Estado: aceptada por instrucción explícita del usuario, 15 de octubre de 2026.

Corrección explícita del16 de octubre de2026: control denominado Ubicación según ADR-047, siempre a la izquierda y Filtrar casos a la derecha en la misma fila, sin disposición apilada. Cápsulas compactas, etiquetas/fuente/área táctil conservadas y altura adaptable; omitir icono inicial cuando falta espacio. Paneles de ancho completo anclados a izquierda/derecha respectivamente. Sustituye el orden/apilado descritos abajo, manteniendo selección y operaciones independientes. Formato/análisis estático; sin pruebas ejecutadas por instrucción del usuario, revisión Android pendiente.

## Decisión

El usuario considera sobrecargado Filtrar casos. Se separa en dos controles: Filtrar casos contiene tipo, especie, estado y fecha; Zona contiene Todas las zonas/Por ubicación, búsqueda de ciudad o dirección, mapa y radio. Su acción es Aplicar zona. Ambos comparten el desplegable anclado y transición de ADR-044, sin mover el listado al abrir.

Controles en fila cuando el ancho y texto permiten leerlos; en vertical con ancho estrecho o texto ampliado, con etiqueta Zona de búsqueda. Ambos editores utilizan todo el ancho del área de filtros; Zona se ancla por la derecha cuando está en fila. FilterExpansion recibe icono/ancho de panel/alineación opcionales, conservando sus valores anteriores por defecto.

La selección confirmada sigue siendo única en ExploreFilters. Aplicar filtros conserva ubicación/radio; aplicar zona conserva tipo/especie/estado/fecha. Cerrar sin aplicar descarta el borrador. No se realizan consultas por abrir/editar y se conserva el bloqueo durante consultas, privacidad y distancia aproximada del servidor. Sin cambios de dominio, persistencia, SQL o permisos.

## Validación

Formato Dart y revisión del flujo de selección. Recorrido existente adaptado para aplicar casos y después abrir/aplicar Zona, comprobando conservación del tipo; no ejecutado por instrucción del usuario. Sin nuevas pruebas ejecutadas, renders o builds. Pendiente revisión visual Android: anchos, texto ampliado, teclado, conservación de filtros y consultas con019 activo.
