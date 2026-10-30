# ADR-122: controles web compartidos desde sader-panel

Fecha: 21/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Corrección de la etiqueta sobre fondo degradado —21/10/2026

TextField dibuja su contorno mediante fieldset/legend decorativos y aria-hidden,
con una muesca real cuando la etiqueta flota. La etiqueta visible conserva
label/for y fondo transparente; no se superpone una pastilla opaca para ocultar
un borde continuo sobre orbes/degradados. Input/textarea mantienen dimensiones,
valor, transparencia, resize y contador. Foco/error se dibujan una sola vez en
el contorno compartido; hover no hereda el segundo ribete del kit anterior.
La variante inset conserva la etiqueta interior y el contorno cerrado.
La reserva de líneas adicionales de etiquetas largas es decorativa/aria-hidden;
con ampliación se ajustan padding/altura en rem sin superponer etiqueta y valor.

## Refinamiento de tema celeste —21/10/2026

Por petición posterior del usuario, se conserva el sistema de roles de color de
Sader y se adapta a los celestes de Entre Huellas. fields.css define tokens
locales --sf-* para superficie, borde, outline, foco, hover, selección/texto,
errores y progreso. Selección #D6E8FF con texto #244C75, hover #E5F2FA,
superficie #F5F9FF, foco #2C87CE y segmento del loader #2887EF. Texto principal
#171918 y error #B53F48 conservan la identidad existente.

Los mismos tokens aplican a FieldSelect, TextField, DateField, TimeField,
MorphPanel y TopLoadingBar; se retiran los colores neutros fijos de opciones,
calendario, columnas horarias y barra. Dimensiones y animaciones no cambian.
Es un tema fijo compartido para estos componentes, sin catálogo ni selector de
temas, persistencia nueva o cambio global de landing/acceso/títulos/Flutter.

## Contexto y decisión

El usuario solicita adaptar FieldSelect, inputs, fecha/hora y la línea superior
de carga de `platform-sader-kormind/apps/sader-panel`, conservando su diseño y
animaciones. El incremento se implementa en la aplicación Vue/Nuxt existente,
`apps/platform`, mediante componentes compartidos en `app/components`.

`MorphPanel` encapsula Popover API/top layer, geometría limitada al viewport,
FLIP centrado, radio final32px, apertura420ms power3.out, cierre300ms, blur12px
y reajuste350ms. Web Animations API reproduce la curva mediante muestras,
sin añadir React/GSAP, estilos inline SSR ni relajar CSP. Libera animaciones,
observador y listeners al desmontarse; movimiento reducido omite el morph.

`FieldSelect`, `TextField`, `DateField`, `TimeField` y `DateTimeField` son
presentación controlada. Reutilizan la piel local Inter, controles48px,
radio8px, opciones48px, calendario lunes primero y columnas horarias40px.
El texto puede crecer para accesibilidad en vez de cortarse. TextField admite
etiqueta flotante/inset y textarea con contador. Selección por teclado, búsqueda
sin tildes para más de ocho opciones, Escape, clic fuera y retorno de foco.

Fecha conserva YYYY-MM-DD local; hora conserva HH:mm y permite las24 horas y
los60 minutos: las restricciones comerciales9–20h/5min de Sader no corresponden
a avistamientos. No se copian horarios de oficina ni reglas de otro producto.

`TopLoadingBar` reutiliza ProgressBar/globals.css de la referencia: pista4px,
segmento40%, barrido670ms; posición fija superior durante navegación real.
Movimiento reducido mantiene el pulso sin desplazamiento. Esta petición es una
excepción explícita a la prohibición de indicadores lineales de ADR-027,
limitada a la navegación web. Botones mantienen shimmer y contenido skeleton.

Corrección21/10: la función pageKey de NuxtPage mantiene identidad estable para
evitar inicios de carga por renders del shell. La línea inicia por el evento de
Nuxt y termina también al confirmar navegación/page:finish, incluidas páginas
reutilizadas. Sin un segundo inicio desde un guard propio del componente.

## Consecuencias y alcance

Integración en filtros de Explorar, Registrar/Editar mascota, Reportar,
avistamientos QR y motivo de moderación. Acceso mantiene su composición aprobada.
No modifica Flutter, dominio, ViewModels, repositorios, datos, SQL, permisos,
consentimiento, marcas ni títulos principales. Los errores permanecen en toast
superior, con invalidez semántica/shake sin helper/error bajo campos.

La validación ejecutada y sus límites se registran en
[la ficha](../funcionalidades/controles-web.md) y ESTADO. Portar valores desde
el código fuente no equivale a certificar igualdad píxel a píxel en todos los
navegadores ni confirmación remota. No se autoriza despliegue.
