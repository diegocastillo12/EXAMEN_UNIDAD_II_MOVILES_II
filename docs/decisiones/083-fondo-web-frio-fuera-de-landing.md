# ADR-083: fondo web frío fuera de la landing

Fecha: 19/10/2026. Estado: aceptada por instrucción del usuario.

## Contexto y decisión

El usuario solicita un fondo blanco/gris frío con azul pastel como la referencia
aportada, sin el matiz amarillo actual, en toda la plataforma excepto la landing.
Conservar las luces difuminadas del componente BackgroundGlowOrb existente.

WebShell declara en `.reader-shell` un único `--page-background`:
`linear-gradient(180deg, #e5efff 0%, #f5f7fa 55%, #ffffff 100%)`.
AmbientPageShell y LegalPage dejan de sobrescribir el fondo. Así acceso,
bienvenida, inicio, moderación, QR y avistamientos comparten la misma base.
Los recorridos con orbe conservan sus colores, intensidades, máscaras,
animaciones y movimiento reducido. No se modifica BackgroundGlowOrb.

## Alternativas y consecuencias

Se descartan fondos por pantalla para evitar divergencias. Cambiar el orbe
global afectaría también la landing, por lo que se modifica únicamente la base
de reader-shell. Landing conserva CSS, crema, superficies y animaciones propios.
El cambio se limita al fondo exterior; tarjetas, campos, fotos y mapas mantienen
sus superficies. Sin cambios de dominio, datos, permisos, rutas o Flutter.

## Validación

Comprobar typecheck, build y pruebas existentes; revisar en navegador los fondos
calculados, orbe conservado, landing independiente y vistas móvil/escritorio.
Los resultados y límites se registran en [ESTADO](../ESTADO.md).
