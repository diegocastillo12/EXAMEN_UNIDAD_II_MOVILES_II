# Auditoría del backlog — 18 de octubre de 2026

Revisión solicitada por el usuario al detectar más casos como HU-03: tarjetas
que conservaban pendientes antiguos a pesar de entregas posteriores. Se revisaron
las29 tarjetas que seguían In progress, las confirmaciones y fichas funcionales,
la integración y las fuentes concretas. Se corrigieron20 a Done y se documentaron
los nueve pendientes actuales. No se extrapola una prueba local a una nueva
demo real ni se inventan confirmaciones del usuario.

## Fuentes contrastadas

- Árbol remoto de [main en7367c5f](https://github.com/srg-cp/entrehuellas/tree/7367c5f2aeb1ba27237869895efd2085805889c9):
  auth68, onboarding19, profile25, pets53, interest_zones17, alert_preferences14,
  lost_cases20, found_cases27, explore29, case_posters16 y sightings11 fuentes Dart.
  notifications y case_closure:0 fuentes; estas dos entregas aún son locales.
- PR [53](https://github.com/srg-cp/entrehuellas/pull/53),
  [54](https://github.com/srg-cp/entrehuellas/pull/54),
  [55](https://github.com/srg-cp/entrehuellas/pull/55),
  [56](https://github.com/srg-cp/entrehuellas/pull/56),
  [57](https://github.com/srg-cp/entrehuellas/pull/57),
  [58](https://github.com/srg-cp/entrehuellas/pull/58),
  [59](https://github.com/srg-cp/entrehuellas/pull/59) y
  [60](https://github.com/srg-cp/entrehuellas/pull/60) fusionadas.
  CI de PR60 Flutter/SQL/reader/photos aprobado, verificado durante esta sincronización.
- [ESTADO](../ESTADO.md): regresión Flutter412 aprobada; pruebas SQL/procesador
  y recorridos Android reales del16/10 (sesión, lista/mapa/fotos/filtros).
  Fichas: confirmación de012/WASM/guardado, validación HU-02 y022/023/QR operativo.
- Google18/10, consulta pública sin autenticar ni seguir la redirección:
  HTTP302 a accounts.google.com con redirect_uri correcto
  https://entrehuellas-supabase.kormind.com/auth/v1/callback. No se imprimen
  estado OAuth, códigos, tokens ni client_id. El error de ruta duplicada del7/10
  ya no describe el endpoint actual; esto no demuestra el retorno Android.

## Clasificaciones corregidas a Done

| Issue | Evidencia y motivo |
| --- | --- |
| [#2](https://github.com/srg-cp/entrehuellas/issues/2) | HU-02 completa como configuración de ubicaciones y preferencias: #26/#27 implementadas, parches010/011 confirmados por el usuario e incorporadas a main. La ficha de preferencias registra validación de HU-02. FCM no forma parte de esta entrega de configuración y no bloquea su cierre. |
| [#4](https://github.com/srg-cp/entrehuellas/issues/4) | HU-04 completa en código integrado: cámara/galería, procesamiento servidor y miniaturas sin EXIF, principal y retirada implementados en PR54; patch012 y guardado desde la app confirmados. La nota de entrega parcial era del9/10 y quedó superada. Agrupa #30/#31; no depende de push ni de un APK nuevo para clasificar la entrega funcional. |
| [#5](https://github.com/srg-cp/entrehuellas/issues/5) | Publicación de búsquedas propias implementada/integrada, con autorización, idempotencia, fotos verificadas y ubicación pública aproximada; patch013 confirmado. Casos con fotos reales se consultaron en Android/Supabase posteriormente. ADR-034 amplía el flujo sin dejar una operación pendiente de HU-05. Pruebas SQL/Flutter y CI aprobados; las notas de implementación meramente local ya no describen main. |
| [#6](https://github.com/srg-cp/entrehuellas/issues/6) | Publicación comunitaria y avisos vinculados implementados e integrados por PR55/60; activación014 reportada y contrato vigente ADR-034/plan018 consumido por QR/avistamientos operativos posteriores. Sin asignar dueño ni cerrar por un aviso. La descripción original se conserva como trazabilidad y el alcance aprobado está entregado, con pruebas de permisos/idempotencia/fotos. |
| [#7](https://github.com/srg-cp/entrehuellas/issues/7) | Ambas derivadas #32/#33 entregadas e integradas (PR56/57/60). Revisión Android real del16/10 con sesión conservada, Supabase,3 casos/fotos/teselas, misma consulta en lista/mapa y filtro Gato=1; CI339 y regresiones posteriores aprobadas. Volumen/rendimiento y QA ampliado no equivalen a funcionalidad sin implementar. |
| [#9](https://github.com/srg-cp/entrehuellas/issues/9) | Lector QR operativo según confirmación registrada de022/023 y generación/lectura; migración Vue/Nuxt integrada por PR59/60 y avistamientos web ya aceptados. Proyecciones públicas, activo/cerrado/neutral, revocación y privacidad implementados y probados. El pendiente histórico de web no desplegada fue superado por confirmaciones posteriores; no se inventa una prueba nueva con otro teléfono. |
| [#10](https://github.com/srg-cp/entrehuellas/issues/10) | HU-10 agrupa #36 web ya Done y #37 Android implementado/integrado y025 confirmado. Ambos flujos comparten persistencia y reglas; la confirmación de025 seguida de HU-11 operativa y sus pruebas sustituyen la nota de Android todavía por implementar. La épica puede finalizar al cerrar ambas derivadas. |
| [#17](https://github.com/srg-cp/entrehuellas/issues/17) | Registro por correo y OTP de6 dígitos completo e integrado: validación, reenvío60s, verificación, sesión válida y perfil único. El usuario ya informó recepción de correo con código alternativo de6 dígitos; no hay una plantilla nueva obligatoria pendiente para utilizarlo.94 pruebas de los flujos Auth/OTP y regresiones posteriores/CI cubren la implementación; se sustituye la nota genérica de falta de PR o de implementación local. |
| [#18](https://github.com/srg-cp/entrehuellas/issues/18) | Login correo/contraseña integrado y consumido por los recorridos Android autenticados posteriores. Lectura real de cuenta/perfil y navegación privada sin duplicación; validación, fallo/reintento y doble envío probados. No se conserva como bloqueo una nota inicial de falta de PR cuando el código ya está en main. |
| [#20](https://github.com/srg-cp/entrehuellas/issues/20) | Sesión y cierre integrados: restauración, prioridad de recuperación, logout, protección de rutas y descarte por cambio de cuenta. El recorrido Android del16/10 conserva la sesión real al hot restart; pruebas de sesión/rutas/identidad y CI aprobadas. No falta implementación ni integración; una matriz ampliada de dispositivos no convierte la historia en desarrollo activo. |
| [#21](https://github.com/srg-cp/entrehuellas/issues/21) | Onboarding por cuenta entregado e integrado: tres etapas sin Omitir, RPC protegida y persistencia por identidad, fallo/reintento. Consumido por la entrada privada existente; pruebas SQL de aislamiento/persistencia y Flutter de navegación aprobadas. Los motivos antiguos de implementación solo local o sin PR quedan sustituidos por main y CI. |
| [#22](https://github.com/srg-cp/entrehuellas/issues/22) | Recuperación por OTP entregada e integrada: código introducible desde otro dispositivo, reenvío, sesión de recuperación prioritaria, nueva contraseña y cierre de sesión al terminar/cancelar. El contrato usa el código que el usuario ya reportó recibir; pruebas SDK/VM/UI y CI aprobadas. No se afirma un cambio de contraseña remoto nuevo durante esta auditoría. |
| [#23](https://github.com/srg-cp/entrehuellas/issues/23) | Perfil, campos permitidos y foto privados implementados e integrados; selección de ciudad y guardado/descartar/fallo/cuenta cubiertos por regresiones y CI remoto aprobado. La nota de no tener PR o selector sin implementar es histórica. No se ejecuta un guardado remoto nuevo ni se atribuye esa prueba a la auditoría. |
| [#26](https://github.com/srg-cp/entrehuellas/issues/26) | Ubicaciones manuales/radio, edición y borrado implementados e integrados en main; patch010 confirmado. La selección manual y radio reales también se consumen por el mapa/seguimiento. RLS/RPC y reintentos probados. Se elimina como bloqueo la integración en main que ya ocurrió; no se exige GPS continuo ni activar push. |
| [#27](https://github.com/srg-cp/entrehuellas/issues/27) | Preferencias por cuenta implementadas/integradas y patch011 confirmado; la ficha registra validación del usuario de HU-02. Pausa/conservación de elecciones, tipos/canales y protección de versión cubiertos. Recepción efectiva/push pertenece a HU-12, no es trabajo faltante de HU-02.2; FCM pospuesto no bloquea esta historia. |
| [#30](https://github.com/srg-cp/entrehuellas/issues/30) | Carga cámara/galería, validación, autorización y procesamiento/miniaturas servidor implementados e integrados (PR54). Patch012/WASM y guardado desde la app confirmados; fotos procesadas reales usadas por casos posteriores. Se comprobaron fuentes concretas y pruebas de procesador/SQL/Flutter existentes. Cámara y miniaturas no siguen pendientes de implementación. |
| [#31](https://github.com/srg-cp/entrehuellas/issues/31) | Elección explícita de principal, retirada, sustitución consistente y borrador hasta guardar implementados e integrados. Casos de uso/set_primary_pet_photo y ViewModel presentes, con regresiones de persistencia/permisos/reintento y corrección de dependencia circular incorporadas. La nota del9/10 que decía principal pendiente era anterior a la entrega. |
| [#32](https://github.com/srg-cp/entrehuellas/issues/32) | Consulta pública paginada y filtrada integrada (PR56/57/60); datos reales en Android con fotos y paridad con mapa revisados el16/10. SQL prueba filtros, cursores, permisos y privacidad; Flutter/CI prueba reintentos y estado. Rendimiento ampliado es QA adicional, no una funcionalidad pendiente. Guardados offline #49 sigue fuera de esta entrega. |
| [#33](https://github.com/srg-cp/entrehuellas/issues/33) | Mapa, coordenadas aproximadas, selección/ficha y filtros compartidos entregados e integrados; revisión Android/Supabase/teselas reales documentada con3 casos y filtro Gato. Pruebas de agrupación, navegación, páginas y fallos/CI aprobadas. El APK nuevo bloqueado por Gradle no invalida el recorrido Dart real acreditado por attach/hot restart. |
| [#37](https://github.com/srg-cp/entrehuellas/issues/37) | Avistamientos Android implementados e integrados por PR60,025 confirmado por el usuario tras su entrega y recorrido HU-11 posterior operativo. Foto opcional, punto manual/GPS, fecha, recibo y reintento idempotente comparten servidor con web. Pruebas SQL/SDK/VM/UI y CI aprobadas; no hay una integración pendiente en main. No se inventa una prueba remota nueva en esta revisión. |

## In progress con pendiente concreto

| Issue | Pendiente actual |
| --- | --- |
| [#1](https://github.com/srg-cp/entrehuellas/issues/1) | La épica no está completa: Google #19 conserva validación de retorno OAuth Android pendiente, y baja #24/exportación #25 no están implementadas. #17/#18/#20/#21/#22/#23 ya entregadas pasan a Done. La épica no debe ocultar esos avances ni cerrarse por arrastre. |
| [#8](https://github.com/srg-cp/entrehuellas/issues/8) | Generación/lector QR implementados, parches022/023 y operación confirmados. Quedan criterios concretos de #34 (impresión y escaneo de prueba) y #35 (guardar/compartir PDF/enlace con hojas nativas Android) sin evidencia completada; no falta implementar el lector ni configurar una web provisional. |
| [#12](https://github.com/srg-cp/entrehuellas/issues/12) | #40/#41 implementados localmente y027 confirmado, pero sus fuentes aún no están en main (comprobado árbol remoto) y falta validar el evento/bandeja actual con cuentas reales. #42 FCM permanece pospuesto por ADR-068. Motivo actual: integrar/activar/aceptar esas dos derivadas y respetar la exclusión de FCM. |
| [#13](https://github.com/srg-cp/entrehuellas/issues/13) | Cierre implementado localmente y412 pruebas Flutter aprobadas. Sus fuentes aún no están en main y028 no está confirmado como aplicado. Pendientes concretos: integración,028 y recorrido Android/Supabase real; no se solicita reaplicar027 ni activar FCM. |
| [#19](https://github.com/srg-cp/entrehuellas/issues/19) | Implementación Google integrada y proveedor habilitado. Auditoría18/10 verificó HTTP302 a accounts.google.com con redirect_uri correcto https://entrehuellas-supabase.kormind.com/auth/v1/callback: el redirect_uri_mismatch por ruta duplicada del7/10 ya no es un bloqueo vigente. Falta evidencia concreta del retorno OAuth Android con app abierta/cerrada y sesión válida; consultar el redirect no equivale a iniciar sesión. |
| [#34](https://github.com/srg-cp/entrehuellas/issues/34) | Generación PDF/QR implementada e integrada y usuario confirmó022/023/generación/lectura. Se retiró como bloqueo el pendiente histórico del lector web. El criterio pendiente específico es PDF/QR legible en otro teléfono y en impresión de prueba; hay render/decodificación local, no evidencia de esa prueba física. |
| [#35](https://github.com/srg-cp/entrehuellas/issues/35) | Guardar/compartir implementados e integrados; lector público operativo. Falta verificar las hojas nativas Android: guardar archivo, compartir PDF/enlace y cancelar/reintentar con el artefacto correcto. No se sustituye esa comprobación por mocks, render local o generación en memoria. |
| [#40](https://github.com/srg-cp/entrehuellas/issues/40) | Seguimiento implementado y027 confirmado. Árbol remoto main no contiene notifications: falta integrar la implementación local y demostrar seguimiento/persistencia con sesión real. No falta activar Firebase ni fusionar otra vez las ubicaciones antiguas; FCM no bloquea esta historia. |
| [#41](https://github.com/srg-cp/entrehuellas/issues/41) | Bandeja implementada localmente,027 confirmado y SQL probado. Árbol remoto main no contiene notifications: falta integrar y validar un evento real, leído/reentrada y aislamiento actual. La ausencia de FCM no es el bloqueo; permanece pospuesto. |

## Resultado y límites

51 elementos:27 Done,9 In progress,2 Ready,13 Backlog y0 In review.24 issues
abiertos/27 cerrados; todos los Status y sus etiquetas coinciden por API. Se
actualizaron29 cuerpos de issue y20 estados; los nuevos Done quedaron cerrados.
Se preservan asignación, prioridades, estimaciones y dependencias.

Baja/exportación, moderación, offline y métricas no se dan por implementados;
Guardados online no equivale a HU-15.3 offline. FCM sigue pospuesto (ADR-068).
Los pendientes de impresión/hojas nativas y retorno OAuth se conservan porque
son recorridos concretos requeridos, no por falta genérica de PR. QA ampliado,
otro tamaño de pantalla o un APK nuevo no mantienen indefinidamente en desarrollo
una funcionalidad ya integrada y respaldada por la evidencia posterior.

No se ejecutaron nuevas pruebas de aplicación, SQL ni despliegues. La única
comprobación de red nueva fue la redirección pública Google descrita arriba.
Los JSON antes/después, árbol main, plan y verificación se conservan localmente
en apps/mobile/build/backlog-audit-*.json y backlog-audit-20261018, sin credenciales.
