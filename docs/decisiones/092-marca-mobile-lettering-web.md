# ADR-092: lettering móvil igual al de la web

Fecha:19/10/2026, America/Lima. Estado: implementado localmente por instrucción del usuario.

El usuario solicita que la marca móvil coincida con la web en fuente y grosor.
Comparación: app_icon.png y /brand.png tienen el mismo SHA256; el símbolo ya
coincide. La discrepancia estaba en «Entre\nHuellas»/sans-serif800 del móvil frente
a «entre huellas»/Arial500/#171918/tracking−.05em del SiteBrand web.

BrandName renderiza wordmark.svg: contornos de Arial regular (cara disponible
que resuelve el peso CSS500), minúsculas, color#171918 y tracking−.05em. Se exporta
solo el lettering de marca; no se redistribuye un archivo de fuente ni se depende
de Arial instalada en Android o de una descarga. SVG con paths, sin elementos text.
Flutter usa flutter_svg ya instalado. Script reproducible en
apps/mobile/tool/generate_brand_wordmark.py (fonttools como herramienta local).

BrandWordmark y StartupReveal reutilizan BrandName; no queda otra variante de
lettering visible en Flutter. Mantienen sus tamaños por recorrido y composición
en dos líneas, como la marca del login web responsive; no se copia el layout
de toda la web. Gap7px en tamaños compactos y16px con icono≥76. Viewport SVG y
dimensiones explícitas mantienen geometría antes/después de cargar el recurso.
Como arte de marca conserva tamaño gráfico al ampliar texto, con FittedBox para
ancho disponible y etiqueta accesible «Entre Huellas» del contenedor. El resto
de los textos conserva fuente/tamaño ampliado existentes.

No cambia iconos oficiales, splash nativo, launcher, marca web, body de pantallas,
fondo, glass, navegación, dominio/data o permisos. Conserva movimiento del arranque,
cabeceras y movimiento reducido. Requiere nuevo arranque para registrar el asset.
Sin HU/RF/issue nuevos ni cierre de historias. Validación y límites en ESTADO.
