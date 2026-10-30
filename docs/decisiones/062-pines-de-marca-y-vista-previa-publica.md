# ADR-062: pines de marca y vista previa pública en el mapa

Fecha:18 de octubre de2026. Decisión explícita del usuario.

## Motivo y decisión

El usuario solicita usar logo/only-black.svg como pin y sustituir Abrir caso
por una vista previa con foto principal, tamaño, raza y fecha del suceso.

Corrección posterior del usuario: foto a ancho completo arriba y nombre/datos
debajo. Tamaño, raza y fecha forman una fila con icono propio sobre cada dato.
La foto mide136px; la altura de la etiqueta se adapta al mapa visible. Con texto
ampliado, la fila puede desplazarse horizontalmente y toda la vista previa
verticalmente; los controles de coincidencias permanecen fuera del scroll.
Esta composición sustituye la foto lateral y los datos apilados de la primera
implementación, sin cambiar lectura pública, apertura ni estados.

ExploreMapPin renderiza una copia exacta del SVG mediante flutter_svg2.2.1,
compatible con el SDK instalado. El símbolo permanece negro; grupos conservan
la marca y añaden contador. La copia se sincroniza desde logo mediante el
generador existente y una prueba compara los bytes. El original no se modifica.

La etiqueta junto al pin conserva apertura por toque y navegación de
coincidencias. ExploreMapCasePreview reutiliza CasePhotoView, EntityCardSurface,
LoadingShimmer, ConfirmationToastHost y el formateador de fecha compartido.
Foto sin URL conserva un placeholder; fallo de imagen conserva el feedback
compartido. El espacio se ajusta al mapa visible sobre el panel mínimo42%;
texto ampliado permite recorrer los datos por scroll, con controles de grupo
fuera de ese scroll. La cámara reserva ese espacio y no consulta por movimiento.

ReadExploreCasePreview es un caso de uso de dominio que colabora mediante
LostCaseRepository/FoundCaseRepository para leer únicamente la proyección
pública del caso seleccionado. Extrae tamaño, primera foto pública ordenada
y fecha. Sus providers declaran la colaboración sin importar data ni otras
presentaciones; bootstrap conserva la inyección de repositorios existente.
ExploreCasePreviewViewModel autoDispose por caso observa la sesión, oculta datos
al cambiar cuenta y normaliza errores/reintento sin una nueva búsqueda global.

La fecha se etiqueta Desaparición, Encuentro o Avistamiento según el tipo del
resultado. Raza no existe en los modelos/formularios actuales: se muestra Raza
no registrada, sin inventar valores ni reutilizar especie/species_detail como
si fueran raza. Capturar y persistir raza sería un incremento separado; esta
decisión no lo acredita. Tamaño desconocido no se inventa ni se confunde con
un error de consulta. No hay SQL, nuevos permisos o lectura de fichas privadas.

## Validación

Pruebas de copia SVG, lectura pública por origen, foto principal, fallos seguros,
reintento, identidad, pines/coincidencias, apertura/retorno, mínimo del panel y
texto ampliado. Renders con foto fixture y teselas neutras en tamaño normal y
320×350/texto2; evidencia en ESTADO. No acreditan backend real o build Android.
