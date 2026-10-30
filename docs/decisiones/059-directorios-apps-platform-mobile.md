# ADR-059 — Aplicaciones en apps/platform y apps/mobile

Fecha:17 de octubre de2026. Decisión explícita del usuario: organizar la web
completa en apps/platform y la aplicación Flutter en apps/mobile. Esta instrucción
sustituye la conservación de Flutter en la raíz decidida el6 de octubre.

Se conservan implementaciones, identidad de paquete Flutter, configuración local,
historia Git y separación por funcionalidad. No se recrean proyectos. No se mueven
database/supabase/docs a las aplicaciones. La rama de landing en otro worktree
permanece independiente hasta su integración en la plataforma.

Se realizan dos movimientos con commits separados. Primer commit: plataforma,
workflow y referencias web; Flutter todavía permanece en su ubicación anterior.
Segundo commit: Flutter, rutas de editor/CI/pruebas/docs y normas de ubicación.
El segundo movimiento conserva config local y todos los archivos del proyecto,
incluidos artefactos ignorados; el package name Dart continúa siendo el mismo.
Actualizar Dokploy al nuevo contexto apps/platform y Dockerfile
apps/platform/Dockerfile cuando esta revisión se publique. No se modifica su
panel ni se dispara un despliegue con el movimiento local.

Los enlaces QR /c/<token>, contratos SQL, credenciales y package name Flutter no
cambian. No se genera APK ni se requiere SQL nuevo. Validación pertinente a cada
movimiento y resultados en ESTADO; no acreditar builds nativos no ejecutados.
