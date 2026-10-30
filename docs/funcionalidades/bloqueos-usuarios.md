# Bloquear y desbloquear cuentas

Integración23/10 con HU-14.4: se conserva035 de apelaciones y el complemento
local de contacto cambia a036/fuente122 con el mismo cuerpo SQL. Los nombres035
anteriores de contacto quedan sustituidos en el repositorio; no ejecutar ambos
como incrementos distintos. La integración y su validación se registran en ESTADO.

HU-14.2 / RF-23 / issue #44. Implementación móvil/web/SQL en
`feature/user-blocking`, 23/10/2026. [ADR-130](../decisiones/130-bloqueos-de-interacciones-entre-cuentas.md).

## Qué hace y recorrido

El bloqueo impide nuevos avisos vinculados y avistamientos con sesión y oculta el
contacto del reportante (nombre, teléfono y foto) entre ambas cuentas, según
confirmación expresa del usuario. Cada persona administra solo su elección. Si ambas bloquean,
desbloquear una elección no retira la de la otra persona.

Móvil: ficha perdida/encontrada → Bloquear cuenta del reportante → confirmación
del alcance → resultado del servidor. La revisión privada de un avistamiento
autenticado permite bloquear a su reportero; uno anónimo no tiene esa acción.
Perfil → Cuentas bloqueadas → lista paginada → Desbloquear → confirmación.
El contenido propio no muestra un control de autobloqueo.

Web: Perfil → Cuentas bloqueadas (`/cuentas-bloqueadas`). Explorar ofrece
Gestionar bloqueo del reportante y lleva el contexto de la ficha a esa pantalla.
La cuenta y elecciones se comparten con Android. La ruta usa acceso global de
cuenta y onboarding; cada API vuelve a verificar sesión, identidad esperada y
onboarding. El SQL valida la propiedad de la relación.

## Reglas y límites

- Interacciones afectadas: publicación de avisos `sighting`/`with_reporter`
  vinculados a búsquedas perdidas/comunitarias y nuevos avistamientos privados
  con `reporter_id` verificado por el servidor.
- Se conserva el contenido anterior, recibos y cronología; reintentar un envío
  ya guardado no crea otro y puede devolver su recibo después del bloqueo.
- Las fichas, lista/mapa, Guardados, denuncias, moderación y cierre conservan
  sus permisos. El contacto y su foto se ocultan entre las cuentas bloqueadas;
  el autor conserva su edición y los terceros autorizados su lectura. Al
  desbloquear, solo reaparece lo que el autor todavía comparte por caso.
- El QR sin cuenta continúa disponible; no se puede asociar un visitante anónimo
  con una cuenta bloqueada. La UI explica estos límites antes de confirmar.
- Sin directorio, búsqueda de cuentas, chat, teléfono editable como objetivo,
  suspensión de cuentas ni mensajes a la persona bloqueada.

## Persistencia y permisos

Plan034 después de033; fuentes115–118, migración
`20261023003400_user_blocks.sql` y patch034 generados mediante
`Build-UserBlocksPatch.ps1` / `Build-RunAll.ps1`.
Después, plan036/fuente122 y migración/patch036
`20261023003600_block_case_contacts.sql`, mediante `Build-BlockCaseContactsPatch.ps1`,
añaden el ocultamiento confirmado sin reescribir034. Las lecturas RPC y las
políticas restrictivas existentes de avatar usan `case_contact_visible`.
No se borran ni alteran consentimiento, número o versión del contacto.

`user_blocks` guarda propietario, cuenta destino, UUID de relación, etiqueta de
contexto, elección, versión y fecha. RLS sin grants directos, también para
`service_role`. Solo RPC autenticadas para preparar/listar/cambiar elecciones
propias. Preparar deriva el autor en SQL desde un recurso autorizado y puede
crear una relación inactiva. No activa bloqueos por abrir una ficha.

DTO permite únicamente UUID de relación, etiqueta de contexto, elección y
versión. Sin perfiles ajenos, teléfono, identificadores de cuentas o evidencia.
La lista propia pagina de20 y conserva la relación para desbloquear aunque
desaparezca la ficha. La elección contraria no se revela ni se modifica.

Triggers de `found_cases` y `public_sightings` rechazan escrituras nuevas
afectadas, incluidas las peticiones directas y el adaptador autenticado Nuxt.
El rechazo revierte la transacción y sus efectos. SQL emplea lock por pareja
para serializar elección y contribución, con límites de espera en las RPC.

## Errores, reintentos y ciclo de vida

Sin éxito antes de confirmación. Respuesta ambigua congela UUID de relación,
elección y versión; reintentar repite la misma orden y bloquea envíos opuestos.
Conflicto exige consultar de nuevo y no pisa una elección posterior. El estado
remoto permite recuperar el resultado al volver a entrar.

Carga inicial con skeleton, acciones con shimmer/etiqueta estable, refresh
con contenido conservado. Errores/resultados en toast superior; fallo de lectura
no se presenta como lista vacía. Cambios/errores de sesión y disposición ocultan
datos y descartan respuestas antiguas. Autorización/CAS se comprueba en servidor.
El error de contribución bloqueada tiene traducción propia, distinta de sesión
inválida y respuesta incierta; conserva lo escrito para salir o reintentar.

## Activación y validación

1. Verificar prerrequisitos hasta033. Aplicar los patches034 y036 completos en desarrollo,
   con el procedimiento versionado; no reaplicar030 ya confirmado por el usuario.
2. Actualizar/reiniciar Nuxt y Flutter conjuntamente con el nuevo contrato.
   Reutiliza Auth, variables privadas de cuenta web y URL del servidor de
   avistamientos Android. No requiere nuevas variables, roles ni Firebase.
3. Usar A/B/C reales: A bloquea B; intentar ambas direcciones en avisos y
   avistamientos, mediante UI y llamadas directas; C conserva sus operaciones.
   Reiniciar, cambiar de cuenta, desbloquear y comprobar bloqueo contrario.
4. Validar respuesta perdida, conflicto de versión, retirada del recurso,
   contacto/foto ocultos, terceros autorizados, consentimiento intacto,
   QR anónimo, denuncias, cronología y una carrera con conexiones independientes.

Móvil vuelve a consultar todos los contactos al terminar una operación de bloqueo,
incluido un resultado ambiguo; nombre/teléfono/foto anteriores se retiran durante
la revalidación. La lectura al pulsar llamar/SMS revalida igualmente el permiso.
Las URLs de foto ya firmadas pueden durar60s y los datos previamente obtenidos
no pueden recuperarse de otras aplicaciones o dispositivos.

Evidencia local final:526 pruebas Flutter,77 web,30 de servidor Nuxt y50 SQL aprobadas;
28 regresiones móviles tras ajustar rechazo conocido y18 de bloqueos/arquitectura
tras revisar DTO/composición.23 de bloqueos/contactos/arquitectura tras confirmar
el contacto, con teléfono retirado y restaurado por revalidación. Cinco escenarios
SQL de bloqueos incluyen contacto/foto, terceros y consentimiento intacto.
Publicación RPC y ambas direcciones comprobadas. Formato/análisis, typecheck y build correctos.
Chrome del build: entrada desde Perfil, acceso global, cancelación, reintento
ambiguo sin doble escritura, recarga, refresh fallido, desbloqueo, normal/reducido
y1440/390/320 con texto200%, sin overflow/CSP/hidratación. Capturas revisadas en
`apps/mobile/build/ui-preview/user-blocks` y `web-user-blocks`.

Faltan patches034/036 remotos, demo Android/Supabase real, Safari/Firefox y concurrencia
hosted multiconexión. PGlite y fixtures no certifican esos escenarios. Sin
despliegue, asignación de roles ni cierre de la historia/épica por esta entrega.

Integración23/10 de ambas funcionalidades:537 pruebas Flutter,83 web,31 de
servidor y55 SQL aprobadas; formato/análisis/typecheck/build correctos. Chrome
sobre el build integrado vuelve a validar ambos recorridos con fixtures. El
router real móvil prueba acceso a bloqueos en sus tres etapas de cuenta y
conserva las regresiones de apelaciones. Evidencia local; activación y demo
remotas pendientes, como se detalla en ESTADO.
