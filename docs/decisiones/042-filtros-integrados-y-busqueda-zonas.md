# ADR-042: filtros integrados y búsqueda de zonas

Estado: aceptada por corrección explícita del usuario y confirmación del buscador de ciudad/dirección. Fecha: 15 de octubre de 2026, America/Lima.

## Corrección de experiencia

El usuario retira el popup de ADR-041: Filtrar casos vuelve a desplegar opciones dentro de Explorar, con el diseño compartido de cápsulas. `FilterExpansion<T>` reemplaza a `FilterPopover<T>`; se conserva `FilterChoiceGroup<T>` y `SelectionPillSurface` compartida con Activas/Archivadas. No crea rutas, barreras ni diálogos. La expansión participa en el scroll vertical existente; cabecera estable y cover→stagger del editor, sin repetirlo durante la edición. Con movimiento reducido se monta directamente, sin AnimatedSize de duración cero.

Cerrar la cápsula descarta cambios sin aplicar. Aplicar confirma, colapsa y devuelve el scroll al control para consultar resultados. La edición y la consulta conservan bloqueo de duplicados, shimmer y toast. La separación16 entre filtro y grilla evita que ambos se toquen. Las cards conservan columnas completas/márgenes, foto4:3 y alturas naturales por fila. Se elimina Mascota perdida del texto descriptivo: nombre y especie debajo; tipo corto y estado quedan en badges. Si no hay nombre, la especie ocupa el título sin repetirse. Los registros anteriores conservan su clasificación propia.

## Ubicación de búsqueda

El usuario confirma el recorrido solicitado tomando Marketplace como referencia: buscar ciudad/dirección, seleccionar un resultado en el mapa y ajustar radio en kilómetros. No se replica código, marca o una pantalla externa.

Todas las zonas evita aplicar filtro geográfico. Por ubicación permite buscar explícitamente con botón o teclado, seleccionar un lugar, ajustar el centro tocando el mapa y mover un slider de1–50km. El centro no se inventa por elegir el radio. Se muestra la selección confirmada y un círculo. `ZoneMapPicker.fitRadius` ajusta cámara al centro/radio y es opt-in: otros recorridos conservan su comportamiento. No se solicita GPS ni permiso de localización. El contrato019 sigue calculando cercanía sobre coordenadas públicas aproximadas de los casos, sin nuevos SQL ni exposición de puntos privados.

## Búsqueda de lugares y proveedor

Se adopta el contrato público de [Photon](https://github.com/komoot/photon), basado en OpenStreetMap. La fuente recibe cliente HTTP y endpoint desde bootstrap; `PLACE_SEARCH_URL` permite sustituir el servicio sin cambiar UI. El valor inicial es `https://photon.komoot.io/api/`, servidor de demostración que permite proyectos con uso razonable, sin garantía de disponibilidad y con posible limitación de uso. Es adecuado para validar este incremento de desarrollo; revisar servicio propio/proveedor con garantías antes de distribución o volumen mayor. No se usa Nominatim público.

Una solicitud explícita por búsqueda, máximo5 resultados, timeout12s y caché en memoria de30 consultas con expiración5min. No hay autocomplete por cada tecla, consultas masivas, reintento automático o persistencia de historial. Photon recibe el texto que la persona decide buscar, sin sesión/tokens de Supabase ni coordenadas privadas de reportes. El editor ofrece atribución enlazada a [OpenStreetMap](https://www.openstreetmap.org/copyright) junto al buscador; no se restituye el bloque retirado bajo los mapas compartidos.

Dominio agrega SearchPlace, PlaceSearchRepository y SearchPlaces (normalización/límites). Data contiene DTO GeoJSON, fuente Photon, caché y mapeo de fallos estables. PlaceSearchViewModel autoDispose gobierna resultados/carga/errores y descarta respuestas al cambiar identidad o desmontar. PlaceSearchFields consume ese ViewModel. Bootstrap/main inyectan implementaciones; providers siguen declarativos. `http` ya estaba fijado para tests y pasa a dependencia de ejecución con la misma versión resuelta. Sin claves nuevas ni SDK geográfico en widgets.

## Fallos y validación

Error, vacío y validación se comunican en toast superior; búsqueda real con shimmer/skeleton y datos públicos seleccionables. Fallar el geocodificador permite buscar de nuevo o elegir centro manual en mapa. Radio sin centro conserva shake/borde danger, no aplica ni confirma datos inexistentes. Una respuesta inválida del proveedor no se convierte en vacío exitoso.

Pruebas de normalización/validación, GeoJSON y coordenadas, errores/caché, solicitud única, cuentas/respuestas tardías y recuperación. El recorrido UI comprueba ausencia de popup, edición sin consultas de casos, colapso/aplicación, resultado de ciudad, centro/radio entregados al caso de uso y renders normal/pequeño/texto2. La fuente/repositorio/caso de uso reales ejecutados con Dart devolvieron5 lugares válidos para Miraflores, Lima, Perú, tras identificar la aplicación con User-Agent legítimo (el cliente Dart genérico recibió403); no equivale a validación Android autenticada, cobertura de todas las direcciones, rendimiento o disponibilidad futura. Evidencia final en ESTADO.
