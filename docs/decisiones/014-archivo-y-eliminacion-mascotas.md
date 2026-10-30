# ADR-014: archivo reversible y eliminación definitiva de mascotas

Fecha: 9 de octubre de 2026. Estado: aceptada por instrucción explícita del usuario. Trazabilidad: HU-03 / RF-03; contrato backend e integración Flutter autorizados, sin añadir adopciones ni casos a este sprint.

## Decisión

Archivar es la acción habitual para retirar una mascota del listado activo. Conserva ficha, propietario y fotos; permite restaurar. Eliminar definitivamente se permite únicamente cuando nunca ha tenido casos relacionados. Si existe un caso activo, primero debe resolverse/cancelarse; si existe historial de casos cerrados, solo se permite archivar/restaurar.

El registro de ficha no publica automáticamente un caso. Publicación de perdido utiliza la mascota propia; encontrado puede publicarse sin registro previo. Adopciones permanece después del MVP. Este incremento no implementa ni simula esas operaciones.

## Contrato y seguridad

El parche 008 añade archived_at, case_history_at y active_case_count. RPC archive_pet/restore_pet reciben p_id y p_expected_version; obtienen auth.uid() en servidor, bloquean la fila, validan propietario, estado y versión, y devuelven la fila confirmada. Cambios de archivo incrementan versión; un reintento del mismo estado admite la versión original o confirmada sin escribir de nuevo. No archivar/restaurar una eliminación ya iniciada.

begin_pet_deletion y finish_pet_deletion se evolucionan en una fuente nueva, manteniendo limpieza de Storage antes de retirar metadata y tombstone de 007. Ambas rechazan historial/casos activos, antes de retirar archivos. Un trigger impide borrar mascotas con historial, borrar/cambiar su primer timestamp de caso o introducir historial/archivo durante eliminación. Constraints impiden contador negativo, caso activo sin historial o mascota archivada con caso activo. Clientes no tienen permisos directos de escritura ni reciben una RPC para manipular estos indicadores.

## Integración pendiente de casos

Los casos aún no están implementados. El marcador case_history_at representa historia de casos, no ediciones ordinarias ni fotos de perfil. El módulo S3 debe mantener los indicadores en la misma transacción y bajo el mismo bloqueo de fila al publicar/cerrar/vincular casos. No tomar la decisión en widgets ni permitir que el cliente envíe estos campos. Para publicar, verificar también archived_at/deletion_requested_at y rechazar una mascota archivada o en eliminación. Nunca limpiar case_history_at al cerrar un caso.

Si hubiera tablas de casos externas no versionadas, integrar y rellenar indicadores antes de habilitar borrado; el parche no detecta ni migra esquemas desconocidos. La guardia DELETE también impide cascadas de baja de cuenta que destruirían historia: el incremento de baja debe definir conservación/anónimización y su transición explícita antes de utilizar ese flujo. No resolverlo desactivando el trigger desde el cliente.

## Transición de aplicación

Primero aplicar 007 completo y después 008 completo. Flutter integra archived_at/case_history_at/active_case_count en entidad/DTO, ArchivePet/RestorePet y PetLifecycleViewModel autoDispose por mascota. Mis mascotas permite consultar Activas (archived_at IS NULL) y Archivadas (IS NOT NULL), siempre filtradas por dueño bajo RLS. La ficha permite Archivar con confirmación y Restaurar; conserva edición y galería privada. Errores de archivo/restauración permanecen contextuales y el éxito confirmado usa el toast superior compartido. La eliminación continúa solo por swipe, con guards de dominio y servidor para historia/casos activos; no se amplía la autorización de toast de errores de eliminación a otras operaciones. Los widgets no deciden permisos.

La operación bloquea envíos repetidos, edición y retorno mientras espera. Un keepAlive limitado a la escritura y generaciones de sesión descartan respuestas de cuentas anteriores. Al confirmar se invalidan ambos listados, ficha y editor, conservando las fotos. Guardar metadatos/fotos o eliminar invalida también Archivadas. Errores de versión permiten actualizar ficha/listado y reintentar; un reintento ambiguo conserva ID y versión originales hasta recibir confirmación.

Comprobación remota del 9 de octubre: archive_pet y restore_pet disponibles, HTTP401/42501 para actor anónimo y UUID nulo. No acredita operación autenticada ni todas las políticas; no se desplegó SQL ni se alteraron datos reales.

## Validación

Pruebas SQL con roles propietario/otra cuenta/anónimo, archivo/restauración, versiones/reintentos, fotos conservadas, cierre de caso con historial permanente, bloqueo antes de limpiar archivos, borrado con limpieza y repetición de migración/bootstrap. El fixture marca historia desde servidor sin crear reportes ficticios de producto. SQL local no demuestra despliegue, Storage real ni integración Flutter.
