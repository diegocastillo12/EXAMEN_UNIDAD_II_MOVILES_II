# ADR-119: animaciones web desde origen y navegación liquid

**Instrucción posterior21/10:** el motor de navegación desde origen descrito
aquí y sus aproximaciones se reemplazan por [ADR-125](125-origen-web-reemplazado-por-sader-gsap-flip.md).
Se elimina el clonado/WAAPI y se usa PrettyModal/GSAP de Sader, contenido al100%.
Las reglas de barra liquid que no interviene ADR-125 conservan su vigencia.

Fecha: 20/10/2026, America/Lima. Estado: aceptada por instrucción explícita.

Corrección posterior20/10: el usuario retira también la elevación del acento al
hover. UserNavigation elimina translateY(-2px) en hover/foco/presión; conserva
brillo, foco accesible, selección deslizante y arrastre horizontal con retorno.
Esta corrección sustituye la elevación descrita inicialmente a continuación.

Refinamiento posterior del20/10, también explícito: barra máxima304px para
opciones más redondeadas (aproximadamente71×52px). Por corrección posterior del
usuario, se retira el impulso horizontal al hover. Arrastre hasta8px con retorno
480ms al soltar, sin activar destinos. Movimiento reducido elimina este efecto extra;
conservar deslizamiento de selección, elevación, enlaces y limpieza existentes.

## Contexto

El usuario corrige la primera adaptación web: la barra móvil no tiene etiquetas
visibles y faltan el indicador que se desplaza y las aperturas desde el origen.
Solicita llevar los efectos reales a componentes web reutilizables.

## Decisión

UserNavigation es solo iconos en todos los anchos, con aria-label/title/foco y
áreas de 52/64 px. Su instancia permanece montada al cambiar secciones, fuera de
NuxtPage. Un indicador azul único se desplaza 320 ms con la curva de móvil; los
iconos interpolan gris/blanco según la posición real. Hover/foco/presión levantan
el acento 2 px/200 ms. Se conserva el acabado GlassSurface/navigation accent de
móvil y el botón negro independiente de Reportar.

El plugin navigation_motion crea estado de presentación por aplicación, sin
serializar DOM/identidad en SSR. AccountScreen habilita la barra únicamente tras
confirmar cuenta/bienvenida; el host restringe su visibilidad a las cuatro rutas
de cuenta. No se crean reglas de acceso alternativas a la política global.

OriginTransitionHost y su controlador compartido expanden la superficie real del
control: bounds, radio, color e icono/etiqueta. Entrada 320 ms y retorno 260 ms,
como OriginPageTransition/router móvil. La identidad del origen se desvanece
hasta el 45%; el contenido aparece del 65% al 100%. Cabecera/marca y barra quedan
fuera de la transformación. La superficie crece hasta el área bajo la cabecera.

NavigationLink opta por este efecto con origin; OriginActionButton lo reutiliza
en cambios locales. Aplicaciones iniciales: Reportar, Registrar/Editar mascota y
acceso autorizado a revisión. Volver desde la ruta de origen y cancelar editor
revierten el efecto. Rutas directas/recargas no inventan un origen. Se conservan
stagger, permisos, formularios y guard de cambios pendientes.

La pantalla anterior puede permanecer como copia visual inerte durante la
expansión: sin campos de formulario, IDs, scripts, diálogos o avisos, sin eventos,
sin almacenamiento ni SSR. Se libera al terminar/cancelar y no se conserva en el
registro de retorno. Un cambio de identidad cancela y limpia el efecto. Nunca se
capturan credenciales de acceso ni se reutiliza una copia entre cuentas.

## Consecuencias y validación

### Corrección de implementación desde Sader —21/10/2026

Por instrucción explícita reiterada del usuario, la expansión debe mover y
escalar el contenido desde el origen; un fade con escala .98→1 en su posición
final, aunque tenga recorte, no cumple. Se traslada la técnica FLIP de
PrettyModal/ExpandIntactModal de sader-panel: medir el destino con su layout
final e invertirlo al rect real del disparador, compartiendo traslación/escala
entre superficie y cuerpo vivo. No se importan React/Framer/GSAP; WAAPI aplica
la matriz equivalente y conserva320/260ms, curvas/fases de ADR-124.

Los radios y el icono decorativo compensan la escala de la superficie. Ningún
formulario se clona para el morph. El primer fotograma corresponde al botón,
el contenido permanece oculto antes de65% y sigue creciendo cuando se revela.
Al montar el host se retiran capas huérfanas de implementaciones anteriores
para que HMR no perpetúe una copia antigua en una pestaña ya abierta.

QA debe medir el primer fotograma y matrices comunes durante el crecimiento,
no solo el recorte o estado final. Probar nueve puntos y acceso negro de Inicio
en servidor de desarrollo y build, además de retorno/cancelación/reducido.

Animaciones mediante CSS/WAAPI/CSSOM, compatibles con la CSP vigente sin unsafe-inline.
Esperar montaje de la nueva página de Nuxt antes de adjuntar la superficie a su
shell. Retorno, resize/orientación, movimiento reducido, cambios de identidad y
desmontaje liberan máscaras, promesas, frames e inert. Navegación cancelada no
reproduce el efecto; clic modificado/otra pestaña conserva el comportamiento web.

La expansión explícita desde un control sustituye solo esa apertura, no introduce
una cobertura global opaca/crema ni reemplaza el stagger general de ADR-075.
No se añade ocultamiento de barra por scroll vertical: LiquidNavigation móvil
mantiene su posición; se traslada el deslizamiento real de su indicador.

QA Chrome de fotogramas, retorno, identidad, cancelación y movimiento reducido;
build/tipos/pruebas y pendientes en ESTADO y ficha transiciones-web. Sin backend,
SQL, Flutter, publicación o cierre de historias por este incremento.
