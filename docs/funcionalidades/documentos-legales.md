# Términos de servicio y política de privacidad web

21/10: por petición explícita se retiran los enlaces del pie de cuenta tras
iniciar sesión. Documentos y rutas públicas, enlaces de landing/login/registro
y redirecciones existentes se mantienen; sin cambios de contenido ni permisos.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión en dispositivos reales pendiente.

## Marca compartida con landing —19/10/2026

Cabecera usa SiteBrand/SiteHeader con la misma posición, color, fuente y tamaños
adaptables de landing, también en responsive y fuera del stagger. Sin cambios
de negocio, permisos o persistencia. Validación local en ESTADO; sin despliegue.
[ADR-077](../decisiones/077-marca-web-compartida-referencia-landing.md).

## Rutas españolas implementadas —19/10/2026

/terminos y /privacidad son canónicas; /terms y /privacy conservan redirecciones308
con query. Enlaces cruzados y retorno apuntan al acceso /iniciar-sesion.
Sin cambios de texto, diseño, persistencia o permisos. QA Chrome de enlaces,
retorno, SSR sin JS y responsive/texto200% aprobado con fixture.
[ADR-073](../decisiones/073-acceso-general-web-y-gestion-por-permisos.md).
Sustituye el estado pendiente de la nota siguiente; sin despliegue.

## Convención de rutas aprobada —19/10/2026

[ADR-072](../decisiones/072-rutas-web-en-espanol.md) fija /terminos y /privacidad
como rutas canónicas objetivo. /terms y /privacy siguen implementadas: al migrar,
conservar redirecciones y actualizar enlaces cruzados y retorno al acceso.
Sin cambios de contenido, persistencia, permisos o activación. Validación de
navegación directa, enlaces y SSR pendiente para esa migración; este incremento
solo registra la regla y no requiere build/pruebas de aplicación.

## Retorno legal compacto —19/10/2026

Por solicitud del usuario, el botón izquierdo de /terms y /privacy pasa a
36×36px e icono16px, emparejado con la altura normal del enlace derecho.
Mantiene diseño circular glass y navegación al login. Override local en
LegalPage: GlassNavigationButton conserva su tamaño en otros recorridos.
Chrome local confirma36px/icono16px, radio50%, blur22px y retorno real
al login en ambas rutas. Sin overflow a320px/texto200%; git diff --check
aprobado. Sin build para este ajuste CSS. Siguiente paso: revisión visual.

## Proporciones del botón legal —19/10/2026

La comparación con sader-panel confirma que no bastaba cambiar el radio:
el botón derecho tenía mínimo48px y padding12/16px. Ahora usa mínimo36px,
padding8/12px, fuente14px/500 con línea20px e icono16px, como su Button
(h-9, py-2 y has-svg:px-3). Conserva radio18px y colores de Entre Huellas.
Altura flexible para texto ampliado y ajuste de líneas. Chrome local confirma
36px, padding8/12px, radio18px, fuente14px/500 e icono16px en ambas rutas.
Sin overflow a320px con texto200%; git diff --check aprobado. Sin build
para este ajuste CSS. Siguiente paso: revisión visual del usuario.

## Radio del enlace legal superior —18/10/2026

Por solicitud del usuario, el botón derecho compartido de /terms y /privacy
usa calc(.625rem + 8px), equivalente a rounded-2xl de sader-panel
(--radius .625rem + 8px):18px a tamaño base. Sustituye16px.
Verificación CSS y git diff --check; sin cambios de contenido o navegación.
Siguiente paso: revisión visual del usuario.

## DM Sans e iconos corregidos —18/10/2026

Por corrección del usuario, el retorno web deja de representar el chevrón
mediante el carácter ‹. GlassNavigationButton usa AppIcon con el SVG oficial
Material Symbols Rounded chevron_left de28px; círculo52px, transparencia,
gradiente/reflejos interiores y blur22px alineados con GlassSurface móvil.
No se alteran posición local en barra legal, tooltips, foco ni navegación.

Fecha y anuncio dejan de usar dibujos outline aproximados: se incluyen
Material Symbols Outlined FILL1/optical20 schedule y campaign, los mismos
usados por sader-panel a16px. AppIcon reutiliza sus trazados locales; no se
carga una fuente de iconos ni se consulta Google al navegar. Flecha cruzada
conserva su trazo existente. Licencia Apache2 incluida.

El usuario amplía explícitamente la instrucción de fuente: solo /terms y
/privacy adoptan DM Sans, la familia confirmada en layout de sader-panel.
Fuente variable100–1000, subconjunto latino con acentos, WOFF2 local/preload
y OFL adjunta. Se aplica a toda la shell legal, incluidos metadatos y títulos;
login, landing y moderación conservan sus familias previas. Esta indicación
sustituye la conservación de Arial en legales, sin cambiar el resto de la web.
Escala45/32/16px, texto/contacto, orbe y layout previos conservados.

Validación: typecheck/build aprobados. QA Chrome de legal/login verifica
DM Sans computada y fuente disponible, iconos sólidos locales, retorno SVG28px
sin carácter de texto, glass blur22px, posiciones/scroll/orbe y responsive
1440/390/320 con texto200%; sin overflow/CSP/hidratación. Capturas escritorio
y móvil revisadas en apps/mobile/build/ui-preview/login-legal. QA moderación
aprobado tras corregir selector obsoleto de la etiqueta del botón de acceso;
se conserva la etiqueta actual Iniciar Sesión. QA completo de login también
aprobado, incluida su familia Arial y los flujos OAuth simulados. Sin cambios SQL/Flutter,
autenticación, envío de correos o despliegue. Siguiente paso: valoración visual
del usuario; OAuth real mantiene su activación/configuración pendiente.

## Diseño legal alineado con sader-panel —18/10/2026

Por corrección explícita del usuario, /terms y /privacy adoptan la composición
de sader-panel: viewport de lectura con scroll propio, documento máximo896px,
padding24/48px, barra superior dentro del documento, enlace al otro documento,
título centrado con degradado y metadatos de fecha/anuncio con iconos SVG locales.
Se retiran el logo/descripción e índice adicionales de la variante anterior.

GlassNavigationButton conserva su círculo/glass/chevrón y52px; solo en la
barra legal su posición pasa de fixed a static, alineada con el documento.
No cambia el componente global ni los otros recorridos. Escala tomada de CSS
real de sader-panel (incluidos overrides markdown): h1 45px, h2 32px, cuerpo16px/
interlineado24px, metadatos14px y footer12px. Se conserva Arial por la instrucción
anterior del usuario; no se importa DM Sans. Texto ampliado mantiene ajuste
natural de línea sin recorte ni reducción de fuente.

El orbe de las páginas legales usa medium0.5, fijo al viewport sin máscara
vertical; su luz permanece durante el scroll del documento. Fondo blanco/celeste
y capa backdrop-blur10px con desvanecimiento en bordes como referencia. El texto
es estático, sin cover/reveal de la versión anterior; login/landing y contenido
legal/contacto/fecha conservados. Sin cambios de sesión, permisos, SQL o Flutter.

Validación local: typecheck y build aprobados. Chrome comprueba título45px,
encabezados32px/cuerpo16px, tres iconos, retorno dentro de la barra con posición
static y orbe fixed sin máscara vertical. Movimiento del orbe comprobado con
frames distintos y opacidad0.5; conserva posición al desplazar el contenedor.
Enlaces/retorno/contacto, SSR sin JS y1440/390/320 con texto200% aprobados, sin
overflow ni errores CSP/hidratación. Capturas de escritorio, móvil y lectura
desplazada revisadas en apps/mobile/build/ui-preview/login-legal.
Git diff --check aprobado. Sin despliegue; siguiente paso: valoración del usuario.

Ampliación explícita del usuario18/10/2026 vinculada al acceso web, sin nueva
HU/RF/issue ni cierre automático de historias. Documentos públicos en apps/platform.

## Qué hace y recorrido

/login → Términos de servicio (/terms) o Política de privacidad (/privacy).
Barra superior del documento con retorno glass al inicio de sesión,
enlaces cruzados y Contactar con mailto:sergiotlv51@gmail.com. Sin sesión obligatoria.
Páginas SSR legibles y enlaces funcionales sin JavaScript. Mantienen Arial,
fondo AmbientPageShell con orbe medium fijo y texto estático sin reveal.

## Contenido y reglas

El usuario proporciona el correo sergiotlv51@gmail.com e indica korMind para
identificación cuando sea necesario; pide redacción permanente, sin notas de MVP.
Los términos cubren propósito/alcance, cuentas, participación, publicaciones,
moderación, disponibilidad, privacidad, actualizaciones y contacto. La política
cubre responsable, categorías/finalidades, público/privado, proveedores,
cookies/sesión, conservación, derechos y actualizaciones. Fecha18/10/2026.
No se inventan domicilio, sociedad inscrita, registro de banco de datos ni
plazos exactos de borrado no implementados. El contacto recibe solicitudes;
no se afirma que exista un formulario automático de derechos/eliminación.

Se consultan la [guía de información de ANPD](https://cdn.www.gob.pe/uploads/document/file/4566447/Gu%C3%ADa%20pr%C3%A1ctica%20para%20la%20observancia%20del%20%C2%ABDeber%20de%20Informar%C2%BB.pdf)
y el [Reglamento publicado en Congreso](https://www3.congreso.gob.pe/Docs/DGP/DIDP/files/ds_016-2024-jus.pdf)
como referencias, contrastando descripción del servicio con código/fichas.
No se certifica cumplimiento jurídico global mediante una prueba de interfaz.

## Persistencia, permisos y dependencias

Contenido estático versionado en features/legal/presentation/legal_content.ts;
LegalPage compartido entre rutas, sin capas o repositorios vacíos. No solicita
APIs de producto ni serializa datos privados. Sin cookies/tablas/permisos nuevos.
Los enlaces no envían correos automáticamente ni registran aceptación/versiones
de términos o consentimientos. La autorización del login permanece en servidor.

## Errores y reintentos

Lectura estática sin carga remota, errores de producto ni reintentos ficticios.
Retorno al login siempre tiene destino fijo. El enlace mailto depende del cliente
de correo configurado del usuario. Movimiento reducido mantiene contenido visible.

## Validación y siguiente paso

Validación: typecheck,30 pruebas y build Nuxt aprobados. Chrome de producción
con fixtures: entrada/hover del icono, orbe animado, ausencia de reinicio al editar,
movimiento reducido estático; enlaces, retorno glass, anclas y mailto correctos;
SSR sin JavaScript en documentos. Renders1440/390/320 con texto200%, sin overflow
ni errores CSP/hidratación. Se corrigió ajuste de títulos largos para permitir
lectura con texto ampliado. Capturas revisadas en
apps/mobile/build/ui-preview/login-legal. QA completo de login previo también
aprobado, incluidos Google/Facebook fixture. git diff --check aprobado.
Siguiente paso: valoración visual del usuario; OAuth real sigue pendiente de
configuración. No se publica ni despliega.
Cambios futuros de tratamiento/servicio requieren actualizar contenido y fecha.
Publicación no realizada; OAuth real conserva su configuración pendiente.
