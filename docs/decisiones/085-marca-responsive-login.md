# ADR-085: marca grande en el login responsive

Fecha: 19/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Contexto y decisión

El usuario aporta dos capturas y elige para el login móvil la composición con
logo grande, «entre huellas» en dos líneas y título próximo a la marca.
Esta petición sustituye localmente ADR-076/077 en login hasta600px.

Se reutilizan SiteHeader/SiteBrand con la clase login-header existente.
site-brand.css concentra la excepción: padding superior52px y lateral24px,
logo76px, gap16px, texto2rem/interlineado.95 y ancho min-content para partir entre palabras.
El contenido empieza32px después de la cabecera, sin centrado vertical automático.
La marca permanece fuera del formulario, skeleton y stagger; su geometría se
define en CSS desde SSR, sin lógica de montaje o detección de viewport por JS.

## Alternativas y consecuencias

No se duplica la marca ni se añade un segundo logo al formulario. La excepción
se acota a login y <=600px; escritorio, landing y demás recorridos conservan
sus reglas compartidas. Fondo y orbe conservan los valores aprobados.
Sin cambios de cuenta, persistencia, permisos, rutas o Flutter.

## Validación

Comprobar móvil, ancho estrecho, límite600/601px, escritorio, texto ampliado,
SSR/hidratación/recarga y movimiento reducido. Resultados en ESTADO.
