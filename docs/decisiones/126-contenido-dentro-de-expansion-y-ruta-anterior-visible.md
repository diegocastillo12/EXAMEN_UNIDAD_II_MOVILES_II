# ADR-126: contenido dentro de la expansión y ruta anterior visible

Estado: aceptada por instrucción explícita del usuario,21/10/2026.

Precisión posterior: ADR-127 sustituye la apertura sin fade y el destino main
por fullscreen y fases originales de PrettyModal. Conserva la ruta anterior
detrás y el contenido dentro del contorno, sin aparición diferida al terminar.

## Instrucción y sustitución

El usuario precisa que la sección actual debe seguir visible detrás y que los
datos nuevos deben verse dentro de la forma desde el inicio, creciendo con ella.
Al terminar no debe aparecer contenido adicional por un reveal diferido.
Esto sustituye la fase de cuerpo oculto hasta100% registrada en ADR-125.
Se conserva su excepción web a ADR-124, duración0.7s y CustomEase de Sader.
Perfil/Alertas y Flutter conservan sus contratos; no es una auditoría global.

## Implementación

NuxtPage usa hooks de transición sin animación CSS de ruta. Mientras se abre
desde origen, Vue conserva el DOM real de la ruta saliente con su callback de
leave pendiente, fijo en su posición y fuera de interacción/árbol accesible.
La entrante tiene fondo exterior transparente durante el morph. Al finalizar,
se completa leave y se retira la anterior. Sin snapshots, cloneNode ni otra
instancia de formularios. No se transforma Reportar en un modal ni se modifica
la política global de acceso o los guards de borrador.

OriginTransitionHost selecciona la superficie entrante, excluyendo la saliente.
GSAP Flip transforma juntos superficie, título, campos y mapa desde el rect y
radio reales del botón. El cuerpo tiene visibilidad/opacidad1 desde el inicio,
pero permanece inert durante el movimiento. Overflow hidden recorta todo al
mismo contorno transformado; el contenido nunca aparece en su posición final
antes de que esa superficie llegue allí.

La superficie pinta un fondo opaco alineado al degradado de página, con relleno
del botón que se disuelve en la misma timeline. Así la vista anterior no se
transparenta a través del formulario: solo se ve fuera del contorno creciente.
Al finalizar se restauran estilos, sin un segundo reveal de contenido.

Retorno: Flip.to sobre el componente aún montado antes de cambiar ruta.
Reducción de movimiento omite morph y retención. Cambio de identidad, fallo de
navegación y finalización liberan la ruta retenida; resize real y preferencias
conservan su limpieza. Los avisos de viewport sin cambio real no cancelan.

## Validación y alcance

QA sobre GSAP real, ambos disparadores: contenido visible desde0%, título
escalado en el contorno, sección anterior real aún visible detrás y retirada
al finalizar; capturas iniciales/intermedias/finales, duración/crecimiento real,
retorno, reaperturas, resize, reducido, borrador cancelado e identidad.
Dev y build con fixture; no usar sesión/datos reales. Resultados en ESTADO.
Sin SQL, permisos, nuevas HU/RF, cambios funcionales o despliegue.
