# Toast web compartido

Actualizado:19/10/2026. Apps/platform, componente TopToast. Mejora transversal
solicitada por el usuario, sin nueva HU/issue ni cierre de historias.

## Qué hace y recorrido

Anuncia errores, validación y resultados de los recorridos que ya usan TopToast
(acceso, cuenta/onboarding, moderación, QR y avistamientos). Baja desde fuera del
viewport y vuelve a salir por arriba. Se puede arrastrar con dedo o ratón para
descartar; un gesto corto/cancelado retorna y uno hacia abajo ofrece resistencia.
También admite toque, teclado y Escape al tener foco dentro del aviso.

## Reglas y campos

API show(text, retry?, error?) y close conservadas. Glass/radio28px, texto14px
peso400, icono32/20px, safe-area+12px, márgenes24px y máximo360px conservados.
Entrada480ms, retorno420ms, salida240ms; sin transiciones con movimiento reducido.
Descarte por40px arriba o gesto rápido desde12px (velocidad media>0.45px/ms).
Temporizador6500ms pausado al sostener y reiniciado al devolver a posición.
Reemplazo y desmontaje liberan timer/captura. Roles alert/status conservados.
Texto extenso permite scroll nativo; en ese caso el icono conserva el arrastre.

## Persistencia, permisos y dependencias

Estado local de presentación, sin persistencia, peticiones ni nuevos permisos.
Vue Transition, Pointer Events y CSSOM; no importa datos ni funcionalidades.
Se activa automáticamente en los consumidores existentes del componente.
[ADR-081](../decisiones/081-toast-web-deslizable.md).

## Errores y reintentos

No cambia mensajes ni validación de negocio. Un arrastre no ejecuta el clic de
cierre ni el callback de Reintentar. Un toque real en Reintentar cierra primero
y ejecuta el callback existente. Avisos posteriores reinician el estado del gesto.

## Validación

typecheck, build aislado de Nuxt y46 pruebas aprobados. check-toast-browser.mjs
comprueba entrada superior, ratón/touch CDP, descarte, retorno corto/hacia abajo,
cancelación, reintento por toque y no por arrastre, teclado/Escape, expiración,
movimiento reducido, anchos1920/1440/731/390/320 y texto200%, sin overflow
horizontal/CSP/hidratación. Capturas en apps/mobile/build/ui-preview/web-toast.
Render320/texto200% revisado. Evidencia local con fixture, sin cambios remotos.
Pendiente comprobar Safari/iPhone físico y sensación del gesto en dispositivo.
