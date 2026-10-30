# ADR-066: cronología privada y revisión trazable

Fecha: 18/10/2026. Estado: aceptada para HU-11.1/#38 y HU-11.2/#39; RF-12,14.

## Contexto

HU-10 guarda avistamientos web y Android en `public_sightings`, con evidencia
privada y hora observada distinta de recepción. Faltaba una lectura autorizada
y una revisión que conservase decisiones anteriores. Android es la aplicación
autenticada disponible; el QR web continúa público y no debe exponer estos datos.

## Decisión

Se incorpora `case_timeline` en Flutter, con dominio/casos de uso, contrato de
repositorio, providers declarativos, ViewModels autoDispose, estado, pantallas,
DTO, repositorio y fuente Supabase inyectada por bootstrap. Router compone slots
de acceso en fichas, sin imports de presentation entre funcionalidades. Un caso
cerrado conserva el acceso autorizado de lectura; uno eliminado o una mascota
con eliminación solicitada lo pierde. No se inventan roles de moderación ni
responsables adicionales: responsable significa propietario del caso en el
modelo de permisos actual.

Fuentes088–090/plan026 añaden RPC autenticadas, sin grants directos sobre tablas.
La autoridad se valida dentro de cada operación, también para foto e historial.
La capacidad del botón no sustituye esa comprobación. Se reutilizan el orden de
bloqueos mascota→caso y una fila de avistamiento bloqueada para serializar revisión.
No se modifica025 ni se amplía el DTO público del QR.

La cronología mezcla los eventos existentes de publicación/recuperación con
avistamientos privados web/app, por hora del suceso descendente y clave estable.
Cada avistamiento conserva hora de recepción, marca tardía, presencia de foto y
clasificación como datos distintos. Páginas20, máximo50, cursor por tiempo/clave.
Detalle incluye punto exacto/comentario y carga explícita de la foto saneada
privada (hasta1MiB); la lista no descarga las fotos ni propaga actor_hash,
request_hash o identidad del reportero.

Revisión inicial Sin revisar; permite Útil, Dudoso, Rechazado y Confirmado en
casos abiertos. Se puede pasar de cualquiera de esas cuatro a otra distinta,
con motivo obligatorio de1–500 caracteres. No se permite volver a Sin revisar,
repetir el mismo estado o revisar un caso cerrado. Confirmado evalúa evidencia;
no equivale a recuperación ni a una ubicación actual garantizada.

Cada decisión inserta una fila en `sighting_reviews`: UUID de orden, revisión,
estado anterior/nuevo, motivo, actor Auth y fecha de servidor. No se actualizan
filas anteriores ni la evidencia. Versión esperada y unicidad por avistamiento/
revisión rechazan escrituras simultáneas obsoletas. Repetir la misma orden y
contenido devuelve la decisión original incluso tras revisiones posteriores o
cierre; reutilizar la clave con otro contenido produce conflicto. El servidor
asigna actor y fecha, nunca acepta esos campos del formulario.

Historial de revisiones paginado20 por número de revisión, sin truncar auditoría.
El formulario congela la orden tras respuesta ambigua y permite reintentarla.
Un conflicto exige Actualizar y revisar antes de crear otra orden; conserva
motivo/clasificación. No cambia el estado visible hasta recibir la decisión
guardada. Refresh conserva contenido de la misma cuenta con shimmer; cambio de
cuenta, error de permiso y disposición ocultan datos/descartan respuestas tardías.

## Alternativas y límites

Guardar únicamente el estado actual perdería auditoría. Escribir directamente
desde widgets eludiría dominio, CAS y autorización. Publicar toda la cronología
en el QR expondría punto/evidencia privados sin una necesidad de producto aprobada.
Por ello el incremento entrega lectura/revisión al responsable en Android y
las RPC; no añade panel privado web ni permisos administrativos ficticios.

Los avisos públicos anteriores de `found_cases` conservan su lista y operaciones.
No se convierten automáticamente en los avistamientos privados de HU-10 ni se les
inventa evidencia, estados o fechas. Publicaciones/cierres sin evento histórico
persistido no reciben eventos fabricados. Push/HU-12, offline/HU-15 y moderación/
HU-14 siguen fuera de este incremento. No se afirma concurrencia hosted por
comprobar CAS con dos órdenes secuenciales en PGlite.

## Activación y validación

Aplicar026 sobre025 confirmado por el usuario y actualizar Flutter. No requiere
nueva ruta Nuxt ni publicar la evidencia web. Generadores versionan migración,
patch y run_all. Pruebas SQL cubren roles, dos usuarios, orden/páginas, cuatro
clasificaciones, motivos, reintentos, CAS, cierre, eliminación y repetición.
Pruebas Flutter cubren fallos, sesiones, disposición, fotos, navegación y renders
normal/320×350 texto200%. Evidencia y pendientes reales en [ESTADO](../ESTADO.md).
