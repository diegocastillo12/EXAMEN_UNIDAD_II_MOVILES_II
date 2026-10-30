# ADR-129: mapas web con la referencia móvil

Fecha:21/10/2026. Estado: aceptado por instrucción explícita del usuario.
Trazabilidad: mapas de HU-05/06/07 y avistamientos HU-10; sin cierre de historias.

## Decisión

El usuario exige que mapa, pines y detalles web reproduzcan móvil. ADR-104
igualaba teselas y filtro, pero dejaba intactas las superposiciones y controles
de cada plataforma; LocationMap todavía utilizaba un punto circular, zoom14,
altura300, radio24 y controles Leaflet ajenos al selector móvil.

Cada recorrido equivalente debe tomar su referencia real de ZoneMapPicker:
Positron/filtro sRGB compartido, fondoF5F5F3, altura280, esquinas22, zoom12,
pin Material location_on negro111111 de36 centrado en la coordenada. No cambiar
el anclaje al extremo inferior. Crédito superior con márgenes8, espacio izquierdo76,
superficie blancaEF/radio12 y objetivos48. Sin controles+/− ni acción visible
Usar centro del mapa, ausentes en móvil; teclado conserva flechas y Enter/Espacio
para seleccionar el centro. Texto ampliado conserva créditos legibles.

Reportar pérdida usa radio0, como CaseLocationFields; avistamientos/mascota
con el informante usan200m como SightingScreen, círculo111111, relleno34/255
y borde2. Estos valores son presentación; no amplían precisión pública ni
exponen puntos privados. Los pines de resultados de Explorar móvil son otro
componente (silueta48 con marca oficial/selección); no deben reemplazar el
location_on del selector. Explorar web todavía ofrece lista, sin mapa de resultados.

## Integración y validación

Conservar LocationMap como único adaptador Leaflet; SightingMap y Reportar
entregan radio según recorrido. ResizeObserver invalida el tamaño tras expansión
o resize sin recentrar; liberar observador/mapa al desmontar. Bloquear navegación
y selección al deshabilitar como readOnly móvil. Fallos conservan toast/reintento;
sin cambios de SDK, dependencias, SQL, permisos o contratos de dominio.

QA debe comprobar pin y círculo reales, selección manual/teclado, filtro pintado,
créditos, responsive/texto ampliado, CSP e hidratación en ambos formularios.
Capturas con teselas fixture prueban presentación; revisar Android/web con
Positron real para confirmar fidelidad final y disponibilidad del proveedor.
No afirmar paridad funcional global ni mapa de resultados web implementado.
