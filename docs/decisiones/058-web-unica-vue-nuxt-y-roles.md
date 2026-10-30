# ADR-058 — Web única Vue/Nuxt con módulos y permisos por rol

Fecha:17 de octubre de2026. Aceptada por instrucción explícita del usuario.
Sustituye la implementación DOM/Node manual de ADR-057, conservando sus contratos
SQL, privacidad, rutas QR, feedback y restricciones de caché.

## Decisión

Una aplicación web Vue3 + Nuxt4 + TypeScript para landing, fichas QR y futuros
flujos de usuarios/administración. La separación será por funcionalidades,
layouts y permisos; no se crean proyectos distintos solo por tener roles.
Los roles se validarán por operación en backend/RLS, no solo ocultando rutas.
No se implementan roles, login web ni pantallas vacías en este incremento.
Flutter se conserva en móvil; Supabase mantiene datos/autorización/reglas comunes.

Nuxt permite HTML estático para landing y SSR dinámico para primera lectura de
fichas, con componentes cliente donde se necesite interacción. Vue+Vite es viable,
pero exigiría integrar aparte SSR/transporte del servidor; aquí se adopta Nuxt
por las necesidades del producto, sin atribuirle ventaja de velocidad universal.
La rama de landing contiene trabajo independiente que se conserva sin modificar;
su integración y conversión Vue se hará como incremento posterior.

## Límites

Dominio y contratos/casos de uso TypeScript independientes en shared/features;
repositorios/fuentes servidor solo en server/features; ViewModel puro separado
de componentes Vue. App/plugins compone por petición, sin singleton de identidad.
Pantallas no importan infraestructura; server no importa presentation.
Compartidos reales: marca, botones, toast y skeleton, sin frameworks de UI nuevos.

Se conserva apps/platform y su contexto Docker para no cambiar configuración
del usuario por mover carpetas. Nitro reemplaza el servidor manual. Node24 LTS
para CI/contenedor. Variables Supabase existentes exclusivamente en server,
sin NUXT_PUBLIC ni claves embebidas durante build. SSR serializa solo proyección
pública; CSP permite scripts de hidratación con nonce por respuesta, no unsafe-inline.
Fichas/HTML/payload/API/fotos sin caché, sin analítica ni paths privados visibles.
No se elimina ni reescribe SQL aplicado. No hay nueva migración de datos.

## Verificación y consecuencias

Typecheck, pruebas de entidades/contratos/ViewModel/fronteras, build SSR,
integración del servidor compilado y browser QA en normal/pequeño/texto ampliado.
Resultados y auditoría de dependencias en ESTADO; no confundir evidencia local
con nueva publicación. Dependencias y lockfile requieren mantenimiento.
El visitante conserva /c/<token> y el aspecto aprobado. Las operaciones de QR
siguen sin formulario hasta HU-10.1. Nunca crear un acceso de administración
sin autorización real como parte de una supuesta base preparada.
