# Ficha fotográfica inmersiva

Actualización posterior20/10, ADR-113: el patrón sigue conservado íntegro y activo en vistas previas de los formularios. La consulta pública de perdidos/encontrados ya usa CasePublicCards. Esta nota sustituye las menciones inferiores a su uso activo en las fichas de consulta; el contrato y futura reutilización se conservan.

Estado20/10/2026: diseño implementado, conservado y renombrado por petición del
usuario para reutilización futura. Continúa activo en sus consumidores actuales.
La futura funcionalidad no está definida ni implementada. No cierra una historia.
Decisión: [ADR-112](../decisiones/112-conservar-ficha-fotografica-inmersiva.md).

## Identidad y archivos

Nombre anterior: `CasePublicationPreview`; nombre actual: `ImmersivePhotoSheet`.
Implementación: `apps/mobile/lib/core/presentation/widgets/immersive_photo_sheet.dart`.
Geometría: `immersive_photo_sheet_geometry.dart` / `ImmersivePhotoSheetGeometry`.
Prueba conservada: `apps/mobile/test/immersive_photo_sheet_test.dart`.
Es el diseño de foto a pantalla completa con panel inferior deslizable;
la propuesta nueva de tarjetas glass gris perla es otro diseño, aún sin implementar.

## Composición y recorrido

- Galería PageView a pantalla completa, degradado oscuro superior/inferior e
  indicador segmentado si hay varias fotos. Índice local, no persistido.
- Nombre blanco48/800, fuente del sistema, altura1.05, sombra negra suave,
  dos líneas con elipsis; sin cápsula. Etiqueta del evento en cápsula roja
  #B53F48. Nombre/etiqueta apilados en modo compacto.
- Panel GlassSurface de radio32, superficie #DDF5F5F7 y margen lateral16.
  Nombre con margen24; interior20; tirador38×4 en objetivo táctil de48.
- Panel inicial46% con acciones y36% sin ellas;76% en altura menor500 o
  texto16 ampliado por encima de22. Máximo calculado con inset superior y64,
  limitado a94%. Arrastre, scroll y tirador para expandir/contraer.
- Tirador anima320ms easeInOutCubic; movimiento reducido usa salto inmediato
  y desactiva snap. Controlador liberado al desmontar.
- Datos con iconos en dos columnas; una columna con texto ampliado. Descripción
  expandible compartida. Fecha, mapa y privacidad aparecen al expandir; las
  acciones reales inyectadas siguen en el contenido desplazable.
- Navegación/retorno superior y estado de carga pertenecen al shell consumidor;
  no forman parte del componente. CasePublicSkeleton sigue usando su geometría.

## Campos y contrato actual

Recibe nombre, widgets de fotos, lista PreviewFact(icono, etiqueta), descripción,
fecha ya formateada, texto de privacidad, latitud/longitud públicas, etiqueta de
ubicación, etiqueta de evento y slot opcional de acciones. Puede recibir una
factoría de TileProvider para pruebas. No consulta repositorios ni SDK de backend.
El nombre neutral conserva este contrato concreto, incluido su mapa; no se añaden
opciones o abstracciones para usos hipotéticos.

## Persistencia, permisos y privacidad

Sin persistencia propia; foto seleccionada y expansión son estado local de UI.
Lost_cases y found_cases proporcionan datos públicos mediante sus ViewModels y
casos de uso. Permisos, identidad y acciones se resuelven fuera del patrón.
El mapa usa ZoneMapPicker de solo lectura, radio1000m, sin marcador central y
MapStyle compartido. Nunca sustituir coordenadas públicas por el punto privado
para reutilizar el diseño. No hay cambios SQL, RLS, RPC ni configuración remota.

## Errores, reintentos y dependencias

El consumidor aporta fotos con su shimmer/fallback y acciones de reintento.
Los fallos de lectura, refresh y operaciones siguen en sus ViewModels/shells,
con toast superior y ContentRefresh/LoadingShimmer compartidos. El patrón no
introduce mensajes de error, loaders ni llamadas de negocio.
Dependencias visuales: GlassSurface, StaggerRevealItem, ExpandableDescription,
ZoneMapPicker e ImmersivePhotoSheetGeometry; shell y skeleton permanecen externos.

## Reutilización y activación

Imports actuales en case_public_content.dart y found_public_content.dart apuntan
al componente renombrado, tanto en vista previa como en ficha pública. No se
requiere activar flags, migrar datos o cambiar rutas. Para la futura funcionalidad,
definir primero datos públicos y acciones reales, componer desde su presentación
y conservar las fronteras entre funcionalidades. Mantener este componente al
sustituir sus consumidores actuales por las nuevas tarjetas; no borrarlo como
limpieza automática ni inventar una pantalla futura para retenerlo.

## Validación

Se conservan las pruebas existentes de galería, expansión, estilo del nombre,
descripción y acciones alcanzables en390×844 y320×350/texto2 con movimiento
normal/reducido; integraciones de perdidos/encontrados y regla arquitectónica.
Resultado de la ejecución del renombrado en docs/ESTADO.md. Revisión física
Android y validación del uso futuro pendientes; no hay despliegue ni confirmación
remota asociados a esta conservación.
