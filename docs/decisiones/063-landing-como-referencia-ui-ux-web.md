# ADR-063 — Landing aprobada como referencia de UI y UX web

Fecha: 18 de octubre de 2026, America/Lima. Estado: aceptada por instrucción
explícita del usuario. Alcance: documentación y referencia visual web.

## Contexto

El usuario confirma que le encantó la landing terminada y pide documentar las
reglas usadas para desarrollar toda la parte web. ADR-060 limitaba su identidad
a la landing y conservaba QR/acceso/móvil fuera de esa referencia.

## Decisión

[REGLAS_UI_UX_WEB](../REGLAS_UI_UX_WEB.md) establece la base para todos los
recorridos de `apps/platform`: público, usuarios y administración. Recoge los
valores finales del CSS y componentes Vue, incluidas las variantes originales
del hero/secciones restauradas y los botones azules con brillo, sin recuperar
paletas intermedias descartadas. Complementa ADR-058 y sustituye la restricción
visual de ADR-060 que impedía extender la identidad de landing al resto de web.

La referencia móvil permanece vigente. Se conserva arquitectura por funcionalidad,
autorización de servidor y separación de datos públicos/privados. Los estados
operativos siguen ADR-027/028: toast superior, skeleton y shimmer accesibles.

## Alternativas y consecuencias

Ampliación explícita18/10/2026: el usuario pide que el detalle lateral sea una
mancha superpuesta al footer sin desplazar contenido y corrige su tipografía.
La frase decorativa usa Kalam Regular autoalojada con licencia SIL OFL, elegida
por su trazo manuscrito próximo a la imagen; no se afirma identificar la fuente
exacta de la referencia. Esta excepción es local al adorno, sin cambiar Arial
del resto de la plataforma. Se conserva CSP font-src self y no se consulta un
proveedor externo al visitar la landing. El adorno absoluto no reserva columnas
ni padding y permite superposición visual por instrucción del usuario, manteniendo
pointer-events none para no interceptar acciones. Se oculta por debajo de1100px.

Mantener sistemas visuales separados para landing, usuarios y administración
contradice la referencia común solicitada. Copiar toda la composición de landing
a cada pantalla tampoco resuelve formularios/listados: se heredan identidad y
patrones, con escala y distribución adecuadas a la tarea.

La aprobación de diseño no certifica contraste global, otros navegadores ni
publicación. No se crean rutas, componentes vacíos, HU, RF o issues nuevos.

## Transición y validación

Este incremento solo documenta la norma. El QR existente no se declara migrado:
al intervenir cada recorrido se adaptarán componentes compartidos con evidencia
responsive, estados, accesibilidad y regresión landing/QR. El login/panel/admin
se implementará cuando corresponda a una funcionalidad autorizada.

Actualizar puntos de entrada documentales y ficha de landing; comprobar enlaces,
consistencia con código y ausencia de cambios de aplicación. No requiere repetir
builds por edición exclusiva de Markdown. Resultados en ESTADO.

## Ajuste del fondo general — 18/10/2026

Por nueva instrucción explícita del usuario, la landing sustituye el radial
crema por base blanca con celeste difuminado lateral y transición al cream
existente del footer. Se aplica al fondo exterior de landing; no modifica
los fondos propios de secciones ni los componentes de otros recorridos.
Regla web y ficha actualizadas. QA local1440/390/320px (texto200% en320),
sin overflow ni errores de página; captura de escritorio revisada. Sin despliegue.

## Resplandor reutilizable — 18/10/2026

Por instrucción del usuario se implementa BackgroundGlowOrb compartido en
app/components, adaptando el efecto de su proyecto sader-panel a Vue/CSS.
La landing lo incorpora detrás del contenido, con celeste tenue y máscara que
conserva el cream del footer. Intensidad por clases y colores por tokens CSS,
sin estilos inline ni excepciones CSP. Animaciones CSS, grano SVG local,
aria-hidden/pointer-events none y movimiento reducido estático. Reutilizable
por otros recorridos sin imports de presentación entre funcionalidades.
Tipos,25 pruebas, build y QA Chrome responsive/SSR/CSP/QR aprobados; evidencia
y límites en ESTADO y ficha de landing. Sin despliegue.

Ajuste posterior18/10 solicitado: el fondo del panel de propósito usa blanco
con cream tenue al final (degradado160deg #FFFFFF/#FFFDF8/--cream).
Variante local de .purpose, sin cambio de arquitectura o alcance funcional.
Validación Chrome1440/390/320px, texto200% en320, sin overflow/errores.

Corrección explícita posterior18/10, con captura: la indicación anterior
corresponde al fondo exterior detrás del carrusel, no al panel de propósito.
Se revierte su degradado y se mantiene #F3F2EE. .character-strip incorpora
una capa blanca/cream difuminada, conservando contenido y animación.
Validación Chrome1440/390/320px sin overflow/errores; sin despliegue.
