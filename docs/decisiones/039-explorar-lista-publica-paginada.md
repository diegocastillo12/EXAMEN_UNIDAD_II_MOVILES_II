# ADR-039: lista pública filtrada de Explorar

Estado: implementada para HU-07.1, continuación autorizada por el usuario. Fecha: 15 de octubre de 2026, America/Lima.

## Decisión y alcance

Explorar incorpora una lista paginada de búsquedas y avisos existentes. HU-07 / RF-13 se entrega en dos incrementos: esta lista (HU-07.1, issue #32) y posteriormente mapa de resultados (HU-07.2, issue #33). El mapa del filtro solo selecciona el centro manual; no representa una entrega anticipada del mapa de resultados.

La clasificación respeta ADR-034: pérdidas propias y posibles pérdidas comunitarias se filtran como Perdidas; avisos con custodia y reportes independientes anteriores como Encontradas; avistamientos tienen filtro propio. Un registro legacy conserva la etiqueta Reporte anterior. Las tarjetas abren las fichas existentes, desde donde se crean avisos vinculados a búsquedas abiertas. No se añade publicación genérica de avisos.

Los estados consultables respetan las proyecciones actuales: los resueltos solo son visibles para su autor. No se amplía su publicación ni la lectura de fotos resueltas de terceros para satisfacer el filtro. Los períodos filtran la fecha del suceso; el orden de páginas usa fecha de publicación, origen e ID.

## Consulta geográfica y privacidad

SQL066–069/plan019 añade PostGIS en `extensions`, índices GiST y RPC `explore_cases`. La instalación rechaza un PostGIS existente en otro esquema; no lo mueve automáticamente. La cercanía se calcula con ST_DWithin/ST_Distance sobre las coordenadas públicas aproximadas, nunca sobre el punto exacto. Evita inferirlo consultando repetidamente radios pequeños. Índices y consulta usan la misma expresión geográfica.

La RPC requiere sesión autenticada y devuelve campos explícitos de tarjetas, coordenadas públicas y referencia de miniatura procesada seleccionada. No devuelve columnas de propietario, referencia privada, originales o documentos. Reutiliza `read_recovery_pet_case` y `read_recovery_report`: borrados, borradores y destinos sin visibilidad permanecen fuera. No concede SELECT adicional sobre tablas ni permisos de escritura.

PostGIS y uso de índices siguen las referencias primarias de [Supabase](https://supabase.com/docs/guides/database/extensions/postgis) y [PostGIS](https://postgis.net/documentation/tips/st-dwithin/). Selección de zona mediante ZoneMapPicker/MapConfig existentes, sin solicitar GPS. El proveedor y sus pendientes de condiciones no cambian.

## Páginas y recuperación

Orden descendente estable por publicación/origen/UUID, cursor con límite temporal de la primera consulta y copia de filtros. Cambiar filtros invalida el cursor. La RPC limita páginas a 50; la app solicita 20 y solo muestra Ver más cuando existe otra página. Inserciones posteriores no entran en la ventana ya iniciada. No es una instantánea transaccional entre peticiones: cierres/eliminaciones se vuelven a evaluar por seguridad y pueden retirar filas.

Presentation usa ExploreViewModel autoDispose → SearchCases → ExploreRepository; data contiene DTO, fuente Supabase y mapeo de fallos. Providers declaran contratos/casos de uso. Bootstrap/main inyectan implementaciones; router entrega ExploreSection al shell de Inicio sin imports de presentation/data entre funcionalidades. Las miniaturas se firman desde data con los permisos existentes; un fallo se comunica como fallo de consulta, sin convertirlo en vacío confirmado.

Skeleton inicial, LoadingShimmer en acciones y ContentRefresh para refresh con datos conservados. Un filtro nuevo oculta los resultados anteriores hasta confirmar la respuesta. Se conservan páginas/cursor al fallar Ver más, se bloquean solicitudes duplicadas y se descartan respuestas tardías al cambiar de cuenta. Errores/validación en toast superior, selección manual inválida con ShakeField/borde danger. Entradas usan cover→stagger del shell; filtrar/paginar/refrescar no repite la entrada.

## Activación y validación

Migración/patch019 tras001–018 y pipeline previo de fotos. No requiere una Edge Function nueva. Fuentes y artefactos generados, repetición/permisos/filtros/páginas con PostGIS real en PGlite, pruebas Flutter y renders locales registrados en ESTADO. El paquete experimental de PostGIS se limita a herramientas de prueba, fijado con PGlite compatible; no se incluye en Flutter ni sustituye Supabase hosted, pruebas multiconexión, rendimiento o demo Android.

No se cierra HU-07 ni se despliega por esta decisión. La validación del usuario sobre la rama anterior queda separada de la activación y demo de este incremento.
