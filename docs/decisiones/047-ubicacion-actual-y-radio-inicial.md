# ADR-047: ubicación actual y radio inicial de 15 km en Explorar

Estado: aceptada por instrucción explícita del usuario, 15 de octubre de 2026.

## Producto y recorrido

Explorar intenta obtener la ubicación actual al abrirse y consulta inicialmente casos a15km. El control se llama Ubicación. Se retira Todas las ubicaciones: cualquier búsqueda de casos requiere centro y radio. La persona puede buscar otra ciudad/dirección, tocar el mapa y ajustar1–50km, o volver mediante Usar mi ubicación actual. Cambiar centro conserva los otros filtros y el radio elegido; el valor inicial de la visita es15km. No hay seguimiento continuo ni historial persistido del dispositivo.

Denegación, servicios apagados, timeout o plataforma no disponible conservan selección manual, con aviso superior y acciones reales de selección/reintento. Sin centro no se consulta el listado ni se presenta como vacío confirmado. El estado invita a elegir ubicación; el buscador y mapa siguen disponibles. Un fallo del backend después de localizar conserva filtros y reintento.

Una consulta sin centro no supone por sí sola un colapso:019 limita páginas a20 elementos. El cambio prioriza relevancia local y acota geográficamente cada operación de producto; no sustituye índices, permisos, límites o medición de producción. La RPC019 conserva su contrato compatible con centro opcional; SearchCases y ExploreViewModel impiden ese uso desde la app. No se afirma un nuevo rechazo en servidor ni se modifica SQL aplicado.

## Arquitectura, plataforma y privacidad

CurrentLocationRepository/GetCurrentExploreLocation en dominio; DeviceLocationSource encapsula geolocator y CurrentLocationRepositoryImpl mapea resultados/fallos a entidades/fallos de dominio. Providers declaran contratos y casos de uso, bootstrap/main inyectan implementación. ViewModel gobierna solicitud inicial y reintento; widgets no llaman SDKs. Se amplía la comprobación arquitectónica para proteger geolocator.

geolocator14.0.2 se fija porque14.1.1 requiere dependencias incompatibles con Dart3.9.2; SDK existente conservado. Permiso Android ACCESS_COARSE_LOCATION y descripción iOS de uso mientras la app está abierta. Fuente solicita solo permiso de primer plano y una posición de precisión media, con timeout12s; comprobaciones previas con límite5s. No stream ni permiso de fondo. Selección manual permite usar Explorar sin conceder permiso. Según la [documentación del plugin](https://pub.dev/packages/geolocator/versions/14.0.2), la ubicación aproximada puede tardar más; el timeout no garantiza una lectura disponible.

El centro de búsqueda se utiliza como parámetro de la consulta autenticada a Supabase, sin crear una ubicación pública del usuario ni guardarla como preferencia. Photon recibe texto de búsqueda, sin enviarle automáticamente la posición del dispositivo. Sigue pendiente configuración/prueba de Apple y plataformas de escritorio; Android es referencia.

Por petición del usuario, toda etiqueta/mensaje visible de la app que decía Zona/Zonas pasa a Ubicación/Ubicaciones: Explorar, ubicaciones de interés, Perfil, Inicio, preferencias de alertas y fichas de reportes. No se renombran clases, rutas, tablas, módulos o archivos existentes; persisten contratos y permisos anteriores.

## Validación y límites

Dependencias resueltas con flutter pub get; formato y flutter analyze --no-pub sin incidencias. Expectativas existentes de texto y recorrido de Explorar adaptados; fuente de ubicación sustituible en pruebas y SDK protegido en arquitectura. **No se ejecutan pruebas por instrucción del usuario**, ni builds/renders ni lectura real de ubicación. La validación anterior no acredita el nuevo permiso, flujo inicial o renombrado global.

Pendiente recompilar Android (el cambio nativo no se activa solo con hot reload) y verificar permisos concedidos/denegados/permanentes, servicio apagado, timeout, cambio manual, retorno a ubicación actual, radio15km, identidad y respuestas tardías; comprobar backend019 activado. Apple requiere validación de su configuración nativa antes de distribuir. Sin publicación, modificación remota ni cierre de HU-07.1.
