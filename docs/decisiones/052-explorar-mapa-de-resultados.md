# ADR-052: mapa de resultados de Explorar

Fecha: 16 de octubre de 2026, America/Lima. Estado: implementado localmente; validación Android/hosted pendiente. Trazabilidad: HU-07.2 / RF-13 / issue #33, dentro de S3. Autorización: continuar la siguiente funcionalidad tras revisar la rama de lista.

## Problema y decisión

El mapa de Ubicación selecciona el centro del filtro; no representa los resultados. Se añade Lista/Mapa mediante TwoOptionFilter compartido, conservando la cabecera y los controles de ubicación/filtros. El cambio discreto de vista usa cover seguido de stagger y respeta movimiento reducido. Cambiar vista no consulta el servidor, no borra páginas ni modifica filtros.

Ambas vistas observan el mismo ExploreState y usan SearchCases y la RPC explore_cases de019. El mapa recibe exactamente los elementos ya consultados; Ver más casos incorpora la página siguiente a ambas vistas. No descargar todas las páginas automáticamente ni afirmar que los puntos representan todos los casos del área. El contador explicita los casos consultados. Mover/ampliar el mapa solo cambia su cámara: una nueva búsqueda se confirma con Ubicación/Filtrar casos.

Los marcadores usan únicamente PublicCaseCard.latitude/longitude, que provienen de la proyección pública aproximada del contrato existente. Coincidencias exactas se agrupan para no ocultar casos de distintos orígenes con el mismo UUID. Tocar un marcador muestra las tarjetas compartidas de esa ubicación; cada tarjeta abre la misma ficha/ruta que la lista. No se consulta posición privada ni se solicita seguimiento continuo. La selección manual existente sigue disponible cuando falla o se deniega GPS.

## Reutilización y fronteras

ExploreViewModel guarda la vista elegida y la conserva durante filtros, refresh, paginación y errores; una identidad nueva comienza en Lista. Presentación agrupa los puntos solo para dibujar y elegir tarjetas, sin reglas de negocio o acceso remoto. El origen forma parte de la identidad del caso.

ZoneMapPicker incorpora marcadores, altura, capa de atribución y navegación de solo lectura opcionales, conservando los valores predeterminados de sus consumidores previos. El mapa de resultados permite pan/zoom sin habilitar selección del centro. Reutiliza ajuste al radio, configuración, fallo de teselas, toast y Reintentar mapa. Al reintentar se restablece la disponibilidad de la cámara antes del nuevo montaje. El controlador y el proveedor conservan su ciclo de vida con flutter_map.

No se crean casos de uso, repositorios o migraciones vacíos: el contrato de consulta ya cubre esta operación. No hay imports entre presentaciones de funcionalidades ni core→features.

## Proveedor y condiciones

Se conserva flutter_map8.3.2 con MAP_TILE_URL y, por defecto, teselas estándar OpenStreetMap. El nuevo mapa incluye atribución visible enlazada a copyright. Se mantiene identificación de app, panBuffer0 y caché predeterminada de NetworkTileProvider; sin descarga masiva, precarga de áreas u offline.

La [política de teselas](https://operations.osmfoundation.org/policies/tiles/) exige atribución, identificación y respeto de caché; el servicio no garantiza disponibilidad. Antes de distribución se debe verificar caché/volumen en dispositivo y condiciones del endpoint elegido; cambiar el proveedor requiere revisar su atribución. Esta entrega no certifica producción ni altera la configuración de mapas anteriores.

## Evidencia y límites

Las regresiones del mapa comprueban la identidad de consulta/páginas al alternar, bloqueo durante peticiones, conservación de vista tras error/reintento/filtros, coincidencias entre orígenes y apertura de ambas tarjetas, coordenadas recibidas y gestos sin editar centro. Capturas390×844 y320×350/texto2/movimiento reducido usan teselas neutras generadas en memoria, sin red; no acreditan cartografía real o rendimiento Android. Resultados finales en ESTADO.

La revisión de CI de esta tarea identifica además tres fixtures desactualizados: ciudad de perfil sin seleccionar, GPS no sustituido en navegación y nombres de fuentes sensibles a mayúsculas en Linux. Se corrigen los fixtures y se resuelven los nombres reales del SDK sin relajar validación de producción. Seguimiento16 de octubre: CI remoto38946521408 de c727b2f aprobado con339 pruebas y recorrido autenticado Android16 mediante attach/hot restart con fotos/teselas reales, filtros y retorno. La generación de APK nuevo falla por conexión local Java/Gradle; evidencia y límites en ESTADO. No se cierran historias.
