# Landing pública en la plataforma

## Segunda mejora de SEO: recursos adaptables —20/10/2026

Sin cambios de CSS, texto o composición aprobados en ADR-120. El hero ofrece
WebP320/640 además de1254 mediante srcset/sizes, manteniendo PNG de respaldo y
dimensiones de layout. El navegador decide según viewport/densidad. Las variantes
pequeñas se remuestrean desde PNG y se codifican WebP sin pérdida; no equivalen a
los píxeles originales a resolución completa, que continúan disponibles.

QA local1440px: DPR1 descarga186.122 bytes entre ambos hero frente a2.604.418
de los WebP completos (−92,9 %); DPR2 elige640 y descarga702.904; DPR3 conserva
los completos. Son tamaños de archivos seleccionados, no reducción porcentual
de toda la página ni medición de Core Web Vitals. Tamaño, color y fuente del
título confirmados en los tres casos; QA responsive/sin JS/texto200 % conservado.

La vista previa social usa derivado JPEG público1200×630 sobre blanco de la
ilustración aprobada (sin recortar),89.933 bytes frente a3.628.600 del PNG anterior.
Open Graph y JSON-LD actualizan URL/tipo/dimensiones; el origen sigue configurable.
El script optimize-landing-images.mjs regenera variantes y vista previa.

Producción revisada de nuevo: entrega el título SEO antiguo, sin JSON-LD ni
summary_large_image; el código preparado localmente aún requiere publicación.
El dominio propio entrehuellas.app mejora claridad/recordación de marca, pero
.app no da ventaja automática de ranking. Puede posicionarse el subdominio actual.
Tras publicar, verificar propiedad en Search Console, enviar sitemap e inspeccionar
portada/indexación; medir rendimiento real antes de afirmar mejoras de posición.
La compra/migración y acciones de Search Console siguen pendientes del propietario.

Referencia: [guía SEO de Google, dominios y extensiones](https://developers.google.com/search/docs/fundamentals/seo-starter-guide),
[experiencia de página](https://developers.google.com/search/docs/appearance/page-experience)
y [recursos adaptables](https://web.dev/learn/design/responsive-images).

## Restauración del hero original —20/10/2026

Por petición explícita y primera captura del usuario, #hero-title recupera Arial500,
#171918, interlineado1.02, tracking−0.055em y tamaño42–108px (móvil32–48px).
Se recuperan también escala/offsets originales de las mascotas laterales. Valores
anteriores a1fc1bd1, cuyo cambio global a Poppins32 redujo este hero. ADR-120
sustituye solo aquí la regla ADR-111 descrita más abajo. Texto del título, SEO,
WebP, acceso, controles y persistencia/permisos permanecen. Sin nueva activación
de backend; revisión responsive/texto ampliado y resultados en ESTADO.

## SEO y dominio público —20/10/2026

La portada conserva SSR, un único h1, preguntas nativas y navegación sin JS.
El título pasa a «Entre Huellas | Mascotas perdidas y encontradas» y la descripción
explica búsqueda, avisos y colaboración. El apoyo del hero menciona mascotas
perdidas sin sustituir el lema ni la composición. Open Graph y Twitter incluyen
nombre, URL e ilustración pública existente con tamaño/alt. No se inventan
perfiles sociales, valoraciones, descargas ni disponibilidad.

JSON-LD WebSite/Organization/WebPage identifica el proyecto y su portada con nonce
de la CSP existente. No promete resultado enriquecido ni publica datos de cuentas
o casos. `shared/seo/site_metadata.ts` centraliza textos y valida el origen HTTPS.
`NUXT_PUBLIC_SITE_URL` es configuración pública Nuxt actualizable al arrancar:
canonical, og:url, imágenes, JSON-LD, robots y sitemap usan la misma identidad.
No depende de Host, parámetros de campaña ni cabeceras reenviadas. Un origen
inválido falla explícitamente; corregir configuración y reiniciar el proceso.

Solo `/` aparece en sitemap y es indexable. Acceso, legales, cuenta y QR conservan
su X-Robots-Tag noindex; robots no bloquea JS/CSS/fuentes/ilustraciones. Se mantienen
las restricciones QR/API; robots no concede permisos ni garantiza que desaparezca
una URL enlazada desde terceros. Sin persistencia, SQL ni endpoints de producto.

Las doce ilustraciones ofrecen WebP sin pérdida mediante picture y PNG original
de respaldo, conservando dimensiones y lazy loading. Regenerar desde apps/platform
con `node scripts/optimize-landing-images.mjs` tras cambiar PNG. El script verifica
alfa y RGB visibles: 27.134.705 →15.165.652 bytes (−44,1 %), sin contar repeticiones
ni caché. No equivale a medir Core Web Vitals reales.

Dominio público vigente (24/10/2026): `https://entrehuellas.app`.
El código y los ejemplos usan esta base; en Dokploy configurar también
`NUXT_PUBLIC_SITE_URL=https://entrehuellas.app` y
`PUBLIC_WEB_ORIGIN=https://entrehuellas.app`. El usuario confirma compra,
Cloudflare activo y Resend verificado; no equivale a validar el despliegue desde
este checkout. Supabase e infraestructura conservan sus dominios en kormind.com.
Para completar la migración:

1. Adquirir/configurar DNS y HTTPS del dominio nuevo y comprobar la aplicación.
2. Cambiar NUXT_PUBLIC_SITE_URL y PUBLIC_WEB_ORIGIN a https://entrehuellas.app
   en el entorno del proceso y reiniciar. Son contratos distintos: identidad SEO
   y origen permitido de operaciones. Actualizar callbacks OAuth, allowlists y
   consumidores del dominio según su configuración existente.
3. Configurar redirecciones permanentes301/308 de navegación desde el dominio
   anterior a la misma ruta del nuevo, preservando parámetros necesarios y evitando
   cadenas. Mantener el dominio anterior al menos un año. Verificar QR existentes,
   acceso y recuperación; las cookies anteriores no se transfieren al dominio
   nuevo. No reproducir escrituras automáticamente.
4. Verificar ambas propiedades en Google Search Console, enviar el sitemap nuevo,
   solicitar indexación/usar Cambio de dirección si está disponible y vigilar
   indexación, errores y tráfico. Requiere acceso del propietario; no se inventa
   etiqueta de verificación ni se promete una posición.

Validación: SSR/metadatos/JSON-LD/CSP/imagen, cambio de dominio en runtime y
cabeceras ajenas; QR/privadas siguen noindex. Resultados finales en ESTADO.
24/10: el usuario confirma propiedad verificada en Search Console. Código local
migrado:83/83 pruebas web, typecheck/build,31/31 pruebas de servidor y7/7 de
producción tras añadir la regresión del origen nuevo/anterior. Despliegue de
esta revisión, redirecciones, revisión de marca OAuth y métricas reales pendientes.

Referencias: [nombres de sitio](https://developers.google.com/search/docs/appearance/site-names),
[títulos](https://developers.google.com/search/docs/appearance/title-link),
[robots](https://developers.google.com/search/docs/crawling-indexing/robots/intro) y
[migración de dominio](https://developers.google.com/search/docs/crawling-indexing/site-move-with-url-changes).

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión en dispositivos reales pendiente.

## Acceso preparado antes de pulsar —19/10/2026

AccountViewModel consulta sesión en segundo plano al montar (SSR sigue público)
y el enlace apunta al destino confirmado, con sus componentes precargados.
Data reutiliza brevemente la consulta para guard/pantalla y agrupa concurrentes;
no hay otra espera de sesión al clic preparado. Polling visible10s, foco y
mensajes mantienen destino actualizado; recursos se liberan al salir. Sin sesión
se conserva /iniciar-sesion y sin JS funciona redirección de servidor. No cachea
permisos ni promete ausencia de espera antes de preparar/caducar. ADR-080 y ficha
de acceso detallan invalidación/límites. Validación y pendientes en ESTADO.

El enlace de acceso usa NavigationLink compartido: feedback inmediato con
shimmer/aria-busy durante la comprobación y navegación, conservando texto/href
y bloqueando clics repetidos. La latencia real de sesión permanece; no se monta
login intermedio ni se adelanta autorización. Véase ficha de acceso/ESTADO.

Regla ratificada19/10: marca arriba a la izquierda como landing, con color y
medidas compartidos; conservar posición desde SSR hasta hidratación/recarga,
sin saltos. [Norma completa](../REGLAS_UI_UX_WEB.md) y ADR-077.

## Corrección del salto de cabecera al recargar —19/10/2026

La hoja de cabecera compartida deja de declarar layout para .landing-page.
Landing conserva su composición aprobada y la marca compartida; se elimina
la competencia align-items:flex-start/center con igual especificidad que
movía la marca3px durante hidratación. QA registra fotogramas de entrada y
recarga en1440/731/390/320, producción y dev; evidencia final en ESTADO.
Sin cambios de contenido, navegación o despliegue.

## Marca compartida con landing —19/10/2026

Cabecera usa SiteBrand/SiteHeader con la misma posición, color, fuente y tamaños
adaptables de landing, también en responsive y fuera del stagger. Sin cambios
de negocio, permisos o persistencia. Validación local en ESTADO; sin despliegue.
[ADR-077](../decisiones/077-marca-web-compartida-referencia-landing.md).

## Enlaces de acceso y documentos reales —19/10/2026

La acción de cabecera Iniciar sesión conduce a /iniciar-sesion; el footer enlaza
a /privacidad y /terminos. Composición/ilustraciones y demás acciones conservadas.
No se prometen operaciones de mascotas/reportes aún pendientes en web.
[Ficha de acceso](acceso-web.md) y
[ADR-073](../decisiones/073-acceso-general-web-y-gestion-por-permisos.md).
Sin persistencia/permisos nuevos; navegación landing→login verificada con fixture.
Sin despliegue.

## Consolidación de reglas UI/UX web — 18/10/2026

Se consolida REGLAS_UI_UX_WEB con fondo general blanco/celeste, fondo exterior
del carrusel blanco/cream, paneles #F3F2EE, footer cream y contrato de
BackgroundGlowOrb (intensidades, tokens, capas, movimiento/CSP). Texto secundario
y oportunidad reflejan los retoques locales del usuario. Se integra la información
en paleta/movimiento/aceptación y se retira el apéndice duplicado. REGLAS_UI_UX
enlaza la consolidación vigente.

Cambio exclusivo de Markdown, sin cambios de app, alcance o permisos.
Validación: enlaces locales, concordancia con CSS/componente y git diff --check.
No se repiten builds ni pruebas de app por esta edición.
Siguiente paso: aplicar estas reglas en futuros incrementos web.

## Corrección: fondo exterior del carrusel blanco/cream — 18/10/2026

El usuario aclara con captura que el ajuste corresponde al fondo detrás del
carrusel de mascotas. Se revierte el cambio equivocado de .purpose, que conserva
el panel #F3F2EE. Una capa decorativa de .character-strip mezcla blanco predominante
y cream tenue con bordes difuminados sobre el fondo celeste animado. Mantiene
mascotas, tarjetas, espacios, controles y animaciones sin cambios.

Validación Chrome local1440/390/320px, etiquetas200% en320: fondo computado
correcto y panel original restaurado, sin overflow ni errores de página. Captura
de escritorio revisada en apps/mobile/build/ui-preview/landing-carousel-cream.
Sin build nuevo ni despliegue. Siguiente paso: valoración visual del usuario.

## Resplandor de fondo compartido — 18/10/2026

Por petición del usuario se adapta el efecto de sader-panel como componente Vue
compartido BackgroundGlowOrb, sin dependencias de React ni del otro proyecto.
Dos orbes celestes, halo y grano SVG local; movimiento CSS17/11/16s y entrada
por opacidad. intensity acepta soft/medium/strong; los colores se personalizan
con --glow-color y --glow-secondary desde CSS, sin atributos style ni relajar CSP.
El contenedor consumidor aporta posición relativa y orden de capas.

Landing lo monta una vez, en intensidad soft, detrás del contenido. Sigue el
viewport mediante sticky y se desvanece hacia el footer cream mediante máscara
exclusiva de landing. Decorativo, aria-hidden, sin eventos ni datos; movimiento
reducido lo deja estático y visible. No afecta otras rutas ni sus permisos.

Sin nuevas HU/RF/issues ni cambios de alcance funcional, persistencia o activación.

Validación local: typecheck,25 pruebas y build Nuxt aprobados. Chrome de
producción en1920/1440/731/390px y320px con texto200%: desplazamiento real de
orbes, seguimiento del scroll, máscara del footer, modo reducido sin animaciones,
FAQ operable y ausencia de overflow/errores CSP/hidratación. QA existente de landing
aprobado: teclado/anclas/ilustraciones, SSR/FAQ sin JS y navegación landing→QR→landing.
Capturas de escritorio/móvil y footer revisadas en
apps/mobile/build/ui-preview/landing-glow. Sin despliegue; pendiente valoración
del usuario y comprobación en otros navegadores.

## Fondo blanco y celeste, footer cream — 18/10/2026

El usuario solicita una base blanca con celeste suave como su referencia.
Dos radiales laterales sobre un degradado blanco terminan en --cream (#FFFBEF) al pie; la transición acompaña la altura real de la página.
Se mantienen los colores locales previos, composición y recorridos. Sin cambios
en persistencia, permisos, activación ni HU/RF/issues.

Chrome local1440/390/320px, este último con textos al200%: fondo computado
correcto, sin overflow ni errores de página. Captura de escritorio revisada en
apps/mobile/build/ui-preview/landing-background. Build de producción no ejecutado;
sin despliegue y valoración del usuario pendiente.

**Distribución irregular solicitada — 18/10/2026:** se sustituye la alineación y el tamaño uniforme por huellas con tamaños, alturas, separaciones y giros diferentes, sobre el crema exterior. Diez en escritorio y cuatro en móvil. Build Nuxt y revisión Chrome en 1920/1440/731/390/320px (320 con texto al 200%) aprobados: tamaños y posiciones distintos, sin invadir el panel ni producir overflow o errores de página. Capturas closing-paws actualizadas. Sin despliegue; pendiente revisión del usuario.

## Huellitas del cierre sobre fondo crema — 18/10/2026

Por petición del usuario, las huellas de «Una huella tuya puede acercarlos a casa» pasan al fondo amarillento exterior. Un contenedor de presentación reserva bandas superior/inferior; el panel aurora conserva título y acciones. Diez huellas en escritorio y cuatro en móvil, decorativas y sin eventos.

Validación local: typecheck,17 pruebas y build Nuxt aprobados. Chrome en1920/1440/731/390/320px (320 con texto200%): huellas fuera del panel, sin overflow ni errores de página; capturas de escritorio/móvil revisadas en apps/mobile/build/ui-preview/closing-paws-*.png. Sin despliegue. Siguiente paso: revisión del usuario.

**Ubicación corregida al footer — 18/10/2026:** el usuario aclara que el adorno
corresponde al pie debajo del cierre. LandingSideNote se traslada al footer,
superpuesto a la derecha sin espacio reservado, conservando mancha/huellas y
fuente manuscrita local. Pointer-events none mantiene los enlaces operables;
oculto bajo1100px. Build y revisión1920/1440/1100/731/390/320 aprobados sin
overflow ni desplazamientos del contenido. Sustituye ubicaciones previas,
sin despliegue.

**Mancha sobre el cierre — 18/10/2026:** corrección explícita del usuario.
LandingSideNote pasa de beneficios a la última sección, posición absoluta z2
al borde derecho, sin padding/columna reservada ni modificación del layout.
Formas SVG irregulares con tonos suaves, huellas originales y corazones.
Frase en Kalam Regular local (SIL OFL), trazo manuscrito aproximado a la referencia;
Arial permanece en el resto. Adorno sin eventos/animación y aria-hidden, oculto
por debajo de1100px. Typecheck/build y QA navegador aprobados. Comprobación
geométrica confirma título/acciones sin desplazamiento al retirar el adorno;
fuente cargada y capturas1920/1440/1100/731/390/320 revisadas. Sin despliegue.

**Detalle lateral — 18/10/2026:** por aclaración del usuario, se incorpora
LandingSideNote dentro de beneficios, al costado derecho, sin sección adicional.
Adorno190×285px con ondas, frase pequeña, corazones y huellas del SVG original.
Lateral reservado240px desde1100px; oculto en tamaños inferiores para mantener
el contenido. Sin interacción/animación y aria-hidden. Huellas grandes anteriores
conservadas. Typecheck/build y QA de navegador aprobados; ajuste final de padding
registrado y verificado en renders1920/1440/1100/731/390/320px, sin cruces con
tarjetas ni overflow. Sin despliegue; valoración del usuario pendiente.

**Reversión del último ajuste — 18/10/2026:** el usuario solicita recuperar
la versión anterior. Retirados el bloque de ondas/frase/corazones y sus estilos;
se conservan las huellas grandes descritas a continuación. Sin despliegue.

**Huellas ampliadas — 18/10/2026:** ajuste posterior según dos referencias del
usuario; sustituye los pares pequeños descritos abajo. Cuatro huellas distribuidas
por los bordes de hero/oportunidad/cierre, todas con la silueta original de
`logo/only.svg` mediante máscara CSS y tonos suaves salvia/celeste/durazno.
12 en escritorio; 10 en móvil al simplificar oportunidad. Tamaños34–130px,
sin animación/interacción y aria-hidden. Typecheck/build y QA navegador existente
aprobados, incluidos texto200%, SSR/CSP y navegación QR. Renders1920/1440/731/
390/320px revisados sin overflow; misma carpeta landing-paws. Sin despliegue;
valoración del usuario y otros navegadores pendientes.

**Huellitas decorativas — 18/10/2026:** por solicitud del usuario se añaden
tres pares discretos en hero, oportunidad y cierre. LandingPawTrail combina el
icono existente con una copia exacta de `logo/only.svg`, conservando el original,
sin animación adicional, sin interacción y ocultos a lectores de pantalla.
Tamaños y opacidad suaves, adaptados a móvil; no cambia datos, permisos ni alcance.
Typecheck, 17 pruebas y build aislado aprobados. Renders Chrome de 1920, 1440,
731, 390 y 320px sin overflow y SVG decodificado; capturas en
`apps/mobile/build/ui-preview/landing-paws`. Sin despliegue; valoración del usuario
y otros navegadores pendientes.
QA de navegador existente aprobado, incluidos texto200%, FAQ/teclado/anclas,
movimiento reducido, SSR/CSP/hidratación y navegación landing→QR→landing.

**Aprobación final — 18/10/2026:** el usuario confirma que le encantó la landing
terminada y solicita usarla como referencia para toda la web. La valoración visual
de los últimos ajustes queda confirmada; las notas anteriores de revisión pendiente
son históricas. [REGLAS_UI_UX_WEB](../REGLAS_UI_UX_WEB.md) consolida la norma y
[ADR-063](../decisiones/063-landing-como-referencia-ui-ux-web.md) extiende el alcance
visual. Este incremento solo modifica Markdown; no despliega ni adapta todavía
el QR. Próximo paso: aplicar la norma en el siguiente recorrido web autorizado.

**Radio unificado17/10:** todos los botones de landing comparten cápsula999px,
incluidos secundarios/lima y tamaños tablet/móvil. Se conserva estilo cromático
de cada acción y control circular. Validación responsive y build en ESTADO.

**Botones/ilustración17/10:** por referencias del usuario, acciones azules de
cabecera/cierre ahora son cápsulas con brillo superior, degradado azul/celeste,
texto blanco y sombra. Botones lima aprobados conservados. dog-report.png
recreado con imagegen para eliminar la pata extra del perro, preservando PNG
transparente1312×1199, personajes y emblemas; actualizado en ambos usos. Evidencia
glossy-buttons/report-anatomy, procedencia en LANDING_ASSETS y validación en ESTADO.

**Corrección de fondos17/10:** restaurada la generación y cobertura de la capa
.aurora::before eliminada accidentalmente al consolidar colores. Hero original
y cierre azul vuelven a pintarse. QA navegador ahora comprueba que las capas
existan y cubran ambas secciones, además del gradiente. Build/QA aprobados y
capturas revisadas; evidencia aurora-fix en ESTADO. Sin despliegue.

**Corrección4/5/6 del17/10:** oportunidad, comunidad y colaboración restauran
sus colores de fondos/botones/números/etiquetas originales. Por rectificación
explícita, «Una huella tuya» conserva la paleta azul nueva. Geometría y recursos
intactos; sin reintroducir pines02/03. Build/QA en ESTADO, evidencia sections-original.

**Propósito17/10:** numeración01–04 con color original171918 por solicitud del
usuario. Retirados los pines CSS morados y decoración asociada de pasos02/03;
PNG/fondos/encuadres conservados. Build y QA responsive en ESTADO, evidencia
steps-cleanup. Sin publicación.

**Corrección posterior17/10:** el hero vuelve a la paleta original completa,
incluidos gradiente, botones, badge, valores y fondos de mascotas. El resto
conserva la paleta azul nueva; geometría y animación intactas. Build/QA y
renders hero-original-colors en ESTADO. Sin publicación.

**Paleta azul autorizada17/10:** primario3C537B/blanco, secundarioB5D5E9/azul,
acentos2C87CE; fondos celeste/azul/lavanda y verde suave residual. Se conserva
crema, mascotas, geometría y movimientos aprobados. Variables compartidas en
landing.css; botones primary/secondary por función. Cambios solo de presentación,
sin operaciones, permisos o rutas nuevas. Regla/decisión actualizadas en UI/ADR-060.
Build, tipos,9 pruebas y QA responsive/200%/SSR/QR aprobados; contrastes de
acciones AA, capturas revisadas y valoración del usuario pendiente. Evidencia
blue-palette en ESTADO. No publicado.

**Ajuste tras aprobación17/10:** margen superior del pie reducido a24–48px
(3vw), conservando texto entre mascotas y encuadre/tamaños aprobados. Nueva
exportación del logo sincronizada en landing/QR/favicon. Build y QA responsive
en ESTADO; evidencia footer-gap-logo. Sin despliegue.

**Encuadre final del pie17/10:** por aclaración del usuario, texto entre las
mascotas en escritorio, centrado con elevación20–40px y ancho36%; imágenes39%
sin recorte y cerca de los laterales. Sustituye el contenido en fila superior
del ajuste anterior. Móvil conserva distribución en dos filas y figuras50%.
Cierre alto conservado. Build/QA y capturas footer-centered en ESTADO.

**Corrección posterior17/10:** el usuario solicita conservar el tamaño original
de las mascotas del pie. Ancho39% cada una en escritorio y50% en móvil; fila
natural completa debajo del contenido para evitar recorte y cruces. Se mantiene
la altura ampliada del cierre. Sustituye el escalado reducido del ajuste previo.
Build y geometría responsive aprobados; evidencia footer-original-size en ESTADO.

**Pie y cierre17/10/2026:** mascotas completas en columnas laterales sin
recorte ni superposición con enlaces. Contenido central alineado arriba; móvil
coloca las mascotas en una segunda fila. Cierre «Una huella tuya» con altura
mínima420–640px (440px móvil) y contenido centrado. Sin recursos ni operaciones
nuevas. Build SSR y QA responsive/200%/FAQ/anclas/no-JS/CSP/hidratación/QR
aprobados; geometría sin cruce/recorte verificada en1920/1440/731/390/320px
y texto ampliado. Renders revisados; pendiente valoración del usuario,
sin despliegue. Evidencia landing-footer-* en apps/mobile/build.

**Títulos y comunidad17/10/2026:** los siete h2 de sección comparten la escala
de propósito mediante --section-title-size (hasta58px; móvil34px), sin alterar
el h1 del hero. Imagen de comunidad con ventana305:160 frente a305:123 anterior
(aprox.30% más alta), conservando PNG y contain. Anchos, márgenes y onda intactos.
Build SSR y QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados;
igualdad de fuentes/proporción comprobada hasta1920px y capturas revisadas.
Logs landing-heading-scale-*.log en apps/mobile/build. Pendiente valoración
visual del usuario; sin publicación, cambios de datos ni cierre de historias.

**Onda viajera17/10/2026:** referencias del usuario requieren una curva amplia
que recorra las tarjetas. Ciclo6s, doce fases progresivas cada0.5s y amplitud
24–56px. Seis personajes repetidos dos veces por grupo; copias decorativas,
sin duplicar mensajes accesibles. Dos grupos equivalentes y avance120s conservan
velocidad horizontal previa y continuidad de onda en la unión. Pausa horizontal,
movimiento reducido, dimensiones y márgenes conservados. Build SSR y QA
responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados; muestreo confirma
propagación, continuidad y velocidad conservada. Capturas revisadas; logs
landing-traveling-wave-*.log en apps/mobile/build. Pendiente revisión del usuario,
sin publicación ni nuevas historias.

**Espacio y onda17/10/2026:** margen adaptable40–88px tras propósito y entre
secciones posteriores/pie, conservando el espacio previo de la tercera sección.
Onda vertical6s, seis fases cada1s y curva suave; avance horizontal60s, amplitud,
arte, marcos, pausa horizontal y movimiento reducido conservados. Build SSR y
QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados; espacios medidos
en1920/1440/731/390/320px y continuidad de onda comprobada. Capturas revisadas.
Evidencia landing-spacing-wave-*.log en apps/mobile/build; pendiente revisión
visual del usuario, sin publicación, cambios de permisos ni nuevas historias.

**Ancho global17/10/2026:** por petición del usuario, todas las secciones,
cabecera y pie comparten el ancho aprobado de hero/propósito mediante `.wrap`,
sin máximo1280px y con margen móvil14px conservado. Diseño, arte y movimientos
conservados. Diez contenedores alineados en1920/1440/731/390/320px, sin overflow;
build SSR y QA responsive/200%/no-JS/CSP/hidratación/FAQ/anclas/QR pasados.
Capturas escritorio/móvil revisadas; logs landing-sections-width-*.log en
apps/mobile/build. Pendiente revisión del usuario, sin publicación ni nuevas HU.

**Ajuste de tercera sección17/10/2026:** el panel blanco de «Una comunidad con
un propósito» comparte ancho/márgenes del hero sin máximo1280px; cuatro imágenes
con ventanas3:1 en lugar de3.6:1 (20% más altas a igual ancho). Se conservan
recursos y movimientos. Build SSR y QA responsive/200%/no-JS/CSP/hidratación/QR
pasados; comprobación adicional de alineación con hero hasta1920px y capturas
escritorio/móvil revisadas. Logs landing-purpose-*.log en apps/mobile/build.
Servidor dev existente reutilizado; pendiente aprobación visual del usuario.
Sin cambios de persistencia/permisos, publicación ni cierre de historias.

**Relevo vigente17/10/2026:** el usuario aprobó el diseño tras el último aumento
leve del marco. Para continuar en otro chat, leer [RELEVO_LANDING](../RELEVO_LANDING.md):
consolida el estado final y sustituye las soluciones intermedias de este historial.

Integración solicitada17/10/2026, sin HU/RF/issue nuevos asignados. / en
apps/platform, Vue/Nuxt/TypeScript; [ADR-060](../decisiones/060-landing-integrada-en-platform-vue.md).
Proviene del trabajo de feature/landing-page, conservado sin modificar allí.

## Qué hace y recorrido

Presenta Entre Huellas con header/anclas, hero, personajes, propósito, cuatro
pasos, oportunidad, comunidad, colaboración, beneficios, FAQ, cierre y footer.
Mantiene composición y contenido aprobados, con diez ilustraciones independientes
generadas con imagegen y componentes Vue/CSS/SVG reales, sin capturas por debajo. CTA enlazan secciones existentes. FAQ nativo
exclusivo, operable con teclado y sin JavaScript. Responsive/movimiento reducido.

## Reglas, campos y persistencia

Página informativa sin campos ni envíos. No añade SDK/consultas Supabase, usuarios
simulados, estadísticas, contacto, descargas ni autenticación ficticios. No guarda
datos personales, sesión o cookies de usuario. Las fichas /c/<token> siguen siendo
la funcionalidad HU-09 independiente en rutas, dentro del mismo proyecto/despliegue.

Paleta institucional aislada de QR/app. Diez PNG RGBA con dimensiones nativas documentadas,
con carga diferida salvo hero. LandingCharacterCard contiene tarjetas/etiquetas/
decoraciones HTML/SVG y LandingArt consume assets independientes sin atlas ni
offsets de captura. Logo oficial PNG actualizado en header/footer y favicon; SVG completo disponible y hero aprobado
conservado con los mismos tiempos/movimiento reducido. CSP sin cambios. Prompts
y procedencia en apps/platform/LANDING_ASSETS.md. La raíz es
indexable con título/description/canonical/social; sitemap solo raíz, robots
excluye QR/API/rutas privadas y el servidor mantiene noindex fuera de la raíz.

## Errores y reintentos

Sin operaciones remotas ni loaders/toast artificiales. Fallos de entrega se
reintentan recargando en navegador; no existe confirmación de producto inventada.
Sin instalar la app ni ejecutar JavaScript se puede leer el contenido y usar FAQ.

## Activación y validación

Mismo Dockerfile/contexto apps/platform, stage runtime y puerto5173 de Dokploy.
No nuevas variables ni SQL. Publicar código y redeploy para ver la landing en el
dominio; no hace falta cambiar enlaces de QR. Node24/npm según guía de plataforma.
Landing puede renderizarse sin configurar Supabase; los casos sí lo necesitan.

Pruebas/tipos/build/QA locales y evidencia en [ESTADO](../ESTADO.md). Capturas en
apps/mobile/build/ui-preview/landing-vue; QA de enlaces, FAQ, indexación, ausencia
de llamadas de producto, CSP, variantes responsive/texto200% y aislamiento SPA.
Pendientes: revisión del usuario, Safari/Firefox, publicación y Search Console.
No se afirma posicionamiento real ni integración de login/administración web.

Diversidad17/10: corgi, dálmata, atigrado, spaniel, mestizo/calicó y parejas de
retriever/gris y beagle/blanco-negro, además de pastor/ragdoll. Pañuelos de colores
con only-black.svg reproducido en blanco por imagegen dentro del tejido del PNG,
sin superposición SVG/CSS. Se conservan interfaz, CTA y animación aprobados.

Acabado17/10: por corrección explícita del usuario, los PNG se editan con
imagegen para retirar el perfil oscuro y la iluminación de borde anaranjada.
Las tres referencias aportadas fijan pelaje natural, detalle fino y luz difusa
neutra, sin halo de color ni desenfoque global. Mantener razas, estampados y
escenas; revisar archivos sobre fondos claros/oscuros y detalle al100%, además
de la composición real. Prompts y procedencia en LANDING_ASSETS.md; evidencia y
límites de comprobación en ESTADO. Sin cambios de funcionalidad o persistencia.

Revisión posterior del usuario: los primeros suavizados no resuelven el acabado.
Priorizar hebras definidas y silueta formada por pelo, según gatito-curioso.png;
no aceptar una franja luminosa, oscura o desenfocada. Se calibró primero un PNG
de dálmata y se integraron después diez PNG seleccionados, revisados en fondos
claros/oscuros y en Chrome responsive. Build y QA de esta pasada registrados en
ESTADO; integración verificada y aprobación artística final del usuario pendiente.

El usuario rechazó también esa última pasada: identifica una franja gris sobre
pelo blanco en la oreja del dálmata. La corrección artística global sigue pendiente.
Se preparó una muestra fuera del público que retira ese sombreado y reconstruye
hebras claras; comparar landing-white-fur-ear.png y resolver su revisión visual
antes de nuevos reemplazos en bloque. No confundir build/QA con aceptación de arte.

La muestra también fue rechazada. Diagnóstico de solo lectura de color/alfa en
ESTADO; no se continúa extrapolando generaciones. Pendiente elección del usuario
sobre probar tratamiento localizado del PNG conservando el detalle existente.

Nueva referencia explícita: hero-bienvenida.png original, especialmente los
mechones y volumen de la cola. Se prueba esa fuente transparente con una edición
imagegen limitada a estampados; muestra/comparación en ESTADO. No se ha aplicado
la alternativa manual ni se ha resuelto todavía el conjunto de ilustraciones.

Las dos nuevas pruebas desde el master y de neutralización con imagegen también
fueron rechazadas por contorno/luminosidad y pérdida de pelo en cola. No se han
integrado ni extrapolado al resto. La corrección visual global sigue sin resolver;
los checks de web no acreditan cumplimiento de ese acabado.

Pasada posterior del 17/10: sustituido el dálmata público por la edición ImageGen
`exec-e5839c84-0e7b-46ec-8087-e9bfc66c8f4c.png`, PNG transparente de 1254×1254,
sin retoques posteriores. Revisión visual de oreja y cola al tamaño nativo sobre
gris: menor halo, pelo negro continuo en su borde y hebras de cola conservadas.
Emblema blanco integrado en el pañuelo naranja. Build comprobado. La aceptación
artística del usuario y revisión de los otros ocho recursos siguen pendientes.

Corrección siguiente: el usuario rechazó e5839c84 por sombreado en mejilla.
Sustituido por `exec-228f74fc-9ac3-428c-89de-5a5f1d1932bc.png`, generado
directamente desde su referencia del 7 de octubre y emblema oficial. Dimensiones
nativas 1312×1199. La tarjeta del dálmata usa contain para no cortar su cola
completa; antes heredaba cover. Aceptación artística pendiente.
Build y QA responsive de esta sustitución pasados: registros
landing-dalmatian-reference-build.log y landing-dalmatian-reference-browser.log
en apps/mobile/build; captura de tarjetas confirma cola visible entera.

### Colección desde el estilo aprobado —17/10/2026

El usuario aprobó el dálmata y autorizó completar e integrar las ocho variantes
restantes. Sustituidos dog-curious/cat/dog-wave/corgi/tabby/dog-report/pets-home/
pets-map con ImageGen, usando como referencias el dálmata y el emblema blanco.
Pañuelos variados con emblema integrado, PNG RGBA sin filtros posteriores.
Dimensiones nativas declaradas. Pareja original conservada y ampliada al 160 %
solo en la tarjeta Volvemos, centrada abajo. Animación principal conservada.
Prompts, referencias y procedencia: apps/platform/LANDING_APPROVED_STYLE.md.
Build SSR y QA Chrome responsive/texto200 %/SSR/no-JS/FAQ/teclado/anclas/CSP/
hidratación/aislamiento QR pasados; capturas desktop/mobile/characters revisadas.
Sin publicación. No equivale a cerrar una HU ni aprobar artísticamente cada PNG.

Petición posterior: recuperar exclusivamente las dos imágenes anteriores del
hero. Restauradas como hero-dog.png/hero-cat.png (1254×1254) con asignación
independiente; las imágenes nuevas del resto y Volvemos ampliado se conservan.
Build SSR y QA responsive/texto200 %/no-JS/QR pasados en esta restauración;
captura del hero revisada, sin cambio de animación ni despliegue.

Petición posterior: hero más grande, con título hasta78px, ilustraciones
hasta120px y mayor padding adaptable; móvil con tipografía y espacio propios.
Marca de cabecera/footer en minúsculas «entre huellas» y peso500, antes750.
Sin modificar el icono oficial ni el texto editorial o la marca de la ficha QR.
Build SSR y QA responsive/texto200 %/SSR/no-JS/QR pasados; capturas revisadas
y git diff --check sin errores. Evidencia landing-hero-size-*.log en build móvil.

Referencia posterior: hero ocupa la primera pantalla bajo cabecera, ancho casi
completo y min-height100svh descontando cabecera/margen; contenido centrado,
título hasta108px e imágenes hasta148px en escritorio. Móvil conserva escala
propia y crecimiento natural con texto ampliado. Marca/arte/animación intactos.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados; capturas revisadas.
Evidencia landing-fullscreen-hero-*.log en apps/mobile/build. Sin despliegue.

### Fila horizontal escalonada —17/10/2026

Tarjetas alternan altura y tienen64–100px de espacio vertical alrededor.
Dos grupos de seis completan ciclo horizontal de60s sin salto; la copia se
oculta a lectores de pantalla. Control pausa/reanudar, pausa al hover/foco y
fila estática con movimiento reducido. Carga anticipada solo de las tarjetas.
Dálmata145 % y pareja185 % para equilibrar presencia, sin cambiar los PNG.
Build y QA responsive/200 %/SSR/no-JS/QR pasados; movimiento entre frames,
pausa/reanudación y reducción de movimiento comprobados. Captura revisada.
Evidencia landing-character-drift-*.log en apps/mobile/build; sin publicación.

Revisión posterior solicitada: mayor margen32–64px y padding72–104px vertical,
etiquetas centradas y peso400. La onda sustituye alturas fijas: oscilación12s
con fases separadas2s por tarjeta, simultánea al avance horizontal60s. Grupos
duplicados mantienen fases iguales para el cierre continuo. Retirados botón y
pausas hover/foco según instrucción; movimiento reducido del sistema conservado.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados; comprobados movimiento
vertical/horizontal real, fases y continuidad durante hover. Captura revisada.
Evidencia landing-character-wave-*.log en apps/mobile/build; sin publicación.

Revisión posterior: marcos12–24px más anchos y48–72px más altos. Se conserva
el tamaño anterior de la ventana de arte, centrada abajo, y cada escala de mascota.
Botón cápsula inferior derecha con pausa/play y aria-pressed: detiene solo el
avance horizontal; la onda vertical sigue. Reanuda desde el mismo punto, sin
pausas hover/foco. Preferencia de movimiento reducido conservada.
Build SSR y QA responsive/200 %/SSR/no-JS/QR pasados; comprobada pausa horizontal
con onda activa, reanudación y tamaño de imágenes conservado. Captura revisada.
Evidencia landing-card-frame-*.log en apps/mobile/build. Sin publicación.

Corrección posterior: control circular44×44 en la esquina superior derecha.
Todas las mascotas usan contain y se retiran zooms de pareja/dálmata para mostrar
las ilustraciones completas sin cortar orejas/patas/colas. Marcos conservados;
ajuste proporcional de arte sin editar PNG. Pausa solo horizontal y onda activa.
Build y QA responsive/200 %/SSR/no-JS/QR y verificaciones del encuadre/control
pasados; captura revisada. Evidencia landing-card-fit-*.log en apps/mobile/build.

Corrección posterior del usuario: recuperar el tamaño anterior de mascotas,
restaurando cover/pareja185 %/dálmata145 % sin reducir marcos. Control circular
superior derecho76×76, mismo ancho que la cápsula anterior; pausa solo horizontal.
Build y QA responsive/200 %/SSR/no-JS/QR pasados, incluida onda durante pausa.
Captura revisada; evidencia landing-restored-card-scale-*.log en build móvil.

Corrección de contenedor limitado: ventana y marco se amplían al ancho completo
de las mascotas grandes (factor1.45 individual/1.85 pareja), conservando altura
visual. Contain sin zoom/márgenes negativos en el PNG: sin recortes internos.
Tarjetas más anchas para alojar la ilustración. Control60px/icono28px superior;
margen40–72px y padding superior128–168px despejan el botón y bajan la fila.
Build SSR y QA responsive/200 %/no-JS/QR pasados, incluyendo altura conservada,
ventanas contenidas y separación del control. Captura revisada; evidencia
landing-unclipped-frames-*.log en apps/mobile/build. Sin publicación.

Corrección explícita posterior: se restaura ancho aprobado de tarjetas sin el
factor1.45/1.85. Esos factores permanecen solo en la ventana de arte, con overflow
visible para eliminar el corte interior; el marco redondeado exterior delimita
la ilustración. Botón/espacio/movimiento conservados. Build SSR y QA responsive/
200 %/SSR/no-JS/QR pasados, ancho y overflow interior comprobados, captura revisada.
Evidencia landing-inner-window-*.log en apps/mobile/build. Sin publicación.

Aumento leve posterior solicitado: solo marcos, aproximadamente+16px ancho y
24px alto en escritorio (+8/+12px móvil). Ventanas e imágenes conservan medidas
y escala; botón/onda/avance intactos. Build SSR y QA responsive/200 %/SSR/no-JS/
QR pasados; captura revisada. Evidencia landing-card-small-increase-*.log en build.
