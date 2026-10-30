# Diseño de la interfaz: implementación y revisión

Corrección23/10, ADR-133: Favoritos/Seguir/Bloquear usan el mismo
PanelActionButton que Descargar/Denunciar: círculos grises56 con iconos26, sin
etiqueta visible, tooltip/semántica. Todos bajo el separador; Wrap centra y
ajusta filas en pantallas pequeñas. Sin glass dentro del panel blanco.

23/10, [ADR-133](decisiones/133-acciones-de-ficha-y-navegacion-glass-compartida.md):
Ficha pública conserva Volver/Compartir; Favoritos/Seguir/Bloquear viven en el
panel blanco. GlassNavigationBar es responsable de posición segura superior+4,
márgenes24 y acciones alineadas; compartido por los shells de ficha y entidades.
Las pantallas consumidoras entregan acciones, sin recolocar botones. No se afirma
migración global de otros controles glass.

## Patrón reutilizable aprobado: expansión desde origen

[Guía de uso y revisión](patrones-ui-ux/expansion-desde-origen.md), aprobada
visualmente por el usuario el21/10/2026 en Reportar web. Define superficie
que se estira desde el control, identidad sin estiramiento, fullscreen,
transformación del contenido y retorno; incluye parámetros, componentes,
ejemplos de integración, accesibilidad y comprobaciones. Es la referencia
para reutilizar esta animación sin recrearla por funcionalidad.

Los apuntes cronológicos siguientes conservan el historial; el contrato actual
es ADR-128 y la guía enlazada, sin ocultar el cuerpo hasta100% ni aplicar blur
a la superficie/icono.

Contrato vigente21/10, ADR-128: combinar fullscreen/GSAP Sader con identidad
móvil al abrir y cerrar. La superficie negra y su radio se transforman; icono
y nueve puntos mantienen tamaño, centrados dentro del contorno, con fase fuente
hasta45% invertida al regresar. Fade/blur de Sader solo al cuerpo de destino.
Control original oculto temporalmente para evitar duplicado y restaurado junto
a la limpieza de identidad, estilos y referencias. Se mantienen0.7s/CustomEase,
ruta anterior detrás, marca/barra, acceso/guards y reducido. Perfil/Alertas y
Flutter intactos. [ADR-128](decisiones/128-identidad-mobile-en-origen-web-fullscreen.md).
Los apuntes anteriores que contradigan esa fase se conservan como historial.

Origen de navegación web21/10, instrucción posterior ADR-125: reemplazo por
GSAP Flip/PrettyModal de Sader (0.7s), sin clonar páginas; cuerpo oculto hasta
terminar apertura y componente cerrado oculto hasta commit de ruta. Excepción
explícita a ADR-124 solo en ese motor; Perfil/Alertas y Flutter conservados.
[Contrato vigente](decisiones/125-origen-web-reemplazado-por-sader-gsap-flip.md).

Paridad obligatoria21/10, ADR-124: animaciones equivalentes móvil/web comparten
efecto, origen, sentido, duración, curvas, fases y retorno; solo geometría
responsive adaptable. Perfil/Alertas web:320/260ms desde avatar/campana reales,
easeInOutCubic, fuente hasta45%, contenido desde65% con easeOutCubic y escala
según ancho. Revisar fotogramas de entrada/salida con movimiento normal,
además de reducido, foco y limpieza; capturas finales no prueban paridad.
[Contrato](decisiones/124-paridad-animaciones-mobile-web.md).

Hero landing20/10, ADR-120: recuperar primera captura del usuario, con Arial500,
oscuro #171918, tamaño42–108px (móvil32–48px), line-height1.02 y tracking−0.055em.
Mascotas laterales originales; #hero-title queda fuera de Poppins global.

Animaciones web20/10, ADR-119: iconos sin texto visible, cápsula azul deslizante
320ms con iconos gris/blanco y elevación del acento2px. Barra fuera de NuxtPage
para conservar continuidad; origen compartido320/260ms en Reportar y editor de
mascota, con retorno y cabecera estable. Movimiento reducido/cancelación/resize
liberan interacción; [ficha](funcionalidades/transiciones-web.md).

Navegación web20/10, ADR-118: cápsula glass flotante de Inicio/Explorar/Mis mascotas
y círculo Reportar de nueve puntos, selección degradada azul basada en móvil.
Semántica/foco/tooltip, área segura, espacio de scroll y texto ampliado; marca
superior conservada. Formularios reutilizan mapa/toast/skeleton/shimmer; acciones
apiladas en móvil. [Ficha](funcionalidades/navegacion-web.md).

Teléfono20/10, ADR-117: bandera vectorial y prefijo seleccionables junto al número nacional, con AppFieldSurface compartido; apilado en ancho/texto ampliado. Panel blanco con búsqueda española y scroll integral ante teclado, sin X. Vacíos con Perú inicial; número existente conserva prefijo, compartidos ambiguos muestran globo. Semántica país/prefijo y controles48.

Perfil20/10, ADR-116: Celular de contacto opcional reutiliza AppTextField/ShakeField/espaciado20 existente, teclado telefónico y privacidad visible. Sugerencia por caso sin activar consentimiento ni foto; toast superior y guardado conjunto con shimmer real.

Compartir ficha20/10, ADR-115: panel inferior blanco opaco/radio28/tirador, sin glass ni X. Copiar enlace azul/icono blanco, WhatsApp verde y Facebook azul arriba; Descargar/Denunciar en círculos grises contiguos solo iconos, tooltip y semántica. Gesto/toque fuera/Atrás para cerrar; scroll con texto ampliado. Cabecera conserva glass y sitúa título en fila propia bajo380px o texto ampliado, evitando solapamiento con Compartir/Guardar. [Ficha](funcionalidades/compartir-ficha.md).

Corrección de fidelidad20/10, ADR-113: etiqueta Perdido a la derecha del nombre en una fila centrada; paginación debajo y al centro. GlassSurfaceFinish.frosted para tarjetas de ficha y controles de contacto: un ribete blanco, sombra difusa y gradiente traslúcido perla/celeste; sin relleno gris adicional ni contorno oscuro doble. Polished sigue por defecto en navegación y consumidores anteriores. Adaptar etiquetas largas/texto ampliado con apilado y foto más alta.

Ficha pública móvil20/10: [tarjetas glass aprobadas](funcionalidades/ficha-publica-mobile.md), ADR-113. Radio28, margen16, foto redondeada con nombre blanco48/800, navegación glass52 y mapa propio. Título de navegación Poppins400/20/gris por referencia explícita; texto ampliado usa título32 en fila propia. [Contacto autorizado por caso](funcionalidades/contacto-reportante.md), ADR-114. ImmersivePhotoSheet continúa en las vistas previas, conservado para reutilización.

Diseño conservado20/10: **Ficha fotográfica inmersiva** (`ImmersivePhotoSheet`, antes `CasePublicationPreview`), según [ADR-112](decisiones/112-conservar-ficha-fotografica-inmersiva.md). [Guía de reutilización](funcionalidades/ficha-fotografica-inmersiva.md). Se conservan foto completa, nombre blanco48/800 y panel deslizable; nuevo mockup por tarjetas aún sin implementar.

**Títulos principales20/10/2026, ADR-111:** Poppins Regular400, tamaño base32,
gris #454746, interlineado1.25 y tracking0 en móvil y web. Flutter usa
AppTypography.primaryTitle; Nuxt typography.css/h1 y fuente local compartida.
Permitir ajuste de líneas y ampliación accesible, sin overrides de tamaño/peso/color
por pantalla. Aplica también a Guardados, acceso, onboarding, landing y legales.
Marca oficial y remate azul600 de «empieza contigo» conservados; subtítulos,
diálogos, tarjetas, controles y PDF conservan su jerarquía. Sustituye reglas
anteriores de tipografía de títulos. Véase [ADR-111](decisiones/111-titulos-principales-poppins-mobile-web.md).

Inicio, corrección posterior20/10: título Poppins32 sin contenedor glass,
mismos pesos de ADR-105. Primera frase gris #454746; segunda con ShaderMask
horizontal #459FF6→#75C9EF según nueva captura. Descripción16/1.4 debajo del perro/gato dentro
de HomeReunionCard glass, padding horizontal total22 y separación12 de imagen.
HomeNotice de Cerca de ti reutiliza GlassSurface/radio26 y preserveBackdrop.

Explorar20/10, ADR-106: mínimo =32 de tirador + altura real resumen/Ver ficha +
inset inferior+12, dividido por viewport (18–85%); sin selección22%. Apertura50%
o mínimo si requiere más y máximo90%, scroll seguro. MapAttribution.compact:
fuente8/escalable, ribete claro estrecho, objetivos48; derecha8/izquierda84,
crédito visual aproximadamente8px sobre panel, sigue extensión/resistencia.
Título central se retira en altura insuficiente; retorno conservado.
Movimiento del panel: resorte propio1/260/34 con impulso del gesto, cancelado
al tocar de nuevo. Parada por dirección de pasada rápida o proximidad al soltar despacio. Resorte
inferior1/190/28; dedo directo, contenido con su inercia, reduced sin acomodo.

Título de Inicio móvil20/10: referencia tipográfica del usuario aplicada con
Poppins local, tamaño23/altura1.25. «Su regreso» gris #454746/peso400 y salto
de línea antes de «empieza contigo», azul #459FF6/peso600. Text.rich sin altura
fija ni truncamiento; ampliación y etiqueta accesible completa conservadas.
Excepción local documentada en [ADR-105](decisiones/105-titulo-inicio-mobile-referencia-tipografica.md).

Cartografía vigente20/10, ADR-104: todos los mapas móviles/web comparten el
punto medio50/50 entre fuente original de Reportar y filtro anterior de Explorar.
Conservar color parcial y claridad leve; MapStyle Flutter y SVG sRGB Nuxt con
paridad numérica. Solo teselas; marca/pines, círculos, créditos y controles
sin filtro. Usar adaptadores compartidos; revisar fuentes reales y text scale.

Mapa20/10, ADR-103: resumen compacto con foto112×112/radio18, nombre20/600 y
rasgos14 hasta dos líneas; sin tipo de reporte debajo del nombre. Flecha48
con NavigationAccentSurface de core, compartido con LiquidNavigation. Ver ficha
gris/radio12/alto mínimo48 y detalles verticales tras separador.
Detalles: separador con padding vertical16, título→datos16 y gap16 entre
Tamaño/Especie/Fecha, según captura aprobada; etiqueta/valor conservados.
Panel50–90%, contenido desplazable y tirador32. Sin disco gris del radio; créditos bajo
cabecera y símbolo oficial en pines de ubicación. Selección negra/blanca.
Sustituye las dimensiones anteriores del resumen; consulta/radio real intactos.
Refinamiento20/10: título centrado con GlassSurface/radio24/padding22×12.
Teselas blanco grisáceo con calidez leve (claro orientativo #F6F6F2), con pines/créditos intactos; selección acerca
a zoom15 si estaba más lejos, sin alejar una cámara ya más próxima.
[ADR-103](decisiones/103-mapa-resumen-compacto-referencia-aprobada.md).

Corrección19/10/2026: el fondo móvil conserva las luces del tercio superior y atenúa progresivamente el celeste hasta casi blanco junto a la navegación. El velo se pinta dentro de AppPageBackground antes del contenido; conserva movimiento, glass, viewport y accesibilidad. Véase docs/decisiones/102-fondo-mobile-atenuado-hacia-navegacion.md.

Mapa flotante19/10: elección3 sustituye fila Lista/Mapa; GlassSurface/radio26,
padding18/12, icono22 +8 + texto14/600, mínimo48. Posición derecha16/bottom100
más inset,20 sobre barra. Scroll reserva200 más ampliación de texto/inset.
Origen real y retorno conservados; ADR-101, revisión física Android pendiente.

Explorar compacto19/10: fila con Ubicación expandida y botón tune48×48 a la
derecha, separación8. Lugar y radio en línea; lugar elidido con tooltip completo.
FilterExpansion.compact conserva48 táctiles sin padding exterior y6 verticales
interiores. Variante iconOnly con tooltip/semántica y estado expandido, sin
chevrón/texto. Altura normal48, adaptable a texto2. Paneles y estilos compartidos
conservados. [ADR-100](decisiones/100-explorar-controles-compactos.md).

Corrección posterior19/10/2026 del usuario: Reportar (nueve puntos) vuelve
a su IconButton circular negro #111111 original, de64px y puntos blancos,
sin degradado, brillo ni sombra azul. El acabado de landing y sus efectos
se conservan únicamente en la selección activa de la barra.
Validación: formato, análisis completo y7 pruebas de Home aprobados.
Pendiente revisión visual Android.

## Mapa: pines individuales y foto mayor —19/10/2026

ADR-099: reemplazar raza por especie disponible (Perro/Gato/Otra especie), con
fallback Tipo no registrado. Foto a ancho completo4:3, sin136px fijos. Sin estado
ni conteo textual del mapa en el panel. ExploreMapPins separa objetivos48px con
paso56px, preferencia horizontal y proyección de cámara; sin contador ni flechas
entre casos. Zoom/giro recalculan la presentación, conservando coordenadas y
consulta. Mantener scroll, CTA y panel42–90%. Capturas normales/pequeñas y panel
expandido revisados; Android del ajuste pendiente.
[ADR-099](decisiones/099-mapa-pines-individuales-y-resumen-fotografico.md).

Navegación móvil19/10: LiquidNavigation comparte el acabado de Iniciar sesión
de landing entre selección activa y Reportar. Gradiente vertical75BFFF/459FF6
al48%/2887EF, brillo blanco superior y sombras azules7/20 y2/5. Interacción
hover/foco/pulsación200ms, elevación2px y brillo97%; con movimiento reducido,
color inmediato y posición fija. Glass y geometría existentes;
selección320ms conservada. [ADR-098](decisiones/098-navegacion-mobile-acabado-boton-landing.md).

## Resumen inferior del mapa móvil —19/10/2026

Filtros/Ubicación solo en Explorar. ExploreCaseMap coloca la vista previa
pública dentro del panel42–90%, sin callout junto al pin. Tirador persistente,
foto arriba, nombre/fila de datos debajo y estado; Ver ficha fijo si cabe y
alcanzable por scroll en altura reducida. Sin selección, instrucción para tocar
un pin. Coincidencias con anterior/siguiente; cámara sin efectos en la consulta.
Capturas390×844 y320×350/texto2 revisadas; Android del nuevo recorrido pendiente.
[ADR-097](decisiones/097-explorar-filtros-unicos-y-resumen-en-mapa.md).

## Toast móvil con referencia web —19/10/2026

ConfirmationToastHost adopta entrada480ms desde fuera del viewport, retorno420ms,
salida superior240ms y gesto de TopToast; texto14/400/1.4 y acción subrayada mínima44.
Conservar glass/blur18/radio28, icono32/20, máximo360/márgenes24 y safe-area+12.
6500ms con pausa al sostener. Scroll/texto2, toque/teclado/semántica y movimiento
reducido conservados. Revisar capturas de entrada/arrastre/retorno y320×350/texto2.
[ADR-096](decisiones/096-toast-mobile-igual-web.md), [ficha](funcionalidades/toast-mobile.md).

## Glass estable y reunión en Inicio —19/10/2026

Corrección ADR-095: las tarjetas de Inicio entran con StaggerRevealItem y
preserveBackdrop: fade/desplazamiento habituales, sin recorte ni blur de entrada
del material. GlassSurface usa blendMode src en la capa de opacidad de estas
tarjetas. Inicio/Explorar omiten cover previo y tienen un solo
timeline activo; no reiniciar por datos de consulta o refresh.
Conservar radio26 y padding22 de la tarjeta principal. HomeReunionCard añade
el PNG original de landing, contenido3:2/padding12, sin recortar mascotas ni
acciones inventadas. Secuencia: tarjeta principal, accesos rápidos, reunión,
Cerca de ti (cuatro grupos). ADR-093; comparar ribete durante/final de entrada.

## Marca móvil alineada con web —19/10/2026

BrandName/wordmark.svg sustituye el texto anterior en BrandWordmark y StartupReveal:
minúsculas, contornos Arial de peso CSS500, #171918 y tracking−.05em. Conservar
el símbolo, posición y escala por pantalla; tamaños gráficos estables con texto2,
semántica del contenedor y FittedBox en anchos pequeños. Gap7/16px según tamaño
compacto/grande. No aplicar Arial al cuerpo de la app ni crear logos alternativos.
Revisar acceso, bienvenida, Inicio y arranque. ADR-092.

## Fondo móvil compartido —19/10/2026

AppScaffold sustituye fondos blancos exteriores de pantallas Flutter y compone
AppPageBackground por fuera del Scaffold transparente. Corrección ADR-091:
blanco con cinco nubes azules a distintas alturas y movimiento suave de24s;
trayectorias cerradas, pausa accesible/TickerMode, sin rebuild del contenido.
HomeContent usa GlassSurface/radio26 en la tarjeta principal con padding22 y
acción originales. Sustituye la distribución estática de ADR-088.
Conservar áreas seguras/scroll y el tamaño completo del fondo con teclado.
CoverReveal y OriginPageTransition reutilizan fondo; no recolorear superficies
de campos, otras tarjetas, fotos/mapas o paneles. Verificar
acceso/onboarding/Inicio/formularios, texto2 y movimiento reducido.

## Marca de cabecera compartida —19/10/2026

SiteBrand/SiteHeader sustituyen las marcas independientes: misma posición,
color#171918, Arial500, gap7px y tamaños adaptables de landing. Incluye login
y onboarding; cabecera fuera del efecto, login conserva cuatro grupos de cuerpo.
QA compara medidas/render contra landing en1440/731/390/320 y texto200%,
y exige posición/dimensiones constantes desde SSR hasta hidratar y recargar.
La marca va arriba a la izquierda, fuera de cargas/entradas; acciones y retorno
se acomodan sin desplazarla. No añadir reglas CSS competidoras por orden de carga.
[ADR-077](decisiones/077-marca-web-compartida-referencia-landing.md).


## Posición de la marca web —19/10/2026

Logo oficial junto a «entre huellas», arriba a la izquierda, con posición y
márgenes de landing/onboarding. Mantener arriba en responsive y fuera del
stagger, skeletons y columna del formulario. Revisar alineación, texto ampliado
y estabilidad entre etapas; reutilizar cabecera/marca al adaptar recorridos.
[ADR-076](decisiones/076-posicion-unificada-marca-web.md).


## Reveal compartido web —19/10/2026

No pintar cobertura crema antes de revelar. StaggerReveal usa el composable
aprobado:850ms/90ms, blur18px y desplazamiento28px; cabecera persistente.
Login/onboarding conservan sus grupos y parámetros. Probar fotogramas reales,
movimiento reducido, contenido actualizado y QR sin JavaScript.
[ADR-075](decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md).

## Onboarding web con referencia de Sader —19/10/2026

OnboardingFlow de access: columna448px, izquierda, Inter local, título48/600,
descripción18/500 y botones carbón/radio18px base/mínimo48px/flecha20px.
PNG/textos/saltos originales de onboarding móvil. Stagger compartido550ms/90ms,
offset56px, salida invertida antes de cambiar paso, press400ms y entrada doble rAF.
Sin .reveal ni cobertura crema; orbe strong persistente, movimiento reducido sin
esperas. Guardado con shimmer visible y error/reintento conservando tercer paso.
[ADR-074](decisiones/074-onboarding-web-referencia-sader-y-mobile.md).

## Referencia web consolidada —19/10/2026

Las [reglas web](REGLAS_UI_UX_WEB.md) contienen los valores vigentes. Las notas
fechadas anteriores son el historial; no recuperar sus medidas sustituidas.

| Componente | Implementación vigente |
| --- | --- |
| Stagger de login | useStaggerReveal + vStaggerReveal; transiciones originales de sader-panel, doble rAF, will-change persistente,850ms/90ms, blur18px/offset−28px; CSSOM compatible con CSP. |
| Marca de cabecera | SiteBrand/SiteHeader compartidos con landing, fuera del stagger; misma posición, color y escala responsive (ADR-077). |
| TopToast | Glass claro, radio28px/blur18px, medallón32px/icono20px, texto14px/400 sin negrita, sin X. Entrada desde arriba480ms, descarte deslizando hacia arriba/salida240ms, retorno420ms; toque y teclado conservados (ADR-081). |
| Retorno legal |36×36px, chevrón16px, circular glass/blur22px; variante local en LegalPage. |
| Enlace legal derecho | Mínimo36px, padding8/12px, radio calc(.625rem + 8px), texto14px/500/línea20px, flecha16px. |
| Fuente legal | DM Sans local, solo /terms y /privacy. |

Conservar movimiento reducido, foco/tooltip, cierre y reintento del toast,
limpieza al desmontar y lectura sin recortes con texto ampliado. El retorno
compartido fuera de legales mantiene52px/icono28px. La paleta y el orbe vigentes
se conservan. ESTADO y las fichas de acceso/documentos legales registran el QA.

## DM Sans legal y glass corregido —18/10

/terms y /privacy usan DM Sans variable local, incluido título/cuerpo/metadatos.
Reloj/anuncio Material Symbols Outlined filled a16px; retorno Material Rounded
chevron16px dentro de glass36px/blur22px en legales (actualizado19/10). Sustituye glyph tipográfico y dibujos
aproximados. Login conserva Arial. Font/iconos/licencias en platform/ASSETS_UI;
QA responsive y de moderación en ESTADO/ficha legal.

## Documentos legales: composición sader-panel —18/10

Referencia vigente: barra dentro del documento, retorno glass original en flujo,
link cruzado/flecha, título centrado y fecha/anuncio con iconos locales. DM Sans
con h145/h232/cuerpo16, ancho896px/padding24–48. Orbe medium fijo detrás del
viewport de lectura con scroll propio, sin atenuación vertical. Sin índice extra
ni cover del artículo. Capturas login-legal y resultados en ESTADO/ficha legal.

## Entrada de login sin destello amarillo —18/10

Referencia vigente: sader-panel850ms/90ms, blur18→0, translateY(-28)→0 y
opacidad0→1 para icono/nombre/título/lema/formulario/legales. Sin .reveal ni
cover crema solo en login. Sustituye entrada previa700ms del icono. Capturas
de recarga inicio/mitad/final en build/ui-preview/login-reload; datos/sesión
y edición no reinician la entrada. Reglas web y ficha acceso-web actualizadas.

## Login y documentos legales —18/10

AmbientPageShell compartido: orbe strong en login y soft en /terms y /privacy.
Icono con entrada/hover como referencia sader-panel, sin reinicio por edición
y estático con movimiento reducido. Enlaces legales bajo el formulario; lectura
con índice, retorno glass, navegación cruzada y correo confirmado. Arial
conservada. Ficha documentos-legales y ESTADO registran QA y límites.

## Login: formulario estable y acceso social —18/10

Formulario visible desde SSR, sin sustitución por skeleton al consultar sesión;
controles bloqueados durante esa consulta, sin shimmer por deshabilitación.
Retirado el texto de cuentas autorizadas. Separador y botones Google/Facebook
con iconos locales, cápsula blanca/borde suave, altura mínima60 y texto1rem.
Shimmer solo en el proveedor solicitado durante trabajo real; errores/cancelación
al toast superior. Arial y composición móvil conservados. Capturas web-login
actualizadas en escritorio/móvil/texto200%; detalle en ficha acceso-web.

## Login web —18/10, referencia móvil y sader-panel

Por solicitud posterior del usuario: composición centrada sin tarjeta exterior,
marca grande/nombre en dos líneas, campos suaves con iconos y control de
contraseña. Arial de web conservada. WebShell minimal, fondo blanco/celeste/cream
y resplandor soft; botón carbón como en móvil. LoginInput reutilizado en ambos
campos, radio22px/alto mínimo76px, etiquetas flotantes, foco y toast/invalid/shake.
Capturas aprobadas localmente en apps/mobile/build/ui-preview/web-login, incluido
320px/texto200%. Detalle, permisos y límites en ficha acceso-web.

## Moderación web —18/10

Solo apps/platform, sin equivalente administrativo Flutter. /moderacion reutiliza
WebShell (variante ancha alineada), ActionButton (envío semántico), TopToast y
ContentSkeleton con etiqueta accesible por recorrido. GlassNavigationButton
web compartido para retorno flotante; ConfirmationDialog nativo modal con foco,
Escape y cancelación para decisiones/salida. Crema/Arial/celeste y cápsulas de
la landing; paneles de trabajo, dos columnas desde850px, una columna pequeña.
Cabecera fuera del reveal; edición/refresh no reinician entrada. Motivo con
contador500, inválido/shake/toast y shimmer real con etiqueta estable.
Capturas de validación en apps/mobile/build/ui-preview/moderation-web; resultados
finales en ESTADO. [Ficha](funcionalidades/moderacion-web.md).


Android18/10, HU-14.1: Denunciar contenido abre Denuncia desde fichas y revisión
privada con transición desde el botón compartido. Shell/glass/cover/stagger,
inputs/contadores500 y1000, toast/invalid/shake, skeleton/shimmer. Recibo tras
persistencia; salida con borrador/ambigüedad confirmada. Renders390×844 y
320×350/texto2 en apps/mobile/build/ui-preview/content-reports, revisados.


Android18/10, HU-13: Ya fue recuperada abre Cierre con la transición del
botón compartido. CaseScreenShell mantiene glass/cabecera y cover/stagger; motivo
y evidencia testimonial opcional usan AppTextField/contador500, toast/invalid/
shake, skeleton y shimmer. Confirmación explícita antes de escribir; recibo
privado después y Ver recuperación desde ficha resuelta. Renders normal390×844
y pequeño320×350/texto2 revisados en build/ui-preview/case-closure.

Android18/10, HU-11: Ver historial se compone como slot en ficha, visible tras
capacidad autorizada del servidor. Historial/Revisión usan CaseScreenShell,
glass flotante, cover/stagger con cabecera persistente, superficies compartidas,
mapa privado de lectura/navegación, selectores y AppTextField con contador500.
El mapa refleja la precisión GPS registrada, sin círculo de precisión inventado
para un punto manual. Foto solo tras Ver foto; sin descarga de imágenes en lista.
Toast/shake/invalid, Guardar revisión con etiqueta constante/shimmer, refresco
por gesto con contenido conservado y recuperación explícita tras conflicto.
Clasificación, evidencia y auditoría se presentan separadas; texto aclara que
Confirmado no garantiza posición actual ni recupera el caso. Renders en
apps/mobile/build/ui-preview/case-timeline, normal y320×350/texto2, con fixtures.

Android18/10, HU-10.2: acción Reportar avistamiento en ficha abierta y formulario
con título breve La vi, para no partir palabras con texto200%. Reutiliza
CaseScreenShell, glass flotante, cover/stagger, fecha/hora independientes,
ZoneMapPicker, AppTextField con contador500 y PhotoGalleryStrip/PhotoAddTile.
Toast superior para validación/errores/resultados, ValidationSurface/ShakeField,
shimmer durante trabajo real y confirmación solo tras recibo persistido.
Renders normal/320×350 texto2 en build/ui-preview/android-sightings; mapa de
prueba con teselas neutras. Recibo y condición tardía son datos del registro;
sin nueva cronología ni publicación de evidencia. [ADR-065](decisiones/065-avistamientos-android-y-persistencia-compartida.md).

Web18/10, HU-10.1: WebShell/ActionButton y lector QR adoptan ADR-063 (crema,
Arial, marca minúscula, cápsulas con brillo/celeste). SightingForm con ancho
máximo620, campos60px/radio24, fecha/hora adaptables, mapa300px, adjuntos con
label accesible y foco visible, toast superior y shimmer de acciones reales.
Retorno glass52 flotante; WebShell reserva88px en cabecera para no tapar la
marca. Cabecera persistente fuera del reveal; sin repetir al editar/contar/GPS.
Estados inválidos/borde/shake; sin feedback bajo campos. Fotos/puntos reales
de visitantes no aparecen en la ficha QR; se conservan instrucciones de privacidad.
Capturas fixture en apps/mobile/build/ui-preview/public-sightings; referencia
operativa, no certificación de mapas/fotos remotos ni auditoría AA global.
Contraste18/10: primario/crema17.08:1, secundario/crema5.48:1 y azul/celeste5.03:1.
La combinación heredada blanco/degradado azul falla4.5:1 (1.97–3.62:1); se
registra para adaptación accesible de la referencia aprobada, sin afirmar AA.

Web — 18/10/2026: la landing final queda aprobada por el usuario como base
de toda la plataforma. [REGLAS_UI_UX_WEB](REGLAS_UI_UX_WEB.md) reúne tokens exactos,
radios, tipografía, botones, espacios, variantes de color, imágenes y movimiento,
con reglas de adaptación a formularios/listados y criterios de revisión.
[ADR-063](decisiones/063-landing-como-referencia-ui-ux-web.md). No se modifica UI
en este incremento; no se declara migración visual del QR ni paneles implementados.

Mapa18/10: ExploreMapPin usa SVG negro36 dentro de área táctil48; grupos añaden
contador. Callout de ancho máximo330 con foto superior136 a ancho completo,
nombre y fila de tamaño/raza/fecha con iconos18. Cada columna conserva ancho
legible; texto ampliado permite scroll horizontal en la fila y vertical en la
tarjeta, cuya altura se limita al mapa sobre el panel. Reutiliza CasePhotoView/EntityCardSurface y
fecha compartida, skeleton de tamaño mientras consulta y toast con Reintentar
ante error. Sin texto Abrir caso; nombre/tamaño/raza/fecha mantienen apertura
por toque. Fecha semántica por suceso; raza ausente declarada, no inferida.
ADR-062; no se promete captura/persistencia de raza.

Vacíos18/10: CollectionEmptyState reutiliza el diseño aprobado de Mascotas
en Mascotas/Explorar: padding vertical40, huella88 gris6E6E73, separación24,
título20/w600/111111 centrado, separación8 y descripción16 gris centrada.
Acción opcional con separación24/ancho máximo280, solo cuando existe una
operación real. No mostrar vacío mientras carga o falla una consulta.

Mapa18/10: DraggableScrollableSheet entre42–90%, con resistencia visual máxima
18px bajo el mínimo y retorno240ms al soltar. Retorno glass ligado a extensión
78–90% (fundido/retirada superior72px), restaurado al bajar; oculto sin hit-test
ni semántica. Movimiento reducido sin traslación/rebote. Filtros sin título
redundante; ver [ADR-061](decisiones/061-mapa-altura-minima-y-retorno-progresivo.md).

Landing17/10/2026: app/features/landing de plataforma compone LandingPage,
LandingArt/Icon/Brand/Actions y landing.css limitado a .landing-page. Recortes
de ilustración en clases CSS fijas compatibles con CSP, no inline. Referencia:
mockup de la rama landing, conservado al portar React→Vue. Lectores QR usan
.reader-shell para evitar interferencia al navegar. [ADR-060](decisiones/060-landing-integrada-en-platform-vue.md).

Web Vue17/10/2026: app/components comparte WebShell/ActionButton/TopToast/
ContentSkeleton; app/features/case_reader contiene pantalla y galería Vue.
app/assets/main.css conserva los tokens y geometría de la ficha anterior.
Revisión mediante build SSR y Chrome real, incluyendo hidratación, CSP, errores
y 320px con texto200%. [ADR-058](decisiones/058-web-unica-vue-nuxt-y-roles.md),
[guía Vue](../apps/platform/DESARROLLO.md).

Revisión del mapa (16 octubre): se sustituye la ficha inferior por ExploreFilterEditor combinado dentro del panel deslizable; sin mapa embebido duplicado. Botón Aplicar filtros fijo al pie cuando cabe; con panel mínimo pasa al scroll para no recortar texto/acciones. Pin sin selección inicial; al pulsar se reduce panel y aparece una etiqueta junto al punto con nombre/Abrir caso, superficie compartida y anterior/siguiente solo si hay coincidencias. Cámara acomoda la etiqueta; pan no consulta. Campos de lista y mapa comparten implementación y metadatos de lugar por cuenta. [ADR-056](decisiones/056-mapa-filtros-inferiores-y-acceso-en-pin.md).

Mapa de Explorar (16 octubre): opción Mapa navega a pantalla propia desde sus límites reales con entityEditorPage/OriginPageTransition. Sin cabecera ni navegación de Home sobre el mapa; GlassNavigationButton flotante. DraggableScrollableSheet 14/42/90% con tirador persistente, nombre/Ver ficha, coordenadas aproximadas y PublicCaseGrid de una columna/foto2:1. Un caso visible; anterior/siguiente solo para coincidencias. Padding de cámara evita centrar la búsqueda bajo el panel. Sin entrada repetida por pan/selección/refresh. [ADR-055](decisiones/055-explorar-mapa-inmersivo-y-panel-deslizable.md).

Cápsula de Ubicación (16 octubre): FilterExpansion admite subtítulo opcional; lugar aplicado como etiqueta centrada, radio en km debajo, tooltip con selección completa y elipsis para etiquetas largas. Filtrar casos conserva etiqueta normal. El texto real de ciudad/dirección se conserva separado del nombre de selección manual/GPS. Shimmer compartido mantiene su árbol estable en reposo/carga, sin desmontar contenido al entrar/salir del refresh.

Selectores (16 octubre): FilterExpansion ofrece placement `below` por defecto y `atOrigin` para Ubicación. La segunda superpone el panel al control desde su borde superior y conserva la animación original de escala/fundido, además de fundido/blur, scroll, teclado y cierre exterior/atrás. Filtrar casos conserva variante principal. Texto centrado y slots de iconos simétricos en ambas; sin nueva transición de página.

Con poco ancho/texto ampliado, sin icono inicial, la flecha se coloca debajo de la etiqueta centrada para evitar partir palabras. Si el origen quedó parcialmente fuera del viewport por scroll, el panel de Ubicación respeta el margen superior seguro de 8. Capturas normales y 320×350/texto2 revisadas; teselas no disponibles en pruebas de widgets, revisión Android pendiente.

Cartel con QR (16 octubre): EntityScreenShell con retorno glass/cabecera persistente, etapas preparar/listo y cover→stagger; LoadingShimmer en Generar, Imprimir/guardar y Compartir, toast para resultados/cancelaciones/errores. Solo fichas propias abiertas muestran el acceso mediante slot del router. Pantalla muestra foto pública y acciones reales; el PDF usa plantilla A4 con QR vectorial y fuentes incluidas, sin nuevos estilos globales. Renders en build/ui-preview/posters y build/poster-preview, con fixtures; [ADR-053](decisiones/053-carteles-pdf-y-enlaces-qr.md).

HU-07.2,16 de octubre: ExploreCaseMap reutiliza ZoneMapPicker con navegación de solo lectura, marcadores táctiles48, radio y atribución visibles; coincidencias muestran contador y tarjetas compartidas. TwoOptionFilter Lista/Mapa y cover→stagger conservan cabecera/filtros y consulta. Capturas de prueba en build/ui-preview/explore-map:390×844 y320×350/texto2/movimiento reducido; teselas neutras en memoria, sin validar cartografía real. [ADR-052](decisiones/052-explorar-mapa-de-resultados.md).

Corrección de recarga16 de octubre: PullToRefresh usa Stack sin recorte para que el indicador glass que entra desde coordenadas negativas no quede cortado durante el descenso/retirada. En Home envuelve toda la composición, incluida LiquidNavigation, y pinta el indicador al final sobre cabecera/contenido/acciones. Sin cambiar gesto, material o tiempos. Formato y análisis estático sin incidencias; sin pruebas/renders/build por instrucción vigente, revisión visual Android pendiente.

Ajuste vigente del16 de octubre: el marcador compacto de Explorar abre la pantalla independiente Guardados en /home/saved-cases. Reutiliza OriginPageSource/OriginPageTransition mediante entityEditorPage: expansión desde el icono y retorno al origen al cerrar, con movimiento reducido respetado. Sustituye el cambio de vista en la cabecera y la segunda pulsación. SavedCasesScreen reutiliza EntityScreenShell con retorno glass y cover→stagger, SavedCasesSection y PullToRefresh; scroll siempre desplazable incluso con lista vacía. Explorar permanece debajo con filtros/posición conservados. Sin cambios SQL;021 sigue pendiente de aplicación y revisión Android.

**Explorar/Perfil:** Guardados se abre con marcador24/área táctil48 junto al título, vacío/lleno según vista; segunda pulsación vuelve a Explorar. CollectionHeader mantiene esta acción en la misma fila con título flexible. Sin selector de secciones; cabecera fuera del cover→stagger. Guardados reutiliza PublicCaseGrid/entidades/DTO extraídos a core. Ubicación y Ciudad comparten PlaceSearchFields de places, modo ciudad aislado y selección explícita. Router compone slots de Explore/Profile; fuente/área táctil y feedback compartidos. [ADR-051](decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md). Análisis sin incidencias, sin pruebas/renders ejecutados;021/Android pendientes.

**Recarga glass:** PullToRefresh reutiliza GlassSurface con radio26/SizedBox52/icono28, igual que el control de volver. Posición oculta ajustada a52; mismo seguimiento/giro/retorno y semántica, sin interacción de botón. Formato/análisis estático sin incidencias; sin pruebas/renders por instrucción vigente, revisión Android pendiente.

**Guardar casos:** router compone SaveCaseButton en slots opcionales de fichas/EntityScreenShell/CaseScreenShell: superior derecho, inset+4/margen24, simétrico al retorno. GlassNavigationButton52, bookmark vacío/lleno confirmado, semántica/shimmer/toast compartidos. Solo con ficha disponible. [ADR-050](decisiones/050-casos-guardados-por-cuenta.md). Formato/análisis sin incidencias; SQL020/Android/renders pendientes, sin pruebas ejecutadas por instrucción vigente.

**Explorar,16 de octubre:** fila única Ubicación izquierda/Filtrar casos derecha, separación8 y anchos iguales. FilterExpansion.compact reduce padding/iconos sin reducir fuente ni área táctil; showLeadingIcon permite priorizar etiquetas con ancho reducido/texto ampliado. Altura natural compartida; no se apilan los controles. Panel de ancho completo anclado por la izquierda para Ubicación y por la derecha para Filtrar casos. Formato/análisis estático; sin nuevas pruebas por instrucción del usuario, revisión Android pendiente.

**Indicador vigente de actualización por gesto:** Icons.refresh_rounded reemplaza la flecha: seguimiento del dedo con resistencia, acomodo64px al soltar, giro durante petición real y retorno/desvanecido220ms. Reconocimiento nativo sin su spinner, sin anillo/barra; contenido conserva shimmer. Movimiento reducido directo sin giro. Compatibilidad explícita con estado refresh de Flutter3.35 y acción accesible. [ADR-049](decisiones/049-indicador-recarga-y-retorno.md) sustituye el aspecto anterior; formato/análisis sin incidencias, sin pruebas ejecutadas por instrucción del usuario.

**Actualización de listas por gesto:** PullToRefresh en core envuelve el scroll principal con RefreshIndicator.noSpinner y una flecha con LoadingShimmer, sin cargador circular/lineal. PullToRefreshTarget registra callbacks de la funcionalidad visible, sin dependencias core→features. Integrado en scroll de Inicio para Explorar/Mis mascotas y directamente en Ubicaciones de interés; AlwaysScrollableScrollPhysics, umbral/cancelación desde arriba, filtros y contenido conservados, operación duplicada bloqueada y gesto deshabilitado al editar ubicación. Icono de Explorar y botón ordinario de ubicaciones retirados. [ADR-048](decisiones/048-actualizar-listas-al-jalar.md); sin pruebas ejecutadas por instrucción del usuario, revisión Android pendiente.

**Controles de Explorar:** Filtrar casos y Zona son independientes; en fila si caben y apilados con ancho reducido/texto ampliado. Editor de Zona contiene buscador/mapa/radio y Aplicar zona. FilterExpansion permite icono, ancho de panel completo y anclaje derecho para Zona, conservando la transición vigente y selector nítido. Aplicaciones conservan selección del otro control. [ADR-045](decisiones/045-explorar-zona-independiente.md). Revisión visual pendiente; sin ejecutar pruebas por instrucción del usuario.

**Transición vigente del filtro:** aproximación Flutter a Control Center de iPhone, con blur0–16/velo negro0–28% y expansión/fundido sincronizados, apertura420ms/cierre280ms. ClipPath excluye la cápsula de origen del efecto y permite tocarla para cerrar. FilterExpansion no usa cover/stagger; salida conserva portal hasta finalizar y movimiento reducido directo. Sustituye las notas anteriores de movimiento del filtro; [ADR-044](decisiones/044-filtros-transicion-control-center.md). Sin nuevas pruebas/renders por instrucción del usuario.

**Explorar, ajuste vigente del 15 de octubre de 2026:** FilterExpansion<T> usa OverlayPortal y CompositedTransformTarget/Follower para desplegar bajo el control, con su mismo ancho, por encima de las cards y sin cambiar su posición. Sin ventana centrada; superficie F5F5F7/radio28 y scroll propio limitado al espacio disponible. Cards: solo badge de estado, nombre y distancia del servidor respecto a la zona elegida (A 4 km / A menos de 1 km); sin especie, fecha ni badge de tipo. Sin distancia se omite la línea. [ADR-043](decisiones/043-explorar-desplegable-anclado-y-distancia.md). Sustituye los detalles anteriores incompatibles; este ajuste no tiene nuevas pruebas ni renders por petición del usuario.

**Regla vigente — 11 de octubre de 2026:** feedback de errores, validación y resultados en el toast superior compartido en todas las funcionalidades. Sin texto bajo inputs, errorText/helperText ni indicadores circulares/lineales. Skeleton y LoadingShimmer para carga inicial/acciones; ContentRefresh con shimmer conserva contenido durante refresh. Se mantienen invalid/ShakeField, semántica, reintentos, etiquetas/datos e instrucciones de privacidad. [ADR-027](decisiones/027-feedback-global-toast-shimmer.md) sustituye las restricciones anteriores de feedback; las notas fechadas anteriores son historia de las decisiones.

La norma obligatoria es [REGLAS_UI_UX.md](REGLAS_UI_UX.md). Su referencia son las pantallas actuales de Login, Crear cuenta, Recuperar contraseña, Revisa tu correo, Nueva contraseña y Contraseña actualizada. Este documento es un índice de implementación; no mantiene otra paleta ni reglas diferentes. Sustituye las propuestas antiguas de superficies coloreadas y la UI retirada de Inicio.

## Componentes de referencia

Rutas relativas a `apps/mobile/lib`:

| Responsabilidad | Fuente |
| --- | --- |
| Layout, cabecera y scroll | `core/presentation/widgets/app_page_layout.dart` |
| Acción principal | `core/presentation/widgets/primary_action_button_style.dart` |
| Marca | `core/presentation/widgets/brand_mark.dart`, `brand_wordmark.dart` |
| Arranque horizontal con resorte | `core/presentation/widgets/startup_reveal.dart` |
| Cover y cambios de etapa | `core/presentation/widgets/cover_reveal.dart` |
| Stagger compartido | `core/presentation/widgets/stagger_reveal.dart` |
| Carga y atenuación | `core/presentation/widgets/loading_shimmer.dart` |
| Error de campo | `core/presentation/widgets/shake_field.dart` |
| Decoración de inputs de acceso | `features/auth/presentation/widgets/auth_input_decoration.dart` |
| Correo y OTP | `features/auth/presentation/widgets/email_code_confirmation.dart`, `email_code_input.dart` |
| Tema general | `core/theme/app_theme.dart` |

AuthPageLayout y authPrimaryButtonStyle delegan en las versiones compartidas de core. Mantienen geometría del flujo aprobado. No importar widgets de Auth desde otro módulo: extraer la responsabilidad común cuando corresponda.

## Referencias renderizadas

Desde la carpeta Flutter:

```powershell
flutter test --no-pub tool/capture_ui_preview.dart
```

Genera en `build/ui-preview` login, registro, solicitud de código, confirmaciones OTP, nueva contraseña, éxito, arranque y fases de cover/stagger/shimmer. Viewport normal 390 × 844, fuentes reales y repositorios sustituidos. Variantes pequeñas incluyen 320 × 350 con texto escala 2. Inicio provisional tiene `home.png` y `home_small.png`; conserva solo bienvenida y cierre de sesión hasta diseñar el módulo real.

Revisar capturas finales e intermedias, controles accesibles con teclado/scroll, estados de error y carga. Las capturas no prueban correo/Auth remoto ni fluidez en Android. Resultados y pendientes se registran en [ESTADO.md](ESTADO.md).

## Comportamientos conservados

El onboarding mantiene tres etapas después del primer ingreso y persistencia por cuenta según [ADR-004](decisiones/004-onboarding-por-cuenta.md), sin Omitir. Se conserva PageView y reveal textual, mascotas completas, margen de ilustración 12, alto proporcional .68 limitado a 180–460, indicadores 12/margen 5 y Continuar/Comenzar de radio 26/alto mínimo 68. Este diseño no sustituye la referencia normativa de acceso ni autoriza a copiarlo como otro estilo general.

Splash Android conserva fondo blanco y PNG 3D de marca. Su variante API 31+ usa margen proporcional de 33.3333% por lado para respetar la máscara. Debe verificarse tras recompilar/reinstalar con arranque frío; Hot Restart no actualiza recursos nativos. El resorte horizontal y el cover/stagger de Flutter se revisan tras Hot Restart.

## Inicio con cápsula liquid glass

Diseño autorizado el 8 de octubre de 2026: `features/home/presentation/widgets/liquid_navigation.dart` implementa superficie translúcida con blur, cápsula de cuatro destinos y acción Reportar separada. `home_content.dart` compone cabecera de contenido, tarjeta destacada, acciones y sección cercana; los módulos pendientes se identifican expresamente sin datos de ejemplo. `home_view_model.dart` controla selección y salida mediante el caso de uso existente de dominio, sin importar presentación de Auth.

QA añade `home_report.png`, `home_small.png` y `home_profile_small.png`. El cierre de sesión pasó a Perfil. La cabecera puede desplazarse con el contenido en pantallas pequeñas; queda fuera del efecto de cambio de sección. Esta entrega es el diseño navegable de Inicio, no la implementación de HU-02–HU-13 ni una prueba de sus servicios.

### Ajuste de navegación y paleta, 8 de octubre de 2026

La cápsula queda solo con iconos, manteniendo nombres accesibles/tooltip/selección semántica. Selección carbón #111111, icono blanco e inactivos #6E6E73, según los componentes reales de login. Acciones de Inicio y tema Material usan la paleta neutra del mockup. GlassSurface reduce la opacidad, aumenta blur a 22 y pinta doble borde de reflejo direccional en blanco/gris, con sombras neutras. No utiliza un shader de refracción física. Se conserva el panel Reportar, las cuatro secciones y la salida real.

### Nueve puntos e indicador deslizante

Ajuste aprobado el 8 de octubre: acción Reportar con puntos blancos 3 × 3 sobre círculo sólido #111111, sin GlassSurface. La cápsula conserva glass y usa un único indicador deslizante, interpolado en 320 ms, con retarget desde posición actual y movimiento reducido inmediato. Capturas adicionales: home_navigation_slide y home_explore. ADR-006 y REGLAS_UI_UX registran que esta animación local convive con cover/stagger del contenido.

Último ajuste de selección: InkWell de destinos usa NoSplash y overlay transparente para eliminar el destello de Material durante el deslizamiento. Se conserva el glass estático y el contraste del icono activo.

Cabecera de Inicio: BrandWordmark compartido con iconSize 46/textSize 22, dos líneas y sin lema. Sustituye la composición manual con nombre en una línea y subtítulo; conserva semántica continua de marca.

## Perfil de cuenta

HU-01.7 / RF-01, issue #23: pestaña Perfil con nombre visible y ciudad opcionales, validación, guardar/descartar y cierre de sesión existente. Usa los componentes aprobados de acceso. `core/presentation/widgets/app_input_decoration.dart` contiene la implementación compartida; `authInputDecoration` delega sin cambiar geometría/estados de login. ProfileEditor consume únicamente su ViewModel; router compone el formulario en Home.

QA incorpora profile, profile_loading, profile_load_error, profile_saving, profile_error, profile_saved, profile_small, profile_fields_small y profile_actions_small. Los datos de esos renders son fixtures exclusivas de pruebas; la app consulta el repositorio real inyectado. Cover/stagger sigue en el shell al entrar en la sección, sin repetirlo por edición, guardado o error.

Ajuste de Perfil: retirados encabezados redundantes y texto de instrucciones permanente; conserva un título Perfil y los dos campos. Cerrar sesión usa superficie roja tenue y texto de error aprobado, dimensiones compactas (mínimo 48, fuente 14) y carga compartida. Guardar permanece como acción principal; sin cambios de persistencia/permisos.

## Toast superior de confirmación

ConfirmationToastHost en core sustituye el texto permanente de éxito de Perfil por «Cambios guardados» flotante sobre la cabecera. Aviso compacto carbón/blanco con icono de éxito y cierre; expira sin modificar layout. Sin paquetes externos. El formulario conserva errores contextuales. Su lifecycle, accesibilidad y alcance están en ADR-007; entrada local independiente de cover/stagger del contenido. QA: profile_saved muestra el aviso; profile normal no lo muestra.

Toast revisado a estética iOS por petición del usuario: cápsula clara de ancho ajustado al mensaje, icono oscuro en medallón neutro y sin X. Cierre al tocar y acción accesible; fondo difuminado, borde claro y sombra leve. Mantiene comportamiento de confirmación y ciclo de vida. Revisión visual en profile_saved y profile_toast_small.

## Perfil desde cabecera

Perfil se abre mediante avatar circular de cabecera, logo/campana conservados. Home tiene tres destinos inferiores; ProfileScreen mantiene campos, toast y salida danger en una ruta superpuesta con cierre X/Atrás, sin barra inferior. OriginPageTransition reutilizado desde bounds de avatar; _ProfileEntrance espera completar apertura antes de stagger. Renders nuevos: profile_origin_start y profile_origin_middle; home/profile y variantes pequeñas actualizados. Avatar muestra foto privada de la cuenta, respaldo HTTPS de Google o iniciales reales. Galería/subida incorporadas mediante ADR-008 por solicitud posterior.

ProfilePhotoEditor agrupa avatar de 72, acción de cámara y Añadir/Cambiar foto. LoadingShimmer conserva etiqueta; fallo junto a la acción y reintento con bytes retenidos. Recuperación de selección ofrece Guardar foto recuperada/Descartar antes de enviar. ProfileEditor presenta Correo electrónico como SelectableText en superficie neutra con icono, sin TextField ni comando de escritura. Nombre/ciudad y salida danger conservan componentes existentes. Renders normal/pequeño con texto 2 revisados; no se acredita fluidez de galería nativa ni subida real con capturas de harness.

Retirados título/promesa de Inicio y su espaciado para priorizar contenido útil visible. El hero existente, acciones y Cerca de ti conservan composición y operaciones; timeline de entrada ajustado a los bloques reales.

## Ajuste autorizado de foto, ADR-009

Por nueva solicitud explícita del usuario, el avatar es el único acceso habitual al selector/reintento: retirados Añadir/Cambiar foto y error permanente. El toast compartido admite icono de error danger suave para fallos de foto, con el mismo ciclo de vida y sin generalizar a otros errores. La confirmación excepcional de selección recuperada se conserva. Ver ADR-009, que amplía el alcance de feedback de ADR-007/005.

## Registro y ficha de mascotas

Componentes en features/pets: PetsSection (lista/consulta vacía/error), PetScreenShell (cabecera persistente y cover/stagger), PetEditorScreen (seis grupos con inputs compartidos, selectores adaptables, error/shake y LoadingShimmer) y PetDetailScreen (campos reales y edición). Composición desde router evita acoplar Home a presentation de mascotas. Sin control de fotografías hasta HU-04.

QA reproducible: flutter test --no-pub test/pets_navigation_test.dart --concurrency=1 --dart-define=CAPTURE_PETS=true. Capturas pets_empty/form/species/detail/error/list en build/ui-preview, normal y 320x350 con texto 2. Repositorio de prueba solo en harness; la app consulta Supabase y distingue error de vacío. No acredita sesión/reinicio Android ni despliegue remoto.

## AppSelectField: selección acorde a los inputs

Corrección20/10/2026: la apertura de ruta del panel precede a una única línea
StaggerReveal de opciones. Sin AuthStageTransition/CoverReveal interior: evitamos
una segunda apertura y la cortina con el fondo de página dentro del panel blanco.
El stagger espera AnimationStatus.completed, sin temporizadores; reconstrucciones
y cierre conservan su estado. Movimiento reducido muestra opciones inmediatamente.

Core/presentation/widgets/app_select_field.dart implementa campo controlado reutilizando decoración compartida y panel inferior de opciones propio. Especie y Sexo en PetEditorScreen consumen el mismo componente; callback solo llama al ViewModel. AppSelectOption envuelve incluso valores null para diferenciar desconocido de cancelación. Sin SDK ni reglas de dominio en el componente.

Panel blanco sin elevación/tinte, radio superior 28; filas neutras de radio 18, estado activo carbón/check, iconos decorativos y etiquetas accesibles. Cabecera fuera de cover/stagger; cuerpo desplazable, texto ampliado y movimiento reducido conservados. Campo y flecha conservan dimensiones de input y foco/error. QA añade pets_options_normal/small; pruebas de selector comprueban cancelación, desconocido y bloqueo, junto al recorrido completo de mascotas.

## Placeholders de carga, ADR-011

PetSkeleton (widgets de pets) reutiliza LoadingShimmer con layouts de tarjetas/detalle/formulario. SkeletonFormFields en core comparte geometría escalable entre editor de mascotas y Perfil; no contiene operaciones ni datos simulados. PetRefreshProgress superpone línea de 2 píxeles sin alterar posiciones; TickerMode respeta movimiento reducido. Widgets diferencian loading inicial, refresh explícito con valor previo de la misma cuenta, error y vacío confirmado. No existe texto visible Cargando/Preparando ni spinner circular.

QA: pets_loading/detail_loading/editor_loading normal/pequeño en el harness de navegación con consultas pendientes; profile_loading en el harness general. Pet loading tests comprueban skeleton -> error -> reintento -> vacío confirmado y refresh con tarjetas que se ocultan al cambiar cuenta. La semántica de carga permanece accesible aunque no haya texto visible. Referencia de patrón: https://docs.flutter.dev/cookbook/effects/shimmer-loading.

## Ficha ampliada y fotos privadas, ADR-012

PetScreenShell coloca retorno fijo en SafeArea superior y contenido desplazable alineado arriba. PetSizeSelector ofrece tres chips neutros en fila horizontal desplazable, selección de borde carbón y etiqueta accesible; tocar el activo limpia tamaño. Campo Tipo de mascota aparece solo para Otra especie y reutiliza input/error existentes. PetPhotoGallery ofrece miniaturas de 112 píxeles/radio 22 y acción de añadir foto, sin botón duplicado ni datos simulados; hasta tres fotos, retirada accesible, shimmer real y errores contextuales. Ficha muestra fotos confirmadas y listado primera foto como portada.

QA: capturas pets_form/species/detail/editor_loading normal y 320x350 con texto 2; pruebas verifican retorno arriba, cancelación/selección/retirada, tipo/tamaño y persistencia. Selector nativo/fluidez Android pendientes de build funcional, no acreditados por capturas de widgets.

## Paleta del mockup aprobada, 9 de octubre de 2026

Referencia cromática: `mockups/Entre Huellas_ personajes 3D premium.png`. Fondo #FFFFFF, texto/acciones #111111, superficie #F5F5F7, texto secundario #6E6E73 y separadores #E5E5EA. AppTheme declara todos los roles Material mediante ColorScheme.light, incluidas superficies, contenedores y colores fijos; sin generación desde una semilla. AppColors conserva solo los tokens neutros y el error contextual de ADR-005. Componentes de acceso, Perfil, Inicio y mascotas alineados con estos valores.

PetSizeSelector reutiliza AppColors y desactiva surfaceTintColor para que el chip seleccionado conserve su superficie neutra. El borde y la semántica comunican selección. QA añade pets_size_selected y pets_edit_size en tamaños normal y pequeño con texto ampliado; el harness conserva selección, deselección y persistencia existentes.

## Texto y selección con etiqueta interior

AppFieldSurface contiene el marco, foco, error, etiqueta interior y espacio opcional del icono. AppTextField incorpora TextField nativo, controlador recibido, teclado/autofill, líneas y callbacks; posee y libera su FocusNode. AppSelectField reutiliza el marco y conserva el panel de selección, cancelación y valor null explícito. Ningún componente obtiene repositorios ni controla reglas de producto.

PetEditorScreen y ProfileEditor adoptan los campos; etiquetas externas retiradas de inputs/selectores. Correo de Perfil mantiene SelectableText dentro del mismo marco, sin comando de edición. Uso: AppTextField(label: 'Nombre', controller: controller); añadir icon: Icons.person_outline_rounded cuando se necesite. Para varias líneas, indicar minLines/maxLines. AppSelectField admite omitir icon y hint.

QA: flutter test --no-pub test/app_text_field_test.dart --concurrency=1 --dart-define=CAPTURE_FIELDS=true genera fields_empty/filled/selected/error_normal/small. Comprueba etiqueta accesible, escritura, multilinea, limpieza por controlador, bloqueo, error, selección sin icono y liberación al desmontar. Harness de mascotas y capturas generales verifican integración normal y 320x350 con texto 2. Datos de las capturas pertenecen exclusivamente a pruebas.

## Entrada única al resolver skeleton

PetScreenShell mantiene AuthStageTransition con etapa constante y usa ContentReveal: la línea de tiempo no se recrea al pasar carga -> ficha/formulario/error. ContentReveal completa el StaggerReveal al resolver una carga observada; contenido disponible desde el montaje conserva su entrada. Perfil reutiliza ContentReveal y mantiene la expansión de ruta. PetsSection recuerda haber mostrado skeleton y desactiva el StaggerRevealItem heredado del Home para el resultado. Refresh, reintento y cambio de cuenta conservan responsabilidades y privacidad previas.

content_reveal_test verifica respuestas rápidas durante el cover y lentas después de la entrada, datos/vacío/error inmediatamente opacos e interactivos, ausencia de nueva cortina, reintento y entrada inicial de contenido disponible con movimiento reducido. No se usan retrasos de producto para ajustar animación.

### Corrección de skeleton que aparece, se oculta y reaparece

AuthStageTransition admite enabled para omitir/cancelar la cortina sobre cargas; PetScreenShell lo desactiva mientras espera datos. ContentReveal completa la línea de tiempo desde que observa skeleton, no solo al resolverlo. Home desactiva cover/stagger en Mis mascotas. Así no se tapa otra vez el placeholder que ya se mostró.

PetDetailViewModel y PetEditorViewModel mantienen la carga de pantalla hasta completar en paralelo ReadPet e inicialización de fotos. PetPhotosViewModel.ensureInitialized comparte el Future inicial dentro del ciclo de cuenta/mascota; PetPhotoGallery lo reutiliza al montarse, conservando initialize para reintentos explícitos. Sin APIs/SDK en widgets, datos ficticios, demoras o cachés globales.

pet_screen_loading_test observa 20 frames con consulta pendiente, completa metadatos antes de fotos y comprueba que conserva el mismo elemento skeleton sin cortina, antes de mostrar una única galería sin segunda consulta. Incluye ficha/edición normal y pequeña con texto 2. content_reveal_test ahora exige skeleton completamente visible desde el montaje.

## Apertura de Registrar mascota desde origen

PetsSection obtiene bounds del botón mediante Builder/RenderBox y envía Rect en extra a /home/pets/new. Router reutiliza OriginPageTransition en CustomTransitionPage, con las mismas duraciones de Crear cuenta y Perfil. PetScreenShell mantiene la continuidad de skeleton de ADR-011. PetEditorScreen regresa con pop al cancelar y conserva navegación a ficha tras éxito.

Harness de mascotas verifica rectángulo del botón, apertura, contracción/cierre y reapertura sin perder la sección; capturas pets_register_origin_start/middle_normal/small muestran fases, junto al formulario final. Prueba compartida de OriginPageTransition cubre movimiento reducido.

## Botones equilibrados y fallo de eliminación en toast

PetDeletionDialog comparte geometría de ambas acciones mediante _DeletionActions: ancho/alto iguales, 48 mínimo, padding 8, radio 18 y fuente 14. LayoutBuilder/TextPainter comprueban si caben en fila y calculan altura común al apilar con texto ampliado. No heredar dimensiones distintas de FilledButton y OutlinedButton.

PetsSection retira los bloques de error bajo cada fila y envía error/éxito al ConfirmationToastHost. noticeId de PetDeletionState identifica cada resultado; el host permite acción opcional y anuncios repetidos. Conflicto ofrece Actualizar lista dentro del aviso. ADR-013 registra la excepción autorizada. Harness de mascotas genera pets_delete_confirmation y pets_delete_error_toast normal/pequeño; prueba de toast verifica repetición, acción, dismiss y disposición.

_DeletionActions ahora calcula ancho compacto desde la etiqueta más larga, usa padding 8/mínimo 48 y Align.bottomRight. Fila de ancho mínimo o columna alineada a la derecha con texto ampliado. Cancelar y Eliminar mantienen igualdad de tamaño, fuente y radio. Prueba de navegación comprueba tamaño y borde derecho del botón frente al grupo.

## Registro minimalista en Mis mascotas

PetRegistrationButton reúne variantes normal/compacta y captura del origen para /home/pets/new. PetsSection compone _PetsHeader con + Mascota solo si hay datos no vacíos; _PetsEmptyState ofrece huella mayor y Registrar mascota debajo del mensaje confirmado. Cabecera adapta fila/columna manteniendo acción derecha con texto ampliado. Fuente/colores/componentes compartidos conservados; no añade llamadas de producto a widgets.

Harness de mascotas verifica botón debajo de huella en vacío, ausencia de Registrar mascota ancho en listado, + Mascota en borde derecho, apertura desde ambos orígenes, cancelación/reapertura y persistencia. Capturas pets_empty/list/add_compact normal y pequeña con texto2. Renders siguen usando fixtures de pruebas y no acreditan Android remoto.

## Swipe continuo de eliminación

SwipePetCard usa AnimationController.unbounded con desplazamiento en píxeles: limitado al70% del ancho a la izquierda por corrección posterior, retorno a0 al soltar. Color rojo interpolado con recorrido y contentBuilder entrega foreground/secondary a textos/iconos conservando fotos. Retira el ClipRRect que encerraba toda la acción y el panel fijo Eliminar; el Material de la tarjeta conserva radio22 y recorte de su propio contenido.

onDelete ahora devuelve Future para bloquear duplicados hasta cerrar modal/terminar operación. Se espera endOfFrame tras el retorno para que el modal nunca cubra la tarjeta todavía desplazada. Listener distingue cancelación real del puntero; gesto cancelado y desmontaje no producen confirmación. Se retiran long press y CustomSemanticsAction de eliminación por petición de interacción exclusiva mediante swipe izquierdo; se conservan busy/disabled y LoadingShimmer durante borrado real.

swipe_pet_card_test verifica seguimiento, rojo progresivo, límite70% del ancho, retorno antes del callback, gesto corto/cancelado, bloqueo/duplicados, pulsación larga sin confirmación, disposición y movimiento reducido. Harness de mascotas captura swipe_partial/swipe durante drag y delete_confirmation después de retornar; confirmación/cancelación/error/reintento siguen pasando por ViewModel.

SwipePetCard añade ColorFiltered/BlendMode.srcATop sobre el contenido completo: texto/iconos/foto reciben tinte danger hasta32% según recorrido, por ajuste posterior del usuario. Filtro estable con intensidad0 en reposo, sin cambiar la estructura de widgets al iniciar/terminar el drag. Prueba de swipe incorpora Image e Icon, comprueba cobertura del filtro, variación y retorno al filtro inicial, y preserva el mismo elemento de imagen. Fondo interpola superficie a rojo contextual #C12F3D mediante easeOutCubic para intensificarse antes; texto/iconos interpolan sus colores originales a #FFE3E6 desde el inicio del recorrido con easeOutCubic compartido con fondo y filtro. Sustituye el salto negro/blanco basado en luminancia.

## Modal de eliminación con transformación de origen

SwipePetCard entrega Rect relativo al Navigator raíz después del frame de retorno. PetCardContent comparte la composición de foto/nombre/especie/icono entre listado y copia visual de origen. confirmPetDeletion usa showGeneralDialog y OriginDialogTransition, sin CoverReveal ni StaggerReveal. El layout final permanece estable; superficie interpola posición/tamaño/radio/color durante320ms. Copia original se desvanece hasta45%, destino aparece desde65% mediante originContentOpacity compartido con OriginPageTransition. Bloquear interacción/semántica del contenido hasta completar; movimiento reducido evita transformación. Cierre invierte la transición.

Cabecera del modal coloca cierre en su propia línea si texto ampliado deja poco ancho al título; scroll conserva acceso a todas las acciones en superficies pequeñas. Pruebas comprueban rectángulos de origen/destino, opacidad por etapas, reversa, interacción, movimiento reducido, límite del gesto y ausencia de cover/stagger en modal. Capturas delete_origin_start/middle y delete_confirmation complementan la revisión normal/pequeña.

PetCardContent compacta nombre y especie/texto secundario: gap2 (antes4), TextStyle.height1.2 para nombre y1.25 para secundario; padding vertical14 (antes20), horizontal20 conservado. Mantiene foto56 y altura flexible para texto ampliado/nombres largos. Reutilización en listado y copia de origen evita divergencia al abrir confirmación.

Corrección de retorno: OriginDialogTransition distingue cierre, omite copia de origen al contraerse y desvanece overlay en el último18% para dejar visible la tarjeta real. Material.animationDuration=Duration.zero evita una segunda animación de forma/color con retraso. La superficie alcanza el mismo Rect; origen real no se transforma. Prueba verifica cierre sin copia, overlay final invisible y ausencia de animación implícita. Color de texto/iconos y filtro del swipe cambian desde el inicio con easeOutCubic compartido con fondo, por corrección posterior del usuario.

PetRegistrationButton.compact ahora es FilledButton con CircleBorder, tamaño56, padding0, fondo ink e icono add_rounded blanco26 con semanticLabel Registrar mascota. Sin etiqueta Mascota visible; tooltip conservado. Key pet-add-compact identifica acción en harness sin depender de texto. Mantiene origen de navegación/cabecera derecha; variante de vacío conserva icono y etiqueta completa. SwipePetCard ya no registra pulsación larga ni acción semántica de eliminación, por instrucción de acceso exclusivo desde swipe izquierdo.

_PetsHeader conserva Row para carga/vacío/listado en ancho normal; SizedBox.square56 sustituye acción ausente y mantiene posición del título al aparecer el círculo. En layout apilado mantiene título primero. Harness compara desplazamiento del título respecto a PetsSection antes/después de registrar, independiente del scroll de navegación.

## Identidad y retorno de la ficha

PetDetailScreen elimina «Ficha de mascota» y presenta galería sobre el nombre (encabezado accesible de32). _PetIdentity observa PetPhotosViewModel para ocultar la huella al existir fotos; no accede a infraestructura. PetPhotoGallery admite tileSize; editor conserva112 y ficha usa ancho disponible limitado a160. PetSkeleton.detail sigue foto/nombre/datos. GlassSurface se extrae sin cambiar su acabado a core/presentation/widgets/glass_surface.dart; navegación y retorno circular de ficha lo reutilizan sin imports entre funcionalidades.

PetScreenShell con glassBack usa scroll a altura completa y retorno posicionado por encima, sin franja blanca superior. Padding inicial incluye inset superior +72; chevrón fijo en inset +4. Registrar/Editar comparten ahora el mismo layout flotante según ADR-015. PetSkeleton.detail reduce su foto a160. Prueba de carga/identidad verifica que al desplazar la galería ocupa el espacio detrás del retorno y el botón no se mueve.

_PetIdentity calcula un único tamaño en LayoutBuilder para foto y huella sustitutiva; ambos comparten dimensión hasta160 y separación inferior20. Icono decorativo excluido de semántica.

## Retorno común y selector de ancho completo

GlassNavigationButton en core reutiliza GlassSurface y centraliza círculo52/icono28/tooltip para volver/cerrar pantallas. PetScreenShell lo superpone en Stack para ficha, registro y edición; se elimina glassBack y la variante plana. ProfileScreen conserva cierre fijo sobre scroll; AppPageLayout reutiliza el mismo botón con X. ADR-015 registra la regla general.

PetSizeSelector usa Expanded en tres columnas con dos gaps8. ChoiceChip conserva callback/selección/borde neutro; label ocupa el ancho interior disponible. Con texto ampliado/ancho limitado dispone icono sobre texto adaptable. Harness de navegación verifica extremos y anchos iguales y genera size_selected en ambos tamaños.

## Confirmación de cambios sin guardar de mascotas

PetEditorState.hasUnsavedChanges distingue registro vacío de formulario modificado y compara edición con original; dirty conserva su semántica para guardado/validación. PetEditorScreen usa PopScope y el callback onBack de PetScreenShell para unificar salida por glass/sistema. Fotos pendientes también activan el guard. PetDiscardDialog reutiliza OriginDialogTransition con acciones reales y scroll. Confirmar salida limpia pending mediante PetPhotosViewModel.discardPending, sin tocar fotografías confirmadas, antes de cerrar. Rechazar salida conserva controladores/selecciones/fotos; guardado confirmado omite el aviso.

## Ficha abierta desde su tarjeta

PetsSection captura el Rect de la tarjeta pulsada mediante Builder/RenderBox y lo entrega como extra a /home/pets/:id. Router compone CustomTransitionPage con OriginPageTransition compartido, apertura320ms/cierre260ms y movimiento reducido. Sin Rect conserva NoTransitionPage y las semánticas previas de Pet guardado e inspect. No modifica consultas ni reinicia entradas al resolver skeleton. Harness de mascotas comprueba origen/retorno y captura detail_origin_start/middle/close normal y320×350 texto2.

## Editor de mascotas pulido — ADR-016

PetPhotoGallery editable usa tileSize calculado hasta160, igual que ficha; skeleton acompaña. Nombre/especie/tamaño/edad/rasgos obligatorios, sexo opcional/Macho inicial, especie sin valor con placeholder Seleccionar. AppFieldSurface/AppTextField/AppSelectField admiten invalid sin errorText; PetSizeSelector adapta borde danger sin overflow con texto ampliado. Rasgos o descripción muestra contador interno0/200 y UnicodeLengthLimitingFormatter coherente con dominio/SQL.

PetEditorState.invalidFields reúne fallos del dominio; ViewModel valida antes de enviar, incrementa errorId por intento y limpia solo el campo editado. Formulario y galería editable usan ConfirmationToastHost/ShakeField para errores, sin bloques de texto inferiores; aviso de conflicto conserva Ver ficha actual. PetPhotosState.errorId permite repetir fallos. ConfirmationToastHost maneja también estado confirmado al montar y limpia overlay/timer. Fotos de ficha mantienen feedback contextual. Nueva norma en ADR-016.

## Fotos pendientes hasta guardar — ADR-017

Quitar foto oculta la miniatura solo en el borrador editable; no borra el archivo al tocar X. Ficha mantiene fotos confirmadas. Añadir prepara vista previa local, y quitar una selección local la descarta sin llamadas remotas. Guardar contempla también retiradas sin cambios de campos; continuar conserva el borrador y Salir sin guardar restaura las fotografías confirmadas. Límite de tres aplicado al resultado previsto permite reemplazar. Feedback de guardado fallido conserva shake danger/toast de ADR-016 y pendientes para reintentar.

## Activas/Archivadas y acciones de ciclo de vida

PetsSection ofrece PetListFilter para Activas/Archivadas: cápsula gris #E5E5EA, dos segmentos iguales y un indicador carbón #111111 deslizante con texto blanco, sin check ni bordes individuales, según referencia explícita del usuario. Tipografía del tema14/600, padding6 y área táctil mínima48; letras ampliadas que no caben en fila se apilan dentro de la misma superficie, sin reducir ni truncar. Indicador y colores de ambas etiquetas comparten un único progreso TweenAnimationBuilder320ms/easeInOutCubic: color interpolado carbón/blanco según la posición, con reorientación desde el progreso vigente al cambiar de destino. Inmediato con movimiento reducido y orden RTL respetado. Mantiene consultas independientes y vacío específico de Archivadas. La ficha conserva Editar y añade acción secundaria Archivar/Restaurar con icono, etiqueta estable y LoadingShimmer durante la RPC. Archivo pide confirmación mediante OriginDialogTransition compartida, modal neutro desplazable y acciones que se ajustan al ancho; cancelar no escribe. Estado archivado comunica conservación de ficha/fotos. Errores contextuales bajo la acción, actualización ante conflicto y toast superior de éxito confirmado. Retorno glass y edición se deshabilitan durante la operación; PopScope protege Atrás. Eliminación por swipe conserva su feedback autorizado y explica restricciones por historial. Sin nueva animación de entrada al confirmar o refrescar.

## Continuidad visual del botón al registrar

PetRegistrationButton comparte _content entre botón y copia visual, conserva tipografía/padding/iconos y entrega OriginPageSource al router. OriginPageTransition recibe la identidad solo para pets/new y transforma carbón/radio/Rect; contenido de origen fijo y centrado, sin estiramiento, desaparece hasta45% y reaparece al contraer; destino desde65%. Otras rutas conservan parámetros anteriores. Capturas register_origin_start/middle/close/return y compact_origin_start/morph cubren las dos variantes normal y320×350 texto2; prueba compartida verifica identidad inicial/final, reversa, bloqueo y movimiento reducido.

## Zonas de interés — HU-02.1

Perfil abre `/home/interest-zones`, protegida por login/onboarding. Título32 carbón, margen24/max440, retorno GlassNavigationButton flotante con chevrón. Listado privado muestra vacío confirmado, radio, Editar/Eliminar con confirmación y Añadir zona; conserva datos con progreso fino al actualizar. Error inicial tiene Reintentar y nunca se representa como vacío.

Editor usa campo de nombre, mapa280 con selección manual/círculo métrico, radio0.1–50km y alternativa expandible Indicar coordenadas. Atribución OSM visible fuera del mapa para texto ampliado; fallo permite reintentar mapa y conserva formulario. Guardar mantiene etiqueta/shimmer y éxito confirmado en toast superior; errores contextuales, shake de nombre y consulta de versión actual con confirmación de descarte. Atrás/retorno bloqueados durante escritura; cancelar no persiste.

Cabecera queda fuera de cover/stagger; pasos listado/editor los usan sin reinicios por edición/slider/teclado. Inicio del scroll restaurado al cambiar etapa. Renders con fuentes reales se generan con `flutter test --no-pub --dart-define=CAPTURE_ZONES=true test/interest_zones_test.dart` en `build/ui-preview/zones`; tamaños390×844 y320×350 texto2, incluido modal completo. Las fixtures no son datos de producto ni cartografía remota validada. Véase ADR-018.

## Preferencias de alertas — HU-02.2

Perfil enlaza a Preferencias de alertas: título32, ancho440/margen24, scroll y GlassNavigationButton flotante con chevrón. Secciones de recepción, tipos y canales usan interruptores neutros con etiquetas ampliables; elecciones editables incluso pausadas. Texto explica recepción futura, sin controles de permisos/envío. Guardar preferencias conserva etiqueta y LoadingShimmer solo durante escritura. Errores junto a guardar; conflictos ofrecen consulta actual confirmando descarte. Éxito en ConfirmationToastHost ligado a cuenta/confirmación. Actualizar conserva contenido con progreso fino; carga inicial skeleton y cambio de cuenta oculta datos previos. Entrada cover/stagger sin repetir al alternar interruptores. Modal compartido en core, con scroll y acciones ampliables. ADR-019 registra alcance y contratos.

## Gestión de fotos — HU-04.1/#30 y HU-04.2/#31

Galería del editor conserva tiles, shake danger y toast superior. Añade Tomar foto con alternativa de galería ante permiso/cámara no disponible; principal mediante estrella de48 de área táctil, tooltip y semántica selected. Imagen, retirada y principal son borrador hasta guardar; descartarlos no escribe. Ficha indica la principal confirmada y listado usa su miniatura limpia. Retirar principal selecciona la publicada más antigua o ninguna si no quedan fotos, según ADR-020. Conflicto de principal ofrece Consultar fotos antes de reintentar; no anuncia éxito por cambiar la estrella local. Renders del componente en build/ui-preview/photos/primary_normal.png y primary_small.png (390×844 y320×350 texto2) con fuentes reales y fotos de prueba, sin incorporar fixtures al producto. Los flujos de editor/navegación existentes siguen cubiertos por la suite Flutter.

## Casos perdidos — HU-05

Entrada por Reportar, sin AppBar genérica. CaseScreenShell mantiene cabecera fuera de cover/stagger y GlassNavigationButton flotante; scroll vuelve arriba solo al cambiar etapa formulario/vista previa/confirmación. Selector de mascota, fotos públicas explícitas, calendario/reloj, mapa compartido y coordenadas alternativas, referencia privada y vista previa. Campos/persistencia con errores contextuales; acción Publicar caso conserva etiqueta con LoadingShimmer y bloquea duplicados. Confirmación es una etapa persistida con acción Ver ficha pública. Consultas usan skeleton inicial y contenido retenido con progreso fino durante actualización explícita, sin circular ni textos de carga. Renders en build/ui-preview/cases:390×844 y320×350 texto2; fixtures no acreditan cartografía/bytes reales ni rendimiento Android.

## Casos encontrados — HU-06

Reportar → Mascota encontrada abre Reportar hallazgo, con geometría y shell compartidos con casos perdidos; título32 permite texto ampliado sin partir palabras. Especie/rasgos obligatorios, opcionales explícitos sin datos inventados, fotos cuadradas160 de galería/cámara, fecha/hora y lugar manual con referencia privada. Contador interior de rasgos200, validación contextual/shake y Publicar caso con etiqueta estable/shimmer. Vista previa incluye fotos/custodia/datos públicos aproximados; punto/referencia privados excluidos. Mis encontrados diferencia draft de publicación; descarte de pendientes requiere confirmación y limpieza autorizada. Renders en build/ui-preview/found-cases con fuentes reales,390×844 y320×350 texto2; solo fixtures locales, sin acreditar mapa/Storage real. Cover/stagger por etapa, glass flotante, skeleton/progreso fino y movimiento reducido según reglas vigentes.

Los accesos conservan el nombre Mis encontrados; el título de su pantalla usa Mis reportes para mantener palabras completas con texto ampliado. La limpieza tardía se presenta como pendiente y conserva reintento autorizado, sin mostrarse como publicación.


## Feedback de reportes: corrección del 10 de octubre de 2026

Por instrucción explícita del usuario, los mensajes de error, validación y resultado se muestran en el toast superior compartido, sin texto contextual dentro de la pantalla ni debajo de campos/acciones. Esta instrucción sustituye las restricciones anteriores que reservaban el toast a excepciones y exigían feedback contextual. Etiquetas, datos, estados e instrucciones de privacidad se mantienen. El incremento adapta los flujos de reportes perdidos/encontrados; conserva invalid/ShakeField, acciones de reintento y ciclo de vida del aviso. Las demás funcionalidades existentes se adaptarán al intervenir sus flujos; no se afirma una migración global completada. Véase [ADR-023](decisiones/023-feedback-reportes-toast-superior.md).


## Reutilización de carga y confirmaciones — 10 de octubre de 2026

Resolver skeleton a datos/vacío/error pertenece a la misma entrada: AuthStageTransition conserva el subárbol cuando vuelve a habilitarse después de carga; ContentReveal conserva su historial de skeleton. Vista previa/confirmación siguen siendo cambios discretos con cover seguido de stagger. No usar un nuevo reveal por terminar una consulta.

Todas las confirmaciones de salir/descartar/archivar/eliminar delegan en confirmActionDialog de core: ruta, transición OriginDialogTransition, superficie centrada/ancho máximo420, padding24, cabecera/cierre, scroll y acciones. Se conserva la geometría aprobada de eliminación: pareja de botones con igual tamaño, alineados a la derecha, cancelar primero y confirmar después; se apilan según ancho/texto medido. Altura mínima48 y radio18, ampliables; el tamaño del contenido y las etiquetas pueden variar sin cambiar la regla de composición. Solo texto, semántica, origen de apertura y carácter destructivo se parametrizan. Los wrappers de funcionalidad no construyen botones ni layout.


## Reporte perdido: mapa y fotos compartidas — 10 de octubre de 2026

Por instrucción del usuario, HU-05 retira campos/lectura de coordenadas numéricas del formulario: selección manual en mapa sin GPS, preservando coordenadas privadas internamente. Fotos del formulario y vista previa reutilizan PhotoGalleryStrip/PhotoGalleryTile de core, extraídos de la galería de mascotas; misma geometría de detalle112–160, separación10, radio22 y scroll horizontal. Selección de fotos públicas pertenece al ViewModel del reporte, sin cambiar principal ni contenido privado de la mascota. No copiar galerías con disposición vertical al incorporar este recorrido.


## Vista previa de publicación inmersiva — 10 de octubre de 2026

Por referencia e instrucción explícita del usuario, perdidos/encontrados comparten CasePublicationPreview: fotografías protagonistas deslizables a ancho completo, indicador de foto, nombre/especie destacado y panel inferior GlassSurface con datos y acciones reales. CaseScreenShell conserva retorno glass, cabecera fuera de la transición, scroll y cover→stagger por etapa; se eliminan márgenes/cabecera de formulario solo en vista previa. La galería del formulario sigue usando PhotoGalleryStrip/PhotoGalleryTile; la vista previa sustituye sus tiles por el pager protagonista. primaryActionButtonStyle, LoadingShimmer y toast mantienen implementación única.

ExpandableDescription comparte contracción a dos líneas y expansión/contracción al tocar el texto, con AnimatedSize320ms/easeInOutCubic. Movimiento reducido presenta contenido inmediatamente. No reproduce el reveal ni cambia foto, borrador o envío al expandir. Se permite scroll y crecimiento con texto ampliado. Datos privados/funcionalidades de venta de la referencia no se añaden. Decisión y revisión en [ADR-024](decisiones/024-vista-previa-publicacion-inmersiva.md).


## Scroll continuo hasta el área del gesto — 10 de octubre de 2026

Por captura e instrucción del usuario, las páginas con scroll usan ScrollSafeArea de core: el viewport llega al borde inferior y no reserva una banda blanca fija con SafeArea(bottom:true). El espacio del gesto se suma al padding final del contenido y a los controles flotantes mediante bottomPadding; con teclado abierto se usa el inset efectivo, sin sumar una segunda franja. Mantener protegidos el último campo/botón y los márgenes laterales/superiores. La barra de navegación del sistema se solicita transparente, sin divisor ni contraste opaco; iconos oscuros sobre formularios y claros sobre vista previa fotográfica. Modales/onboarding mantienen sus áreas seguras específicas. Véase [ADR-025](decisiones/025-scroll-continuo-area-gesto.md).


Ficha pública y vista previa de perdidos/encontrados deben usar la misma composición CasePublicationPreview, con fotos grandes deslizables, panel glass y descripción expandible. Solo cambian título, texto preventivo y acciones según el estado del recorrido; no conservar una ficha con layout anterior. En el formulario de perdida se retiran Volver a consultar fotos y Mis casos; la recuperación de envíos ambiguos sigue disponible. Véase ADR-024 actualizado.


Actualización del 10 de octubre de 2026: por instrucción del usuario se retira el título glass flotante de la ficha/vista previa inmersiva; se conserva únicamente GlassNavigationButton para volver. Fecha del suceso a20px/negrita, con ajuste por texto ampliado. La ubicación se representa mediante ZoneMapPicker compartido en modo lectura, con la zona aproximada pública, círculo y sin marcador de punto exacto; formulario conserva edición del punto privado. Preview usa la proyección aproximada existente y ficha solo las coordenadas públicas del contrato. Errores del mapa usan toast superior compartido y conservan Reintentar mapa, sin mensajes bajo el mapa ni solicitud de coordenadas numéricas. La consulta no modifica ubicación ni captura el scroll vertical. Sustituye las indicaciones previas de título inmersivo y ubicación explicada solo por texto.


## Listas de casos consistentes con mascotas — 10 de octubre de 2026

Por instrucción del usuario, Mis casos/Mis reportes usan la implementación extraída de Mis mascotas a core: EntityCardContent/EntityCardSurface, SwipeActionCard, TwoOptionFilter, CollectionHeader/CollectionAddButton. Mascotas delega en los mismos componentes y conserva su referencia aprobada. Abiertos/Resueltos, foto real disponible y botón+ de56 reemplazan ListTile y el botón grande inferior. Swipe devuelve posición y abre confirmActionDialog común; shimmer/errores/confirmación siguen el patrón existente. Borradores encontrados conservan descarte con superficie compartida. Presentación consume ViewModels/casos de uso; dominio no adquiere dependencias de Flutter/SDK. Incremento de gestión por dueño solicitado sobre HU-05/RF-05 y HU-06/RF-06: eliminación de casos active/resolved y consulta privada de resueltos, con IDs/historial conservados y permisos versionados en016. No implica cierre de historias. Véase [ADR-026](decisiones/026-listas-casos-componentes-compartidos.md).

## Componentes consolidados — 11 de octubre

ContentRefresh delega en LoadingShimmer con semántica de contenido. FailureFeedback ofrece toast y acción real de reintento. ValidationSurface reúne semántica, ShakeField y borde danger para fotos/mapa. Galería encontrada reutiliza PhotoGalleryStrip/PhotoGalleryTile. Los campos compartidos no aceptan textos de error/ayuda debajo del input. Los avisos largos se recorren en el toast acotado; las acciones de pantalla permanecen alcanzables. ADR-027/028 conservan las decisiones y ESTADO la evidencia.

## Skeleton de ficha/vista previa de casos — 11 de octubre

CasePublicSkeleton sustituye SkeletonFormFields en la carga inicial de las fichas perdidas/encontradas. Conserva la composición inmersiva: espacio de foto, nombre, panel GlassSurface con formas de datos y mapa; usa LoadingShimmer sin textos visibles, datos ficticios ni petición de tiles. La navegación glass permanece fuera del efecto. CasePreviewGeometry comparte espacio superior/márgenes/radio con CasePublicationPreview; la altura del mapa reutiliza ZoneMapPicker.viewportHeight. CasePhotoView comparte foto local/remota, shimmer hasta primer fotograma y CasePhotoFailure para error con toast. El refresh de la misma cuenta conserva contenido mediante ContentRefresh; el skeleton no sustituye esos datos.

Pruebas en case_loading_test.dart cubren ambos tipos/tamaños, fin de consulta y primer fotograma/fallo de foto. Capturas en build/ui-preview/case-loading. El skeleton representa una estructura de contenido, no la longitud desconocida de cada dato del servidor.

## Apertura de mascotas y casos — 11 de octubre

app/navigation/entity_detail_page.dart centraliza la configuración de la apertura y el retorno. ManagedCaseCollection entrega el rectángulo de tarjeta como Mis mascotas; sus pantallas pasan extra sin importar app. No hay acción permanente Volver a consultar en ninguna pantalla. Reintentar se conserva condicionado al fallo, con toast. Fichas/vista previa mantienen sus campos y composición aprobados, skeleton y navegación glass; la apertura comparte ahora el comportamiento de mascotas. ADR-029 y pruebas case_navigation_test.dart/pets_navigation_test.dart conservan las comprobaciones.


## Panel de ficha expandible — 11 de octubre de 2026

Por solicitud del usuario, ficha pública y vista previa comparten un panel inferior arrastrable con apertura por toque en el indicador; foto/pager permanecen detrás. Desaparición (Encuentro en encontrados) aparece en badge fuera del glass, junto al nombre cuando hay espacio y debajo con texto ampliado. Nombre con sombra leve, máximo dos líneas y elipsis; la etiqueta accesible conserva el nombre completo. El mapa no se monta hasta abrir el panel; fecha, ubicación aproximada y privacidad se muestran en los datos ampliados. El contenido se desplaza dentro del panel y las acciones existentes conservan sus operaciones reales. Movimiento reducido desactiva animación y snap; no se reproduce reveal durante gestos. Véase [ADR-030](decisiones/030-panel-ficha-expandible.md).


### Corrección del anclaje inferior — 11 de octubre de 2026

Por corrección del usuario, el resumen inicial baja (36% del viewport para ficha sin acciones,46% para vista previa con acciones; texto ampliado conserva espacio desplazable). El panel glass ocupa como mínimo el espacio restante hasta el margen seguro inferior aunque haya pocos datos, evitando una tarjeta suspendida con vacío debajo. Nombre con sombra más sutil: opacidad20%, blur3 y desplazamiento vertical1. Apertura/mapa/acciones conservados.


## Casos con la referencia aprobada de Mascotas — 11 de octubre de 2026

Por instrucción del usuario, la UI de Mascotas se conserva y se reutiliza en Casos. EntityScreenShell y entityEditorPage extraen su contenedor/apertura existentes: mismos márgenes, navegación glass y cover→stagger, fuente visual del botón y retorno. Registrar perdido/encontrado desde Reportar o+ usa esa misma transición; todos los campos, fotos, instrucciones y acciones participan del timeline existente, sin reiniciarlo por edición/teclado/selección. PhotoAddTile y SizeChoiceSelector comparten las implementaciones aprobadas; Encontrados conserva tamaño/sexo/custodia opcionales y los contratos del reporte. Listados usan cabecera/grupo de contenido con entrada compartida, sin count por registro. No se altera el panel de ficha inmersiva solicitado en ADR-030. Véase [ADR-031](decisiones/031-casos-reutilizan-ui-mascotas.md).

Validación local: suite completa309 pruebas aprobadas;8 regresiones nuevas repetidas tras reforzar el descarte en tamaños390×844/320×350 texto2 y movimiento reducido. Renders revisados en build/ui-preview/case-creation. Pendiente revisar Android autenticado con fotos/teselas reales; la aprobación visual no cierra historias ni confirma backend remoto.


## Fecha y hora independientes — 11 de octubre de 2026

Por solicitud del usuario, los reportes muestran Fecha y Hora en dos inputs con AppFieldSurface, lado a lado en tamaño normal y apilados con texto ampliado. EventDateTimeFields se comparte entre perdidos/encontrados, con calendario y reloj separados. EventDateTimeDraft conserva selecciones parciales en el estado del ViewModel: elegir una no inventa la otra; el timestamp existe solo con ambas y cambiar una conserva la otra. Las operaciones bloqueadas por envío/respuesta ambigua siguen sin admitir cambios. Valores existentes preservan UTC/segundos hasta una edición explícita. Validación, shake/toast y entrada por stagger conservados. [ADR-032](decisiones/032-fecha-hora-independientes-casos.md).

Edición revisada: casos publicados todavía no tienen contrato/caso de uso/RPC de actualización ni ruta de edición. Editar reporte modifica solo el borrador antes de publicar. Recomendación propuesta: permitir al autor corregir información de casos abiertos, con versionado/historial y misma ficha; alcance todavía no aprobado ni implementado.


## Consistencia de formularios perdido/hallazgo — 11 de octubre de 2026

Corrección explícita del usuario tras detectar controles extra en hallazgo. Se retiran Latitud/Longitud, Usar coordenadas, lectura numérica del punto, Recuperar foto interrumpida y el acceso permanente Mis encontrados dentro del formulario. CaseLocationFields de core compone ambos formularios con la misma selección en mapa, instrucciones de privacidad, referencia privada, invalid/shake y stagger; solo cambia el título del suceso y los callbacks del ViewModel. Coordenadas continúan internas, sin nueva captura numérica ni GPS. Fecha/hora siguen compartidas por ADR-032. Fotos usan la misma etiqueta pública y galerías/controles compartidos.

Se conservan las diferencias propias del producto: perdido elige mascota/fotos registradas; hallazgo describe y fotografía una mascota sin dueño conocido y permite custodia opcional. Consultar la lista permanece solo ante envío ambiguo, igual en ambos recorridos. La API de recuperación de fotos permanece para el ciclo de vida existente, sin botón técnico permanente ni afirmación de recuperación automática nueva. [ADR-033](decisiones/033-formularios-reportes-consistentes.md).

Validación:50 pruebas de reportes, entrada real, preview, arquitectura y consistencia aprobadas; análisis sin incidencias. Las8 pruebas de creación verifican controles retirados ausentes, uso del bloque común, punto del mapa entregado al estado y ausencia de coordenadas visibles, tamaños390×844/320×350 texto2 y movimiento reducido. Capturas regeneradas y revisadas; no acreditan fotos/teselas reales. Revisión Android pendiente.


## Nuevo significado de búsqueda y aviso — 11 de octubre de2026

Por instrucción del usuario, Mascota perdida admite Mi mascota u Otra mascota posiblemente perdida. Mascota encontrada avisa en una búsqueda abierta con La vi o La encontré y está conmigo, sin cerrarla. Desde ficha se vincula automáticamente el aviso; solo el autor confirma Ya fue recuperada. Se conservan UI de Mascotas, coordenadas privadas/zonas públicas y órdenes estables. Aviso admite foto opcional; búsqueda comunitaria exige fotos. Registros anteriores siguen como Reporte anterior, sin reclasificación automática. [ADR-034](decisiones/034-busquedas-y-avisos-vinculados.md) y [ficha](funcionalidades/busquedas-y-avisos.md).

Cambio de alcance autorizado: HU-05/RF-05 y HU-06/RF-06; se adelantan partes app de HU-10/RF-11 y confirmación de HU-13/RF-07. No se cierran historias ni se entrega web/QR, moderación completa, push o exploración/paginación de HU-07. Fuentes062–065/plan018, migración generada y probada localmente; activación remota/Android y concurrencia multiconexión pendientes.


Mi mascota/Otra mascota es selección local del formulario de búsqueda: título/GlassNavigationButton/TwoOptionFilter persistentes, cuerpo con cambio inmediato, sin transición entre opciones. No reinicia skeleton/cover/stagger al alternar. Mantiene cada borrador hasta salir; confirma descarte al salir. Ver [ADR-035](decisiones/035-alternar-origen-sin-recargar-formulario.md).


Reportar compacto: dos filas de opción con icono/nombre/descripción14 regular/chevrón, superficieF5F5F7, título28/700 negro, separación12 y padding24. Sin párrafo largo, Cerrar o enlaces de consulta. Inicio centraliza gestión en Mis reportes con componentes de Mascotas; + reaprovecha el panel. Texto ampliado permite scroll y seleccionar por etiqueta. [ADR-036](decisiones/036-reportar-y-mis-reportes.md).


Reportar directo y aviso contextual: Inicio/navegación/+ abren formulario de pérdida sin panel. Ficha abierta ofrece La vi o la encontré; aviso presenta referencia estática y tipo de observación, sin selector de destinos. Toast y retorno ante destino cerrado, conservando borrador hasta salir. Origen real del control y apertura compartida conservados. [ADR-037](decisiones/037-avisos-desde-ficha.md).


## Mascota perdida: formulario único — 12 de octubre de 2026

Mascota a reportar usa AppSelectField con fichas existentes y No está en mis mascotas; panel corto Mascota. Sustituye pestañas Mi mascota/Otra mascota. Resumen de datos disponibles/fotos de ficha o descripción/fotos sin registro propio; CaseReportFields comparte fecha/hora/mapa/referencia/revisión con avisos y editores. Un solo bloque visible, conservado al seleccionar sin recarga/reveal; datos/fotos de origen separados. Shell, glass, controles, feedback y vista previa mantienen referencia. [ADR-038](decisiones/038-formulario-unico-mascota-perdida.md). Renders normal/pequeño en build/ui-preview/unified-report; no acreditan Android/teselas/fotos reales.


## Explorar: lista filtrada — 15 de octubre de 2026

ExploreSection compuesta en Inicio mediante app: CollectionHeader, EntityCardSurface/EntityCardContent, AppSelectField, primaryActionButtonStyle, LoadingShimmer, ContentRefresh y ConfirmationToastHost compartidos. Filtrar casos despliega controles en el scroll, con centro manual ZoneMapPicker si se pide distancia. ShakeField/borde danger ante radio sin centro. Reutiliza cover→stagger de HomeScreen y no lo reinicia al consultar. Skeleton inicial, datos conservados en refresh, resultados anteriores ocultos al cambiar filtros; error distinto de vacío confirmado. Tarjetas sin swipe de gestión, apertura con origen hacia fichas existentes. Render normal390×844 y pequeño320×350/texto2/movimiento reducido documentado en ESTADO. [Ficha](funcionalidades/explorar.md).


## Explorar: foto protagonista en grilla — 15 de octubre de 2026

Por preferencia explícita del usuario, sustituye las filas con EntityCardContent descritas arriba. ExploreCaseGrid mantiene EntityCardSurface/radio22, separación horizontal14/vertical16 y foto horizontal4:3 mediante CasePhotoView. Por aclaración del usuario, dos columnas completas desde280px de contenido con texto16 escalado hasta21; margen lateral12 en el shell de Explorar y separación14. La grilla no incorpora scroll propio: usa únicamente el vertical del shell. Una columna del ancho disponible en otro caso. Título y filtros añaden12px internos para conservar alineación24. Alturas naturales igualadas por fila, texto sin truncar y sin scroll interno. Nombre/tipo20 negrita y especie/distancia debajo. Por corrección del usuario, se retira la fecha de la tarjeta y el estado se coloca como badge neutro en la esquina superior derecha de la imagen. Skeleton de cuatro cards; reporte sin foto con superficie neutra. Entrada, filtros, páginas y toast permanecen. [ADR-040](decisiones/040-explorar-grilla-fotografica.md).


## Filtrar casos como panel flotante — 15 de octubre de 2026

Sustituye el desplegable que empujaba la grilla. FilterPopover<T> mantiene una cápsula estable y abre DialogRoute en el Navigator raíz. Panel blanco de ancho máximo440/radio28, cabecera con Filtros y GlassNavigationButton X; cuerpo desplazable con cover→stagger. FilterChoiceGroup<T> usa la misma SelectionPillSurface extraída de TwoOptionFilter: fondoE5E5EA, padding6, indicador negro/radio26 y tipografía14/600. Mide fuentes del tema y texto ampliado para distribuir opciones, sin truncar. Selección provisional solo se confirma con Aplicar filtros; se descarta al cancelar. Apertura/cierre no cambia rectángulos de tarjetas. Renders normales/pequeños en build/ui-preview/explore/*filters-top.png y *filters.png; [ADR-041](decisiones/041-filtros-flotantes-reutilizables.md).


## Filtros desplegados dentro de Explorar — 15 de octubre de 2026

Por corrección del usuario, se retira FilterPopover y se usa FilterExpansion<T>, sin DialogRoute ni popup. Conserva SelectionPillSurface y FilterChoiceGroup: fondo gris, selección negra e indicador adaptable. Editor dentro del scroll existente, cerrar descarta y Aplicar confirma/colapsa. Separación16 respecto a la primera fila. Cards con nombre/especie, tipo/estado en badges y sin texto redundante; nombre ausente usa especie una sola vez.

Zona con Todas las zonas/Por ubicación, AppTextField de ciudad/dirección, botón Buscar ubicación con LoadingShimmer, resultados reales, atribución enlazada y mapa con centro/círculo. Slider1–50km y ZoneMapPicker.fitRadius opt-in. Sin GPS ni coordenadas numéricas visibles. Renders normales/pequeños y evidencia en ESTADO; [ADR-042](decisiones/042-filtros-integrados-y-busqueda-zonas.md).

## Ilustraciones independientes de landing —17/10/2026

Se sustituye el raster compuesto de ADR-060 por siete assets independientes
imagegen con transparencia, documentados en apps/platform/LANDING_ASSETS.md.
LandingArt mapea nombres semánticos a archivos/dimensiones nativas, sin offsets
ni ventanas de mockup; LandingCharacterCard contiene figura, etiqueta HTML y
trazos SVG. Gradientes/bordes/superficies/círculos/pins decorativos son CSS real.
Se elimina del público landing-reference.png. Header/footer usan el logo oficial
/brand.png; ningún logo generado. Conservar hero y sus cover/stagger, tiempos y
movimiento reducido aprobados por el usuario. Composición y CSS siguen aislados
de QR; escenas pueden reencuadrarse como ilustraciones, nunca como capturas UI.

## Diversidad y marca —17/10/2026

Diez PNG independientes: corgi, dálmata, gato atigrado, pastor/ragdoll, spaniel,
mestizo/calicó, retriever/gato gris y beagle/gato blanco-negro. Pañuelos carbón,
verde bosque, marino, burdeos, petróleo, ciruela y terracota según mascota.
Emblema de only-black.svg estampado en blanco por imagegen dentro de la tela,
con perspectiva/textura/pliegues; no se superpone desde CSS/SVG. LandingArt solo
presenta PNG y LandingCharacterCard conserva figura/caption/decoración nativas.
Fuentes oficiales actualizadas en logo se conservan; copias oficiales PNG en landing/QR/favicon y /brand.svg disponible como vector y recursos
Flutter/launchers/splash actualizados. Animación hero aprobada conservada.
Prompts finales/procedencia: apps/platform/LANDING_ASSETS.md.

Reportar20/10, ADR-107: buscador compartido de ciudad/dirección antes del mapa,
con sugerencias de Perú y mismo campo/listado de Explorar. Título/privacidad,
buscador, mapa y referencia participan en el stagger con cuenta actualizada;
header persistente. Buscar es opcional, elegir centra/marca y tocar mapa ajusta;
referencia privada independiente. Skeleton/shimmer y toast compartidos.
Renders390×844/texto1 y320×350/texto2 revisados sin overflow; Android pendiente.

Buscador20/10, ADR-108: OverlayPortal/LayerLink anclado al campo; panel único
#F5F5F7/radio22/separación8, ancho del campo, altura máxima320 limitada por teclado
y área segura. Preferir debajo; arriba si debajo hay menos120 y arriba hay más.
Filas rectas mínimo48, texto13/fuente compartida, icono18; scroll sin expansión
del formulario. Foco/selección/cierre fuera/Escape/retorno y desmontaje cuidados.
Consulta muestra skeleton/shimmer en el panel, sin repetir stagger por edición.
