# ADR-106: panel minimizable y créditos compactos en Explorar

Fecha:20/10/2026. Estado: aceptado por instrucción explícita del usuario.
Trazabilidad: HU-07.2 / RF-13 / issue #33.

## Decisión

Conservar apertura del mapa al50% y máximo90%, pero permitir bajar el panel
hasta mostrar el resumen y Ver ficha, antes del separador de Detalles del caso.
Sustituye el mínimo fijo50% de ADR-103. Medir la altura real del resumen y del
botón en layout; mínimo = tirador32 + resumen + inset inferior +12px, dividido
por altura disponible, con límites18–85%. Sin selección se admite22%.
Con texto ampliado/altura reducida, la apertura aumenta si50% no permite el
mínimo accesible. Con contenido excepcional que exceda el límite, conservar
scroll. No reducir fuentes ni inventar datos para ajustar el panel.

El área de scroll deja inset inferior+12px libres sobre la navegación del
sistema. En el mínimo normal se ve Ver ficha completo y el separador queda
fuera de la vista. Snap en mínimo,50% cuando cabe y90%; colapso accesible
restablece scroll. Mantener resistencia/rebote, movimiento reducido, selección,
ficha y paginación/reintento. La cámara reserva también espacio para los créditos.

Refinamiento posterior de movimiento por petición del usuario: el acomodo usa
resorte amortiguado (masa1/rigidez260/amortiguación34) con velocidad inicial del
gesto, normalizada por altura del panel. Sustituye easeInOutCubic320–540ms, que
reiniciaba desde reposo al soltar. Controlador propio cancelado al tocar de nuevo,
incluso antes de ganar el gesto; liberar controlador al desmontar.
El panel sigue directamente al dedo; al soltar, una pasada rápida avanza en su
dirección y una liberación lenta elige la parada más próxima. No interceptar
la inercia del contenido cuando la lista ya se está desplazando. La resistencia
inferior vuelve con resorte amortiguado (masa1/rigidez190/amortiguación28), sin
rebote excesivo. Créditos acompañan los mismos controladores.

Nuevos gestos/movimientos invalidan acomodos pendientes; callbacks tras frame
verifican mounted/controlador adjunto y se invalidan al liberar la pantalla.
Un toque en una acción no dispara snap. Movimiento reducido conserva acciones
inmediatas y detiene la inercia del panel al soltar, sin acomodo autónomo.

Créditos de Explorar a la derecha justo encima del borde del panel, siguiendo
arrastre y resistencia. Reutilizar MapAttribution.compact con fuente8 (antes10),
fondo estrecho y objetivos táctiles48px, enlaces reales y toast ante fallo.
Texto respeta ampliación; en ancho limitado puede elidirse con tooltip/nombre
accesible completo. Reservar izquierda84 para retorno. Retirar solo el título
central cuando no hay espacio vertical para cabecera/créditos, manteniendo el
retorno hasta la expansión máxima. Con mapa casi cubierto y sin espacio seguro,
ocultar crédito en lugar de superponerlo al área del sistema.

Los demás mapas conservan ubicación/tamaño previos de los créditos. Esta
decisión sustituye la posición superior de ADR-084 únicamente en Explorar;
paleta global ADR-104, proveedor, contratos, coordenadas y permisos intactos.

## Implementación y validación

Medición y alturas pertenecen a presentación: ExploreMapPreviewContent reporta
altura tras layout; ExploreCaseMap ajusta límites y compone MapAttribution.
ZoneMapPicker permite omitir su crédito cuando el contenedor lo compone en otra
posición. No eliminar créditos ni usar esta opción para evitar atribución.
Liberar controladores/listeners y comprobar normal/pequeño/texto2, gesto de
minimizar, botón visible, créditos sobre panel, selección y navegación de mapa.
Evidencia y limitaciones en ESTADO y la ficha de Explorar; sin SQL ni despliegue.
