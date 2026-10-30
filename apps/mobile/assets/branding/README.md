# Recursos de marca

Los originales oficiales están en `logo/`. La actualización del17 de octubre de2026 se propaga a BrandMark/BrandWordmark/StartupReveal mediante `app_icon.png`, copia exacta de `Logo EntreHuellas 512 vector inner v2@2x.png`. No se modifica el símbolo ni se cambian identificadores de paquetes. La marca tipográfica sigue siendo texto de la app.

El recurso Android `drawable-nodpi/startup_brand.png` usa el mismo original. Los iconos de launcher clásicos/adaptativos/monocromáticos y los catálogos iOS/macOS, favicon/PWA Flutter y Windows se regeneran mediante `tool/generate_android_icons.ps1`, con `flutter_launcher_icons.yaml`. Desde apps/mobile ejecutar `./tool/generate_android_icons.ps1`. Las rutas al directorio logo usan ../../ tras la organización apps/mobile. Se conservan formas/colores SVG en Android; los filtros no soportados por VectorDrawable no se convierten. iOS recibe iconos sin alfa. El script preserva la bandera Xcode de Swift asset symbols ante el comportamiento de flutter_launcher_icons0.14.4.

Generar estos archivos no acredita compilación, instalación ni soporte completo en las plataformas futuras; Android sigue siendo la prioridad del MVP. Las comprobaciones efectivas se registran en docs/ESTADO.md.

`google_g.png` sigue siendo el símbolo oficial de Google para el botón de acceso, independiente de la marca Entre Huellas. No se reemplaza por el nuevo logo.
