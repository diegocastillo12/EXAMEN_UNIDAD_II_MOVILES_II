# ADR-026: listas de casos con los componentes de mascotas

Fecha: 10 de octubre de 2026. Estado: aceptada por instrucción del usuario. Trazabilidad: HU-05/RF-05 y HU-06/RF-06; incremento de gestión por el dueño solicitado sobre los flujos existentes, sin declarar historias cerradas.

## Motivo y decisión

El usuario muestra la diferencia entre las filas ListTile de Mis casos y las tarjetas aprobadas de Mis mascotas. Exige conservar la UI/UX y permitir eliminar casos abiertos o resueltos. Se extraen a core los componentes reales existentes: EntityCardContent, EntityCardSurface, SwipeActionCard, TwoOptionFilter, CollectionHeader y CollectionAddButton. Los widgets de mascotas delegan en ellos; los casos usan la misma implementación, sin importar presentación de otra funcionalidad ni copiar geometría/efectos.

Mis casos/Mis reportes muestran Abiertos/Resueltos, tarjetas con foto pública disponible y título/estado reales, y botón+ de56 junto al título. Textos ampliados apilan el selector y las acciones como en mascotas. Deslizar hacia la izquierda devuelve la tarjeta a su lugar y abre confirmActionDialog desde su origen; Cancelar conserva el registro. Confirmar llama al ViewModel, caso de uso, repositorio y fuente; shimmer conserva la tarjeta mientras trabaja y bloquea otras operaciones. Solo un éxito confirmado retira la tarjeta y muestra toast. Error conserva el caso y permite repetir. Refresh conserva datos/selección; cambio de identidad oculta datos e ignora resultados anteriores. Cabecera permanece fuera del reveal. Los borradores encontrados mantienen Descartar/limpieza, con la superficie compartida y sin enlace público falso.

## Persistencia y permisos

Fuentes057–060 y migración016 incorporan consultas de tarjetas del dueño y delete_lost_case/delete_found_case. El servidor valida auth.uid/propiedad, bloquea filas y admite eliminación de active/resolved; borradores encontrados usan su descarte anterior. Eliminación lógica conserva identificador de publicación y auditoría, evitando resucitar publicaciones mediante un reintento viejo. deleted_at retira listado/acceso público; el estado interno pasa a resolved para que dejen de cumplirse las proyecciones activas existentes. Esto no presenta el caso eliminado como un caso resuelto en la lista.

Eliminar perdido activo decrementa active_case_count una sola vez, conserva case_history_at y versiones, y usa orden de bloqueo mascota→caso como publicar, con espera5s. No elimina la mascota ni sus fotos. Los derivados de encontrados permanecen privados como historial; no se implementa purga física de archivos en esta operación. Las consultas del dueño pueden abrir casos resueltos no eliminados; terceros solo consultan activos. No se exponen punto exacto/referencia. URLs firmadas previamente emitidas conservan su vigencia existente de300s; no se promete revocación instantánea del archivo descargado. Clientes no pueden escribir deleted_at ni invocar las operaciones como anon. El cliente acota solicitudes de eliminación a15s y reintenta el mismo ID ante respuesta ambigua.

## Validación y activación

Evidencia local: pruebas Flutter de listas/gestos/confirmaciones, casos de uso/identidad, SDK, mascotas/Inicio/reveal/arquitectura; SQL PostgreSQL en memoria de permisos, conservación, repetición y nueva publicación tras eliminación. Capturas390×844/320×350 texto2. Detalle en ESTADO. La activación requiere migración016 sobre013/014/015 y recargar/instalar la app; no se aplicó al servidor ni se acredita una prueba Android autenticada. Incidente previo de publicación separado.
