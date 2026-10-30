# ADR-025: viewport continuo detrás del área del gesto

Fecha: 10 de octubre de 2026. Estado: aceptada por instrucción del usuario al señalar la franja inferior que corta el contenido. Alcance: presentación transversal de páginas con scroll.

## Problema y decisión

Los layouts de reportes, mascotas, perfil, zonas, preferencias, Inicio y acceso envolvían el viewport en SafeArea con bottom activo. El inset inferior quedaba fuera del scroll: Scaffold lo pintaba de blanco y el contenido se cortaba en una línea fija antes del indicador de navegación. La vista previa fotográfica heredaba el mismo recorte.

ScrollSafeArea compartido mantiene las protecciones superior/lateral necesarias y deja el viewport llegar abajo. La seguridad inferior se aplica al padding final del scroll y a la posición de acciones flotantes, nunca mediante una franja opaca fija. Inicio conserva la posición segura de su navegación; acceso conserva el anclaje original descontando el inset del cálculo, y el panel inmersivo mantiene su padding seguro sobre la foto extendida. Con teclado, MediaQuery.padding efectivo evita doble reserva.

AnnotatedRegion solicita navegación transparente, divisor transparente y contraste opaco desactivado. Formularios usan iconos oscuros; preview fotográfico usa claros sobre la imagen sombreada. No se altera bootstrap, SDK, navegación autorizada ni negocio. Modales, splash y onboarding conservan sus geometrías específicas; no sustituir indiscriminadamente todos los SafeArea.

## Validación y límites

Pruebas locales verifican el borde real del viewport, píxeles de contenido en la zona anteriormente excluida y última acción alcanzable con inset34 y teclado en reportes/mascotas/acceso. Renders del preview incluyen insets24/34 en390×844 y320×350 texto2, con movimiento reducido. Los tests Flutter no dibujan la barra nativa del SO: su transparencia/iconos deben confirmarse en Android/iOS reales. Resultados completos y relevo en ESTADO.
