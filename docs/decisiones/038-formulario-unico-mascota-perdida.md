# ADR-038: un solo formulario de Mascota perdida

Estado: aceptada por el usuario. Fecha: 12 de octubre de 2026, America/Lima.

## Problema y decisión

Mi mascota/Otra mascota parecía dividir el reporte en dos secciones, aunque fecha, hora y lugar expresan el mismo suceso. El usuario acepta sustituir las pestañas por una elección dentro de un único formulario.

Mascota a reportar ofrece las fichas de Mis mascotas y No está en mis mascotas. Una ficha existente aporta un resumen de los datos disponibles y permite seleccionar sus fotos públicas; la otra opción pide descripción y fotos sin registrar la mascota como propia. El panel de opciones usa el título corto Mascota para conservar espacio con texto ampliado.

Fecha, hora, mapa, referencia privada y Revisar publicación se renderizan una sola vez con CaseReportFields. Cambiar de origen conserva este bloque, incluidas selecciones parciales de fecha/hora y coordenadas exactas privadas. Detalles y fotos de cada origen permanecen separados; no se copian a la otra mascota. Seleccionar una ficha distinta vuelve a consultar sus propias fotos. Vista previa, publicación y confirmación conservan las operaciones existentes.

## Fronteras y ciclo de vida

LostReportScreen compone ambos editores en app, como ADR-035. Cada funcionalidad expone su estado y acciones mediante su ViewModel; restoreReportDetails reemplaza únicamente el bloque del reporte y comprueba identidad/bloqueos. No hay imports de presentation/data entre funcionalidades ni core hacia features. CaseReportFields recibe datos y callbacks sin conocer repositorios o contratos de mascota.

Conservación local durante la visita, sin borrador offline nuevo. No se permite cambiar selección durante fotos, envío o respuesta ambigua. Salir comprueba ambos borradores y conserva limpieza autorizada y errores mediante toast. Cambiar cuenta oculta datos anteriores; no se transfieren datos entre identidades. No se añade SQL ni cambia clasificación/permisos de publicaciones.

Sustituye la interfaz de pestañas y la separación de datos del suceso de ADR-035; mantiene UUID, privacidad, descarte y entrada sin recarga ni animación al seleccionar. No cambia las reglas de arquitectura del proyecto.

## Validación y límites

Pruebas de selección comprueban un solo bloque de fecha/mapa, ausencia de pestañas/skeleton al alternar, ruta/selector estables, conservación de fecha parcial/punto/referencia/UUID y descripción por origen, sin nueva consulta de catálogo. Recorrido sin mascotas registradas comprueba publicación, aviso vinculado y recuperación explícita. Revisados tamaños 390×844 y 320×350 con texto2/movimiento reducido; capturas en build/ui-preview/unified-report. Suite, formato y análisis en ESTADO.

HU-05/RF-05 y búsqueda comunitaria de HU-06/RF-06. Implementación local, sin historia cerrada, commit/push, APK o despliegue. Pendiente Android autenticado con fotos/teselas reales y backend018 activo.
