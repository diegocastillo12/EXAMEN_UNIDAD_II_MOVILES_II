# Relevo para continuar el diseño de la landing

**Relevo actualizado — 18/10/2026:** el usuario aprueba la landing final,
incluidos los últimos retoques, y la adopta como referencia de toda la web.
Las menciones anteriores de valoración pendiente quedan resueltas por esta
aprobación. Antes de continuar leer [REGLAS_UI_UX_WEB](REGLAS_UI_UX_WEB.md) y
[ADR-063](decisiones/063-landing-como-referencia-ui-ux-web.md). No hay publicación
ni migración visual del QR en este incremento documental.

Actualizado el 17/10/2026, America/Lima. El usuario acaba de aprobar el estado
actual: «ok esta perfecto». Continuar desde esta base, sin rehacerla.

## Ubicación y estado de trabajo

- Repositorio: `C:/Users/Administrator/Documents/projects/entreHuellas`.
- Rama comprobada: `feature/vue-nuxt-web`. Verificar al empezar; no crear otra
  rama ni volver a la antigua `feature/landing-page` por instrucciones históricas.
- Web unificada Vue/Nuxt/TypeScript: `apps/platform`. Flutter: `apps/mobile`.
  No usar el antiguo proyecto React ni crear `apps/landing-page`.
- Hay cambios locales y PNG nuevos sin commit, además de cambios del usuario
  en `logo/`. Preservarlos. Este relevo no hace commit, push ni despliegue.
- Dev existente: `http://127.0.0.1:5173`, proceso9128 al preparar este documento.
  Comprobar si sigue activo y reutilizarlo; no cerrarlo ni iniciar un duplicado.
- Leer AGENTS.md, REGLAS_ARQUITECTURA, REGLAS_UI_UX, ESTADO, ARQUITECTURA,
  la sección de calidad visual de GUIA_MVP y la ficha de landing.

## Diseño aprobado que se debe conservar

- Radio de todos los botones999px, incluidos secundarios/lima y responsive,
 por instrucción posterior del usuario17/10. Regla centralizada en .button.

- Último ajuste17/10: botones azules de cabecera/cierre como referencias del
 usuario: cápsula999px, degradado75BFFF/459FF6/2887EF, blanco, brillo y sombra.
 dog-report.png corregido mediante imagegen para retirar quinta pata; mismo
 tamaño1312×1199 y transparencia. Evidencia glossy-buttons/report-anatomy.

- Corrección17/10 de fondos blancos: .aurora::before requiere content vacío,
 posición absoluta, z-index:-1 e inset:0. Conservar esta base compartida al
 modificar gradientes; hero original y cierre azul. QA ahora verifica generación
 y dimensiones reales de ambas capas. Evidencia aurora-fix en ESTADO.

- Última corrección17/10: secciones4/5/6 (oportunidad/comunidad/colaboración)
 recuperan colores originales. «Una huella tuya» CONSERVA azul por rectificación
 explícita del usuario. Hero original, geometría y retirada de pines02/03 intactos.
 Evidencia sections-original en ESTADO.

- Propósito17/10: 01–04 conservan color original171918; usuario solicita quitar
 pines CSS morados de imágenes02/03. Eliminados ::before/::after respectivos;
 no reintroducir overlays. PNG y encuadres intactos. Evidencia steps-cleanup.

- Última corrección17/10: HERO con paleta original (gradiente vivo, botones
 lima/celeste, badge, valores blancos y fondos de mascotas). Demás secciones
 y cabecera conservan azul nuevo. Layout/animación intactos. Evidencia
 hero-original-colors en ESTADO; sustituye la paleta azul del hero.

- Paleta azul autorizada17/10: botones principales3C537B/blanco, secundarios
 celesteB5D5E9/azul; fondos azul/celeste/lavanda, verde residual suave. Crema,
 mascotas, geometría, pie y animaciones intactos. Clases de botón ahora
 button-primary/button-secondary. Sustituye la prioridad lima histórica.
 Build/tipos/9 pruebas/QA aprobados; evidencia blue-palette en ESTADO.
 Pendiente valoración visual del usuario; servidor5173 reutilizado.

- Usuario aprueba texto entre mascotas. Último ajuste17/10: solo reducir el
 margen superior del pie a clamp(24px,3vw,48px); resto del encuadre conservado.
 Logo renovado otra vez y sincronizado en web/móvil/splash/iconos. Evidencia
 footer-gap-logo en ESTADO y apps/mobile/build.

- Aclaración final17/10 del pie: texto ENTRE mascotas, ligeramente elevado
 20–40px respecto al centro vertical; ancho36%, imágenes39% completas y en
 laterales. Sustituye la fila superior independiente de los ajustes previos.
 Móvil conserva dos filas. Cierre alto intacto. Evidencia footer-centered.

- Corrección posterior del pie17/10: conservar tamaño original de mascotas,
 39% del ancho cada una en escritorio,50% móvil. Contenido arriba e imágenes
 completas en fila natural inferior. Sustituye las columnas laterales que
 redujeron su tamaño. Cierre alto conservado; evidencia footer-original-size.

- Ajuste solicitado17/10 del cierre/pie: bloque «Una huella tuya» mucho más
  alto (mínimo420–640px;440px móvil). Pie en tres columnas, contenido arriba
  y mascotas completas a los lados; móvil con mascotas en segunda fila.
  Sin posiciones negativas ni contenedor que recorte cabezas. Build y QA
  responsive/texto ampliado/SSR/QR aprobados, capturas revisadas en
  apps/mobile/build/ui-preview/footer. Pendiente valoración visual del usuario.

- Actualización de títulos17/10: todos los h2 de sección usan el tamaño de
  propósito, variable --section-title-size: clamp(29px, 4.3vw, 58px), móvil34px.
  Hero h1 intacto. La tarjeta de imagen de comunidad es30% más alta, proporción
  305:160 (antes305:123). Build y QA pasados, logs landing-heading-scale-*.log
  en apps/mobile/build; pendiente valoración visual del usuario.
- Actualización posterior17/10: usuario aprobó ancho de propósito alineado con
  hero y ventanas de sus cuatro imágenes3:1 (antes3.6:1). Después pidió extender
  el mismo ancho a todas las secciones: `.wrap` compartido sin máximo1280px,
  ancho `calc(100% - clamp(24px, 4vw, 64px))`, móvil conserva14px por lado.
  Cabecera/secciones/pie alineados; arte y movimientos conservados. Build y QA
  pasados, incluida alineación hasta1920px. Logs landing-sections-width-*.log
  en apps/mobile/build. Último ancho global pendiente de revisión del usuario.
- Hero casi de primera pantalla: altura mínima100svh descontando cabecera y
  margen, contenido centrado, ancho casi completo, título hasta108px y mascotas
  hasta148px en escritorio; móvil tiene escala propia y crecimiento natural.
- Conservar la animación principal aprobada: cover0.7s y stagger0.55s con
  retrasos0.2/0.3/0.4/0.5s. Respetar movimiento reducido.
- Marca visible de cabecera/footer: «entre huellas», minúscula y peso500.
  Conservar el icono oficial; no cambiar arbitrariamente los textos editoriales.
- Las dos imágenes pequeñas del HERO son las anteriores restauradas:
  `hero-dog.png` y `hero-cat.png`, ambas1254×1254. No reemplazarlas por las
  mascotas nuevas del resto. Ese cambio ya fue solicitado explícitamente.
- El usuario aprobó el nuevo dálmata y después el conjunto de ocho variantes.
  Mantener variedad de razas/pelajes y pañuelos con el emblema blanco impreso.
- Nada de mockup usado como fondo, etiquetas dibujadas en PNG ni logo DOM
  superpuesto sobre pañuelos. UI real en Vue/CSS/SVG y PNG independientes.

## Fila de tarjetas: estado final, después de varias correcciones

- Movimiento horizontal continuo120s, dos grupos de doce tarjetas (cada grupo
  repite dos veces las seis originales). Distancia y duración duplicadas para
  conservar la velocidad previa en píxeles y ampliar la onda sin salto. La segunda
  copia está oculta a lectores de pantalla. Sin pausa por hover/foco.
- Actualización de espacio17/10: desde propósito, las secciones siguientes y
  el pie tienen margen superior compartido40–88px (`--section-gap`). Conserva
  espacio de tarjetas a propósito; ancho global anterior intacto. Build y QA
  pasados; logs landing-spacing-wave-*.log en apps/mobile/build. Pendiente
  valoración visual del usuario.
- Onda viajera vertical6s según referencias posteriores del usuario: doce
  fases progresivas separadas0.5s hacia la derecha, amplitud24–56px y curva
  cubic-bezier(0.37, 0, 0.63, 1). Copias visuales adicionales decorativas.
  QA comprueba continuidad en la unión y propagación; logs
  landing-traveling-wave-*.log en apps/mobile/build. Pendiente valoración visual.
  Las tarjetas cambian de
  altura suavemente, no permanecen alternadas en alturas fijas.
- Botón circular de60×60px con icono28px, arriba a la derecha (top12px/right4%).
  Pausa/reanuda SOLO el avance horizontal; la onda vertical sigue activa.
- Separación externa40–72px y padding superior128–168px para que el control
  no choque con la cresta de la onda. Padding inferior72–104px.
- Etiquetas centradas, peso400. Ventanas de imagen centradas abajo.
- ÚLTIMO AJUSTE APROBADO: aumentar un poco SOLO el marco, sin escalar imágenes.
  Ancho `calc(var(--character-art-width) + clamp(20px, 2.6vw, 40px))`;
  alto `calc(var(--character-art-width) * 1.52414 + clamp(60px, 6.67vw, 96px))`.
  En1440px, tarjeta325px de ancho; incremento anterior aprox16px ancho/24px alto.
- `--character-art-width` sigue en `clamp(145px, 20.5vw, 288px)`, móvil155px.
  No modificar esta variable para agrandar el marco: agrandaría las mascotas.
- Ventana de arte: ancho base×1.45 individual/base×1.85 pareja, alto base×1.31076,
  `overflow: visible`; imagen `contain`. El ancho de tarjeta NO se multiplica
  por1.45/1.85. Ese error ya provocó un rechazo explícito.
- El recorte interior recto era el problema: la ventana de imagen no debe
  cortar antes del borde redondeado exterior. El marco exterior sí delimita
  la ilustración y los extremos de la fila salen naturalmente del viewport.
- No volver a reducir las imágenes para mostrar todo el PNG: el usuario pidió
  conservar su tamaño. Tampoco ensanchar mucho las tarjetas para alojarlo entero.

## Arte y fuentes

- Recursos finales: `apps/platform/public/images/landing` (doce PNG).
- Asignaciones y dimensiones: `landing_artwork.ts` en widgets de landing.
- Prompts y procedencia: `apps/platform/LANDING_APPROVED_STYLE.md`, enlazado
  desde `LANDING_ASSETS.md`. El historial anterior contiene versiones rechazadas;
  prevalecen este relevo y el código actual.
- Pareja `reunion.png`: conserva el pelaje de la referencia original; solo
  se cambiaron las zonas de estampado de los pañuelos. No regenerarla sin petición.
- Símbolo fuente: `logo/only-black.svg`; en pañuelos aparece blanco integrado.
- Si se pide arte nuevo, usar skill imagegen y su herramienta integrada.
  Referencia de estilo aprobada: dálmata actual, pelo detallado, sin contorno,
  halo artificial blanco/gris/naranja ni difuminado. No retomar candidatos rechazados.

## Archivos principales

- `apps/platform/app/features/landing/presentation/screens/LandingPage.vue`:
  secciones, grupos de tarjetas y estado de pausa horizontal.
- `apps/platform/app/features/landing/presentation/styles/landing.css`:
  estilos aislados bajo .landing-page. Hay overrides al final; leerlos antes de editar.
- `widgets/LandingCharacterCard.vue`, `LandingArt.vue`, `LandingBrand.vue` y
  `landing_artwork.ts`, dentro de la misma carpeta presentation.
- Ficha: `docs/funcionalidades/landing-page.md`. Estado: `docs/ESTADO.md`.

## Validación disponible

Último cambio: build SSR y QA Chrome1440/731/390/320px, texto200 %, imágenes,
FAQ/teclado/anclas, no-JS, CSP/hidratación y aislamiento landing→QR→landing pasados.
Se comprueba también altura del arte conservada, ancho de tarjeta325px en1440,
ventana sin clipping interior, pausa horizontal con onda activa, control y separación.

Logs locales: `apps/mobile/build/landing-card-small-increase-build.log` y
`landing-card-small-increase-browser.log`. Capturas actuales en
`apps/mobile/build/ui-preview/landing-vue/` (characters.png, desktop-top.png,
desktop.png, reference.png, mobile.png, small.png, small-text-200.png).
Build y capturas son artefactos locales ignorados; pueden desaparecer al limpiar.

Helper local para build sin interferir con .nuxt del servidor dev:
`node apps/mobile/build/build-platform-landing.mjs` desde la raíz. Usa un buildDir
separado y genera `apps/platform/.output`. Si falta, leer DESARROLLO.md y preparar
un build aislado equivalente antes de intervenir el dev del usuario.

QA desde la raíz, con dependencias locales ya existentes (no son dependencias del producto):

```powershell
$env:PLAYWRIGHT_MODULE='C:/Users/Administrator/Documents/projects/entreHuellas-landing-page/apps/landing-page/node_modules/@playwright/test/index.mjs'
$env:CHROME_PATH='C:/Program Files/Google/Chrome/Application/chrome.exe'
node apps/platform/scripts/check-landing-browser.mjs
```

Comprobar que esas rutas existan. El script inicia/cierra su propio fixture;
no cerrar procesos del usuario. `git diff --check` pasó. No se corrieron pruebas
Flutter/SQL porque estos cambios son de presentación web.

## Próximo paso

Continuar ajustando el diseño de las siguientes secciones según indique el
usuario en el nuevo chat. No hay otro rediseño pendiente preautorizado ni
motivo para regenerar recursos, refactorizar toda la CSS o implementar login/admin.
Conservar esta base aprobada; actualizar ficha y ESTADO tras cada incremento.
