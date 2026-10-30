# Navegación de usuario y recuperación web

Contrato vigente21/10, ADR-128: combinar fullscreen/GSAP Sader con identidad
móvil al abrir y cerrar. La superficie negra y su radio se transforman; icono
y nueve puntos mantienen tamaño, centrados dentro del contorno, con fase fuente
hasta45% invertida al regresar. Fade/blur de Sader solo al cuerpo de destino.
Control original oculto temporalmente para evitar duplicado y restaurado junto
a la limpieza de identidad, estilos y referencias. Se mantienen0.7s/CustomEase,
ruta anterior detrás, marca/barra, acceso/guards y reducido. Perfil/Alertas y
Flutter intactos. [ADR-128](../decisiones/128-identidad-mobile-en-origen-web-fullscreen.md).
Los apuntes anteriores que contradigan esa fase se conservan como historial.

21/10, instrucción posterior ADR-125: sustituido el motor de origen de navegación
por GSAP Flip de PrettyModal/Sader sobre el componente real. Sin copias de Inicio,
hold/previous ni superficie paralela; formulario oculto hasta completar0.7s y
contracción antes de desmontar. Las descripciones de aproximaciones anteriores
que siguen son historial. [Contrato vigente y evidencia](transiciones-web.md).

21/10, sustitución del mecanismo: Reportar ya no hace fade/escala.98
en su posición final; cuerpo y superficie comparten FLIP desde el control real,
como Sader. Primer fotograma y crecimiento comprobados en el dev5173 con backend
fixture desde nueve puntos y acceso negro de Inicio,1852/1440/390/320. Limpieza
de copias antiguas/HMR incluida. [Contrato y evidencia](transiciones-web.md).

21/10, corrección posterior por captura del usuario: Reportar recorta contenido
y expansión juntos, siguiendo el mecanismo revisado de Sader; espera montaje
real y limpia la copia anterior por referencia. Host fuera del shell al quedar
en reposo. QA1852/1440/390/320 con reaperturas reales y comprobación explícita
de accesos de Inicio ausentes del reporte. [Detalle](transiciones-web.md).

21/10, continuidad del botón de nueve puntos: copia decorativa preparada antes
de navegar a Reportar, conservada durante el montaje del destino y transferida
a la expansión sin fotogramas vacíos. Tiempos/fases y retorno conservados;
limpieza ante cancelación/cambio de cuenta y movimiento reducido comprobados.
[Detalle y evidencia local](transiciones-web.md#continuidad-al-abrir-reportar-21102026).

21/10, estabilidad: html reserva el canal de scroll con scrollbar-gutter:stable
en main.css. Evita que la barra centrada salte horizontalmente al cambiar la
altura del contenido o bloquear el scroll desde Perfil/Alertas. Sin cambios de
dominio, datos, permisos ni animación de selección. QA reproducible en
scripts/check-navigation-stability-browser.mjs con scrollbar clásica visible:
salto previo7,5px; después0px a1440/390/320 durante navegación, lecturas demoradas,
contenido largo y apertura/cierre de Perfil.71 pruebas/typecheck/build aprobados;
Safari/Firefox/dispositivos físicos pendientes. Sin despliegue.

21/10, cabecera: Inicio/Explorar/Mis mascotas/Reportar comparten avatar/perfil,
campana con [bandeja de alertas](notificaciones-web.md) e icono de logout.
Composición por slots en páginas, marca estable y glass compartido con móvil;
cuenta/alertas abren paneles nativos accesibles sin cambiar ruta ni descartar
formularios. Escape/cierre devuelve foco y libera scroll. Cuenta ya no aparece
como desplegable al final de Inicio.

21/10: [Inicio](inicio.md) adapta el diseño móvil con título de dos líneas,
accesos negros a Reportar/Explorar/Mis mascotas, ilustración y tarjetas glass.
Reportar usa NavigationLink origin y conserva retorno a Inicio; los otros
accesos reutilizan las rutas y política existentes. Sin rutas vacías nuevas.

21/10: retiradas las frases decorativas sobre títulos de Inicio, Explorar,
Mis mascotas, Reportar y gestión/moderación por petición del usuario.
AccountScreen ya no muestra el pie de Términos/Privacidad; el contenido conserva
espacio inferior para desplazarse por encima de la barra flotante. Etiquetas de
tipo/estado del caso, persistencia, permisos y reintentos conservados.

## Carga progresiva de Reportar —21/10/2026

[ADR-123](../decisiones/123-carga-progresiva-reportar-web.md): después de comprobar
acceso, se muestra el formulario e inicia mascotas, búsquedas y borrador local
en paralelo. El mapa monta independientemente mediante LocationMap. Solo la
restauración local deshabilita temporalmente los campos para no sobrescribir
edición; las listas remotas no bloquean los inputs de texto/fecha/tipo.

Cada selector muestra FieldSkeleton hasta su lectura confirmada; fallo tiene
toast/reintento específico, sin presentarse como lista vacía. Los resultados se
aplican por separado. Publicar espera únicamente la lista correspondiente al tipo
de reporte; guardar borrador conserva referencias/versiones/fotos restauradas
si la lista aún no llegó. Refresh conserva contenido; respuestas tardías no
reaparecen tras desmontar ni afectan una publicación ya confirmada.

VM/casos de uso/repositorios y autorización existentes, sin persistencia ni
permisos nuevos.64 pruebas/typecheck/build y regresiones Chrome correctos;
scripts/check-report-loading-browser.mjs retiene las tres dependencias y prueba
campos usables, entrega independiente, retry aislado y borrador íntegro; capturas
en apps/mobile/build/ui-preview/web-report-loading. QA recovery confirma los
cuatro tipos/fotos/reintento ambiguo. Pendiente latencia real/Safari/Firefox/
dispositivos físicos; sin despliegue ni cierre de historias.

21/10, [ADR-122](../decisiones/122-controles-web-reutilizables-desde-sader.md):
filtros, metadatos de mascotas y formularios de reportes consumen los
[controles compartidos de Sader](controles-web.md). Línea superior durante
navegación; modelos, persistencia, autorización y reintentos conservados.

Mejora20/10, [ADR-121](../decisiones/121-navegacion-web-sin-esperas-repetidas.md):
los montajes dejan de invalidar su propia sesión; reutilización estricta de15s
después de la política global, sin skeleton repetido al navegar. Código preparado
en la barra y por intención en enlaces. Gestión se consulta solo en Inicio;
mascotas/búsquedas del reporte se leen en paralelo. Cada operación conserva su
autorización real. Expirar, cambiar de cuenta o fallar siguen validación/reintento;
sin datos privados preparados para destinos no visitados. SSR/hidratación conservan
estado inicial coincidente y la primera carga real mantiene skeleton.
QA reproducible: scripts/check-navigation-performance-browser.mjs; resultados
antes/después en apps/mobile/build/ui-preview/web-navigation-performance.

Implementación local del 20/10/2026. [ADR-118](../decisiones/118-navegacion-web-y-recorridos-de-recuperacion.md).

## Qué hace y recorrido

Tras login y bienvenida por cuenta, Inicio, Explorar, Mis mascotas y Reportar
comparten barra inferior flotante basada en LiquidNavigation móvil. Cápsula
glass, selección azul, círculo de nueve puntos, nombres accesibles,
foco por teclado y movimiento reducido. Por corrección explícita, solo iconos
en todos los anchos; nombres en semántica. Por petición explícita del20/10,
sin tooltip al mantener el puntero sobre los cuatro controles de la barra web.
Cabecera/marca estable.
Corrección posterior20/10: selección sin elevación al hover/foco/presión;
conserva brillo y foco accesible. Se retira translateY(-2px) del acento.
Por ajuste posterior del20/10, el conjunto mide como máximo304px, con opciones
aproximadamente71×52px. Por corrección posterior, sin impulso horizontal al
hover; al arrastrar, el acento acompaña hasta8px y regresa en480ms al soltar. Deslizar
no navega ni cambia la selección. Se respeta movimiento reducido y se limpian
gestos/animaciones al cancelar, cambiar ruta o desmontar.
El indicador se desplaza con la barra persistente y Reportar se expande desde el
botón. [Transiciones reutilizables](transiciones-web.md), ADR-119, sustituyen
las etiquetas de escritorio y el cambio estático de selección de ADR-118.
El usuario puede desplazar todos los controles por encima de la barra.
Reportar incluye una X glass flotante para cerrar y regresar a Inicio, Explorar
o Mis mascotas según el origen; entrada directa vuelve a Inicio. Reutiliza
GlassNavigationButton y la transición de retorno existente. Si hay cambios,
mantiene la confirmación de salida y bloquea el cierre durante operaciones.

- Explorar: consulta real, filtros de tipo/especie/estado y Ver más con cursor.
  Tarjetas con foto autorizada, rasgos, fecha y zona aproximada. Error no equivale
  a vacío; refresh conserva contenido con shimmer y permite reintento.
- Mis mascotas: consulta del propietario, registrar/editar nombre, especie,
  detalle de otra especie, tamaño, sexo opcional, edad en meses y rasgos.
  Añadir foto usa el verificador existente; reintentar conserva ID y bytes.
- Reportar: pérdida de mascota propia con sus fotos verificadas; posible pérdida
  con 1–3 fotos; avistamiento o custodia vinculados a búsqueda con fotos opcionales.
  Fecha/hora local, mapa compartido y referencia privada. Confirmación solo al
  recibir publicación activa del servidor. Permite Guardar borrador sin publicar.

## Reglas, persistencia y permisos

Campos de mascota según ADR-016: nombre 1–80, especie/tamaño/edad/rasgos
obligatorios; edad 0–600 meses, rasgos hasta 200 con contador interior. Macho
inicial en registro, sexo opcional. No se inventan campos antiguos incompletos.

Coordenadas exactas y referencia se envían solo al caso; Explorar recibe la
proyección pública aproximada existente. No se publica teléfono/perfil/contacto
por añadir mascota o reporte. Las fotos del navegador aceptan JPEG/PNG/WebP hasta
8 MB, se recodifican sin metadatos y pasan por pet-photo-process. Nunca se
interpreta una foto local como verificada antes de la respuesta del servidor.

RPC existentes: explore_cases, create_pet_v2/update_pet_v2, list_open_recovery_searches,
publish_lost_case, prepare_recovery_report/publish_recovery_report. Lectura pets
filtrada por propietario con RLS y columnas explícitas. APIs propias revalidan
sesión/onboarding, actor esperado y origen. Cookies/token permanecen privados.
Proxy de imágenes comprueba sesión y lectura permitida antes del Storage con JWT.

El borrador se guarda explícitamente en IndexedDB por actor, con UUID/fotos,
restaurable hasta siete días; no se comparte entre cuentas desde la UI ni se
sincroniza entre dispositivos. No guarda contraseñas/tokens. Publicar confirmado
intenta borrarlo; un fallo local no invalida la confirmación remota. Reintento
de respuesta incierta conserva exactamente el envío y bloquea edición.

## Errores y reintentos

TopToast compartido; invalid/shake en campos, sin mensajes inferiores. Skeleton
inicial, shimmer en trabajo real/refresh, sin indicadores circulares ni cambios
de etiqueta con puntos suspensivos. Formularios se conservan ante fallo. Estado
de cada ViewModel se libera al desmontar y al cambiar identidad. Salida con datos
pendientes se confirma, sin bloquear la lectura normal de las otras secciones.

## Activación y límites

Requiere configuración Auth/sesión, SQL/RLS y Edge fotográfica ya utilizadas por
móvil, además de NUXT_PUBLIC_MAP_TILE_URL. Sin migraciones nuevas. No se ha aplicado
SQL remoto ni publicado la web. La navegación y su UI no conceden permisos.

Alcance inicial: lista Explorar; hasta 100 mascotas activas propias; alta/edición
y adición de fotos. No incluye mapa de resultados, ficha autenticada completa,
retirada/ordenación de fotos, mascotas archivadas/baja, seguimiento ni todos los
recorridos móviles. No se cierran historias ni issues por este incremento.

## Validación

Pruebas de dominio/arquitectura y servidor con fixture; QA Chrome de las cuatro
entradas, filtros, mascota alta/edición/foto, cuatro reportes, borrador y reintento.
Renders 1440/390/320 y texto 200%, sin overflow/CSP/hidratación. Evidencia en
apps/mobile/build/ui-preview/web-recovery y resultados finales en ESTADO.
Pendiente integración Supabase real con dos cuentas y revisión de teclado/fotos
y área segura en navegadores físicos; no afirmar validación remota de RLS.
