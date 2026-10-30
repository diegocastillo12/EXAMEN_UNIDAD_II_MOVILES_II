# Avistamientos desde Android

23/10, HU-14.2: con034 activo, los nuevos envíos autenticados respetan
[bloqueos entre cuentas](bloqueos-usuarios.md) en ambos sentidos mediante el
trigger SQL, también tras pasar por Nuxt. Rechazo específico y datos conservados;
reintentar un envío ya guardado devuelve su recibo. QR sin cuenta conserva acceso.
Actualizar servidor/Flutter junto con034; activación/demo reales pendientes.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Auditoría de seguimiento18/10:** HU-10.2/#37 y épica #10 en Done: implementación integrada en PR60,025 confirmado tras la entrega, persistencia compartida con web y HU-11 posterior operativo. Pruebas existentes/CI aprobadas. No se inventa una prueba remota nueva durante el cambio de seguimiento.

18/10, continuación HU-11: el usuario indicó «ok ya esta» después de las
instrucciones de activación025; se registra confirmación comunicada, sin
inspección remota independiente. Sustituye el pendiente025 de las notas
anteriores; no exige reaplicarlo. [Cronología y revisión](cronologia-y-revision.md)
añade lectura/clasificación privada del responsable en Android, tras activar026.
No modifica el envío ni convierte la evidencia en aviso público.

HU-10.2 / RF-11 / issue #37. Implementación local; historia sin cerrar.
[ADR-065](../decisiones/065-avistamientos-android-y-persistencia-compartida.md).

## Qué hace y recorrido

Desde una ficha de búsqueda abierta, «Reportar avistamiento» abre «La vi» con
destino fijo. Fecha y hora real se eligen por separado; el mapa permite marcar
el punto o usar GPS. Comentario y foto son opcionales; galería y cámara son
alternativas. Enviar entrega un recibo persistido, seguido de retorno a la ficha.
El aviso anterior «La vi o la encontré» conserva su comportamiento público/custodia.
Los nuevos avistamientos privados no aparecen en esa lista de avisos: su revisión
autorizada corresponde a HU-11, todavía pendiente.

## Reglas y campos

Fecha desde 2000, nunca futura; más de 24 horas se identifica como observación
tardía conservando hora observada y recibida. Punto manual o GPS con precisión,
latitud ±85/longitud ±180. Comentario opcional hasta 500 caracteres con contador
interior. Una foto opcional; selección limitada a 8MiB, servidor decodifica y
recodifica JPEG/PNG/WebP a JPEG sin EXIF, hasta1280px/1MiB. No captura referencia
ni exige descripción de mascota. Nunca cierra el caso por recibir un avistamiento.

## Persistencia y permisos

Sesión verificada por Nuxt mediante Supabase Auth. URL base pública tomada de
`PUBLIC_CASE_WEB_URL`, HTTPS; ningún secreto en Flutter. Tabla privada compartida
con web, `public_sightings`; reporter_id de cuenta y actor pseudonimizado asignados
por servidor. Fecha/punto/estado/límites/idempotencia se validan en el mismo comando
SQL que web. Evidencia y punto exactos no pasan al DTO público ni a `found_cases`.
No exige QR generado. RPC app solo servidor; sin lectura/escritura directa cliente.

## Errores y reintentos

Toast superior, shake/invalid y shimmer durante trabajo real, etiquetas conservadas.
Fallo GPS conserva mapa manual; cancelar cámara/galería conserva la foto anterior.
Fecha/punto faltantes impiden enviar. Respuesta ambigua congela UUID/payload y
bloquea edición; Reintentar envío usa la misma orden y no consume otro registro.
Errores definitivos de validación/foto/límite permiten corregir conservando datos.
Caso cerrado/no disponible bloquea otro envío y permite volver. Cambio de cuenta
borra formulario y descarta respuestas tardías. Salir con datos requiere confirmar;
no hay persistencia de borrador tras muerte del proceso ni cola offline de HU-15.

## Dependencias, activación y validación pendiente

Requiere024 aplicado, patch025 generado y servidor Nuxt actualizado junto con app.
[Patch025](../../database/patchs/025_patch_app_sightings.sql),
[migración025](../../supabase/migrations/20261018002500_app_sightings.sql).
No exige volver a aplicar022/023/024 ya confirmados por el usuario.
Validación local, capturas y logs en [ESTADO](../ESTADO.md).
Pendiente activar025/servidor y demo Android autenticada con GPS/cámara/galería,
fotos/teselas reales, reintento tras pérdida de respuesta y permisos hosted.
Sin APK nuevo, despliegue, escritura remota ni cierre de issue desde este incremento.


23/10, HU-15.1: el editor conserva un borrador local por cuenta/contexto, con
UUID y evidencia, recuperación sin red y conservación al salir. Comandos ambiguos
se retoman sin editar su contenido. [Recorrido, persistencia, reglas y validación
pendiente](borradores-locales.md), ADR-131. No activa cola automática ni caché
de fichas. La demo Android de reinicio sin red sigue pendiente.


23/10, HU-15.2/ADR-132: las confirmaciones de Publicar/Enviar pasan por la
[cola persistente de envíos](envios-pendientes.md), con estados veraces, UUID/payload
originales y recibo durable. App activa reintenta transitorios; rechazo/conflicto
requiere acción explícita. Un recibo validado tardío actualiza el editor; un
timeout no inicia otra petición mientras el intento original sigue activo.
Descarte respeta reclamación y autorización remota de encontrado. Validación
Android/Supabase real pendiente; no certifica cierre de esta historia.
