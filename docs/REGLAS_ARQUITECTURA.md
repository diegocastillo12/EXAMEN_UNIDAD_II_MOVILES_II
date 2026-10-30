# Entre Huellas: reglas de oro de arquitectura

30/10, [ADR140](decisiones/140-proteccion-y-borrado-local-examen-u2.md): protección
de ruta compuesta en app mediante transporte nativo, sin Flutter en data. Perfil
recibe slot para borrado de listas; ViewModel usa ClearOfflineLists. Fuente
serializa archivo/clave y nativo elimina solo namespace de listas offline.

30/10, [ADR139](decisiones/139-cifrado-lista-offline-android-keystore.md):
lista offline de favoritos recibe cifrador por interfaz sin Flutter en data;
puente de transporte MethodChannel en app e inyección desde main. Keystore/AES-GCM
encapsulados en Android nativo, sin claves en Dart ni negocio en MainActivity.

25/10, [ADR-138](decisiones/138-motor-visual-local-y-hallazgos-independientes.md):
matching conserva dominio/casos de uso, repositorios/fuentes y ViewModels por
funcionalidad. CPU en Nuxt existente con pesos locales fijados; sin nuevo worker
ni inferencia externa. Actor verificado en servidor, índices/RPC privados y
revisión humana sin asignación de propietario ni recuperación automática.

25/10, excepción explícita de alcance [ADR-137](decisiones/137-coincidencias-visuales-en-el-mvp.md):
coincidencias visuales HU-25/HU-26 incluidas en MVP. Esto no autoriza introducir
workers de IA ni servicios nuevos sin decisión técnica; conservar Clean Architecture,
permisos en servidor y separación de originales/derivados privados y datos públicos.

Contrato vigente21/10, ADR-128: combinar fullscreen/GSAP Sader con identidad
móvil al abrir y cerrar. La superficie negra y su radio se transforman; icono
y nueve puntos mantienen tamaño, centrados dentro del contorno, con fase fuente
hasta45% invertida al regresar. Fade/blur de Sader solo al cuerpo de destino.
Control original oculto temporalmente para evitar duplicado y restaurado junto
a la limpieza de identidad, estilos y referencias. Se mantienen0.7s/CustomEase,
ruta anterior detrás, marca/barra, acceso/guards y reducido. Perfil/Alertas y
Flutter intactos. [ADR-128](decisiones/128-identidad-mobile-en-origen-web-fullscreen.md).
Los apuntes anteriores que contradigan esa fase se conservan como historial.

Origen web21/10, instrucción posterior ADR-125: reemplazar el motor de navegación
por GSAP Flip de Sader sobre el componente vivo, sin snapshots/clones de páginas.
Contenido visible solo al terminar apertura0.7s; cierre antes de desmontar.
Excepción explícita a tiempos/fases de ADR-124 en este motor web; Perfil/Alertas
y Flutter conservados. [Alcance y validación](decisiones/125-origen-web-reemplazado-por-sader-gsap-flip.md).

Animaciones21/10, ADR-124: contratos de movimiento equivalentes deben coincidir
en móvil/web y verificarse con fotogramas de apertura/cierre normales y modo
reducido. Parámetros/controladores son presentación compartida, sin negocio,
repositorios ni imports entre presentaciones de funcionalidades. Origen real,
retorno, duración/curvas/fases y lifecycle obligatorios. [Regla](decisiones/124-paridad-animaciones-mobile-web.md).

Reportar web21/10, ADR-123: estado/carga/fallo por recurso en ViewModel mediante
los casos de uso existentes. La UI muestra campos estáticos tras acceso y
skeleton solo en dependencias pendientes, sin confundir fallo con vacío ni
descartar borradores por lecturas tardías. Operaciones autorizadas en servidor,
sin caché adicional. [Decisión](decisiones/123-carga-progresiva-reportar-web.md).

Controles web21/10, ADR-122: componentes compartidos de presentación adaptan
Sader sin importar React ni reglas del otro producto. MorphPanel concentra
geometría/animación/lifecycle; formularios conservan sus modelos y permisos.
Por petición expresa, línea superior solo durante navegación web, excepción
local a ADR-027. [Decisión](decisiones/122-controles-web-reutilizables-desde-sader.md).

Navegación web20/10, ADR-121: reutilizar únicamente la preparación vigente de
data, inyectada por bootstrap en navegación cliente después de hidratar; conservar
política global y revalidación por operación. No invalidar identidad por montar
una sección ni cachear permisos. [Decisión](decisiones/121-navegacion-web-sin-esperas-repetidas.md).

Hero landing20/10: ADR-120 registra la excepción explícita a ADR-111 para
#hero-title, con tipografía/composición originales. Solo presentación; SEO,
dominio, datos y permisos conservados. [Decisión](decisiones/120-restaurar-hero-original-landing.md).

**Cartografía global20/10, ADR-104:** mapas mediante adaptadores compartidos:
ZoneMapPicker/MapStyle en core/presentation móvil y LocationMap en app/components
web. Sin matrices/SDK/mapas independientes por funcionalidad. Filtrar solo
teselas, sin alterar dominio, coordenadas, permisos, pines o créditos. Regla
intermedia Reportar/Explorar común a ambas plataformas, con comprobación de
paridad de matrices. [ADR-104](decisiones/104-cartografia-global-mobile-web.md).

**Registro/recuperación web —19/10/2026:** CredentialViewModel consume casos
de uso de dominio; HTTP/Auth detrás de repositorios/fuentes y composición por
petición. Política global incorpora recovery para la capacidad temporal de
cambio de contraseña. Cookie eh_credentials cifrada con propósito/AAD distintos;
verificar recovery no establece sesión general ni permisos. Sin tokens en JSON,
SSR o cliente. Registro confirmado conserva onboarding. [ADR-087](decisiones/087-registro-y-recuperacion-web.md).

**Cierre web sin bloquear por Supabase —19/10/2026:** endpoints confirman primero
el borrado de cookies y vinculan el intento remoto al ciclo Nitro event.waitUntil.
Conservar casos de uso/fuentes y controles de origen; no afirmar revocación
remota ni entrega duradera por una confirmación local.
[ADR-082](decisiones/082-cierre-web-sin-esperar-supabase.md).

**Acceso preparado desde landing —19/10/2026:** preparación mediante ViewModel
y caso de uso; reutilización breve y deduplicación en data, por aplicación del
navegador, sin singleton de servidor ni payload SSR privado. Invalidar por
cambios de sesión/foco y vencimiento; permisos y operaciones no se cachean.
[ADR-080](decisiones/080-preparar-acceso-desde-landing.md).

**Acceso global a todas las rutas web —19/10/2026:** política compartida única
para servidor y middleware cliente global; sin guards elegidos por pantalla.
Clasificar cada página/alias como pública, acceso, cuenta, onboarding o permiso
implementado. Build y comprobación arquitectónica rechazan páginas sin política.
Validar antes del HTML/montaje para evitar pantallas/skeletons de rutas que no
corresponden. Públicas/QR/legales conservan anonimato y APIs autorizan cada
operación. [ADR-079](decisiones/079-politica-global-de-acceso-web.md) sustituye
los guards particulares descritos en las notas anteriores de ADR-078.

**Entrada web con sesión activa —19/10/2026:** /iniciar-sesion valida en servidor
antes de renderizar y redirige al destino de cuenta/onboarding. Cookie HttpOnly
cifrada con path /, transición de cookies anteriores sin exponer credenciales
ni perfiles en SSR; navegación cliente espera al caso de uso/ViewModel.
Sin login ni skeleton de acceso intermedio; los datos del destino conservan su
carga. Autorización por operación intacta. [ADR-078](decisiones/078-acceso-web-redireccion-servidor-sin-login-intermedio.md).
La misma comprobación previa aplica a /inicio y /bienvenida: sin sesión no
renderizar ni montar shell/skeleton de cuenta antes de ir al login. Distinguir
fallo de backend de sesión ausente y conservar el reintento existente.

**Reveal web compartido —19/10/2026:** retirar la utilidad .reveal y su capa
opaca. StaggerReveal reutiliza useStaggerReveal para entradas generales, conserva
HTML/eventos y no repite entrada por edición/refresh. Respetar movimiento
reducido y QR SSR sin JS/CSP. Flutter y clip-path de landing conservados.
[ADR-075](decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md).

**Onboarding web —19/10/2026:** por instrucción del usuario, presentación de
/bienvenida adapta sader-panel con contenido/PNG originales de móvil.
OnboardingFlow compone estado y acciones del ViewModel; transiciones y timers
son presentación, sin alterar RPC, sesión o permisos. Excepción visual local
a cover/cápsula/Arial, con movimiento reducido y limpieza obligatorios.
[ADR-074](decisiones/074-onboarding-web-referencia-sader-y-mobile.md).

**Acceso general web —19/10/2026:** una cuenta válida puede entrar sin permiso
de moderación; onboarding por cuenta y datos compartidos con móvil. Separar
autenticación de autorización por operación y conservar espacios de gestión
web con permisos diferenciados, sin herencia implícita administrador/moderador.
access y moderation colaboran mediante sesión de servidor/contratos de dominio,
sin imports de data/presentation entre funcionalidades. No crear páginas vacías
ni afirmar paridad web/móvil completa. Véase
[ADR-073](decisiones/073-acceso-general-web-y-gestion-por-permisos.md).

**Rutas web en español —19/10/2026:** la navegación visible de apps/platform
usa español, minúsculas y guiones, sin tildes ni ñ. Al migrar rutas existentes,
conservar redirecciones y parámetros necesarios; /login, /terms y /privacy
tienen como objetivos /iniciar-sesion, /terminos y /privacidad. Mantener raíz /
y QR /c/:token. Código/SQL/endpoints internos pueden seguir en inglés;
callbacks OAuth y deep links no cambian por esta convención. No crear rutas
vacías ni relajar autorización. Login y legales migrados; otros recorridos al implementarse:
[ADR-072](decisiones/072-rutas-web-en-espanol.md).

**Administración solo web —18/10/2026:** por instrucción expresa del usuario,
administración/moderación viven exclusivamente en `apps/platform`. Flutter
conserva operaciones de usuario como denunciar; no incorpora pantallas, menús,
guards ni acciones administrativas. Roles y decisiones se validan en servidor
en cada operación. Véase [ADR-071](decisiones/071-moderacion-exclusiva-platform.md).

**Referencia de presentación web — 18/10/2026:** leer también
[REGLAS_UI_UX_WEB](REGLAS_UI_UX_WEB.md). Por instrucción del usuario, la landing
aprobada guía toda apps/platform; Flutter conserva su referencia de acceso.
[ADR-063](decisiones/063-landing-como-referencia-ui-ux-web.md) extiende la referencia
visual de ADR-060, sin alterar capas, autorización o privacidad. Componentes
compartidos se extraen con reutilización real, sin dependencias de presentation
entre funcionalidades.

**Web,17/10/2026:** por decisión del usuario se adopta Vue/Nuxt/TypeScript
para una única aplicación web con módulos públicos, usuarios y administración.
Los roles no se resuelven solo en navegación: cada operación debe autorizarlos
en backend. La separación dominio/data/presentation también aplica a TypeScript;
dominio sin Vue/Nuxt/SDK, composición por petición y estado SSR sin singleton de
usuario. SSR público solo serializa proyecciones permitidas. Flutter permanece
en móvil. Sin rutas vacías de administración ni separación de proyectos por rol.
[ADR-058](decisiones/058-web-unica-vue-nuxt-y-roles.md).

**Regla vigente — 11 de octubre de 2026:** feedback de errores, validación y resultados en el toast superior compartido en todas las funcionalidades. Sin texto bajo inputs, errorText/helperText ni indicadores circulares/lineales. Skeleton y LoadingShimmer para carga inicial/acciones; ContentRefresh con shimmer conserva contenido durante refresh. Se mantienen invalid/ShakeField, semántica, reintentos, etiquetas/datos e instrucciones de privacidad. [ADR-027](decisiones/027-feedback-global-toast-shimmer.md) sustituye las restricciones anteriores de feedback; las notas fechadas anteriores son historia de las decisiones.

Estado: norma del proyecto. Fecha: 7 de octubre de 2026, America/Lima.

La decisión que sustenta estas reglas está registrada en [ADR-001: arquitectura de la aplicación](decisiones/001-arquitectura-aplicacion.md). La separación de capas permite mantener y probar las reglas de recuperación mientras evolucionan la interfaz, el acceso remoto y el almacenamiento local.

Este documento define las reglas que deben cumplir las implementaciones, refactorizaciones y revisiones del sistema. Se lee antes de modificar código junto con [AGENTS.md](../AGENTS.md), [ESTADO.md](ESTADO.md) y el sprint correspondiente de [GUIA_MVP.md](GUIA_MVP.md). [ARQUITECTURA.md](ARQUITECTURA.md) describe la organización y las decisiones concretas; este documento establece sus límites obligatorios.

**Regla de oro:** cada componente tiene una responsabilidad clara; las dependencias apuntan hacia contratos y dominio; la infraestructura permanece fuera de las reglas del producto. Ninguna entrega se considera completa si rompe estas fronteras.

Las instrucciones explícitas del usuario prevalecen. Ante discrepancias documentales, esta norma rige los límites arquitectónicos y se actualizan los documentos descriptivos para conservar coherencia. Una modificación de arquitectura debe registrarse como una decisión versionada con motivo, consecuencias y validación. El alcance MVP o la urgencia no crean excepciones implícitas.

## 1. Arquitectura y patrones adoptados

| Decisión | Regla del sistema |
| --- | --- |
| Clean Architecture por funcionalidad | Cada funcionalidad organiza presentación, dominio y datos según los componentes que realmente necesita. |
| MVVM | La pantalla renderiza estado; el ViewModel coordina acciones y estado de UI. |
| Casos de uso | Las operaciones del producto y sus reglas se expresan en dominio mediante contratos de repositorio. |
| Repository | Dominio declara el contrato; data implementa acceso, mapeo y coordinación de fuentes. |
| Adapter / fuentes de datos | Los SDK, APIs y almacenamiento se encapsulan en fuentes de datos sustituibles. |
| Inyección de dependencias | Los componentes reciben dependencias; bootstrap/main componen implementaciones y Riverpod las entrega. |
| Estado inmutable y flujo en una dirección | La UI envía acciones al ViewModel y recibe nuevos estados; no modifica entidades o datos compartidos. |
| SOLID | Las responsabilidades, contratos y sustituciones deben poder explicarse y probarse. |

Stack acordado: Flutter, Riverpod, go_router y Supabase. Android primero; la app existente permanece en `apps/mobile`. La web pública QR forma parte del sistema y conserva sus propios límites de acceso. No se añaden ASP.NET Core, SignalR, Redis o workers de IA sin una nueva decisión arquitectónica registrada.

## 2. Organización por funcionalidad

```text
lib/
  main.dart
  app/                         # Bootstrap, app y router
  core/                        # Configuración, tema y componentes compartidos
  features/
    <funcionalidad>/
      presentation/
        screens/
        widgets/
        view_models/
        state/
      domain/
        entities/
        repositories/
        use_cases/
        failures/
      data/
        data_sources/
        models/                # DTO de fuentes externas
        repositories/
      providers/               # Declaraciones de inyección
```

Se crean carpetas y clases cuando contienen una responsabilidad real. Una pantalla estática puede existir sin ViewModel, repositorio o caso de uso vacío. `core` recibe componentes compartidos con una razón concreta de reutilización; no concentra las reglas de todas las funcionalidades.

Archivos y carpetas usan `snake_case`; clases usan `UpperCamelCase`. Los nombres expresan responsabilidad: `AccessScreen`, `AuthViewModel`, `AuthViewState`, `AuthRepository`, `AuthRepositoryImpl`, `SupabaseAuthDataSource`, `AuthSessionDto` y `WatchAuthSession`.

## 3. Dependencias permitidas y prohibidas

El recorrido de una operación es:

```text
Pantalla → ViewModel → Caso de uso → Contrato de repositorio
                                          ↓ implementación inyectada
                              Repositorio de data → Fuente de datos → SDK

Respuesta: datos externos → DTO → entidad → estado de UI → pantalla
```

Este recorrido describe llamadas y resultados. En los imports, la implementación del repositorio depende del contrato de dominio; el contrato no importa la implementación.

| Componente | Puede conocer | No debe conocer |
| --- | --- | --- |
| Dominio | Dart independiente de plataforma, entidades, fallos, contratos y casos de uso de dominio | Flutter, Riverpod, Supabase, JSON de infraestructura, data, presentation, providers o app |
| Pantallas y widgets | Estado de UI, ViewModels, componentes visuales, tema y navegación simple | Repositorios, fuentes, DTO, SDK o composición de app |
| ViewModels | Casos de uso, entidades, estado de UI y providers declarativos | Implementaciones de repositorio, fuentes de datos, SDK o bootstrap |
| Repositorios de data | Contratos/entidades/fallos de dominio, DTO y contratos de fuentes | Pantallas, ViewModels, providers de UI o app |
| Fuentes de datos | SDK, formatos externos y DTO | Pantallas, ViewModels o reglas de presentación |
| Providers de funcionalidad | Contratos y casos de uso; Riverpod para declararlos | Implementaciones de data, pantallas o bootstrap |
| Bootstrap/main | Configuración, implementaciones y contratos para componerlos | Reglas del producto o comportamiento visual de una pantalla |

No introducir ciclos entre módulos. Una funcionalidad no importa la presentación o data de otra; la colaboración se expresa mediante contratos/casos de uso de dominio inyectados. Los exports y archivos compartidos tampoco deben servir para eludir estas reglas.

## 4. Reglas de presentation

La UI y UX cumplen [REGLAS_UI_UX.md](REGLAS_UI_UX.md). La referencia visual es el flujo de acceso aprobado; los componentes comunes se extraen a core respetando estas fronteras.

1. La pantalla obtiene los datos y acciones de su ViewModel. Un estado de pantalla reúne lo necesario para renderizarla; no combina directamente providers de infraestructura o sesión.
2. Los widgets contienen layout, estilos, animaciones, visibilidad y navegación simple. Validación de negocio, persistencia y procesamiento de respuestas se ejecutan fuera de ellos.
3. El ViewModel invoca casos de uso y transforma resultados en estado de UI. Las reglas de autorización o transición del producto no se deciden en presentación.
4. Los estados son inmutables. `AsyncValue` representa carga, dato y error en presentación; no se duplica con otra máquina de estados equivalente sin una necesidad específica.
5. Textos visibles, mensajes de error y adaptación visual pertenecen a presentación. Los mensajes externos del SDK no se muestran directamente.
6. Los providers vinculados a pantalla liberan recursos con `autoDispose` cuando corresponde. Un estado global persistente necesita un motivo y un propietario explícitos.
7. Comprobar carga, errores, recuperación, cambios de sesión y disposición de suscripciones. Una identidad recibida tras un error debe poder recuperar el estado aunque coincida con la anterior.
8. El diseño debe soportar superficies pequeñas y texto ampliado sin desbordamiento. Extraer widgets cuando tengan una responsabilidad visual reconocible.

## 5. Reglas de domain

1. Las entidades representan conceptos del producto y son independientes del almacenamiento. No contienen tokens, objetos del SDK, widgets ni anotaciones de serialización externa.
2. Los contratos de repositorio expresan operaciones y semántica: resultado, ausencia de datos, fallos, idempotencia y comportamiento observable cuando aplique.
3. Los casos de uso reciben contratos por constructor. Expresan operaciones concretas; contienen validación de negocio o coordinación que debe ser independiente de UI/backend.
4. El dominio no obtiene dependencias desde Riverpod ni desde singletons de SDK. Sus componentes se pueden probar con implementaciones sustitutas en Dart.
5. Los fallos de dominio tienen significado estable y no contienen mensajes sensibles o excepciones del SDK como contrato público. Un error no equivale a ausencia de sesión, datos vacíos o éxito.
6. Las reglas críticas de permisos, concurrencia y transiciones también se validan en servidor; una comprobación cliente no autoriza una operación por sí sola.

## 6. Reglas de data

1. El acceso a Supabase y otros SDK se realiza en `data_sources`. La inicialización del SDK en bootstrap es una excepción de composición explícita; no contiene operaciones de negocio.
2. Las fuentes devuelven DTO/proyecciones de datos externos. El repositorio entrega entidades y fallos del dominio a sus consumidores.
3. Los repositorios se construyen con contratos de fuentes; no buscan un cliente global por su cuenta. Las fuentes reciben el cliente desde composición.
4. El mapeo DTO → entidad se realiza en data. No propagar estructuras JSON ni tipos externos para que presentación los interprete.
5. Normalizar fallos externos y conservar la información técnica necesaria para diagnóstico seguro, sin exponer credenciales, tokens ni datos privados. No ocultar errores como resultados exitosos.
6. La responsabilidad de caché, fuentes remota/local y sincronización pertenece a data. Las reglas del producto corresponden a dominio y al servidor.
7. Los reintentos deben tener una política explícita. No reintentar escrituras sin identificador estable y deduplicación/validación del servidor. Diferenciar borrador, pendiente y publicado.
8. Los streams deben conservar transiciones y recuperación pertinentes; cancelación, pausa y reanudación se transmiten al origen. Cada suscripción conserva su estado propio.

## 7. SOLID y tamaño del código

| Principio | Criterio para revisar un cambio |
| --- | --- |
| S: responsabilidad única | Cada clase tiene una responsabilidad y un motivo principal para cambiar. |
| O: abierto a extensión | Un comportamiento variable se puede incorporar mediante contratos/composición, sin introducir decisiones del backend en los consumidores. |
| L: sustitución | Una implementación sustituta conserva la semántica, resultados y fallos acordados; no basta con coincidir en firmas. |
| I: segregación de interfaces | Los contratos ofrecen las operaciones que necesitan sus consumidores; evitar interfaces que agrupan responsabilidades ajenas. |
| D: inversión de dependencias | Los casos de uso dependen de contratos; las implementaciones se inyectan desde composición. |

**No hay un máximo obligatorio de líneas por archivo o método.** Revisar responsabilidades, dependencias, complejidad y duplicación. Dividir cuando una clase acumula motivos de cambio, un método mezcla etapas distintas o un widget contiene componentes visuales independientes.

La división debe mejorar claridad y pruebas. No crear clases base universales, interfaces para cada clase, contenedores DI adicionales o paquetes/generadores sin una necesidad demostrable. Una clase pequeña también debe cumplir sus contratos y fronteras.

## 8. Seguridad y persistencia del sistema

- Flutter contiene solo URL y clave publicable con sesión de usuario. Los valores de compilación no son secretos. Credenciales SQL, `service_role` y claves secretas permanecen en servidor.
- Configuración local ignorada por Git; ejemplos versionados sin credenciales. Nunca registrar códigos/tokens del deep link ni datos privados en logs.
- Versionar migraciones, grants, RLS, restricciones y funciones. Comprobar permisos entre usuarios y roles; no mantener esquema solamente en Dashboard.
- Las fuentes SQL pertenecen a `database`, por tipo de objeto y con numeración global. Los cambios de cada incremento generan su migración de Supabase; conservar el SQL aplicado y añadir nuevos scripts para evolucionarlo. Seguir [database/README.md](../database/README.md) y [ADR-002](decisiones/002-organizacion-database.md). Seeds y tests se ejecutan aparte; no hay dos fuentes editables para el mismo cambio.
- SQL usa inglés y `snake_case` en minúsculas para identificadores; los DTO mapean a `camelCase` en Dart. `database/run_all.sql` es generado y repetible; no editarlo manualmente ni reescribir migraciones aplicadas. Al ampliar su alcance, revisar repetición y permisos según [ADR-003](decisiones/003-ejecucion-sql-idempotente.md).
- Separar contratos públicos del QR de coordenadas/documentos privados. RLS controla filas y debe acompañarse de control de columnas y bytes expuestos.
- Validar invariantes y operaciones atómicas en servidor. Reintentos incompatibles deben producir conflicto, no publicaciones duplicadas.
- Persistir notificaciones y trabajo de entrega antes de intentar push; registrar fallos y permitir reintento.
- Mantener el retorno móvil `entrehuellas://login-callback/` gestionado por Supabase/app_links. Modificar el enlace exige revisar registro nativo, allowlist remota y flujo de autenticación.

Estas reglas describen requisitos de cada incremento; no afirman que todas las funcionalidades o políticas ya estén implementadas. La evidencia actual se registra en [ESTADO.md](ESTADO.md).

## Regla de feedback visual

**No utilizar SnackBar en ninguna funcionalidad de la app**, ni directamente ni mediante wrappers/paquetes. No eludir la regla con una notificación inferior equivalente. Usar el toast superior compartido, accesible y breve, para errores, validación y resultados. En el login, el error modifica el borde y el icono; conserva el fondo. La decisión y las comprobaciones se registran en [ADR-005](decisiones/005-feedback-sin-snackbar.md).

## 9. Verificación obligatoria de cambios

La UX reutiliza cover reveal seguido de stagger reveal en entradas de pantalla y cambios discretos de etapa, con cabeceras estables; no repite efectos por edición/contadores/reenvío ni por cada frame de gestos. La carga de botones conserva su etiqueta y usa LoadingShimmer: no etiquetas de progreso con puntos suspensivos ASCII/Unicode ni spinners de botón. Solo durante trabajo real, con bloqueo de duplicados, semántica accesible y movimiento reducido. La regla, alcance y comprobación se registran en [ADR-006](decisiones/006-transiciones-y-carga-con-shimmer.md). Todo pertenece a presentación; los ViewModels/casos de uso siguen gobernando operaciones y resultados.

Antes de considerar completo un cambio de código, comprobar los puntos que le correspondan:

- Responsabilidades y dependencias respetan esta norma; las operaciones tienen trazabilidad a sus HU/RF.
- Reglas y contratos relevantes se prueban por separado, y se verifica su integración con estado/navegación cuando corresponda.
- Las pruebas cubren fallos y límites materiales: recuperación, cancelación, permisos, invariantes y reintentos según el flujo.
- Se ejecutan formato, análisis y pruebas pertinentes. Un build o demo se declara válido únicamente si se ejecutó.
- La configuración pública está separada de secretos y las migraciones/políticas necesarias están versionadas.
- La documentación de estado registra resultados, limitaciones y siguiente paso. No se acepta una excepción arquitectónica silenciosa.

Comandos desde `apps/mobile`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
```

Resolver dependencias primero si cambiaron. `test/architecture_test.dart` comprueba varias fronteras mediante directivas import/export/part y se ejecuta con `flutter test`. El workflow Flutter ejecuta comprobaciones cuando se publique en GitHub. Esta protección automática complementa la revisión; no cubre todos los símbolos, imports transitivos, reglas de negocio ni permisos remotos. Los cambios solo documentales requieren comprobar coherencia y enlaces; no obligan a repetir builds de aplicación.

## 10. Cómo evolucionar sin perder la arquitectura

Para cambiar una regla, registrar una decisión arquitectónica versionada en `docs` con el problema, alternativas, decisión, impacto, plan de transición y validación. Actualizar esta norma, [ARQUITECTURA.md](ARQUITECTURA.md), [AGENTS.md](../AGENTS.md) y las comprobaciones afectadas en el mismo incremento. Mantener compatible el comportamiento existente o documentar expresamente su migración.

Ningún documento garantiza por sí solo que la arquitectura nunca se rompa. Su cumplimiento se sostiene leyendo estas reglas, revisando cada cambio y manteniendo pruebas y CI que detecten las desviaciones comprobables.

## Evolución explícita del feedback de éxito

[ADR-007](decisiones/007-confirmacion-toast-superior.md) permite un toast superior propio para éxitos confirmados, por nueva instrucción del usuario. Es presentación: widget de core con overlay/timer ligados al ciclo de vida de la pantalla, disparado por nueva confirmación de estado. No introduce SDK, persistencia ni decisiones de negocio en UI. ADR-027 extiende ahora el toast a errores y validación; el componente inferior prohibido no se incorpora. Mantener pruebas de limpieza, no duplicación y accesibilidad, además del escaneo existente.

ADR-009 permite errores de foto en el componente toast superior existente por instrucción expresa. Sigue siendo feedback de presentación con ciclo de vida local; ADR-027 extiende ahora el mismo feedback a todas las funcionalidades y no se incorpora el componente inferior prohibido.

## Validación y feedback del editor de mascotas — ADR-016

Por instrucción explícita del usuario, Registrar/Editar valida nombre, especie, tamaño, edad y rasgos obligatorios (máximo200); sexo opcional. Dominio expresa validación, ViewModel reúne errores y bloquea escritura inválida, UI aplica shake/borde danger y toast superior sin errorText bajo campos. Incluye fallos de guardado/fotos del editor; ADR-027 generaliza ahora la ubicación del feedback a las demás pantallas. Fuente SQL034/trigger035 valida metadatos en servidor sin modificar datos antiguos ni impedir archivo/restauración/eliminación. Véase [ADR-016](decisiones/016-validacion-formulario-mascotas.md).


## Feedback de reportes: corrección del 10 de octubre de 2026

Por instrucción explícita del usuario, los mensajes de error, validación y resultado se muestran en el toast superior compartido, sin texto contextual dentro de la pantalla ni debajo de campos/acciones. Esta instrucción sustituye las restricciones anteriores que reservaban el toast a excepciones y exigían feedback contextual. Etiquetas, datos, estados e instrucciones de privacidad se mantienen. El incremento adapta los flujos de reportes perdidos/encontrados; conserva invalid/ShakeField, acciones de reintento y ciclo de vida del aviso. Las demás funcionalidades existentes se adaptarán al intervenir sus flujos; no se afirma una migración global completada. Véase [ADR-023](decisiones/023-feedback-reportes-toast-superior.md).
