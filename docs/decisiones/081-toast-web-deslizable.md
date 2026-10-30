# ADR-081: toast web con entrada superior y descarte por gesto

Fecha: 19/10/2026, America/Lima. Estado: aceptada por instrucción del usuario.

## Contexto y decisión

El usuario solicita en platform el comportamiento de las notificaciones de
iPhone: entrada de arriba hacia abajo y posibilidad de tomar el aviso y
devolverlo hacia arriba. Sustituye únicamente el movimiento de entrada de180ms
documentado previamente; mantiene la superficie y las acciones de TopToast.

TopToast compartido usa Transition: entra desde fuera del viewport en480ms,
con desaceleración, y sale hacia arriba en240ms. Sigue directamente el dedo o
ratón; al soltar, descarta desde40px de recorrido ascendente, o desde12px con
velocidad media superior a0.45px/ms. Un gesto corto/cancelado vuelve a posición
en420ms. Hacia abajo ofrece resistencia hasta18px y no descarta.

No ejecutar cierre por toque ni Reintentar como consecuencia del clic generado
al terminar un arrastre. Mantener cierre por toque, Enter/Espacio y Escape con
foco en el aviso, roles alert/status y callback de reintento. La expiración de
6500ms se pausa mientras se sostiene y se reinicia al soltar sin descartar.
Cancelar captura y timer al reemplazar/cerrar/desmontar el aviso.

Movimiento reducido elimina las transiciones, conserva el gesto y las acciones.
Mensajes con overflow permiten scroll táctil nativo; el icono sigue permitiendo
arrastrar en ese caso. Aplicar estilos variables mediante CSSOM compatible con
CSP. Toda la lógica es presentación compartida, sin cambios de dominio, datos,
API show/close, Flutter, permisos ni alcance de historias.

## Validación y límites

typecheck, build con NUXT_BUILD_DIR=.nuxt-toast y46 pruebas aprobados. QA Chrome
de producción con fixture: entrada desde fuera del viewport, arrastre real con
ratón y eventos táctiles CDP, retorno corto/hacia abajo/cancelado, gesto sobre
Reintentar sin callback, reintento por toque, teclado, Escape, expiración y
movimiento reducido. Capturas1920/1440/731/390/320, texto200%, sin overflow
horizontal ni errores CSP/hidratación. No acredita Safari/iPhone físico.

Ficha: [Toast web compartido](../funcionalidades/toast-web.md).
