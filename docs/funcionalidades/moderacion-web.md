# Revisión y moderación de denuncias en la web

23/10, HU-14.4: Denuncias incorpora Revisar apelaciones. El revisor registra
respuesta privada con motivo/cuenta/fecha; el autor consulta su estado desde
móvil/web. No cambia visibilidad automáticamente ni reemplaza decisiones.
[Recorrido, persistencia, activación035 y evidencia](apelaciones-moderacion.md).

21/10: cabecera de Denuncias/Revisar denuncia sin frase decorativa superior,
por petición del usuario. Motivo, tipo/fecha, avisos de privacidad, operaciones
y autorización permanecen; solo cambia la presentación de la cabecera.

21/10, ADR-122: el motivo utiliza TextField compartido con etiqueta flotante,
contador y [piel Sader](controles-web.md). Conserva ViewModel, bloqueo/reintento
y autorización de cada decisión. QA Chrome con fixture pasa denegación por rol,
evidencia, decisión/reintento/restauración, cancelación, revocación, responsive,
texto200%, teclado y CSP/hidratación. Sin confirmación remota.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión en dispositivos reales pendiente.

## Cierre web sin bloqueo remoto —19/10/2026

/api/moderation/logout comparte la semántica de acceso: borra las cookies
generales/anteriores y confirma localmente mientras Nitro completa el intento
remoto mediante event.waitUntil. Se conserva limpieza de evidencia/estado,
confirmación de salida con borradores, avisos entre pestañas y controles de origen.
No promete revocación inmediata de JWT ni afecta sesiones móviles. Pruebas
retienen Supabase y exigen llegar al login antes de liberar su respuesta.
[ADR-082](../decisiones/082-cierre-web-sin-esperar-supabase.md), resultados en
ESTADO; sin nuevos permisos, SQL o despliegue.

## Política de acceso global —19/10/2026

Moderación usa la misma política global de todas las páginas, con permiso de
revisión comprobado antes de renderizar en servidor y montar en navegación
cliente. Se retira moderation-access y su excepción de hidratación. Sin sesión
no aparece shell/skeleton de moderación; sin permiso se dirige a /inicio con
toast de denegación; onboarding pendiente va a /bienvenida. Las APIs mantienen
su comprobación por operación, sin herencia de roles ni autoasignación.
[ADR-079](../decisiones/079-politica-global-de-acceso-web.md), evidencia local en
ESTADO. Fallos de backend conservan reintento; sin SQL ni despliegue nuevo.

## Marca compartida con landing —19/10/2026

Cabecera usa SiteBrand/SiteHeader con la misma posición, color, fuente y tamaños
adaptables de landing, también en responsive y fuera del stagger. Sin cambios
de negocio, permisos o persistencia. Validación local en ESTADO; sin despliegue.
[ADR-077](../decisiones/077-marca-web-compartida-referencia-landing.md).

## Reveal compartido —19/10/2026

Sustituida la utilidad .reveal por StaggerReveal/useStaggerReveal sin capa crema.
Conserva HTML/acciones, no repite entrada por edición/refresh; movimiento reducido
inmediato. QR conserva lectura SSR sin JS. Sin cambios de datos/permisos.
[ADR-075](../decisiones/075-reveal-web-compartido-sin-cobertura-opaca.md); evidencia local en ESTADO,
sin despliegue ni nuevo cierre de historia.

## Acceso general y permiso independiente —19/10/2026

Entrada común /iniciar-sesion → bienvenida por cuenta o /inicio. Revisar denuncias
aparece al confirmar permiso; /moderacion permite volver al espacio de usuario.
Acceso directo comprueba cuenta/bienvenida y rol antes de cargar denuncias.
Un403 de moderación conserva la sesión general y vuelve a inicio. Cada operación
sigue validando Auth/require_content_reviewer y permisos SQL, aun con enlace
conocido o rol retirado. Sin rol administrativo nuevo, SQL, Flutter o despliegue.
[ADR-073](../decisiones/073-acceso-general-web-y-gestion-por-permisos.md).
QA Chrome fixture de cola/detalle/evidencia, decisión ambigua/reintento,
restauración, cancelación, rol revocado/retorno, teclado y responsive aprobado.
Pendiente demo real; las notas de login exclusivo describen el estado anterior.

## Acceso social web —18/10

Google y Facebook disponibles en /login por solicitud del usuario; intercambio
PKCE/validación Auth y rol en servidor antes de crear sesión de moderación.
[Acceso web](acceso-web.md) documenta flujos, configuración/allowlist pendiente
y evidencia local. Sin cambios de permiso, SQL ni ciclo operativo.

## Acceso separado — 18/10/2026

El recorrido vigente es /moderacion sin sesión → /login → /moderacion tras
autenticación/rol válidos. El formulario embebido descrito en notas anteriores
queda sustituido por [Acceso web](acceso-web.md). Se conservan contratos, cookie,
permisos de servidor y datos privados. Revisión remota continúa pendiente.

Validación local: typecheck,27 pruebas unitarias/arquitectura, build Nuxt y
6 pruebas de servidor de producción aprobados. Chrome con backend fixture:
login, validación, denegación de rol, Enter, destino fijo, sesión existente,
logout entre pestañas, recuperación503 y caducidad. QA moderación aprobado
(cola/evidencia/decisiones/reintentos/revocación); sin errores CSP/hidratación.
Renders1920/1440/731/390/320 y texto200% en320, sin overflow; escritorio y
tamaño pequeño revisados en apps/mobile/build/ui-preview/web-login.
Pendiente acceso con cuentas/configuración remotas reales y otros navegadores.
030 confirmado previamente por usuario; no reaplicarlo. Sin publicación/GitHub.

**Confirmación posterior18/10:**030 aplicado según el usuario, sin inspección SQL
remota nueva. No reaplicarlo. Captura de /moderacion acredita render del acceso
sin error visible, no login/rol ni demo completa. El acceso se muestra al no
tener sesión web vigente; la sesión móvil no se comparte con el navegador.


HU-14.3 / RF-22,33; issue #45. Implementación en `apps/platform` y SQL Supabase.
Administración exclusivamente web por instrucción explícita del usuario;
Flutter solo conserva denuncia de contenido, sin pantallas/acciones de revisor.

## Qué hace y recorrido

`/login` → iniciar sesión con cuenta autorizada → `/moderacion` → cola Pendientes/Resueltas
paginada20 → Revisar denuncia → motivo/evidencia escrita y contenido original →
Ver foto bajo petición → elegir decisión/motivo → confirmar → recibo persistido.
Consulta actualizada permite revisar las últimas20 decisiones y volver a la cola.

Tres decisiones: ocultar contenido, restaurar visibilidad o resolver sin cambiar
visibilidad. No recupera/cierra/elimina casos ni suspende cuentas. La denuncia y
el estado operativo siguen separados. Bloqueo de usuarios y apelación son otras HU.

## Campos y reglas

Motivo de decisión obligatorio hasta500 caracteres Unicode. Actor/fecha fijados
por servidor. Cada decisión conserva UUID, versiones de denuncia/recurso,
acción y resultado de visibilidad. El contenido puede haberse retirado: la
denuncia se conserva y no se inventa una ficha. Restaurar no deshace retiro del
autor/cierre ni ocultamiento de una búsqueda vinculada.

## Persistencia y permisos

Plan030/fuentes102–105. Tablas privadas de visibilidad, resoluciones, decisiones
append-only y accesos. Auth verifica cuenta y SQL comprueba rol en cada operación.
Asignación privada en `content_report_reviewers`, sin autorregistro de revisores.
Cola sin evidencia; abrir detalle/foto requiere autorización y deja auditoría.
DTO omite identidad del denunciante, coordenadas privadas y paths de Storage.
Foto primaria procesada mediante proxy autorizado, sin originals ni URLs técnicas.

Ocultamiento excluye proyecciones públicas, QR, Explorar/guardados y permiso de
fotos; avisos/avistamientos heredan ocultamiento del caso. La revisión ordinaria
no muestra avistamientos ocultos; nuevos avisos se rechazan en búsquedas ocultas.
Registros privados propios y el ciclo de vida permanecen. Bytes/URLs firmadas
previamente entregados no se revocan retroactivamente.

## Acceso y sesión

Correo/contraseña de cuentas existentes, sin registro ni concesión de permisos.
Cookie HttpOnly cifrada/autenticada, SameSite Strict, Secure con HTTPS, máximo1h,
sin refresh token ni secretos en JavaScript/SSR/localStorage. Al expirar se exige
nuevo login; logout solo afecta esta sesión web. Cambio de sesión entre pestañas,
expiración/falta de rol/logout/disposición ocultan datos y descartan respuestas
tardías. La landing y el QR no requieren iniciar sesión administrativa.

## Errores y reintentos

Toast superior compartido, invalid/shake y acciones reales. Skeleton inicial y
shimmer durante trabajo real; refresh conserva contenido de la misma identidad.
Vacío solo tras consulta correcta. Reintentos ambiguos conservan UUID/contenido,
sin doble envío; conflicto exige consultar versión actual y conserva motivo si
esa consulta falla. Salida con borrador/resultado ambiguo requiere confirmación.
No se conserva borrador de moderación tras cerrar/reiniciar la página.

## Dependencias y activación

029 confirmado aplicado por usuario; no reaplicarlo. 030 también aplicado según usuario;
configurar/verificar variables nuevas de servidor y asignar explícitamente
la cuenta revisora desde servidor según CONFIGURACION. Actualizar Nuxt y acceder
a `/moderacion`. No requiere instalar/actualizar UI administrativa en móvil.
Firebase/FCM fuera del alcance. No se despliega ni se modifica GitHub aquí.

## Validación

Pruebas SQL de permisos/role revocation, lectura auditada, decisiones/idempotencia,
CAS entre denuncias del mismo recurso, visibilidad pública/QR/fotos/avistamientos,
ciclo operativo intacto y repetición del bundle. TypeScript prueba dominio,
DTO/source, sesión cifrada, ViewModel, cambio de cuenta y disposición.
Producción prueba cookie, Origin/CSRF, SSR sin evidencia, proxy y pérdida de
respuesta; Chrome revisa normal/pequeño/texto200%, teclado y movimiento reducido.
Typecheck/build,25 pruebas web y6 de producción aprobados; regresión SQL40/40
y suite final de moderación4/4 (3 ya incluidos en la regresión). Chrome y renders
1440/731/390/320/1920,320 texto200%, revisados. Resultados/logs y límites en ESTADO;
fixtures no certifican Supabase real.

030 confirmado aplicado. Pendientes: configuración/asignación de rol, demo con dos revisores/cuenta
ordinaria y contención multiconexión hosted. No se cierra HU-14 ni issue remoto
por implementación local. La demo real y publicación se distinguen de pruebas.
