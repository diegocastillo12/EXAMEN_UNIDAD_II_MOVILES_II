# ADR-074: onboarding web con referencia de sader-panel e ilustraciones móviles

Fecha:19/10/2026. Estado: implementada localmente; revisión del usuario pendiente.
Autoridad: el usuario pide reproducir prácticamente el onboarding de su proyecto
sader-panel, conservando imágenes/contenido del móvil de Entre Huellas.
Incremento visual de HU-01/RF-01,34 en web; sin nueva HU/issue ni cierre.
Complementa ADR-006/063/073 y sustituye la presentación inicial de /bienvenida.

## Causa y referencia

El paso anterior usaba la clase global .reveal. Su pseudo-elemento dibuja una
cobertura #FFFBEF y vuelve a ejecutarse al recrear el bloque por número de paso.
Ese efecto no es el stagger de sader-panel y produce el rectángulo reportado.

Se consulta la referencia local platform-sader-kormind/apps/sader-panel:
src/app/onboarding/page.tsx, features/onboarding/components/welcome-step.tsx,
appearance-step.tsx, hooks/use-stagger-reveal.tsx, components/ui/button.tsx,
components/shared/press-effect.tsx y app/globals.css/layout.tsx.
Rigen los valores del código, no sus comentarios de direcciones contradictorios.

## Decisión visual

Solo /bienvenida adopta columna max448px, texto alineado a la izquierda,
gap32px, posición inferior con margen60px en móvil y centrado vertical desde640px.
Permitir scroll cuando el contenido/texto ampliado supera el viewport; no copiar
overflow-hidden que recortaría acciones en superficies pequeñas.

Inter variable local (misma familia declarada en layout de sader-panel),
título48px/600/línea1/tracking−.025em, descripción18px/500/línea1.375,
separación efectiva8px entre título y descripción.
Botón principal carbón, altura mínima48px, texto16px/500, flecha20px,
radio calc(.625rem + 8px),18px a tamaño base. Excepción local explícita a la
cápsula y Arial generales, sin cambiar login, legales, landing u otros botones.

Se mantienen tres pasos, los títulos/descripciones/saltos de línea y los PNG
originales del móvil: dog_waving.png, dog_with_map.png y dog_and_cat.png.
Copias byte a byte en public/images/onboarding, sin recortar/recrear/recomprimir;
reemplazan las ilustraciones de landing usadas provisionalmente.
Corrección posterior del usuario19/10: solo Continuar/Comenzar, sin Anterior ni
puntos visibles. Por aclaración posterior, logo oficial52px y nombre entre huellas
van en cabecera al inicio de la página, alineados al borde con márgenes de landing,
fuera de la columna centrada y del stagger, también en responsive.
La etapa conserva anuncio accesible no visual.
Ampliación posterior solicitada: ilustración a todo el ancho de columna,
hasta448px base escritorio y ancho disponible móvil, sin el máximo anterior288px.
PNG originales/proporción conservados.
Sin configuración de apariencia, roles ni textos propios de Sader.
Se retiran cabecera/footer de cuenta y etiqueta extra de bienvenida en esta ruta.

## Transiciones y ciclo de vida

OnboardingFlow recibe estado y acciones del ViewModel, sin SDK/persistencia.
Usa el composable Vue compartido useStaggerReveal portado previamente:
cuatro grupos (ilustración/título/descripción/acciones),550ms/gap90ms, blur18px/offset56px. Entrada desde abajo en orden superior;
salida hacia abajo con orden invertido, como WelcomeStep. Doble rAF y CSSOM
existentes, sin estilos SSR arbitrarios ni nueva dependencia de React.
El tiempo de salida es820ms. Antes se reproduce el ciclo press400ms equivalente
a afterPress (200ms de bajada y200ms de subida). Se espera la salida antes de
cambiar contenido y se bloquean clics repetidos durante salida/entrada.
No se usa .reveal ni una superficie que tape texto/imagen en este onboarding.

El guardado final conserva contenido y shimmer visible durante la RPC real.
Solo tras confirmar finalización sale el paso y se navega a inicio; un error
mantiene el tercer paso, toast y reintento sin volver a reproducir entrada.
Orbe strong compartido permanece montado entre pasos. Preferencia de movimiento
reducido elimina efectos y esperas, incluso si cambia durante la transición.
Al desmontar se cancelan timers, listeners y callbacks pendientes.

La revisión con texto200% detecta que el enlace compartido Saltar al contenido
se ocultaba con top−100px, insuficiente para su propia altura ampliada. Se oculta
mediante translateY de su altura completa y se revela al recibir foco, sin perder
el enlace de teclado ni alterar su posición visible normal.

## Persistencia, alcance y validación

Se conservan AccountViewModel, tres etapas sin Omitir, complete_onboarding,
sesión, permisos, rutas y datos compartidos con móvil. Sin SQL, cambios Flutter,
configuración de Auth, cuentas de prueba reales o despliegue.
Inter se sirve local con licencia OFL; sin consultas a Google al visitar la ruta.

Typecheck/build, suite existente y Chrome con fixture verifican tiempos CSS
reales, orden/salida/entrada, avance/retorno/clics repetidos, imágenes idénticas,
guardado visible/error/reintento, movimiento reducido, cancelación al salir,
foco y tamaños1440/390/320×350/320 con texto200%. Sin overflow/CSP/hidratación.
La regresión de acceso mantiene roles, OAuth simulado y ciclo de sesión.
Resultados/capturas en ESTADO y ficha acceso-web. Evidencia local no certifica
proveedores reales; la aprobación visual final corresponde al usuario.

