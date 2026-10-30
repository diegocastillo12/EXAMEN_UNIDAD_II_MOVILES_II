# ADR-130: bloqueos de interacciones entre cuentas

Integración23/10: apelaciones ya integrada en main conserva035/fuentes119–121.
El complemento de contacto de esta decisión usa036/fuente122, con SQL idéntico;
se regeneran migración y patch y se conserva034 sin modificaciones.

Fecha: 23/10/2026, America/Lima. HU-14.2 / RF-23 / issue #44.

## Contexto

El usuario solicita implementar HU-14.2 y hacer commit/push al terminar.
El refinamiento pendiente exige enumerar las interacciones existentes. Hoy
existen avisos públicos vinculados (`sighting` y `with_reporter`) y avistamientos
privados con reportero autenticado. No hay chat interno. Los QR permiten aportar
sin cuenta y el contacto tiene consentimiento independiente por caso.

El usuario confirma expresamente impedir nuevas contribuciones entre cuentas
identificadas y ocultar entre ellas el contacto del reportante. Se conserva el
consentimiento almacenado por caso, que sigue siendo necesario tras desbloquear.
Esta confirmación de alcance no acredita aprobación visual ni demo remota.

## Decisión

- Cada cuenta administra exclusivamente su elección A→B. Si A bloquea a B,
  las nuevas contribuciones autenticadas A→B y B→A se rechazan en servidor.
  Desbloquear retira solo la elección propia; B puede conservar B→A.
- Se impiden publicar nuevos avisos vinculados a búsquedas perdidas/comunitarias
  y guardar nuevos avistamientos privados autenticados. Los triggers están en
  las tablas de escritura, incluidos los adaptadores con `service_role`.
- Una pareja ordenada comparte bloqueo transaccional entre la elección y los
  envíos. Los cambios usan versión esperada y reintento exacto; una orden antigua
  no sobrescribe una elección posterior. No se promete concurrencia hosted por
  pruebas PGlite de una conexión.
- El contacto (nombre, teléfono y foto consentida) se oculta en ambos sentidos
  cuando existe cualquier elección activa entre las cuentas. El autor conserva
  edición/lectura de su contacto. El tercero no bloqueado conserva acceso.
  RPC de contacto y políticas existentes de Storage reutilizan
  `case_contact_visible`; no se modifica consentimiento ni se publica contacto
  al desbloquear. Una URL de foto ya firmada puede durar60s; no se recuperan
  datos o fotos obtenidos antes del bloqueo. Móvil invalida las consultas de
  contacto al terminar una mutación, incluida una respuesta ambigua.
- Los envíos ya confirmados conservan sus recibos e historial. Fichas públicas,
  Explorar, Guardados, denuncias, revisión, cierre y QR
  anónimo mantienen sus permisos. Una petición anónima no identifica una cuenta;
  no se atribuye al visitante una identidad a partir de IP, teléfono o cookies.
- El objetivo se deriva de una ficha visible o de un avistamiento privado que
  el responsable puede revisar. No hay directorio de usuarios ni UUID de cuenta
  editable. Un avistamiento anónimo y el contenido propio no ofrecen bloqueo.
- La relación privada tiene un UUID distinto de ambas cuentas y una etiqueta
  tomada del contexto público, sin leer perfiles ajenos. Preparar el control
  puede crear una fila inactiva; solo confirmar activa el bloqueo. La lista
  muestra exclusivamente elecciones activas propias, en páginas de 20.
- La lista propia permite desbloquear aunque se retire la ficha de origen.
  Los identificadores de las cuentas permanecen dentro de SQL, fuera de DTO/SSR.

## Presentación y consecuencias

Flutter: acceso desde ficha y revisión privada; gestión desde Perfil. Nuxt:
gestión desde Perfil y contexto de Explorar en `/cuentas-bloqueadas`, ruta
`account` de la política global. Son operaciones de usuario, sin administración
móvil ni permisos de moderador. Arquitectura por funcionalidad, ViewModels,
casos de uso, repositorios y fuentes SDK/HTTP separados.

Confirmación informa del alcance y de sus límites. Toast superior para resultado
y errores, skeleton inicial, shimmer en acciones y contenido conservado en
refresh. No hay éxito optimista. Una respuesta ambigua conserva relación,
elección y versión para reintentar; conflicto exige consultar el estado actual.
Cambios de cuenta y disposición descartan respuestas tardías. Se reutilizan
shells, botones glass, stagger y confirmación existentes, sin nuevo contrato de
animación. La confirmación web compartida ajusta texto/acciones para 320px/200%.

Plan034/fuentes115–118 se activa después de033; plan036/fuente122 añade el contacto
confirmado por el usuario sin reescribir034. Después se actualizan los clientes.
No se reescriben migraciones anteriores. No requiere Firebase ni secretos nuevos.
La activación remota, prueba Android físico, navegadores adicionales y contención
multiconexión siguen pendientes; HU-14 y el issue no se cierran por evidencia local.

Evidencia y pasos: [ficha](../funcionalidades/bloqueos-usuarios.md) y
[ESTADO](../ESTADO.md).
