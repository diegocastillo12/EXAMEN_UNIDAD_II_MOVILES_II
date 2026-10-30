# ADR-120: restaurar el título original de la landing

Fecha:20/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Decisión

El usuario solicita recuperar la primera captura aportada: «Más huellas juntas.
Más caminos de vuelta a casa.» con su escala original. Excepción local a ADR-111
solo para `#hero-title`: Arial/Helvetica/sans-serif, peso500, color #171918,
line-height1.02, tracking−0.055em y tamaño clamp(42px,7vw,108px); en móvil
clamp(32px,8.5vw,48px). Recuperar mascotas laterales de62–148px y offsets previos;
los ajustes móviles de36/35px permanecen como en la implementación original.

Los valores se recuperan del padre del commit1fc1bd1, que había sustituido esta
composición al unificar títulos. No es una exigencia de SEO. El resto de h1
conserva Poppins400/32/gris, excluyendo explícitamente este ID del selector global.
Se mantienen semántica h1 única, metadatos SEO, WebP, SSR, animaciones y controles.

## Validación

Build, comprobación arquitectónica y QA de landing en navegador con escritorio,
móvil, texto200 % y sin JS; resultados y pendientes en ESTADO. No modifica datos,
permisos ni despliega. La revisión del usuario de las capturas sigue pendiente.
