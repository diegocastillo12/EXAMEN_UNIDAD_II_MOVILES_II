# ADR-031: casos reutilizan la UI y efectos aprobados de Mascotas

Estado: aceptado por instrucción explícita del usuario. Fecha: 11 de octubre de 2026.

## Motivo

El usuario considera terminada la UI de Mascotas y exige usarla como referencia exacta en Casos, empezando por registrar. La revisión detectó rutas nuevas sin transición, origen visual ignorado, cabecera con geometría distinta, campos/fotos/mapa fuera del stagger y controles alternativos de fotos/tamaño. No se cambia el diseño aprobado de Mascotas.

## Decisión

- entityEditorPage en app/navigation reproduce la apertura320ms/retorno260ms de Registrar mascota, con OriginPageSource (forma/color/contenido del control) y OriginPageTransition existentes. Las tres rutas de creación delegan en esa composición; entrada directa conserva fade y movimiento reducido elimina la animación.
- CollectionAddButton captura la misma fuente para+ de listados y acciones de Reportar. beforeNavigate cierra el panel de opciones antes de navegar; su valor nulo preserva los accesos de mascotas.
- EntityScreenShell en core recibe la implementación de PetScreenShell: ancho440, márgenes24, inset superior+72, separación título28, navegación glass persistente, ScrollSafeArea y cover320ms seguido de StaggerReveal (850ms/elemento, desfase90ms, curva/blur/desplazamiento existentes). PetScreenShell queda como adaptador con los mismos parámetros y tooltip. CaseScreenShell añade toast y configuración por etapa sin duplicar el renderer. La ficha inmersiva conserva su panel de ADR-030.
- Found y lost completan las entradas de campos opcionales, fotos/instrucciones, mapa/coordenadas, custodia y acciones. Se mantiene el timeline al editar, abrir teclado, cambiar selección o reintentar. Skeleton a contenido permanece en la misma entrada, sin retrasos artificiales.
- PhotoAddTile y SizeChoiceSelector se extraen de las implementaciones de Mascotas a core sin cambiar su geometría o efectos. Mascotas adapta sus valores de dominio; Encontrados adapta sus strings sin importar presentación ajena. Tamaño desconocido continúa opcional y se deselecciona; no se añade metadata obligatoria. Galería, contador interior, validación y shimmer reutilizan los componentes existentes.
- Listados de casos animan cabecera y grupo de contenido como Mascotas, evitando una ranura de animación por cada registro (que antes excedía el count fijo al crecer la lista). Se conservan filtro, swipe, diálogos y acciones confirmadas.

## Consecuencias y validación

Sin cambios de contratos/backend ni reglas de publicación. La aprobación de UI no implica cerrar HU-03/HU-05/HU-06. Las fronteras continúan protegidas: core no importa features; colaboración por valores/callbacks/adaptadores.

Suite Flutter completa309 pruebas aprobadas; las8 regresiones nuevas verifican controles reales desde Inicio/listado, fuente/radio, movimiento reducido y texto2, campos dentro del stagger, timeline conservado al editar, descarte y retorno. Se repitieron las8 tras reforzar confirmación alcanzable en pantalla pequeña. Capturas normales y pequeñas en build/ui-preview/case-creation revisadas. Fotos/repositorios son sustitutos locales y las peticiones de teselas del test no acreditan mapas reales. Revisión en Android autenticado pendiente.
