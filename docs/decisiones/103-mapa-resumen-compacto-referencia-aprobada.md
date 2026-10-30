# ADR-103: mapa y resumen compacto según propuesta aprobada

Fecha:20/10/2026. Estado: aceptado por instrucción explícita del usuario.
Trazabilidad: HU-07.2 / RF-13 / issue #33.

## Decisión

Corrección de color vigente20/10: el usuario rechaza el amarillo hueso intenso
y aporta una segunda referencia de cartografía blanco grisáceo apenas cálido.
Solo teselas: luminancia92% con mezcla8% hacia blanco y azul−4; gris245 produce
#F6F6F2 y blanco #FFFFFB. Sustituye el tinte #F7F5EB/#FFFDF3 descrito abajo.
Mantener símbolo oficial, créditos y operaciones; no añadir la ruta dibujada
de la referencia de seguimiento.

Aplicar la propuesta visual generada con ImageGen en este chat, basada en la
referencia de seguimiento aportada por el usuario, al mapa de casos de Explorar.
Mapa claro sin disco gris ni contorno del radio; conservar proveedor configurado,
créditos enlazados, consulta por radio y coordenadas públicas aproximadas.
Corrección posterior20/10: desaturación y tinte amarillo hueso solo en teselas
(claro orientativo #F7F5EB; blanco fuente a #FFFDF3),
sin alterar pines/créditos. Al seleccionar un caso, acercar hasta zoom15 si la
vista era más lejana; conservar zoom superior y permitir pan/zoom manual.
Cabecera Explorar dentro de GlassSurface/radio24 con padding22/12, conservando
centrado, retirada al expandir y movimiento reducido. Foto ampliada de80 a112px.
Pines con silueta de ubicación, símbolo oficial only-black.svg y selección
negra con símbolo blanco; sin agrupación ni modificación de coordenadas.

Panel blanco redondeado50–90%, tirador persistente y contenido desplazable.
Elección final del usuario20/10: inicio y mínimo50%, sustituyendo60% por ser
demasiado alto. Mantener scroll para alcanzar la fecha cuando sea necesario;
selección, colapso, cámara y resistencia usan también50%.
Corrección posterior20/10: inicio y mínimo60% (antes45%) para mostrar también
la fecha tras ampliar foto/espaciados. Selección, colapso, cámara y resistencia
usan el mismo mínimo. Pantallas pequeñas/texto ampliado conservan scroll.
Resumen horizontal con foto112×112/radio18 (mayor que la miniatura de la propuesta),
nombre y rasgos públicos como descripción hasta dos líneas. Si no existen rasgos,
se omite la descripción en lugar de inventarla. Flecha circular48px con el mismo
acabado de la selección de la navegación: NavigationAccentSurface compartido
en core, degradado/brillo/sombras e interacción200ms con movimiento reducido.
La flecha y Ver ficha abren el mismo detalle existente desde su origen real.
Ver ficha usa superficie gris/radio12 antes del separador; detalles de tamaño,
especie y fecha en filas verticales. Carga de tamaño con shimmer y fallo con
toast/reintento existentes. Bloquear aperturas duplicadas durante navegación.
Corrección de espaciado20/10 según captura del usuario: separador con16px
verticales a cada lado,16px entre título y datos y16px entre filas (antes10/8).
Conservar tamaño del texto y agrupación etiqueta/valor; acceso por scroll.

Sustituye foto4:3 y fila horizontal de ADR-099, CTA fijo de ADR-097 y mínimo42%
de ADR-061. El vacío compartido, scroll, resistencia, retorno y paginación
permanecen. No añadir menú sin acción ni operaciones de seguimiento/rutas.

## Consecuencias y validación

Cambio de presentación; sin SQL, nuevas operaciones de dominio ni permisos.
ZoneMapPicker permite ocultar radio y desplazar créditos solo en este consumidor;
mapas de edición conservan sus valores por defecto. No importar presentación
entre funcionalidades para compartir el acabado azul.

Verificar aperturas desde ambos botones, consulta/retorno y separación de pines,
texto ampliado/altura reducida, carga/fallo y fronteras arquitectónicas. Capturas
con teselas de fixture no acreditan cartografía remota. Resultados y siguiente
paso en ESTADO.md y funcionalidades/explorar.md; revisión Android pendiente.
