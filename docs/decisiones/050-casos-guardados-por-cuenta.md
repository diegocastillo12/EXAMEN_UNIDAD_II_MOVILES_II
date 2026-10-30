# ADR-050: guardar casos por cuenta desde la ficha

Estado: aceptada por instrucción explícita del usuario, 16 de octubre de 2026.

Ampliación posterior: [ADR-051](051-guardados-en-explorar-y-ciudad-con-sugerencias.md) añade listado paginado en Explorar → Guardados mediante021. Sustituye la limitación de recorrido solo por ficha descrita aquí, conservando marcas/permisos de020.

## Alcance

El usuario solicita favoritos/guardar casos arriba a la derecha de la ficha. Ampliación explícita de HU-07/RF-13, sin issue nuevo asignado. No cierra HU-07.1/#32, seguimiento HU-12 ni consulta offline HU-15.3/#49.

Ficha pública disponible de origen lost/found: marcador glass flotante vacío Guardar caso/lleno Quitar de guardados, simétrico al retorno. Shimmer inicial/escritura, bloqueo de dobles envíos, marca solo tras respuesta del servidor y toast superior. Error de lectura permite reconsultar; escritura incierta conserva operación deseada/versión para reintentar. Recorrido actual desde ficha; no añade listado propio, descargas o suscripciones. Guardar nunca amplía visibilidad del caso.

## Arquitectura

saved_cases/domain: SavedCaseRef (origen + UUID), SavedCaseMark, contrato y ReadSavedCase/SetSavedCase con validación de identidad/UUID/versión. DTO/fuente Supabase/repo y fallos externos en data. Providers declarativos; bootstrap/main inyectan. ViewModel autoDispose por referencia, generación por identidad y operación pendiente; se descartan respuestas obsoletas. Origen significa tabla, no categoría: búsqueda comunitaria usa found.

Router inyecta SaveCaseButton en slots opcionales de las fichas. CaseScreenShell/EntityScreenShell exponen trailingAction sin conocer features. Las presentaciones de perdidos/encontrados no importan saved_cases/presentation. Tocar el marcador no reinicia cover/stagger del contenido.

## Persistencia y permisos

Fuentes070–073/plan020 generan migración20261016002000_saved_cases.sql y patch020. Tabla saved_cases por owner/origen/UUID, saved/versión/fecha; FK elimina marcas con cuenta. Sin fotos, coordenadas o documentos. RLS de propietario y guard restrictiva, lectura por columnas, sin DML directo cliente. RPC read_saved_case/set_saved_case autenticadas, SECURITY DEFINER/search_path vacío y auth.uid explícito, sin propietario recibido del cliente.

Guardar comprueba read_recovery_pet_case/read_recovery_report. Quitar una marca existente permite limpieza aunque el caso haya dejado de ser visible, sin devolver sus datos. Clave compuesta evita colisiones de UUID entre tablas. Bloqueo transaccional por propietario/origen/ID y versión esperada. Repetir la misma elección no modifica versión/fecha; elección opuesta con versión obsoleta produce conflicto. Quitar conserva tombstone privado para impedir restauración por reintento antiguo. Timeout no confirma ni invierte localmente el estado. Conflicto requiere reconsulta; sin reintentos automáticos ni cola offline.

## Activación y validación

Aplicar001–019 y020 en desarrollo; Build-SavedCasesPatch/Build-RunAll generan artefactos, sin editar migraciones anteriores. Activar UI/RPC juntas; sin020 la UI informa fallo y permite reintentar, sin guardado ficticio.

Formato y flutter analyze --no-pub sin incidencias. Generadores verifican migraciones anteriores y producen020/patch/run_all. **Sin pruebas ejecutadas por instrucción del usuario**, incluidas SQL; sin build/renders/despliegue. Pendiente A/B/anónimo, DML/columnas, visibilidad, reintento/CAS/concurrencia, repetición SQL, cambio de identidad, reinicio y Android normal/pequeño/texto ampliado. Generar SQL no acredita políticas ejecutadas. La comprobación arquitectónica existente recorre el módulo nuevo sin excepciones; no se ejecutó.
