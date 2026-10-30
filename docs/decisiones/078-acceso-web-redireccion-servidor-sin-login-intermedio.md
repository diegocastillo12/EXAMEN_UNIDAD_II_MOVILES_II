# ADR-078: entrada web sin login intermedio con sesión activa

Fecha:19/10/2026. Autoridad: el usuario solicita entrar directamente al destino
de su sesión, sin mostrar login ni skeleton intermedio, y autoriza implementarlo.
Trazabilidad: HU-01/RF-01,34; corrección del acceso web de ADR-073, sin ampliar
funcionalidades ni cerrar historias. Sustituye su alcance /api de eh_access y
la comprobación posterior al montaje para entrar al login.

## Decisión

La cookie general eh_access pasa a path / para que el servidor pueda recibirla
en /iniciar-sesion. Conserva HttpOnly, cifrado AES-GCM, SameSite Strict, Secure
en HTTPS y el vencimiento original (máximo una hora, sin refresh token).
No se expone a JavaScript ni se serializa en HTML/payload SSR.

El middleware de servidor session-entry se ejecuta después de security:
valida la sesión mediante el caso de uso existente (Auth y perfil propio/RLS)
y responde302 a /inicio o /bienvenida antes de renderizar login.
Cookie inválida/expirada se elimina y permite el formulario. Un fallo de backend
conserva la cookie y lleva a /inicio, donde existe recuperación mediante reintento;
no equivale a ausencia de sesión ni exige introducir credenciales otra vez.
No se aceptan destinos externos ni se usa la redirección como autorización.

Para sesiones existentes con path /api, una entrada sin cookie visible pasa por
/api/access/entry. Ese endpoint puede recibir la cookie antigua, la valida,
elimina el alcance anterior y establece path / sin extender su vencimiento.
Después redirige al destino real sin renderizar login. Sin sesión devuelve
/iniciar-sesion con entry=checked y los parámetros originales. Este marcador
solo termina el salto anónimo; no acredita identidad ni concede permisos.
El middleware cliente lo retira con replace conservando reason y demás parámetros.
Anónimos tienen un salto HTTP adicional; sin JavaScript el marcador puede quedar
en la URL, pero las redirecciones de cuentas autenticadas funcionan igualmente.

En navegación cliente, guest-access espera al ViewModel/caso de uso antes de
montar login. Las instancias se liberan incluso al redirigir; no existe caché
global de identidades. El cierre elimina eh_access en ambos paths. Moderación
conserva su autorización por operación y recibe la misma sesión general.

## Consecuencias y validación

### Corrección de entradas sin sesión a inicio/bienvenida —19/10/2026

La primera implementación solo interceptaba /iniciar-sesion: entrar a /inicio
sin sesión todavía renderizaba su skeleton antes de redirigir desde onMounted.
Por el reporte del usuario, session-entry también comprueba /inicio y /bienvenida
antes del HTML. Sin cookie pasa por el puente existente y llega al formulario;
con cookie inválida la elimina y redirige al login. Con sesión válida conserva
la ruta correcta o redirige según onboarding antes de renderizar la incorrecta.
account-access espera al mismo ViewModel/caso de uso en navegaciones cliente,
sin montar la pantalla de cuenta si falta sesión. Las APIs siguen autorizando
cada operación; el middleware no concede acceso a datos.

Un error de backend en rutas de cuenta permite su shell de reintento existente.
Si ocurre al recuperar cookie antigua en /api/access/entry, /inicio recibe
entry=unavailable para evitar volver al puente en bucle. Ese marcador solo permite
un shell sin información privada: la pantalla vuelve a validar por API y no
obtiene datos sin sesión autorizada. No equivale a sesión anónima confirmada.
Pruebas de servidor y observación de montajes en Chrome verifican ambas rutas
tras logout, recarga, navegación SPA, destinos por onboarding y recuperación503.

El navegador recibe directamente el destino autenticado: no hay formulario ni
skeleton de acceso intermedio. Los datos de /inicio y /bienvenida conservan
su carga actual, sin publicar información privada en SSR. No cambia Flutter,
SQL, OAuth/callback ni la configuración remota. Se amplía el envío de la cookie
a rutas del mismo host para permitir SSR; las respuestas mantienen no-store.

Regresiones de servidor y Chrome comprueban redirección antes del HTML,
onboarding pendiente, cookie antigua con scope real, navegación SPA, acceso
sin JavaScript, parámetros, cookies inválidas, fallo503 y cierre en ambos paths.
La evidencia es local con backend fixture, no confirmación de sesiones remotas.
Resultados y siguiente paso en [ESTADO](../ESTADO.md) y
[ficha de acceso](../funcionalidades/acceso-web.md).
