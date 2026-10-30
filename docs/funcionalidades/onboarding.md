# Onboarding por cuenta

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Auditoría de seguimiento18/10:** HU-01.5/#21 en Done: tres etapas sin Omitir, RPC/persistencia por cuenta y reintento implementados e integrados; pruebas existentes aprobadas. No se ejecuta una nueva finalización de cuenta por este cambio de seguimiento.

Módulo: `onboarding`. Decisión: [ADR-004](../decisiones/004-onboarding-por-cuenta.md).

## Qué hace y cómo se usa

Después de iniciar sesión, una cuenta que no completó el onboarding recorre
tres etapas introductorias. No se ofrece Omitir. Comenzar en la tercera etapa
guarda la finalización antes de permitir entrar a la app.

Al volver a iniciar sesión, una cuenta completada entra directamente a la app.
Una cuenta distinta tiene su propio estado: completar el recorrido en un
dispositivo no completa el onboarding de todas las cuentas de ese dispositivo.
Se respetan finalizaciones existentes reconocidas por el servidor.

## Reglas, datos y errores

EntryViewModel consulta CheckOnboarding junto con la sesión; OnboardingViewModel
coordina etapas y CompleteOnboarding. La finalización se persiste en el perfil
de la cuenta mediante una RPC protegida, no con un indicador global local.
Sin sesión se vuelve a login. Si falla consulta o guardado, se permite reintentar
y no se autoriza saltar el recorrido. El router no se recrea en cada evento.

La UI mantiene indicadores de progreso y transiciones por etapa, respetando
movimiento reducido. No repite animaciones por edición ni por cada frame de un gesto.

## Dependencias y validación

Depende de Auth, perfil y RPC de finalización. Verificar cuenta nueva, cuenta
completada, reinicio, cambio de cuenta y fallo de red al pulsar Comenzar.
El registro de pruebas ejecutadas y pendientes está en [ESTADO](../ESTADO.md).

## Corrección de consistencia — 11 de octubre de 2026

Entrada observa el contrato de sesión y CheckOnboarding sin importar ViewModels de auth. El cierre usa SignOut mediante EntryExitViewModel. Fallos de consulta, guardado y salida usan toast; reintentos conservados.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.
