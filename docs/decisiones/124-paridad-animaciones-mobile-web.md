# ADR-124: paridad de animaciones entre móvil y web

Estado: aceptada por instrucción explícita del usuario. Fecha:21/10/2026.

## Problema

La cabecera web reproducía avatar/campana y glass de Home móvil, pero Perfil y
Alertas abrían GlassDialog sin animación. La comprobación previa con movimiento
reducido verificaba estructura/función y no detectaba la ausencia del movimiento.
El usuario exige que las animaciones equivalentes de ambas plataformas coincidan.

## Decisión obligatoria

Para un mismo recorrido, móvil y web comparten efecto, control de origen real,
destino, sentido, duraciones, curvas, fases de revelado y retorno. No reemplazar
la expansión por aparición instantánea o fade, ni escoger otros parámetros por
plataforma. Se permite adaptar los límites finales a la composición responsive;
esa adaptación no permite alterar la secuencia del movimiento. Las instrucciones
explícitas posteriores del usuario prevalecen; una divergencia necesita aprobación
explícita y registro, no una excepción técnica implícita.

Movimiento reducido conserva el comportamiento equivalente sin expansión; cambios
de preferencia, resize, desmontaje y cambio de identidad deben dejar foco, scroll,
interacción y semántica operativos. Las pruebas deben observar fotogramas reales
de entrada y salida con movimiento normal, además del resultado final y del modo
reducido. Una captura estática o una prueba únicamente reducida no acredita paridad.

## Corrección de Perfil y Alertas web

La referencia es OriginPageTransition móvil y las rutas profile/entityEditorPage:
entrada320ms, salida260ms, curva easeInOutCubic, fuente desvanecida del0 al45%
y contenido del65 al100% con easeOutCubic. Perfil no fabrica un icono de fuente
(su transición móvil recibe Rect); Alertas conserva la campana decorativa.
La escala del contenido sigue el ancho de la superficie, en ambos sentidos.

GlassDialog recibe el control real y conserva el diálogo/contenido montados hasta
terminar la contracción. origin_motion_contract centraliza tiempos/curvas/fases,
origin_dialog_motion reproduce el progreso Flutter en WAAPI y la transición de
rutas web consume las mismas constantes. No se clonan formularios ni datos de
cuenta para animar; solo el SVG decorativo autorizado de la campana.

Mantiene el panel glass responsive aprobado y las operaciones existentes. El
contenido queda inerte durante la transición; el cierre sigue permitiendo Escape
y, al terminar, devuelve el foco al control original. Resize/preferencia/desmontaje
cancelan y liberan animaciones, estilos temporales, nodos y bloqueo de scroll.
No añade estado de negocio, rutas, SQL ni dependencias entre funcionalidades.

## Alcance y consecuencias

La regla es global y obligatoria al crear/intervenir animaciones equivalentes.
Sustituye el criterio de elegir efectos/tiempos distintos por plataforma. Este
incremento corrige y verifica Perfil/Alertas; no acredita una auditoría global
de todos los efectos existentes ni modifica Flutter para adaptarlo a la omisión web.
Los otros recorridos se contrastan contra su referencia móvil al intervenirlos.

## Validación

Prueba de arquitectura compara parámetros web con las duraciones/rutas Flutter,
curvas y fases de OriginPageTransition. check-dialog-motion-browser.mjs verifica
origen real,320/260ms, fotogramas intermedios y contenido, contracción/foco/marca,
1440/390/320 con texto200%, resize, preferencia reducida en vivo, cierre durante
apertura, recarga/desmontaje y reproducción a tiempo real. Capturas en
apps/mobile/build/ui-preview/web-dialog-motion. Resultados finales en ESTADO;
backend fixture, sin despliegue ni validación física/Safari/Firefox.
