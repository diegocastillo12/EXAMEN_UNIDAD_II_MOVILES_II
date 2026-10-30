# Fondos compartidos de la plataforma web

Fecha: 19/10/2026. Incremento visual transversal; sin nueva HU/issue ni cierre.

- Qué hace: fondo exterior azul pastel → gris frío → blanco, sin crema, en
  acceso, bienvenida, inicio, moderación, legales, QR y avistamientos.
- Recorrido/reglas: WebShell declara `--page-background` en reader-shell;
  AmbientPageShell y legales heredan la base. Landing mantiene su fondo propio.
  Las superficies interiores conservan su color; no se modifican fotos o mapas.
- Orbe: se conserva BackgroundGlowOrb donde ya se usa, con colores, intensidad,
  movimiento, máscaras y accesibilidad existentes.
- Persistencia/permisos: no hay datos ni configuración nueva; permisos intactos.
- Errores/reintentos: sin operaciones nuevas ni cambios de feedback.
- Dependencias/activación: CSS compartido y compilación habitual de Nuxt;
  sin variables, SQL, Flutter o activación remota.
- Validación: resultados locales y siguiente paso en [ESTADO](../ESTADO.md);
  la implementación local no acredita publicación ni aprobación visual del usuario.

[ADR-083](../decisiones/083-fondo-web-frio-fuera-de-landing.md).
