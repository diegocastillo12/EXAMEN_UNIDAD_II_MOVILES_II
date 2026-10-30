# Entre Huellas: instrucciones del proyecto

Coincidencias25/10, ADR-137/138: HU-25/#71 y HU-26/#72 pertenecen al MVP.
Hallazgos independientes aprobados expresamente; conservar avisos vinculados
y clasificación histórica. Modelo CPU local en Nuxt existente, sin nuevos
workers/servicios ni inferencia externa; pesos/versiones fijados y revisión
humana. No afirmar precisión por un smoke ni cerrar historias sin activación,
evaluación y aceptación. Véase docs/funcionalidades/coincidencias-de-casos.md.

Patrón UI/UX aprobado21/10: antes de reutilizar la expansión desde origen,
consultar docs/patrones-ui-ux/expansion-desde-origen.md. Conservar el contrato
ADR-128 y usar componentes/coordinador existentes; validar cada integración.
Aprobación visual del usuario en Reportar web, sin migración global implícita.

Origen web21/10, combinación explícita ADR-128: conservar fullscreen/GSAP Sader
pero sumar identidad móvil al abrir/cerrar: superficie negra/radio del control
se transforman, nueve puntos mantienen tamaño y se centran dentro, fase fuente
hasta45% invertida al volver. Fade/blur de Sader solo al cuerpo, no a superficie
ni icono; restaurar control y limpiar identidad en cancelación/fin/cambio de
cuenta. Véase docs/decisiones/128-identidad-mobile-en-origen-web-fullscreen.md.

Origen web21/10, precisión ADR-127: expansión al viewport completo, con fases
originales de PrettyModal/Sader (Flip0.7s más entrada opacity0/blur10→1/0 en500ms,
cubic-bezier(0.56,0.27,0,1)). Sustituye apertura sin fade y destino limitado al
main de ADR-126; conservar sección anterior detrás, contenido dentro del morph,
marca/barra estables, reducido y limpieza. Véase docs/decisiones/127-origen-fullscreen-y-fases-prettymodal-sader.md.

Origen web21/10, precisión posterior ADR-126: conservar la sección anterior
visible detrás durante apertura; el contenido nuevo se ve desde el inicio
dentro de la superficie y escala con ella desde el botón. Sin reveal al final.
Sustituye la fase de cuerpo oculto de ADR-125; mantener0.7s/CustomEase de Sader,
sin clones de páginas, con acceso global, reducido y limpieza de identidad.
Perfil/Alertas y Flutter conservados. Véase docs/decisiones/126-contenido-dentro-de-expansion-y-ruta-anterior-visible.md.

Animaciones21/10, ADR-124, por instrucción explícita: las animaciones de un mismo
recorrido en móvil y web deben coincidir en efecto, origen/destino, sentido,
duración, curva, fases de contenido y retorno. No sustituir expansión por panel
instantáneo/fade ni cambiar tiempos por plataforma. La geometría final puede
adaptarse al viewport sin cambiar el contrato de movimiento. Respetar movimiento
reducido en ambos, conservar foco/limpieza y comprobar fotogramas de apertura y
cierre con movimiento normal. Cualquier divergencia requiere instrucción explícita
del usuario y decisión documentada. Perfil/Alertas usan origen real320/260ms,
easeInOutCubic, fuente hasta45% y contenido desde65%. Véase
docs/decisiones/124-paridad-animaciones-mobile-web.md. No afirmar auditoría global
de animaciones por validar solo estos recorridos.

Hero landing20/10, ADR-120: por instrucción explícita, #hero-title recupera Arial,
peso500, #171918, line-height1.02, tracking−0.055em, tamaño adaptable42–108px
(móvil32–48px) y mascotas laterales originales. Excepción local a ADR-111;
los demás títulos conservan Poppins400/32/gris. No reducirlo por cambios de SEO.

Celular20/10, ADR-116: profiles.contact_phone es privado/opcional; solo se sugiere al autor por read_case_contact. Guardar perfil no publica contacto ni modifica los ya compartidos. Mantener consentimiento por caso/foto y plan033 después de032.

Compartir ficha20/10, ADR-115: botón junto a Guardar; panel blanco opaco, sin glass ni X por instrucción explícita. Copiar enlace azul/icono blanco, WhatsApp y Facebook con etiquetas; Descargar/Denunciar son dos círculos grises contiguos sin texto visible, con tooltip/semántica. Compartir/descargar usa solo el enlace QR público activo y autorizado (plan032), sin dar permisos de autor a otros lectores.

Ficha pública móvil20/10, ADR-113/114: consultas usan CasePublicCards con tarjetas glass según mockup aprobado; conservar ImmersivePhotoSheet en vistas previas y para reutilización futura. Título compacto de navegación Poppins400/20/gris por aprobación explícita; con texto ampliado título32 en fila propia. Nombre sobre foto blanco48/800. Contacto del autor por caso con consentimiento y RPC protegidas (plan031), sin ampliar perfiles privados/QR.

Conservación20/10, ADR-112: el componente `CasePublicationPreview` se renombra a `ImmersivePhotoSheet` (Ficha fotográfica inmersiva). Conservarlo para reutilización futura, también cuando se sustituya el diseño de Ver ficha. Las reglas anteriores de su nombre blanco48/800 siguen vigentes. Véase docs/funcionalidades/ficha-fotografica-inmersiva.md.

## Contexto

Construimos el MVP de recuperación colaborativa. Android primero. La arquitectura acordada es Clean Architecture por funcionalidad con Flutter, MVVM, Riverpod, casos de uso, repositorios y Supabase como backend. La web QR forma parte del MVP. Los motivos y las consecuencias se registran en [ADR-001](docs/decisiones/001-arquitectura-aplicacion.md).

Las instrucciones explícitas del usuario prevalecen sobre este documento. El plan maestro PDF es referencia de producto; sus propuestas técnicas se actualizan con las decisiones registradas aquí.

## Inicio y alcance

- Leer `docs/REGLAS_ARQUITECTURA.md` (norma obligatoria), `docs/ESTADO.md`, `docs/ARQUITECTURA.md` y la sección del sprint pertinente en `docs/GUIA_MVP.md`.
- Comprobar rama, cambios locales y estado real antes de editar. Conservar el trabajo existente.
- Usar las HU y RF originales para trazabilidad; separar el número de historia del número de issue de GitHub.
- Implementar un incremento completo con criterios de aceptación. No ampliar el MVP por la existencia de funciones futuras en el PDF.
- Por decisión explícita del usuario del17 de octubre de2026, las aplicaciones
  se organizan en `apps/mobile` (Flutter existente) y `apps/platform` (Vue/Nuxt).
  Esta instrucción sustituye la ubicación en la raíz acordada el6 de octubre.
  No recrear los proyectos ni cambiar identificadores de paquete por moverlos.

## Implementación

- Excepción local a ADR-111,20/10/2026: el nombre sobre fotografía de la ficha
  del caso (CasePublicationPreview) conserva fuente del sistema, blanco48/800,
  sombra suave y dos líneas con elipsis; sin cápsula blanca. Los demás títulos
  conservan Poppins400/32/gris.

- Títulos principales de móvil/web: Poppins Regular400, tamaño base32, gris
  #454746, interlineado1.25 y tracking0. Reutilizar AppTypography.primaryTitle
  y typography.css; fuente local, texto ampliado y ajuste de líneas. Incluye
  Guardados/acceso/onboarding/landing/legales; marca oficial y énfasis azul600
  de Inicio conservados. Sin overrides por funcionalidad. Seguir
  [ADR-111](docs/decisiones/111-titulos-principales-poppins-mobile-web.md).

- Cartografía global20/10/2026: todos los mapas móviles/web usan el acabado
  intermedio entre Reportar original y Explorar, según
  [ADR-104](docs/decisiones/104-cartografia-global-mobile-web.md). Reutilizar
  ZoneMapPicker/MapStyle en Flutter y LocationMap/maps.css/map-style.svg en Nuxt;
  sin filtros por funcionalidad ni mapas que eludan adaptadores compartidos.
  Solo teselas, manteniendo contraste de pines/radios/créditos, datos, permisos,
  selección y reintentos. Configurar la misma base Positron en ambos entornos;
  ninguna credencial de backend en URL pública de cartografía.

- Registro y recuperación web por código (19/10/2026): seguir ADR-087.
  /crear-cuenta y /recuperar-contrasena usan política guest;
  /restablecer-contrasena usa recovery en la política global SSR/cliente.
  La capacidad cifrada eh_credentials nunca autoriza inicio/moderación ni se
  convierte en sesión normal al verificar recovery. Token solo en servidor/cookie
  HttpOnly; código6 y reenvío60s validados en dominio/servidor. Registro confirmado
  conserva onboarding por cuenta. No introducir guards por pantalla ni SDK cliente.

- Por instrucción explícita del usuario del19/10/2026, el acceso y la etapa de
  cuenta se comprueban globalmente en todas las rutas web, antes de renderizar
  en servidor y montar en navegación cliente. Usar la política única compartida
  de ADR-079; no añadir guards por pantalla. Toda página/alias nueva declara su
  política y el build/comprobaciones rechazan omisiones. Públicas, QR y legales
  conservan acceso anónimo; rutas protegidas no muestran shell/skeleton antes
  del login sin sesión. Permisos por operación y reintento ante fallo de backend
  se mantienen. Véase [ADR-079](docs/decisiones/079-politica-global-de-acceso-web.md).

- Marca web: reutilizar SiteBrand/SiteHeader de la landing en todos los
  recorridos, con su posición, color #171918, tipografía y tamaños adaptables,
  incluidos login/onboarding. Cabecera fuera del stagger; no crear variantes
  por funcionalidad. Mantener posición y dimensiones desde el primer render SSR
  hasta hidratación/recarga completadas, sin saltos ni recentrado; acciones y
  retorno no desplazan ni tapan la marca. Seguir [ADR-077](docs/decisiones/077-marca-web-compartida-referencia-landing.md).


- Por instrucción explícita del usuario del19/10/2026, el logo oficial y texto
  «entre huellas» de la web van en la cabecera superior, alineados a la izquierda
  con la posición/márgenes de landing y onboarding, también en responsive.
  Fuera de la columna de contenido, stagger y skeletons; estables entre etapas.
  Aplica también a acceso y gestión, sustituyendo posiciones previas dentro
  del contenido. Seguir [ADR-076](docs/decisiones/076-posicion-unificada-marca-web.md).


- Por instrucción explícita del usuario del19/10/2026, /bienvenida web toma la
  composición/tipografía/botones y transición de sader-panel, con los tres PNG
  y textos originales de onboarding móvil. Seguir
  [ADR-074](docs/decisiones/074-onboarding-web-referencia-sader-y-mobile.md):
  Inter local, botones radio18px base y stagger550ms/90ms con salida antes del
  cambio. Es excepción local a Arial/cápsula/cover; no usar .reveal ni cobertura
  crema en onboarding, ni copiar apariencia/roles del otro proyecto.
  Mantener movimiento reducido, shimmer de guardado, reintento y limpieza.

- Por instrucción explícita del usuario del19/10/2026, Entre Huellas ofrece
  funciones de usuario en web y móvil sobre la misma cuenta/datos. La landing
  presenta el proyecto; el login web es general y no exige rol de moderación.
  Seguir [ADR-073](docs/decisiones/073-acceso-general-web-y-gestion-por-permisos.md):
  entrada común, bienvenida por cuenta y espacios de gestión según permisos.
  Administrador y moderador son permisos diferenciados, sin herencia implícita
  ni autoasignación. El incremento actual entrega inicio de cuenta y revisión;
  no afirmar paridad completa ni crear páginas de administración/usuario vacías.
  Administración y moderación siguen exclusivamente en web.

- Por instrucción explícita del usuario del19/10/2026, las rutas de navegación
  visibles de `apps/platform` usan español, minúsculas y guiones, sin tildes ni ñ.
  Seguir [ADR-072](docs/decisiones/072-rutas-web-en-espanol.md): objetivos
  `/iniciar-sesion`, `/terminos` y `/privacidad`; al migrar, conservar redirecciones
  desde `/login`, `/terms` y `/privacy` y los parámetros necesarios del flujo.
  La raíz `/` y el contrato QR `/c/:token` se conservan. Código, SQL y endpoints
  internos pueden seguir en inglés; callbacks OAuth y deep links son contratos
  de integración y no se renombran por esta regla. Login y legales ya migrados
  con redirecciones por ADR-073; otros nombres objetivo no crean pantallas vacías.

- Por instrucción explícita del usuario del18/10/2026, administración y
  moderación se implementan exclusivamente en `apps/platform` (Vue/Nuxt).
  `apps/mobile` no contiene pantallas, menús, guards ni acciones administrativas;
  conserva las operaciones del usuario, como denunciar contenido. La separación
  visual no sustituye la autorización por rol en servidor en cada operación.
  Seguir ADR-071; no crear una aplicación adicional por rol.

- Web, referencia aprobada del 18/10/2026: antes de cambios visuales en
  `apps/platform`, leer [REGLAS_UI_UX_WEB](docs/REGLAS_UI_UX_WEB.md).
  La landing final guía público, usuarios y administración; adaptar escala y
  composición a cada tarea, reutilizando componentes reales. ADR-063 extiende
  el alcance visual de ADR-060. Las reglas de feedback/arquitectura siguen vigentes;
  Flutter conserva su referencia de acceso. QR se adapta al intervenir sus recorridos.

- Web, decisión explícita del17/10/2026: Vue + Nuxt + TypeScript en una sola
  aplicación para público, usuarios y administración, organizada por funcionalidad
  y permisos de servidor. Flutter permanece en móvil. No separar proyectos por
  roles ni crear pantallas/guards ficticios antes de implementar autorización.
  SSR, generación estática o cliente se eligen por recorrido. Seguir ADR-058;
  ningún secreto en app/public/shared cliente, payload SSR o NUXT_PUBLIC.

- Cumplir [las reglas de oro de arquitectura](docs/REGLAS_ARQUITECTURA.md). Ningún incremento está completo si rompe sus fronteras. Registrar cambios de reglas como decisiones arquitectónicas versionadas y actualizar documentación/comprobaciones; no introducir excepciones implícitas por alcance MVP o urgencia.

- Presentation contiene pantallas, ViewModels y estado; data contiene implementaciones de repositorios y acceso a datos. Las operaciones del producto se expresan mediante casos de uso de dominio consumidos por ViewModels.
- Clean Architecture por funcionalidad: `domain/entities`, `domain/repositories` (contratos) y `domain/use_cases` independientes de Flutter, Riverpod y Supabase. Los casos de uso expresan operaciones concretas y reglas; no crear clases base genéricas ni funcionalidades vacías. Bootstrap/main inyectan implementaciones; `app` contiene bootstrap, aplicación y router.
- El alcance MVP limita las funcionalidades, no la separación de responsabilidades ni su calidad. Mantener el test de dependencias arquitectónicas al añadir funcionalidades.
- `presentation` organiza `screens`, `view_models`, `state` y `widgets` según componentes reales. La pantalla observa el estado del ViewModel; no obtiene repositorios ni combina directamente providers de infraestructura. Riverpod/AsyncValue pertenece a presentación/inyección, nunca al dominio.
- `data` organiza `data_sources`, `models` (DTO) y `repositories`. El SDK se encapsula en fuentes de datos; el repositorio mapea DTO a entidades y fallos externos a fallos de dominio. No propagar mensajes/tokens del SDK hacia la UI.
- Los providers de cada funcionalidad declaran contratos/casos de uso sin importar implementaciones ni pantallas. Bootstrap/main inyectan las implementaciones. Presentation no importa `app`; data no importa presentation/providers/app. Liberar suscripciones de presentación con autoDispose y comprobar recuperación tras error.
- Los widgets consumen ViewModels. El SDK de Supabase se usa detrás de repositorios o servicios, sin llamadas de negocio desde widgets.
- El acceso comienza en login; después mostrar las tres etapas de onboarding hasta completarlo; no se ofrece Omitir. Persistir la finalización por cuenta mediante los casos de uso y RPC protegida; no usar un indicador global por instalación. Seguir ADR-004.
- Nunca usar SnackBar en la UI del proyecto, directamente ni mediante wrappers/paquetes. No sustituirlo por una barra inferior equivalente. Por instrucción explícita del usuario, ADR-007 permite toast superior propio para éxito confirmado y ADR-009 lo amplía a errores de foto de perfil; ADR-013 permite también errores de eliminación de mascotas en el mismo toast superior; ADR-016 permite validación y errores de guardado/fotos en Registrar/Editar mascota con shake danger, sin mensajes debajo. Los demás errores/validación permanecen contextuales según ADR-005. Mantener las comprobaciones y el ciclo de vida del aviso.
- Antes de cualquier cambio visual, leer y cumplir [la regla de oro de UI y UX](docs/REGLAS_UI_UX.md). La referencia aprobada es el flujo actual de acceso/cuenta/códigos/contraseña; no reutilizar la dirección antigua ni el Inicio retirado como modelo. Consultar `docs/DISENO_UI.md` para implementación/revisión. Reutilizar componentes, dimensiones, estados y efectos; revisar renders normales/pequeños con texto ampliado, sin acciones vacías ni datos simulados.
- Retorno/cierre superior de pantallas: usar GlassNavigationButton compartido, circular glass flotante sobre el scroll, sin franja opaca; chevrón para volver y X para cerrar. Respetar insets, tooltip y área táctil. Seguir ADR-015 y REGLAS_UI_UX.
- Web: usar StaggerReveal/useStaggerReveal sin capa opaca ni utilidad .reveal;
  preservar parámetros de login/onboarding, cabeceras, movimiento reducido y
  QR SSR sin JS. Landing conserva clip-path aprobado. ADR-075 sustituye
  cover→stagger para estas entradas web; la regla siguiente conserva Flutter.
- Aplicar cover reveal seguido de stagger reveal en entradas de pantalla y cambios discretos de etapa, con cabeceras persistentes fuera del efecto y movimiento reducido respetado. No repetir efectos con edición/teclado/contadores/reenvío ni durante cada frame de un gesto; seguir ADR-006.
- Nunca indicar carga de botones mediante etiquetas con puntos suspensivos (`...` o `…`). Mantener la etiqueta y usar `LoadingShimmer` compartido durante trabajo real, con semántica de progreso y bloqueo de dobles envíos; sin spinner en botones ni shimmer por simple deshabilitación/cooldown. Mantener la comprobación automática y seguir ADR-006.
- Carga de contenido según ADR-011: skeleton en carga inicial, contenido conservado con progreso fino superpuesto durante refresh explícito de la misma cuenta. Sin textos visibles de carga ni indicadores circulares; labels accesibles permitidos. Ocultar datos anteriores al cambiar identidad y distinguir error de vacío confirmado.
- La configuración de acceso, permisos y reglas críticas se valida en Supabase: grants, RLS, restricciones y funciones autorizadas.
- Separar datos públicos del QR de coordenadas y documentos privados. La RLS controla filas; no sustituye el control de columnas expuestas.
- Versionar migraciones, políticas y funciones. No mantener cambios de esquema solamente en el Dashboard.
- Organizar fuentes SQL en `database` según `database/README.md` y ADR-002: directorios por tipo de objeto y numeración global `001_...sql`. Los scripts del incremento generan una migración en `supabase/migrations`; no mantener copias editables independientes ni reescribir SQL aplicado. Usar `database/scripts/Build-Migration.ps1` con los planes versionados y validar la migración en desarrollo antes del despliegue. `database/functions` es SQL; `supabase/functions` contiene Edge Functions.
- SQL usa identificadores en inglés con `snake_case`; Dart conserva `camelCase`/`PascalCase`. Generar `database/run_all.sql` con `database/scripts/Build-RunAll.ps1`, sin editar el resultado manualmente. Seguir ADR-003 y probar repetición/permisos al ampliar su alcance.
- La app usa clave publicable y sesión de usuario. Credenciales SQL, claves secretas y service_role permanecen en servidor.
- Guardar envíos offline con identificador estable; el servidor deduplica y valida reintentos. Diferenciar borrador, pendiente y publicado.
- Guardar la notificación antes de intentar push. Registrar fallo y permitir reintento.
- Mantener el alcance sin ASP.NET Core, SignalR, Redis ni workers de IA. Registrar una decisión arquitectónica si una necesidad posterior cambia este acuerdo.

## Validación y relevo

- Ejecutar las comprobaciones pertinentes a lo modificado. Para Flutter: formato, análisis y pruebas significativas; para datos: permisos entre usuarios, invariantes y reintentos.
- Reportar pruebas ejecutadas y pendientes; no afirmar que un build o una política funciona sin comprobarlo.
- Al terminar, actualizar `docs/ESTADO.md` con resultados, bloqueos y siguiente paso. Registrar modificaciones de alcance en la guía.
- Por instrucción del usuario, mantener una ficha por funcionalidad en `docs/funcionalidades`, enlazada desde su índice: qué hace, recorrido, reglas/campos, persistencia/permisos, errores/reintentos, dependencias/activación y validación pendiente. Actualizarla en cada incremento; distinguir funcionalidad implementada de historia cerrada y evidencia local de confirmación remota.
- Comunicar en español. Incluir resultado, validación y limitaciones materiales.
- La publicación, despliegue y acciones en GitHub siguen la autorización del usuario en la tarea actual; esta guía no concede por sí sola autorización para ejecutarlas.

- ADR-016, por instrucción explícita del usuario, exige nombre/especie/tamaño/edad/rasgos al guardar mascotas, rasgos hasta200 con contador interior; sexo opcional con Macho inicial. En Registrar/Editar los errores de campos, guardado y fotos usan shake danger y toast superior, sin mensajes debajo; las demás pantallas conservan feedback previo. No inventar datos de fichas antiguas incompletas: completar al editar metadatos y conservar sus operaciones de ciclo de vida.


## Feedback de reportes: corrección del 10 de octubre de 2026

Por instrucción explícita del usuario, los mensajes de error, validación y resultado se muestran en el toast superior compartido, sin texto contextual dentro de la pantalla ni debajo de campos/acciones. Esta instrucción sustituye las restricciones anteriores que reservaban el toast a excepciones y exigían feedback contextual. Etiquetas, datos, estados e instrucciones de privacidad se mantienen. El incremento adapta los flujos de reportes perdidos/encontrados; conserva invalid/ShakeField, acciones de reintento y ciclo de vida del aviso. Las demás funcionalidades existentes se adaptarán al intervenir sus flujos; no se afirma una migración global completada. Véase [ADR-023](docs/decisiones/023-feedback-reportes-toast-superior.md).

## Feedback global y consistencia: instrucción del 11 de octubre de 2026

El usuario extiende el toast superior a errores, validación y resultados de toda la app, sin mensajes bajo inputs ni errorText/helperText. No usar loaders circulares/lineales ni textos de carga: skeleton y LoadingShimmer; ContentRefresh aplica shimmer sobre contenido conservado en refresh. Mantener invalid/ShakeField, semántica, acciones reales y ciclo de vida del toast. Esta instrucción sustituye las reservas contextuales anteriores y la adaptación diferida de ADR-023. Véanse docs/decisiones/027-feedback-global-toast-shimmer.md y028-consistencia-fronteras-y-reutilizacion.md. No permitir presentation/data entre funcionalidades ni core→features; colaboración mediante dominio/providers declarativos.
