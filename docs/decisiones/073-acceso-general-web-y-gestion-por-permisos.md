# ADR-073: acceso web general y gestión por permisos

Fecha:19/10/2026. Estado: implementada localmente; validación real pendiente.
Autoridad: el usuario aclara que Entre Huellas debe funcionar en web y móvil,
aprueba una entrada común con espacios de gestión y solicita proceder.
Trazabilidad: acceso de HU-01/RF-01,34 en web; conserva HU-14.3/RF-22,33,
issue #45 de moderación. No crea issues ni cierra historias.
Complementa ADR-058/071/072 y sustituye el acceso exclusivo de revisores de071.

## Problema y decisión

El acceso web comprobaba require_content_reviewer antes de guardar sesión.
Una identidad válida sin ese permiso no podía usar la plataforma.
Se separa autenticación general de autorización de operaciones de gestión,
manteniendo una sola aplicación Nuxt. No se crean aplicaciones por rol.

Una cuenta permite operar como usuario en móvil y web sobre el mismo Supabase.
Moderador y administrador son permisos de trabajo diferenciados; no se obliga
a crear otra cuenta para usar funciones normales. No se supone herencia entre
administrador y moderador. La asignación debe realizarse mediante operaciones
privilegiadas de servidor, nunca por registro público o metadatos del proveedor.
Este incremento utiliza únicamente el permiso de revisor ya existente:
no crea un rol administrativo, su gestión ni /administracion vacío.

Se elige acceso común con espacios y navegación adecuados para cada tarea,
en lugar de enviar a todos al panel de moderación o mezclar todas las acciones
en una sola barra. Las rutas y botones no autorizan; cada operación restringida
conserva su validación de servidor y SQL.

## Incremento entregado y límites

- /iniciar-sesion: correo/contraseña, Google y Facebook para cuentas válidas,
  sin exigir rol de moderación.
- /bienvenida: tres pasos sin Omitir; lectura de profiles.onboarding_completed_at
  y finalización mediante complete_onboarding existente, con JWT del usuario.
  La finalización se comparte por cuenta con móvil; no hay indicador global.
- /inicio: nombre, correo y ciudad reales de la cuenta, cierre de sesión,
  enlaces legales/proyecto y acceso a moderación solo al confirmar permiso.
- /moderacion: navegación de regreso a Entre Huellas; rol comprobado de nuevo
  por operación. Retirarlo conserva el acceso general del usuario.
- Landing enlaza al acceso y documentos legales reales.
- ADR-072 aplicado a login y documentos legales; rutas antiguas redirigen308
  a destinos españoles fijos conservando parámetros y hash en navegación cliente.

El inicio web es un incremento de cuenta, no una entrega de paridad completa.
Explorar web, mascotas, reportes, avisos, perfil editable, registro/recuperación
web y administración continúan pendientes. No se presentan menús vacíos,
estadísticas simuladas ni acciones ficticias. No cambia Flutter ni SQL aplicado.

## Arquitectura e identidad

access es una funcionalidad independiente con dominio, casos de uso de acceso,
inicio/finalización social, onboarding y consulta de gestión; repositorios HTTP,
DTO permitidos y fuente/repositorio Supabase REST en servidor. ViewModel reúne
estado y descarta respuestas tras cambio de cuenta o disposición; plugins
componen dependencias por instancia. LoginInput/SocialSignInButton/estilos y
pantalla de login salen de moderation y pertenecen a access. Se retiran los
adaptadores sociales anteriores de moderation para evitar dos flujos de acceso.

La sesión general valida Auth y consulta solo id/display_name/city/
onboarding_completed_at del perfil propio, con clave publicable y JWT del usuario,
RLS/grants existentes. No usa service_role ni confía en user_metadata para roles.
Un perfil ausente/error no se inventa ni se transforma en vacío confirmado.

La consulta separada de permiso de revisión distingue forbidden (sin permiso)
de indisponibilidad (toast/reintento). Fallar la consulta no elimina los datos
ni la sesión general. Onboarding y gestión ligan la petición a la identidad
esperada; una pestaña antigua no actúa sobre una cuenta distinta.

## Cookies, OAuth y compatibilidad

eh_access: cookie HttpOnly cifrada/autenticada AES-256-GCM, SameSite Strict,
Secure en HTTPS, path /api. AAD separado del de la cookie anterior de moderación.
Se reutiliza MODERATION_SESSION_SECRET como secreto servidor para esta transición,
sin exponerlo ni añadir configuración obligatoria. El nombre histórico no
restringe la cuenta a un rol. Clave publicable/URL/origen conservan sus variables.

Duración máxima de una hora o el vencimiento menor del access token. No se guarda
refresh token; expirar exige iniciar sesión otra vez. Cerrar elimina cookies
web generales/anteriores y solicita logout local, sin cerrar sesiones móviles;
un JWT emitido conserva su vencimiento original.

APIs generales bajo /api/access, con control de origen, cuerpos/tiempos acotados
y límites compartidos con acceso anterior. SSR privado entrega solo shell/skeleton,
sin datos de cuenta ni tokens en HTML/payload. BroadcastChannel comunica cambios
de identidad/cierre sin transportar tokens y elimina datos anteriores.

PKCE mantiene el callback autorizado /api/moderation/oauth/callback y cookie
temporal eh_oauth con path /api/moderation/oauth: son contratos de integración.
El callback valida flujo, expiración y verifier, intercambia en servidor, guarda
la sesión general y dirige a /bienvenida o /inicio. Cancelación/fallo retornan
al acceso español. Los endpoints anteriores de inicio OAuth se conservan y
ahora producen el mismo acceso general; no hay elevación de permisos.

Moderación acepta la sesión general con preferencia sobre la cookie anterior;
las APIs anteriores de acceso de revisores siguen restringidas para compatibilidad.
La comprobación directa inicial espera al montaje antes de redirigir para evitar
desajustes de hidratación, y verifica cuenta/onboarding antes de cargar denuncias.

## Validación y activación

Pruebas unitarias/dependencias, typecheck, build Nuxt, servidor construido y
Chrome con fixtures verifican cuentas normales/revisoras, permisos revocados,
onboarding, errores/reintentos, cookies/CSRF/identidad, OAuth, redirecciones,
SSR sin datos privados, cierre entre pestañas, expiración y tamaños con texto200%.
La prueba arquitectónica impide imports de data/presentation entre funcionalidades.

Resultados concretos en ESTADO y ficha acceso-web. Estas pruebas no certifican
Google/Facebook reales, allowlist remota, cookies HTTPS en producción ni sesiones
Android reales. No se asignan roles ni se modifican proveedores/despliegue.
Siguiente incremento de producto: definir y entregar un recorrido web de usuario
completo reutilizando contratos existentes, empezando por Explorar.

