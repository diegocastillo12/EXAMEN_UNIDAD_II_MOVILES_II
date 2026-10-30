# ADR-036: Reportar compacto y consulta unificada de Mis reportes

Estado: aceptada por corrección de UI/UX del usuario. Fecha: 12 de octubre de 2026.

## Problema y decisión

El panel Reportar mezclaba dos acciones de creación con enlaces a dos listados y una acción Cerrar redundante para este recorrido. El usuario solicita minimalismo, elimina Cerrar y pide reformular el acceso a los reportes. Se separan las tareas: panel con dos opciones y consulta en un único destino Mis reportes accesible desde Inicio.

Reportar conserva el indicador de arrastre y contiene Mascota perdida/Mascota encontrada como filas de selección con icono, nombre, explicación breve y chevrón, superficie neutra compartida. Se retiran el párrafo largo inicial, enlaces intercalados y Cerrar. Cierre disponible mediante gesto, barrera exterior y Atrás del sistema, sin otra acción visible añadida. El modal permite scroll, insets y texto ampliado. Dos opciones tienen igual jerarquía, sin simular una acción principal diferente.

CollectionAddButton admite descripción de opción y acción local además de ruta: mantiene geometría/origen y transición de registro aprobados, sin cambiar la apariencia de Mascotas o botones existentes. La referencia del botón real sigue alimentando entityEditorPage. Movimiento reducido conserva su tratamiento anterior; seleccionar Mi mascota/Otra mascota sigue siendo inmediato según ADR-035.

Inicio ofrece Reportar, Mis reportes y Mis mascotas como accesos reales. Mis reportes combina búsquedas de mascotas propias, búsquedas comunitarias, avisos vinculados y reportes anteriores, identificados por texto. Reutiliza cabecera/botón+, tarjetas, filtro Abiertos/Resueltos y eliminación por swipe de Mascotas. Envíos pendientes y limpieza de fotos conservan acceso a descarte, sin fingir publicación. + abre las mismas dos opciones.

## Fronteras y persistencia

RecoveryReport envuelve entidades de dominio existentes y distingue origen en una clave compuesta para no confundir UUID iguales de tablas diferentes. ListRecoveryReports combina los casos de uso de consulta autorizada en paralelo: ambas fuentes deben completar, sin representar error como lista vacía. RemoveRecoveryReport delega eliminación/descarte en los casos de uso vigentes y comprueba autor. Declaraciones de providers consumen dominio/providers; no importan presentaciones o data externas. Pantalla observa RecoveryReportsViewModel; app/router compone apertura del panel de Home mediante callback.

Carga inicial con skeleton; refresh conserva registros con ContentRefresh/shimmer. Toast superior para error/resultado, reintento y bloqueo de doble eliminación. Guards de generación/cuenta impiden resultados tardíos sobre otra identidad. Tras volver de ficha o registro, se refresca la consulta conservando contenido. No hay una nueva tabla/RPC/migración/Edge; sigue siendo necesaria018 si no está activa. No se inventa orden cronológico global porque los contratos actuales no entregan fechas de orden comunes.

Rutas antiguas permanecen para recuperación de envíos y accesos existentes, pero salen del panel Reportar. No modifica permisos ni cierre explícito de búsquedas. Alcance: reorganización de UI y consulta privada sobre HU-05/06; no entrega exploración pública/paginación, QR/web, alertas o nuevas historias cerradas.

## Validación y referencias

Pruebas de navegación en tamaños normal/pequeño, texto2 y creación desde cada opción; identidad, refresh fallido conservado, orígenes con el mismo UUID y eliminación correcta. Capturas con fuentes reales, análisis/suite y límites en ESTADO. Android autenticado/fotos/teselas reales pendientes.

Referencias de componentes consultadas: [Apple Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets), [Material bottom sheets](https://m3.material.io/components/bottom-sheets/guidelines). La composición concreta respeta el sistema visual del proyecto y la instrucción explícita del usuario.
