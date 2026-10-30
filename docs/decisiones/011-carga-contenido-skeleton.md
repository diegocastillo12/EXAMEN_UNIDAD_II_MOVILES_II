# ADR-011: carga de contenido mediante skeleton

Fecha: 9 de octubre de 2026. Estado: aceptada por instrucción explícita del usuario.

El usuario rechaza texto visible de carga, etiquetas con puntos suspensivos y spinner circular central. Para la carga inicial de contenido se muestran placeholders neutros con geometría cercana a tarjetas/ficha/formulario y brillo compartido de LoadingShimmer. Son formas sin nombres/datos ficticios ni acciones. Mantener cabecera y navegación; no añadir demoras artificiales. Skeleton estático con movimiento reducido y tamaño de campos adaptable al texto. La descripción de carga queda solo en semántica accesible.

En recarga explícita del mismo recurso/cuenta se conserva el contenido y una línea indeterminada fina superpuesta, sin desplazarlo. Movimiento reducido pausa esa animación. Un cambio de identidad o dependencia vuelve a skeleton y oculta datos anteriores; una consulta fallida muestra error y reintento, nunca un vacío supuesto. Vacío únicamente tras respuesta exitosa. No guardar nuevos datos en caché global por esta decisión: se usa el valor anterior del estado de presentación solo durante refresh explícito.

Aplicación inicial: listado/detalle/editor de mascotas y consulta de Perfil. PetSkeleton describe los layouts de mascotas; SkeletonFormFields compartido da geometría a formularios de mascotas y Perfil. PetRefreshProgress solo se activa durante trabajo real con datos disponibles. Mantener ADR-006 para cover/stagger, movimiento reducido y LoadingShimmer de botones con etiqueta fija; errores según ADR-005/009 y éxitos confirmados según ADR-007.

La comprobación de arquitectura rechaza textos directos de carga (incluido el patrón previo de ternario simple) e indicadores circulares; labels accesibles quedan permitidos. Verificar espera real, error/reintento, vacío confirmado, contenido retenido y cambio de cuenta, además de renders normal/pequeño con texto ampliado. No sustituye validación Android/Supabase ni modifica dominio o contratos de persistencia.

## Resolución de carga sin segunda entrada, 9 de octubre de 2026

Por corrección explícita del usuario, la sustitución del skeleton por datos reales, vacío confirmado o error no es una nueva etapa visual. Se conserva la entrada inicial de pantalla/sección, pero al resolver la consulta el contenido queda visible e interactivo sin nuevo cover ni stagger. Si la consulta responde durante la entrada, se completa el stagger inmediatamente; en cargas con skeleton se omiten cover y stagger desde el primer frame, según el ajuste de continuidad posterior. No imponer demoras para completar efectos o exhibir placeholders.

PetScreenShell conserva una única etapa de entrada; ContentReveal termina su timeline al resolver un skeleton. Perfil utiliza el mismo comportamiento después de la expansión de ruta. Mis mascotas evita aplicar el stagger heredado al resultado de la consulta. Reintentos/refresh/cambios de cuenta actualizan contenido sin nuevas entradas y siguen ocultando datos ajenos. Una navegación real inicia su propia entrada; contenido disponible sin skeleton conserva la animación inicial. Se mantienen ADR-006 para navegación/movimiento reducido y ADR-005 para errores.

## Continuidad del skeleton y consultas coordinadas

Ajuste posterior autorizado por el usuario el 9 de octubre: el skeleton no debe aparecer, quedar tapado por la cortina y reaparecer. En pantallas de consulta, se omiten cover y stagger cuando hay skeleton desde el montaje; solo queda el shimmer continuo y la transición de ruta que corresponda. Mis mascotas omite cover/stagger de sección para evitar que el Home cubra sus placeholders. Otros flujos de acceso y contenido disponible desde el primer frame conservan las entradas existentes. Esta excepción explícita actualiza ADR-006.

Ficha y editor de mascotas consultan metadatos y fotos en paralelo desde sus ViewModels, mediante sus casos de uso existentes. El estado de pantalla permanece en carga hasta terminar ambas consultas. La galería reutiliza la inicialización ya realizada en el mismo ciclo de cuenta/mascota; no inicia otra carga al montarse. PetPhotosViewModel conserva error contextual y reintento explícito; el fallo de fotos no se convierte en error de metadatos ni en ausencia confirmada. Cambio de identidad reinicia la inicialización y mantiene las guardas previas. Sin caché global, timers de espera o datos simulados.
