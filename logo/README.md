# Icono de Entre Huellas

Lettering móvil19/10 (ADR-092): wordmark.svg contiene únicamente los contornos
de «entre huellas» en Arial, como SiteBrand web (peso CSS500, tracking−.05em,
#171918). BrandName lo reutiliza en pantallas y arranque. El icono no cambia.
Regenerar desde apps/mobile con fonttools disponible:
`py tool/generate_brand_wordmark.py C:/Windows/Fonts/arial.ttf`.
Solo se exportan paths del lettering; no se incluye un archivo de fuente en la app.

Mapa18/10/2026: only-black.svg también es la fuente del símbolo de los pines.
apps/mobile/assets/branding/only-black.svg conserva bytes idénticos; el script
generate_android_icons.ps1 la sincroniza junto a las demás copias. flutter_svg
2.2.1 renderiza el vector en Flutter, sin editar sus paths ni recolorearlo.
La prueba explore_case_preview_test.dart verifica igualdad con el original.

Originales exportados desde Figma. Se conservan aquí como fuentes de diseño.

- `Logo EntreHuellas 512 vector inner v2@2x.png`: 1024 × 1024, fuente de los iconos Android clásicos. Conserva textura y sombras del diseño.
- `Logo EntreHuellas 512 vector inner v2-16.svg`: vector con viewport 512 × 512, fuente del símbolo y gradiente de los iconos adaptativos.
- Las exportaciones PNG de 256, 512 y 1200 se conservan como variantes del original.

## Regeneración Android

Desde `apps/mobile`, con dependencias resueltas:

```powershell
flutter pub get --enforce-lockfile
./tool/generate_android_icons.ps1
```

`flutter_launcher_icons` 0.14.4 genera los PNG clásicos en las cinco densidades Android. El script genera después los VectorDrawable y los recursos adaptativos API 26+/monocromáticos API 33+. La app los utiliza mediante `@mipmap/ic_launcher` en su manifiesto.

La versión adaptativa mantiene las formas y los colores del SVG, utiliza un fondo sin esquinas precortadas y centra el símbolo con escala 0.72. Los filtros SVG de textura/sombra interna no se trasladan a VectorDrawable. La variante monocromática permite aplicar el tema del sistema cuando el launcher lo admite. Los recursos generados se versionan; no se editan por separado.

Si cambia el archivo fuente o su estructura, revisar la configuración y el adaptador. La generación verifica el viewport y los cinco paths esperados antes de producir recursos. La generación actualizada incluye también catálogos iOS/macOS, web/PWA y Windows; no acredita ejecución o distribución en esas plataformas.

## Comprobar el icono instalado

Detener y volver a ejecutar la app con el perfil **Entre Huellas - desarrollo local**. Los recursos del launcher requieren reinstalación/compilación, no hot reload. Revisar el icono en el launcher del emulador y sus recortes. Si el launcher mantiene una copia anterior, desinstalar la app de prueba y volver a ejecutarla; la desinstalación elimina sus datos locales y su sesión.

La validación efectivamente realizada se registra en [ESTADO.md](../docs/ESTADO.md).

## Actualización global —17 de octubre de2026

Nueva exportación azul del17/10: ejecutar `apps/mobile/tool/generate_android_icons.ps1`
desde la raíz sincroniza también las cinco copias oficiales de marca: PNG de
Flutter, splash Android, PNG/SVG web y favicon256. Después regenera todos los
catálogos de iconos. `flutter_launcher_icons.yaml` y el manifiesto PWA usan los
colores azul central/final del nuevo gradiente. Las variantes `only.svg` y
`only-black.svg` no fueron actualizadas por el usuario en esta exportación;
se conservan, al igual que los estampados blancos de las ilustraciones.

Se mantienen intactas las fuentes actualizadas por el usuario. `only-black.svg` es la fuente geométrica del emblema monocromo usado como referencia de estampado blanco en ilustraciones; `only.svg` conserva la variante verde. La web conserva copia exacta del SVG completo en `apps/platform/public/brand.svg`; navegación usa el PNG oficial actualizado y el favicon deriva del PNG oficial256 para conservar su textura a tamaño pequeño. No se superpone el símbolo a las mascotas desde Vue/CSS: los emblemas blancos forman parte de los PNG regenerados mediante imagegen.

`apps/mobile/assets/branding/app_icon.png` y el splash Android son copias del PNG@2x actualizado. El generador existente ahora regenera también iconos iOS/web/Windows/macOS, además de Android, sin cambiar paquetes ni recrear apps. La ruta de fuentes se corrigió tras mover Flutter a apps/mobile. Los recursos para plataformas futuras no equivalen a builds o distribución verificados. Véase ESTADO para evidencia y límites.
