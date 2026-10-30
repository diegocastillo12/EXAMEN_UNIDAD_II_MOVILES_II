# ADR-094: entrada única de Inicio y Explorar móvil

El recorte progresivo se sustituye por fade/desplazamiento en ADR-095 tras
rechazo visual del usuario. Se conserva una entrada sin cover en ambas secciones.

Fecha:19/10/2026, America/Lima. Estado: implementado localmente por corrección del usuario.

El usuario reporta doble entrada en Inicio/Explorar y aporta capturas de tarjetas
glass vacías y cobertura sin contenido. Había cover320ms previo al stagger850ms;
además ADR-093 dejaba el glass visible mientras su contenido esperaba el timeline.

Se retira AuthStageTransition/cover únicamente de estas dos secciones. Inicio
usa su stagger existente de cuatro grupos; para secciones reales de Explorar y
Mascotas el timeline exterior continúa desactivado y la funcionalidad mantiene
la entrada propia. Explorar tiene solo su stagger de un grupo, sin reinicio por
resolución del skeleton/consulta/error. No cambia otras entradas Flutter.

StaggerRevealItem añade preserveBackdrop para tarjetas con BackdropFilter: usa
el mismo timeline/curva/intervalo mediante ClipRect, revelando superficie y
contenido juntos, sin Opacity/ImageFiltered ni traducción sobre el material.
Un margen40px conserva las sombras blur24/offset8. No cambia layout ni geometría.
Inicio aplica esta variante a tarjeta principal y reunión. Conserva glass final
de ADR-093 y evita paneles vacíos al principio; sustituye su decisión de animar
solo contenido. Otros elementos conservan blur/fade/desplazamiento existentes.
Movimiento reducido muestra todo directamente. Cabecera/navegación persistentes.

Solo presentación, sin ViewModels, consultas, SQL, permisos, HU/RF/issue nuevos o
cierre de historias. Regresiones:34 pruebas aprobadas de glass/Inicio/Explorar/
stagger/arquitectura. Comparación de píxeles comprueba glass ausente inicialmente,
ribete ya revelado idéntico al final y acción original; Explorar recorre90 frames
con una entrada, cero covers, una consulta y misma instancia de skeleton.
Validación final y límites Android en ESTADO.
