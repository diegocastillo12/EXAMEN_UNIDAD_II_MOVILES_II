# Explorar: lista y mapa de casos

Excepción local20/10/2026, por petición explícita: el nombre de la ficha del
caso sobre fotografía conserva su diseño anterior a ADR-111: fuente del sistema,
blanco, tamaño48/peso800, altura1.05 y sombra negra suave, máximo dos líneas con
elipsis. Sin cápsula blanca. Solo CasePublicationPreview; los demás títulos
conservan Poppins400/32/gris. Acciones, panel y datos intactos.

Corrección20/10/2026: nombre principal de Ver ficha directamente sobre la
fotografía, sin cápsula blanca ni padding añadido. CasePublicationPreview
conserva Poppins400/32/gris, texto completo y scroll. Ajuste solicitado por el
usuario; sin cambios de datos, permisos o acciones.

Alineación20/10/2026: CollectionHeader ancla el título al borde superior de
la fila, conservando mínimo56 y espacio de acciones. Explorar y Mis mascotas
comparten la posición inicial de «Su regreso»; se elimina el desplazamiento8
por centrado vertical. Regresión de navegación con fuentes reales en390×844
y320×350/texto2 aprobada. Sin cambio de tipografía, datos o permisos.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

Título de sección20/10/2026: «Explorar» usa sans-serif del sistema, tamaño32,
peso400 y gris #454746, por petición del usuario para igualar «Su regreso».
Estilo compartido con Mis mascotas; conserva geometría y texto ampliado.
Sin cambios de datos/permisos; revisión visual Android pendiente.

**Panel vigente20/10, ADR-106:** puede bajarse hasta resumen/Ver ficha completo,
antes del separador. Mínimo según altura real +tirador32 +inset inferior+12;
apertura50% o mínimo si requiere más con texto ampliado, máximo90%. Scroll,
resistencia, selección y ficha conservados. Créditos fuente8/objetivos48 arriba
del panel a la derecha, siguiendo su posición; tooltip/nombre completo si se
elide al ampliar texto. Título central se retira si falta espacio, retorno
conservado. Sustituye mínimo50%/atribución superior de notas anteriores.
Sin cambios de persistencia/permisos/activación; paleta global ADR-104 intacta.
Movimiento refinado: acomodo al soltar/subir/bajar con resorte amortiguado
1/260/34, conservando impulso del gesto y cancelándose al contacto siguiente;
sustituye easeInOutCubic320–540ms. Retorno amortiguado bajo el mínimo.
Durante arrastre sigue al dedo; gesto nuevo cancela el acomodo anterior y los
toques en acciones no lo disparan. Reduced mantiene acciones inmediatas y
sin acomodo autónomo; contenidos conservan scroll/inercia.
Validación del movimiento:6 pruebas de mapa (posición intermedia, convergencia,
impulso rápido, interrupción al contacto y cambio de dirección) y10 de arquitectura
aprobadas; repetición de6 con CARTO/capturas aprobada, formato/análisis
completos limpios. Pendiente evaluar sensación real en Android físico.
Validación de ADR-106:17 pruebas de mapa/selector/arquitectura aprobadas con
teselas CARTO de fixture, análisis limpio y renders390×844/320×350/texto2
revisados. Gesto minimiza conservando Ver ficha visible y crédito sobre panel;
selección/pan/retorno comprobados. Revisión física Android pendiente.

Cartografía vigente20/10, ADR-104: acabado intermedio Reportar/Explorar global
móvil/web desde adaptadores comunes. Se retira la matriz exclusiva de Explorar;
ver [ficha compartida](cartografia-compartida.md). Panel50–90% conservado.

Color vigente20/10: segunda captura aportada sustituye el amarillo hueso por
blanco grisáceo apenas cálido (#F6F6F2 en gris245, blanco #FFFFFB). Contraste
de teselas mayor que el filtro anterior; símbolo oficial/créditos sin filtro.

**Diseño vigente20/10, ADR-103:** mapa sin disco del radio, pines de ubicación
con símbolo oficial y selección negra/blanca. Panel50–90% con miniatura112×112,
nombre y rasgos públicos como descripción (se omite si falta), flecha circular
azul con acabado compartido de navegación y Ver ficha gris. Ambos abren la misma
ficha desde su origen, con bloqueo de aperturas duplicadas; detalles verticales
de tamaño/especie/fecha.
Elección final20/10: inicio/mínimo50%, sustituyendo60% por ser demasiado alto.
Cámara/colapso/selección acompañan la altura; fecha accesible mediante scroll
cuando no cabe. Revisión física Android pendiente.
Validación del ajuste50%:6 pruebas de mapa aprobadas y análisis de pantalla/widget
sin incidencias; conserva acceso por scroll también con texto ampliado.
Espaciado corregido20/10:16px desde título a datos y entre filas, separador
con16px verticales por lado; conservar agrupación etiqueta/valor y scroll.
Conserva consulta por radio, permisos, paginación, toast/reintento, shimmer,
vacío y scroll. Sin activación o persistencia nuevas.
Refinamiento posterior20/10: título Explorar en cápsula glass, foto112px y mapa
blanco grisáceo apenas cálido (claro orientativo #F6F6F2) solo en teselas. Seleccionar acerca a zoom15 desde vistas
más amplias, conservando zoom superior y navegación manual; consulta intacta.
Corrección de color20/10: amarillo hueso en lugar del gris; claro #F7F5EB y
blancos #FFFDF3.6 pruebas de mapa y análisis del archivo aprobados; captura
normal revisada con teselas neutras, cartografía real en Android pendiente.
Validación del refinamiento:16 pruebas de mapa/selector/arquitectura aprobadas,
análisis limpio y capturas normales/texto2 revisadas con teselas neutras. Foto
mayor puede requerir scroll para leer la fecha en el panel mínimo. Pendiente
comprobar aspecto de calles reales en Android, sin nueva activación remota.
Sustituye foto4:3, fila horizontal, CTA fijo y mínimo42% de notas previas.
[ADR-103](../decisiones/103-mapa-resumen-compacto-referencia-aprobada.md).

Validación de ADR-103:43 pruebas de mapa/preview/Home/arquitectura/selector de
ubicación/Explorar aprobadas en serie, formato/diff correctos y análisis limpio.
Renders390×844 y320×350/texto2 revisados con teselas neutras; cartografía real y
revisión visual Android pendientes. No implica cierre de HU-07.2/issue #33.

Panel sin selección19/10/2026: reutiliza CollectionEmptyState de core con la
misma huella88, título20/semibold y descripción16 del vacío del listado.
Con resultados: Selecciona un pin y la instrucción de ver el resumen; con vacío
confirmado: No encontramos casos y sugerencia de ajustar ubicación/filtros.
Conserva instrucciones específicas cuando falta ubicación o procede reintentar,
scroll/expansión42–90% y resumen/Ver ficha al seleccionar. Sin persistencia,
permisos o activación nuevos. Análisis limpio y15 pruebas de mapa/arquitectura
aprobadas; capturas normales/pequeñas con texto2 revisadas. Android pendiente.

**Acceso Mapa vigente19/10, ADR-101:** se retira la fila Lista/Mapa. Cápsula
glass flotante Mapa sobre la navegación, fija al desplazar, mínimo48px y20px
de separación de la barra. Padding final permite descubrir la última tarjeta.
Solo Explorar con estado consultado; busy bloqueado, sin acceso durante carga
inicial/error sin datos. Mismo mapa, filtros/resultados, expansión desde el
botón real y retorno con scroll conservado. Router compone slot visual de Home,
sin dependencia de presentación entre módulos ni nueva activación/persistencia.
Validación:36 pruebas de Home/Explorar/mapa/arquitectura aprobadas; análisis
completo, formato y diff correctos. Capturas normales/pequeñas con texto2
revisadas; revisión física Android pendiente.
[ADR-101](../decisiones/101-mapa-acceso-flotante-explorar.md).

**Controles compactos19/10, ADR-100:** Ubicación muestra lugar/radio en línea
y ocupa el espacio restante junto al icono circular Filtrar casos48×48, sin
texto visible ni chevrón. Tooltip/nombre accesible y estado expandido conservados.
Fila48px con texto normal; lugar largo elidido con tooltip completo, texto
ampliado aumenta altura cuando hace falta. Mantiene áreas táctiles48px,
paneles de ancho completo, borradores, cierre/Aplicar y shimmer/reintento.
Sin nuevas dependencias, persistencia, permisos o activación.25 pruebas de
Explorar/arquitectura/navegación de mascotas aprobadas; análisis y formato
correctos, capturas normales/pequeñas revisadas. Revisión física Android pendiente.
[ADR-100](../decisiones/100-explorar-controles-compactos.md).

**Corrección vigente19/10, ADR-099:** el resumen del mapa muestra el tipo de
mascota (Perro/Gato/Otra especie), no raza; fallback seguro si falta. Foto mayor,
a ancho completo4:3, sin altura136px. Se retiran Abierto/Resuelto y conteo de
casos/ubicaciones del panel. Cada caso tiene su propio pin; los solapamientos
se separan en píxeles sin cambiar coordenadas públicas ni consulta. Sin contador,
1 de2 o flechas; tocar un pin actualiza su resumen y Ver ficha abre su detalle.
Filtros en Explorar, scroll/panel, paginación/reintento y permisos conservados.
Sin activación remota o nueva persistencia.22 pruebas mapa/preview/arquitectura/
ZoneMapPicker aprobadas; análisis completo y formato correctos; capturas390×844
y320×350/texto2 revisadas. Android de este ajuste pendiente.
[ADR-099](../decisiones/099-mapa-pines-individuales-y-resumen-fotografico.md)
sustituye las menciones a raza/agrupación/contador/estado del resumen anteriores.

**Recorrido vigente19/10 (ADR-097):** configurar filtros y Ubicación únicamente
en Explorar; Mapa muestra la misma consulta. Al tocar un pin, su resumen público
aparece en el panel inferior (foto, nombre, tamaño, raza no registrada, fecha y
estado) con Ver ficha hacia el detalle existente. Sin callout duplicado ni editor
inferior. Coincidencias anterior/siguiente,42–90%, CTA fijo cuando cabe o por
scroll en altura pequeña, retorno, paginación/reintento y refresco conservados.
Sin selección se pide elegir un pin. Filtros/resultados se conservan al volver.
Persistencia/permisos/dependencias sin cambios; sin nueva activación remota.
19 pruebas mapa/preview/arquitectura, análisis completo limpio y capturas locales
normales/pequeñas con texto2 revisadas. Android de este cambio pendiente.
[ADR-097](../decisiones/097-explorar-filtros-unicos-y-resumen-en-mapa.md)
sustituye la disposición anterior de filtros/callout descrita abajo.

19/10/2026: título Explorar en peso500 mediante CollectionHeader compartido,
por petición del usuario para igualar el peso de Inicio web. Tamaño32 y
composición existentes conservados. Revisión visual Android pendiente.

Corrección19/10 (ADR-094): entrada única de sección, sin cover previo ni timeline
exterior activo desde Inicio. Skeleton y resolución de consulta conservan el
stagger ya iniciado; no nuevo envío ni vacío intermedio por transición. Regresión
de90 frames confirma una consulta y misma instancia de shimmer, con/sin movimiento
reducido. Sin cambios de filtros/datos/permisos; Android del ajuste pendiente.

Ajuste visual19/10: [cartografía móvil](cartografia-mobile.md) usa CARTO Positron
en la configuración local, con crédito enlazado compartido y pines originales
conservados. No cambia filtros, permisos ni consultas. ADR-084; revisión Android
del nuevo estilo pendiente, independiente de la evidencia funcional anterior.

**Auditoría de seguimiento18/10:** HU-07/#7, lista #32 y mapa #33 en Done: integración y recorrido Android/Supabase real del16/10 con3 casos y filtro Gato, más pruebas/CI. No se conserva un genérico Android aún no revisado; volumen/QA ampliado queda como tal. Guardados offline #49 no está implementado.

Revisión18/10 durante HU-10.1:33 pruebas focalizadas mapa/preview/Explorar/
arquitectura aprobadas. Attach+hot restart con configuración local sobre la
instalación Android existente: consulta Photon Lima/15km, dos casos reales,
fotos/teselas, selección de pin→foto/tamaño/fecha→ficha→retorno y arrastre del
panel. Evidencia apps/mobile/build/hu10-map-preview.png, hu10-map-expanded.png y
XML de navegación; revisión visual del preview confirmada. No es APK nuevo ni
arranque frío. Continúan permisos/volumen/concurrencia hosted y Android físico;
no cierra HU-07 ni modifica los cambios previos de su implementación.

Corrección de composición18/10: foto principal arriba a ancho completo y nombre
debajo; tamaño, raza y fecha en una fila de tres datos con iconos. La fila se
desplaza horizontalmente cuando el texto ampliado requiere más ancho; la tarjeta
permite scroll vertical en poco espacio. Sin cambios de consulta o permisos.
Regresiones verifican foto por encima de los datos y alineación de sus iconos,
además de lectura/acceso con texto2 y panel mínimo42%. ADR-062 actualizado.

Pines/vista previa18/10/2026: marca original only-black.svg en cada pin y contador
superpuesto para coincidencias. Seleccionar abre una etiqueta tocable con foto
principal, nombre, tamaño y fecha local del suceso; sin texto visible Abrir caso.
La fecha distingue desaparición/encuentro/avistamiento. Raza no se registra aún:
se informa Raza no registrada, sin inferirla. Tamaño/foto se completan consultando
la ficha pública seleccionada mediante caso de uso/ViewModel autoDispose; no
consulta el catálogo ni la mascota privada. Fallo usa toast con Reintentar;
cambio de cuenta oculta resultado anterior. Datos ampliados desplazables y
controles de coincidencias fuera del scroll; cámara reserva panel mínimo42%.
Sin SQL/permisos nuevos. [ADR-062](../decisiones/062-pines-de-marca-y-vista-previa-publica.md).

Estado vacío18/10/2026: una consulta confirmada sin resultados muestra
CollectionEmptyState de core, extraído de Mis mascotas: misma huella88,
título20/semibold, descripción16, centrado y espaciados. Texto: No encontramos
casos; Prueba con otra ubicación o ajusta los filtros de búsqueda. Sustituye
la línea No hay casos con estos filtros. Se conservan controles superiores,
sin nueva acción duplicada. Carga, fallo y falta de ubicación siguen estados
distintos; sin cambios de consultas/permisos. Regresión y renders normal/pequeño
con texto2 compartidos con Mascotas; revisión Android pendiente.

Mapa18/10/2026: panel inicial/mínimo42%, máximo90%. Ya no baja al14% al tocar
pines; cámara/etiqueta reservan el panel normal. Arrastrar bajo el mínimo produce
solo resistencia visual hasta18px y vuelve al soltar. El retorno glass se
desvanece y sube en el tramo final de expansión, recuperándose al bajar; oculto
no recibe acciones. Movimiento reducido evita desplazamientos/rebote. Se retira
Filtros de búsqueda, conservando campos, borrador y Aplicar filtros. Sin cambios
de consulta, persistencia/permisos; ver ADR-061. Gesto, pines, aplicar, detalle y
retorno probados localmente; cartografía real/fluidez Android pendientes.

Corrección posterior18/10/2026: CollectionHeader comparte altura mínima56 en
la fila del título, independientemente de que la acción mida48 (Guardados) o56
(añadir mascota). Elimina la diferencia vertical4px con Mis mascotas sin
compensaciones por pantalla. Regresión integrada con fuentes reales compara
origen de ambos textos en carga/datos y durante90 fotogramas, en390×844 y
320×350/texto2. Conserva una sola entrada y consulta inicial.

Corrección18/10/2026: Explorar controla una sola entrada cover→stagger de su
contenido, con cabecera persistente. Home desactiva su transición exterior
cuando compone esta sección real, evitando dos efectos simultáneos sobre el
skeleton. La carga y su resolución no cambian la etapa. Regresión de entrada
desde Inicio confirma una consulta inicial, misma instancia de shimmer durante
90 fotogramas y contenido visible al terminar, con/sin movimiento reducido.
Sin cambios de consulta, dominio, permisos o SQL; revisión Android pendiente.

Revisión del mapa (16 octubre): filtros combinados en el panel inferior y confirmación explícita en Aplicar filtros, con formulario compartido con la lista. GPS, ciudad/dirección, centro visual y radio son borrador hasta aplicar; sin segundo mapa en el panel. Botón fijo si cabe y dentro del scroll al reducir altura. No hay caso seleccionado al entrar: pulsar pin reduce panel y muestra nombre/Abrir caso junto al punto; coincidencias se recorren allí de una en una. Tocar fondo retira etiqueta; aplicar otra consulta la limpia y recupera el panel42%. Se abre la ficha existente, no un cartel PDF nuevo. Texto real de lugar/nombre de centro sobreviven a refresh/paginación y actualizan Ubicación al volver a la lista, separados de datos sintéticos del input. Errores/reintentos/toast, geografía pública aproximada y cuenta protegida conservados. [ADR-056](../decisiones/056-mapa-filtros-inferiores-y-acceso-en-pin.md) sustituye ficha inferior/selección inicial de ADR-055. Sin SQL ni nueva persistencia; revisión Android pendiente.

Validación de esta revisión: análisis global limpio y353 pruebas aprobadas, incluyendo borrador/GPS sin consulta, aplicación explícita, metadatos tras refresh/paginación, descarte por cambio de cuenta, mini etiqueta y recorrido completo de ficha/retorno. Renders finales normales/pequeños con texto ampliado y movimiento reducido revisados: build/map-filters-final-renders.log y build/ui-preview/explore-map. Teselas de prueba neutras; revisión Android/servicio real pendiente, sin APK ni publicación.

Mapa en pantalla propia (16 octubre, sustituye la alternancia integrada): Mapa expande desde su opción y ocupa el viewport; volver con control glass restaura Explorar. Conserva exactamente consulta, filtros y páginas sin nueva búsqueda al entrar/salir. Panel inferior deslizable inicialmente42%, ajustable14–90%, con tirador persistente y acciones accesibles. Una ficha de ancho completo, nombre y Ver ficha; coincidencias usan anterior/siguiente. Primera ubicación cargada seleccionada inicialmente; marcador cambia selección y recupera panel reducido. Paginación/reintento en panel y refresh al volver de ficha. No cambia búsqueda al mover cámara ni expone coordenadas privadas. Sin SQL, nueva persistencia o dependencia; [ADR-055](../decisiones/055-explorar-mapa-inmersivo-y-panel-deslizable.md). Revisión Android pendiente.

Validación del mapa inmersivo: análisis limpio,351 pruebas de la suite aprobadas y11 de acceso/onboarding con la nueva ruta. Pruebas normal/pequeña verifican origen real, consulta/páginas/cursor, no duplicación al navegar, detalle/retorno, arrastre del panel, agrupaciones y pan sin editar. Capturas con teselas neutras: build/ui-preview/explore-map/screen-normal.png y screen-small.png; revisión de cartografía real y movimiento Android pendiente. La tarjeta reutilizada oculta el título interior cuando el panel ya presenta el nombre.

Selección aplicada visible (16 octubre): la cápsula de Ubicación muestra el nombre completo de la ciudad/dirección elegida con elipsis visual y tooltip, más radio en km. GPS indica Ubicación actual; una selección manual aplicada indica Punto del mapa. El nombre del centro se mantiene separado del texto del buscador, sin rellenarlo con etiquetas sintéticas. Editar sin aplicar no cambia la cápsula; Filtrar casos conserva nombre y variante. Estado de presentación de la sesión de pantalla, sin nueva persistencia ni consulta geográfica inversa.

Refinamiento de cierre (16 octubre): ambas variantes usan salida de 320 ms con contracción/retirada suave, fundido diferido y recuperación del fondo coordinada. Cancelar durante apertura conserva el progreso sin salto; portal hasta final y movimiento reducido inmediato. Sin cambios en filtros ni guardado de selección. Pruebas de interrupción para ambas variantes incluidas; revisión de movimiento en dispositivo pendiente.

Variantes del selector (16 octubre): Ubicación usa el panel `atOrigin`, alineado al borde superior de su cápsula y superpuesto a ella, con la animación original del selector, sin transición de página desde el origen. Filtrar casos conserva `below`, la variante principal. Ambas mantienen ancho completo, scroll, blur, cierre exterior/atrás y aplicación explícita; cancelar descarta cambios. Etiquetas centradas con espacios equilibrados para iconos. Sin cambios en consultas, permisos o persistencia.

Ajuste del panel Ubicación16 de octubre: título Ubicación de búsqueda, acción de ubicación actual, Ciudad o dirección, radio/deslizador, mapa y Aplicar ubicación. Se retira Centro y la explicación del mapa; tampoco se rellena el input con Punto elegido en el mapa/Ubicación actual/Ubicación seleccionada. Selección manual y radio conservan coordenadas reales; elegir una ciudad mantiene su etiqueta. Se conserva la eliminación previa del texto explicativo que ya estaba en el archivo al iniciar este ajuste. Sin SQL nuevo.

Corrección posterior16 de octubre: por instrucción explícita del usuario, se retiran créditos/enlaces visibles del proveedor y su feedback. El mapa conserva puntos, selección, filtros y recuperación de teselas; sustituye la mención anterior de atribución visible.

Resultado final16 de octubre:04b3a13 publicado; Flutter38947608248 aprobado en Linux con339 pruebas, formato y análisis. Recorrido Android real y limitación de APK documentados abajo y en ESTADO.

Seguimiento16 de octubre: CI Linux de c727b2f aprobado con339 pruebas, formato y análisis. Recorrido autenticado en emulador Android16 sobre la instalación debug existente, actualizado por attach/hot restart: ubicación manual real Photon/Lima,3 casos con fotos y teselas reales en ambas vistas, selección→ficha→retorno y filtro Gato con1 resultado coincidente. Se corrige el singular del contador. Capturas/evidencia en ESTADO. Gradle falla al construir APK nuevo por conexión local de Java; no se acredita instalación/arranque frío nuevos. Pendientes Android físico, denegación explícita, fallo controlado de teselas, volumen y permisos/concurrencia hosted; no se cierra historia.

## Incremento vigente: mapa de resultados — 16 de octubre de 2026

HU-07.2 / RF-13 / issue #33 implementada localmente en `feature/explore-case-map`. Lista/Mapa reutiliza TwoOptionFilter y cambia de vista con cover→stagger; cabecera y filtros se conservan. Ambas vistas observan exactamente la misma consulta y páginas, sin nueva petición al alternar. Ver más casos añade resultados a ambas; el contador del mapa describe los casos consultados, sin prometer todos los del área.

El mapa permite pan/zoom sin cambiar filtros ni centro. Ubicación continúa siendo el editor de centro/radio, con selección manual disponible sin GPS. Los puntos usan coordenadas públicas aproximadas ya recibidas; coincidencias se agrupan y muestran las tarjetas compartidas debajo del mapa. Cada tarjeta abre la ficha existente y el retorno refresca la misma consulta. El origen diferencia UUID iguales. La vista se conserva durante filtros/refresco/reintentos y se reinicia al cambiar de cuenta.

Carga inicial/consulta nueva conserva skeleton y shimmer; refresh de la misma consulta conserva contenido. Error de consulta vacío no se presenta como resultado confirmado. Fallo de teselas usa toast y Reintentar mapa de ZoneMapPicker; fallo del enlace de atribución usa toast. Reintentar recrea proveedor/mapa y ajusta cámara al radio. No hay escrituras, SQL nuevo, seguimiento continuo ni descarga offline.

Dependencias: backend019 y fotos operativos, igual que la lista;020/021 corresponden a Guardados y su aplicación está confirmada por el usuario. Mapa usa MAP_TILE_URL/flutter_map y atribución OpenStreetMap visible; disponibilidad, caché y condiciones antes de distribución en [ADR-052](../decisiones/052-explorar-mapa-de-resultados.md). La nota anterior de HU-07.2 pendiente queda sustituida por esta implementación local.

Validación: pruebas de paridad de consulta/páginas, errores/reintentos/filtros, agrupación por ubicación con orígenes distintos, apertura de tarjetas y navegación sin editar centro; renders normal/pequeño con texto2/movimiento reducido revisados con teselas neutras de prueba. Sin demo Android/hosted ni cierre de historia. Resultados completos en ESTADO.

Confirmación del usuario16 de octubre: patch021 aplicado y recorrido de guardar/Guardados probado con resultado correcto («ya esta el patch ese, si permite guardar ya lo probe y todo esta bien»). Sustituye el pendiente de activación021 en notas anteriores; evidencia comunicada por el usuario, sin inspección remota independiente ni certificación adicional de permisos/concurrencia.

Corrección de recarga16 de octubre: PullToRefresh usa Stack sin recorte para que el indicador glass que entra desde coordenadas negativas no quede cortado durante el descenso/retirada. En Home envuelve toda la composición, incluida LiquidNavigation, y pinta el indicador al final sobre cabecera/contenido/acciones. Sin cambiar gesto, material o tiempos. Formato y análisis estático sin incidencias; sin pruebas/renders/build por instrucción vigente, revisión visual Android pendiente.

Corrección16 de octubre: el guard de sesión del router omitía /home/saved-cases y redirigía a /home al pulsar el marcador. Se permite explícitamente esa ruta solo cuando EntryDestination.home está resuelto; acceso/onboarding/recuperación mantienen sus controles. Se conserva OriginPageTransition existente. Formato y análisis estático de router sin incidencias; sin pruebas por instrucción del usuario y sin verificación Android. Pendiente revisar apertura/retorno en dispositivo;021 sigue pendiente para cargar el listado.

Ajuste vigente del16 de octubre: el marcador compacto de Explorar abre la pantalla independiente Guardados en /home/saved-cases. Reutiliza OriginPageSource/OriginPageTransition mediante entityEditorPage: expansión desde el icono y retorno al origen al cerrar, con movimiento reducido respetado. Sustituye el cambio de vista en la cabecera y la segunda pulsación. SavedCasesScreen reutiliza EntityScreenShell con retorno glass y cover→stagger, SavedCasesSection y PullToRefresh; scroll siempre desplazable incluso con lista vacía. Explorar permanece debajo con filtros/posición conservados. Sin cambios SQL;021 sigue pendiente de aplicación y revisión Android.

Módulo `explore`. HU-07.1 / RF-13 / issue #32; implementación local. [ADR-039](../decisiones/039-explorar-lista-publica-paginada.md).

**Presentación vigente, última corrección del 15 de octubre:** una sola insignia de estado Abierto/Resuelto en la imagen; debajo, nombre (Sin nombre si falta) y distancia aproximada desde el centro elegido: A 4 km o A menos de 1 km. Sin especie, fecha ni badge de tipo. Sin distancia del servidor se omite esa línea. Filtros anclados debajo de su cápsula y superpuestos a las cards, con scroll independiente; fuera/Atrás cancela y Aplicar confirma. [ADR-043](../decisiones/043-explorar-desplegable-anclado-y-distancia.md) sustituye las variantes visuales históricas descritas abajo. No se ejecutan pruebas ni renders para este último ajuste por instrucción del usuario; pendiente revisión Android.

## Qué hace y recorrido

**Vistas actuales:** Marcador compacto junto al título para abrir Guardados, sin selector de secciones. Marcador lleno/título Guardados identifica esta vista; pulsarlo otra vez vuelve a Explorar. Cabecera persistente en una fila, área táctil48/icono24 y cover→stagger en cambio discreto. Guardados compuesta por router con saved_cases, misma grilla core, paginación/refresco y fichas; solo marcas privadas disponibles, sin radio/GPS. Cercanos conserva filtros/centro durante el cambio. El buscador de Ubicación ahora pertenece a places y llega por slot. Guardados requiere021 tras020; sin aplicación/pruebas de021 ni verificación Android. [ADR-051](../decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

Indicador de recarga (ajuste16 de octubre): mismo material glass del retorno, con GlassSurface52/radio26/icono28. Mantiene seguimiento del jalón, giro y retirada; sin botón permanente. Formato/análisis sin incidencias; sin pruebas/renders por instrucción del usuario, revisión Android pendiente.

**Distribución vigente,16 de octubre:** Ubicación a la izquierda y Filtrar casos a la derecha en la misma fila, sin disposición vertical. Cápsulas compactas, etiquetas/fuente/área táctil conservadas y altura adaptable; se omiten iconos iniciales cuando falta espacio. Los paneles siguen usando todo el ancho, anclados a sus extremos respectivos. Se conservan selección, búsqueda, radio y transición. Formato/análisis estático, sin pruebas ejecutadas por instrucción vigente; revisión visual Android pendiente. Sustituye las notas históricas de apilado.

Indicador de gesto actualizado: icono de recarga que baja siguiendo el dedo, se acomoda al soltar, gira durante refresh y se retira al terminar/cancelar; conserva filtros y shimmer del contenido. Movimiento reducido sin giro/retorno animado. [ADR-049](../decisiones/049-indicador-recarga-y-retorno.md). Formato/análisis del componente sin incidencias; sin nuevas pruebas ejecutadas ni revisión Android.

**Actualizar vigente:** jalar hacia abajo desde el borde superior y soltar reemplaza el icono Actualizar casos. Conserva centro/radio/filtros, renueva primera página y mantiene contenido con shimmer; lista vacía/corta permite gesto y cancelar antes del umbral no consulta. Reintento de fallo conservado. [ADR-048](../decisiones/048-actualizar-listas-al-jalar.md). Formato/análisis sin incidencias; sin pruebas ejecutadas, gesto Android pendiente.

**Ubicación vigente:** Explorar intenta usar ubicación actual con radio inicial15km. Sin permiso/servicio/posición disponible, aviso superior y elección manual por buscador/mapa, sin consulta global ni falso vacío. Ubicación reemplaza Zona; se retiran Todas las ubicaciones y Por ubicación. Centro/radio obligatorios para consultar;1–50km ajustable, otra dirección manual y Usar mi ubicación actual conservan filtros. Permiso aproximado de primer plano, sin seguimiento ni persistencia de ubicación del dispositivo; centro enviado como parámetro de consulta a Supabase y no a Photon. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md) sustituye los valores iniciales/ausencia de GPS anteriores. Formato/análisis sin incidencias, sin pruebas ejecutadas por petición del usuario; recompilación y revisión Android pendientes.

**Búsqueda de ubicación vigente:** al escribir al menos3 caracteres se consultan sugerencias tras600ms de pausa, sin botón Buscar ubicación. Campo siempre editable; solo una solicitud activa y una consulta pendiente más reciente. Editar/limpiar/seleccionar/cambiar cuenta/desmontar invalida respuestas anteriores y cancela esperas. Seleccionar resultado centra mapa; escribir no aplica filtros ni elige centro. Errores en toast y mapa manual conservados; sin toast por cada vacío de sugerencias automáticas. El teclado permite búsqueda explícita cuando no hay otra en curso. Texto se envía al proveedor después de la pausa. [ADR-046](../decisiones/046-sugerencias-automaticas-de-ubicacion.md) sustituye las notas históricas de búsqueda exclusivamente explícita. Sin nuevas pruebas ejecutadas por instrucción vigente.

**Distribución vigente:** Filtrar casos contiene solamente tipo, especie, estado y fecha. El control independiente Zona (Zona de búsqueda en disposición vertical) abre ciudad/dirección, mapa y radio, con Aplicar zona. Los controles se disponen en fila cuando caben y en vertical con ancho reducido/texto ampliado; los paneles usan todo el ancho del área disponible. Cada aplicación conserva los valores confirmados del otro control; cerrar descarta solo el borrador. Sin nuevas consultas por abrir/editar. [ADR-045](../decisiones/045-explorar-zona-independiente.md) sustituye la distribución unificada descrita en las notas anteriores.

El deslizamiento del indicador de opción dura180ms (antes320ms), por petición del usuario de una selección más rápida. Conserva curva suave y movimiento reducido; no cambia la transición del panel. Ajuste sin nuevas pruebas por instrucción vigente.

La cápsula Filtrar casos interpola fondo, texto e iconos y gira su chevrón con la misma animación del panel, tanto al abrir como al cerrar. Las opciones comparten NoSplash y overlay transparente con Mis mascotas: sin destello claro temporal al pulsarlas; se conserva el indicador de selección móvil. Ajuste con formato/revisión de código, sin nuevas pruebas ni renders por instrucción del usuario.

Al abrir/cerrar filtros, desenfoque y sombreado del fondo progresan junto con expansión/fundido del panel desde arriba, inspirados en Control Center de iPhone. El selector Filtrar casos queda fuera del blur/velo y permanece nítido, igual que el editor. Sin cover/stagger en esta interacción; movimiento reducido directo. Tocar el fondo o selector cierra sin aplicar; no mueve la grilla. [ADR-044](../decisiones/044-filtros-transicion-control-center.md). Último ajuste sin nuevas pruebas por petición del usuario; revisión visual Android pendiente.

Desde la sección Explorar de Inicio se consultan tarjetas reales de búsquedas y avisos. Filtrar casos despliega opciones ancladas debajo de su cápsula, superpuestas a la grilla sin desplazarla: tipo, especie, estado, período y ubicación/radio. El editor tiene scroll propio y conserva las cápsulas compartidas. Aplicar filtros empieza una consulta nueva; Ver más casos añade otra página. Actualizar y volver de una ficha refrescan la consulta. Una tarjeta abre la misma ficha pública existente; en búsquedas abiertas se puede enviar un aviso vinculado. No hay swipe de eliminación en esta consulta colaborativa.

## Reglas y campos

Tipos: Todos, Perdidas (propias/comunitarias), Encontradas (con custodia y anteriores), Avistamientos. Los anteriores se identifican como Reporte anterior sin reclasificarlos. Especies: todas/perro/gato/otra. Estados: abiertos, resueltos visibles para mí, todos los visibles. Se conservan los permisos previos: resueltos solo para su autor.

Períodos por fecha del suceso: cualquiera, últimas24h,7,30 o90 días. La ventana queda fijada al aplicar. Radio ajustable de1–50km desde un centro buscado o elegido en el mapa, o cualquier zona. Sin GPS ni solicitud de permisos; selección manual disponible siempre. La distancia es aproximada, calculada en servidor sobre la zona pública. No se muestran coordenadas numéricas.

Las páginas tienen20 elementos, orden estable por publicación/origen/ID y cursor asociado a todos los filtros. La primera consulta limita temporalmente las siguientes: publicaciones nuevas aparecen al refrescar. Cada petición revalida visibilidad; cambios de estado/retirada pueden reducir resultados. No se promete una instantánea transaccional entre páginas.

## Persistencia y permisos

Consulta sin escrituras ni datos de demostración en producción. Fuentes066–069/plan019: PostGIS en extensions, índices y RPC autorizada `explore_cases`. Reutiliza proyecciones existentes y excluye borrados/borradores/destinos ocultos. Solo coordenadas públicas aproximadas; sin referencia privada, documentos u originales. Miniaturas verificadas seleccionadas, URLs temporales firmadas por data. Los filtros viven durante la visita a la sección; no se añaden preferencias persistentes ni caché offline.

## Errores y reintentos

Carga inicial con skeleton; acciones con shimmer. Refresh de la misma consulta conserva datos; cambiar filtros los oculta. No hay casos solo tras respuesta exitosa vacía. Errores en toast superior con Reintentar; fallo de página conserva cursor y páginas previas. No se mezclan orígenes con UUID iguales; doble envío bloqueado. Cambio de cuenta oculta datos y descarta respuestas tardías; recuperación de sesión tras error admitida. Radio sin centro produce toast y shake/borde en mapa. Fallo de teselas usa recuperación del componente compartido.

## Dependencias y activación

Aplicar [migración019](../../supabase/migrations/20261015001900_explore_cases.sql) o [patch019](../../database/patchs/019_patch_explore_cases.sql), tras001–018 y fotos operativas. Generadores Build-ExploreCasesPatch/Build-RunAll; no ejecutar patches antiguos sobre este contrato. PostGIS debe instalarse en extensions; si existe en otro esquema, el script falla expresamente para revisión. La app y la RPC se activan juntas. HU-07.2 (mapa de resultados), QR/web, push y offline quedan para sus incrementos.

## Validación y pendiente

Pruebas SQL/PostGIS locales de filtros, distancia, privacidad, permisos, repetición e inserciones entre páginas; Flutter de repositorio, dominio, concurrencia de solicitudes, cuentas, refresh/reintento, navegación y renders390×844/320×350 texto2/movimiento reducido. Evidencia final en [ESTADO](../ESTADO.md).

Pendientes activación de019, demo Android autenticada con fotos/teselas reales, permisos Storage hosted y rendimiento con volumen representativo. La validación del usuario de la rama anterior no acredita este contrato nuevo ni cierra HU-07.1. El proveedor del mapa mantiene las condiciones pendientes registradas en configuración.


## Grilla fotográfica — 15 de octubre de 2026

Por instrucción del usuario, los resultados se presentan en cards con foto horizontal4:3 protagonista, nombre/tipo y especie/distancia debajo. Por ajuste posterior del usuario, la fecha se retira de la tarjeta (se conserva en ficha/filtros) y el estado pasa a un badge en la esquina superior derecha de la imagen. Por aclaración posterior con captura, dos columnas completas, margen lateral12 y desplazamiento exclusivamente vertical. Se retira el scroll horizontal y el tamaño al76%; las cards son menores que esa variante y aprovechan el espacio lateral. Una columna del ancho disponible con ancho reducido/texto ampliado; alturas naturales sin truncar datos. La tarjeta completa abre la ficha. CasePhotoView y EntityCardSurface compartidos conservan skeleton, shimmer, errores en toast y superficie/radios aprobados. Sin foto se muestra icono sobre superficie neutra. Carga inicial con cuatro cards skeleton. No cambia persistencia, filtros, paginación, permisos, activación019 ni alcance de HU-07.1; [ADR-040](../decisiones/040-explorar-grilla-fotografica.md). Renders de prueba usan imágenes locales de fixture, sin demostrar fotos de Supabase.


## Panel flotante de filtros — 15 de octubre de 2026

Sustituye el despliegue dentro de la grilla. La cápsula Filtrar casos abre FilterPopover compartido por encima del contenido; las opciones siguen el selector Activas/Archivadas mediante FilterChoiceGroup y SelectionPillSurface comunes. Cabecera corta Filtros, X glass, grupos adaptables y scroll dentro del panel. La grilla conserva posición/geometría. Cerrar por fuera/X/Atrás descarta la edición; Aplicar confirma y consulta, y al reabrir se restaura esa selección. Abrir/editar no consulta servidor. Radio sin centro mantiene panel abierto con shake/toast y no aplica.

El panel se retira al desmontar el propietario/cambiar cuenta; bloqueo de aperturas y confirmaciones duplicadas. Movimiento reducido y texto ampliado respetados. No hay SQL nuevo ni cambio de permisos/activación019. [ADR-041](../decisiones/041-filtros-flotantes-reutilizables.md) y ESTADO registran validación local y pendientes.


## Filtros integrados y ubicación de búsqueda — 15 de octubre de 2026

Sustituye el panel modal descrito arriba, por nueva corrección explícita del usuario. FilterExpansion reutilizable despliega el editor dentro de Explorar; cerrar descarta edición sin aplicar, y Aplicar confirma/colapsa y devuelve al listado. Se mantiene estilo de Activas/Archivadas mediante cápsulas compartidas. Separación16 respecto a cards; texto bajo fotos solo nombre/especie, sin Mascota perdida. Tipo/estado en badges y especie como título único si no hay nombre.

Zona de búsqueda: Todas las zonas o Por ubicación. En esta última se escribe ciudad/dirección y se pulsa Buscar ubicación o la acción del teclado; no hay autocomplete por tecla. Seleccionar un resultado centra el mapa; slider de1–50km cambia el radio/círculo y ajusta cámara. Tocar mapa permite ajustar el centro manualmente. Sin GPS ni permiso nuevo. Al aplicar se usan los mismos parámetros geográficos de019, siempre sobre ubicación aproximada pública de los casos. Sin centro se conserva shake/toast y no aplica.

Búsqueda de lugares mediante Photon/OpenStreetMap, cinco resultados y caché en memoria, sin historial persistente. El texto escrito se consulta al proveedor; no se envían tokens o datos privados de casos. Atribución enlazada junto al buscador. PLACE_SEARCH_URL permite sustituir el endpoint; el servidor demo inicial admite uso razonable sin garantías y requiere revisión antes de distribución/volumen mayor. Error del servicio mantiene opción manual y reintento, con feedback superior. [ADR-042](../decisiones/042-filtros-integrados-y-busqueda-zonas.md).

20/10/2026: sugerencias textuales limitadas a Perú en la fuente compartida de
places, con petición countrycode=PE y comprobación del país recibido. Mapa,
GPS, radio y consulta conservados. [Ficha](ubicaciones-buscador.md), ADR-107.
