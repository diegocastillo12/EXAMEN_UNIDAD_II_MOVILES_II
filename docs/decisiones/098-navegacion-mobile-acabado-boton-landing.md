# ADR-098: navegación móvil con acabado del botón de landing

Corrección posterior19/10/2026 del usuario: Reportar (nueve puntos) vuelve
a su IconButton circular negro #111111 original, de64px y puntos blancos,
sin degradado, brillo ni sombra azul. El acabado de landing y sus efectos
se conservan únicamente en la selección activa de la barra.
Validación: formato, análisis completo y7 pruebas de Home aprobados.
Pendiente revisión visual Android.

Fecha:19/10/2026. Estado: aceptada por instrucción del usuario.

## Decisión

La opción activa de LiquidNavigation y Reportar adoptan el acabado de
Iniciar sesión de la cabecera de landing: cápsula, degradado vertical
#75BFFF / #459FF6 al48% / #2887EF, brillo superior y sombras azules suaves.
Iconos blancos; hover/foco/pulsación oscurecen3% y elevan2px en200ms.
La pulsación ofrece la interacción equivalente al hover web en móvil.
Movimiento reducido conserva color inmediato sin elevación.

El contenedor glass, iconos, destinos, áreas táctiles52/64 y desplazamiento
de selección320ms permanecen. No se añade login a esta barra.
El acabado se comparte dentro del widget de presentación de home, sin imports
web ni cambios de dominio, datos, permisos o dependencias. Excepción visual
limitada a estos acentos, sin cambiar botones de otros recorridos.

## Validación

Home/arquitectura:16 comprobaciones aprobadas con fondo ambiental detenido.
Capturas390/320px (texto2 en320) revisadas con sombras habilitadas.
Formato y análisis completos sin incidencias. Revisión física Android pendiente;
sin APK, instalación, publicación ni cierre de historias.
