# Preferencias de alertas por cuenta

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

Corrección20/10/2026: conservar la transición y el scroll al resolver la consulta,
sin claves derivadas de datos pendientes. Skeleton sin cortina/stagger y resultado
inmediato, sin segunda entrada. Selecciones, errores, reintentos y aislamiento
entre cuentas conservados.24 regresiones nuevas compartidas con ubicaciones;
suite ampliada61/61 con fondo animado desactivado para pumpAndSettle y análisis
limpio. Evidencia y límites en [ESTADO](../ESTADO.md); revisión Android pendiente.

**Auditoría de seguimiento18/10:** HU-02.2/#27 y épica #2 en Done: configuración por cuenta integrada,011 confirmado y validación HU-02 registrada. FCM es HU-12.3 pospuesta y no bloquea estas preferencias.027 ya está confirmado; seguimiento/bandeja conservan integración/demo propias pendientes.

18/10/2026, instrucción del usuario: FCM/Firebase pospuestos (ADR-068).
Las preferencias de recepción/tipos/bandeja siguen operativas; la elección
de teléfono solo guarda la preferencia futura, con explicación explícita.
No registra token, no pide permiso ni activa un proveedor en este incremento.

Ajuste del15 de octubre: etiquetas Zona/Zonas se denominan Ubicación/Ubicaciones; contratos y preferencias persistidas conservados. Formato/análisis, sin nuevas pruebas por instrucción del usuario. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

Módulo: `alert_preferences`. HU-02.2 / RF-02,16;
[issue #27](../backlog/027-HU-02.2.md).

## Qué hace y cómo se usa

Desde Perfil se configura si recibir alertas, qué tipos interesan y qué canales
se prefieren. Los tipos son mascotas perdidas, encontradas y novedades de casos;
los canales son dentro de la app y push. Pausar conserva las elecciones.

Estas elecciones se guardan por cuenta. HU-12 consume sus valores en servidor
para seleccionar destinatarios y revalidar reintentos. Seguimiento/bandeja y
registro de teléfono se implementan en notifications; esta pantalla no pide
permiso ni maneja SDK de Firebase. 027 confirmado y FCM pospuesto (ADR-068), sin afirmar
entrega real. [Ficha de alertas](seguimiento-y-alertas.md).

## Reglas, estado y persistencia

Sin configuración guardada: recepción desactivada; tres tipos seleccionados;
canal dentro de la app activo y push desactivado. Para habilitar recepción debe
haber al menos un tipo y un canal. Versión cero representa primera escritura.

SaveAlertPreferences envía la selección completa y versión esperada. El servidor
comprueba sesión, reglas y versión; un reintento idéntico reconoce el resultado,
guardar sin cambios no altera versión y una selección incompatible genera conflicto.
Lectura propia con RLS y RPC protegida; no se acepta un propietario arbitrario.

El editor conserva borrador tras fallo y bloquea dobles envíos. Salir, consultar
versión actual o refrescar cuando se perderían cambios pide confirmación.
Cambio de identidad limpia datos anteriores; una misma cuenta recuperada tras
error puede volver a cargar. Éxito superior solo tras confirmación del servidor;
errores contextuales. No hay cola offline persistente.

## Dependencias y validación

Patch011; ReadAlertPreferences/SaveAlertPreferences y repositorio Supabase.
El usuario reporta parche aplicado y validación de HU-02; las pruebas y pendientes
detallados están en [ESTADO](../ESTADO.md). Verificar cambio de cuenta, pausa,
reapertura, selección inválida y conflictos; no probar recepción real como si
estuviera implementada.

HU-12 deberá consultar preferencias vigentes al generar/reintentar avisos y
persistir la notificación antes de intentar push. [ADR-019](../decisiones/019-preferencias-alertas-por-cuenta.md).


## Reutilización visual — 10 de octubre de 2026

Confirmaciones delegadas al diálogo completo confirmActionDialog de core, con acciones de geometría/alineación y adaptación compartidas, sin layouts propios. En reportes, terminar carga conserva la entrada del skeleton y no dispara cover/stagger nuevos; vista previa y confirmación conservan su transición. Validación local y límites en ESTADO; no cambia persistencia/permisos ni cierra la historia remota.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Corrección de consistencia — 11 de octubre de 2026

Errores de consulta, validación, guardado y conflicto usan toast; sin mensajes intercalados en opciones. Se conservan selecciones y acciones de reintento/actualización.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.
