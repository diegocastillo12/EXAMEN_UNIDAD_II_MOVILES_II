# ADR-134: conflictos de publicación sin reintento de PostgREST

Fecha:23/10/2026. Estado: aceptado;037/038 aplicados por el usuario y comprobados
con6/6 pruebas remotas estrictas. HU-15.2 / RF-32 / issue #48.

## Contexto

La validación ampliada contra desarrollo comprueba publicación idempotente y
replay concurrente correctos, pero reenviar el mismo UUID con contenido diferente
termina en timeout30s, en vez de devolver case_conflict. Una llamada HTTP directa
independiente también agota10s. La cola evita esa mutación local mediante huella;
el servidor debe expresar igualmente un rechazo definitivo.

Las RPC usan SQLSTATE40001 para conflictos de negocio. [Supabase documenta](https://supabase.com/kb/troubleshooting/high-cpu-and-infinite-transaction-retries-when-using-custom-error-codes-in-rpc-functions)
un bucle de reintentos al usarlo en PostgREST14 y recomienda PT409 para HTTP409.
El comportamiento remoto observado es compatible con ese fallo; no se ha
inspeccionado la versión privada de PostgREST ni sus procesos/logs SQL.

## Decisión

Plan037/fuente123 sustituye los errcode40001 explícitos por PT409 exclusivamente
en publish_lost_case, prepare_recovery_report y publish_recovery_report, las tres
RPC de comandos de cola. No cambia las reglas del conflicto ni convierte fallos
de serialización genuinos en errores de negocio. Las demás funciones con40001
conservan su contrato y requieren auditoría aparte, sin migración global implícita.

La prueba remota posterior a037 descubre que publish_recovery_report delega la
comparación de rasgos/fotos a publish_found_case. Plan038/fuente124 completa esa
función interna con la misma sustitución y sin ampliar sus permisos de ejecución.
037 aplicado se conserva inmutable. La comprobación de metadatos y repetición
cubre ahora las cuatro funciones; no se extiende a otras RPC de fotos o perfil.

La fuente obtiene pg_get_functiondef por tres firmas exactas y cambia solo esa
asignación de código. CREATE OR REPLACE conserva cuerpo restante, configuración
de lock_timeout/search_path, propietario, security definer y ACL. Una función
ausente o sin contrato reconocido aborta la transacción; repetir el patch ya
actualizado no cambia nada. No se reescriben fuentes/migraciones aplicadas ni
se recrean funciones/tablas. Run_all aplica la corrección al final mediante el
generador existente; el patch037 es el artefacto de actualización incremental.

Los adaptadores Flutter de perdido/encontrado aceptan PT409 y el40001 anterior.
found_target_closed sigue convirtiéndose por su mensaje en rechazo definitivo.
La web ya interpreta HTTP409 como conflicto. No se modifica SQL de fotos,
Edge Functions, RLS, grants, UUID, payload, autorización ni política de reintento.

## Validación y activación

Cuatro pruebas SQL focalizadas pasan: conversión repetible con comparación exacta
de definiciones/propietario/security definer/proconfig/ACL, más perdido, encontrado
y búsquedas. Veinte Flutter focalizadas pasan, incluyendo los dos códigos y cola.
Regresión completa posterior:575/575 Flutter y56/56 SQL locales, análisis limpio;
build normal actualizado compilado e instalado. El primer intento ampliado
terminó5/6 por timeout de perdido; se conserva como evidencia del defecto.

Después de037, búsqueda seguía fallando por el helper omitido (5/6). Con038
confirmado por el usuario, la suite remota estricta aprueba6/6 e incluye campos
y fotos incompatibles de búsqueda, además del conflicto de perdido. Cuatro SQL
focalizadas con037+038 pasan; regresión completa posterior a038 aprobada56/56,
sin omisiones. Validación técnica completada para el entorno documentado en ESTADO.

La aplicación de los patches exige un rol administrativo en desarrollo;
las cuentas autenticadas no pueden ejecutar DDL. Si quedan procesos antiguos en
bucle, inspeccionarlos y cancelarlos de forma acotada según diagnóstico del servidor:
cambiar funciones no acredita que hayan terminado. No se ejecuta cancelación
amplia, reinicio o despliegue sin autorización ni se cierra la historia mientras
falle la comprobación remota de conflicto.
