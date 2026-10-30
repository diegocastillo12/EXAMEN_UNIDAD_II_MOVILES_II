# ADR-128: identidad móvil en el origen web fullscreen

Estado: aceptada por instrucción explícita del usuario,21/10/2026.

Aprobación visual confirmada por el usuario el21/10/2026, con petición de
documentarla para reutilización. [Patrón UI/UX](../patrones-ui-ux/expansion-desde-origen.md)
recoge el contrato vigente y su integración; no cambia sus parámetros ni
declara aprobados otros recorridos por el hecho de reutilizar el motor.

## Instrucción

Combinar la expansión fullscreen aprobada de Sader con el nacimiento y retorno
del botón de móvil: se estira su superficie negra, conservando el tamaño de
los nueve puntos, y se transforma progresivamente en el destino. Aplicar al
abrir y cerrar. Complementa ADR-127; no sustituye sus0.7s/CustomEase ni agrega
una espera/reveal al finalizar. Perfil/Alertas y Flutter no se modifican.

## Decisión e implementación

Se revisa OriginPageTransition de Flutter: source.color/radius/child, identidad
centrada con dimensiones originales y opacidad hasta45%, radio que interpola
a0 y fondo de página que sustituye el negro mientras crece la superficie.

La web conserva GSAP Flip de Sader y viewport completo. Captura solo el icono,
etiqueta y estilos del control; no clona páginas ni formularios. La identidad
visual aria-hidden se centra dentro de la misma superficie y compensa ambos
ejes de escala para mantener el tamaño real del icono. Reutiliza la fase source
de originMotionFrame (45%, easeInOutCubic) y la invierte al cerrar. Se oculta
temporalmente el control original para evitar verlo duplicado; se restaura
al finalizar/cancelar incluso si ya está desconectado por la ruta.

La superficie permanece opaca, sin blur. Su relleno negro se transforma al
degradado de página con la geometría de Sader. Radio calculado en coordenadas
visuales como ClipRRect de móvil, compensando scaleX/Y; se evita interpolar
shorthands mixtos de porcentaje y px, que devolvían una esquina en vez de círculo.
La entrada/salida de opacidad/blur de Sader se aplica solo al cuerpo de destino,
conservando sus500ms/curva y cierre700ms. Así no desaparecen ni se desenfocan la
superficie negra o sus puntos. Es una combinación explícita, no paridad global
de tiempos/fases con Flutter (allí contenido desde65% y320/260ms).

## Limpieza, permisos y validación

Se retiran identidad, estilos temporales, espaciador y referencia geométrica;
se restaura control/cabecera al terminar, reducir movimiento, resize real,
cambiar identidad o desmontar. Capturas de icono solo en memoria de la misma
cuenta; clear/retorno/navegación liberan su referencia. No cambia acceso global,
guards de borrador, datos, APIs ni permisos. Ruta anterior conservada detrás.

QA real GSAP por ambos accesos: tamaño del icono constante en apertura/cierre,
fuente hasta45%, retorno visible antes de llegar, radio circular al cerrar,
fullscreen, cuerpo dentro del contorno, sin salto al finalizar, limpieza,
reaperturas, reducido, resize e identidad. Resultados en ESTADO. Sin despliegue,
nuevas HU/RF o ampliación funcional.
