# Ilustraciones de onboarding

Tres assets independientes, derivados de las ilustraciones de las tres primeras pantallas de `mockups/Entre huellas_ bienvenida y cuenta-1.png` mediante la herramienta integrada **image_gen** (modo built-in, sin CLI).

| Archivo | Ilustración | Formato |
| --- | --- | --- |
| `dog_waving.png` | Perrito saludando con la pata levantada | PNG RGBA, 1254 × 1254 |
| `dog_with_map.png` | Perrito con mapa y marcador rojo | PNG RGBA, 1254 × 1254 |
| `dog_and_cat.png` | Perrito abrazando al gato blanco | PNG RGBA, 1254 × 1254 |

Se solicitó extraer y reconstruir con más detalle cada personaje, conservar poses, colores, bandana, expresiones y estilo 3D del mockup, eliminar marcos/textos/controles y entregar transparencia real. Son reconstrucciones generadas desde la referencia, no ampliaciones deterministas de sus píxeles. Las tres salidas mantienen canal alfa y se copiaron sin redimensionar ni recomprimir.

Los prompts exactos están en [generation_prompts.json](generation_prompts.json). El mockup original permanece en `mockups`; ya no se incluye una copia del tablero completo en el bundle de Flutter. `OnboardingIllustration` muestra cada PNG con `BoxFit.contain`, sin recortes de orejas o patas. Textos, indicadores y botones siguen siendo widgets reales y accesibles.
