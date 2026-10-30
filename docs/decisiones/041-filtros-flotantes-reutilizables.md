# ADR-041: filtros flotantes con selectores reutilizables

Estado: sustituida en su comportamiento modal por [ADR-042](042-filtros-integrados-y-busqueda-zonas.md), por nueva corrección del usuario. Se conserva la extracción de cápsulas compartidas. Fecha: 15 de octubre de 2026, America/Lima.

## Problema y decisión

El usuario pide que Filtrar casos se abra por encima de la grilla, sin empujar resultados, y que siga el selector Activas/Archivadas de la captura como referencia. Se retira ExpansionTile de Explorar y se introduce un panel modal flotante, con fondo blanco, bordes28, cierre glass y contenido desplazable dentro de la ventana.

El control permanece en el mismo lugar y abre una ruta superpuesta en el Navigator raíz. La colección no cambia geometría ni posición al abrir/cerrar. Tocar fuera, Atrás y X cierran sin aplicar. Aplicar confirma los valores y dispara la consulta existente; los cambios sin confirmar se descartan al cerrar. La última selección aplicada se conserva durante la visita. La carga real se comunica mediante LoadingShimmer sobre el control; no se añade una operación remota por abrir o editar opciones.

## Reutilización y estilo

`FilterPopover<T>` en core recibe etiqueta/título, constructor del editor y callback de resultado. Se ocupa del disparador, ruta modal, límites, scroll y ciclo de vida, sin conocer filtros de negocio. `FilterChoiceGroup<T>` recibe opciones/selección/callback y mide texto con el tema real: cápsulas compartidas, grupos que se redistribuyen con ancho/texto ampliado, indicador negro único con movimiento320ms/easeInOutCubic y semántica de selección exclusiva.

`SelectionPillSurface` extrae la superficieE5E5EA, padding6 y radios32/26 de TwoOptionFilter. El selector existente delega en esa misma superficie, conservando su indicador y comportamiento. No se copia su interfaz como una variante visual independiente. Selección negro111111/blanco, tipografía14/600 y objetivos táctiles mínimos48. Las opciones largas crecen sin truncar el texto.

Cabecera del panel fuera de cover→stagger; el cuerpo inicia tras el cover y no reinicia la entrada al editar opciones. Movimiento reducido desactiva transición de ruta, reveal e indicador. El título corto Filtros permite mantener cierre y lectura en320×350 con texto2. No hay errorText, mensajes bajo inputs ni indicadores circulares/lineales.

## Fronteras y recursos

Core no importa funcionalidades. ExploreFilters compone el editor específico con dominio como datos y callback del ViewModel; el borrador visual es local al panel. La validación de centro manual mantiene shake/borde danger y toast superior, sin cerrar el panel ni consultar servidor cuando falta. Las reglas de consulta permanecen en dominio y servidor. Resueltos mantiene el permiso previo, con instrucción visible de privacidad.

El componente conserva la ruta exacta que creó y la retira al desmontar su propietario, por ejemplo al cambiar de cuenta; no deja ventanas sobre una nueva identidad ni aplica resultados tardíos. Se bloquea apertura duplicada y doble confirmación. Toast y mapa del editor conservan su disposición existente. Sin cambios de SQL, persistencia, filtros disponibles, permisos o alcance de HU-07.1/RF-13.

## Validación

Las regresiones de Explorar comprueban geometría de la grilla intacta, apertura sin consultas, cancelación sin aplicar, selección confirmada/restaurada al reabrir, cierre por Atrás, normal390×844 y pequeño320×350/texto2/movimiento reducido. Una prueba específica retira el propietario mientras está abierto y verifica limpieza de ruta sin callback. Suite general y capturas registradas en ESTADO; la evidencia con fixtures no acredita Android/Supabase remoto.
