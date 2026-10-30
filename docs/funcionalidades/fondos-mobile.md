# Fondo compartido de la aplicación móvil

Corrección19/10/2026: el fondo móvil conserva las luces del tercio superior y atenúa progresivamente el celeste hasta casi blanco junto a la navegación. El velo se pinta dentro de AppPageBackground antes del contenido; conserva movimiento, glass, viewport y accesibilidad. Véase docs/decisiones/102-fondo-mobile-atenuado-hacia-navegacion.md.

Corrección posterior ADR-095: el usuario rechaza el recorte de094. Las tarjetas
recuperan fade/desplazamiento del stagger compartido, sin blur de entrada sobre
glass; backdropBlendMode src compone el material en la capa de opacidad. Una
entrada y superficies/contenido conjuntos conservados. Validación en ESTADO.

Corrección posterior19/10 (ADR-094): Inicio y Explorar tienen una sola entrada
stagger sin cover previo. Glass y contenido aparecen juntos por recorte mediante
preserveBackdrop, sin paneles vacíos ni filtros de entrada sobre el material.
Sustituye la separación superficie/contenido de093, conservando glass final y
reunión. 34 regresiones aprobadas; detalles y límites en ESTADO.

Corrección19/10 (ADR-093): glass principal fuera del efecto de blur/opacidad de
entrada, solo contenido animado; material y geometría estables. Se añade tarjeta
HomeReunionCard con PNG idéntico al original web, imagen3:2 contenida y etiqueta
accesible, entre accesos rápidos y Cerca de ti. Sin interacción ficticia.
Fondo animado conserva su movimiento y reflejos naturales sobre el glass.
Regresión de píxeles/ribete y18 comprobaciones aprobadas; render nuevo y límites
de dispositivo en ESTADO. Requiere reiniciar para registrar el asset nuevo.

Actualización19/10/2026: instrucción visual transversal, sin nueva HU/issue.
[ADR-091 vigente](../decisiones/091-nubes-mobile-animadas-y-tarjeta-glass.md),
que amplía ADR-088 con distribución completa, movimiento y tarjeta glass.

- **Qué hace:** fondo exterior blanco con nubes azules suaves en toda la altura,
  con movimiento continuo de24s; tarjeta principal de Inicio translúcida usando
  GlassSurface compartido. Sin crema ni degradado vertical uniforme.
- **Recorrido:** arranque Flutter, cuenta/acceso/registro/contraseña, bienvenida,
  Inicio, perfil, preferencias, ubicaciones y pantallas basadas en EntityScreenShell
  comparten AppScaffold/AppPageBackground. También cubre estados sin mapa visible.
- **Reglas:** fondo detrás de áreas seguras y contenido; fijo al viewport durante
  scroll y teclado. CoverReveal y expansión desde origen usan la misma paleta.
  Se conservan campos, otras tarjetas, fotos, mapas, paneles y modales. Cabeceras,
  animaciones existentes, insets y movimiento reducido mantienen su comportamiento.
- **Persistencia/permisos:** no añade almacenamiento, configuración o servicios;
  conserva sesiones, ViewModels, casos de uso y permisos.
- **Errores/reintentos:** conserva skeleton/shimmer, toast y acciones reales.
- **Activación/dependencias:** código Flutter compartido; sin paquetes nuevos ni
  configuración remota. Hot reload o nuevo arranque con la compilación actualizada.
- **Movimiento:** respeta accesibilidad y TickerMode; controlador liberado al
  desmontar. Pintura separada del contenido, sin reconstruir formularios/acciones.
- **Límites:** splash nativo conservado. Rendimiento Android físico pendiente;
  renders locales no sustituyen esa revisión.
- **Validación:**30 comprobaciones aprobadas, incluida animación real/pausas/
  liberación y harness visual. Capturas normal/pequeña con texto2 revisadas.
  Las regresiones usan AMBIENT_BACKGROUND_MOTION=false para fijar solo el fondo;
  el test específico fuerza animate:true. Formato/análisis sin incidencias.
