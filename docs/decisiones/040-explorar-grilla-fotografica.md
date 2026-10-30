# ADR-040: grilla fotográfica de Explorar

Estado: aceptada por instrucción explícita del usuario. Fecha: 15 de octubre de 2026, America/Lima.

## Motivo y decisión

El usuario prefiere cards en grilla con imagen protagonista, de inspiración Apple, aunque ocupen más espacio. Explorar sustituye las filas con miniatura de ADR-039 por tarjetas fotográficas. Es una composición específica de esta consulta colaborativa y conserva los componentes y tokens neutros de la app.

Por aclaración del usuario con captura, la grilla usa exclusivamente el scroll vertical del shell: dos columnas completas dentro de la pantalla, margen lateral12 y separación14. Se retira la interpretación previa de cards al76% con scroll horizontal. El contenido tiene una columna cuando su ancho es inferior a280px o el texto16 escalado supera21px. Título y filtros conservan margen24 mediante composición, mientras las cards aprovechan más ancho. Filas de altura natural y tarjetas igualadas dentro de cada fila, sin alturas rígidas ni recorte del texto. Por corrección posterior del usuario, imagen horizontal4:3 a todo el ancho, nombre/tipo20 en negrita y especie/distancia debajo. Se retira la fecha de la card; estado Abierto/Resuelto aparece únicamente como badge neutro en la esquina superior derecha de la imagen, con texto escalable. La fecha sigue disponible en la ficha y conserva su función en filtros. EntityCardSurface mantiene radio22 y superficieF5F5F7. La tarjeta completa abre la misma ficha, tomando su rectángulo como origen de la transición.

La fotografía usa CasePhotoView compartido, con skeleton/shimmer y feedback superior existentes. Si el reporte no tiene foto se reserva una superficie neutra con icono, sin inventar una imagen. El skeleton inicial reproduce cuatro tarjetas de la misma grilla. No se añaden sombras, gradientes decorativos, controles sin acción o una biblioteca visual nueva.

## Fronteras, conservación y alcance

Todo pertenece a presentation/widgets de explore. La grilla recibe entidades y callback de apertura; ExploreSection sigue consumiendo un único ViewModel. Se conservan filtros, páginas, retorno/refresh, privacidad, URLs de miniaturas y contratos de ADR-039, sin cambios de SQL, dominio o servidor. La entrada mantiene cover→stagger del shell; paginar/refrescar no la repite. HU-07.1/RF-13 conserva alcance y HU-07.2 sigue pendiente.

## Validación

Se adaptan las regresiones visuales existentes con tres tarjetas, cantidad impar, dos fotos de fixture y un registro sin foto. Comprueban dos columnas completas junto a los bordes, ausencia de scroll horizontal y desplazamiento vertical real, una en320×350 con texto2/movimiento reducido, alturas naturales sin overflow y apertura de ficha desde la card. Las imágenes de revisión vienen de un asset local usado solo por el harness; no son reportes de producción ni prueba de Storage remoto. Evidencia y pendientes en ESTADO y en la ficha de Explorar.
