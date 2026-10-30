# ADR-097: filtros en Explorar y resumen del pin en el mapa

Estado: aceptada por el usuario. Fecha: 19/10/2026, America/Lima.
Trazabilidad: HU-07.1/HU-07.2, RF-13; issues #32/#33, sin reapertura ni cierre automático.

## Contexto

Lista y Mapa compartían la consulta pero ofrecían dos editores de filtros.
El usuario pide concentrar su configuración en Explorar y dedicar el panel
inferior del mapa al caso seleccionado, con una acción para abrir la ficha.

## Decisión

Explorar mantiene Filtrar casos y Ubicación. El mapa consume esa búsqueda
sin editor, GPS, búsqueda de lugares ni Aplicar filtros dentro de su pantalla.
Pan/zoom y selección de pines no modifican la consulta.

El panel inferior muestra el resumen público del pin seleccionado: foto,
nombre, tamaño, raza no registrada cuando no existe, fecha y estado; Ver ficha
abre el detalle existente del caso correspondiente. Se retira la tarjeta
flotante junto al pin para evitar duplicar el resumen. Sin selección se indica
que debe elegirse un pin; sin resultados confirmados se orienta a Explorar.
No se interpreta un error o una consulta pendiente como vacío confirmado.

Se conservan agrupación por coordenadas públicas aproximadas, anterior/siguiente
en coincidencias, panel42–90%, resistencia al bajar, retorno glass y movimiento
reducido. El resumen utiliza el scroll del panel; Ver ficha permanece fijo
cuando cabe y pasa al scroll en altura reducida/texto ampliado. Sin botón de
ficha hasta seleccionar un caso. Ver más casos y Reintentar conservan las
operaciones existentes. Al volver de la ficha se refresca la misma búsqueda;
al volver a Explorar se mantienen filtros/resultados/paginación compartidos.

## Consecuencias

Sustituye el editor inferior de ADR-056, la tarjeta junto al pin de ADR-062 y
la referencia a filtros del panel de ADR-061. Conserva su contenido público,
marca y comportamiento restante. La ruta inmersiva de ADR-055 continúa vigente.
No cambia dominio, repositorios, SQL, permisos ni lectura privada. La pantalla
observa los ViewModels existentes; el router deja de inyectar places en el mapa.
Cambiar la búsqueda requiere regresar a Explorar, por decisión del usuario.

## Validación

Formato verificado, flutter analyze --no-pub sin incidencias y19 pruebas de
mapa, preview público y arquitectura aprobadas. Cubren filtros no predeterminados
conservados, ausencia del editor en mapa, selección, coincidencias, Ver ficha,
refresh, paginación y retorno;390×844 y320×350/texto2/movimiento reducido.
Capturas locales con fotos/teselas de fixture revisadas; no son evidencia hosted.
Pendiente revisión de este nuevo recorrido en Android; no se genera APK ni se
publica o despliega por este incremento.
