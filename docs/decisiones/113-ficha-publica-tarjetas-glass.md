# ADR-113: ficha pública móvil por tarjetas glass

Fecha:20/10/2026. Estado: aceptada por aprobación explícita del mockup y ejecución.

Refinamiento posterior20/10 por corrección del usuario: etiqueta del caso a la
derecha del nombre en la misma fila, alineada por su centro; paginación centrada
debajo. Texto ampliado o etiqueta larga apilan sin recortar el estado. GlassSurface
incorpora acabado frosted: ribete blanco único, sombra difusa suave y mezcla
gris perla/celeste traslúcida, sin doble contorno oscuro. CasePublicGlassCard y
SMS/teléfono usan frosted; volver/guardar mantienen el acabado anterior aprobado.
El valor por defecto polished conserva los demás consumidores y el patrón
ImmersivePhotoSheet.

## Decisión

Ver ficha de perdidos y encontrados usa CasePublicCards: fotografía redondeada,
nombre blanco48/800, etiqueta del caso, paginación, contacto autorizado cuando
existe, datos en dos columnas, rasgos, fecha y mapa en tarjeta propia. El material
gris perla con reflejos celestes compone GlassSurface; no duplica su blur/ribete.
El contenedor es CasePublicScreenShell, con AppScaffold/fondo compartido y scroll.
Se conserva ImmersivePhotoSheet según ADR-112; continúa en las vistas previas de
los formularios y no se elimina aunque deje de utilizarse en fichas públicas.
Esta separación sustituye la obligación anterior de igualar ambos layouts.

La referencia aprobada se conserva en
[mockup con contacto](../../mockups/ficha-publica-glass-contacto.png).
La imagen es referencia de diseño; sus datos no se incorporan a producción.

## Tipografía, navegación y estados

Excepción local a ADR-111 aprobada con esta composición: el título de navegación
«Ficha pública» usa Poppins400/20/gris; con texto ampliado más del130%, pasa
a título32 en una fila propia desplazable. El nombre sobre foto mantiene
blanco48/800/sombra/dos líneas. Los demás títulos conservan sus reglas.
Volver y guardar usan GlassNavigationButton52, tooltip e insets; flotan sobre
el scroll, sin franja opaca. El título se desplaza para no solapar otros textos.

Las tarjetas tienen radio28, margen lateral16, separación12 e interior18.
Foto normal1.35:1, más alta con texto ampliado; metadatos pasan a una columna.
Sin foto se muestra un símbolo y semántica de ausencia; no se inventa una imagen.
La galería permite deslizar también sobre los textos superpuestos.
Skeleton inicial específico, ContentRefresh para refresco conservado, toast
superior y cover→stagger fuera de navegación. Respeta movimiento reducido.

## Operaciones y mapa

El acceso a seguimiento conserva su autorización existente y pasa a enlace
«Ver seguimiento». Reportar avistamiento mantiene la ruta real y usa el acabado
azul compartido NavigationAccentSurface. Las otras operaciones permanecen debajo,
según autor, estado y permisos; no se sustituyen por acciones del mockup vacías.
El CTA desaparece en casos cerrados y en avisos que no son búsquedas.

Mapa180px mediante ZoneMapPicker/MapStyle, sin matriz por funcionalidad ni SDK
nuevo. Solo usa coordenadas públicas, cámara adaptada a1000m y halo/punto azul.
Se retira el disco negro del radio en esta composición; el texto conserva que
el punto es aproximado, y no publica lugar exacto ni ciudad inventada. Créditos
y recuperación de teselas pertenecen al adaptador; misma configuración Positron
del entorno. No se modifica cartografía global ADR-104.

Ficha funcional: [ficha pública móvil](../funcionalidades/ficha-publica-mobile.md).
Contacto es otro incremento autorizado en este chat, descrito en ADR-114.
