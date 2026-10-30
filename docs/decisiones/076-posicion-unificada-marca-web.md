# ADR-076: posición unificada de la marca web

Fecha: 19/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Decisión

En apps/platform, el logo oficial junto al texto «entre huellas» se sitúa en
la cabecera superior, alineado a la izquierda con la posición y los márgenes
de la landing aprobada. El onboarding actual es la referencia de aplicación
de esa posición fuera de la landing.

En responsive la marca permanece arriba, con los márgenes adaptables de la
cabecera; no se centra dentro de formularios, tarjetas o la columna de contenido.
Se conserva fuera del stagger, de skeletons y de cambios de etapa. La regla
establece la posición de la marca; no exige fijar la cabecera al hacer scroll.

Aplica a los recorridos web públicos, de usuario y de gestión, incluido acceso.
Sustituye las composiciones previas que coloquen la marca dentro del contenido.
No cambia tipografías, tamaños de ilustraciones, permisos o navegación por rol,
ni la referencia móvil. Reutilizar la cabecera/marca compartida al adaptar código.

## Verificación

Comparar la posición y alineación con landing y onboarding en escritorio y
responsive, también con texto ampliado. La marca debe permanecer estable durante
entradas y cambios de etapa, sin solaparse con acciones ni producir overflow.
Este incremento registra la norma; no afirma una adaptación global del código.
