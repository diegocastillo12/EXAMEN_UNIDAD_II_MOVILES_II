# ADR-091: nubes móviles animadas y tarjeta principal glass

Fecha:19/10/2026, America/Lima. Estado: implementado localmente por instrucción explícita del usuario.

El usuario solicita que la tarjeta «Su regreso empieza contigo» tenga acabado
glass como la referencia aportada, y que las nubes difuminadas se distribuyan
por todo el largo del fondo y se muevan. Sustituye el carácter estático y la
concentración superior de ADR-088; la web y las demás superficies no cambian.

HomeContent reutiliza GlassSurface con radio26, mismo padding22, contenido,
tipografía y acción reales. Se elimina solo el relleno gris opaco de la tarjeta:
blur22, transparencia, ribete y sombra proceden del material compartido existente.
No se crea un material paralelo ni se altera el glass de navegación/fichas.

AppPageBackground usa cinco nubes radiales a distintas alturas sobre blanco.
AnimationController de24s mueve sus elipses con trayectorias sinusoidales cerradas,
desplazamiento máximo13% del ancho y5.5% del alto. La pintura escucha directamente
el controlador y está aislada por RepaintBoundary; no reconstruye el contenido.
El fondo conserva coordenadas del viewport, fuera del scroll/teclado/insets.
TickerMode pausa las rutas ocultas y movimiento reducido detiene el controlador;
al desmontarse se libera. No añade imágenes, paquetes o filtros de blur al fondo.
El blur existente se limita a la tarjeta glass. No se reinician stagger o formularios.

Las regresiones/capturas fijan la fase con el define público opcional
AMBIENT_BACKGROUND_MOTION=false: permite esperar las animaciones de contenido
sin esperar una animación ambiental infinita. La app conserva true por defecto.
README y comando CI actualizados; no se ha ejecutado GitHub Actions. El test
específico fuerza animate:true incluso bajo ese define y comprueba cambio real
de píxeles, ausencia de rebuild de contenido, pausa/reanudación por accesibilidad
y TickerMode, y liberación al desmontar.

Solo presentación: sin dominio/data, SQL, permisos, operaciones, HU/RF/issue nuevos
o cierre de historias. Validación local y límites Android en ESTADO y ficha.
