# Transiciones web desde origen y navegación liquid

El usuario aprueba visualmente la animación de Reportar el21/10/2026 y pide
documentarla para reutilización. [Guía de patrón UI/UX](../patrones-ui-ux/expansion-desde-origen.md):
cuándo usarla, parámetros, piezas compartidas, ejemplos y criterios de revisión.
Esta ficha conserva recorrido y evidencia de implementación; no sustituye la
validación de cada nueva integración.

## Qué hace y recorrido

Complemento vigente [ADR-128](../decisiones/128-identidad-mobile-en-origen-web-fullscreen.md):
la superficie conserva el negro/radio del botón al nacer y regresar. Su icono
se centra dentro y compensa scaleX/Y para conservar el tamaño original, como
OriginPageTransition móvil. Fase fuente45% reutilizada de originMotionFrame,
invertida al cerrar. El control original se oculta temporalmente y se restaura
al finalizar/cancelar; solo se copia icono/etiqueta, nunca páginas/formularios.
Fade/blur de Sader aplica al cuerpo, mientras superficie/identidad siguen
visibles y sin blur. Radio visual compensado por eje para volver al círculo.

Por precisión explícita del usuario del21/10, la sección actual permanece
visible detrás mientras el destino crece desde el botón. Título, campos y mapa
se transforman dentro del contorno con el fade/blur de PrettyModal sobre el cuerpo,
sin aparición diferida al terminar. [ADR-127](../decisiones/127-origen-fullscreen-y-fases-prettymodal-sader.md)
sustituye la apertura sin fade y el destino limitado al main de ADR-126.

Reportar desde nueve puntos o acceso negro de Inicio conserva su ruta real.
NuxtPage retiene el DOM saliente mediante el callback leave de Vue, fijo en su
posición, inert y aria-hidden. La ruta entrante no pinta fondo exterior durante
el morph; GSAP Flip escala su main real con overflow hidden hasta cubrir
100dvw/100dvh, sin límites de columna. Al finalizar se
libera leave y se retira la sección anterior. No hay clones ni snapshots de
pantallas ni una segunda instancia del formulario. La marca y navegación
permanecen fuera de la superficie transformada.

El contenido nunca se revela en su posición final antes de tiempo: su geometría
es hija de la misma transformación. El negro se transforma al degradado de
página con la geometría de Sader; el fade/blur solo afecta al cuerpo. Un
espaciador sin contenido conserva alto/scroll mientras el main ocupa viewport
fijo; el cuerpo conserva sus coordenadas finales. Al restaurar estilos no hay
otro reveal ni salto del contenido.
Skeleton/datos reales siguen sus estados existentes; no se inventan datos ni se
espera a que termine una consulta para animar.

Se conserva GSAP3.15.0, Flip.getState/from/to, scale:true, CustomEase original de
PrettyModal/Sader y0.7s. Apertura copiada de globals.css: opacity0/blur10px a
opacity1/blur0 en500ms cubic-bezier(0.56,0.27,0,1). No hay una espera inventada
al50%: el cambio progresivo resulta de esos parámetros originales.
Cerrar conserva sus keyframes y anima el componente antes de cambiar ruta; queda
oculto hasta el commit para evitar destellos. Los guards de borrador se resuelven
antes; cancelar conserva datos y no lanza contracción. Entrada directa/recarga no
inventa un origen. Editores locales reutilizan el contenido escalado, sin retener
una ruta distinta porque el cambio sucede dentro de la misma página.

## Reglas y componentes

- OriginPageSurface: main real y body, contenido visible dentro del morph,
  identidad por instancia e interacción bloqueada durante movimiento.
- OriginTransitionHost: identidad visual del control y GSAP sobre la superficie entrante, excluyendo la ruta
  retenida; layout final congelado y fondo opaco alineado al degradado de página.
- origin_transition: captura rect/color/radio, coordina rutas/local, retiene y
  libera leave. Sin persistir HTML ni payload SSR de nodos.
- app.vue: hooks estables de NuxtPage para enter/leave, sin fade de ruta ni otra
  política de autorización. CSS exterior transparente solo durante apertura.
- navigation_motion, NavigationLink y OriginActionButton: guards/enlaces reales,
  precarga y convenciones de clic modificado conservadas.

ADR-125/126/127/128 registran la excepción web a ADR-124 para este motor:0.7s y
fases de PrettyModal de Sader. Perfil/Alertas conservan320/260ms y sus fases móviles; Flutter y
MorphPanel de campos no se modifican. No es paridad ni auditoría global.

## Navegación liquid

Cápsula Inicio/Explorar/Mis mascotas: selección azul deslizante320ms y colores
interpolados. Reportar: nueve puntos blancos en círculo negro independiente.
Solo iconos/nombres accesibles; sin tooltip por instrucción posterior. Ancho
máximo304px y opciones52px de alto. Sin impulso al hover; arrastre horizontal
hasta8px con retorno480ms, sin navegar. Barra persistente con espacio de scroll,
insets y sesión/bienvenida confirmadas. Reducido elimina esos efectos.

## Persistencia, permisos y errores

Solo presentación: operaciones, datos, ViewModels, borradores y permisos intactos.
Política global valida acceso; las APIs autorizan cada operación. Ningún dato de
backend ni secreto se añade al cliente. La vista saliente no admite interacción
ni foco y se libera al terminar, fallar o cambiar identidad. Desmontaje libera
callbacks, clases, estilos, referencias geométricas e inercia.

Resize real, altura visual/escala, preferencia e identidad cancelan con limpieza.
Avisos de visualViewport sin cambio real (incluido ancho por scrollbar) no
terminan prematuramente el morph. Movimiento reducido omite expansión/retención.

## Activación y validación

Requiere gsap3.15.0 y build actualizado; sin SQL, variables nuevas, despliegue,
nuevas HU/issues ni cierre de historias.

check-origin-continuity-browser.mjs pausa la timeline GSAP real para capturar
0/2/5/10/15/45/99/100% y cierre: rect inicial igual al control, parámetros
fade/blur copiados, título escalado, destino al viewport completo, ruta anterior
retenida detrás y retirada al terminar, sin salto de título al restaurar layout. Ejecuta además aperturas sin pausar, exige crecimiento y
duración real >=600ms e inyecta un aviso de viewport sin cambio de tamaño.
Tamaño original del icono constante en apertura/cierre, fuente hasta45%, retorno
visible antes de llegar, radio circular y retirada de identidad al completar.
Ambos disparadores,1852/1255/390/320, retorno, reaperturas y movimiento reducido.
Capturas: apps/mobile/build/ui-preview/web-origin-sader.

BROWSER_ORIGIN permite dev5173 con APIs interceptadas hacia fixture; sin sesión
o datos reales. ORIGIN_WIDTHS y ORIGIN_TEXT_SCALE acotan viewport/texto ampliado.
check-navigation-motion-browser.mjs revisa indicador, marca, retorno local/ruta,
borrador cancelado, resize real, reducido e identidad; Perfil/Alertas conservan
su QA aparte. Resultados y límites en ESTADO; aprobación visual del usuario
confirmada para Reportar. Safari/Firefox/físico pendientes.
