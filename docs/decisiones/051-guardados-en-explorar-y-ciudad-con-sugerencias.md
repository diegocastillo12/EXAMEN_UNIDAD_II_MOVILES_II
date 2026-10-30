# ADR-051: Guardados en Explorar y ciudad con sugerencias compartidas

Ajuste vigente del16 de octubre: el marcador compacto de Explorar abre la pantalla independiente Guardados en /home/saved-cases. Reutiliza OriginPageSource/OriginPageTransition mediante entityEditorPage: expansión desde el icono y retorno al origen al cerrar, con movimiento reducido respetado. Sustituye el cambio de vista en la cabecera y la segunda pulsación. SavedCasesScreen reutiliza EntityScreenShell con retorno glass y cover→stagger, SavedCasesSection y PullToRefresh; scroll siempre desplazable incluso con lista vacía. Explorar permanece debajo con filtros/posición conservados. Sin cambios SQL;021 sigue pendiente de aplicación y revisión Android.

Estado: aceptada por instrucción explícita del usuario, 16 de octubre de2026.

## Producto

Por corrección posterior del usuario, Explorar abre Guardados mediante un marcador compacto junto al título, sustituyendo el selector inicial. Icono24/área48, vacío en Explorar y lleno en Guardados; título identifica la vista y segunda pulsación vuelve a Explorar. CollectionHeader conserva esta acción en la misma fila con título flexible para texto ampliado. Cabecera persistente y cover→stagger solo al cambiar vista. Cercanos conserva ubicación/radio/filtros durante el cambio; Guardados consulta únicamente las marcas de la cuenta, sin filtrar por radio ni exigir centro. Grilla fotográfica compartida, páginas20/Ver más, jalar para actualizar y refresco al volver de ficha. Quitar el guardado desde ficha se refleja al volver. Casos retirados/ocultos se excluyen por proyecciones vigentes; no se copian datos para mantener acceso. Error es distinto de vacío y conserva páginas/datos cuando procede.

Perfil reutiliza la búsqueda de Ubicación, en modo ciudad. Desde3 caracteres/pausa600ms, cinco sugerencias, escritura disponible y descarte de respuestas obsoletas. Seleccionar confirma ciudad; escribir texto nuevo por sí solo no permite guardarlo. Nombre/ciudad siguen opcionales, ciudad hasta120 puntos Unicode. Se permite vaciarla y conservar una ciudad antigua sin modificarla, sin inventar validación retroactiva. Descartar restituye texto/selección y limpia sugerencias pendientes; foto de perfil conserva esta edición.

## Reutilización y fronteras

El geocodificador se extrae de explore a places: entidades/contratos/caso de uso/fallos propios, fuente Photon/DTO/repositorios/caché, providers y ViewModel/widget de búsqueda. Bootstrap/main inyectan la misma instancia. Estados y caché distinguen ciudad de dirección, sin mezclar resultados. App/router compone el widget por slots de ExploreFilters y ProfileEditor; no se importan presentaciones entre funcionalidades. GPS continúa en explore y solo usa la entidad de lugar compartida en dominio.

PublicCaseCard/Kind/Status, PublicCasePageDto y PublicCaseGrid se extraen a core por uso real en Cercanos/Guardados. Los nombres anteriores de Explore se mantienen como alias hacia componentes compartidos, sin copiar lógica ni core→features. SavedCasesListViewModel consume ListSavedCases, con autoDispose, generaciones de identidad, bloqueo de doble envío, refresco/paginación/reintento y contenido conservado con shimmer.

## Ciudad y proveedor

Photon admite [filtrar por layer=city](https://github.com/komoot/photon/blob/master/docs/api-v1.md#filter-results-by-layer). El DTO exige resultado de ciudad/asentamiento reconocido con nombre y etiqueta≤120; no ofrece una calle como ciudad. La etiqueta guarda nombre/región/país, no coordenadas en perfil. UpdateProfile recibe explícitamente citySelected y rechaza texto nuevo no seleccionado; el ViewModel conserva esa condición durante edición/guardado/fallo/foto. La base de perfil mantiene sus límites/permisos previos: esto es selección/validación del flujo de app, no certificación de un registro oficial ni prueba de selección verificable en SQL.

Se mantiene caché30/5min, solicitud serializada/última pendiente, límite/timeout/atribución, endpoint PLACE_SEARCH_URL y condiciones del demo. Sin historia persistida ni envío de tokens a Photon. Fallar el proveedor permite reintentar; no se guarda texto nuevo arbitrario como sustituto de selección.

## Backend de Guardados

Fuentes074–076/plan021: índice parcial de marcas activas por cuenta/fecha/origen/UUID y list_saved_cases autenticada con límite1–50 (cliente20). Cursor vinculado a propietario/as_of/última clave; orden por guardado más reciente. Lee solo marcas propias y usa read_recovery_pet_case/read_recovery_report antes de incluir cada card; mismos permisos/miniaturas públicas verificadas. Respuestas contienen datos públicos y URLs firmadas por data, sin coordenadas/documentos privados.

No es una instantánea transaccional entre páginas: cambios posteriores pueden omitir elementos hasta refrescar. No se añade consulta global sin ubicación: Guardados es una colección privada, distinta de Cercanos. No se reescriben fuentes ni migración020 ya aplicada según el usuario. Se requiere aplicar021 después de020; ciudad no requiere nueva migración de perfil.

## Evidencia y pendientes

Formato/flutter analyze --no-pub sin incidencias; Build-RunAll generó migración20261016002100_saved_case_list.sql/patch021/run_all y verificó migraciones previas. Fixtures/imports/contratos existentes adaptados sin ejecutar pruebas, por instrucción del usuario. Sin SQL ejecutado, consultas reales del geocodificador, build/renders o despliegue.

Pendiente021 en desarrollo: permisos A/B/anónimo, cursor/cambios de marcas/visibilidad, índice/volumen, retorno y refresco; ciudad: selección/escritura/descartar/legados/fallo/cuenta, cobertura del proveedor y renders Android/pequeño/texto ampliado. No se cierra historia ni se implementa offline/seguimiento.
