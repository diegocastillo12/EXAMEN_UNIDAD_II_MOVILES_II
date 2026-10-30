# ADR-002: organización de las fuentes SQL

Estado: adoptada. Fecha: 7 de octubre de 2026.

## Contexto

Las tablas, funciones, políticas y restricciones de Entre Huellas deben mantenerse en el repositorio. Se requiere localizarlas por tipo de objeto y conservar un orden explícito de ejecución. La documentación anterior reservaba todo el SQL para migraciones en `supabase/migrations`.

## Decisión

Las fuentes SQL se organizan en `database`, con directorios para extensiones, tipos, tablas, índices, funciones, triggers, vistas, políticas y grants. Sus nombres utilizan una secuencia global `001_descripcion.sql`, `002_descripcion.sql` y así sucesivamente. Los seeds y las pruebas se mantienen separados del esquema y tienen numeración propia.

Cada incremento reúne sus fuentes en orden numérico para generar una migración con el formato de Supabase en `supabase/migrations`. Las fuentes son el lugar de edición; el archivo de migración conserva el paquete exacto que se aplica. `database/scripts/Build-Migration.ps1` genera desde planes versionados en `database/migration_plans`, con referencias y hashes SHA256 de las fuentes normalizadas. Valida numeración global y rechaza sobrescribir una migración diferente. Su primera ejecución remota debe validarse en desarrollo. No se mantendrán copias editables independientes.

Después de aplicar un incremento, sus fuentes y su migración quedan inmutables. Las modificaciones se realizan mediante nuevos scripts y una nueva migración. Las Edge Functions permanecen en `supabase/functions`; `database/functions` contiene funciones SQL.

## Motivos y consecuencias

- La separación por objeto facilita localizar tablas, RPC y políticas durante implementación y revisión.
- Una secuencia global expresa dependencias que cruzan carpetas y evita que dos archivos `001_...` del esquema tengan un orden ambiguo.
- El historial de migraciones permite aplicar y verificar incrementos; la existencia de carpetas ordenadas no sustituye ese historial.
- Los grants y políticas se revisan con los objetos que protegen. La organización por carpetas no permite desplegar una tabla expuesta como un incremento independiente sin sus permisos.
- La generación añade un paso que debe ser reproducible y validarse antes de usarlo. En esta preparación se crean carpetas y convenciones, sin ejecutar SQL ni modificar Supabase.

La convención y los ejemplos están en [database/README.md](../../database/README.md). Esta decisión amplía la organización del SQL y mantiene las fronteras cliente/backend de [ADR-001](001-arquitectura-aplicacion.md).

La entrada manual repetible `database/run_all.sql` complementa esta decisión sin reemplazar el historial de migraciones. Su generación, compatibilidad y convenciones se registran en [ADR-003](003-ejecucion-sql-idempotente.md).
