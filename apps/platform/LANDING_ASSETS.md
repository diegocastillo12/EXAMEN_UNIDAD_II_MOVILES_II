# Ilustraciones independientes de la landing

Detalle superpuesto del footer18/10: LandingSideNote contiene formas orgánicas
SVG nativas y reutiliza las huellas originales. La frase usa
`public/fonts/kalam/Kalam-Regular.ttf`, descargada sin modificar del repositorio
oficial google/fonts, directorio ofl/kalam, junto a OFL.txt (SIL OFL1.1;
copyright2014 Indian Type Foundry). Archivo427360bytes; fuente servida localmente,
sin peticiones externas. Solo se aplica a la frase del adorno.

Decoración18/10/2026: `public/images/landing/only.svg` es una copia sin cambios
de `logo/only.svg` (374×354). Tras referencias del usuario, LandingPawTrail usa
su silueta como máscara CSS en cuatro huellas por sección (dos en oportunidad
móvil), tonos salvia/celeste/durazno, opacidad0.36 y proporción original.
Recurso local decorativo sin animación adicional; no forma parte de los PNG
generados. Sustituye los tres pares pequeños de la primera versión.

Generadas el17 de octubre de2026 con la herramienta integrada image_gen, aplicando la habilidad imagegen. Siete llamadas independientes, una por ilustración; sin CLI/API ni credenciales. Referencia de estilo: captura de personajes facilitada por el usuario en este chat. No se utilizó esa captura como textura, fondo, atlas o recurso de la página final.

Los PNG originales de generación se conservan con transparencia en `public/images/landing`. Sin escalar artificialmente ni recortar un mockup; las dimensiones finales se registran en `landing_artwork.ts`. No se promete resolución 4K ni detalle infinito. El logo no se genera: se usa el recurso oficial existente `/brand.png`, también usado por la plataforma.

## Prompts finales

Prompt de perro curioso: una ilustración independiente cuadrada, fondo realmente transparente, del cachorro pastor alemán dorado/negro de la referencia, ojos marrones grandes, orejas expresivas erguidas, hocico crema, nariz brillante, cabeza inclinada y expresión alegre, pañuelo carbón sin emblema. Personaje de animación3D detallado, iluminación de estudio suave y cálida, bordes definidos. Busto con patas delanteras, orejas completas dentro del encuadre. Sin texto/logotipo/UI/marcos/fondos/degradados/marca de agua. Solicitado2048×2048; se conserva la resolución real devuelta, sin inventar píxeles.

Prompt común para los seis restantes: `Use case: stylized-concept. ONE independent production 3D illustration, not a website screenshot. Use the attached reference ONLY for the puppy/kitten character identity and premium 3D style. Same adorable tan-and-black German shepherd puppy, large brown eyes, upright expressive ears, cream muzzle; same fluffy seal-point ragdoll kitten, blue eyes, cream coat and brown ears/mask/tail. Simple charcoal bandanas without emblems. Detailed soft fur, expressive friendly faces, warm soft studio lighting, polished animated-film render, crisp edges, high resolution. Genuine TRANSPARENT BACKGROUND. Entire characters/ears inside canvas with 6% clear margin. NO text, NO labels, NO UI, NO cards, NO frames, NO website, NO collage, NO colored background, NO watermark, NO logos.`

Se añade la escena correspondiente:

| Archivo PNG | Especificación de escena añadida |
| --- | --- |
| dog-curious.png | Perro curioso descrito arriba; personaje base de Busco, hero y footer. |
| cat.png | Square2048×2048. ONLY the ragdoll kitten, front three-quarter sitting bust, front paws visible, looking up with adorable bright blue eyes and tongue slightly peeking, fluffy curled tail along side. No puppy. |
| dog-wave.png | Square2048×2048. ONLY the German shepherd puppy greeting the viewer, one front paw raised with realistic dark pads visible, happy open mouth, pink tongue, expressive eyes; friendly sitting bust. No kitten. |
| reunion.png | Square2048×2048. Puppy and kitten together, cuddling cheek to cheek, kitten eyes happily closed, puppy delighted, both front paws visible. Intimate warm reunion pose. |
| dog-report.png | Square2048×2048. German shepherd puppy proudly holding a small white paper notice in a front paw, paper contains ONLY a small simple purple paw symbol and three pale blue abstract horizontal lines, no letters or words. Puppy smiles at viewer. Single illustration, not a card layout. |
| pets-home.png | Landscape2048×1024. Puppy and kitten lying comfortably side by side in front of a small warm pale-wood pet house with a heart-shaped opening, a few rounded green plants on either side. Both pets as protagonists; fully visible ears and paws. Compact arrangement at bottom, no floor rectangle, surroundings transparent. No words or graphic heart stickers. |
| pets-map.png | Landscape2048×1024. Puppy and kitten collaborating over an unfolded pale street map, a single friendly purple location pin standing in middle of map, a few small rounded green leaves at edges. Both looking toward viewer/map, visible ears and paws; coherent compact tableau. No letters, words, borders or graphic labels; transparent surroundings. |

## Composición real

LandingArt inserta un PNG independiente mediante img con dimensiones nativas y carga diferida salvo hero. El mismo personaje se reutiliza donde tiene sentido para mantener identidad y caché; seis tarjetas no implican seis descargas distintas. LandingCharacterCard contiene figura, etiqueta HTML y decoración SVG. Superficies, fondos, degradados, círculos, ubicaciones decorativas, bordes, botones y textos se implementan en Vue/CSS/SVG. Sin desplazamientos/variables de atlas ni máscaras para ocultar restos de captura.

La animación aprobada del hero conserva cover-reveal y stagger-reveal, duraciones/demoras y movimiento reducido. Este cambio no altera el QR ni sus fotos de producto.

Dimensiones reales de entrega: cinco PNG de1254×1254 y dos de1774×887, todos RGBA. La petición de tamaño en el prompt no implica que la herramienta haya devuelto ese tamaño exacto. Se conservaron los píxeles devueltos sin reescalado artificial. Los originales ocupan aproximadamente12.5MB en conjunto; carga diferida y reutilización por URL reducen descargas iniciales, sin acreditar todavía Core Web Vitals ni transferencia en red móvil real.

## Actualización vigente: diversidad y estampado en tela —17/10/2026

Diez PNG finales, generados/editados individualmente con la herramienta integrada image_gen. Los tres primeros personajes añadidos fueron corgi, dálmata y gato atigrado naranja/blanco. Después, por corrección explícita del usuario, TODAS las ilustraciones se regeneraron con pañuelos variados y el emblema blanco incorporado en los píxeles de la tela. Se retiraron por completo las capas SVG de emblemas y sus coordenadas: LandingArt solo inserta el PNG. No hay logos superpuestos en ejecución.

Fuente geométrica: `logo/only-black.svg`. Se renderizó únicamente para referencia de imagegen, en negro sobre blanco y en blanco sobre carbón; esos archivos de QA están en apps/mobile/build/brand-reference, fuera del público. Las fuentes SVG originales no se modificaron. La herramienta reproduce el símbolo en la tela con perspectiva, pliegues, textura y luz: no constituye una garantía de identidad vectorial píxel a píxel. La web conserva el SVG completo actualizado en /brand.svg y usa el PNG oficial actualizado en navegación, evitando el aliasing de sus filtros de grano a tamaño pequeño; el favicon procede del PNG oficial256.

### Prompt común final

`Use case: precise-object-edit / stylized-concept. Image 1 is the scene/character EDIT TARGET. Keep its premium 3D animated-film style, detailed fur, expressive eyes, warm studio lighting, pose, framing, objects, character count, and transparent background. Images 2 and 3 show the SAME OFFICIAL Entre Huellas emblem in black and white, for exact SHAPE reference only; their backgrounds must NOT be included. Integrate the official emblem as a small WHITE monochrome ink screenprint into EVERY visible neckerchief. Crucial shape: FOUR separate rounded toe pads above one pointed, location-pin-shaped paw pad with a CIRCULAR NEGATIVE-SPACE HOLE in the middle; that hole reveals the fabric beneath. Not a generic solid paw. The print must follow fabric folds, weave, perspective, lighting and subtle occlusion, as part of the rendered textile. No floating decals, no SVG overlays, no patches, no pendants, no green logos, no words, no watermark, no UI or card backgrounds. Preserve alpha and high resolution.`

A ese prompt se añadió la variante de cada archivo:

| Archivo | Variación final pedida |
| --- | --- |
| dog-curious.png | Mismo pastor alemán; pañuelo verde bosque y emblema blanco. |
| cat.png | Mismo ragdoll con ojos azules; pañuelo azul marino y emblema blanco. |
| dog-wave.png | Cocker spaniel dorado con orejas largas suaves, pose de saludo/pata elevada conservada; pañuelo burdeos y emblema blanco. |
| reunion.png | Pastor y ragdoll abrazados, pañuelos petróleo y ciruela; emblema blanco en ambos. |
| dog-report.png | Perro mestizo canela/blanco con orejas semicaídas y gato calicó; pañuelos azul y terracota; estampados blancos. Conservar aviso, sustituir huella genérica por símbolo oficial púrpura y mantener líneas abstractas sin letras. |
| pets-home.png | Retriever dorado y gato gris de ojos ámbar; casa/plantas/composición conservadas; pañuelos burdeos y marino, estampados blancos. |
| pets-map.png | Beagle tricolor y gato blanco/negro de ojos verdes; mapa/pin/hojas conservados; pañuelos verde y ciruela, estampados blancos. |
| dalmatian.png | Mismo dálmata con orejas caídas y saludo; pañuelo rojo ladrillo/terracota con estampado blanco. |
| tabby.png | Mismo atigrado naranja/blanco, ojos verdes y pelo corto; pañuelo petróleo con estampado blanco. |
| corgi.png | Mismo corgi, fondo transparente y pañuelo carbón; integrar símbolo blanco exacto de referencia como estampado sobre pliegues/textura, sin verde ni rectángulos. Este primer edit usó identity-preserve y solo modificó el estampado. |

Los archivos finales están en `public/images/landing`; las dimensiones reales figuran en landing_artwork.ts y no se han inventado píxeles para aumentarlas. Se conservan ilustraciones PNG independientes y la UI continúa en Vue/CSS/SVG. La animación del hero no cambia. Las especificaciones anteriores describen la generación inicial; esta sección define los recursos vigentes.

## Corrección de contornos —17/10/2026

El usuario señaló el borde oscuro y continuo del dálmata, frente al pelaje natural
de su segunda referencia. La corrección se realiza en los PNG con imagegen
integrado, una edición por ilustración; no mediante filtros CSS, desenfoque global
ni capas sobre la imagen. Se conserva una copia anterior de QA fuera del público
en apps/mobile/build/landing-before-natural-edges. Los originales de generación
permanecen en el directorio generated_images de Codex.

Prompt de edición común (imagen1: PNG objetivo; imagen2: detalle de pelaje natural
aportado por el usuario, únicamente como referencia de acabado):

> Use case: precise-object-edit. Refine only the artificial perimeter of the target
> illustration. Remove continuous dark outlines, brown edge bands, bright rim-light,
> halos, oversharpened edges, and sticker-like silhouettes. Replace the perimeter
> with fine individual organically uneven fur hairs, subtly translucent tips and
> natural soft transitions to true transparent background. Preserve breeds, coat
> lengths, markings, expressions, eye colors, poses, character count, objects,
> framing, bandana colors and white official Entre Huellas symbols printed in the
> fabric: four separate toe pads over a pointed paw/location-pin pad with a circular
> negative-space hole. Keep textile shading, folds and texture. Broad soft diffuse
> studio lighting and restrained natural material colors. Retain crisp face, eyes,
> fur and fabric detail. No outline, stroke, halo, color fringe, colored matte,
> ground shadow, whole-image blur, new objects or UI. Genuine transparent background,
> same aspect ratio and high resolution.

El dálmata añade explícitamente pelo corto y atención a cola, orejas y patas.
Este criterio sustituye las peticiones históricas de «crisp edges» cuando provoquen
una silueta perfilada. La referencia no se incorpora a la web como fondo o textura.

### Aclaración vigente: sin luminosidad anaranjada

El usuario aportó después tres referencias de acabado: mockups/Imagen de ChatGPT
7 oct 2026, 17_03_12.png, mockups/landing-mascotas-v2/buscar-juntos.png y
mockups/landing-mascotas-v2/reencuentro-feliz.png. No basta suavizar un perfil:
también se debe retirar el brillo anaranjado y cualquier iluminación de borde
ajena al pelaje. La segunda pasada usa esas tres imágenes como referencias de
acabado, manteniendo los personajes/escenas actuales y la marca estampada.
Sus fondos y sus huellas genéricas no son recursos que deban copiarse.

Prompt final de iluminación y acabado, aplicado individualmente a los diez PNG:

> Image 1 is the EDIT TARGET. Images 2,3,4 are the user's APPROVED REFERENCES for
> natural fur rendering and clean silhouettes, NOT their backdrops, characters,
> props or generic paw symbols. Re-light target with neutral diffuse light, soft
> material shading and finely resolved individual fur at the silhouette. NO
> continuous outline of any color. Remove orange/gold edge light, warm backlight,
> saturated rim, glowing fringe, light spill, dark border, sticker outline and
> colored matte contamination from all ears, tails, paws and body edges of every
> animal. Do NOT replace the orange halo with a white halo or blur the silhouette.
> Preserve fine fur detail and clean alpha, without surrounding haze or glow.
> Keep biologically golden/orange coat colors but no separate luminous perimeter.
> Preserve breeds, count, markings, faces, expressions, poses, objects, composition,
> framing and bandana colors. Preserve every official white Entre Huellas print
> in fabric, four toe pads and pointed main pad with circular hole revealing cloth.
> No new elements or overlays. One high-quality independent PNG, genuinely
> transparent background, original aspect ratio. Sole change: clean naturally
> shaded fur edges, absolutely no colored rim light or artificial contour.

El criterio de aceptación es visual: revisar tanto el archivo sobre fondos claros
como sobre oscuro, y el detalle al100%, además de la integración responsive. Las
comprobaciones automáticas acreditan dimensiones/decodificación y composición,
no una garantía matemática de acabado artístico ni fidelidad vectorial del print.

### Revisión posterior: pelo definido, sin suavizado del perímetro

Las dos pasadas anteriores fueron rechazadas visualmente por el usuario: seguían
mostrando luminosidad/perfil artificial y algunas perdían detalle. No constituyen
un acabado aprobado, aunque las imágenes se decodifiquen correctamente. La nueva
referencia prioritaria es mockups/landing-mascotas-v1/gatito-curioso.png. Conservar
hebras individuales y pequeñas irregularidades del pelo en la silueta, con su
color local hasta la punta; no sustituir el contorno por una banda luminosa,
desenfoque, feathering o franja oscura. Validar primero un dálmata a tamaño nativo
sobre claro y oscuro antes de extender el resultado. Las capturas generales de
las pasadas anteriores no acreditan aceptación artística.

Prompt del nuevo piloto, imagegen integrado (PNG de dálmata del usuario como
objetivo y gatito-curioso.png como referencia de pelo):

> Refine the fur of the Dalmatian puppy in image 1 to match the beautifully
> detailed fur rendering of the kitten in image 2. Keep the Dalmatian's character,
> spots, pose, red bandana and white printed emblem. Render distinct fine short
> hairs all along the puppy's ears, tail, paws and silhouette, with delicate
> irregular tips in the same color as the neighboring fur. Detailed natural groom
> and soft neutral front lighting. Preserve crisp fur texture; the silhouette
> should consist of hairs, without a continuous drawn contour or luminous outline.
> No edge glow, orange rim light, dark stroke, airbrushed edge, blur, haze or
> backdrop. Square composition, full puppy inside canvas, genuinely transparent
> background.

Un primer intento de este piloto no produjo archivo: rechazo de la herramienta
en moderación de salida (categoría other). El segundo generó un candidato que
se revisa en fondos sólidos y detalle nativo, fuera del público hasta seleccionarlo.

### Selección integrada de la pasada de pelo definido

El dálmata del piloto y nueve ediciones independientes desde las copias anteriores
al suavizado sustituyen los diez PNG públicos. No se aplicó tratamiento de píxeles
con scripts: las copias conservan exactamente el PNG y el alfa devueltos por
imagegen integrado. Prompt común final para los otros nueve:

`Refine the fur of the animals in image 1 to match the beautifully detailed fur rendering of the kitten in image 2. Image 2 is ONLY a fur-quality reference; keep image 1's exact breeds, number of pets, markings, fur lengths, eye colors, faces, expressions, poses, all scene objects, composition and framing. Render distinct fine individual hairs along EVERY animal's ears, tails, paws and silhouette, with delicate irregular tips in the same local color as neighboring fur. Follow each animal's coat length, short coats stay short, long coats stay fluffy. Detailed natural groom, crisp strand texture and soft neutral front lighting. The silhouette should consist of hairs without a continuous drawn contour or luminous outline. No edge glow, orange rim light, colored spill, dark stroke, airbrushed edge, blur or haze. Keep EVERY neckerchief's original color and official WHITE printed emblem as part of fabric, four separate toe pads above a pointed paw/location-pin pad with a circular hole revealing cloth. Preserve printed texture/folds, no overlay, no substitution with the reference kitten's generic paw. Preserve all props/map/house/plants/paper if present. Genuine transparent background, no backdrop or floor shadow, same original aspect ratio. One detailed independent production illustration.`

Destinos: apps/platform/public/images/landing/{dog-curious,cat,dog-wave,reunion,
dog-report,pets-home,pets-map,corgi,dalmatian,tabby}.png. Ocho1254×1254 y
dos1774×887; total20862121bytes, originales sin reescalado. El manifiesto de
selección con rutas de generación y los hashes se conservan para QA en
apps/mobile/build/landing-fur-final.json y landing-fur-assets.log, fuera del público.
Se conserva carga diferida y reutilización por URL; no se acreditan métricas
reales de red móvil ni Core Web Vitals.

Build SSR y QA Chrome responsive aprobados para esta selección; capturas en
apps/mobile/build/ui-preview/landing-vue. Detalle de pelo en landing-fur-pilot-detail.png
y conjunto sobre fondos claros/oscuros en landing-natural-edges{,-dark}.png.
La selección e integración local no implican aprobación artística del usuario;
las versiones previas rechazadas quedan documentadas como tales.

### Corrección pendiente de revisión: sombreado gris sobre pelo blanco

El usuario volvió a rechazar el piloto anterior y precisó el defecto en un
acercamiento de la oreja: el pelo blanco se oscurece junto a la silueta. No se
ha aceptado el conjunto integrado. No continuar sustituyendo imágenes en bloque
sin resolver primero esta diferencia en una muestra.

Se hicieron dos ediciones locales con imagegen integrado, sin cambiar PNG públicos.
La primera retira el sombreado gris pero produce una silueta demasiado lisa; se
conserva solo como intermedio en apps/mobile/build/landing-white-fur-review/
light-material.png. La segunda recupera fibras sobre ese material claro; candidato
en el mismo directorio como dalmatian.png. Comparación de oreja a resolución
nativa sobre gris en apps/mobile/build/ui-preview/landing-white-fur-ear.png.

Prompt del primer edit:

`Precisely edit the Dalmatian puppy in image 1. Image 2 is a PROBLEM CLOSE-UP of its ear: the user rejects the dirty gray/brown shaded band on WHITE fur along the outer ear. This edit is specifically about that band of surface shading, not about adding a fuzzy border. Correct the white fur material/lighting at the silhouette of both ears, tail, legs and head: neutral ivory WHITE hairs must retain the SAME light local color as adjacent interior white fur right through their tips. Lift/remove the narrow gray/brown edge-shadow strip on the white coat. Uniform broad frontal and side fill light, zero silhouette ambient-occlusion darkening, zero Fresnel edge tint, zero vignette baked into the fur. Keep detailed individually resolved hair strands sharp. White fibers stay ivory white even at the outer side of an ear; they should not become gray or beige just because they are at the perimeter. Preserve every real BLACK SPOT and black hair: do not recolor legitimate black markings, do not erase black hairs, do not bleach the whole animal. Preserve face, pose, anatomy, terracotta neckerchief, white printed Entre Huellas paw/location-pin symbol with round opening and original framing. The requested change is white-fur edge-shadow removal ONLY. No added bright edge, no glow, no outlining in any color, no artificial white band, no blur, no airbrushing, no alpha feathering, no new objects. Natural finely stranded fur silhouette with local material colors. Genuine transparent background, square high-resolution PNG.`

Prompt del segundo edit (intermedio claro como objetivo, gatito-curioso.png como
referencia de detalle de fibras):

`Edit image 1, keeping its corrected LIGHT ivory white fur colors and uniform fill lighting. Image 2 is a reference for detailed individual fur strands only. The Dalmatian's white ear perimeter in image 1 is too smooth and solid, like a cut-out paper shape. Replace that smooth outer cut line with actual fine individual short WHITE hairs, irregular little strand-tipped tufts, alternating lengths/directions and tiny transparent gaps between fibers, matching the detail quality of image 2 while keeping a short-haired dog coat. Especially rebuild the outer left ear tip and edge. At native resolution the short hairs should be visibly resolved rather than a soft blur: about 4–10 pixels long at the silhouette, slender and detailed. Continue surface hairs naturally into those tips; there must be no solid white ribbon underlying the edge. KEEP every white strand the same LIGHT ivory white from root to tip: no gray/brown edge-shadow band, no darkening toward the silhouette, no halo or outline, no glowing rim, no color cast. Preserve black patches as real black fur; preserve pose, character identity, face, bandana, official white paw/location-pin print with circular hole, anatomy and full framing. Maintain corrected bright neutral fur material; only rebuild the unnaturally smooth perimeter into detailed fibers. No smoothing/blur/airbrush/feathered mask, no added background or ground shadow. Genuine transparency, one high resolution square PNG.`

Validación: archivo inspeccionado y renderizado sobre gris al100%. No se acredita
aceptación artística, sustitución del conjunto, QA responsive nuevo ni corrección
de todas las mascotas. Los builds anteriores no validan el acabado de esta muestra.

### Nueva base: el original hero-bienvenida.png del usuario

El usuario aclara también la forma de la cola y el volumen de los mechones.
La referencia principal es mockups/landing-mascotas-v1/hero-bienvenida.png,
1536×1024 RGBA ya transparente. Los valores RGB cálidos de áreas con alfa0 no
constituyen un fondo opaco que deba extraerse. Se cambia de enfoque: edición
mínima sobre esa fuente, sin usar como objetivo los PNG de pelaje rechazado.

Muestra imagegen con estampados oficiales en los dos pañuelos, conservada fuera
del público en apps/mobile/build/landing-approved-source-review/hero-bienvenida.png.
Salida1536×1024, muestras exteriores alfa0, sin reescalado por scripts.
Comparación nativa de cola: apps/mobile/build/ui-preview/landing-approved-tail-comparison.png
(original del usuario / edición con emblemas / reencuentro rechazado).
No se ha sustituido ninguna imagen de ejecución con esta muestra y el dálmata
sigue sin resolver. El cambio de los estampados es la instrucción de edición;
no se afirma que imagegen preserve matemáticamente todos los demás píxeles.

Prompt final de esta muestra (referencia2: render blanco del only-black.svg):

`Image 1 is the user's approved ORIGINAL artwork and EDIT TARGET. Make ONE minimal localized change: replace the generic white paw printed on EACH black bandana with the official white Entre Huellas symbol from image 2. It has four rounded toe pads above a pointed main paw/location-pin pad with a round negative-space opening showing the cloth beneath. Keep the print small, following the existing cloth folds and light. Image 2 is only the symbol reference; do not include its dark square background. Preserve ALL other artwork from image 1: original detailed individual fur fibers, fluffy long dog tail with separated irregular wisps, cat tail, ears, original fur colors, existing natural lighting, anatomy, faces, expressions, pose, composition, black bandanas, aspect ratio and transparent alpha background. Do NOT re-render, simplify, sharpen, blur, outline, smooth, recolor or relight the fur or silhouette. Do NOT introduce any new dark shadow band or luminous halo around white fur. No new scene elements. This is a logo-print-only edit of the approved source, not a new illustration. Keep genuinely transparent background as in source and high native detail.`

### Últimas pruebas: rechazadas, sin integración

Nuevo dálmata desde hero-bienvenida.png y símbolo oficial: salida
exec-2652cca3-1eec-4395-ac0e-bc958a6ab5c5.png en generated_images de Codex,
rechazada por tinte/borde anaranjado. Corrección cromática posterior
exec-2e9fc014-ca73-43be-a250-d656f8e7fcea.png, rechazada por ribete blanco y
pérdida de detalle en cola. Ambas son candidatos descartados de la selección,
no recursos finales ni ejemplos de cumplimiento. No hay ocho variantes nuevas
aprobadas ni generadas a partir de ellos. No afirmar equivalencia con la
referencia original o solución del problema.
# Dálmata: edición integrada del 17/10/2026

Actualización: e5839c84 fue rechazado por el usuario y sustituido por
`exec-228f74fc-9ac3-428c-89de-5a5f1d1932bc.png` (1312×1199 RGBA).
Entradas: referencia original `Imagen de ChatGPT 7 oct 2026, 17_03_12.png`
y emblema blanco. Se pidió pelo blanco hasta las puntas, pelo negro hasta
las puntas negras, sin franja de sombreado en mejilla ni iluminación de
contorno; cola entera con mechones definidos. Copia directa, sin filtros.
La tarjeta usa contain para conservar toda la silueta. Aceptación pendiente.

Fuente ImageGen: `exec-e5839c84-0e7b-46ec-8087-e9bfc66c8f4c.png` en generated_images
de Codex; copia directa en `public/images/landing/dalmatian.png`, 1254×1254 RGBA.
Se pidió conservar pose, logo impreso y hebras de cola, corrigiendo solo el
acabado del borde: negro hasta la última hebra negra, blanco neutro hasta la
última hebra blanca; sin rim light, contorno, nube difusa ni sombra externa.
Sin filtros posteriores. Comparado al 100 % en Chrome sobre gris. Esta
integración no equivale a aprobación artística del conjunto.

# Colección vigente: estilo del dálmata aprobado

## Corrección anatómica de dog-report —17/10/2026

Por solicitud del usuario se sustituye dog-report.png mediante imagegen integrado
(edición precise-object-edit del recurso anterior). Fuente generada:
exec-151f282c-8705-43ac-9f3d-e720e9b41e4d.png, conservada en generated_images de
Codex y copiada al recurso público. PNG1312×1199 con alpha real, dimensiones
previas conservadas. Se pidió retirar la pata delantera extra bajo la pata que
sostiene el papel: exactamente una delantera levantada, otra apoyada y dos
traseras sentadas. Conservar spaniel, gata calicó, papel, pañuelos petróleo y
terracota, emblemas blancos, pelaje/expresiones y composición, sin fondo añadido.
Revisión visual de anatomía y ambos usos web en ESTADO. Sin filtros posteriores.

La pasada [Colección desde el dálmata aprobado](LANDING_APPROVED_STYLE.md)
sustituye los recursos y estados de rechazo anteriores para las ocho variantes.
El dálmata fue aprobado explícitamente por el usuario antes de esta pasada.

