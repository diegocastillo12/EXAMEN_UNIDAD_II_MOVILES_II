# ADR-037: avisos únicamente vinculados desde la ficha

Estado: aceptada por instrucción explícita del usuario. Fecha: 12 de octubre de 2026.

## Problema y decisión

El selector de todos los casos abiertos en Mascota encontrada no escala ni permite reconocer una mascota con claridad. El usuario establece que La vi/La encontré se reporta desde la propia ficha; la navegación Explorar es el destino previsto para consultar casos. Se retira Mascota encontrada de Reportar y se elimina el selector de casos del aviso.

Reportar en Inicio y navegación inferior, y + en Mis reportes, abren directamente el formulario de Mascota perdida (Mi mascota/Otra mascota). Se retira el panel con opciones: ya no hay elección intermedia para una sola tarea. Mis reportes conserva consulta de búsquedas y avisos. El acceso anterior + de Mis reportes comunitarios también abre pérdida, sin crear avisos huérfanos. Se mantienen geometría/origen del control y transición de registro compartidos; selección de origen continúa inmediata según ADR-035.

La ficha de búsqueda abierta conserva La vi o la encontré. Abre el aviso con ID y origen de la búsqueda fijados; no permite cambiar destino ni elegir un catálogo. Una ruta de aviso sin vínculo u origen válido vuelve a Inicio. Enlaces directos válidos también resuelven un caso concreto; no se pretende probar navegación física previa como requisito de autorización.

ReadRecoverySearch consulta únicamente la proyección pública del caso vinculado, verifica ID/estado y que el destino comunitario sea búsqueda (possible_loss). No llama list_open_recovery_searches ni descarga/filtra todos los casos abiertos. El ViewModel conserva el destino y metadatos y la pantalla muestra referencia estática en vez de dropdown. Dominio usa contratos de lost_cases/found_cases; providers declarativos inyectan implementaciones desde bootstrap existente. No hay imports de presentation/data entre funcionalidades.

Servidor018 sigue validando el destino abierto en publicación. Si se cierra, toast superior ofrece Volver a la ficha; se conservan texto/fotos/UUID hasta salida, sin reasignar a otra búsqueda ni reenviar contra una búsqueda cerrada. Salir conserva confirmación/descarte real. La consulta inicial de un destino cerrado muestra toast y retorno, sin simular formulario habilitado. Aviso no confirma recuperación; solo el autor conserva esa acción separada.

## Alcance y validación

Sustituye la elección genérica del aviso de ADR-034 y el panel de creación de ADR-036; no cambia esquema, grants, RPC o Edge. No ejecutar nuevas migraciones;018 sigue siendo requisito del flujo vigente si falta aplicarla. HU-05/RF-05 y HU-06/RF-06, sin historias cerradas.

La sección Explorar continúa como destino previsto; este cambio no implementa la exploración pública/lista/mapa/filtros de HU-07/RF-13, actualmente pendiente. No se afirma que el usuario ya pueda descubrir mil casos desde ella.

Pruebas: apertura desde fichas propia/comunitaria y Reportar directo, vínculo inmutable, lectura de un solo caso frente a catálogo1000+, rechazo por cierre con borrador conservado y bloqueo de reenvío, movimiento reducido y texto ampliado. Evidencia/suite/capturas en ESTADO. Android autenticado/teselas/fotos reales y activación remota pendientes.
