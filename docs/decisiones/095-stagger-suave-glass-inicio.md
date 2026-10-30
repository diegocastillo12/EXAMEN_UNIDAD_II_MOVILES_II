# ADR-095: stagger suave para el glass de Inicio

Fecha:19/10/2026. Estado: implementado por corrección explícita del usuario.

El usuario rechaza el recorte progresivo introducido en ADR-094 porque cambia
la animación de Inicio. Se retira esa variante: preserveBackdrop conserva el
mismo fade y desplazamiento−28px del stagger850ms/90ms, sin el ImageFiltered
de entrada sobre las tarjetas glass. Superficie y contenido se mueven juntos.
No se añaden covers ni otro timeline; Explorar mantiene la corrección de094.

GlassSurface ofrece backdropBlendMode (srcOver por defecto). Las dos tarjetas
de Inicio usan src para componer el backdrop dentro de la capa de opacidad,
evitando doble mezcla temporal. Las otras superficies mantienen su composición.
Se conservan tamaños, radios, imagen de reunión y movimiento reducido.

Sin cambios de dominio/datos/permisos/HU. Regresiones temporales verifican
entrada conjunta, desplazamiento28 sin cambio de tamaño, resultado estable
después de completar, acción original y una sola entrada de Explorar.
Resultados y límites de revisión Android en ESTADO.
