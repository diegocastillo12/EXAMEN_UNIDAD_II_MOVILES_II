# ADR-101: acceso flotante a Mapa desde Explorar

Fecha:19/10/2026. Estado: aceptada por el usuario al elegir la propuesta3.

## Decisión

Retirar la fila Lista/Mapa. Mapa es una acción que abre su pantalla existente,
mediante cápsula glass con icono map_outlined22, texto14/600 y mínimo48px.
Radio26, padding horizontal18/vertical12, separación icono/texto8.
Reutiliza GlassSurface real; Reportar negro y navegación permanecen.

El botón flota a16px de la derecha y100px más inset inferior del borde,
con20px de separación sobre la barra de64px situada a16px más inset.
Permanece fijo durante scroll y solo aparece en Explorar con estado consultado;
no aparece en carga inicial/error sin datos. Busy conserva el bloqueo existente.
Home reserva200px más crecimiento del texto e inset al final del scroll para
que la última tarjeta/acción pueda salir de debajo de los controles.

Router compone ExploreMapButton en un slot visual exploreFloatingAction de Home,
sin imports de presentación entre funcionalidades. El botón observa el mismo
ExploreViewModel; no ejecuta búsqueda ni crea estado de consulta alternativo.
Captura su rectángulo real para OriginPageSource/entityEditorPage; retorno,
movimiento reducido, filtros, resultados y scroll existentes conservados.
La copia visual del origen usa FittedBox para soportar cambios de restricciones
y tipografía durante la expansión sin desbordamientos.

Sustituye el selector de ADR-052 y su acceso desde ADR-055; el mapa inmersivo y
sus operaciones permanecen. Refinamiento HU-07.1/07.2, RF-13, issues #32/#33;
sin nuevo alcance, SQL, permisos, dependencias, activación ni cierre de historia.

## Validación

Regresión integrada en Home390×844 y320×350/texto2 comprueba botón fijo,
separación de navegación, origen real, consulta compartida, detalle/paginación,
retorno con scroll conservado y retirada al salir de Explorar. Movimiento
normal/reducido.36 pruebas aprobadas; análisis completo/formato/diff correctos.
Capturas normales/pequeñas revisadas; evidencia final en ESTADO.
Revisión física Android pendiente. Sin APK, instalación o despliegue.
