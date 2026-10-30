# Mis reportes

Alineación20/10/2026: CollectionHeader ancla el título al borde superior de
la fila, conservando mínimo56 y espacio de acciones. Explorar y Mis mascotas
comparten la posición inicial de «Su regreso»; se elimina el desplazamiento8
por centrado vertical. Regresión de navegación con fuentes reales en390×844
y320×350/texto2 aprobada. Sin cambio de tipografía, datos o permisos.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

Módulo: found_cases, colaboración por dominio con lost_cases. UI de entrada compuesta en app/router. HU-05/RF-05 e HU-06/RF-06; issues#5 y#6, sin cierre de historias.

## Qué hace y recorrido

Desde Inicio, Mis reportes reúne las búsquedas propias, búsquedas comunitarias y avisos del usuario en una lista. Cada tarjeta identifica el tipo real. Abiertos/Resueltos filtra el estado confirmado; tocar una tarjeta abre la ficha correspondiente. Swipe y confirmación retiran el reporte. + abre Reportar con las dos opciones de creación, sin listados dentro del modal. Volver de ficha/registro actualiza la lista conservada.

## Reglas y campos

Solo reportes de la cuenta actual. Clave de UI compuesta por origen e ID; UUID iguales en tablas diferentes siguen siendo registros independientes. Títulos/nombre/especie y foto proceden de contratos existentes, sin datos simulados. Avisos muestran si su búsqueda está abierta/cerrada según018. Reportes antiguos permanecen explícitos; borradores/limpieza pendiente tienen estado y acción de descarte, separados de publicación. Se conserva orden entregado por cada fuente; no se declara cronología global inexistente en los contratos.

## Persistencia y permisos

Consulta mediante ListRecoveryReports, que combina ListMyLostCases/ListMyFoundCases. Eliminación/descarte mediante RemoveRecoveryReport y casos de uso existentes, con validación de autor/estado y RPC/RLS previas. No crea tablas, columnas, políticas ni migraciones; proyecciones y fotos conservan privacidad vigente. Eliminar no equivale a confirmar recuperación.

## Errores y reintentos

Ambas lecturas deben completar para confirmar la lista. Error inicial muestra toast/Reintentar, sin afirmar vacío; refresh fallido conserva ambas fuentes con toast y acción real de reintento. Skeleton inicial/ContentRefresh con shimmer; eliminación/descarte bloquean dobles acciones. Una fuente fallida no borra registros anteriores. Cambio de identidad oculta anteriores y rechaza resultados tardíos. Descarte relee el estado para conservar tombstones de limpieza reales.

## Dependencias, activación y validación pendiente

Depende del backend de casos001–018 y pipeline de fotos anterior. Este incremento solo modifica app, sin nuevo SQL. Componentes de core compartidos con Mascotas; dominio/providers colaboran entre funcionalidades, sin imports cruzados de presentation/data. [ADR-036](../decisiones/036-reportar-y-mis-reportes.md). Evidencia local en [ESTADO](../ESTADO.md); Android autenticado, Supabase remoto y fotos/teselas reales pendientes.


Actualización del12 de octubre: + crea búsqueda perdida directamente, sin panel de dos opciones. Los avisos se crean desde la ficha de una búsqueda abierta, nunca eligiendo un catálogo. Lista unificada y operaciones conservadas; [ADR-037](../decisiones/037-avisos-desde-ficha.md).
