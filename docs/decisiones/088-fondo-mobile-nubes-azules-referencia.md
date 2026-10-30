# ADR-088: fondo móvil de nubes azules según referencia

La distribución estática y superior se sustituye por ADR-091: movimiento continuo,
nubes en toda la altura y tarjeta principal con GlassSurface compartido.

Fecha:19/10/2026, America/Lima. Estado: implementado localmente por corrección explícita del usuario.

El usuario rechaza el degradado vertical móvil de ADR-086 y aporta una referencia
de dos pantallas de envíos. Se adopta únicamente su fondo: blanco con nubes de
azul pastel difuminadas en la parte superior, aperturas blancas y reflejo frío
tenue inferior izquierdo. No se trasladan tarjetas, textos, navegación o funciones
de logística. La corrección sustituye la equivalencia con el fondo web interior;
la web mantiene ADR-083 y la landing su regla propia.

AppPageBackground conserva su contrato y pinta la base blanca más elipses
radiales superpuestas, en proporciones del viewport, mediante CustomPainter.
Azules BAD5FA/B1CFF7 y reflejo CDDDF0 con transparencia; sin líneas de corte,
imagen bitmap, dependencia, animación o filtro de desenfoque por frame.
AppScaffold mantiene el fondo fuera del ajuste de teclado, scroll y áreas seguras.
CoverReveal reutiliza el mismo fondo. OriginPageTransition desvanece el fondo
desde la superficie de origen con el progreso existente; se mantienen clip,
duraciones, interacción y movimiento reducido.

Alcance de pantallas de ADR-086 conservado: arranque Flutter, acceso/cuenta,
onboarding, Inicio, perfil, preferencias, ubicaciones y EntityScreenShell.
Fotos, mapas, tarjetas, campos, paneles y splash nativo conservados. Sin cambios
de dominio/data/SQL/permisos, sin nuevas HU/RF ni cierre de historias.

Validación:22 comprobaciones existentes de arranque, reveal, arquitectura y harness
visual aprobadas. Capturas de acceso, onboarding, Inicio y perfil revisadas en
390×844 y320×350/texto2. Formato/análisis y límites finales en ESTADO. Renders
locales no equivalen a aprobación visual del usuario ni revisión Android físico.
