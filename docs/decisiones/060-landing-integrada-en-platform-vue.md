# ADR-060 — Landing integrada en la plataforma Vue/Nuxt

Fecha:17 de octubre de2026. Decisión: aceptada por solicitud del usuario.
Alcance: ampliación de presentación pública, sin HU/RF/issue nuevos asignados.
Complementa ADR-058/059; no sustituye contratos ni privacidad de HU-09.

## Contexto y decisión

La landing creada en feature/landing-page tenía Next/React y trabajo sin confirmar
en su propio worktree. El usuario pide integrarla en la web única Vue/Nuxt.
Se portan composición, textos, iconos y ventanas de ilustración a componentes Vue
en apps/platform/app/features/landing, y / pasa de neutral a página de presentación.
No se incorpora un segundo runtime Next ni se modifica el worktree de origen.
No se mezclan sus instrucciones/documentos antiguos de arquitectura con los vigentes.

La referencia visual de esta landing es el mockup aprobado del11 de octubre:
crema, lima/celeste y composición de personajes. Es una excepción deliberada de
presentación institucional; no modifica el diseño de QR, acceso o app móvil.
CSS se limita a .landing-page y el CSS del lector a .reader-shell. Componentes
propios de marca/acciones/ilustración se reutilizan dentro de esta composición.
Ventanas CSS reproducen las ilustraciones del raster autorizado; textos/FAQ
siguen siendo HTML, no una captura de pantalla. Resolución limitada por la fuente.

## Renderizado y seguridad

Se usa SSR de Nuxt para entregar HTML indexable con metadatos/canonical. El
contenido es estático en producto, pero no se exporta como otra app estática:
se sirve con el mismo proceso Nitro y nonce CSP por respuesta. Sin API de
producto, sesión, cookies de usuario ni lectura Supabase para mostrar la landing.
No prerender/ISR/caché compartido en este incremento; se conserva no-store.
Las ventanas de ilustración usan clases CSS fijas, sin style inline ni relajar CSP.

Solo / permite indexación. /c/<token>, /api y las rutas privadas conservan noindex;
robots.txt excluye fichas/API/app/admin y sitemap.xml contiene únicamente la raíz.
Los metadatos sociales no exponen mascotas ni datos privados. Canonical al dominio
acordado entrehuellas.kormind.com, sin crear enlaces o contactos inventados.

## Consecuencias y validación

Referencia de botones posterior17/10: primarios azules de cabecera/cierre usan
cápsula, gradiente celeste/azul con blanco, brillo y sombra según capturas del
usuario. Sustituye el azul plano anterior. dog-report.png se corrige mediante
imagegen para retirar una extremidad extra, preservando transparencia y
dimensiones. Sin cambios de layout, arquitectura o permisos.

Corrección posterior17/10: secciones4/5/6 recuperan sus colores originales de
fondos/botones/números/etiquetas. Por rectificación explícita durante el trabajo,
«Una huella tuya» conserva la nueva paleta azul; geometría y recursos intactos.

Excepción posterior solicitada: el hero restaura sus colores originales,
incluidos gradiente, botones, badge, valores y fondos de mascotas. Se conserva
su geometría/entrada y la nueva paleta azul en las demás secciones.

Actualización visual autorizada17/10/2026 tras cambiar el logo: landing conserva
composición, crema, mascotas, geometría y animación, pero prioriza azul3C537B,
acento2C87CE y celesteB5D5E9. Botones principales azul/blanco; secundarios
celeste/azul. Gradientes con celeste/azul/lavanda y verde residual suave.
Sustituye la prioridad lima anterior solo en landing; CSS aislado de QR/móvil.
Variantes de botón usan nombres semánticos button-primary/button-secondary.
Validar contraste de acciones, responsive/texto ampliado y navegación QR.

FAQ nativo usable sin JavaScript y con teclado; anclas reales, sin botones de
descarga/registro falsos ni cifras de producto inventadas. Desarrollo Android
se informa conforme a la landing original. Login web/admin/HU-10 siguen pendientes.
No hay SQL, nuevas variables, dependencias ni cambios en Flutter.

Validar tipos, unitarias/fronteras, build/servidor compilado, SSR sin consultas de
producto, robots/canonical, navegación, FAQ y regresión de QR. Revisión de renders
1440/731/390/320px, texto200%, movimiento reducido y navegación SPA en ambos
sentidos para comprobar que no se mezclan estilos. Resultados en ESTADO.
La evidencia local no certifica Safari/Firefox, posicionamiento ni un redeploy.

## Corrección visual —17 de octubre de2026

Por instrucción del usuario se retira completamente landing-reference.png del público. LandingArt deja de leer ventanas/offsets de una captura y consume siete PNG independientes generados uno por uno con imagegen, con transparencia real: personajes, saludo, reencuentro, aviso, casa y mapa. Metadatos y nombres están en landing_artwork.ts. LandingCharacterCard implementa figura/etiqueta/decoración reales; gradientes, superficies, marcadores decorativos, círculos y bordes se dibujan en CSS/SVG. Se usa /brand.png oficial en ambas marcas; no se genera otro logo. El hero conserva exactamente sus animaciones, tiempos y movimiento reducido aprobados. Prompts y procedencia en apps/platform/LANDING_ASSETS.md. No se cambia arquitectura, datos, QR ni condiciones de publicación de esta decisión.
