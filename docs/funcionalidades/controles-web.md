# Controles web reutilizables desde sader-panel

Implementación local21/10/2026. [ADR-122](../decisiones/122-controles-web-reutilizables-desde-sader.md).

Corrección de etiqueta21/10: TextField usa una muesca real con fieldset/legend
decorativos (aria-hidden) y label/for transparente. Elimina el rectángulo claro
detrás del texto y el doble ribete del hover anterior. Contorno cerrado en vacío,
muesca al enfocar o conservar texto tras blur; aplica a inputs y textarea.
Foco/invalid/inset/disabled y contador conservan sus contratos. Sin datos nuevos.
La etiqueta larga puede ajustar líneas con texto ampliado: una reserva visual
aria-hidden ocupa solo las líneas adicionales y evita que tape el valor escrito.
Las medidas de texto/padding del campo escalan en rem; el tamaño base se conserva.

Tema celeste21/10 por petición explícita: todos estos controles consumen roles
--sf-* compartidos en fields.css. Superficie #F5F9FF, borde #B5CDE4,
hover #E5F2FA, selección #D6E8FF/texto #244C75, foco #2C87CE y loader #2887EF.
Sustituye la piel neutra inicial; dimensiones, estados y animaciones de Sader
se conservan. Sin selector de tema ni cambios globales en otras pieles.

Corrección21/10: pageKey de NuxtPage es una función estable; los renders de
cabecera/navegación no reinician la línea. TopLoadingBar inicia solo por el evento
Nuxt y termina también al confirmar la ruta/page:finish, sin depender de otro
montaje de Suspense. Regresión Chrome check-top-loading-browser.mjs valida
recarga con sesión, navegación, consulta retenida, query/hash, duplicado,
abortado, redirección y legales; línea oculta al terminar cada escenario.

## Qué hace y recorrido

FieldSkeleton (ADR-123) representa únicamente el selector pendiente en Reportar,
con etiqueta persistente, semántica de estado y shimmer compartido. Al confirmar
datos lo sustituye el FieldSelect real sin volver a animar el formulario; el
fallo muestra su acción de reintento y toast, sin simular una lista vacía.

Los formularios web comparten FieldSelect, TextField, DateField, TimeField y
DateTimeField; MorphPanel contiene la expansión desde el control. Explorar usa
selectores en sus tres filtros; mascotas en especie/tamaño/sexo y metadatos;
Reportar en tipo, mascota/búsqueda, fecha/hora, referencia y rasgos;
avistamientos en fecha/hora/comentario; moderación en motivo de decisión.
TopLoadingBar muestra la línea superior durante navegación, sin porcentaje falso.

## Reglas y campos

Piel extraída de componentes/globals.css de Sader: Inter local, control48px,
radio8px, opción48px, panel32px, calendario360px limitado al viewport y celdas40px.
El contenido/texto ampliado puede crecer. Input con etiqueta flotante y foco
inset3px; variante inset56px; textarea conserva límites/contador. Labels y
semántica permanecen visibles; no hay mensajes de error debajo.

Select controlado, búsqueda automática con más de ocho opciones y normalización
de tildes; flechas, Home/End, Enter/espacio, Escape y clic fuera. Calendario
lunes primero, min/max y navegación mensual/por flechas. Hora se muestra en12h
y entrega HH:mm de24h con precisión de un minuto, manteniendo contratos existentes.
Fecha/hora combinadas conservan las mitades mientras se completa el campo.

## Persistencia y permisos

Los componentes no llaman APIs, casos de uso ni repositorios. Emiten valores
al formulario actual. No alteran sesión, autorización por operación, QR,
privacidad de ubicación/contactos, borradores confirmados ni SQL. Los modelos
y servidores existentes siguen validando y guardando. Sin dependencias nuevas.

## Errores, reintentos y ciclo de vida

Toast superior y reintentos de cada flujo conservados. Controles deshabilitados
durante operaciones reales, aria-invalid y shake; movimiento reducido sin morph.
Timers/animaciones/ResizeObserver/listeners se liberan al cerrar/desmontar;
la barra termina al completar, cancelar o fallar la navegación.

## Dependencias y activación

Nuxt/Vue, Web Animations y Popover API; fuente Inter local ya disponible.
CSS compartido en `app/assets/fields.css`, sin contaminar landing ni otras pieles.
No necesita migración, activación de backend ni cambios en Sader.

## Validación

Corrección de etiqueta21/10: build/typecheck/62 pruebas correctos; regresión
check-text-field-browser.mjs pasa vacío/hover/foco/texto/blur/invalid para input y
textarea, transparente y muesca dimensionada al label. Incluye etiqueta larga
con valor a320px/texto200% sin superposición; capturas revisadas en web-text-field.
QA de campos/QR/moderación también correcto, con repetición TextField/QR tras el
ajuste final de reserva de líneas. Sin errores CSP/hidratación ni overflow en
estos escenarios. Sin comprobación Safari/Firefox ni dispositivos físicos.

Refinamiento celeste21/10: build y QA Chrome fields correctos. El script
comprueba los colores renderizados de selección/lista/calendario/hora, foco
de input y loader; capturas revisadas en web-fields. Contrastes de los pares
locales: selección7.12:1, texto secundario5.44:1, hover4.81:1 y foco3.64:1.
Se mantienen responsive, texto200%, teclado, búsqueda y movimiento reducido.
Esto no acredita una auditoría de contraste global ni Safari/Firefox.

Typecheck,62 pruebas existentes, build local y diff-check correctos. Chrome QA
con backend fixture pasa controles compartidos, recovery, sightings y moderación:
fotogramas reales del morph/blur, búsqueda sin tildes, teclado/retorno de foco,
línea superior durante consulta de sesión bloqueada, fecha local/hora23:59,
1920/1440/731/390/320px, texto200% y movimiento reducido. Recovery confirma
crear/editar/subir foto, filtros, los cuatro tipos de reporte, borrador restaurado
y reintento ambiguo sin duplicar. QR confirma anonimato, punto manual/GPS denegado,
foto inválida/EXIF eliminado y caso cerrado. Moderación confirma denegación por
rol, evidencia, decisión/restauración/reintento/cancelación y revocación.
Sin errores de CSP/hidratación ni desbordamiento horizontal en estos recorridos.
Capturas y frames revisados en apps/mobile/build/ui-preview/web-fields,
web-recovery, public-sightings y moderation-web. Scripts reproducibles en
apps/platform/scripts/check-{fields,recovery,sightings,moderation}-browser.mjs.
Pendientes: dispositivos físicos/Safari/Firefox, comparación visual integral
con Sader en todos sus estados y confirmación del backend remoto. No cierra HU
ni publica/despliega el proyecto.
