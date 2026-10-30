# ADR-077: marca y cabecera web compartidas con la landing

Fecha: 19/10/2026. Estado: aceptada por corrección explícita del usuario.

## Contexto y decisión

ADR-076 formalizó la posición, pero persistían versiones independientes con
colores, tamaños y posiciones distintos en Inicio, onboarding, login y QR.
El usuario exige que coincidan con la landing, referencia aprobada.

SiteBrand y SiteHeader de app/components se reutilizan en landing, acceso,
bienvenida, inicio, moderación, QR/avistamientos y documentos legales.
La marca de cabecera usa Arial/Helvetica/sans-serif, color #171918,
peso500, espaciado−.05em, interlineado.9 y gap7px. Texto en una línea.
Texto clamp(16px,1.9vw,25px), logo clamp(25px,3.3vw,42px), proporción original;
en <=600px texto20px y logo30px. Fuente y medidas explícitas impiden heredar
Inter del onboarding o DM Sans de legales. No alterar la marca del footer.

Cabecera al ancho disponible con márgenes/padding adaptables de landing,
sin límites de ancho por funcionalidad. Posición del logo comprobada contra
landing en escritorio/tablet/móvil. Cabecera estable fuera de stagger/cargas;
no se modifica al editar o cambiar de etapa. No exige fijación al hacer scroll.
Retorno glass de recorridos con withBack se ubica debajo de la cabecera para
no tapar la marca; documentos legales conservan su toolbar dentro del scroll.

Login retira el logo grande y texto partido del formulario: conserva cuatro
grupos de contenido del stagger850ms/90ms. Onboarding sustituye logo52px y
marca24px por las medidas de landing; conserva Inter/ilustraciones/transiciones
del cuerpo. Esta decisión sustituye esas medidas de marca de ADR-074 y
concreta ADR-076, sin afectar móvil, autenticación, permisos o persistencia.

## Validación

Comparación automatizada de bounding boxes, color, fuente, peso, separación,
interlineado y tamaño del logo con landing en1440/731/390/320 y texto200%.
Verificar recorridos, no overflow, cabecera estable, SSR/CSP y retorno glass.
Evidencia ejecutada y pendientes en ESTADO; sin despliegue.

Corrección de implementación19/10: el layout de cabecera de landing lo declara
solo landing.css; site-brand.css limita su layout general a reader-shell.
Evitar reglas de igual especificidad con valores distintos cuya precedencia
cambie entre SSR/hidratación. Marca compartida y composición aprobada conservadas.

## Ratificación explícita de la regla —19/10/2026

El usuario solicita registrar el resultado corregido como norma de ubicación.
La referencia es la posición final aprobada de landing, estable desde SSR,
no una posición provisional que se reajusta al hidratar. Las reglas web detallan
ubicación, color, medidas, composición responsive y verificación de recarga.
