# ADR-102: fondo móvil atenuado hacia navegación

Fecha:19/10/2026, America/Lima. Estado: implementado localmente.

El usuario aprueba las luces superiores y pide menor intensidad al bajar hacia
la navegación. Conservamos distribución y movimiento de ADR-091 con atenuación
fija al viewport: tercio superior intacto y blanco progresivo hasta96% en el borde
inferior. Sustituye solo la intensidad inferior de la decisión anterior.

AppPageBackground pinta un velo blanco después de las nubes y antes del contenido.
Se prefiere a reducir cada nube para controlar la intensidad inferior durante todo
el ciclo. No añade capas offscreen, paquetes ni afecta geometría, glass, dominio,
data o permisos. Conserva pausa accesible/TickerMode y liberación. Aplica a todos
los consumidores y transiciones existentes; sin migración, HU/issue o alcance nuevos.

Validación y siguiente paso Android en ESTADO y ficha de fondos móviles.