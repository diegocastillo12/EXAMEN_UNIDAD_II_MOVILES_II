# ADR-132: cola persistente de envíos Android

Fecha: 23/10/2026, America/Lima. Estado: implementado localmente; validación Android/Supabase pendiente.
Trazabilidad: HU-15.2 / RF-32 / issue #48, S6. Dependencia: HU-15.1/#47/ADR-131.

## Contexto y alcance autorizado

El usuario pide continuar con HU-15.2 después de explicar el recorrido de cola y
reintentos. HU-15.1 conserva su validación Android pendiente; avanzar no la cierra.
Los formularios ya congelaban UUID/payload al publicar pero no tenían una intención
persistente de reintento ni registro duradero del recibo. Un timeout de la UI no
prueba que la operación remota haya terminado.

## Decisión

- Ampliar la funcionalidad `offline_drafts` con entidades/contratos/casos de uso de
  cola, transporte por las operaciones de dominio existentes, estado/ViewModels y
  pantalla Envíos. Ningún import de data/presentation cruza funcionalidades; app
  compone navegación y lifecycle. Providers declarativos inyectan dominio.
- Esquema local SQLite2: `submission_queue`, clave cuenta/UUID y fingerprint SHA-256
  de los campos reales del comando y bytes de evidencia. La migración1→2 preserva
  borradores. Pendiente, en curso, fallido y publicado son estados persistentes.
  Borrador sigue separado: editar no autoriza publicación ni encola automáticamente.
- Encolar antes de red. La transacción enlaza UUID/payload; una reclamación CAS y
  un nonce protegen el intento y su finalización. Un solo Future por cuenta/UUID
  comparte intentos manuales/automáticos. Dos repositorios del mismo proceso no
  pueden reclamar dos veces. Un proceso nuevo recupera reclamaciones antiguas como
  pendientes, conservando comando y evidencia; no cambia su UUID.
- Solo las operaciones PublishLostCase/PublishFoundCase/SubmitSighting y sus
  validaciones de recibo confirman. El recibo validado se guarda antes de mostrar
  publicado; después se retira el borrador y los bytes nuevos de la fila de cola.
  Una limpieza fallida no provoca otro envío: el recibo durable resuelve el replay.
  Una confirmación válida tardía del mismo intento también actualiza el editor;
  sustituye la expectativa anterior de ignorarla tras un timeout de presentación.
- Los snapshots de mascota y URLs firmadas no forman parte del fingerprint; sí la
  versión/id de mascota, fotos seleccionadas, instante y campos enviados. Rechazar
  payload incompatible antes de HTTP. Cambiar un rechazo conocido invalid/photo
  exige una nueva acción explícita Publicar; conflictos y publicados no se reemplazan.
  No crear silenciosamente otro UUID para sortear conflicto o respuesta incierta.
- Transporte/timeout/busy conservan pendiente con backoff5/15/30/60/120s. Rechazo,
  bloqueo, cierre, límite, autorización y conflicto detienen la automatización y
  exigen revisión/reintento explícito. La pausa de la app no convierte un rechazo
  definitivo recibido en un fallo transitorio.
- Sincronizar al entrar/volver y comprobar cada15s mientras la app está activa, con
  sesión, bienvenida global completada, recuperación inactiva y la misma cuenta
  autorizada por app. No inferir éxito por Wi-Fi. Pausa/logout/cambio de cuenta
  impiden iniciar otro elemento. Una operación ya iniciada puede terminar; las
  fuentes comprueban identidad entre RPC/fotos y antes/después de autenticación.
  Sin servicio Android de segundo plano, WorkManager ni nuevo proveedor/backend.
- Descarte explícito retira intención pendiente/fallida de forma atómica; no puede
  retirar una reclamación activa ni un recibo publicado. Encontrado conserva su RPC
  de descarte autorizado antes de borrar datos locales. Si falla esa RPC se conserva
  el borrador/UUID para revisión manual; no se afirma reversión remota.
- Perfil → Envíos y enlace desde Borradores/previas. Estados e intentos son datos;
  motivos/errores van al toast superior. Skeleton inicial, shimmer en acciones y
  progreso real, bloqueo de doble acción, texto ampliado y navegación compartida.

## Consecuencias y límites

Sin SQL remoto, nueva autorización, modificación de políticas ni paridad offline
Nuxt. La cola puede reintentar al volver con la misma cuenta; con app cerrada/pausada
no se promete sincronización. A lo sumo el backoff vigente más el siguiente sondeo
precede al nuevo intento. Los temporizadores/reclamaciones locales no sustituyen
la deduplicación/autorización del servidor. Un timeout físico puede dejar trabajo
remoto pendiente: todo replay usa la misma clave y contenido.

Los recibos/metadatos quedan en el dispositivo para el historial; se retiran bytes
nuevos tras confirmación. La base ya está excluida de backup/traslado por ADR-131.
No hay credenciales, tokens ni contacto privado en la cola. La caché de fichas
HU-15.3 sigue fuera del incremento. Rendimiento con colas/fotos máximas y prueba
Android/Supabase real permanecen pendientes; no se cierra la historia por fixtures.

## Evidencia

Migración real1→2, cierre/reapertura y cambio de proceso, bytes/clave/instante,
pérdida antes/después de persistir, replay con un único registro simulado, CAS,
reclamaciones tardías, rechazo y resolución explícita, pausa/cambio de cuenta,
recibo inválido, cancelación segura y UI/acceso. Resultados finales en ESTADO y
[ficha](../funcionalidades/envios-pendientes.md). Gradle/Java sigue bloqueando
la compilación nativa con Unable to establish loopback connection.
