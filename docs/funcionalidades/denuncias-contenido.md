# Denunciar contenido

25/10: desde Compartir ficha móvil, el formulario recibe la identidad del botón
Denunciar y reutiliza la expansión/retorno compartidos. El panel permanece
montado detrás y conserva su scroll al volver, tanto en perdidos como en
encontrados; movimiento reducido inmediato. La confirmación de descarte,
autorización, envío estable y recibo conservan su implementación. Evidencia y
límites de esta integración en [Compartir ficha](compartir-ficha.md) y ESTADO.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Continuación HU-14.3:** la revisión/decisión por moderadores se implementa solo
en la [plataforma web](moderacion-web.md). El móvil conserva este flujo de
usuario, sin administración.030 añade auditoría a lecturas privilegiadas y
visibilidad independiente, sin reescribir029 confirmado aplicado.


HU-14.1 / RF-22; issue #43. Implementación Android/SQL en
`feature/content-reports`. No equivale a cierre remoto de la historia.

## Qué hace y recorrido

Ficha disponible → Denunciar contenido → motivo y evidencia escrita opcional →
Enviar denuncia → recibo guardado → volver al contenido. Incluye fichas de casos
perdidos, búsquedas comunitarias, avisos y reportes anteriores. La revisión
privada de un avistamiento ofrece el mismo acceso con destino fijo.

La denuncia pide revisión; no cambia el estado del contenido ni garantiza una
decisión. El recibo muestra fecha, motivo, evidencia aportada y referencia del
envío. No hay publicación pública de denuncias ni nuevos archivos adjuntos.

## Reglas y campos

Motivo obligatorio, máximo500 caracteres Unicode. Evidencia escrita opcional,
máximo1000. Espacios iniciales/finales normalizados; evidencia vacía se guarda
como null. El recurso viene del recorrido, sin selector ni UUID editable.
Fecha y actor son determinados por servidor. Cliente nunca decide autorización.

## Persistencia y permisos

Plan029, fuentes099–101, tabla `content_reports` con RLS y sin grants directos.
RPC `submit_content_report` autenticada comprueba visibilidad mediante contratos
vigentes. Avistamientos privados exigen acceso del responsable a la cronología.
Un UUID estable y bloqueo transaccional evitan duplicados del mismo envío;
reintento incompatible da conflicto. El recibo persiste aunque se retire el recurso.

`read_content_report` permite lectura al denunciante del propio envío y a revisores
asignados explícitamente por servidor en `content_report_reviewers`, tabla privada
sin autoasignación ni usuarios predeterminados. Usuarios ajenos, incluido el autor
del contenido denunciado, no pueden leer la denuncia si no son denunciantes o
revisores autorizados. No se copian ubicación/fotos privadas del recurso.

## Errores y reintentos

Validación con invalid/shake y toast superior. Guardado con shimmer, etiqueta
constante y bloqueo de doble envío; sin confirmación optimista. Ante respuesta
ambigua se retiene y reintenta la misma orden sin permitir editar su contenido.
Conflicto bloquea otro envío en ese formulario. Salir con borrador o resultado
ambiguo pide confirmación; el borrador no persiste tras reiniciar (HU-15).
Cambio/error de sesión oculta datos; respuestas tardías no confirman otra cuenta.
Reintentar tras recuperar la sesión vuelve a un estado limpio.

## Dependencias y activación

028 aplicado según confirmación expresa del usuario, sin inspección remota nueva.
029 aplicado según confirmación expresa del usuario; no reaplicarlo.
Actualizar/reiniciar Flutter. No hay cambios Nuxt ni despliegue web necesario. Firebase/FCM
está fuera del alcance y no bloquea esta entrega. No hay commit/push/PR/despliegue
por este incremento. Moderación, bloqueo, apelación y cola administrativa son
historias posteriores; no existen guards/pantallas vacíos para ellas.

## Validación y pendientes

Pruebas de dominio/DTO/ViewModel, cambios/errores de cuenta, pérdida de respuesta,
doble envío y disposición; renders390×844 y320×350/texto2 revisados, acciones y
recibo alcanzables por scroll; navegación real desde ficha comunitaria. SQL local
prueba permisos, Unicode, replay/conflicto, revisor/revocación, recurso retirado,
ausencia de cambios operativos y repetición del bundle. Resultado:419 pruebas Flutter y37 SQL aprobadas; análisis limpio, formato
sin cambios. Logs y límites en ESTADO.

029 confirmado aplicado; pendiente demo Android/Supabase real con denunciante, autor, usuario ajeno y
revisor asignado desde servidor; pérdida de respuesta y contención multiconexión.
PGlite no certifica concurrencia hosted. No se declara HU-14 completa.
