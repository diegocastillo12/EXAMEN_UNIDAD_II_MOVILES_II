# Auditoría de GitHub — 24 de octubre de 2026

## Seguimiento actualizado — 25/10/2026

Aceptación expresa del usuario: #19, #34, #35, #40, #41, #13 y épica #8
cerrados/Done en GitHub y Projects. La aceptación procede del usuario; no se
ejecutó una nueva demo del agente ni se fabrican logs de escenarios particulares.
HU-01 sigue abierta por #24/#25 sin implementar; HU-12 por #42/FCM pospuesto.
Moderación/denuncias/bloqueos/apelaciones conservan sus pendientes #43–#46.
Estadísticas #50 ya cerradas por la aceptación del24/10.

Match incluido expresamente en MVP: **HU-25 / #71** y **HU-26 / #72**,
RF-19/RF-20, Backlog/P1 y needs:refinement. No existían issues de estas
historias al revisar los51 issues abiertos/cerrados. Ahora hay53 issues:
**39 Done (31 historias y8 épicas),8 In progress (4 historias y4 épicas),
6 Backlog (6 historias)**. No es porcentaje de avance ni53 entregas distintas.

Pendientes de implementación: baja #24, exportación #25, controles #51 y
coincidencias #71/#72. Push #42 sigue diferido. Las tablas/notas inferiores
son instantáneas históricas, sustituidas por esta actualización.

Actualización posterior autorizada: PR69 fusionado y checks Flutter/web aprobados;
#49/HU-15.3 y épica #15 cerradas/Done con evidencia integrada. HU-16.1/#50
implementada localmente y épica #16 In progress; activación039, asignación
administrador, demo alojada e integración pendientes. #51 conserva su refinamiento.
Auditoría API final de los51 issues:31 Done,16 In progress y4 Backlog; etiquetas,
estado abierto/cerrado y Projects concordantes. Los totales inferiores son la
instantánea anterior. No se repiten las demos de todas las historias.

Revisión autorizada por el usuario de los 51 issues originales/derivados y del
tablero EntreHuellas. Se contrastan criterios, estado remoto, fuentes integradas,
PR y fichas funcionales. Esta auditoría no equivale a ejecutar de nuevo las demos
de todas las funcionalidades. Las notas históricas no sustituyen el estado actual.

## Historias que cumplen el cierre

- **HU-15.1 / #47:** SQLite privado por cuenta, UUID estable, campos parciales y
  evidencia conservados. Smoke WRITE→force-stop→READ offline, diez comprobaciones
  SQLite nativas y guardar/retomar desde la app normal en Android emulado.
  [Ficha y límites](../funcionalidades/borradores-locales.md).
- **HU-15.2 / #48:** cola persistente, estados veraces, sincronización automática,
  recibos y aislamiento. 575 pruebas Flutter, análisis limpio, 56 SQL locales,
  seis integraciones reales con cuentas A/B y servidor de desarrollo; diez
  comprobaciones SQLite nativas. Se comprueban respuesta perdida tras commit,
  mismo UUID sin duplicados, contenido incompatible, revocación y cambio de
  identidad. Ciclo de app normal sin red→force-stop→reabrir→recuperar red→publicar.
  Parches 037/038 aplicados por el usuario y comprobados remotamente.
  [Ficha y reproducción](../funcionalidades/envios-pendientes.md).

Integrado en main por [PR #67](https://github.com/srg-cp/entrehuellas/pull/67),
commit12dac7b; #47/#48 cerrados. Flutter validate, SQL56/56 y fotos aprobados en CI.
No se acredita
teléfono físico ni reinicio completo de Android: se probó reinicio del proceso
en emulador Pixel_9a/API36/x86_64. No se vuelve a aplicar SQL ni se despliega
backend por esta auditoría. Los logs privados y la configuración de cuentas
permanecen fuera de Git; las herramientas reproducibles se incluyen en el PR.

## Issues abiertos que conservan trabajo pendiente

| Issues | Resultado de la revisión / criterio pendiente |
| --- | --- |
| #19 | Google: retorno OAuth Android con app abierta/cerrada, cancelación y sesión válida; no basta abrir navegador. |
| #24, #25 | Baja y exportación de cuenta: entregas pendientes; no confundir edición de perfil con estas operaciones. |
| #34, #35 | Carteles integrados: falta impresión y escaneo desde otro teléfono; guardar/compartir/cancelar en las hojas nativas Android. El lector web ya existe. |
| #40, #41 | Seguimiento y bandeja implementados, 027 confirmado. Falta demostrar en backend real destinatarios/evento, persistencia, lectura y permisos entre cuentas. FCM no bloquea por sí solo estas derivadas. |
| #42 | Push FCM pospuesto explícitamente por ADR-068; no marcar como implementado ni activar emisor/cron. |
| #13 | Cierre implementado y 028 confirmado. Falta demo remota de autorización/concurrencia, QR actualizado, rechazo de nuevos avistamientos y nuevo episodio. |
| #43 | Denuncias implementadas y 029 confirmado. Falta demo remota de evidencia privada, deduplicación y permisos de denunciante/autor/ajeno/revisor. |
| #44 | Bloqueos implementados e integrados. Pendientes activación/verificación 034/036 y demo remota A/B, contactos/fotos y concurrencia. Alcance ya acordado; retirar needs:refinement. |
| #45 | Moderación web implementada y 030 confirmado. Falta verificar configuración/rol y demo con revisores reales, cuenta ordinaria y concurrencia. |
| #46 | Apelaciones implementadas e integradas. Pendientes activación/verificación 035 y demo de autor/ajeno/revisor reales, historial y reintentos. |
| #50 | Estadísticas implementadas localmente, con89 pruebas web,33 de servidor,58 SQL completas y Chrome fixture. Faltan039, asignación administrador, demo alojada e integración. |
| #51 | Controles administrativos sin implementar; requiere acordar funciones controlables. |
| #1, #8, #12, #14, #16 | Épicas abiertas: tienen derivadas pendientes. #15 ya cerrada después de integrar #49 por PR69. |

Las historias #43–#46 y las épicas #14/#15 están In progress, conservando
pendientes concretos. #47/#48 están Done después de integrar y verificar CI.
Verificados por API los51 issues: una etiqueta status por issue, concordancia
con Status nativo y con abierto/cerrado. Totales:29 Done,15 In progress,7 Backlog.

## Cierres previos contrastados

Ya estaban cerrados con status:done **27 issues**:
#2, #3, #4, #5, #6, #7, #9, #10, #11, #17, #18, #20, #21, #22,
#23, #26, #27, #28, #29, #30, #31, #32, #33, #36, #37, #38 y #39.
Las fichas y auditoría anterior registran integración/aceptación; no se detecta
otra entrega completa abierta además de #47/#48. #5/#6/#9 tienen criterios
aceptados y cerrados, pero cuatro casillas técnicas antiguas cada uno siguen
vacías: se sincronizan sin atribuirles una demo nueva.

Resultado verificado tras integrar: **29 cerrados y 22 abiertos**, contando épicas
y derivadas por separado. No son 29 funcionalidades independientes ni un
porcentaje de avance del MVP. Los cierres anteriores conservan sus límites de
validación documentados; esta revisión no certifica todas las funciones en remoto.

La publicación automática de APK conserva un bloqueo previo independiente:
faltan MOBILE_CONFIG_JSON, ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD,
ANDROID_KEY_ALIAS y ANDROID_KEY_PASSWORD en GitHub. Run40040206814 tiene validate
aprobado y release fallido en preparación. No se afirma APK publicado ni se
proporcionan nuevos secretos de firma por actualizar issues.
