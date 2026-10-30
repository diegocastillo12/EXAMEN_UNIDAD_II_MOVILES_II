# ADR-030: panel inferior expandible de ficha

Estado: aceptado por instrucción explícita del usuario. Fecha: 11 de octubre de 2026.

## Motivo

La ficha inmersiva obligaba a recorrer un bloque largo para consultar la información y el mapa. El usuario solicita un resumen sobre la fotografía, badge de Desaparición fuera del panel, apertura al tocar o arrastrar hacia arriba y mejor legibilidad de nombres largos.

## Decisión

CasePublicationPreview conserva la foto y pager a tamaño de viewport, y usa DraggableScrollableSheet con scroll interior y controlador liberado al desmontar. El indicador tiene área táctil de48 y semántica de apertura/cierre. El mapa público en lectura se monta al expandir; conserva proyección aproximada, privacidad y reintentos existentes. Nombre blanco con sombra suave, dos líneas y elipsis; badge rojo contextual fuera de GlassSurface, a su lado cuando cabe y debajo con texto ampliado. La fecha completa permanece en los datos ampliados.

CaseScreenShell acota a viewport el contenido inmersivo confirmado y conserva navegación/reveal; carga y formularios mantienen sus contratos. Encontrados usa el mismo componente con badge Encuentro. Animación320ms/easeInOutCubic al tocar y snap al arrastrar; movimiento reducido usa salto inmediato y gesto sin snap. No hay reveal por gesto ni cambio de foto/estado de negocio al expandir.

## Consecuencias y validación

Sustituye la composición larga de ADR-024 para datos confirmados de ficha/vista previa. Sin nuevos contratos, SQL ni acceso a infraestructura desde UI. En pantallas pequeñas con texto ampliado, el contenido completo sigue disponible por scroll interior. Pruebas locales cubren toque/arrastre, mapa ausente antes de abrir, pager, nombre largo, descripción y acciones alcanzables. Revisión en Android con fotos y teselas reales pendiente; no implica cierre de HU-05/HU-06.


### Corrección del anclaje inferior — 11 de octubre de 2026

Por corrección del usuario, el resumen inicial baja (36% del viewport para ficha sin acciones,46% para vista previa con acciones; texto ampliado conserva espacio desplazable). El panel glass ocupa como mínimo el espacio restante hasta el margen seguro inferior aunque haya pocos datos, evitando una tarjeta suspendida con vacío debajo. Nombre con sombra más sutil: opacidad20%, blur3 y desplazamiento vertical1. Apertura/mapa/acciones conservados.
