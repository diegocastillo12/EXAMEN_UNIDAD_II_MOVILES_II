# ADR-108: sugerencias de ubicación superpuestas

Fecha:20/10/2026. Estado: aceptada por instrucción del usuario.

## Motivo y decisión

El usuario pide el listado continuo de su segunda captura y que las sugerencias
se desplieguen sobre el contenido, sin empujar mapa, radio o campos posteriores.
Sustituye la disposición de resultados en columna y cápsulas individuales de
PlaceSearchFields. Aplica a Reportar, Explorar y Ciudad del perfil.

PlaceSearchFields compone un OverlayPortal anclado al campo mediante LayerLink.
Un solo panel con fondo compartido #F5F5F7, filas rectas de altura mínima48,
icono de ubicación y texto13 de la fuente común. El panel conserva el ancho del
campo, separación8 y scroll hasta320px, limitado por teclado/área segura. Abre
hacia arriba si falta espacio debajo y hay más arriba. Skeleton/shimmer de
consulta dentro del mismo panel, sin ocupar espacio en el formulario.

Solo se muestra con foco, campo habilitado y consulta real o resultados.
Seleccionar actualiza etiqueta/callback y cierra; tocar fuera permite la acción
exterior y cierra/invalida consultas pendientes. Escape y retorno cierran el
desplegable. OverlayPortal retira el panel al desmontar. TapRegion conserva el
foco al interactuar con las opciones. Sin nuevos efectos de entrada por escritura.

## Fronteras y consecuencias

Comportamiento visual dentro de places/presentation; mismos ViewModel, casos de
uso, fuente y política de Perú de ADR-107. AppTextField permite recibir FocusNode
externo y conserva el foco propio por defecto; no dispone nodos ajenos. Sin SQL,
backend, dependencias nuevas ni ampliación/cierre de historias.

## Validación

Pruebas de geometría sin desplazamiento durante consulta/resultados, scroll y
selección normal/320×350 con texto2, ajuste ante teclado de300px, cierre exterior,
respuesta tardía y desmontaje. Regresiones de Explorar (incluido panel flotante
anidado), Reportar, Perfil, places y arquitectura; evidencia en ESTADO. Renders
normales/pequeños en build/ui-preview/place-overlay. Android real pendiente.
