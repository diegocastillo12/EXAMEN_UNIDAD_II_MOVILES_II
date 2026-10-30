# ADR-024: vista previa de publicación con foto protagonista

Fecha: 10 de octubre de 2026. Estado: aceptada por instrucción explícita del usuario. Alcance: vista previa y ficha pública de reportes HU-05/RF-05 y HU-06/RF-06.

## Contexto y decisión

El usuario aporta una referencia con fotografía protagonista, nombre sobre la imagen y panel inferior de datos/acción. Solicita reutilizar componentes y expandir descripciones largas suavemente al tocarlas. La composición anterior de fotos pequeñas y texto vertical no satisface esta referencia para la vista previa.

CasePublicationPreview de core compone un pager de fotos a ancho completo, indicadores cuando hay varias, título de mascota/especie y panel inferior GlassSurface existente. CaseScreenShell conserva GlassNavigationButton, toast, scroll y una única transición cover→stagger; la etapa de vista previa usa composición inmersiva sin cabecera opaca. Las funcionalidades aportan solamente información pública y sus acciones reales; el panel reutiliza primaryActionButtonStyle y LoadingShimmer existentes. La ficha pública y la vista previa usan la misma composición; la galería del formulario conserva sus tiles112–160.

ExpandableDescription es una responsabilidad visual compartida: hasta dos líneas al contraerse, clic en texto/indicación para expandir/contraer, cambio de altura320ms con easeInOutCubic. No reproduce reveal ni reinicia foto/estado/envío. Respeta texto ampliado y movimiento reducido (contenido inmediato sin AnimatedSize). Solo ofrece interacción si el texto supera dos líneas.

Se muestran datos disponibles de cada reporte, fecha y explicación de privacidad/zona aproximada. El reportero de encontrada no adquiere un nombre de mascota ni edad inventados. No se incorporan precio, venta, favoritos, peso ni acciones sin respaldo. Punto exacto/referencia privada no se proyectan en la vista previa. No cambia dominio, persistencia, RPC, SDK o permisos.

## Consecuencias y validación

El panel y la descripción crecen por contenido; las superficies pequeñas usan el scroll existente para mantener acciones alcanzables. Se revisan390×844 y320×350 con texto2, variantes contraída/intermedia/expandida, pager y movimiento reducido. Los fixtures de imagen/capturas locales no acreditan descargas remotas ni publicación real. Evidencia y pendientes en ESTADO; actualización integrada de Android pendiente.

## Ficha pública y acciones redundantes — 10 de octubre de 2026

Por instrucción posterior del usuario, se elimina la composición antigua de las fichas públicas de perdidos/encontrados. Sus widgets delegan en el mismo renderer de la vista previa y CasePublicationPreview: fotos grandes deslizables, datos reales, panel GlassSurface y ExpandableDescription. CaseScreenShell admite título inmersivo para distinguir Ficha pública de Vista previa pública. La ficha conserva estado activo, consulta/refresh con progreso superpuesto y privacidad; las acciones Publicar/Editar permanecen en la vista previa. La explicación preventiva de publicación se presenta solamente antes de publicar.

El formulario de perdida retira Volver a consultar fotos y Mis casos. Se conserva Consultar Mis casos únicamente ante un envío de resultado ambiguo, como recuperación necesaria. No cambia acceso a la lista desde Reportar, selección de fotos, borrador, dominio, contratos ni persistencia. Las pruebas comprueban composición única, ausencia de opciones retiradas y acciones públicas alcanzables en tamaño normal/pequeño con texto ampliado.


Actualización del 10 de octubre de 2026: por instrucción del usuario se retira el título glass flotante de la ficha/vista previa inmersiva; se conserva únicamente GlassNavigationButton para volver. Fecha del suceso a20px/negrita, con ajuste por texto ampliado. La ubicación se representa mediante ZoneMapPicker compartido en modo lectura, con la zona aproximada pública, círculo y sin marcador de punto exacto; formulario conserva edición del punto privado. Preview usa la proyección aproximada existente y ficha solo las coordenadas públicas del contrato. Errores del mapa usan toast superior compartido y conservan Reintentar mapa, sin mensajes bajo el mapa ni solicitud de coordenadas numéricas. La consulta no modifica ubicación ni captura el scroll vertical. Sustituye las indicaciones previas de título inmersivo y ubicación explicada solo por texto.
