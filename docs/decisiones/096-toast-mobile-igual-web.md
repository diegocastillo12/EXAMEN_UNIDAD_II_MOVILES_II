# ADR-096: toast móvil con el mismo acabado y gesto que la web

Fecha: 19/10/2026, America/Lima. Estado: aceptada por petición del usuario.

## Contexto y decisión

El usuario solicita trasladar a móvil el toast aprobado en platform (ADR-081),
incluidos aspecto, entrada desde arriba y descarte al deslizar hacia arriba.
Se modifica ConfirmationToastHost compartido, sin variantes por funcionalidad.

Conservar glass #F5F5F7 al90%, borde blanco70%, blur18, radio28, sombra existente,
icono32/20, ancho natural máximo360 y márgenes24/safe-area+12. Texto14/peso400,
interlineado1.4, mensaje mínimo32 y acción subrayada mínima44 alineada a la
izquierda. Se mantiene la familia tipográfica móvil; no se añade otra fuente.

Entrada desde fuera de la pantalla en480ms, salida superior en240ms y retorno
en420ms, con las curvas de web. Seguir directamente el gesto táctil/ratón.
Descartar desde40px hacia arriba o desde12px con velocidad media>0.45px/ms.
Gesto corto/cancelado vuelve a posición; hacia abajo, resistencia hasta18px.
El área de texto conserva scroll si desborda; el icono sigue admitiendo el gesto.
No ejecutar acciones por el arrastre. Mantener cierre por toque/teclado,
Escape con foco y acción semántica de descarte. Sin transiciones con movimiento
reducido, conservando interacción y anuncios liveRegion.

Duración6500ms, pausada mientras se sostiene y reiniciada al soltar sin cierre.
La acción cierra y ejecuta su callback una vez tras la salida. Reemplazar un
aviso o desmontar su pantalla elimina overlay, timer y animaciones; los eventos
restantes de un dedo sobre el aviso retirado no reactivan timers ni callbacks.
Mantener exclusión de avisos anidados y API pública del host.

## Consecuencias

La presentación administra gesto, temporizador y salida; no se añaden casos de
uso ni cambian ViewModels, persistencia, permisos o backend. Se sustituyen la
entrada180ms, el peso600 y la expiración3/6s móviles previos. Las pruebas que
esperaban expiración o controles detrás del toast se adaptan a6500ms/cierre
explícito. Sin cambios web, nuevas HU/issues ni cierre de historias.

## Validación

16 pruebas de toast: entrada/salida, texto regular, arrastre por superficie e
icono, flick, retorno/cancelación, scroll/texto2, pausa/expiración, reintento sin
activación por gesto, teclado/Escape, reemplazo sostenido y disposición. Suite
específica con arquitectura/preferencias/avatar y harness visual:33 aprobadas.
Otros54 casos aprobados: perdidos/encontrados, validación/salida del editor de
mascotas, carteles y Explorar. Fondo ambiental estático mediante el define
existente AMBIENT_BACKGROUND_MOTION=false; el movimiento del toast sigue activo.

Capturas en apps/mobile/build/ui-preview/mobile-toast, con fuente real,
390×844 y320×350/texto200%. Suite general no completada: timeouts del fondo
continuo y límite de hilos/memoria; en el intento con fondo estático se observaron
también fallos de origin_page_transition_test ajenos al componente. No se declara
la suite completa aprobada. Pendiente revisión táctil en Android/iPhone físico;
sin nuevo APK, instalación o despliegue. Formato, flutter analyze y
git diff --check finales aprobados.

[Ficha](../funcionalidades/toast-mobile.md).
