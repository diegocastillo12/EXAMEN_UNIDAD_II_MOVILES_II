# Buscador compartido de ubicaciones y ciudades

Corrección16 de octubre: por instrucción explícita del usuario, se retiran créditos/enlace visibles del proveedor y el mensaje de fallo asociado. Aplica al componente compartido tanto en Ubicación como en Ciudad del perfil; búsqueda/selección conservadas.

Módulo places, extraído el16 de octubre de2026 para Explorar (HU-07/RF-13) y Perfil (HU-01.7/RF-01). [ADR-051](../decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

## Qué hace y recorrido

Sugerencias al escribir3–120 caracteres tras pausa600ms. En Ubicación busca ciudad/dirección para elegir centro del mapa; en Perfil solo ciudades/asentamientos para confirmar Ciudad. Selección explícita, cinco resultados, campo editable mientras consulta, sin botón de búsqueda; teclado admite envío inmediato cuando no hay otra petición.

## Reglas, persistencia y permisos

Dominio/DTO/fuente Photon/repositorios/providers/ViewModel/widget únicos. Modo ciudad solicita layer=city y descarta tipos incompatibles/etiquetas mayores120; nombre/región/país. Caché30 consultas/5min en memoria, separada por modo; sin historial persistente. Solo el texto escrito se consulta al proveedor, sin sesión/tokens/datos privados. Perfil guarda etiqueta elegida, no coordenadas; su ciudad anterior se conserva hasta modificar/seleccionar/vaciar.

Router compone el buscador en slots de ambas funcionalidades; sin imports entre sus presentaciones. PLACE_SEARCH_URL mantiene endpoint HTTPS configurable. Atribución enlazada OpenStreetMap y condiciones de demo Photon conservadas; no acredita cobertura oficial o servicio de producción.

## Errores y reintentos

Toast superior para errores, skeleton/shimmer en consulta real. Una petición vigente por campo; editar cancela la anterior y la última empieza sin esperarla; editar/seleccionar/limpiar/cambio de identidad/desmontaje invalidan respuestas y cancelan temporizadores. No se inventan resultados. Perfil no admite guardar texto nuevo sin selección; se permite vaciar valor opcional y conservar datos anteriores.

## Activación y validación

Sin SDK/clave/migración nueva para el buscador. Inyección de places desde bootstrap/main. Formato/análisis sin incidencias, contratos/fixtures adaptados sin ejecutar pruebas por petición del usuario. Pendiente Android: ambos modos, ciudades reales del proveedor, selección/descartar, fallo/reintento, texto ampliado y cambio de cuenta. No se hicieron consultas reales ni se garantiza disponibilidad futura.

## Buscador en reportes y sugerencias de Perú —20/10/2026

ADR-107: Reportar reutiliza places antes del mapa para pérdida propia/comunitaria
y avisos de hallazgo. Elegir sugerencia marca/centra el punto privado mediante
el ViewModel del reporte; después se ajusta tocando el mapa. Buscar es opcional
y no rellena la referencia privada. App compone el slot de presentación y aísla
el ViewModel del reporte para no compartir sugerencias con Explorar bajo la ruta.

Todos los modos (también Explorar y Ciudad del perfil) piden countrycode=PE y
descartan sugerencias con código ausente/distinto de PE, aunque su etiqueta diga
Perú. El mapa conserva navegación/selección libres. No restringe publicación
por territorio ni modifica ciudades anteriores del perfil. Sin SQL, configuración
adicional o credenciales nuevas; depende del proveedor HTTPS ya inyectado.
Fallos conservan toast/reintento; resultados vacíos permiten editar/reenviar o
usar el mapa. Precisión pública y permisos del reporte se conservan.

Validación:24 pruebas places/arquitectura/creación por rutas reales aprobadas,
con selección y ajuste sin rellenar referencia privada. Renders390×844/texto1
y320×350/texto2 revisados sin overflow; teselas bloqueadas por el harness.
Consulta real Tacna/PE devolvió cinco resultados PE. Android y cobertura real de
direcciones pendientes; no acredita cierre de HU.
Véase [ADR-107](../decisiones/107-busqueda-reportes-y-sugerencias-peru.md).

## Sugerencias flotantes —20/10/2026

Por corrección del usuario, el campo muestra una lista continua superpuesta,
sin cápsulas individuales y sin desplazar radio/mapa/campos. Un solo panel del
ancho del input, filas mínimo48px, icono/texto comunes, máximo320px con scroll.
Respeta teclado/área segura y abre arriba cuando hay más espacio. Consulta real
muestra skeleton/shimmer dentro del panel; errores siguen en toast superior.
Se abre con foco y resultados/consulta; elegir cierra y conserva el callback.
Tocar fuera cierra/invalida pendientes y permite la acción exterior; Escape y
retorno cierran. Desmontar elimina overlay y libera foco. Aplica a Reportar,
Explorar y Ciudad; filtro Perú y persistencia/permisos de ADR-107 conservados.
[ADR-108](../decisiones/108-sugerencias-ubicacion-superpuestas.md).

## Respuesta reciente y cancelación —20/10/2026

ADR-109 sustituye la espera600ms y cola serial: debounce300ms; editar cancela
inmediatamente la petición anterior y la última empieza sin esperar su respuesta.
Señal por operación desde ViewModel/caso de uso/repositorio hasta aborto HTTP;
no afecta otros campos. Selección, cierre, cambio de cuenta y desmontaje cancelan.
Consultas activas idénticas se deduplican; respuestas/errores tardíos se ignoran,
resultados cancelados no entran en caché. Se conservan PE, modos Ciudad/dirección,
caché30/5min, toast/shimmer, panel flotante y reintento. No requiere activación.

Pruebas verifican arranque exacto a300ms con petición anterior pendiente, ambos
modos, aborto del transporte, descarte tardío/caché y limpieza. La latencia del
proveedor observada desde este entorno fue5,6–9,75s: no garantiza menos3s.
Android y tiempos desde la red del usuario pendientes.
[ADR-109](../decisiones/109-buscador-cancelacion-y-respuesta-reciente.md).

## Corrección de errores y búsqueda parcial —20/10/2026

Regla vigente ADR-110: restaurar600ms por instrucción del usuario; mantener
cancelación inmediata y última consulta sin cola. Fuente acepta texto parcial:
la prueba real `tacn` devolvió cinco lugares PE/Tacna a13,42s; `tacna` a14,37s.
El timeout12s descartaba respuestas válidas: presupuesto ampliado a20s con
aborto al vencer. GET anterior y petición cancelable tardaron ambos13,9s y
devolvieron los mismos datos. No se añade igualdad del nombre ni comodines.
Consulta, país y modo siguen llegando intactos al servicio. Sin reintentos
automáticos ni cambio de proveedor. Errores reales conservan toast/reintento;
no se confunden con vacío confirmado. No promete reducir latencia del servidor.
Pruebas con respuesta válida a15s y aborto a20s; Android pendiente.
[ADR-110](../decisiones/110-buscador-parcial-y-tiempo-de-respuesta.md).
