# Backlog de Entre Huellas

- [#71 — HU-25: Indexar fotos visuales](071-HU-25.md) — MVP, Backlog/P1.
- [#72 — HU-26: Sugerir y revisar coincidencias](072-HU-26.md) — MVP, Backlog/P1.

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

## Seguimiento final del24/10/2026

PR [#69](https://github.com/srg-cp/entrehuellas/pull/69) fusionado; Flutter/web del
HEAD y validate de main aprobados. #49 y épica #15 cerradas/Done. HU-16.1/#50
cerrada/Done tras aceptación del usuario,039/asignación confirmadas y PR70
integrado con CI de main aprobada. Épica #16 In progress por #51 sin iniciar.
API de los51 issues y Projects comprobados:32 Done,15 In progress,4 Backlog;
sin discrepancias. La publicación APK requiere verificar una nueva ejecución
con la configuración definitiva de firma/secrets informada por el usuario.

| Estado actual24/10 | Total | Historias | Épicas |
| --- | ---: | ---: | ---: |
| Done | 32 | 25 | 7 |
| In progress | 15 | 10 | 5 |
| Backlog | 4 | 4 | 0 |
| Ready / In review | 0 | 0 | 0 |

## Instantánea anterior a HU-15.3 y HU-16.1 —24/10/2026

[Auditoría actual de los 51 issues](auditoria-github-2026-10-24.md), autorizada por
el usuario. PR [#67](https://github.com/srg-cp/entrehuellas/pull/67) fusionado con CI
aprobado; cola integrada y #47/#48 cerrados. Verificado:29 cerrados y22 abiertos;
#15 queda abierta por #49. #43–#46 y épicas #14/#15 pasan a In progress;
#44 ya tiene alcance acordado. Los criterios remotos/nativos pendientes de las
otras historias se mantienen explícitos. Las tablas y fichas de instantánea
inferiores corresponden al18/10, no al resultado actual de GitHub/Projects.

| Estado actual24/10 | Total | Historias | Épicas |
| --- | ---: | ---: | ---: |
| Done | 29 | 23 | 6 |
| In progress | 15 | 10 | 5 |
| Backlog | 7 | 6 | 1 |
| Ready / In review | 0 | 0 | 0 |

**Avance23/10:** [HU-14.2/#44](044-HU-14.2.md) implementada localmente en
`feature/user-blocking`, con alcance de nuevas contribuciones autenticadas y
SQL034–035 y contacto/foto ocultos según confirmación del usuario.
[Ficha](../funcionalidades/bloqueos-usuarios.md). Activación/demo remotas
pendientes; tablas y etiquetas `needs:refinement` inferiores son la instantánea
previa de GitHub, sin sincronización de issues/Projects en esta tarea.

**Avance posterior18/10:** HU-14.3/#45 implementada localmente en platform,
con030/configuración/demo/integración pendientes. Administración exclusivamente
web; Flutter conserva denuncia del usuario. Estados remotos/tablas inferiores
son la última instantánea, sin nuevas acciones GitHub en este incremento.


**Avance local posterior18/10:**028 confirmado aplicado; el usuario autoriza
HU-14.1/#43, implementada localmente en feature/content-reports, pendiente029/demo.
[Denuncias](../funcionalidades/denuncias-contenido.md). Tabla y estados remotos
inferiores conservan la última instantánea API; sin sincronización GitHub nueva.
Firebase/FCM fuera del alcance, sin considerarlo bloqueo de las historias activas.


Sincronización auditada: **18 de octubre de 2026**, America/Lima.
[Tablero](https://github.com/users/srg-cp/projects/3) · [Issues](https://github.com/srg-cp/entrehuellas/issues) · [Auditoría y evidencia](AUDITORIA_2026-10-18.md).

51 elementos:39 historias ejecutables y12 épicas;24 issues abiertos/27 cerrados.
No contar épicas y derivadas como el mismo esfuerzo. Verificado por API: cada
Status coincide con una única etiqueta status:*.

## Estados actuales

| Estado | Total | Historias | Épicas |
| --- | ---: | ---: | ---: |
| Done | 27 | 21 | 6 |
| In progress | 9 | 6 | 3 |
| Ready | 2 | 1 | 1 |
| Backlog | 13 | 11 | 2 |
| In review | 0 | 0 | 0 |

## Criterio aplicado

Se sustituyeron motivos históricos (sin PR, fotos/principal/cámara o integración
pendientes) por el estado de main, pruebas y confirmaciones posteriores. La
auditoría ampliada movió20 tarjetas más a Done y actualizó29 motivos; no equivale
a realizar una nueva demo ni autoriza SQL/despliegues. Las limitaciones de la
evidencia se conservan sin convertir todo QA ampliado en desarrollo pendiente.

- **Done:** entrega implementada/integrada y respaldada por evidencia posterior.
  Incluye las aceptaciones expresas de HU-10.1/HU-11 y corrección de HU-03. La
  [matriz](AUDITORIA_2026-10-18.md) justifica cada corrección adicional.
- **In progress:** pendiente concreto: #1 (Google/baja/exportación), #19
  (retorno OAuth Android), #8/#34/#35 (impresión/escaneo/hojas nativas),
  #12/#40/#41 (integrar seguimiento/bandeja y demo) y #13 (integración/028/demo).
  No se exige Firebase a HU-02 ni reactivar FCM para validar bandeja.
- **Ready:** #43 denuncia y épica #14; no hay implementación iniciada.
- **Backlog:** cuenta/offline/métricas/moderación posterior sin iniciar; #42
  FCM explícitamente pospuesto y #44/#51 con needs:refinement conservado.
- **In review:** reservado a entrega presentada a revisión; sin tarjetas actuales.

[ESTADO](../ESTADO.md) y [funcionalidades](../funcionalidades/README.md) detallan
comportamiento y límites. Las notas antiguas se conservan como historial fechado
y se leen junto al motivo actual, no como bloqueos vigentes automáticos.

## Done

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#2](002-HU-02.md) | Épica | Épica — HU-02 — Elegir zonas y preferencias de alertas |
| [#3](003-HU-03.md) | Épica | Épica — HU-03 — Registrar una mascota |
| [#4](004-HU-04.md) | Épica | Épica — HU-04 — Administrar las fotos de mi mascota |
| [#5](005-HU-05.md) | Historia | HU-05 — Publicar un caso de mascota perdida |
| [#6](006-HU-06.md) | Historia | HU-06 — Publicar una mascota encontrada |
| [#7](007-HU-07.md) | Épica | Épica — HU-07 — Consultar y filtrar casos en lista y mapa |
| [#9](009-HU-09.md) | Historia | HU-09 — Consultar la ficha del caso desde el navegador |
| [#10](010-HU-10.md) | Épica | Épica — HU-10 — Reportar un avistamiento desde web o app |
| [#11](011-HU-11.md) | Épica | Épica — HU-11 — Revisar avistamientos y consultar la cronología |
| [#17](017-HU-01.1.md) | Historia | HU-01.1 — Registrarme y confirmar mi correo |
| [#18](018-HU-01.2.md) | Historia | HU-01.2 — Acceder con correo y contraseña |
| [#20](020-HU-01.4.md) | Historia | HU-01.4 — Conservar y cerrar mi sesión de forma segura |
| [#21](021-HU-01.5.md) | Historia | HU-01.5 — Completar el onboarding de mi cuenta |
| [#22](022-HU-01.6.md) | Historia | HU-01.6 — Recuperar mi contraseña con un código |
| [#23](023-HU-01.7.md) | Historia | HU-01.7 — Consultar y editar mi perfil |
| [#26](026-HU-02.1.md) | Historia | HU-02.1 — Guardar mis zonas y radios de interés |
| [#27](027-HU-02.2.md) | Historia | HU-02.2 — Configurar mis preferencias de alertas |
| [#28](028-HU-03.1.md) | Historia | HU-03.1 — Registrar y consultar mis mascotas |
| [#29](029-HU-03.2.md) | Historia | HU-03.2 — Editar la ficha de mi mascota con sus fotos |
| [#30](030-HU-04.1.md) | Historia | HU-04.1 — Agregar fotografías seguras a mi mascota |
| [#31](031-HU-04.2.md) | Historia | HU-04.2 — Elegir y retirar fotografías de mi mascota |
| [#32](032-HU-07.1.md) | Historia | HU-07.1 — Consultar y filtrar casos en una lista |
| [#33](033-HU-07.2.md) | Historia | HU-07.2 — Explorar los mismos casos en el mapa |
| [#36](036-HU-10.1.md) | Historia | HU-10.1 — Reportar un avistamiento desde la web pública |
| [#37](037-HU-10.2.md) | Historia | HU-10.2 — Reportar un avistamiento desde Android |
| [#38](038-HU-11.1.md) | Historia | HU-11.1 — Consultar la cronología del caso |
| [#39](039-HU-11.2.md) | Historia | HU-11.2 — Revisar y clasificar un avistamiento |

## In progress

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#1](001-HU-01.md) | Épica | Épica — HU-01 — Entrar y gestionar mi cuenta |
| [#8](008-HU-08.md) | Épica | Épica — HU-08 — Generar y compartir un cartel con QR |
| [#12](012-HU-12.md) | Épica | Épica — HU-12 — Recibir alertas y consultarlas en la bandeja |
| [#13](013-HU-13.md) | Historia | HU-13 — Cerrar un caso como recuperado |
| [#19](019-HU-01.3.md) | Historia | HU-01.3 — Acceder con Google |
| [#34](034-HU-08.1.md) | Historia | HU-08.1 — Generar un cartel PDF con QR legible |
| [#35](035-HU-08.2.md) | Historia | HU-08.2 — Descargar y compartir mi cartel y enlace |
| [#40](040-HU-12.1.md) | Historia | HU-12.1 — Seguir y dejar de seguir casos y zonas |
| [#41](041-HU-12.2.md) | Historia | HU-12.2 — Consultar mis alertas en una bandeja persistente |

## Ready

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#14](014-HU-14.md) | Épica | Épica — HU-14 — Denunciar contenido y atender reportes |
| [#43](043-HU-14.1.md) | Historia | HU-14.1 — Denunciar contenido con un motivo |

## Backlog

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#15](015-HU-15.md) | Épica | Épica — HU-15 — Conservar borradores sin conexión y reintentar envíos |
| [#16](016-HU-16.md) | Épica | Épica — HU-16 — Consultar estadísticas básicas del MVP |
| [#24](024-HU-01.8.md) | Historia | HU-01.8 — Solicitar la baja y consultar su estado |
| [#25](025-HU-01.9.md) | Historia | HU-01.9 — Exportar los datos básicos de mi cuenta |
| [#42](042-HU-12.3.md) | Historia | HU-12.3 — Recibir notificaciones push con reintento |
| [#44](044-HU-14.2.md) | Historia | HU-14.2 — Bloquear y desbloquear usuarios |
| [#45](045-HU-14.3.md) | Historia | HU-14.3 — Revisar denuncias y moderar con auditoría |
| [#46](046-HU-14.4.md) | Historia | HU-14.4 — Apelar una decisión de moderación |
| [#47](047-HU-15.1.md) | Historia | HU-15.1 — Conservar borradores al perder conexión |
| [#48](048-HU-15.2.md) | Historia | HU-15.2 — Reintentar mis envíos pendientes sin duplicarlos |
| [#49](049-HU-15.3.md) | Historia | HU-15.3 — Consultar casos guardados sin conexión |
| [#50](050-HU-16.1.md) | Historia | HU-16.1 — Consultar estadísticas agregadas del piloto |
| [#51](051-HU-16.2.md) | Historia | HU-16.2 — Controlar funciones del piloto con auditoría |

## In review

Sin elementos.

<details>
<summary>Instantánea histórica del10 de octubre de2026 (sustituida por la sincronización anterior)</summary>

### Backlog anterior

Sincronización: 10 de octubre de 2026, America/Lima. Repositorio: [srg-cp/entrehuellas](https://github.com/srg-cp/entrehuellas/issues).

Hay **51 archivos de issue**, uno por cada #1–#51, además de este índice. El nombre combina número GitHub e identificador HU, por ejemplo `017-HU-01.1.md`. Se conservan descripción, aceptación, dependencias, validación y definición de terminado del issue, junto a metadatos, estado y motivo de clasificación.

Son **12 épicas** y **39 historias ejecutables**. No contar ambas como el mismo esfuerzo. [BACKLOG_MVP](../BACKLOG_MVP.md) conserva la estructura académica y [ESTADO](../ESTADO.md) la evidencia del avance.

## Estados y evidencia

| Estado | Total de issues | Historias ejecutables | Épicas |
| --- | ---: | ---: | ---: |
| Backlog | 34 | 26 | 8 |
| Ready | 0 | 0 | 0 |
| In Progress | 17 | 13 | 4 |
| In Review | 0 | 0 | 0 |
| Done | 0 | 0 | 0 |

- **Backlog**: falta un resultado previo de una dependencia o concretar reglas; no significa listo para comenzar.
- **Ready**: resultado, criterios y contratos necesarios disponibles para iniciar. Aún sin implementación; la estimación se acuerda antes de comprometer la entrega. El acceso local existe aunque su validación integrada esté pendiente; cada nueva entrega debe probar sus permisos reales antes de cerrarse.
- **In Progress**: implementación iniciada o local disponible, con criterios o validación integrada pendientes.
- **In Review**: entrega presentada a revisión mediante PR y evidencia verificable. PR#53 de mascotas está abierto, pero conserva descripción de plantilla y las historias tienen criterios completos pendientes; su existencia no acredita una entrega terminada.
- **Done**: todos los criterios demostrados, código integrado, datos/permisos validados y estado actualizado. No hay evidencia suficiente para clasificar una historia completa aquí.

Las épicas agregan el estado de sus historias: trabajo iniciado → In Progress; sin trabajo iniciado y alguna historia Ready → Ready; sin entregas preparadas → Backlog. Solo pueden terminar después de todas sus historias y demo integrada. No son historias adicionales de implementación.

## GitHub y alcance de la sincronización

Los estados están aplicados a los issues mediante etiquetas `status:backlog`, `status:ready`, `status:in-progress`, `status:in-review` y `status:done`. Se distingue `type:epic` de `type:story`. #44 y #51 llevan `needs:refinement`. Los 51 issues permanecen abiertos y asignados a srg-cp.

**Tablero sincronizado:** [EntreHuellas — Backlog](https://github.com/users/srg-cp/projects/3/views/1). Se verificaron los 51 items del repositorio: 34 Backlog y17 In progress; sin items en Ready, In review o Done. Actualización más reciente: #27/#30/#31/#4 pasan a In progress, con etiquetas y Status nativo coincidentes. #2/#26 conservan In progress y reciben evidencia actualizada. No se guardaron tokens en el repositorio.

Referencia del mecanismo y permisos de Projects: [documentación oficial de GitHub](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects).

Estos archivos son una instantánea del issue y su estado a esta fecha, no una sincronización automática. GitHub es la referencia operativa; al modificar criterios, etiquetas o Status de Projects, mantener coherentes tarjeta, etiqueta, archivo e índice. Un cambio de estado no demuestra aceptación ni sustituye pruebas. Los enlaces locales facilitan consultar relaciones sin salir del repositorio.

Actualización autorizada el 9 de octubre: Perfil #23 y mascotas #3/#28/#29 en In progress; fotos #4/#30 en Ready. No se marca Done ni se cierra ningún issue sin evidencia integrada. Status y etiquetas verificados después del cambio.

Actualización autorizada el 10 de octubre: Zonas #26 y su épica #2 pasan de Ready a In progress. Implementación local verificada; patch010 aplicado en Supabase según el usuario. Falta demostrar el recorrido real Android/Supabase e integrar el código. Preferencias #27 permanece en Backlog.

Avance local posterior del 10 de octubre: preferencias #27 implementadas en `feature/alert-preferences` según ADR-019, con SQL040–043/patch011 preparado y pruebas locales. Este incremento de desarrollo no modificó el snapshot de GitHub; patch011 y validación integrada siguen pendientes. Consultar ficha #27 y ESTADO.

Sincronización posterior autorizada del 10 de octubre: #27 de Backlog a In progress, #30/#4 de Ready a In progress y #31 de Backlog a In progress. Zonas/preferencias publicadas por el usuario en sus ramas; patch010/011 aplicados según su confirmación. Fotos refleja avance parcial de galería/carga/retirada, con cámara, principal y procesamiento público pendientes. Se actualizaron cuerpos, etiquetas y Projects; no se cerraron issues ni se marcaron criterios sin demo real.

## In Progress

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#1](001-HU-01.md) | Épica | Épica — HU-01 — Entrar y gestionar mi cuenta |
| [#2](002-HU-02.md) | Épica | Épica — HU-02 — Elegir zonas y preferencias de alertas |
| [#3](003-HU-03.md) | Épica | Épica — HU-03 — Registrar una mascota |
| [#4](004-HU-04.md) | Épica | Épica — HU-04 — Administrar las fotos de mi mascota |
| [#17](017-HU-01.1.md) | Historia de usuario | HU-01.1 — Registrarme y confirmar mi correo |
| [#18](018-HU-01.2.md) | Historia de usuario | HU-01.2 — Acceder con correo y contraseña |
| [#19](019-HU-01.3.md) | Historia de usuario | HU-01.3 — Acceder con Google |
| [#20](020-HU-01.4.md) | Historia de usuario | HU-01.4 — Conservar y cerrar mi sesión de forma segura |
| [#21](021-HU-01.5.md) | Historia de usuario | HU-01.5 — Completar el onboarding de mi cuenta |
| [#22](022-HU-01.6.md) | Historia de usuario | HU-01.6 — Recuperar mi contraseña con un código |
| [#23](023-HU-01.7.md) | Historia de usuario | HU-01.7 — Consultar y editar mi perfil |
| [#26](026-HU-02.1.md) | Historia de usuario | HU-02.1 — Guardar mis zonas y radios de interés |
| [#27](027-HU-02.2.md) | Historia de usuario | HU-02.2 — Configurar mis preferencias de alertas |
| [#28](028-HU-03.1.md) | Historia de usuario | HU-03.1 — Registrar y consultar mis mascotas |
| [#29](029-HU-03.2.md) | Historia de usuario | HU-03.2 — Editar la ficha de mi mascota con sus fotos |
| [#30](030-HU-04.1.md) | Historia de usuario | HU-04.1 — Agregar fotografías seguras a mi mascota |
| [#31](031-HU-04.2.md) | Historia de usuario | HU-04.2 — Elegir y retirar fotografías de mi mascota |

## Ready

Sin issues en este estado.

## Backlog

| Issue local | Tipo | Resultado |
| --- | --- | --- |
| [#5](005-HU-05.md) | Historia de usuario | HU-05 — Publicar un caso de mascota perdida |
| [#6](006-HU-06.md) | Historia de usuario | HU-06 — Publicar una mascota encontrada |
| [#7](007-HU-07.md) | Épica | Épica — HU-07 — Consultar y filtrar casos en lista y mapa |
| [#8](008-HU-08.md) | Épica | Épica — HU-08 — Generar y compartir un cartel con QR |
| [#9](009-HU-09.md) | Historia de usuario | HU-09 — Consultar la ficha del caso desde el navegador |
| [#10](010-HU-10.md) | Épica | Épica — HU-10 — Reportar un avistamiento desde web o app |
| [#11](011-HU-11.md) | Épica | Épica — HU-11 — Revisar avistamientos y consultar la cronología |
| [#12](012-HU-12.md) | Épica | Épica — HU-12 — Recibir alertas y consultarlas en la bandeja |
| [#13](013-HU-13.md) | Historia de usuario | HU-13 — Cerrar un caso como recuperado |
| [#14](014-HU-14.md) | Épica | Épica — HU-14 — Denunciar contenido y atender reportes |
| [#15](015-HU-15.md) | Épica | Épica — HU-15 — Conservar borradores sin conexión y reintentar envíos |
| [#16](016-HU-16.md) | Épica | Épica — HU-16 — Consultar estadísticas básicas del MVP |
| [#24](024-HU-01.8.md) | Historia de usuario | HU-01.8 — Solicitar la baja y consultar su estado |
| [#25](025-HU-01.9.md) | Historia de usuario | HU-01.9 — Exportar los datos básicos de mi cuenta |
| [#32](032-HU-07.1.md) | Historia de usuario | HU-07.1 — Consultar y filtrar casos en una lista |
| [#33](033-HU-07.2.md) | Historia de usuario | HU-07.2 — Explorar los mismos casos en el mapa |
| [#34](034-HU-08.1.md) | Historia de usuario | HU-08.1 — Generar un cartel PDF con QR legible |
| [#35](035-HU-08.2.md) | Historia de usuario | HU-08.2 — Descargar y compartir mi cartel y enlace |
| [#36](036-HU-10.1.md) | Historia de usuario | HU-10.1 — Reportar un avistamiento desde la web pública |
| [#37](037-HU-10.2.md) | Historia de usuario | HU-10.2 — Reportar un avistamiento desde Android |
| [#38](038-HU-11.1.md) | Historia de usuario | HU-11.1 — Consultar la cronología del caso |
| [#39](039-HU-11.2.md) | Historia de usuario | HU-11.2 — Revisar y clasificar un avistamiento |
| [#40](040-HU-12.1.md) | Historia de usuario | HU-12.1 — Seguir y dejar de seguir casos y zonas |
| [#41](041-HU-12.2.md) | Historia de usuario | HU-12.2 — Consultar mis alertas en una bandeja persistente |
| [#42](042-HU-12.3.md) | Historia de usuario | HU-12.3 — Recibir notificaciones push con reintento |
| [#43](043-HU-14.1.md) | Historia de usuario | HU-14.1 — Denunciar contenido con un motivo |
| [#44](044-HU-14.2.md) | Historia de usuario | HU-14.2 — Bloquear y desbloquear usuarios |
| [#45](045-HU-14.3.md) | Historia de usuario | HU-14.3 — Revisar denuncias y moderar con auditoría |
| [#46](046-HU-14.4.md) | Historia de usuario | HU-14.4 — Apelar una decisión de moderación |
| [#47](047-HU-15.1.md) | Historia de usuario | HU-15.1 — Conservar borradores al perder conexión |
| [#48](048-HU-15.2.md) | Historia de usuario | HU-15.2 — Reintentar mis envíos pendientes sin duplicarlos |
| [#49](049-HU-15.3.md) | Historia de usuario | HU-15.3 — Consultar casos guardados sin conexión |
| [#50](050-HU-16.1.md) | Historia de usuario | HU-16.1 — Consultar estadísticas agregadas del piloto |
| [#51](051-HU-16.2.md) | Historia de usuario | HU-16.2 — Controlar funciones del piloto con auditoría |

## In Review

Sin issues en este estado.

## Done

Sin issues en este estado.

Avance local posterior: HU-04.1/#30 y HU-04.2/#31 continúan en codex/pet-photos con cámara, principal y procesamiento protegido/miniaturas preparados. Snapshot remoto In progress conservado. Patch012/Edge y demo Android/Supabase/runtime hosted pendientes; no se cierran issues por225 Flutter/15 SQL/7 Deno locales. Detalles en ESTADO y ADR-020.


</details>
