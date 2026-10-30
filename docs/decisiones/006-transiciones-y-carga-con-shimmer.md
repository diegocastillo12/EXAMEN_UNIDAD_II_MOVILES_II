# ADR-006: transiciones de etapa y carga con shimmer

Refinamiento20/10/2026, confirmación de salida: por petición del usuario,
confirmActionDialog sin origen usa PopupDialogTransition (fundido y escala
uniforme .96→1,160ms al abrir/cerrar). Superficie y contenido aparecen juntos,
sin cuadro vacío, medición post-frame ni aparición tardía del texto. Conserva
SafeArea/insets, ancho máximo420, radio28, scroll, semántica y acciones.
Movimiento reducido inmediato. Solo las confirmaciones con origen explícito
conservan OriginDialogTransition/320ms; la navegación de páginas no cambia.


Fecha: 8 de octubre de 2026. Estado: aceptada por instrucción del usuario.

## Contexto

Refinamiento20/10/2026, corrección solicitada del reveal duplicado en selectores:
AppSelectField usa la apertura nativa del panel seguida del stagger compartido
cuando finaliza la animación de ruta. No añade AuthStageTransition/CoverReveal
interior, que reproducía otra apertura y pintaba el fondo de página en el panel.
Cabecera fuera del efecto; movimiento reducido inmediato. Alcance compartido a
sus consumidores, sin cambios de selección, dominio o persistencia.

El usuario solicita una UX consistente con cover reveal seguido de stagger reveal en los lugares apropiados, incluido el resultado Contraseña actualizada. Rechaza etiquetas de carga con puntos suspensivos, como Enviando…, y pide shimmer como indicador de trabajo en curso. La marca debe permanecer estable durante las etapas de acceso.

## Decisión

- Para entrada de pantallas y cambios discretos de etapa, reutilizar AuthStageTransition/CoverReveal y StaggerReveal: cortina plana de 320 ms, seguida del timeline compartido. Cabeceras persistentes quedan fuera de la animación. No añadir expansión desde el botón a estas etapas.
- Aplicar ahora a login, registro/confirmación, recuperación/código/reset/resultado/error y al contenido de Inicio. El onboarding conserva PageView, su interacción continua y el reveal textual ya acordado; no superponer una cortina por cada frame del gesto. En futuras pantallas, elegir la unidad de entrada/etapa que ayude a entender el cambio.
- No reiniciar efectos al escribir, abrir teclado, cambiar visibilidad de contraseña, actualizar contador, presentar error de campo o reenviar en la misma etapa. Los errores contextuales siguen visibles junto al control según ADR-005.
- Nunca usar puntos suspensivos ASCII o Unicode como indicador de carga de botones. Mantener la etiqueta de la acción y mostrar LoadingShimmer durante la operación real. En botones, reemplazar también los spinners por el componente compartido. No mostrar shimmer por estar simplemente deshabilitado ni por la espera de reenvío.
- Mantener dimensiones, radios, contraste y bloqueo de dobles envíos. El lector de pantalla recibe una etiqueta de progreso breve sin puntos suspensivos, estado deshabilitado y liveRegion; el brillo no repite anuncios por frame.
- Cada nueva carga reinicia el barrido desde el borde inicial; conservar su fase durante reconstrucciones de la misma operación. Atenuar el contenido del botón a opacidad 0.72 mientras carga y pintar el brillo encima, manteniendo la etiqueta legible. Al finalizar se recupera su apariencia normal.
- Respetar movimiento reducido: etapas inmediatas y shimmer estático. Detener/liberar animaciones cuando finaliza el trabajo o se desmonta la UI.

## Alternativas

Texto animado con puntos suspensivos y spinners de botón se descartan por instrucción explícita. Un cover por edición/contador o durante todos los gestos del onboarding se descarta por interrumpir interacción y repetir cambios que no constituyen nuevas etapas. Paquetes externos de shimmer no son necesarios para un barrido simple con CustomPainter.

## Consecuencias y transición

LoadingShimmer pertenece a core/presentation/widgets. Los ViewModels siguen controlando el trabajo; la decoración no simula finalización ni modifica reglas de Auth. Verificación y reenvío de OTP se distinguen en estado para iluminar el control correcto. Se añade comprobación automática de etiquetas de UI sin puntos suspensivos. Se actualizan AGENTS, reglas, arquitectura, diseño y estado en el mismo incremento.

Validación: análisis/formato, prueba de política, pruebas de bloqueo/semántica/movimiento reducido/desmontaje, flujos de Auth, secuencia de resultado y renders. Percepción/rendimiento en Android y operaciones remotas se verifican por separado; esta decisión no afirma que ya se hayan probado.

### Indicador de navegación, 8 de octubre de 2026

Por instrucción explícita del usuario, la cápsula de Inicio utiliza un único indicador carbón que se desplaza entre destinos en 320 ms (easeInOutCubic). Conserva posición interpolada al cambiar nuevamente de destino; los iconos ajustan contraste al paso del indicador. Movimiento reducido salta al destino. Es un efecto local de orientación en navegación: el contenido sigue utilizando cover → stagger, sin repetir su timeline por cada frame del indicador. La acción separada utiliza nueve puntos 3 × 3 blancos sobre círculo sólido #24282A; abre el panel Reportar existente y no usa glass. No cambian responsabilidades, operaciones ni reglas de carga.

### Apertura de Perfil desde avatar, 8 de octubre de 2026

Nueva instrucción explícita del usuario: Perfil deja de ser sección inferior y se abre desde avatar de cabecera, conservando logo/campana. Reutilizar OriginPageTransition desde el rectángulo del avatar, 320 ms de apertura y 260 ms de cierre; luego inicia stagger del contenido de Perfil. Es la misma entrada aprobada para registro/recuperación, extendida a Perfil; no sustituye cover/stagger entre las tres secciones del Home. La ruta es protegida y regresa mediante pop para conservar la sección/scroll anterior. Movimiento reducido evita expansión/reveal.

ADR-011 registra el rechazo posterior del usuario a textos visibles de carga e indicadores circulares. Extiende el uso del brillo compartido a skeleton de contenido inicial y permite progreso fino superpuesto durante recarga explícita con datos anteriores de la misma identidad. No cambia las reglas de etiquetas fijas, botones, cover/stagger, errores o movimiento reducido de este documento.

### Sustitución del skeleton, 9 de octubre de 2026

Por instrucción explícita del usuario, ADR-011 distingue entrada de pantalla de resolución de consulta: skeleton -> datos/vacío/error sustituye el contenido directamente, sin repetir cover/stagger. Una respuesta durante el stagger completa ese timeline; las cargas con skeleton omiten cover y stagger desde el primer frame. Navegación real mantiene la entrada acordada; edición, refresh y reintentos no generan nuevas etapas visuales.

### Excepción explícita para carga inicial con skeleton

Por nuevo ajuste del usuario, una carga inicial de contenido omite cover/stagger sobre el skeleton: la cortina anterior podía volver a ocultar un placeholder ya visible. La excepción aplica a ficha/editor con consulta, Perfil cuando espera datos y sección Mis mascotas. Conserva shimmer y transición de ruta; al terminar las consultas se sustituye directamente por contenido. Los demás flujos de acceso/etapas y navegación de contenido sin skeleton mantienen las entradas acordadas. Detalles y coordinación de ficha/fotos en ADR-011.

### Registrar mascota desde su botón, 9 de octubre de 2026

Por instrucción explícita del usuario, Registrar mascota reutiliza OriginPageTransition del flujo Crear cuenta: apertura de 320 ms desde los límites reales del botón en coordenadas del Navigator, y contracción al volver de 260 ms. Router compone la página; el botón aporta únicamente su rectángulo como dato de navegación. Movimiento reducido omite la transición. No añadir cover/stagger sobre el skeleton ni repetir entradas al recibir datos; conserva la excepción de ADR-011. Guardado sigue conduciendo a la ficha confirmada mediante el flujo existente.

### Deslizamiento continuo para solicitar eliminación

Por instrucción explícita del usuario, la tarjeta de mascota sigue el arrastre hacia la izquierda sin panel de acciones abierto. La corrección posterior limita el desplazamiento al70% del ancho. Fondo evoluciona de superficie neutra a rojo contextual según recorrido, con texto/iconos adaptados al contraste. Umbral de intención: 40% del ancho, limitado a96–180 para superficies pequeñas/grandes. Al soltar, vuelve a cero en220ms easeOutCubic y se espera el frame restaurado antes de abrir el modal. Recorrido corto o cancelación vuelve sin confirmación. No sumar cover/stagger por frame del gesto.

Movimiento reducido conserva seguimiento directo del dedo y omite animación automática de retorno. Por corrección posterior explícita, solo el swipe izquierdo abre confirmación: se retiran pulsación larga y acción semántica alternativa de eliminación. Bloquear interacción durante retorno, modal y operación real; desmontaje/cancelación del puntero no debe abrir confirmaciones tardías. Confirmar en el modal sigue siendo necesario antes de invocar eliminación; dominio/backend no cambian.

Corrección posterior autorizada: el rojo del swipe también tiñe todo el contenido, incluida fotografía, además del fondo. Es un filtro visual dependiente del recorrido, con estructura estable y retorno a intensidad0; no cambia bytes ni resultados de negocio. Sustituye la apariencia anterior que adaptaba texto/iconos al contraste sin aplicar tinte a fotos.

### Transformación desde el origen en la confirmación, 9 de octubre de 2026

Por nueva instrucción explícita, la confirmación de eliminación omite cover/stagger y usa OriginDialogTransition desde el rectángulo de la tarjeta ya restaurada. En320ms cambia posición, tamaño, radio y superficie; una copia visual del contenido original se desvanece durante el primer45% y el contenido del modal aparece a partir del65%, con interacción al terminar. La geometría de destino se mide una vez que el layout está disponible; no reordenar elementos durante la animación. Cierre recorre la misma transición. Movimiento reducido presenta el destino inmediatamente.

OriginPageTransition comparte la aparición tardía del contenido desde65% para que primero se transforme la superficie en las aperturas existentes. Conserva origen, navegación y duración de rutas. La excepción sin stagger se aplica al modal de eliminación; no elimina las entradas de otros flujos aprobados.

Corrección visual posterior: swipe intensifica fondo a #C12F3D con easeOutCubic y aumenta el filtro común de22% a32%. Texto/iconos interpolan color original a rojo claro #FFE3E6 desde el inicio del recorrido con easeOutCubic compartido con fondo y filtro, sustituyendo selección binaria negro/blanco según luminancia. Retorno restaura todos los colores, sin cambiar navegación ni operaciones.

Corrección de cierre: Material del modal usa animationDuration cero para no añadir interpolación implícita sobre el morph. Durante contracción no se vuelve a pintar la copia del contenido de origen; superficie se desvanece en el último18% de la animación para revelar la tarjeta real inmóvil. Apertura conserva copia/transición aprobada. Ajuste posterior: texto, iconos y filtro comienzan al iniciar el swipe y comparten easeOutCubic con el fondo, sin intervalo abrupto.

### Abrir detalles desde una mascota existente, 9 de octubre de 2026

Por instrucción explícita del usuario, la ficha abierta desde Mis mascotas amplía el uso aprobado de OriginPageTransition: la tarjeta entrega sus límites reales relativos al Navigator; el router expande en320ms y contrae al volver en260ms. Movimiento reducido omite la animación. Reutiliza el mismo componente que Registrar mascota y conserva la continuidad de carga de ADR-011. Sin origen de tarjeta, guardado confirmado y acceso directo mantienen la navegación anterior. Sin cambios de dominio/datos ni autorización.

### Morph del botón de registro, 9 de octubre de 2026

Por instrucción explícita del usuario, Registrar mascota entrega OriginPageSource con rectángulo, color carbón, radio real y copia visual del icono/etiqueta. OriginPageTransition interpola superficie, posición y radio desde el botón completo o círculo + hasta la pantalla blanca; el contenido original se desvanece durante el primer45% y el destino aparece desde65%. Al cerrar recorre la misma transformación y recupera la identidad del botón. Copia sin interacción/semántica; destino bloqueado durante transición. Conserva320/260ms y movimiento reducido inmediato. Esta actualización sustituye el envío exclusivo del Rect para registro; otros destinos mantienen su comportamiento.
