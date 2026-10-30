# Entre Huellas: guía de proyecto, chats, sprints y GitHub

30/10: punto3 del examen tipo4: respaldo Android excluido, protección de Guardados
y borrado de listas/claves desde Perfil.24 pruebas Flutter y6 nativas aprobadas;
capturas reales del recorrido pendientes. Sin ampliación/cierre de HU. ADR140.

30/10: punto2 del examen U2 tipo4 implementado para la lista de favoritos offline,
AES-GCM/Android Keystore con IV por guardado. Reinstalación limpia realizada;
16 pruebas Flutter y3 instrumentadas Android aprobadas. Login/nuevo guardado/
modo avión/ADB cifrado pendientes del usuario. Sin ampliar HU del MVP.

30/10: incremento académico explícito, examen U2 tipo4 punto1, en Guardados Android:
guardar lista visible en JSON privado sin cifrar y fallback por fallo de backend.
No cambia alcance ni estado de HU del MVP. Evidencia de emulador/modo avión/ADB
pendiente del usuario; [ficha](funcionalidades/lista-guardada-examen-u2.md).

25/10: HU-25/#71 y HU-26/#72 implementadas localmente en `feature/case-matching`.
Hallazgos independientes aprobados expresamente, sin retirar avisos vinculados
ni reclasificar históricos. Encoder visual CLIP CPU local en Nuxt existente,
índices/revisiones privadas (plan040), ranking exploratorio de hasta cinco casos,
revisión humana y recorridos Android/web. Sin worker, inferencia externa ni FCM.
[ADR-138](decisiones/138-motor-visual-local-y-hallazgos-independientes.md) y
[ficha](funcionalidades/coincidencias-de-casos.md). Activación040/demo alojada,
dataset/evaluación, aceptación e integración pendientes; no se cierra el MVP.

25/10: el usuario acepta cuenta/acceso, difusión, seguimiento y recuperación.
Se cierran #19/#34/#35/#40/#41/#13 y épica #8 en GitHub/Projects. Cuenta HU-01
conserva baja #24/exportación #25 sin implementar; HU-12 conserva push #42
pospuesto. Sin nueva prueba independiente del agente.

Cambio explícito de alcance: **coincidencias visuales incluido en MVP**,
HU-25/#71 (indexación) y HU-26/#72 (sugerencia/revisión), RF-19/RF-20 originales.
Sustituye V1/S10 del PDF solo para estas capacidades, sin renumerar HU ni
confundirlas con #25/#26. Backlog/P1, refinamiento/modelo/evaluación pendientes;
sin implementación, plazo ni servicios nuevos activados.
[ADR-137](decisiones/137-coincidencias-visuales-en-el-mvp.md) y
[ficha](funcionalidades/coincidencias-de-casos.md).

24/10: autorizado continuar tras HU-15.3. PR69 ya fusionado; checks de Flutter/web
del HEAD y validación de main aprobados, #49 y épica #15 cerrados con evidencia.
Publicación APK pendiente de nueva ejecución tras la configuración definitiva
de firma/secrets confirmada por el usuario; el run anterior no los recibió.
Se implementa HU-16.1/RF-35/#50 en `feature/pilot-statistics`: siete agregados
por período de Lima, permiso administrador independiente y política global.
Usuario confirma cancelado=retirado sin recuperación registrada y archivado=
retirado después de recuperación registrada. Sin nuevas HU/RF/issues, controles
de HU-16.2/#51 ni cambios de Flutter. Activación039/demo alojada/integración
pendientes; [ficha](funcionalidades/estadisticas-piloto.md).

24/10: cambio autorizado del dominio público a `https://entrehuellas.app` en
servidor web, SEO y consumidores Android de QR/compartir/avistamientos.
Supabase e infraestructura conservan sus endpoints en kormind.com. Sin nueva
HU/RF/issue, SQL, ampliación funcional ni despliegue automático. Activación y
pendientes en [landing](funcionalidades/landing-page.md) y ESTADO.

24/10: autorizado implementar HU-15.3/RF-32/#49 en Android después del cierre de
#47/#48. Caché privada de fichas consultadas y fotos, accesible desde Guardados,
fecha/aviso e invalidación por servidor; ADR-135. Sin ampliar a mapas descargados,
PWA/web offline, SQL nuevo ni cierre de issues por arrastre.
[Evidencia y pendientes](funcionalidades/fichas-sin-conexion.md).

24/10: usuario autoriza integrar y cerrar historias terminadas. PR
[#67](https://github.com/srg-cp/entrehuellas/pull/67) ya fusionado integra HU-15.2;
#47/#48 cerrados con CI y evidencia final. Resultado verificado:29 cerrados y22
abiertos, etiqueta/Projects concordantes. [Auditoría de los51 issues](backlog/auditoria-github-2026-10-24.md)
conserva abiertos los criterios pendientes de otras entregas. HU-15/#15 sigue
abierta por HU-15.3/#49, siguiente incremento sin implementar.

22/10: preparación de distribución Android solicitada por el usuario: firma
propia y prerelease con APK por push a main, condicionada a validaciones.
[Configuración y límites](funcionalidades/distribucion-android.md). Infraestructura
de entrega de las HU existentes, sin nuevas historias, alcance de producto,
cierre del MVP, publicación en Play ni activación remota por arrastre.

Contrato vigente21/10, ADR-128: combinar fullscreen/GSAP Sader con identidad
móvil al abrir y cerrar. La superficie negra y su radio se transforman; icono
y nueve puntos mantienen tamaño, centrados dentro del contorno, con fase fuente
hasta45% invertida al regresar. Fade/blur de Sader solo al cuerpo de destino.
Control original oculto temporalmente para evitar duplicado y restaurado junto
a la limpieza de identidad, estilos y referencias. Se mantienen0.7s/CustomEase,
ruta anterior detrás, marca/barra, acceso/guards y reducido. Perfil/Alertas y
Flutter intactos. [ADR-128](decisiones/128-identidad-mobile-en-origen-web-fullscreen.md).
Los apuntes anteriores que contradigan esa fase se conservan como historial.

21/10: instrucción posterior exige reemplazar el motor web desde origen por el
código de Sader, sin clones de páginas y contenido solo al completar apertura.
[ADR-125](decisiones/125-origen-web-reemplazado-por-sader-gsap-flip.md) registra
la excepción explícita de movimiento web; sin nuevas HU/RF/issues, alcance
funcional, permisos/SQL, cambios de Flutter o cierre de historias.

21/10: regla explícita de paridad móvil/web para animaciones equivalentes,
[ADR-124](decisiones/124-paridad-animaciones-mobile-web.md). Se corrigen apertura
y cierre de Perfil/Alertas web desde sus controles, conservando movimiento móvil.
Sin nuevas HU/RF/issues, permisos, SQL ni operaciones; no es auditoría completa
de otras animaciones ni cambio de la referencia Flutter.

21/10: por petición del usuario, completar cabecera Home web con avatar/perfil
de consulta (HU-01.7/RF-01/#23) y bandeja de alertas (HU-12.2/RF-17/#41) sobre
los datos de cuenta existentes. Lectura/paginación/marcar leída; no amplía a
push, preferencias/seguimiento web, edición de perfil ni paridad completa.
Sin nueva HU/issue, migración o cierre de historias; validación local y límites
en [notificaciones web](funcionalidades/notificaciones-web.md).

Reportar web21/10: mejora autorizada de carga en los recorridos de recuperación
existentes; campos y dependencias cargan de forma progresiva según ADR-123.
Sin nuevas HU/RF/issues, funcionalidad de producto, SQL ni alcance Flutter.
[Ficha](funcionalidades/navegacion-web.md).

Controles web21/10: mejora visual autorizada de recorridos existentes de
recuperación/mascotas/avistamientos/moderación; reutiliza componentes de Sader
en Nuxt. Sin nuevas HU/RF/issues, alcance funcional, SQL ni Flutter.
[ADR-122](decisiones/122-controles-web-reutilizables-desde-sader.md),
[ficha y evidencia](funcionalidades/controles-web.md).

Respuesta web20/10: mejora autorizada de navegación existente, ADR-121. Elimina
invalidación por montaje, reutiliza preparación vigente y acorta entrada general;
sin nuevas HU/RF/issues, cierre de historias ni despliegue. Validación y límites
en [navegación web](funcionalidades/navegacion-web.md).

Segunda mejora SEO20/10: recursos adaptables del hero y vista previa social ligera,
manteniendo diseño ADR-120; sin nuevas HU/RF/issues ni despliegue. Dominio propio
por marca, sin promesa de ranking por.app. [Resultados](funcionalidades/landing-page.md).

Hero20/10: restauración explícita de la referencia original de landing según
capturas del usuario, ADR-120. Excepción local a la unificación de títulos;
sin nuevas HU/RF/issues, cambios de SEO ni despliegue.

SEO20/10: mejora autorizada de la landing existente, sin nuevas HU/RF/issues ni
cierre de historias. Metadatos descriptivos, identidad estructurada, dominio SEO
configurable y WebP sin pérdida; conserva privacidad QR/cuenta y composición.
[Activación, migración futura y límites](funcionalidades/landing-page.md).
No incluye compra de dominio, publicación ni gestión de Search Console.

Corrección visual20/10, ADR-119: usuario exige barra solo con iconos y trasladar
efectos móviles a componentes reutilizables web. Se implementan indicador liquid
persistente y expansión/retorno desde origen en los recorridos existentes;
sin nuevas HU/RF/issues, backend, SQL, despliegue o cierre de historias.
[Alcance y validación](funcionalidades/transiciones-web.md).

## Navegación y recuperación web autorizadas —20/10/2026

El usuario solicita la barra de móvil y confirma incorporar Explorar, Mis mascotas
y Reportar. Incremento web de funciones existentes HU-03/04/05/06/07/10,
RF-03/05/06/11/13;
sin nuevas HU/issues ni cierre por arrastre. Entrega lista filtrada/paginada,
mascotas propias alta/edición/fotos y cuatro tipos de reporte con mapa/borrador.
Sustituye la pendiente histórica de estos recorridos en ADR-073; no implica
paridad completa ni ampliar seguimiento/administración. [ADR-118](decisiones/118-navegacion-web-y-recorridos-de-recuperacion.md)
y [ficha con límites y validación](funcionalidades/navegacion-web.md).
Sin SQL nuevo, despliegue o acciones GitHub; integración remota pendiente.

Incremento20/10 autorizado de HU-01 y HU-05/06/07, RF-01/05/06/13: celular privado opcional en perfil y sugerencia al autor al autorizar contacto por caso (ADR-116). Plan033 después de032/031, sin nueva historia/issue ni cierre adicional. No publicación automática ni contacto anónimo/QR/PDF; hosted y Android pendientes.

## Tipografía compartida móvil/web —20/10/2026

Por instrucción explícita, todos los títulos principales adoptan Poppins400/32/
#454746 según [ADR-111](decisiones/111-titulos-principales-poppins-mobile-web.md).
Incremento transversal de presentación de funcionalidades existentes; sin nueva
HU/RF/issue ni cierre de historias o despliegue por arrastre.

## Registro y recuperación web autorizados —19/10/2026

El usuario autoriza completar los recorridos de acceso ya existentes en móvil:
crear cuenta, verificar/reenviar código y recuperar/guardar nueva contraseña.
Incremento web de HU-01/RF-01,34, sin nueva HU/issue ni cierre de #17/#18/#20/#22
por arrastre (su evidencia móvil conserva su propio alcance). Las notas históricas
de registro/recuperación web pendientes quedan sustituidas por esta implementación
local. Conserva onboarding y gestión por permisos. [ADR-087](decisiones/087-registro-y-recuperacion-web.md),
[ficha](funcionalidades/acceso-web.md). No añade perfil editable, baja/exportación,
administración, SQL o despliegue; demo SMTP/Auth real pendiente.

## Corrección compartida del reveal web —19/10/2026

Corrección transversal de presentación en inicio, moderación, QR y avistamientos.
Elimina la capa crema global, reutiliza el stagger aprobado y conserva contratos
y alcance de las historias existentes. Sin nueva HU/issue ni cierre adicional.
[ADR-075](decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md).

## Corrección visual de onboarding web —19/10/2026

El usuario solicita composición/transición del onboarding de su sader-panel con
ilustraciones/contenido de móvil Entre Huellas. Incremento visual HU-01/RF-01,34
web; sin nueva HU/issue ni backend. Conserva tres pasos sin Omitir, cuenta
compartida y RPC existente.
[ADR-074](decisiones/074-onboarding-web-referencia-sader-y-mobile.md)
y [ficha](funcionalidades/acceso-web.md).

## Acceso general e inicio web de usuario —19/10/2026

El usuario aclara que platform debe ofrecer funciones de usuario junto con móvil,
aprueba login común y espacios de gestión por permisos y autoriza proceder.
Incremento de HU-01/RF-01,34 en web; conserva HU-14.3/RF-22,33 / issue #45.
Entrega acceso de cuenta, bienvenida de tres pasos compartida por cuenta, inicio
con perfil real/cierre y acceso autorizado a revisión. Rutas de acceso/legal
migradas según ADR-072. [ADR-073](decisiones/073-acceso-general-web-y-gestion-por-permisos.md)
registra alcance y límites; [ficha](funcionalidades/acceso-web.md).
No entrega todavía Explorar/mascotas/reportes/avisos/perfil editable ni
registro/recuperación web o administración. Sin SQL, asignación de roles,
Flutter, despliegue ni cierre de historias. Próximo incremento propuesto: Explorar web.

## Convención de rutas web —19/10/2026

El usuario aprueba rutas visibles en español, minúsculas y guiones, sin tildes
ni ñ. [ADR-072](decisiones/072-rutas-web-en-espanol.md) registra nomenclatura,
excepciones API/QR/integraciones y redirecciones compatibles al migrar.
Incremento documental: no entrega nuevas pantallas ni migra las rutas actuales,
no amplía historias ni crea HU/RF/issues. Aplicar en próximos recorridos web.

## Documentos legales del acceso —18/10/2026

El usuario solicita animación del icono, orbe en login y enlaces de términos/
privacidad. /terms y /privacy públicas, con correo y responsable confirmados;
ampliación autorizada del acceso, sin nueva HU/issue ni funciones administrativas
por arrastre. Sin SQL/móvil/despliegue. Ver ficha documentos-legales y ESTADO.

## Ampliación autorizada de acceso web social —18/10/2026

El usuario solicita Google/Facebook como en móvil, retirar texto de cuentas
autorizadas y revisar skeleton. Implementación de /login dentro del incremento
HU-14.3 / issue #45; no crea una HU/issue nuevo ni cierra historia automáticamente.
PKCE y permisos en servidor, sin cambios SQL/móvil. Configuración de proveedores,
allowlist web y demo real pendientes; [ficha](funcionalidades/acceso-web.md).

## Separación del login web —18/10/2026

Petición explícita del usuario: /login separado y redirecciones de /moderacion,
login, logout y expiración. Incremento de acceso de HU-14.3 / issue #45, sin
registro ni nuevos roles/HU, sin SQL ni cambio de alcance móvil.
[Ficha de acceso](funcionalidades/acceso-web.md) y ESTADO separan QA fixture
de validación remota pendiente.030 ya confirmado por usuario.

**Incremento18/10 HU-14.3/#45:** usuario autoriza moderación exclusivamente en
apps/platform; móvil conserva denuncia de usuario, sin administración. Se
implementa cola/revisión/decisión con auditoría y visibilidad independiente del
estado del caso.029 ya aplicado según usuario;030/configuración/demo pendientes.
HU-14.2 bloqueo y HU-14.4 apelación no se entregan por arrastre. FCM fuera del
alcance. [Ficha](funcionalidades/moderacion-web.md),
[ADR-071](decisiones/071-moderacion-exclusiva-platform.md).


**Avance18/10:** usuario confirma028 aplicado y autoriza HU-14.1/#43 de S6.
Denuncia Android/SQL implementada localmente, pendiente029/demo/integración.
[Alcance y validación](funcionalidades/denuncias-contenido.md). Firebase/FCM está
fuera del alcance activo; no se condiciona este avance a su activación.
Las referencias históricas a028 pendiente quedan sustituidas por la confirmación.


**Regla vigente — 11 de octubre de 2026:** feedback de errores, validación y resultados en el toast superior compartido en todas las funcionalidades. Sin texto bajo inputs, errorText/helperText ni indicadores circulares/lineales. Skeleton y LoadingShimmer para carga inicial/acciones; ContentRefresh con shimmer conserva contenido durante refresh. Se mantienen invalid/ShakeField, semántica, reintentos, etiquetas/datos e instrucciones de privacidad. [ADR-027](decisiones/027-feedback-global-toast-shimmer.md) sustituye las restricciones anteriores de feedback; las notas fechadas anteriores son historia de las decisiones.

Fecha: 4 de octubre de 2026. Repositorio: https://github.com/srg-cp/entrehuellas.

Esta es la guía del MVP acordado: **Flutter + Supabase**, con Clean Architecture por funcionalidad, MVVM, Riverpod, casos de uso y repositorios. Adapta los sprints S1-S6 y las historias HU-01 a HU-16 del plan maestro v2. La API ASP.NET Core queda como evolución opcional. [ADR-001](decisiones/001-arquitectura-aplicacion.md) registra los motivos y las alternativas de esta organización.

Cada sprint debe cumplir [REGLAS_ARQUITECTURA.md](REGLAS_ARQUITECTURA.md), norma compartida de patrones, dependencias y SOLID. El alcance funcional del sprint no modifica esos límites.

## 1. Cómo dividir el trabajo entre chats

Recomendación: **un chat de coordinación, un chat de configuración y un chat por sprint**. Abrir un chat adicional por una historia grande solo cuando necesite una investigación o implementación independiente.

| Chat | Propósito | Resultado |
| --- | --- | --- |
| Coordinación | Este chat: alcance, arquitectura, prioridades y decisiones. | Documentación coherente y próximo incremento definido. |
| 00 - Proyecto y estructura | Herramientas, app Flutter, carpetas, GitHub y CI. | Base ejecutable y documentada. |
| 01 - Acceso y cuenta | S1, HU-01. | Sesión y perfil con permisos. |
| 02 - Mascotas y zonas | S2, HU-02 a HU-04. | Mascotas, fotografías y preferencias. |
| 03 - Perdidos y encontrados | S3, HU-05 a HU-07. | Casos en lista y mapa con filtros. |
| 04 - QR y avistamientos | S4, HU-08 a HU-10. | Colaboración desde el navegador sin instalar. |
| 05 - Seguimiento y recuperación | S5, HU-11 a HU-13. | Cronología, alertas y cierre. |
| 06 - Validación del MVP | S6, HU-14 a HU-16. | Moderación, offline, métricas y demo. |

Estos nombres son una propuesta de organización; la guía no crea chats automáticamente. Seleccionar el mismo proyecto/carpeta al abrir cada chat nuevo.

Mantener los archivos como registro compartido. Codex puede cargar instrucciones del proyecto desde `AGENTS.md`; las decisiones y avances que necesita el siguiente chat deben quedar escritos, sin depender de que tenga el historial anterior. [Instrucciones de proyecto en Codex](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

Trabajar de forma secuencial inicialmente: cerrar y validar el incremento anterior antes de comenzar uno dependiente. Si dos chats necesitan editar a la vez, usar ramas y worktrees separados; una rama diferente en la misma carpeta no crea dos copias independientes de los archivos. [Worktrees en Codex](https://learn.chatgpt.com/docs/environments/git-worktrees).

## 2. Qué construimos primero

El recorrido del MVP es:

1. El usuario inicia sesión y registra una mascota.
2. Publica un caso perdido o encontrado con fotos, hora y zona.
3. Comparte un cartel con QR.
4. Un ciudadano abre la web y reporta un avistamiento.
5. El responsable recibe ayuda en su bandeja, revisa evidencia y cierra el caso.
6. El QR muestra el estado actualizado, con moderación y manejo de conectividad.

Además: preferencias de zonas, datos públicos separados de privados, gestión de cuenta, auditoría y métricas mínimas. Chat completo, salud, cuidadores compartidos, refugios, adopciones y reservas se planifican después del MVP. Por decisión del25/10, la similitud visual y revisión de coincidencias (HU-25/HU-26; RF-19/RF-20) se adelantan al MVP; otras ampliaciones de IA no quedan incluidas implícitamente.

Los seis sprints son una secuencia de entregas. Si se conserva la duración de dos semanas del plan, representan doce semanas referenciales. La fecha de entrega y la capacidad semanal todavía deben confirmarse; el chat 00 es preparación, no una promesa de plazo adicional fijo.

## 3. Estado de partida histórico (4 de octubre de 2026)

- Git estaba inicializado. Se configuró `origin` y la rama local `main`.
- El repositorio remoto respondió sin referencias al consultarlo: vacío en esa comprobación.
- La documentación de arranque está creada. Todavía no hay app Flutter ni configuración Supabase.
- Flutter 3.35.3 y Dart 3.9.2 están instalados. No se cambió su versión.
- Para Android faltan Command-line Tools y revisar/aceptar las licencias del SDK.
- GitHub CLI no está en PATH. Se puede trabajar con Git y la interfaz web.
- No se realizaron commit, push, creación de issues, despliegues ni configuración de cuentas externas durante la preparación de esta guía.

## 4. Chat 00: proyecto y estructura

Por decisión del17 de octubre de2026, la aplicación Flutter existente se traslada
a `apps/mobile` y la web se ubica en `apps/platform`. Sustituye la ubicación de
Flutter en la raíz acordada el6 de octubre, sin recrear proyectos ni cambiar
identificadores. Se conservan presentation/domain/data por funcionalidad, MVVM
y Riverpod en móvil. [ADR-059](decisiones/059-directorios-apps-platform-mobile.md),
[ESTADO](ESTADO.md) y [CONFIGURACION](CONFIGURACION.md) conservan validación y comandos.

Orden de trabajo:

Decisión del 7 de octubre de 2026: mantener una base de arquitectura sólida independientemente del alcance MVP. Dominio organiza `entities`, `repositories` y `use_cases`; los ViewModels consumen casos de uso y data implementa los contratos. Se prepara ejecución F5 con configuración local para no repetir argumentos durante el desarrollo. No se amplía el alcance funcional de HU-01 ni se añaden servicios al backend.

Revisión de presentation/data del mismo día: presentación organiza screens/view_models/state/widgets y observa un estado único; data separa data_sources/models/repositories, encapsula el SDK y transforma fallos en errores de dominio. Providers declaran contratos y bootstrap inyecta implementaciones. Añadir pruebas de recuperación tras error y liberación de suscripciones a los criterios técnicos de cada flujo observable. Detalles en [ARQUITECTURA.md](ARQUITECTURA.md).

La base de Inicio y Acceso incorpora la dirección visual de [DISENO_UI.md](DISENO_UI.md): tarjetas redondeadas, marca, ilustración y acciones principales. El acceso se ajustó después al mockup de login e incorporó correo/contraseña y Google, con SQL de perfiles preparado. Registro y recuperación están implementados localmente; edición de perfil y validación remota siguen pendientes en HU-01; los demás recorridos se incorporan en sus sprints.

1. Leer `AGENTS.md` y los documentos; comprobar Git y conservar los archivos existentes.
2. Completar el entorno Android. En Android Studio, abrir SDK Manager y revisar SDK Tools: instalar **Android SDK Command-line Tools**, comprobar Platform-Tools, Build-Tools y una plataforma compatible. El usuario revisa los términos con `flutter doctor --android-licenses`. Volver a ejecutar `flutter doctor` y detectar un teléfono o emulador. [Configuración Android oficial](https://docs.flutter.dev/platform-integration/android/setup).
3. Elegir una versión de Flutter y dependencias compatibles. La instalada es un punto de partida; cualquier actualización se evalúa y documenta.
4. Conservar la app existente en `apps/mobile` y organizar `lib/app`, `lib/core` y funcionalidades con `presentation`, `domain` y `data`. Revisar el identificador Android provisional antes de distribuir.
5. Incorporar inicialmente Riverpod, go_router y supabase_flutter. Añadir Drift/SQLite cuando se implemente el almacenamiento local. Cada paquete debe resolver una necesidad concreta.
6. Preparar configuración con ejemplos sin credenciales. Verificar la app con una pantalla inicial y estado explícito de configuración si Supabase aún no existe.
7. Crear CI con formato, análisis y pruebas pertinentes. Documentar los comandos y fijar la versión de Flutter usada por CI.
8. Revisar los archivos, realizar el primer commit y publicar la base cuando la solicitud de ejecución incluya esas acciones.

La app ya existe: no ejecutar `flutter create` sobre ella. Para trabajar desde la raíz:

```powershell
Set-Location apps/mobile
flutter pub get --enforce-lockfile
```

El identificador conservado es `com.example.flutter_application_entrehuellas`; sigue pendiente elegir el definitivo antes de distribuir.

**Criterio de salida:** app inicial ejecutada en Android, estructura comprensible, versión registrada, comprobaciones pertinentes pasando y procedimiento para configurar Supabase documentado. Si Android sigue bloqueado, registrar lo que se verificó por otra vía y mantener el build Android pendiente.

### Prompt listo para pegar en el chat 00

```text
Configura el proyecto Entre Huellas en la carpeta local de este proyecto.
Lee AGENTS.md, docs/ARQUITECTURA.md, docs/ESTADO.md y la sección 4 de docs/GUIA_MVP.md.

El repositorio es https://github.com/srg-cp/entrehuellas. Origin y la rama main ya fueron configurados; compruébalos sin volver a clonar encima de la carpeta.

Continúa sobre la app Flutter existente en apps/mobile. Lee docs/REGLAS_ARQUITECTURA.md y conserva las capas presentation, domain y data por funcionalidad, MVVM, Riverpod, casos de uso, repositorios, go_router y supabase_flutter. Mantén Supabase como backend del MVP. Prepara configuración de ejemplo sin secretos, el deep link entrehuellas://login-callback/ y CI para formato, análisis y pruebas pertinentes.

Revisa Flutter y Android. Ya se detectaron Command-line Tools y licencias pendientes. Ayúdame a resolver los pasos que requieran mi intervención mientras avanzas con lo independiente. Registra la versión de SDK y el identificador Android elegidos.

Implementa y verifica una pantalla inicial. Conserva la documentación existente. Cuando las comprobaciones pertinentes pasen, realiza el primer commit y publícalo en mi repositorio; no despliegues servicios. Si la autenticación bloquea el push, deja el commit listo y explica el paso pendiente sin pedir credenciales en el chat.

Actualiza docs/ESTADO.md con cambios, pruebas, bloqueos y el siguiente paso. Indica si la ejecución/build Android fue realmente verificada.
```

## 5. Sprints e historias del MVP

El alcance implementado y el funcionamiento de cada módulo se consultan en
[Funcionalidades](funcionalidades/README.md). Mantener sus fichas en cada
incremento, incluyendo reglas, persistencia, errores, activación y validación;
la existencia de una ficha no implica cierre de la HU ni ampliación del MVP.

Se conserva la numeración original para relacionar implementación, informe académico y pruebas. El chat 00 prepara la base técnica que el plan original situaba dentro de S1.

### S1 - Acceso y cuenta

- Ampliación autorizada el17 de octubre de2026 de **HU-01 / RF-01,34 / issue #1**:
  acceso con Facebook además de correo/Google, conservando sesión y onboarding
  por cuenta. Código local y [guía de activación](LOGIN_FACEBOOK.md); Meta/Auth
  y prueba Android pendientes, sin cierre automático de historia.

- Dirección visual obligatoria: [REGLAS_UI_UX.md](REGLAS_UI_UX.md), basada en acceso/cuenta/OTP/contraseña aprobados. Retirado Inicio anterior; destino provisional conserva bienvenida y cierre real, sin ampliar funcionalidades.

- **HU-01 / RF-01,34:** acceso por correo/Google, sesión, perfil y gestión de cuenta. Inicio válido crea o recupera un único perfil; otro usuario no puede editarlo. Solicitud de baja trazable y exportación básica de los datos del usuario según el alcance acordado.
- Crear o identificar el proyecto Supabase de desarrollo, configurar Auth y versionar esquema, permisos y migraciones. Las fuentes SQL se organizan en `database` según [su convención](../database/README.md); preparar la generación ordenada de migraciones antes del primer despliegue.
- Comprobar sesión inválida, cierre de sesión y acceso cruzado con dos cuentas. Resolver los enlaces de retorno/confirmación de correo necesarios para Android.
- **Demo:** entrar, ver perfil, cerrar sesión y verificar permisos.
- Onboarding actualizado el 8 de octubre: sin Omitir, tres indicadores de progreso y botón de ancho completo con flecha. La cuenta pendiente entra a la app tras Comenzar en la tercera etapa; un fallo de guardado permite reintentar. Se conservan finalizaciones anteriores.
- Incremento de registro: Crear cuenta desde login, validar cuatro campos, registrar con Supabase Auth, confirmar por código de seis dígitos o recibir sesión si Auth autoconfirma, reenviar con espera de 60 segundos y entrar al onboarding solo con sesión. Sin casilla de Términos/Privacidad hasta contar con documentos, por decisión del usuario. Implementación local preparada; validar entrega SMTP y callback real en Android antes de dar por cerrado HU-01.
- Incremento de recuperación, 8 de octubre: desde ¿Olvidaste tu contraseña?, solicitar código por correo, mostrar seis casillas sin revelar existencia de cuenta y reenviar tras 60 segundos. La verificación OTP de recuperación abre Nueva contraseña antes de onboarding/Inicio; valida contraseña/confirmación y política del servidor. Guardar muestra éxito; al regresar o cancelar se cierra la sesión de recuperación. Implementación y pruebas locales; quedan SMTP, verificación real de códigos leídos en PC e introducidos en Android, códigos vencidos y reingreso con contraseña nueva. Sin nuevas tablas.

Prompt:

```text
Implementa S1 de Entre Huellas según docs/GUIA_MVP.md: HU-01, RF-01 y RF-34. Lee AGENTS.md y docs/ESTADO.md. Usa Supabase Auth y repositorios; versiona esquema y políticas. Implementa cuenta y sesión con criterios verificables. Si faltan URL/configuración del proyecto, solicita solo lo necesario y avanza con código, migraciones y pruebas independientes. Actualiza el estado con la demo y la validación real.
```

Refinamiento20/10 de HU-01/05/06/07, RF-01/05/06/13: selector de país con bandera/prefijo en perfil y contacto por caso, ADR-117. Número nacional separado y búsqueda local; mismo contrato internacional y consentimiento, sin SQL adicional ni nueva HU/issue.

### S2 - Mascotas, fotos y zonas

- **HU-02 / RF-02,16:** guardar zonas, radio y preferencias; admitir selección manual con GPS denegado y conservarlas tras reiniciar.
- **HU-03 / RF-03:** registrar y editar una mascota propia con los campos mínimos; acceso de otro usuario rechazado.
- **HU-04 / RF-03:** gestionar fotos, principal y miniaturas; controlar formato/tamaño, políticas de Storage y eliminación de EXIF en los bytes públicos.
- La solución de procesamiento de fotos debe comprobarse con los límites del runtime antes de cerrar la historia. Validar al cargar desde cámara o galería y con permisos denegados.
- **Demo:** dos usuarios, mascota privada al editar, fotografía pública permitida y zona manual persistente.

Prompt:

```text
Implementa S2 de Entre Huellas: HU-02 a HU-04 y sus criterios en docs/GUIA_MVP.md. Lee las instrucciones y el estado. Crea mascotas, fotos y zonas con Supabase y permisos por propietario. Incluye alternativas cuando se deniega GPS/cámara y comprueba los bytes públicos de las fotos. Verifica acceso cruzado y persistencia. Actualiza docs/ESTADO.md con resultados y decisiones.
```

### S3 - Casos perdidos y encontrados

Incremento autorizado20/10 de HU-05/06/07, RF-05/06/13: nueva ficha pública móvil por tarjetas glass (ADR-113) y ampliación explícita de contacto por caso (ADR-114). Registro/edición/retiro del contacto desde la ficha publicada, con consentimiento separado para foto y sin repetir publicación. Plan031 requiere030, activación hosted pendiente. Vistas previas conservan ImmersivePhotoSheet. Sin issue nuevo ni cierre de historias; sin contacto en QR/web anónima/cartel.


Conservación20/10 de fichas/vistas previas HU-05/06/07: diseño renombrado a ImmersivePhotoSheet (Ficha fotográfica inmersiva), ADR-112. Sin nueva HU/issue, ampliación de alcance o cierre de historias. Uso futuro documentado; nuevo diseño glass por tarjetas aún sin implementar.

Refinamiento20/10 de HU-07.2 / RF-13 / issue #33: panel de mapa minimizable
hasta Ver ficha, apertura50% y límite adaptable por contenido/texto; créditos
compactos junto al panel. ADR-106, sin alcance/SQL/permisos nuevos.

Refinamiento20/10 transversal de mapas existentes, HU-07.2/RF-13/issue #33:
estilo intermedio Reportar/Explorar global móvil y web con adaptadores comunes,
ADR-104. Sin nuevas operaciones ni paridad funcional web/móvil; no crea nuevas
pantallas, historias o cambios SQL. Activación web del proveedor por entorno.

Refinamiento20/10 de HU-07.2 / RF-13 / issue #33: aplicar propuesta visual
aprobada del mapa con resumen compacto, miniatura mayor, rasgos bajo nombre,
dos accesos al mismo detalle y acabado azul compartido con navegación.
Mapa sin disco gris del radio, pines con símbolo oficial. ADR-103 sustituye
composición anterior, sin ampliación del MVP ni nuevas operaciones/backend.

Refinamiento19/10 HU-07.1/07.2, RF-13, issues #32/#33: acceso flotante Mapa
sustituye Lista/Mapa, según propuesta3 elegida por el usuario. Consulta, ruta
y retorno conservados; sin ampliación del MVP. ADR-101.

Corrección19/10 de HU-07.1/07.2, RF-13, issues #32/#33: resumen del mapa con
especie y foto mayor adaptable, sin raza/estado/conteo textual. Pines individuales
separados visualmente ante solapamiento; no cambia coordenadas, filtros o permisos.
Sin agrupación/contador/selector de coincidencias. Mismo alcance y backend;
[ADR-099](decisiones/099-mapa-pines-individuales-y-resumen-fotografico.md).

Refinamiento19/10 de HU-07.1/HU-07.2, RF-13, issues #32/#33: filtros y Ubicación
solo en Explorar; mapa consume la misma búsqueda y muestra el resumen del pin
en el panel con Ver ficha. Sustituye filtros inferiores y callout, conserva
consulta/paginación/permisos y no amplía el MVP. Validación local aprobada;
revisión Android del ajuste pendiente. [ADR-097](decisiones/097-explorar-filtros-unicos-y-resumen-en-mapa.md).

Refinamiento18/10 de HU-07.2/RF-13/issue #33: pines de only-black.svg y vista
previa fotográfica con tamaño/fecha mediante lectura pública por caso. Raza
ausente en el producto se indica como no registrada; capturarla/persistirla no
se implementa en este incremento. Sin SQL/permisos nuevos. ADR-062.

Refinamiento18/10/2026 de HU-07.2/RF-13/issue #33: panel del mapa limitado a
42–90%, resistencia visual bajo el mínimo, retorno glass retirado al expandir
y sin título redundante. No cambia consultas, permisos ni alcance del MVP.
[ADR-061](decisiones/061-mapa-altura-minima-y-retorno-progresivo.md).

Revisión posterior16 de octubre de HU-07.2/RF-13/issue #33: el panel inferior del mapa contiene filtros en borrador y Aplicar; el caso se abre desde una etiqueta junto al pin. Reutiliza el formulario existente, conserva consulta compartida y no busca por editar/GPS/pan hasta confirmar. [ADR-056](decisiones/056-mapa-filtros-inferiores-y-acceso-en-pin.md) sustituye la ficha inferior de ADR-055, sin ampliar alcance ni cambiar SQL/permisos.

Refinamiento autorizado16 de octubre de HU-07.2/RF-13/issue #33: Mapa abre pantalla propia mediante expansión desde su opción, mapa a todo viewport y panel inferior deslizable con una ficha de ancho completo. Consulta/páginas compartidas con lista; sin nueva operación de producto ni SQL. [ADR-055](decisiones/055-explorar-mapa-inmersivo-y-panel-deslizable.md) sustituye la alternancia integrada de ADR-052. No cierra automáticamente historia ni implica publicación.

Incremento16 de octubre: HU-07.2 / RF-13 / issue #33 implementada localmente en feature/explore-case-map. Lista/Mapa comparte filtros, páginas y contrato019; marcadores públicos aproximados agrupados por coordenada, tarjetas/fichas existentes y recuperación de teselas. Pan/zoom no modifica la búsqueda. Sin SQL nuevo, QR, push u offline; demo Android/hosted y cierre de historia pendientes. Véanse [ficha](funcionalidades/explorar.md) y [ADR-052](decisiones/052-explorar-mapa-de-resultados.md). Patch021 de Guardados ya aplicado según confirmación del usuario; sustituye las notas antiguas de activación pendiente.

Ampliación posterior16 de octubre: listado Guardados dentro de Explorar (HU-07/RF-13) y Ciudad del perfil (HU-01.7/RF-01) mediante el mismo buscador de Ubicación. Plan021 solo para índice/RPC de listado privado paginado, sin modificar020 aplicado según usuario. Ciudad reutiliza places y exige elegir sugerencia para texto nuevo; sin SQL nuevo de perfil ni certificado oficial de ciudad. Sin seguimiento/offline o cierre de historias; análisis limpio, pruebas omitidas por instrucción y021/Android pendientes. [ADR-051](decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

Ampliación explícita solicitada el16 de octubre de2026 de HU-07/RF-13: guardar/quitar casos por cuenta desde marcador superior derecho de la ficha. saved_cases/plan020, sin issue asignado ni cierre de historia. Recorrido por ficha; sin listado propio, seguimiento/push ni descarga offline HU-15.3. [Ficha](funcionalidades/casos-guardados.md), [ADR-050](decisiones/050-casos-guardados-por-cuenta.md). Validación/aplicación020 y Android pendientes; sin pruebas ejecutadas por petición del usuario.

- **HU-05 / RF-05:** publicar perdido con fecha y zona; restricción de un caso activo por mascota y creación idempotente.
- **HU-06 / RF-06:** publicar encontrado sin propietario conocido ni `pet_id` obligatorio.
- **HU-07 / RF-13:** lista y mapa con filtros coherentes y paginación; coordenadas públicas aproximadas y datos privados protegidos.
- Seleccionar el proveedor de mapas por requisitos y condiciones; habilitar PostGIS y consultar cercanía en servidor.
- Preparar desde este sprint claves estables de envío para que S6 pueda implementar la cola local sin cambiar el contrato.
- **Demo:** publicar ambos tipos, repetir un envío, filtrar y comprobar respuestas públicas.

Prompt:

```text
Implementa S3: HU-05 a HU-07 de docs/GUIA_MVP.md. Usa repositorios, Supabase y PostGIS. Cubre perdido/encontrado, lista/mapa, filtros y paginación. Impide dos casos perdidos activos por mascota, deduplica reintentos en servidor y protege coordenadas privadas. Verifica concurrencia y privacidad, documenta el proveedor de mapas elegido y actualiza el estado.
```

### S4 - Cartel, QR y avistamientos

23/10, refinamiento explícito de ficha pública, ADR-133: Favoritos, Seguir caso y
Bloquear pasan al panel Compartir ficha. Cabecera Volver/Compartir con geometría
compartida con entidades. Sin cambios de permisos/datos ni cierre de historias;
no se retiran los recorridos de avistamiento discutidos sin instrucción de cambio.

Ampliación explícita20/10 de HU-07/HU-08, RF-08/13/37: Compartir ficha abre panel blanco sin X; copiar enlace, WhatsApp, Facebook y PDF público por lectores autorizados de búsquedas activas. Denunciar reutiliza el formulario existente. RPC prepare_case_share/plan032, sin otorgar permisos de autor o modificar el contrato QR. Activación remota y prueba de aplicaciones Android pendientes; ADR-115. Sin issue nuevo ni cierre de historias.


18/10/2026, HU-10.2 / RF-11 / issue #37: envío Android desde ficha abierta,
fecha/hora real, comentario/foto opcionales, GPS con alternativa manual y galería
alternativa a cámara. Destino fijo, formulario conservado y UUID/payload congelados
ante respuesta ambigua. Servidor Nuxt verifica sesión y reutiliza el pipeline web;
plan025 comparte persistencia/validación SQL y conserva evidencia privada sin QR
previo. No sustituye los avisos públicos/custodia anteriores ni adelanta HU-11.
Implementación local;025/servidor y demo autenticada pendientes. El usuario ya
confirmó024 y funcionamiento web; no se vuelven a considerar pendientes de HU-10.1.
[Ficha Android](funcionalidades/avistamientos-android.md),
[ADR-065](decisiones/065-avistamientos-android-y-persistencia-compartida.md).

18/10/2026, HU-10.1 / RF-11 / issue #36: formulario de avistamiento sin cuenta
desde QR activo, fecha/hora y punto manual/GPS con precisión, comentario/foto
opcionales, saneamiento servidor sin EXIF y reintento idempotente. Plan024/RPC
solo servidor, límites persistentes por pseudónimo/caso; evidencia y punto exacto
privados. No crea reportero autenticado, cronología HU-11, envío móvil HU-10.2
ni push/offline. WebShell/QR/formulario adoptan ADR-063. Implementación local;
aplicación024, despliegue y demo con otro teléfono pendientes. [Ficha](funcionalidades/avistamientos-web.md),
[ADR-064](decisiones/064-avistamientos-publicos-idempotentes.md).

18/10/2026: el usuario aprueba la landing final y solicita que sea la referencia
UI/UX de toda la web. [Reglas web](REGLAS_UI_UX_WEB.md) y
[ADR-063](decisiones/063-landing-como-referencia-ui-ux-web.md) consolidan esa base
para público/usuarios/administración. Cambio documental, sin nuevas HU/RF/issues,
sin cierre de historias ni implementación anticipada de paneles o adaptación QR.

Integración17/10/2026 solicitada por usuario: landing de feature/landing-page
portada de React a Vue en / de apps/platform, junto a QR /c/<token>. Conserva
referencia y controles reales; sin nuevas HU/RF/issues ni cierre de HU-09/HU-10.
Mismo despliegue, sin SQL ni dependencia nueva. [Ficha](funcionalidades/landing-page.md),
[ADR-060](decisiones/060-landing-integrada-en-platform-vue.md).

17/10/2026: usuario adopta una sola web Vue/Nuxt/TypeScript para público,
usuarios y administración por roles, conservando Flutter móvil. Primer incremento
en feature/vue-nuxt-web migra consulta QR a Vue/SSR con mismos contratos y URLs;
no amplía este paso a login/admin/HU-10 ni modifica la rama de landing en curso.
No hay nueva migración SQL. [ADR-058](decisiones/058-web-unica-vue-nuxt-y-roles.md).

Incremento16 de octubre, feature/public-qr-case-web: HU-09/RF-09/#9 implementa
consulta web ligera y contrato privado de resolución/fotos, plan023. Estados
activo/cerrado/neutral, galería, compartir/copia y actualización real. Falta
HU-10.1/#36 para formulario y validación hosted/TLS/QR desde otro teléfono;
no se cierra la historia. PUBLIC_CASE_WEB_READY sigue false. Sin despliegue/APK.
[Ficha](funcionalidades/ficha-publica-qr.md), [ADR-057](decisiones/057-ficha-qr-web-y-proxy-privado.md).

Incremento16 de octubre: por instrucción del usuario se deja la generación de APK para más adelante y se inicia feature/pet-poster-qr, HU-08.1/#34 y HU-08.2/#35. Cartel A4 público, QR opaco estable, impresión/guardado y compartir PDF/enlace; fuente077–079/plan022. El usuario indica dominio entrehuellas.kormind.com; la generación se activa solo después de aplicar022 y disponer de HU-09 en ese dominio. La raíz responde404 al comprobarla; no se entrega ni despliega web en HU-08. [Ficha](funcionalidades/carteles-qr.md), [ADR-053](decisiones/053-carteles-pdf-y-enlaces-qr.md). Sin ampliación a push/offline/moderación ni cierre automático de historias.

- **HU-08 / RF-08,37:** cartel PDF legible, QR y compartir. Se puede generar en Flutter para el MVP; conservar enlace estable y permitir reintento de la generación.
- **HU-09 / RF-09:** crear `apps/platform` cuando haga falta; web ligera que abre el QR y muestra estado sin instalar la app. Token revocado no revela identidad privada.
- **HU-10 / RF-11:** avistamiento desde web/app con hora del evento y punto manual, foto opcional; rechazo de fecha futura y deduplicación del envío.
- El flujo público tiene permisos acotados y validación de abuso en servidor. Acordar hosting y URL estable antes de imprimir un QR que se usará fuera de pruebas.
- **Demo:** escanear en un segundo teléfono sin app y reportar; comprobar la persistencia y la separación de campos públicos/privados.

Prompt:

```text
Implementa S4: HU-08 a HU-10 de docs/GUIA_MVP.md. Crea cartel PDF/QR y una web pública ligera en apps/platform. El visitante debe consultar y reportar sin instalar Flutter. Implementa tokens revocables, punto manual, hora observada, permisos públicos limitados, controles de abuso y reintentos idempotentes. Prepara el resultado para revisar y documenta la configuración/hosting pendiente antes de publicar. Verifica el recorrido con otro teléfono y actualiza el estado.
```

### S5 - Seguimiento, alertas y cierre

18/10/2026: HU-13/#13 implementada localmente: cierre por responsable con
actor/fecha/motivo/evidencia testimonial opcional privados, recibo estable,
transacción con historial/contador/cancelación de difusión pendiente y consulta
desde ficha resuelta. QR existente y rechazo de avistamientos consumen estado
vigente; episodio nuevo conserva el anterior. Plan028 después de027 confirmado;
no cerrar historia antes de activar y validar Android/Supabase reales. FCM
continúa pospuesto (ADR-068). [Ficha](funcionalidades/cierre-y-recuperacion.md),
[ADR-069](decisiones/069-cierre-recuperacion-auditado.md).


**Alcance vigente por instrucción del usuario18/10/2026:** FCM e implementación
Firebase quedan pospuestos (HU-12.3/#42). El incremento activo HU-12 comprende
HU-12.1/#40 y HU-12.2/#41, seguimiento/bandeja con Supabase.027 ya aplicado
según usuario; no se reaplica. Sin configuración Firebase, registro de teléfono,
despliegue Edge ni cron de push. La activación inmediata descrita en las notas,
lista y prompt anteriores de planificación queda sustituida por
[ADR-068](decisiones/068-posponer-fcm-firebase.md). No cerrar HU-12.3 por este recorte.

18/10/2026: después de la confirmación operativa de HU-11 registrada en ESTADO,
se implementa localmente HU-12.1/#40, HU-12.2/#41 y HU-12.3/#42: seguimiento
explícito separado de Guardados, zonas propias, destinatarios en servidor,
bandeja paginada/leído y outbox transaccional con Edge FCM HTTP v1 y reintentos.
Plan027; no se reaplica026 confirmado. Configuración Firebase, planificador,
activación027, entrega y concurrencia hosted/Android pendientes; sin cierre
de historias por evidencia local. [Ficha](funcionalidades/seguimiento-y-alertas.md),
[ADR-067](decisiones/067-seguimiento-bandeja-y-push.md). Las notas de activación026
pendiente inmediatamente inferiores describen la entrega anterior, sustituida
por la confirmación más reciente del usuario en ESTADO.

18/10/2026: HU-11.1 / RF-14 / #38 y HU-11.2 / RF-12,14 / #39 implementadas
localmente en Android. Historial propio ordenado por hora del suceso, recepción
y tardíos separados, foto/punto privados y clasificación con motivo/actor/fecha
e historial paginado. RPC autorizadas, reintento idempotente y CAS; caso cerrado
solo lectura. No equivale a ubicación actual/recuperación. Plan026 después de025
confirmado por usuario; falta activar026 y demo autenticada/concurrencia reales.
Avisos públicos anteriores conservan su recorrido; no se migran ni se inventan
eventos. Sin push, offline o panel web nuevo. [Ficha](funcionalidades/cronologia-y-revision.md),
[ADR-066](decisiones/066-cronologia-y-revision-privada.md). Historias sin cerrar
ni acciones GitHub; siguiente incremento funcional HU-12 tras validar HU-11.

- **HU-11 / RF-12,14:** revisar avistamientos, guardar actor/motivo y ordenar cronología por hora real.
- **HU-12 / RF-17,18:** alcance activo HU-12.1/12.2: zonas/casos seguidos, destinatarios y bandeja persistente con Supabase. HU-12.3 (push/FCM/Firebase) pospuesta por el usuario, ADR-068; conservar el outbox027 aplicado sin activar entregas.
- **HU-13 / RF-07:** responsable autorizado cierra en una operación atómica con historial; QR actualizado y nuevas alertas de búsqueda detenidas.
- **Demo activa:** generar un evento nuevo, consultar/marcar leída en bandeja, verificar seguimiento/preferencias y aislamiento entre cuentas; cerrar, reabrir QR y comprobar que un usuario ajeno no puede cerrar. Demo FCM diferida junto con HU-12.3.

Prompt:

```text
Implementa el alcance activo S5: HU-11, HU-12.1/12.2 y HU-13 de docs/GUIA_MVP.md. Revisión/cronología, seguimiento, bandeja persistente y cierre autorizado con Supabase. Mantén las alertas deduplicadas y el outbox027 existente inactivo. FCM, Firebase y HU-12.3 quedan pospuestos por el usuario (ADR-068); no configurar otro proveedor ni desplegar el emisor. Valida permisos, reintentos y cierre concurrente, y actualiza QR/ESTADO.
```

### S6 - Moderación, offline y validación

23/10, resolución final remota HU-15.2: usuario aplica037/038;6/6 pruebas estrictas
en desarrollo aprobadas, incluidos campos/fotos distintos del mismo UUID,
deduplicación, permisos y revocación. La delegación interna omitida en037 queda
corregida por038 sin reescribir historia. Regresión final575/575 Flutter,
56/56 SQL después de038, análisis limpio,10 checks SQLite Android y recorrido
normal sin red→reinicio→reintento automático aprobados. Validación técnica de
HU-15.2 completada en emulador y desarrollo remoto; siguiente incremento HU-15.3.
Evidencia en ESTADO; las notas de activación pendiente siguientes son historial anterior.
Sin cierre de issue/épica ni inicio implícito de HU-15.3.

23/10, comprobación posterior: usuario aplica037; perdido devuelvePT409, pero
la búsqueda delegaba en un helper fuera del parche. Plan038/fuente124 completa
publish_found_case sin cambiar037 ni permisos. Cuatro SQL focalizadas pasan;
aplicación remota038 y nueva suite estricta pendientes. Sin nuevas HU/alcance.

23/10, hallazgo posterior al ciclo Android: repetir el mismo UUID con contenido
distinto agota timeout remoto por uso de40001 como conflicto de negocio. Plan037
y ADR-134 preparan PT409 para tres RPC de cola y compatibilidad Flutter; cuatro
SQL/20 Flutter focalizadas y575 Flutter/56 SQL completos posteriores pasan;
análisis limpio y APK actualizado instalado. Aplicación remota037 y suite estricta pendientes;
la evidencia previa siguiente no cierra esa validación ni autoriza omitirla.

23/10, validación posterior de HU-15.1/15.2:575 pruebas Flutter y55 SQL locales,
6 remotas con cuentas distintas y servidor real de desarrollo,10 comprobaciones
SQLite nativas y ciclo completo en app normal Android emulada (guardar/reiniciar
sin red, cola pendiente y publicación automática al recuperar red, mismo UUID y
sin duplicados). Sin migraciones/despliegue nuevo, teléfono físico o cierre en
GitHub. Sustituye los bloqueos anteriores para esos escenarios; límites y logs
en [ESTADO](ESTADO.md) y [envíos](funcionalidades/envios-pendientes.md).
Siguiente incremento funcional: HU-15.3; no iniciado por esta validación.

23/10: autorizado HU-15.2/#48/RF-32 sobre HU-15.1, que conserva su validación
Android pendiente. Cola SQLite por cuenta, reclamación y recibo durable, reintento
activo con backoff, rechazo manual y Perfil → Envíos; ADR-132. Sin SQL remoto,
servicio de segundo plano, cierre de historias ni caché de fichas HU-15.3.
[Evidencia y límites](funcionalidades/envios-pendientes.md).

23/10: autorizado HU-15.1/#47/RF-32. Borradores locales por cuenta en Android,
fotos, fecha parcial y comando estable; Perfil → Borradores. ADR-131 documenta
la recuperación de bienvenida confirmada ante fallo de transporte como dependencia
de entrada offline. Cola automática HU-15.2 y caché de fichas HU-15.3 conservan su
alcance separado. [Validación y límites](funcionalidades/borradores-locales.md).

23/10/2026: HU-14.2/RF-23/issue #44 implementada localmente en móvil/web:
bloquear/desbloquear cuentas desde contenido autorizado y lista propia en Perfil.
Alcance confirmado por el usuario: impedir nuevos avisos y avistamientos
autenticados y ocultar contacto/foto entre ambas cuentas; fichas/historial/denuncias
y QR anónimo conservan permisos. Sin chat ni suspensión. Plan034 después de033 y036 después de034;
activación/demo reales pendientes, sin cerrar historia ni épica.
[Ficha](funcionalidades/bloqueos-usuarios.md), [ADR-130](decisiones/130-bloqueos-de-interacciones-entre-cuentas.md).

Avance23/10, HU-14.4/#46/RF-33: implementada la vía mínima de apelación propia
con motivo/estado/respuesta en móvil/web, revisión autorizada solo en web,
historial e idempotencia privados en plan035. No cambia visibilidad al responder:
se conserva la operación auditada de moderación. Validación local y activación
pendiente en [la ficha](funcionalidades/apelaciones-moderacion.md); no cierra
HU-14, HU-14.2 ni la validación remota de esta derivada.

- **HU-14 / RF-22,23,33:** denuncia, bloqueo, ocultamiento por moderador con motivo y auditoría; vía de apelación mínima.
- **HU-15 / RF-32:** borrador y caché local con Drift/SQLite, cola de envíos y estados visibles. Cortar conexión y reiniciar no pierde el borrador; reenvío no duplica ni confirma publicación antes de respuesta del servidor.
- **HU-16 / RF-35,40:** métricas agregadas y controles administrativos mínimos, accesibles solo por roles autorizados. Definir con el usuario una interfaz mínima para esta operación.
- Probar el recorrido Android/web, permisos, reintentos, conectividad y errores principales. Ensayar recuperación de datos y archivos, preparar versión de prueba y manual de demo.
- **Demo:** recuperación completa, conexión interrumpida, moderación y métricas sin información privada.

Prompt:

```text
Completa S6 del MVP: HU-14 a HU-16 según docs/GUIA_MVP.md. Implementa moderación/bloqueo/auditoría, borradores/caché y cola SQLite, y métricas/administración mínimas. Verifica reinicio sin conexión, reenvío sin duplicados y permisos de usuario/visitante/moderador. Ejecuta el recorrido Android y web, documenta restauración y prepara distribución de prueba y demo. Corrige fallos bloqueantes y registra lo que no se verificó. Actualiza docs/ESTADO.md sin marcar completo trabajo pendiente.
```

La seguridad, pruebas y documentación acompañan cada sprint; S6 reúne la validación final.

## 6. GitHub con un flujo sencillo

Cada issue #1–#51 tiene su archivo en [backlog](backlog/README.md), con snapshot de criterios, estado y motivo. La clasificación está sincronizada entre etiquetas status y el campo Status nativo del [tablero EntreHuellas](https://github.com/users/srg-cp/projects/3/views/1). Distinguir Backlog de Ready, implementación de revisión y evidencia local de Done; actualizar tarjeta, etiqueta y documentación juntas. La sincronización inicial está comprobada y no es automática.

Usar `main` como base integrada y una rama por historia o conjunto coherente de cambios. Inicialmente no hace falta mantener una rama `develop` adicional. El repositorio local ya tiene commits; comprobar las referencias y la autenticación del remoto antes de publicar cambios. Los incrementos siguen ramas y pull requests según la autorización de cada tarea.

Crear un issue por HU y milestones S1-S6. La plantilla de historia está en `.github/ISSUE_TEMPLATE/historia.md`. No hace falta un tablero adicional para empezar; se puede añadir si mejora la coordinación.

Actualización del 8 de octubre de 2026: conservar las 16 HU originales y sus issues #1–#16. Doce pasan a historias agrupadoras; 35 derivadas HU-XX.n (#17–#51) y cuatro originales sin dividir forman 39 entregas ejecutables. Todas mantienen formato de historia de usuario y están asignadas a `srg-cp`. El [desglose versionado](BACKLOG_MVP.md) conserva RF, criterios, dependencias y validación. No sumar esfuerzo de agrupadoras y derivadas, ni reutilizar estimaciones originales como estimaciones nuevas. Cerrar una agrupadora solo después de sus derivadas y su validación integrada; los sprints siguen siendo objetivos. La reorganización no añade alcance funcional ni acredita criterios pendientes.

Precisión académica del mismo día: las 12 agrupadoras se identifican como **épicas** en GitHub; las otras 39 son **historias de usuario ejecutables** con escenarios específicos de validación. HU-XX.n es una convención documentada para conservar trazabilidad, no una exigencia universal. #44 (interacciones afectadas por bloqueo) y #51 (funciones controlables/interfaz administrativa) requieren refinamiento antes de comprometer implementación. #25 concreta la exportación básica como JSON UTF-8 de perfil y solicitudes/estados de baja propios. La prioridad se conserva como referencia de la HU original y las estimaciones deben acordarse por entrega; no se afirma adecuación a una rúbrica docente no recibida.

Ejemplos de ramas: `chore/project-setup`, `feat/hu-01-auth`, `feat/hu-05-lost-cases`, `fix/qr-revoked-token`. El número HU no es el número del issue.

Secuencia: issue con criterios -> rama -> implementación y comprobaciones -> commit -> push -> PR -> revisión -> integración. Para trabajo individual, revisar el diff y los resultados antes de integrar. [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

Ejemplo después de tener un `main` publicado y cuando la carpeta esté limpia. Si hay cambios pendientes, resolver su destino antes de cambiar de rama:

```powershell
git status
git switch main
git pull --ff-only origin main
git switch -c feat/hu-01-auth
```

Tras implementar, seleccionar los archivos del cambio con `git add <rutas>` y revisar `git diff --cached`. Luego:

```powershell
git commit -m "feat(auth): implementar acceso y sesión"
git push -u origin feat/hu-01-auth
```

Abrir la PR en GitHub utilizando `.github/pull_request_template.md`; vincular el issue real. Integrarla cuando sus criterios y checks estén resueltos. Después actualizar `main` local antes del siguiente incremento.

El repositorio ya tiene `origin`; no repetir `git remote add` ni clonar sobre la carpeta. Antes del primer push, confirmar identidad Git y autenticación. Usar el inicio de sesión del gestor de credenciales o herramientas de GitHub; mantener tokens fuera de mensajes y archivos versionados.

Los comandos de la guía son pasos para ejecutar en los chats correspondientes; su presencia no significa que ya se ejecutaron. El primer prompt autoriza explícitamente commit/push. Las siguientes tareas deben indicar las acciones de GitHub que se esperan.

## 7. Qué debe registrar cada chat

Al empezar: leer estado y comprobar rama/archivos. Al terminar: actualizar `docs/ESTADO.md` con:

```text
Sprint / HU:
Rama y commit, si existe:
Issues / PR, si existen:
Comportamiento completado:
Migraciones y configuración:
Pruebas ejecutadas y resultados:
Pendientes o bloqueos:
Decisiones nuevas:
Siguiente paso concreto:
```

Una historia está terminada cuando sus criterios están verificados, los permisos y errores pertinentes están cubiertos, los cambios de datos están versionados y se puede demostrar el resultado. Una interfaz con datos simulados se identifica como tal; no equivale al flujo integrado.

Para trabajos de implementación con Flutter, ejecutar según corresponda desde `apps/mobile`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Usar `test` cuando exista; crear pruebas para comportamientos relevantes. El build Android y las pruebas en teléfono/emulador se realizan al cerrar incrementos que los requieran. Las comprobaciones del cliente no sustituyen pruebas de RLS, restricciones y RPC con usuarios distintos.

Las fuentes SQL se guardan en `database` por objeto y con numeración global; las migraciones de despliegue se generan en `supabase/migrations`, según [ADR-002](decisiones/002-organizacion-database.md). La generación está preparada mediante `database/scripts/Build-Migration.ps1`; validar migración y permisos en desarrollo antes de desplegar. Elegir en S1 el flujo posterior de CLI/entornos. El stack local completo necesita sus dependencias propias y no es condición para redactar las fuentes iniciales. [Migraciones oficiales](https://supabase.com/docs/guides/local-development/database-migrations).

## 8. Prompt para una historia independiente

```text
Trabaja en la historia HU-XX del sprint Sx de Entre Huellas.
Lee AGENTS.md, docs/REGLAS_ARQUITECTURA.md, docs/ESTADO.md, docs/ARQUITECTURA.md y los criterios de docs/GUIA_MVP.md.
Issue de GitHub: [enlace si existe]. Rama: [rama, si ya está creada].
Implementa el comportamiento completo con Supabase y validación pertinente.
Conserva el trabajo existente y registra pruebas y pendientes.
Actualiza docs/ESTADO.md para que el siguiente chat pueda continuar.
Acciones GitHub autorizadas en esta tarea: [indicar commit, push, issue o PR que se espera].
```

Si la tarea implica varios chats activos, acordar quién integra y usar worktrees. Para el arranque, mantener una sola implementación activa reduce el trabajo de integración.

## 9. Próximo paso inmediato

Completar herramientas Android, conectar un teléfono/emulador y validar apertura del deep link sobre la base del chat 00. Identificar el proyecto Supabase de desarrollo e iniciar **01 - Acceso y cuenta**, HU-01 / RF-01,34. El ingreso por correo/Google ya está implementado y el SQL de perfiles preparado; aplicar y validar en desarrollo, y completar registro, recuperación y perfil en HU-01. Las acciones GitHub requieren autorización en la tarea actual.

### Incremento de HU-01, 7 de octubre de 2026

Ingreso por correo/contraseña y Google implementado con casos de uso, repositorios y ViewModel. Fuentes de perfil 001–007, plan y generador de migración preparados. Se conserva HU-01 / RF-01,34 (issue GitHub #1) abierta: falta aplicar y comprobar SQL/RLS, ejecutar el retorno OAuth real y completar registro, recuperación y perfil. Apple está retirado de la interfaz por instrucción del usuario; no amplía los criterios de este incremento. Procedimiento: [CONFIGURACION.md](CONFIGURACION.md) y [database/README.md](../database/README.md).

La entrada manual del esquema de perfiles es ahora `database/run_all.sql`, generada y repetible. Seguir [ADR-003](decisiones/003-ejecucion-sql-idempotente.md); no reemplaza migraciones ni amplía las funcionalidades de HU-01. Al añadir otro incremento, revisar su ejecución repetida y sus permisos antes de ampliar el generador.

### Corrección del recorrido de acceso

Por instrucción del usuario, el orden es login → onboarding de tres pasos → app. No hay bienvenida pública anterior al login ni pantalla intermedia de sesión activa. El onboarding se muestra hasta completarlo u omitirlo y su finalización pertenece a la cuenta, no a la instalación. El retorno de una sesión existente que ya lo completó abre la app directamente. Este incremento de HU-01 incorpora la persistencia y RPC de finalización; no agrega funcionalidades de mascotas, registro o perfil fuera del alcance actual.

### Diseño navegable de Inicio, 8 de octubre de 2026

Por aprobación explícita del usuario, Inicio incorpora cápsula liquid glass (Inicio, Explorar, Mis mascotas, Perfil), botón Reportar separado y panel con los dos tipos de reporte. Incremento de presentación sobre el destino autenticado: no altera el alcance ni completa historias de mascotas/casos/alertas. Sus módulos muestran disponibilidad pendiente; no se simulan datos ni publicación. El cierre de sesión real permanece en Perfil; login/onboarding y permisos conservan sus criterios. Composición y verificación en REGLAS_UI_UX, DISENO_UI y ESTADO.

### Incremento de Perfil — HU-01.7 / RF-01, issue #23

Implementación local de consulta/edición de nombre visible y ciudad desde Perfil, con persistencia Supabase, validación de campos opcionales, respuesta confirmada, conservación del formulario ante fallos y recuperación. Usa esquema y permisos 001–009 existentes; no amplía a baja/exportación ni inicia mascotas. Debe demostrarse con dos cuentas autenticadas y Android antes de cerrar los criterios remotos. La prueba anónima remota y pruebas PostgreSQL locales no sustituyen esa demo. Procedimiento actualizado en CONFIGURACION.

### Cambio de acceso a Perfil

Por aprobación del usuario, Perfil pasa de sección inferior a ruta protegida superpuesta abierta desde avatar de cabecera. Conserva editor/persistencia de HU-01.7. Logo y alertas permanecen arriba; barra principal queda Inicio/Explorar/Mis mascotas. Se añade lectura de foto de metadatos propios cuando existe e iniciales de respaldo, sin cambiar esquema ni iniciar un flujo de subida de fotografías desde galería.

### Ampliación autorizada de HU-01.7: foto y correo

Usuario solicita foto propia desde galería y correo visible de solo lectura. ADR-008 registra este alcance de cuenta, separado de HU-04 (fotografías de mascotas). Incluye selección/normalización, bucket privado/políticas, reintento y recuperación de selección por cuenta. No se cierra issue #23 ni se modifica GitHub con esta entrega; falta activación SQL y demo integrada Android/Storage. No iniciar funciones de mascotas por este cambio.

### Incremento autorizado: Mis mascotas y ficha editable

Se implementa HU-03.1 / #28 y edición de metadatos de HU-03.2 / #29: nombre/especie, opcionales desconocidos, listado/detalle/edición privados, persistencia y reintentos con ID estable/versión. Fotografías (#30/#31), zonas y casos mantienen sus incrementos posteriores. #29 no se completa sin fotos ni #28 sin demo remota/Android. No cerrar historias por pruebas con sustitutos. Contratos y límites en ADR-010.

### Ampliación autorizada de ficha y galería — 9 de octubre de 2026

Usuario solicita retorno superior, tipo concreto para Otra especie, tamaño horizontal y fotos. ADR-012 amplía HU-03.1/#28, HU-03.2/#29 y parte de HU-04.1/#30: galería privada del dueño con hasta tres fotos, normalización cliente, persistencia/reintentos/retirada y permisos por mascota. Fotos confirmadas en ficha y portada de listado. No publicar originales ni completar miniaturas/sanitización servidor/cámara por este ajuste: esos criterios de #30 siguen pendientes junto con demo real Android/Supabase. Nuevo plan/patch 006, sin reescribir SQL anterior ni cambiar estados GitHub en esta tarea.

### Archivo reversible y eliminación definitiva — 9 de octubre de 2026

Por aceptación del usuario, HU-03 / RF-03 añade archivo/restauración como alternativa habitual al borrado. Se entrega ahora el contrato SQL008: conservar ficha/fotos, bloquear archivo con casos activos y borrado con historial. Sin ampliación a adopciones/reportes en este incremento. Integración Flutter y demo remota pendientes; S3 debe mantener indicadores de historia/casos activos bajo bloqueo en la misma transacción. Detalles en ADR-014 y CONFIGURACION.

## Ajuste solicitado de registro/edición de mascotas — 9 de octubre de 2026

HU-03 / RF-03 (issues#28/#29 separados de la numeración HU): nombre/especie/tamaño/edad/rasgos obligatorios al guardar, descripción1–200 con contador, sexo opcional con valor inicial y placeholder de especie no seleccionable. Selector de fotos privado de hasta160, conservando alcance HU-04.1/#30 y sus pendientes. Feedback del editor mediante shake danger y toast superior sin errores debajo, según ADR-016. Plan009 añade validación protegida de metadatos; preserva fichas antiguas y su ciclo de vida. No cierra HU/issues ni activa SQL remoto por pruebas locales.

### Fotos como borrador hasta confirmación — 9 de octubre de 2026

Corrección de HU-03.2/#29 y galería privada HU-04.1/#30: selección/retirada se mantienen locales hasta Registrar mascota/Guardar cambios; cancelar conserva fotos confirmadas. ADR-017 documenta reintento y límites del guardado parcial tras confirmación. No añade sincronización offline persistente, atomicidad de Storage ni migración SQL.

### Integración de archivo/restauración — 9 de octubre de 2026

HU-03 / RF-03 (issues #28/#29): Mis mascotas incorpora Activas/Archivadas y la ficha permite Archivar con confirmación o Restaurar, conservando fotos y metadatos. Eliminar sigue disponible por swipe y rechaza historial/casos activos mediante dominio y servidor. Los casos S3 siguen pendientes y deben mantener indicadores atómicamente según ADR-014. No añade SQL ni cierra automáticamente HU/issues: validación autenticada Android/Supabase y criterios restantes de fotos HU-04 siguen pendientes.

### Zonas de interés implementadas localmente — HU-02.1 / RF-02,16

Primer incremento de la rama `feature/interest-zones`: selección manual en mapa, radio0.1–50km, listado/edición/eliminación privados por cuenta y alternativa de coordenadas. Contrato versionado e idempotente en SQL036–039/plan010, según ADR-018. Sin GPS ni push; HU-02.2 se desarrolla como segundo incremento separado. Las pruebas locales no cierran issue#26 ni S2; patch010 aplicado según usuario del 10 de octubre y demo integrada con dos cuentas en Supabase/Android pendiente.

### Preferencias de alertas — HU-02.2 / issue #27

Rama `feature/alert-preferences`, segundo incremento de HU-02: recepción general, tipos perdidas/encontradas/novedades de casos y canales bandeja/push, conservados por cuenta. Recepción inicialmente pausada; pausar conserva elecciones y activar requiere tipo/canal. Contrato SQL040–043/plan011 privado/versionado según ADR-019. UI guarda selección y explica que recepción se habilitará con HU-12; sin GPS, permisos/tokens ni envío. No ampliar a email/SMS ni afirmar entrega push. Patch011 aplicado según confirmación del usuario; requiere demo Android/Supabase antes de cerrar criterios. Patch010 de zonas ya aplicado según usuario del 10 de octubre.

### Continuación de HU-04 — 10 de octubre de 2026

En codex/pet-photos se implementan cámara con alternativa de galería, procesamiento servidor de JPEG/miniaturas sin EXIF y selección explícita de principal, conservando borradores hasta Guardar y reemplazo determinista al retirar. SQL044–047/plan012 y Edge pet-photo-process preparados; activación conjunta y demo hosted/Android pendientes. ADR-020 mantiene originales y derivados privados: publicación en S3 solo mediante proyección autorizada de bytes verificados. No añade reportes ni entrega alertas; el siguiente incremento funcional sigue HU-05 tras activar/verificar fotos. Historias no cerradas por evidencia local.

### Publicación de mascotas perdidas — HU-05 / RF-05, issue #5

Implementación local en feature/lost-pet-cases: formulario por mascota propia, fotos elegidas, fecha/hora y punto manual, vista previa pública y Mis casos. Publicación autorizada/versionada/idempotente en SQL048–051/plan013 con caso activo único e historial/contador atómicos. Punto/referencia privados y derivados seleccionados verificados con lectura pública limitada; ADR-021 detalla la proyección. La ficha móvil es protegida; web QR, encontrados, exploración/cercanía PostGIS y cierre siguen sus historias posteriores. Activación patch013 y demo real pendientes; no se cierra HU-05 por evidencia local. [Ficha](funcionalidades/casos-perdidos.md).

### Incremento local de S3: HU-06 / RF-06 — 10 de octubre de 2026

Reporte encontrado implementado sin perfil de mascota ni dueño conocido: formulario, fotos seguras, ubicación manual privada/pública aproximada, custodia opcional, vista previa, publicación idempotente, ficha pública y Mis encontrados con limpieza de drafts. Fuentes052–055/plan014 y extensión del handler pet-photo-process requieren activación conjunta. Sin asociación automática ni ampliación a adopción, entrega, QR, exploración o alertas. Persistencia de borrador offline sigue HU-15. [Ficha](funcionalidades/casos-encontrados.md), [ADR-022](decisiones/022-publicacion-casos-encontrados.md) y ESTADO separan implementación local de cierre/demo remota.


## Feedback de reportes: corrección del 10 de octubre de 2026

Por instrucción explícita del usuario, los mensajes de error, validación y resultado se muestran en el toast superior compartido, sin texto contextual dentro de la pantalla ni debajo de campos/acciones. Esta instrucción sustituye las restricciones anteriores que reservaban el toast a excepciones y exigían feedback contextual. Etiquetas, datos, estados e instrucciones de privacidad se mantienen. El incremento adapta los flujos de reportes perdidos/encontrados; conserva invalid/ShakeField, acciones de reintento y ciclo de vida del aviso. Las demás funcionalidades existentes se adaptarán al intervenir sus flujos; no se afirma una migración global completada. Véase [ADR-023](decisiones/023-feedback-reportes-toast-superior.md).


## Reporte perdido: mapa y fotos compartidas — 10 de octubre de 2026

Por instrucción del usuario, HU-05 retira campos/lectura de coordenadas numéricas del formulario: selección manual en mapa sin GPS, preservando coordenadas privadas internamente. Fotos del formulario y vista previa reutilizan PhotoGalleryStrip/PhotoGalleryTile de core, extraídos de la galería de mascotas; misma geometría de detalle112–160, separación10, radio22 y scroll horizontal. Selección de fotos públicas pertenece al ViewModel del reporte, sin cambiar principal ni contenido privado de la mascota. No copiar galerías con disposición vertical al incorporar este recorrido.


## Vista previa de publicación inmersiva — 10 de octubre de 2026

Por referencia e instrucción explícita del usuario, perdidos/encontrados comparten CasePublicationPreview: fotografías protagonistas deslizables a ancho completo, indicador de foto, nombre/especie destacado y panel inferior GlassSurface con datos y acciones reales. CaseScreenShell conserva retorno glass, cabecera fuera de la transición, scroll y cover→stagger por etapa; se eliminan márgenes/cabecera de formulario solo en vista previa. La galería del formulario sigue usando PhotoGalleryStrip/PhotoGalleryTile; la vista previa sustituye sus tiles por el pager protagonista. primaryActionButtonStyle, LoadingShimmer y toast mantienen implementación única.

ExpandableDescription comparte contracción a dos líneas y expansión/contracción al tocar el texto, con AnimatedSize320ms/easeInOutCubic. Movimiento reducido presenta contenido inmediatamente. No reproduce el reveal ni cambia foto, borrador o envío al expandir. Se permite scroll y crecimiento con texto ampliado. Datos privados/funcionalidades de venta de la referencia no se añaden. Decisión y revisión en [ADR-024](decisiones/024-vista-previa-publicacion-inmersiva.md).


## Scroll continuo hasta el área del gesto — 10 de octubre de 2026

Por captura e instrucción del usuario, las páginas con scroll usan ScrollSafeArea de core: el viewport llega al borde inferior y no reserva una banda blanca fija con SafeArea(bottom:true). El espacio del gesto se suma al padding final del contenido y a los controles flotantes mediante bottomPadding; con teclado abierto se usa el inset efectivo, sin sumar una segunda franja. Mantener protegidos el último campo/botón y los márgenes laterales/superiores. La barra de navegación del sistema se solicita transparente, sin divisor ni contraste opaco; iconos oscuros sobre formularios y claros sobre vista previa fotográfica. Modales/onboarding mantienen sus áreas seguras específicas. Véase [ADR-025](decisiones/025-scroll-continuo-area-gesto.md).


Ficha pública y vista previa de perdidos/encontrados deben usar la misma composición CasePublicationPreview, con fotos grandes deslizables, panel glass y descripción expandible. Solo cambian título, texto preventivo y acciones según el estado del recorrido; no conservar una ficha con layout anterior. En el formulario de perdida se retiran Volver a consultar fotos y Mis casos; la recuperación de envíos ambiguos sigue disponible. Véase ADR-024 actualizado.


Actualización del 10 de octubre de 2026: por instrucción del usuario se retira el título glass flotante de la ficha/vista previa inmersiva; se conserva únicamente GlassNavigationButton para volver. Fecha del suceso a20px/negrita, con ajuste por texto ampliado. La ubicación se representa mediante ZoneMapPicker compartido en modo lectura, con la zona aproximada pública, círculo y sin marcador de punto exacto; formulario conserva edición del punto privado. Preview usa la proyección aproximada existente y ficha solo las coordenadas públicas del contrato. Errores del mapa usan toast superior compartido y conservan Reintentar mapa, sin mensajes bajo el mapa ni solicitud de coordenadas numéricas. La consulta no modifica ubicación ni captura el scroll vertical. Sustituye las indicaciones previas de título inmersivo y ubicación explicada solo por texto.


## Listas de casos consistentes con mascotas — 10 de octubre de 2026

Por instrucción del usuario, Mis casos/Mis reportes usan la implementación extraída de Mis mascotas a core: EntityCardContent/EntityCardSurface, SwipeActionCard, TwoOptionFilter, CollectionHeader/CollectionAddButton. Mascotas delega en los mismos componentes y conserva su referencia aprobada. Abiertos/Resueltos, foto real disponible y botón+ de56 reemplazan ListTile y el botón grande inferior. Swipe devuelve posición y abre confirmActionDialog común; shimmer/errores/confirmación siguen el patrón existente. Borradores encontrados conservan descarte con superficie compartida. Presentación consume ViewModels/casos de uso; dominio no adquiere dependencias de Flutter/SDK. Incremento de gestión por dueño solicitado sobre HU-05/RF-05 y HU-06/RF-06: eliminación de casos active/resolved y consulta privada de resueltos, con IDs/historial conservados y permisos versionados en016. No implica cierre de historias. Véase [ADR-026](decisiones/026-listas-casos-componentes-compartidos.md).

Ajuste de consistencia solicitado el11 de octubre (ADR-029): HU-03/RF-03 y HU-05/06/RF-05/06 comparten apertura/retorno de ficha desde tarjeta; se retiran acciones permanentes de volver a consultar y se conservan reintentos solo tras fallo. Sin ampliación funcional del MVP ni cierre de historias por evidencia local.


## Panel de ficha expandible — 11 de octubre de 2026

Por solicitud del usuario, ficha pública y vista previa comparten un panel inferior arrastrable con apertura por toque en el indicador; foto/pager permanecen detrás. Desaparición (Encuentro en encontrados) aparece en badge fuera del glass, junto al nombre cuando hay espacio y debajo con texto ampliado. Nombre con sombra leve, máximo dos líneas y elipsis; la etiqueta accesible conserva el nombre completo. El mapa no se monta hasta abrir el panel; fecha, ubicación aproximada y privacidad se muestran en los datos ampliados. El contenido se desplaza dentro del panel y las acciones existentes conservan sus operaciones reales. Movimiento reducido desactiva animación y snap; no se reproduce reveal durante gestos. Véase [ADR-030](decisiones/030-panel-ficha-expandible.md).


## Casos con la referencia aprobada de Mascotas — 11 de octubre de 2026

Por instrucción del usuario, la UI de Mascotas se conserva y se reutiliza en Casos. EntityScreenShell y entityEditorPage extraen su contenedor/apertura existentes: mismos márgenes, navegación glass y cover→stagger, fuente visual del botón y retorno. Registrar perdido/encontrado desde Reportar o+ usa esa misma transición; todos los campos, fotos, instrucciones y acciones participan del timeline existente, sin reiniciarlo por edición/teclado/selección. PhotoAddTile y SizeChoiceSelector comparten las implementaciones aprobadas; Encontrados conserva tamaño/sexo/custodia opcionales y los contratos del reporte. Listados usan cabecera/grupo de contenido con entrada compartida, sin count por registro. No se altera el panel de ficha inmersiva solicitado en ADR-030. Véase [ADR-031](decisiones/031-casos-reutilizan-ui-mascotas.md).

Validación local: suite completa309 pruebas aprobadas;8 regresiones nuevas repetidas tras reforzar el descarte en tamaños390×844/320×350 texto2 y movimiento reducido. Renders revisados en build/ui-preview/case-creation. Pendiente revisar Android autenticado con fotos/teselas reales; la aprobación visual no cierra historias ni confirma backend remoto.


## Fecha y hora independientes — 11 de octubre de 2026

Por solicitud del usuario, los reportes muestran Fecha y Hora en dos inputs con AppFieldSurface, lado a lado en tamaño normal y apilados con texto ampliado. EventDateTimeFields se comparte entre perdidos/encontrados, con calendario y reloj separados. EventDateTimeDraft conserva selecciones parciales en el estado del ViewModel: elegir una no inventa la otra; el timestamp existe solo con ambas y cambiar una conserva la otra. Las operaciones bloqueadas por envío/respuesta ambigua siguen sin admitir cambios. Valores existentes preservan UTC/segundos hasta una edición explícita. Validación, shake/toast y entrada por stagger conservados. [ADR-032](decisiones/032-fecha-hora-independientes-casos.md).

Edición revisada: casos publicados todavía no tienen contrato/caso de uso/RPC de actualización ni ruta de edición. Editar reporte modifica solo el borrador antes de publicar. Recomendación propuesta: permitir al autor corregir información de casos abiertos, con versionado/historial y misma ficha; alcance todavía no aprobado ni implementado.


## Consistencia de formularios perdido/hallazgo — 11 de octubre de 2026

Corrección explícita del usuario tras detectar controles extra en hallazgo. Se retiran Latitud/Longitud, Usar coordenadas, lectura numérica del punto, Recuperar foto interrumpida y el acceso permanente Mis encontrados dentro del formulario. CaseLocationFields de core compone ambos formularios con la misma selección en mapa, instrucciones de privacidad, referencia privada, invalid/shake y stagger; solo cambia el título del suceso y los callbacks del ViewModel. Coordenadas continúan internas, sin nueva captura numérica ni GPS. Fecha/hora siguen compartidas por ADR-032. Fotos usan la misma etiqueta pública y galerías/controles compartidos.

Se conservan las diferencias propias del producto: perdido elige mascota/fotos registradas; hallazgo describe y fotografía una mascota sin dueño conocido y permite custodia opcional. Consultar la lista permanece solo ante envío ambiguo, igual en ambos recorridos. La API de recuperación de fotos permanece para el ciclo de vida existente, sin botón técnico permanente ni afirmación de recuperación automática nueva. [ADR-033](decisiones/033-formularios-reportes-consistentes.md).

Validación:50 pruebas de reportes, entrada real, preview, arquitectura y consistencia aprobadas; análisis sin incidencias. Las8 pruebas de creación verifican controles retirados ausentes, uso del bloque común, punto del mapa entregado al estado y ausencia de coordenadas visibles, tamaños390×844/320×350 texto2 y movimiento reducido. Capturas regeneradas y revisadas; no acreditan fotos/teselas reales. Revisión Android pendiente.


## Nuevo significado de búsqueda y aviso — 11 de octubre de2026

Por instrucción del usuario, Mascota perdida admite Mi mascota u Otra mascota posiblemente perdida. Mascota encontrada avisa en una búsqueda abierta con La vi o La encontré y está conmigo, sin cerrarla. Desde ficha se vincula automáticamente el aviso; solo el autor confirma Ya fue recuperada. Se conservan UI de Mascotas, coordenadas privadas/zonas públicas y órdenes estables. Aviso admite foto opcional; búsqueda comunitaria exige fotos. Registros anteriores siguen como Reporte anterior, sin reclasificación automática. [ADR-034](decisiones/034-busquedas-y-avisos-vinculados.md) y [ficha](funcionalidades/busquedas-y-avisos.md).

Cambio de alcance autorizado: HU-05/RF-05 y HU-06/RF-06; se adelantan partes app de HU-10/RF-11 y confirmación de HU-13/RF-07. No se cierran historias ni se entrega web/QR, moderación completa, push o exploración/paginación de HU-07. Fuentes062–065/plan018, migración generada y probada localmente; activación remota/Android y concurrencia multiconexión pendientes.


Corrección de experiencia HU-05/RF-05: Mi mascota/Otra mascota alterna dentro del formulario, conserva los borradores de la visita y evita recarga/navegación al seleccionar. Sin ampliación de MVP, contratos SQL nuevos o cierre de historia. [ADR-035](decisiones/035-alternar-origen-sin-recargar-formulario.md).


Reorganización UI autorizada del12 de octubre: Reportar solo crea búsquedas/avisos; consulta por Mis reportes en Inicio, con ambos orígenes y estado pendiente real. Reutiliza operaciones de HU-05/RF-05 y HU-06/RF-06, sin SQL nuevo/exploración/push o historias cerradas. [ADR-036](decisiones/036-reportar-y-mis-reportes.md).


Corrección autorizada del12 de octubre: Reportar crea pérdida; avisos solo desde ficha abierta con destino fijo, sin selector de mil casos. Lectura puntual sobre contratos de HU-05/06, sin SQL nuevo. Explorar/HU-07/RF-13 permanece pendiente; no se implementa por esta reorganización ni se cierran historias. [ADR-037](decisiones/037-avisos-desde-ficha.md).


Corrección UX autorizada el12 de octubre: Mascota perdida es un único formulario con selección de ficha o No está en mis mascotas. Datos del reporte compartidos/conservados; detalles/fotos independientes por origen. HU-05/RF-05 y búsqueda comunitaria de HU-06/RF-06, sin ampliación del MVP, SQL nuevo o historias cerradas. [ADR-038](decisiones/038-formulario-unico-mascota-perdida.md).


## HU-07.1: lista de Explorar — 15 de octubre de 2026

Tras validación de la rama actual confirmada por el usuario, se continúa S3 con HU-07.1 / RF-13 / issue #32. Módulo explore: lista real por tipo/especie/estado/período/zona manual, distancia pública aproximada PostGIS y cursor por publicación/origen/ID. Abre fichas existentes y conserva clasificación de búsquedas/avisos/anteriores. Estados respetan visibilidad previa (resueltos del autor). SQL066–069/plan019, sin Edge nueva. HU-07.2 / issue #33 continúa pendiente; el mapa de selección del filtro no equivale a ese mapa de resultados. Sin ampliación del MVP, publicación/despliegue o historias cerradas automáticamente. [Ficha](funcionalidades/explorar.md), [ADR-039](decisiones/039-explorar-lista-publica-paginada.md) y ESTADO distinguen evidencia local y demo remota.


## Presentación de Explorar en grilla — 15 de octubre de 2026

Ajuste explícito del usuario sobre HU-07.1/RF-13: cards fotográficas en dos columnas adaptables a una, imagen protagonista y datos debajo. Conserva filtros/páginas/ficha y contrato019. Sin ampliación de MVP, SQL nuevo o cierre de historia. [ADR-040](decisiones/040-explorar-grilla-fotografica.md) y [ficha](funcionalidades/explorar.md).


## Filtros de Explorar superpuestos — 15 de octubre de 2026

Ajuste solicitado de HU-07.1/RF-13: panel flotante reutilizable que mantiene fija la grilla y usa cápsulas compartidas con el selector Activas/Archivadas. Cancelar descarta cambios sin confirmar; Aplicar conserva los contratos/paginación existentes. Sin SQL, ampliación del MVP ni cierre automático de historia. [ADR-041](decisiones/041-filtros-flotantes-reutilizables.md) y [ficha](funcionalidades/explorar.md).


## Ajuste de filtros y zona de HU-07.1 — 15 de octubre de 2026

Por nueva instrucción, filtros desplegados dentro de Explorar sin popup. Cards eliminan texto Mascota perdida y conservan nombre/especie más badges. El usuario confirma búsqueda de ciudad/dirección, selección en mapa y radio en kilómetros. Incremento de HU-07.1/RF-13 con geocodificación de lectura Photon y selección manual alternativa, sin GPS, SQL nuevo o mapa de resultados HU-07.2. [ADR-042](decisiones/042-filtros-integrados-y-busqueda-zonas.md), ficha y ESTADO separan evidencias locales de demo autenticada.

Corrección visual16 de octubre de2026 de Guardados (HU-07/RF-13): pantalla independiente desde marcador compacto, con expansión/retorno OriginPageTransition compartido y shell glass; sustituye alternancia de vistas dentro de Explorar. Sin ampliación funcional ni SQL nuevo;021/Android pendientes y sin pruebas por instrucción del usuario.

## Calidad visual de landing —17/10/2026

Por petición explícita se reemplazan todos los recortes del mockup por siete
ilustraciones transparentes generadas individualmente con imagegen. Componentes
Vue/CSS/SVG para tarjetas, etiquetas, superficies y decoración; logo oficial.
No se cambia el stack Nuxt ni el hero aprobado, ni se implementan operaciones
nuevas de producto. Sin HU/RF/issue nuevos ni cierre de historias. Revisión local
según ESTADO; publicación/redeploy no incluidos.

Actualización de identidad17/10: se amplía diversidad de mascotas/pelajes/pañuelos
y se regenera el emblema blanco dentro de las ilustraciones, sin overlays.
Logo actualizado en web/QR/favicon y recursos Flutter/nativos, sin nuevos casos
de uso, permisos, HU/issue o ampliación funcional de plataformas futuras.
Validación y límites registrados en ESTADO y ficha identidad-visual.

Refinamiento20/10/2026 de S3 (HU-05/RF-05/issue #5, HU-06/RF-06/issue #6):
buscador opcional antes del mapa para reportar pérdida/hallazgo, reutilizando
places. Sugerencias de Perú también en Explorar (HU-07/RF-13) y Ciudad del perfil
(HU-01.7/RF-01); mapa manual libre. Sin nuevas historias/SQL ni cierre adicional.
[ADR-107](decisiones/107-busqueda-reportes-y-sugerencias-peru.md),
[ficha](funcionalidades/ubicaciones-buscador.md).
