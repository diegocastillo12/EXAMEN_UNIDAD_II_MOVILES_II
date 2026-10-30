# Acceso web

## Aceptación del usuario — 25/10/2026

El usuario confirma que cuenta/acceso, difusión, seguimiento y recuperación ya
fueron validados y solicita actualizar el seguimiento. Se registra su aceptación,
sin atribuir al agente una nueva demo ni un log individual de cada escenario.
Esta nota sustituye los pendientes de validación correspondientes de las notas
históricas; no activa FCM ni acredita baja/exportación sin implementar.

Cuenta/acceso existente aceptados por el usuario; no implica paridad total web/móvil ni entrega de baja/exportación.

24/10/2026: dominio público actualizado a `https://entrehuellas.app`. Los
endpoints de Supabase y la infraestructura se conservan. Código/configuración
local actualizados; despliegue, retorno OAuth, envío de correo y escaneo de QR
en producción pendientes de comprobación. Los QR/PDF ya distribuidos con el
subdominio anterior necesitan mantener ese host o una redirección de navegación
a la misma ruta y parámetros; el código no regenera documentos existentes.


## Retorno Google de producción —23/10/2026

Diagnóstico remoto sin sesión: inicio OAuth web200 y redirección de Auth302 a
Google con PKCE. Localhost y producción usan el mismo Supabase/cliente Google.
Una cancelación simulada con state nuevo conserva el callback local y flow;
para producción Auth devuelve entrehuellas://login-callback/, perdiendo el
callback web. Confirma rechazo del retorno de producción por la allowlist
efectiva; no demuestra por sí solo la causa de la espera en accounts.google.com.

Corrección operativa pendiente: añadir
https://entrehuellas.app/api/moderation/oauth/callback?flow=*
a GOTRUE_URI_ALLOW_LIST del contenedor Auth, o a ADDITIONAL_REDIRECT_URLS si
Compose la inyecta allí; conservar entradas móvil/local y recrear Auth.
No cambiar el callback Google→Supabase ni sustituir Site URL móvil como atajo.
Repetir cancelación y verificar que vuelve al callback web con flow; después
probar login real y onboarding. Sin acceso al despliegue ni cambios remotos.
La comparación con Sader no acredita esta configuración: usa otro Supabase.

El usuario confirma que Compose inyecta GOTRUE_URI_ALLOW_LIST desde
ADDITIONAL_REDIRECT_URLS; su valor declarado solo contiene el host Supabase,
http://localhost:3000/* y entrehuellas://login-callback/. Falta producción.
El historial b51aa4b→b364688 conserva callback/flow/PKCE desde19/10; no se
identifica una regresión reciente de esa URL. La aceptación remota de127.0.0.1
requiere contrastar también el entorno efectivo de Auth con el declarado.

No se autentican cuentas, intercambian códigos ni registran estados/verifiers/
tokens. Si Google sigue esperando tras corregir el retorno, obtener URL/estado
de la petición pendiente y logs Auth para diagnosticar ese tramo por separado.

21/10, cabecera completada: avatar con foto privada/iniciales abre Tu cuenta
en panel glass. Campana compuesta desde las páginas permite consultar la
[bandeja real](notificaciones-web.md). El cierre usa un icono circular glass
con nombre accesible y tooltip; conserva la operación original. Se retira el
desplegable inferior; política global, onboarding y permisos intactos.

21/10: [Inicio web](inicio.md) adopta la composición de Inicio móvil, con
accesos reales, ilustración y Cerca de ti. Tu cuenta se despliega por teclado
o toque, conserva datos reales y no añade persistencia. Gestión/reintento
continúan según permisos; sesión, onboarding y política global intactos.

21/10: Inicio y tarjeta de gestión sin frases decorativas sobre los títulos.
Se retira el pie legal del shell de cuenta compartido con las demás secciones;
login/registro y documentos públicos conservan sus enlaces legales.
Cambio de presentación, sin modificar sesión, onboarding ni permisos.

Navegación20/10, ADR-121: bootstrap puede iniciar el ViewModel con la proyección
vigente del transporte solo después de hidratar, vinculando actor en HTTP.
No aumenta el plazo15s ni serializa estado privado en SSR. La política global
sigue comprobando cada destino, los permisos no se cachean y los avisos de
sesión/foco/visibilidad conservan invalidación. Montar una sección no representa
un cambio de identidad. El vencimiento se programa también con estado inicial.
Identidad y perfil se leen en paralelo sin devolver datos antes de validar ambos.

Diagnóstico20/10: producción rechazaba el Origin HTTPS antes de Auth y aceptaba
http://127.0.0.1:5173 (POST vacío403 frente a422, sin credenciales). Configurar
PUBLIC_WEB_ORIGIN=https://entrehuellas.app en runtime de producción y
reiniciar/recrear contenedor; desarrollo conserva su origen local. Corrección
remota pendiente, sin cambiar CSRF/roles/SQL. Evidencia en ESTADO.

20/10, ADR-118: Inicio comparte la barra de cuenta con /explorar, /mis-mascotas
y /reportar, protegidas por la política global. AccountScreen ofrece un slot
compuesto por páginas para conservar cabecera, sesión, logout y onboarding sin
importar otra presentación. Gestión continúa en Inicio por permiso.
[Recorridos implementados y límites](navegacion-web.md); las pendientes históricas
de estas tres secciones quedan sustituidas dentro del alcance de esa ficha.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión en dispositivos reales pendiente.

## Hover glass compartido en campos —19/10/2026

LoginInput hereda reflejo glass interior visible (ribete2px/borde#8FA9C4) al pasar el ratón por campos
habilitados/editables. Se mantiene el foco interior al escribir, error rojo y
estados disabled/readonly; sin hover táctil ni cambios de geometría. Aplica a
login, registro, código y nueva contraseña. Sin cambios de datos, permisos,
persistencia o reintentos. [ADR-090](../decisiones/090-hover-glass-interior-campos-web.md);
validación local en ESTADO.

## Foco de campos hacia dentro —19/10/2026

LoginInput hereda el foco interior compartido de reader-shell: outline2px con
offset−2px, azul normal y rojo en invalid. Aplica a login, registro, código y
nueva contraseña, con la misma geometría antes/después del foco. Sin cambios
de etiquetas, datos, validaciones, permisos, persistencia o reintentos.
[ADR-089](../decisiones/089-foco-interior-inputs-web.md); validación en ESTADO.

## Registro, verificación y recuperación implementados —19/10/2026

- Qué hace/recorrido: login ofrece Crear cuenta y ¿Olvidaste tu contraseña?.
  /crear-cuenta solicita nombre/correo/contraseña/confirmación; si falta confirmar,
  verifica código6 con reenvío60s. Sesión confirmada conduce a bienvenida/inicio.
  /recuperar-contrasena solicita/verifica código; /restablecer-contrasena permite
  cambiar contraseña y vuelve al login mediante acción explícita al confirmar.
- Reglas/campos: nombre1–120 tras trim, correo válido<=254; contraseña8–1024 sin
  trim y confirmación igual. Código exactamente6 cifras. Respuestas de correo
  sin revelar existencia de cuenta. Autoconfirmación compatible si Auth la devuelve.
- Persistencia/permisos: misma cuenta Auth y full_name que móvil. Cuenta y perfil
  revalidados al establecer eh_access. Estado temporal en eh_credentials cifrada/
  HttpOnly; recovery nunca concede sesión normal. Token sin exposición JSON/SSR.
  Política global guest/recovery, sin guards por pantalla. Progreso se restaura
  al recargar; formulario no guarda contraseña/código en almacenamiento.
- Errores/reintentos: toast superior/invalid/shake; skeleton inicial, shimmer y
  bloqueo de dobles envíos. Código incorrecto/caducado conserva etapa/reenvío;
  falla de red conserva entrada y permite reintento. Otro flujo en pestaña produce
  conflicto sin borrar el actual. Cancelar limpia capacidad; login/logout/OAuth
  confirmado retiran flujo anterior. Sin reintentos automáticos de escrituras.
- Dependencias/activación: variables Auth existentes, OTP6, plantillas .Token y
  SMTP/registro habilitados. Sin SQL, configuración remota, Flutter o publicación.
  Límite local pendiente30min y reset10min, sin afirmar vencimiento real del OTP.
- Validación: pruebas locales y Chrome fixture detallados en ESTADO; demo con
  correo real pendiente. Implementación no implica paridad global ni cierre de HU.

[ADR-087](../decisiones/087-registro-y-recuperacion-web.md).

## Login responsive con marca grande —19/10/2026

Hasta600px, la cabecera compartida presenta logo76px y texto «entre huellas»
en dos líneas, con título próximo, según captura elegida por el usuario.
Mantiene marca fuera del formulario/stagger y estilos definidos desde SSR.
Escritorio, fondo frío y orbe conservados. Sin cambios de campos, sesión,
persistencia, permisos, errores/reintentos, dependencias o activación.
Incremento visual de HU-01, sin nueva HU/issue ni cierre. Validación local y
revisión visual pendiente del usuario en ESTADO.
[ADR-085](../decisiones/085-marca-responsive-login.md).

## Avisos web de una sola vez y URL limpia —19/10/2026

Por autorización del usuario, login consume los motivos signed-out, expired,
forbidden, oauth-failed y oauth-cancelled; inicio consume forbidden. Tras comprobar
la sesión se reemplaza la entrada actual del router, retirando solo reason
reconocido y mostrando el toast compartido. Recargar o volver desde legales no
repite el aviso consumido. Parámetros ajenos (incluidos repetidos) y fragmento
se conservan; el guard también conserva el fragmento al retirar entry=checked.
No cambia autorización, callbacks OAuth, política SSR ni comprobación por operación.
Los parámetros desconocidos no se interpretan como avisos. La limpieza requiere
JavaScript; en SSR se mantiene el transporte existente hasta la hidratación.
Sin SQL, Flutter, variables nuevas, despliegue ni cierre de HU-01/HU-14.3.

Validación local: typecheck y build de Nuxt correctos;46 pruebas unitarias/
arquitectura y21 de servidor aprobadas. Chrome sobre build de producción y backend
fixture verifica los cinco motivos, alias /login, URL limpia sin entrada adicional
en historial, parámetros repetidos/fragmento, navegación sobre la misma pantalla,
recarga/volver, cierre de cuenta/moderación y denegación SSR/SPA sin montar revisión.
Sin errores CSP/hidratación. No se usaron cuentas remotas ni se publicó.
Siguiente paso: comprobar el recorrido con la configuración real antes de publicar.



## Cierre sin esperar a Supabase —19/10/2026

El servidor elimina cookies web y confirma el cierre local antes de terminar
la llamada a Supabase. Nitro event.waitUntil mantiene ese intento en servidor
con timeout existente5s; no bloquea navegar al login. El cliente espera únicamente
la respuesta de borrado HTTP, limpia datos/preparación y avisa a otras pestañas.
Sin configuración remota también borra cookies; origen/métodos siguen protegidos.
La confirmación no afirma revocación remota ni entrega duradera ante reinicio.
JWT emitidos conservan vencimiento y las sesiones móviles no se cierran.
[ADR-082](../decisiones/082-cierre-web-sin-esperar-supabase.md); pruebas con
Supabase retenido, evidencia en ESTADO. Sin SQL, variables nuevas ni despliegue.

## Destino preparado desde landing —19/10/2026

La landing prepara la sesión con el ViewModel y precarga el destino. El enlace
apunta a /inicio, /bienvenida o /iniciar-sesion antes de pulsar. Preparación,
guard y llegada reutilizan la respuesta en memoria de la misma app máximo15s,
limitada por expiresAt;401 confirmado máximo5s, fallos no se guardan. Data
deduplica consultas y se invalida por mutaciones, cambios entre pestañas, foco,
visibilidad y401/409. Pantalla refresca preparación cada10s solo visible; limpia
timers/listeners al salir. Permisos/operaciones siempre van al servidor.
Sin estado privado SSR, almacenamiento persistente o singleton de servidor.
Si se pulsa antes de preparar o después de caducar puede haber espera real y
se conserva shimmer. [ADR-080](../decisiones/080-preparar-acceso-desde-landing.md)
sustituye la limitación de feedback únicamente descrita en la nota anterior.

## Feedback inmediato al navegar —19/10/2026

La comprobación global de sesión es asíncrona: Vue Router conserva la página
actual hasta conocer el destino autorizado. El clic de landing no mostraba
trabajo y parecía ignorado. NavigationLink compartido conserva href y texto,
activa aria-busy/shimmer inmediatamente y bloquea doble clic mientras espera
la navegación completa (incluidas redirecciones). finally libera el estado ante
cancelación/fallo; enlaces modificados/nueva pestaña y navegación sin JS conservan
comportamiento nativo. Landing, acceso, cuenta, legales y moderación reutilizan
el componente. No elimina la latencia del backend, no introduce una pantalla
intermedia ni caché de identidad o permisos. Movimiento reducido: brillo estático.
Prueba con respuesta retenida comprueba feedback antes de responder y rechazo
de doble clic; resultados en ESTADO.

## Entrada desde otro sitio sin JSON forbidden —19/10/2026

Corregido el filtro que bloqueaba el puente /api/access/entry cuando una
navegación externa conservaba Sec-Fetch-Site cross-site tras redirigir desde
/inicio. Solo se permite GET/HEAD navigate/document a ese endpoint de redirección
interna. Fetch/XHR, iframe, escrituras y demás APIs mantienen bloqueo; cookie
Strict y autorización intactas. Regresión con headers y enlace externo Chrome;
sin cambios de variables, SQL o despliegue. Detalle en ADR-079 y ESTADO.

## Comprobación global para todas las rutas —19/10/2026

La navegación completa usa route_policy y access.global/session-entry, con una
sola regla de etapa compartida; se retiran los guards particulares y su selección
por página. Incluye moderación con permiso validado antes del HTML/montaje.
Landing, legales, QR, aliases y fallback público mantienen su recorrido anónimo.
Toda página/alias nueva debe declarar política: build/test detectan omisiones.
Sin sesión no se monta ninguna ruta protegida ni su skeleton antes del login;
con sesión se permite el destino autorizado para su etapa, sin forzar /inicio
en cada navegación. APIs conservan permisos por operación, cifrado/HttpOnly y
reintentos de ADR-078. Puente de cookie antigua conserva destinos registrados
y descarta externos. [ADR-079](../decisiones/079-politica-global-de-acceso-web.md)
sustituye los guards individuales citados en las notas históricas siguientes.
Validación de inventario completo SSR/SPA, permisos y errores en ESTADO;
sin SQL, Flutter, variables nuevas ni despliegue. Cuentas remotas pendientes.

## Inicio/bienvenida después de cerrar sesión —19/10/2026

Corregido el caso que quedaba pendiente: entrar a /inicio sin sesión montaba su
skeleton antes del login. Ambas rutas /inicio y /bienvenida ahora comprueban
sesión antes de renderizar en servidor y antes de montar en navegación cliente
(account-access). Anónimo llega directamente al formulario, sin shell/skeleton
de cuenta. Sesión válida dirige a la etapa que corresponde; cookie inválida se
limpia. Fallos de backend conservan el reintento y no se interpretan como logout.
El puente de cookies antiguas usa entry=unavailable solo para permitir ese shell
de reintento sin bucles; ningún marcador concede identidad, datos o permisos.
Mismos contratos/configuración de ADR-078, sin SQL ni alcance funcional nuevo.
Validación del escenario tras logout/recarga/SPA documentada en ESTADO.

## Entrada directa con sesión activa —19/10/2026

/iniciar-sesion ahora valida Auth y perfil en servidor y redirige302 a /inicio
o /bienvenida antes de renderizar. No muestra login ni skeleton de acceso
intermedio. En navegación cliente, el middleware espera al ViewModel antes de
montar. Los datos de cuenta del destino conservan su carga actual.

eh_access pasa de path /api a /, conservando cifrado, HttpOnly, SameSite y
vencimiento. /api/access/entry recupera automáticamente cookies anteriores
sin ampliar su duración ni volver a pedir credenciales. Sin sesión, un salto
anónimo conserva reason/otros parámetros y usa entry=checked solo para terminar
la redirección; el cliente lo retira. No habilita permisos ni acepta destinos
externos. Cerrar elimina ambos alcances. Cookie inválida se limpia; fallo503
conserva la sesión y ofrece el reintento existente en /inicio.

Sin cambios de SQL/Flutter/OAuth, variables nuevas ni despliegue. La corrección
sustituye las descripciones históricas de cookie API y login visible durante
comprobación. [ADR-078](../decisiones/078-acceso-web-redireccion-servidor-sin-login-intermedio.md).
Validación local y pendientes en ESTADO; no cierra HU-01 ni HU-14.3.

Regla ratificada19/10: marca arriba a la izquierda como landing, con color y
medidas compartidos; conservar posición desde SSR hasta hidratación/recarga,
sin saltos. [Norma completa](../REGLAS_UI_UX_WEB.md) y ADR-077.

## Marca compartida con landing —19/10/2026

Cabecera usa SiteBrand/SiteHeader con la misma posición, color, fuente y tamaños
adaptables de landing, también en responsive y fuera del stagger. Sin cambios
de negocio, permisos o persistencia. Validación local en ESTADO; sin despliegue.
[ADR-077](../decisiones/077-marca-web-compartida-referencia-landing.md).

## Regla de marca en cabecera —19/10/2026

Logo oficial y texto «entre huellas» deben conservar la posición superior
izquierda de landing/onboarding también en responsive, fuera del contenido y
su stagger/carga. Incluye acceso e inicio; este cambio documenta la regla,
sin afirmar nueva adaptación de pantallas.
[ADR-076](../decisiones/076-posicion-unificada-marca-web.md).


## Corrección: sin skeleton adicional de gestión —19/10/2026

Sustituye el ajuste anterior: se retira ManagementSkeleton completamente.
La consulta de permisos opcionales no agrega un panel gris ni espacio bajo
las tarjetas; usa aria-busy y solo agrega gestión al confirmar permiso.
El skeleton de sesión inicial sigue hasta leer la cuenta. Ante fallo, toast y
reintento; el botón conserva su etiqueta con shimmer y bloqueo durante reintento.
QA exige ausencia de placeholders en cada fotograma del inicio y recarga con
permisos lentos, además de recuperación/roles y responsive. Sin despliegue.

## Skeleton de gestión en Inicio —19/10/2026

La consulta checkingManagement usa ManagementSkeleton con forma del resumen
de gestión, líneas y acción; deja de reutilizar la ficha genérica con foto300px.
Panel de carga, gestión y reintento pertenecen a la misma grilla/stagger de las
tarjetas, a ancho completo. Así la carga no aparece antes de las tarjetas aún
invisibles. Conserva semántica, shimmer, consulta real, error/reintento y permisos;
sin rol confirmado desaparece. QA local retiene la respuesta para comprobar
orden, tamaño, responsive/texto200% y retirada sin replay. Sin despliegue.

## Reveal compartido —19/10/2026

Sustituida la utilidad .reveal por StaggerReveal/useStaggerReveal sin capa crema.
Conserva HTML/acciones, no repite entrada por edición/refresh; movimiento reducido
inmediato. QR conserva lectura SSR sin JS. Sin cambios de datos/permisos.
[ADR-075](../decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md); evidencia local en ESTADO,
sin despliegue ni nuevo cierre de historia.

## Ilustraciones ampliadas y respuesta vacía al completar —19/10/2026

Por solicitud del usuario, las ilustraciones de /bienvenida ocupan todo el ancho
de la columna: hasta448px base en escritorio y el ancho disponible en móvil,
con proporción y PNG originales. Sustituye el máximo anterior288px.

Se reproduce un defecto de AccountSource: complete_onboarding devuelve void y
una respuesta HTTP204 correcta sin cuerpo se convertía en unavailable al exigir
un lector JSON. Las pruebas anteriores simulaban200/null y no lo detectaban.
Ahora se acepta204 solo en esta RPC, se valida el estado HTTP antes de leer cuerpo
y se conserva la consulta posterior del perfil real antes de confirmar/cambiar
de pantalla. No se marca finalización de forma optimista ni se cambia SQL/permisos.
Fixture actualizado a204; dos regresiones fallan antes y pasan después del fix,
incluidos endpoints JSON y errores sin cuerpo. Guardado/reintento siguen ligados
a la misma cuenta. Sin credenciales del usuario, cambios remotos o despliegue.
La reproducción confirma el defecto local, sin capturar la petición de su sesión.

Validación:40 pruebas unitarias/dependencias, typecheck/build, servidor construido
y QA Chrome de onboarding/acceso con fixture204; imágenes a ancho completo,
sin overflow con texto200% y transición a inicio tras completar.
Pendiente confirmar el recorrido con la cuenta real del usuario.

## Marca y avance único del onboarding —19/10/2026

Por nueva instrucción y aclaración del usuario, /bienvenida muestra el logo
oficial y el texto entre huellas en cabecera al inicio de página como landing,
separados de la columna de pasos, también en responsive y fuera de la transición. Se eliminan
Anterior y los tres puntos visuales; solo Continuar/Comenzar. El paso conserva
semántica no visual para lectores de pantalla. Se mantienen tres etapas sin
Omitir, PNG/textos móviles, stagger/press y guardado/shimmer/error/reintento.
Sin cambios de cuenta, RPC, permisos, Flutter o despliegue. ADR-074 actualizado.
Validación: typecheck/build y QA Chrome de onboarding/acceso con fixture;
marca estable, avance único, guardado, movimiento reducido y tamaños pequeños/
texto200%. Pendiente valoración visual del usuario.

## Onboarding con referencia sader-panel —19/10/2026

**Qué hace/recorrido:** sustituye la presentación provisional de /bienvenida por
composición sader-panel: columna448px izquierda, Inter local, título48/600,
descripción18/500 y botones carbón/radio18px base/mínimo48px/flecha20px.
PNG y textos/saltos exactos de móvil; tres pasos con Continuar/Comenzar sin Omitir,
sin Anterior ni puntos por la corrección posterior. Marca propia arriba, sin
cabecera de navegación ni footer de cuenta en esta ruta.
[ADR-074](../decisiones/074-onboarding-web-referencia-sader-y-mobile.md).

**Transición/errores/reintentos:** se retira .reveal que dibujaba el bloque crema.
OnboardingFlow usa useStaggerReveal existente en cuatro grupos,550ms/90ms,
offset56px: press completo, salida invertida, cambio de contenido y entrada.
Bloquea clics repetidos; elimina esperas con movimiento reducido, incluso al
activarlo durante salida. Cancela timers/listeners al desmontar. Conserva
contenido y shimmer durante guardado real; solo sale tras éxito confirmado.
Error mantiene tercer paso y reintento, sin repetir entrada. Orbe continuo.

**Persistencia/permisos/dependencias:** AccountViewModel/RPC complete_onboarding,
sesión y permisos conservados; finalización compartida por cuenta con móvil.
PNG originales copiados sin alterar y fuente Inter local con OFL. Sin React,
apariencia de Sader, SQL, Flutter, configuración remota o despliegue.

**Validación:** typecheck/build y38 pruebas existentes aprobados. Chrome fixture
comprueba estilos/tiempos CSS reales, salida/entrada/anterior/siguiente/doble clic,
PNG idénticos, guardado visible/error/reintento, movimiento reducido/cambio en
salida y desmontaje. Capturas1440/390/320×350/320 texto200% revisadas sin overflow;
sin CSP/hidratación. Regresión de acceso/OAuth/roles/sesión también aprobada.
QA detectó además el skip-link compartido asomando con texto200%: ahora se oculta
por su propia altura y reaparece con foco. Pendientes valoración visual del usuario
y confirmación remota; no se afirma paridad web/móvil ni cierre de historia.

## Acceso general, inicio y bienvenida —19/10/2026

**Qué hace y recorrido:** landing → /iniciar-sesion (correo/Google/Facebook para
cuentas existentes válidas, sin rol de revisión) → /bienvenida si faltan los tres
pasos por cuenta, o /inicio. No hay Omitir. Inicio consulta nombre/correo/ciudad
reales, permite cerrar sesión y enlaza a proyecto/legales. Una cuenta revisora
ve Revisar denuncias y puede volver al espacio normal; retirar el rol conserva
el acceso general. Sustituye el acceso exclusivo descrito en notas anteriores.
Incremento de HU-01/RF-01,34 en web; conserva HU-14.3 / issue #45 sin cierre.
[ADR-073](../decisiones/073-acceso-general-web-y-gestion-por-permisos.md).

**Reglas, persistencia y permisos:** validación/límites de correo/contraseña
conservados. Onboarding lee profiles.onboarding_completed_at y completa mediante
complete_onboarding existente; se comparte con móvil por cuenta. Consulta propia
limitada a id/display_name/city/onboarding_completed_at con JWT/RLS y clave
publicable; correo de Auth. No inventa perfiles ni deriva roles del proveedor.
Gestión consulta aparte require_content_reviewer; cada API restringida lo
comprueba nuevamente. Peticiones de onboarding/gestión ligadas al actor esperado.
Sin SQL nuevo, asignación de roles, Flutter o cambios de Auth remoto.

**Sesión y errores:** eh_access HttpOnly/cifrada/SameSite Strict/path /api,
Secure en HTTPS, reutiliza MODERATION_SESSION_SECRET solo servidor. Namespace
separado del anterior, máximo1h sin refresh token. La sesión general tiene
preferencia sobre la cookie antigua de moderación; logout limpia ambas y solicita
cierre local, sin cerrar Android. SSR sin datos privados. Cambios de cuenta,
disposición y expiración descartan respuestas/datos anteriores; cierre entre
pestañas. Toast superior, skeleton y shimmer conservados. Error de onboarding
mantiene tercer paso y permite reintentar; fallo de gestión conserva la cuenta
y ofrece reintento; falta de rol confirmada oculta gestión.

**Rutas, dependencias y activación:** /login, /terms y /privacy redirigen308 a
/iniciar-sesion, /terminos y /privacidad, conservando query y hash cliente.
Callback /api/moderation/oauth/callback y QR no se renombran. PKCE guarda sesión
general y vuelve a inicio/bienvenida. Variables actuales bastan con origen exacto
y callback autorizado en Auth; no se despliega ni configura el servicio remoto.

**Validación y límites:** typecheck/build,38 pruebas unitarias/dependencias y14
pruebas de servidor construido aprobadas. Chrome con fixtures verifica cuentas
normal/revisora, onboarding/reintento, roles revocados, cierre entre pestañas,
expiración, errores/reintentos, OAuth y redirecciones. Acceso/inicio/bienvenida,
moderación, legales y stagger revisados en tamaños1920/1440/731/390/320 y texto200%
sin overflow; corregido un desajuste de hidratación al redirigir antes del montaje.
Capturas de inicio revisadas en apps/mobile/build/ui-preview/web-access.
Pendientes cuentas/proveedores/retorno/cookies HTTPS reales. Inicio es consulta
de cuenta; Explorar/mascotas/reportes/avisos/perfil editable/registro/recuperación
web y administración no se entregan ni se muestran como accesos vacíos.
Siguiente incremento propuesto: Explorar web.

## Convención de rutas aprobada —19/10/2026

[ADR-072](../decisiones/072-rutas-web-en-espanol.md) fija /iniciar-sesion como
ruta canónica objetivo. /login sigue implementada: su migración deberá conservar
redirección, parámetros necesarios como reason y actualizar navegación,
middleware, logout/expiración y respuesta del callback OAuth conjuntamente.
El endpoint del callback no se renombra por esta convención. Sin cambios de
persistencia, permisos o activación; sin build en este incremento documental.
Validación de navegación y retorno pendiente para la futura migración.

## Puerto local y proveedores —19/10/2026

Capturas sitúan el fallo en3000: OAuth start403 porque el proceso exige origen
5173 y genera callback5173. La recarga de .env.local reinicia Nuxt en5173;
configuración final conserva PUBLIC_WEB_ORIGIN=http://127.0.0.1:5173.
Verificación directa de esa instancia: Google/Facebook start200; Supabase
responde302 hacia accounts.google.com/www.facebook.com. Credenciales de los
proveedores pertenecen a Supabase Auth autohospedado, no al .env de Nuxt.
Pendiente autenticación completa y allowlist del retorno. El toast forbidden de
correo no prueba por sí solo rol faltante: el rechazo de origen también es403
y se mapea al mismo fallo en el repositorio HTTP actual. No se cambia autorización
ni se asignan roles. La observación503 publicada es independiente del fallo local.

## Diagnóstico de conexión —19/10/2026

Ante «No pudimos conectar», se comprueba POST /api/moderation/oauth/start en
producción:503/unavailable con Google, JSON válido y origen correcto. Como la ruta
solo valida configuración y genera URL/cookie, apunta a variables de acceso
ausentes/inválidas en el proceso publicado. GET /login200 y sesión anónima401
no acreditan configuración válida: la consulta sin cookie no la requiere.
Pendiente revisar variables/logs de Dokploy para identificar el valor concreto;
no se cambia configuración remota ni se despliega.

El entorno local conservaba PUBLIC_WEB_ORIGIN de producción y rechazaba POST
local con403. Corregido en archivo ignorado a http://127.0.0.1:5173, sin alterar
credenciales. Runtime construido existente: inicio Google/Facebook200 con callback
local y cookie HttpOnly apropiada para HTTP; origen externo403. Auth settings
remoto leído con clave local:200, email/Google/Facebook habilitados. No demuestra
allowlist del callback, login real ni permisos de revisión de una cuenta.
DESARROLLO detalla arranque y diagnóstico; no hay cambios de código/build/SQL
ni cierre de HU-14.3 / issue #45. Siguiente paso: configurar el servicio publicado
y comprobar el recorrido con cuenta autorizada, manteniendo permisos de servidor.

## Toast web alineado con móvil —18/10/2026

Por solicitud del usuario, TopToast compartido reproduce ConfirmationToastHost
móvil: cápsula #F5F5F7 al90%, borde blanco70%, radio28px, blur18px y sombra
#24282A al10% desplazada6px/blur20px. Ancho ajustado al mensaje hasta360px,
márgenes laterales24px y safe-area superior+12px, mínimo48px, padding16/8px.
Icono Material Rounded oficial20px dentro de círculo neutro32px; error_outline
en #B53F48 para error y check #111111 para confirmación. Texto14px/400 (sin negrita, por corrección posterior del usuario),
fuente heredada de la página. Sin X: tocar el aviso o activar su botón mediante
teclado lo cierra. Reintentar sigue siendo acción independiente, cierra primero
y ejecuta su callback. Entrada fade lineal y slide easeOutCubic de180ms;
movimiento reducido estático. Mensajes extensos/texto ampliado pueden hacer
scroll vertical dentro del límite30svh/220px, sin recorte de contenido.

Conserva API show, roles alert/status, expiración web6500ms y limpieza al
desmontar; no se altera autenticación, stagger, orbe ni código Flutter.
La adaptación se comparte con los recorridos que ya consumen TopToast.

Validación: typecheck/build aprobados. QA Chrome del toast confirma cápsula,
blur/iconos/colores, estados alert/status, cierre al tocar y por teclado,
expiración y movimiento reducido;1440/390/320px con texto200% sin overflow,
CSP ni errores de hidratación. Capturas escritorio/móvil revisadas en
apps/mobile/build/ui-preview/web-toast. QA completo de login y moderación
aprobado con backend fixture. git diff --check aprobado. Siguiente paso:
valoración visual del usuario; OAuth remoto conserva su configuración pendiente.

## Port fiel de useStaggerReveal de sader-panel —18/10/2026

Por nueva corrección del usuario, se sustituye la aproximación con keyframes
arrive por el composable compartido app/composables/useStaggerReveal.ts,
portado del hook de sader-panel. Conserva sus opciones active/count/gap/duration,
blur/offset, dirección y orden independientes de entrada/salida, initialDelay,
animateInitial, autoíndice e índice explícito y exitMs. Misma transición de
opacity/filter/transform850ms, curva(.22,1,.36,1), intervalo90ms y doble
requestAnimationFrame al montar/activar, con cancelación al salir/desmontar.
will-change permanece como en la referencia, también al finalizar.

Login consume seis índices explícitos (icono, nombre, título, lema, formulario,
legales), sin keyframes adicionales. La entrada del icono está en un wrapper
exterior al hover, igual que la referencia; no se mezclan ambas transformaciones.
Se preservan fuente Arial, composición, textos, orbe y autenticación.

Adaptación necesaria de Vue/Nuxt: vStaggerReveal aplica los estilos mediante
CSSOM antes del montaje y al actualizar. El HTML SSR usa una clase compartida
con el mismo estado inicial oculto. Así se respeta la CSP existente sin autorizar
estilos inline arbitrarios ni producir flashes por estilos SSR bloqueados.
Movimiento reducido anula opacidad/blur/desplazamiento/transiciones desde el
primer render; editar o comprobar sesión no reinicia el efecto.

Validación: typecheck/build, QA Chrome de recarga/stagger, login completo y
login/legal aprobados. Transiciones reales y posición final estable verificadas;
hover, edición, movimiento reducido y390/320px con texto200% sin regresiones.
Sin errores CSP/hidratación. Capturas revisadas en login-reload; OAuth se valida
con fixture, no constituye confirmación remota. Siguiente paso: revisión visual
del usuario; activación OAuth real pendiente de configuración.


## Retorno glass e identidad legal —18/10/2026

GlassNavigationButton compartido ahora usa chevrón SVG oficial Material
Rounded28px y acabado glass del móvil. Regresión de moderación comprobada.
Por nueva instrucción, solo /terms y /privacy usan DM Sans local; login conserva
Arial. Ver ficha documentos-legales y ESTADO. No cambia la autenticación.

## Recarga de login sin destello crema —18/10/2026

El usuario detecta un destello amarillo al recargar. Causa comprobada:
.login-form usaba .reveal y su pseudo-elemento de cobertura #FFFBEF del
componente global. Se retira esa clase solo del login; no se modifica el
reveal global ni las páginas legales/QR/landing.

Por solicitud expresa, /login adopta la entrada de useStaggerReveal de
sader-panel: opacidad0→1, blur18→0px, translateY(-28px)→0,850ms y curva
cubic-bezier(.22,1,.36,1). Seis grupos con separación90ms: icono, nombre,
título, lema, formulario y enlaces legales. La primera versión reutilizaba keyframes arrive existentes (sustituida por el port descrito arriba),
sin capa pintada; sustituye entrada previa del icono700ms/12px/escala. Hover del
icono1.05 y orbe se conservan. Cabecera entra una sola vez por esta instrucción,
y permanece estable durante sesión/edición; no se remonta ni se repite entrada.
Movimiento reducido muestra todos los grupos estáticos desde el inicio.

Validación: typecheck/build y QA Chrome de carga/recarga aprobados. Comprobados
valores de seis grupos, ausencia de pseudo-elemento en inicio/mitad/final,
capturas de recarga y ausencia de reinicio al editar.390/320px con texto200%,
sin overflow/errores CSP/hidratación. QA login/legal previo aprobado: orbe/hover,
links/retorno/SSR sin JS y1440/390/320. Capturas en
apps/mobile/build/ui-preview/login-reload revisadas. git diff --check aprobado.
Sin cambios de autenticación, SQL, Flutter o despliegue. Siguiente paso:
valoración visual del usuario; OAuth real conserva su configuración pendiente.

## Icono, orbe y enlaces legales —18/10/2026

Por solicitud del usuario se adapta la entrada del icono y hover1.05 de
sader-panel: animación de aparición700ms, hover/foco300ms y movimiento reducido
estático. Editar campos o comprobar sesión no repite la entrada. El orbe ya
existente en login pasa a strong0.62, con colores celestes y sin radial fijo que
oculte su movimiento. AmbientPageShell reutiliza fondo y BackgroundGlowOrb en
login y documentos legales; landing conserva sus estilos e intensidad.

/login añade enlaces reales a /terms y /privacy. Documentos públicos SSR,
composición compartida LegalPage sin dominio/ViewModel vacíos, índice con anclas,
retorno glass al login, enlaces cruzados y mailto al contacto. El usuario confirma
sergiotlv51@gmail.com y korMind cuando sea necesario identificar al responsable.
Contenido redactado como documentos del servicio, sin referencias a MVP/borrador,
sin inventar domicilio, razón social completa o plazos de conservación. Se usa
korMind en identificación y privacidad; el resto mantiene Entre Huellas.

No se crea registro de aceptación/consentimiento ni se modifican cookies, roles
o datos de autenticación. Sin cambios SQL/Flutter, envío de correos o despliegue.
Validación: typecheck,30 pruebas y build Nuxt aprobados. Chrome de producción
con fixtures: entrada/hover del icono, orbe animado, ausencia de reinicio al editar,
movimiento reducido estático; enlaces, retorno glass, anclas y mailto correctos;
SSR sin JavaScript en documentos. Renders1440/390/320 con texto200%, sin overflow
ni errores CSP/hidratación. Se corrigió ajuste de títulos largos para permitir
lectura con texto ampliado. Capturas revisadas en
apps/mobile/build/ui-preview/login-legal. QA completo de login previo también
aprobado, incluidos Google/Facebook fixture. git diff --check aprobado.
Siguiente paso: valoración visual del usuario; OAuth real sigue pendiente de
configuración. No se publica ni despliega.
[Documentos legales](documentos-legales.md) detalla contenido, recorrido y validación.

## Acceso social y formulario estable — 18/10/2026

Se retira el skeleton que sustituía el formulario al comprobar sesión. /login
renderiza el formulario estático desde SSR, mantiene el mismo árbol durante la
consulta y deshabilita envíos con aria-busy hasta terminar, sin shimmer por simple
deshabilitación. La entrada no se repite por comprobación o edición. Se elimina
el texto «Acceso para cuentas autorizadas…». Skeleton de datos de moderación
permanece; este formulario no muestra datos remotos.

Se añaden Continúa con Google/Facebook y separador «o continúa con» siguiendo
móvil, con SocialSignInButton compartido por ambos proveedores e iconos locales.
StartSocialSignIn/CompleteSocialSignIn expresan operaciones de dominio,
HttpSocialSignInRepository y fuente Supabase encapsulan HTTP; AccessViewModel
coordina busy/proveedor, toast y descarte tardío. Plugin compone dependencias.

OAuth servidor PKCE: POST same-origin /api/moderation/oauth/start, redirect a
Supabase y retorno GET /api/moderation/oauth/callback?flow=…&code=…. Cookie de
flujo AES-GCM/HttpOnly/SameSite Lax, scope /api/moderation/oauth,600s, state aleatorio
y verifier privado; código se intercambia solo en servidor. Callback limpia cookie
de flujo y valida estado/expiración antes de intercambiar. Auth/rol se verifican
antes de guardar la cookie de moderación, que conserva SameSite Strict y scope
/api/moderation. No tokens/verifier en payload cliente ni localStorage, ni roles automáticos.
Solo GET callback admite navegación cross-site; las otras API mantienen bloqueo,
protección de origen y límites. Retorno fijo, sin open redirect. Supabase consume
el código una sola vez; pruebas de replay incluidas.

Validación local: typecheck,30 pruebas unitarias/arquitectura, build y8 pruebas
de servidor aprobados. Chrome fixture: ambos proveedores recorren inicio/retorno
y cierre, más flujos previos; formulario SSR sin skeleton/texto retirado. Renders
1920/1440/731/390/320 y texto200% sin overflow/CSP/hidratación; capturas escritorio
y pequeña revisadas en apps/mobile/build/ui-preview/web-login.

Pendiente configuración local (clave publicable, secreto y PUBLIC_WEB_ORIGIN),
habilitación Google/Facebook y allowlist de callback web en Supabase, y demo con
cuentas reales. Proveedores móviles no implican URL web autorizada. Sin cambios
remotos, SQL, Flutter, despliegue o cierre de historia. Siguiente paso: configurar
y verificar la autenticación real; no reaplicar030.

Cancelación del proveedor vuelve a /login?reason=oauth-cancelled con toast;
error/estado incorrecto/código inválido vuelve con oauth-failed; rol ausente
vuelve con forbidden. Reiniciar desde un botón tras fallo. Solo el flujo más
reciente del navegador conserva cookie válida; un flujo anterior falla cerrado.
La autenticación OAuth puede crear/vincular una identidad en Supabase según
su configuración, pero no asigna permisos de revisor ni crea un panel por rol.

Referencia técnica: [PKCE Supabase](https://supabase.com/docs/guides/auth/sessions/pkce-flow)
y [exchangeCodeForSession](https://supabase.com/docs/reference/javascript/auth-exchangecodeforsession).

## Login inspirado en acceso móvil y sader-panel — 18/10/2026

Por petición del usuario, /login toma la composición del acceso móvil y la
columna concentrada de sader-panel, manteniendo Arial/Helvetica/sans-serif.
Marca oficial grande con nombre en dos líneas, título y lema; formulario directo
sin tarjeta exterior ni cabecera/footer institucional duplicados. WebShell
incorpora variante minimal y conserva el enlace de salto accesible.

LoginInput se reutiliza en correo/contraseña: superficie #F5F5F7, radio22px,
iconos de correo/candado, etiquetas flotantes persistentes y control accesible
Mostrar/Ocultar contraseña. Botón Entrar carbón #111111 y texto blanco como
en móvil, cápsula64px; es variante de login autorizada por esta solicitud.
Fondo blanco/celeste/cream y BackgroundGlowOrb soft conservados. Cabecera fuera
del reveal; edición y visibilidad no reinician entrada; movimiento reducido
respetado. No se copian acciones sociales/registro/recuperación que no tengan
implementación web en este alcance. Autenticación, roles y redirecciones iguales.

Validación: typecheck,27 pruebas y build aprobados. QA Chrome de login con
fixtures aprobado (autenticación/roles/redirects/logout/caducidad/reintento),
además de Arial, ausencia de tarjeta y mostrar/ocultar sin perder el valor.
Renders1920/1440/731/390/320, texto200% en320, sin overflow ni errores
CSP/hidratación. Capturas escritorio/móvil/pequeña revisadas en
apps/mobile/build/ui-preview/web-login. Configuración remota/cuenta revisora
y otros navegadores pendientes; sin despliegue ni cambios SQL/Flutter.
Siguiente paso: valoración visual del usuario y acceso real tras configurar servidor.

## Corrección de consulta anónima de sesión — 18/10/2026

La captura del usuario muestra aviso al abrir /login. Diagnóstico local: GET
/api/moderation/session sin cookie devolvía503 porque se validaba configuración
antes de reconocer ausencia de sesión. .env.local tiene SUPABASE_URL pero faltan
SUPABASE_PUBLISHABLE_KEY, MODERATION_SESSION_SECRET y PUBLIC_WEB_ORIGIN.
Solo se inspeccionó presencia de variables, sin mostrar ni modificar secretos.

readModerationSession devuelve401 si no hay cookie antes de componer backend.
Con cookie presente conserva descifrado/Auth/rol y errores reales; login sigue
fallando cerrado si la configuración está incompleta. No se ocultan fallos503
ni se otorgan permisos. Configuración de acceso real sigue pendiente.

Validación: typecheck/build y7 pruebas de servidor de producción aprobados,
incluida regresión sin configuración (sesión anónima401, cookie suministrada503,
login503). Nuxt dev5173 comprobado: sesión sin cookie401, formulario visible sin
toast de conexión y /moderacion redirige a /login. git diff --check aprobado.
Sin cambios de variables, SQL o despliegue. Siguiente paso: configurar servidor
local y comprobar acceso con cuenta revisora real.

HU-14.3 / RF-22,33; issue #45 como recorrido de acceso a moderación existente.
Implementación de login separado por instrucción explícita del18/10/2026.
No equivale a una autenticación web general para todos los roles futuros.

## Qué hace y recorrido

Por autorización del usuario se crea /login como página separada; /moderacion
ya no contiene formulario. LoginScreen/AccessViewModel consumen AccessModeration
y el repositorio HTTP existentes, sin consultar la cola desde el login.
Instancias por consumidor, sin estado privado singleton. Usa WebShell,
BackgroundGlowOrb soft, ActionButton, TopToast y ContentSkeleton, con referencia
visual web vigente, campos accesibles, shake/invalid y shimmer de trabajo real.

Sin sesión, /moderacion redirige a /login; al entrar o visitar /login con sesión
autorizada se vuelve a /moderacion. Destino fijo, sin aceptar URLs de retorno
arbitrarias. Rol denegado se anuncia por toast sin acceder al panel. Expiración,
logout y cambios entre pestañas limpian datos y llevan al acceso cuando procede.
Fallo de red/servidor permite reintento, sin tratarlo como ausencia de sesión.

La cookie conserva alcance /api/moderation, HttpOnly/cifrado/SameSite y permiso
por operación en servidor. La primera visita SSR sirve shell/skeleton público,
y la redirección se ejecuta tras montar en navegador; el middleware protege
navegaciones cliente posteriores. No se afirma redirección HTTP3xx en SSR.
Sin registro, roles nuevos, panel de usuario, cambios SQL/Flutter o despliegue.

## Campos, reglas y feedback

Correo obligatorio con formato y máximo254 caracteres; contraseña obligatoria
hasta1024, autocomplete username/current-password y envío mediante Enter.
Dominio valida antes de enviar. Contraseña se limpia tras el intento o cambio de
pestaña/sesión y al desmontar; no se persiste en navegador. Doble envío bloqueado.
Validación, credenciales inválidas, acceso denegado y fallos van al toast superior;
sin mensajes bajo inputs. Borde/aria-invalid y shake para datos inválidos.
Formulario estático disponible durante la comprobación inicial; controles
bloqueados hasta terminar. Botón Entrar conserva etiqueta y shimmer al enviar.
Cabecera fuera del reveal, sin reinicio de animación al editar. Movimiento reducido
estático; decoración no intercepta eventos ni foco.

## Persistencia y permisos

Sin migraciones ni tablas nuevas. Usa cuentas existentes y endpoints
/api/moderation/session, login y logout. Auth y RPC autorizan cada operación;
login con cuenta sin rol no establece acceso a la cola. El guard organiza
navegación; no sustituye esos controles. La sesión móvil sigue independiente.

## Errores, reintentos y ciclo de vida

401 requiere acceso;403 muestra denegación.503/red conserva posibilidad de
reintentar; en moderación se muestra Reintentar conexión y permanece la ruta.
BroadcastChannel coordina cambios entre pestañas; sesión expirada o perdida borra
contenido privado antes de salir. La disposición invalida respuestas tardías.
Parámetros reason solo seleccionan mensajes locales conocidos; no se reflejan
mensajes arbitrarios ni se acepta un redirect externo.

## Dependencias y activación

Configuración Nuxt/Supabase y cuenta revisora según CONFIGURACION y ficha de
moderación.030 ya confirmado aplicado por usuario; no reaplicar. No crea registro,
recuperación de contraseña ni asignación de roles ficticios. Sin despliegue.

## Validación y pendientes

Validación local: typecheck,27 pruebas unitarias/arquitectura, build Nuxt y
6 pruebas de servidor de producción aprobados. Chrome con backend fixture:
login, validación, denegación de rol, Enter, destino fijo, sesión existente,
logout entre pestañas, recuperación503 y caducidad. QA moderación aprobado
(cola/evidencia/decisiones/reintentos/revocación); sin errores CSP/hidratación.
Renders1920/1440/731/390/320 y texto200% en320, sin overflow; escritorio y
tamaño pequeño revisados en apps/mobile/build/ui-preview/web-login.
Pendiente acceso con cuentas/configuración remotas reales y otros navegadores.
030 confirmado previamente por usuario; no reaplicarlo. Sin publicación/GitHub.

Comprobaciones reproducibles: npm run typecheck, npm test, npm run build,
npm run test:server y scripts/check-login-browser.mjs / check-moderation-browser.mjs
con PLAYWRIGHT_MODULE y CHROME_PATH. Los fixtures no acreditan login remoto real.
