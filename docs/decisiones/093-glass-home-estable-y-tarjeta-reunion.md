# ADR-093: glass estable en Inicio y tarjeta de reunión

Corrección posterior: ADR-094 sustituye la entrada de solo contenido por recorte
de superficie/contenido juntos y retira cover en Inicio/Explorar. Conserva el
acabado final e imagen; evita mostrar paneles vacíos antes del stagger.

Fecha:19/10/2026, America/Lima. Estado: implementado localmente por petición del usuario.

El usuario detecta que la tarjeta principal cambia de acabado al entrar y pide
conservar su aspecto final. StaggerRevealItem envolvía GlassSurface: el filtro
ImageFiltered/Opacity de entrada componía también el BackdropFilter y ribete del
material en una capa temporal. La tarjeta principal ahora coloca GlassSurface
fuera del stagger; solo su contenido participa en el timeline existente.
Se conservan radio26, dimensiones/padding, material compartido y acción real.
No se modifica GlassSurface global ni se desactiva la entrada de toda la pantalla.
Las nubes siguen animadas: el color reflejado puede variar con el fondo, pero
no se aplica blur/opacidad de entrada al material ni se modifica su geometría.

Por petición explícita se añade HomeReunionCard entre los accesos rápidos y
«Cerca de ti»: usa reunion.png de apps/platform/public/images/landing, copiado
sin alterar a assets/illustrations de móvil y verificado por SHA256. Imagen
contenida a3:2, sin recorte, sobre GlassSurface26 con padding12. Es ilustración
con etiqueta accesible, sin botón/acción ficticia ni datos simulados. Su superficie
también queda fuera del stagger; el contenido toma order2 y Cerca de ti order3.
Inicio tiene cuatro grupos, con mismos tiempos y movimiento reducido.

Solo presentación/asset; sin imports de presentación web, dependencia runtime,
operaciones, SQL, permisos, HU/RF/issue nuevos o cierre de historias.

Regresión visual compara píxeles de ribete y rectángulo de la tarjeta durante
la entrada y tras completarla con fondo fijo, comprueba imagen y acción originales.
Harness añade captura home_reunion; render normal/pequeño y análisis en ESTADO.
Pruebas con fase ambiental fija no certifican fluidez Android real.
