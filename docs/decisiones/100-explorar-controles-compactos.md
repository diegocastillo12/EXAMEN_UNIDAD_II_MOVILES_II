# ADR-100: controles compactos de Explorar

Fecha:19/10/2026. Estado: aceptada por instrucción del usuario.

## Motivo y decisión

El usuario considera demasiado alta la fila Ubicación/Filtrar casos y solicita
un icono para los filtros. Ubicación aprovecha el ancho disponible y muestra
lugar y radio en una línea; el lugar largo se elide visualmente y conserva
su tooltip completo. Filtrar casos usa solo tune, sin texto ni chevrón,
en un círculo48×48 con tooltip, nombre accesible y estado expandido.
La fila mide48px con texto normal; Ubicación crece con texto ampliado.
Ambas acciones conservan al menos48px de área táctil.

FilterExpansion comparte panel, overlay, cierre, borrador/Aplicar, shimmer,
movimiento reducido y lifecycle existentes. Su variante compacta omite el
padding exterior de SelectionPillSurface y reduce el interior, manteniendo
el mínimo táctil. Otros selectores conservan sus medidas predeterminadas.
Sustituye la distribución anterior de dos columnas iguales; el panel de
filtros mantiene ancho completo y alineación derecha, Ubicación atOrigin.
Sin cambios de ViewModel/dominio/data, permisos, SQL, HU/RF o alcance MVP.

## Validación

Comprobar dimensiones48px, ausencia de etiqueta visible, apertura/cierre,
descarte/Aplicar sin consultas prematuras, lugar/radio, texto2 y paneles en
390×844 y320×350. Evidencia y pendientes en ESTADO y ficha Explorar.
Revisión Android física pendiente; sin despliegue ni activación nueva.
