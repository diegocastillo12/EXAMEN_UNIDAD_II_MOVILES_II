# ADR-061: altura mínima del panel del mapa y retorno progresivo

Fecha:18 de octubre de2026. Aceptada por instrucción explícita del usuario.

## Motivo y decisión

El usuario pide que el panel de filtros de Explorar no pueda quedar por debajo
de su posición normal, que el retorno glass se retire hacia arriba al expandir
el panel y que desaparezca el título redundante Filtros de búsqueda.

La altura inicial y mínima es42% del viewport y la máxima sigue90%. Sustituye
el estado14% de ADR-055/056, incluso al seleccionar un pin. La cámara y la etiqueta
del caso reservan ahora el espacio del panel normal; no se oculta el acceso al
caso. Reducir mediante semántica o aplicar filtros también vuelve al42%.

Un arrastre por debajo del mínimo solo desplaza visualmente la superficie,
con resistencia y un máximo18px; al soltar vuelve en240ms. La extensión real
no cambia por debajo del42%. Movimiento reducido evita este efecto.

ExploreMapScreen observa la extensión mediante notificaciones de presentación.
En el tramo78–90%, el retorno compartido pierde opacidad y se retira hasta72px
hacia arriba; vuelve al reducir el panel. Oculto no recibe toques ni semántica.
Movimiento reducido cambia su visibilidad directamente. El botón Atrás del
sistema conserva la navegación. No se modifica GlassNavigationButton global.

ExploreFilterEditor conserva campos/acciones y retira el título redundante.
No cambia el borrador, la consulta al confirmar, la privacidad, los casos de
uso, los repositorios, los permisos o SQL. No se añaden consultas por gesto.

## Validación

Pruebas con gesto real verifican mínimo, resistencia/retorno, ocultación y
restauración del glass, selección de pines, aplicación, detalle/retorno y
movimiento reducido. Renders normal/pequeño con texto2 usan teselas neutras;
no acreditan cartografía ni fluidez Android real. Resultados en ESTADO.
