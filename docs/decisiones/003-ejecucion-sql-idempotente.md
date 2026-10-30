# ADR-003: entrada SQL repetible y convenciones de nombres

Estado: adoptada. Fecha: 7 de octubre de 2026. Complementa ADR-002.

## Contexto

El usuario necesita un archivo `run_all.sql` en la raíz de `database` que pueda ejecutar nuevamente desde Supabase SQL Editor. Las fuentes numeradas y la migración anterior ya están preparadas; también podrían haberse ejecutado manualmente. Reescribir esa migración o mantener otro esquema editable dificultaría conservar su historial.

## Decisión

`database/run_all.sql` es un artefacto generado por `database/scripts/Build-RunAll.ps1` desde las fuentes del incremento actual, después de comprobar que coinciden con la migración inmutable. Contiene SQL autocontenido, sin comandos exclusivos de psql, y conserva los hashes de sus fuentes. No se edita manualmente ni reemplaza el historial de `supabase/migrations`.

La entrada actual abarca los scripts 001–007 de perfiles. Usa una transacción y bloqueo asesor para serializar ejecuciones de esta entrada. Crea la tabla si falta, crea funciones/triggers/políticas ausentes mediante consultas al catálogo, vuelve a aplicar RLS/grants y completa perfiles con `ON CONFLICT DO NOTHING`. No elimina tablas, sustituye funciones/políticas/triggers existentes ni sobrescribe nombres, ciudad o fechas de perfiles existentes.

Antes de modificar objetos, comprueba columnas, tipos, nulabilidad, PK, FK con borrado en cascada y presencia de restricciones validadas de la tabla existente. Una incompatibilidad detiene la transacción. Esta comprobación no es una auditoría completa de deriva: no certifica que el cuerpo de una función, una política o una restricción preexistente coincida con la fuente. Los cambios de esos objetos siguen requiriendo migraciones explícitas y pruebas de permisos.

El generador reconoce el plan actual de forma explícita y rechaza ampliarlo sin revisión. Para un nuevo incremento se añaden fuentes y una migración; se revisa cómo repetir sus operaciones antes de ampliar `run_all`. No se convierten automáticamente operaciones destructivas o `ALTER` arbitrarios en operaciones repetibles. Seeds y pruebas permanecen fuera de esta entrada.

## Convenciones

Los identificadores de PostgreSQL y archivos SQL usan inglés y `snake_case` en minúsculas, sin comillas para conservar mayúsculas: `profiles`, `display_name`, `created_at`, `handle_new_auth_user`. Las tablas representan colecciones y se nombran en plural. Los DTO mapean a `camelCase` en Dart; las clases Dart usan `PascalCase`. Las convenciones concretas se mantienen en [database/README.md](../../database/README.md).

PostgreSQL normaliza a minúsculas los identificadores sin comillas. Adoptar `snake_case` evita que nombres como `displayName` se conviertan en `displayname` o exijan comillas en cada consulta. Es una convención del proyecto, no una obligación del motor. [Identificadores de PostgreSQL](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS).

## Alternativas y consecuencias

- Reescribir la migración inicial como idempotente arriesga modificar SQL que ya se aplicó; se conserva intacta.
- Un `run_all` mantenido manualmente duplicaría fuentes; se genera y se versiona para poder revisarlo y pegarlo en SQL Editor.
- Usar únicamente `IF NOT EXISTS` puede ocultar una tabla incompatible; se añade validación previa. [CREATE TABLE de PostgreSQL](https://www.postgresql.org/docs/current/sql-createtable.html).
- Reemplazar siempre funciones y políticas podría revertir cambios de migraciones posteriores; la entrada solo crea los objetos ausentes. No se utiliza como herramienta de reparación automática de deriva.

## Validación

Pruebas reproducibles en `database/tests/run_all.test.mjs`, con PGlite (PostgreSQL local en memoria) y fixture mínima de `auth.users`, roles y `auth.uid()`: repetición conserva datos/fechas/OID y permisos; compatibilidad con la migración anterior; rechazo de una tabla incompatible sin cambios. Se ejecuta además la prueba SQL entre usuarios. Esta base no incluye GoTrue ni equivale a una verificación del proyecto Supabase remoto. Resultados en [ESTADO.md](../ESTADO.md).

## Ampliación revisada: onboarding (008–009)

El 7 de octubre de 2026 se amplió el generador con el plan 002, conservando la migración inicial. Se revisaron dos operaciones repetibles: añadir la columna de finalización con IF NOT EXISTS, y crear/reemplazar la RPC de finalización propia. Esta RPC específica se vuelve a definir en cada ejecución; las funciones iniciales siguen sin reemplazarse. La validación de tabla acepta las cinco columnas anteriores o las seis actuales, verifica el tipo de la nueva columna y rechaza otras columnas inesperadas. Nuevos incrementos siguen requiriendo revisión explícita.
