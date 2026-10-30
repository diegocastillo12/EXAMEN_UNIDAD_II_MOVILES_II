# Backlog MVP y trazabilidad académica

25/10: HU-25/#71 y HU-26/#72 implementadas localmente en `feature/case-matching`.
Hallazgos independientes aprobados expresamente, sin retirar avisos vinculados
ni reclasificar históricos. Encoder visual CLIP CPU local en Nuxt existente,
índices/revisiones privadas (plan040), ranking exploratorio de hasta cinco casos,
revisión humana y recorridos Android/web. Sin worker, inferencia externa ni FCM.
[ADR-138](decisiones/138-motor-visual-local-y-hallazgos-independientes.md) y
[ficha](funcionalidades/coincidencias-de-casos.md). Activación040/demo alojada,
dataset/evaluación, aceptación e integración pendientes; no se cierra el MVP.

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

Fecha: 8 de octubre de 2026. Responsable: @srg-cp.

Archivos individuales de los 51 issues y clasificación operativa: [docs/backlog/README.md](backlog/README.md). Los estados están aplicados tanto en etiquetas como en el Status nativo del [tablero EntreHuellas](https://github.com/users/srg-cp/projects/3/views/1), verificados para las 51 tarjetas. Las fichas siguientes conservan planificación y trazabilidad; el índice individual incluye estado y motivo.

Actualización operativa del 10 de octubre: HU-02.1 / #26 y su épica HU-02 / #2 pasan a In progress en GitHub y Projects. Zonas implementadas localmente, 212 pruebas Flutter/13 SQL aprobadas y patch010 aplicado en Supabase según el usuario; pendientes demostración Android/Supabase e integración del código. HU-02.2 / #27 sigue en Backlog. Véase [ESTADO](ESTADO.md).

## Estructura y numeración

La base de planificación conserva HU-01 a HU-16 y los issues #1–#16; desde25/10 se incorporan además HU-25/HU-26 originales como #71/#72. Las cantidades del desglose inicial siguiente son históricas. Doce describen alcance amplio y son **épicas**; cuatro conservan un resultado cohesivo y siguen como historias ejecutables. Hay **39 historias ejecutables** (35 derivadas y cuatro originales) y **12 épicas**: 51 issues abiertos asignados a srg-cp. No contar épicas e historias dos veces como esfuerzo ni presentar 51 entregas independientes.

HU-XX.n es una convención local para una historia derivada de HU-XX. Conserva trazabilidad con los RF y el informe original; no es una norma universal ni el número del issue. No se eliminan ni renumeran las HU del plan maestro. Una rúbrica docente puede pedir otra presentación; aún no se ha recibido.

## Calidad y planificación

Cada historia expresa Como/quiero/para y entrega un resultado verificable. UI, dominio, repositorio, servidor y pruebas pertenecen a la misma entrega cuando corresponden; no se convierten en historias sin valor de usuario. Los errores, permisos e idempotencia siguen dentro del flujo. Las épicas conservan los criterios originales y se cierran tras sus historias y la demostración integrada.

S1–S6 son objetivos, no plazos comprometidos. La prioridad de referencia se conserva de la HU original: HU-16 Media, resto Alta. Las estimaciones están pendientes y se acuerdan por entrega; no heredar ni repartir mecánicamente los puntos originales. Antes de comprometer una historia, concretar alcance/reglas/permisos, disponer de contratos/dependencias y acordar aceptación/estimación.

Las dependencias son resultados concretos. No completar baja/exportación para empezar mascotas. Ficha, avistamientos, cierre y alertas comparten contratos de estado: las verificaciones finales cruzadas no son prerrequisitos circulares para empezar. Se comprobó el grafo de 39 entregas sin ciclos.

## Refinamiento y alcance

- #44: alcance concretado e implementado localmente23/10 en
  [ADR-130](decisiones/130-bloqueos-de-interacciones-entre-cuentas.md): nuevas
  contribuciones autenticadas, sin chat ni bloqueo implícito de funciones críticas.
  Contacto/foto ocultos según confirmación del usuario, con consentimiento intacto.
  Activación034/036/demo remotas pendientes; estado GitHub sin sincronización nueva.
- #51: acordar la interfaz administrativa mínima y las funciones controlables.
- #25: exportación básica a JSON UTF-8 con perfil propio y solicitudes/estados de baja, descargable o compartible; no depende de futuros casos/mascotas.

Las dos primeras aún no están listas para comprometer implementación. Registro, acceso, sesión, recuperación y onboarding tienen avance local documentado, sin acreditar todos los criterios con Android/servicios reales.

## Épicas y entregas

| HU original | Épica | Historias ejecutables |
| --- | --- | --- |
| HU-01 | [#1 — Entrar y gestionar mi cuenta](https://github.com/srg-cp/entrehuellas/issues/1) | [HU-01.1 / #17](https://github.com/srg-cp/entrehuellas/issues/17), [HU-01.2 / #18](https://github.com/srg-cp/entrehuellas/issues/18), [HU-01.3 / #19](https://github.com/srg-cp/entrehuellas/issues/19), [HU-01.4 / #20](https://github.com/srg-cp/entrehuellas/issues/20), [HU-01.5 / #21](https://github.com/srg-cp/entrehuellas/issues/21), [HU-01.6 / #22](https://github.com/srg-cp/entrehuellas/issues/22), [HU-01.7 / #23](https://github.com/srg-cp/entrehuellas/issues/23), [HU-01.8 / #24](https://github.com/srg-cp/entrehuellas/issues/24), [HU-01.9 / #25](https://github.com/srg-cp/entrehuellas/issues/25) |
| HU-02 | [#2 — Elegir zonas y preferencias de alertas](https://github.com/srg-cp/entrehuellas/issues/2) | [HU-02.1 / #26](https://github.com/srg-cp/entrehuellas/issues/26), [HU-02.2 / #27](https://github.com/srg-cp/entrehuellas/issues/27) |
| HU-03 | [#3 — Registrar una mascota](https://github.com/srg-cp/entrehuellas/issues/3) | [HU-03.1 / #28](https://github.com/srg-cp/entrehuellas/issues/28), [HU-03.2 / #29](https://github.com/srg-cp/entrehuellas/issues/29) |
| HU-04 | [#4 — Administrar las fotos de mi mascota](https://github.com/srg-cp/entrehuellas/issues/4) | [HU-04.1 / #30](https://github.com/srg-cp/entrehuellas/issues/30), [HU-04.2 / #31](https://github.com/srg-cp/entrehuellas/issues/31) |
| HU-07 | [#7 — Consultar y filtrar casos en lista y mapa](https://github.com/srg-cp/entrehuellas/issues/7) | [HU-07.1 / #32](https://github.com/srg-cp/entrehuellas/issues/32), [HU-07.2 / #33](https://github.com/srg-cp/entrehuellas/issues/33) |
| HU-08 | [#8 — Generar y compartir un cartel con QR](https://github.com/srg-cp/entrehuellas/issues/8) | [HU-08.1 / #34](https://github.com/srg-cp/entrehuellas/issues/34), [HU-08.2 / #35](https://github.com/srg-cp/entrehuellas/issues/35) |
| HU-10 | [#10 — Reportar un avistamiento desde web o app](https://github.com/srg-cp/entrehuellas/issues/10) | [HU-10.1 / #36](https://github.com/srg-cp/entrehuellas/issues/36), [HU-10.2 / #37](https://github.com/srg-cp/entrehuellas/issues/37) |
| HU-11 | [#11 — Revisar avistamientos y consultar la cronología](https://github.com/srg-cp/entrehuellas/issues/11) | [HU-11.1 / #38](https://github.com/srg-cp/entrehuellas/issues/38), [HU-11.2 / #39](https://github.com/srg-cp/entrehuellas/issues/39) |
| HU-12 | [#12 — Recibir alertas y consultarlas en la bandeja](https://github.com/srg-cp/entrehuellas/issues/12) | [HU-12.1 / #40](https://github.com/srg-cp/entrehuellas/issues/40), [HU-12.2 / #41](https://github.com/srg-cp/entrehuellas/issues/41), [HU-12.3 / #42](https://github.com/srg-cp/entrehuellas/issues/42) |
| HU-14 | [#14 — Denunciar contenido y atender reportes](https://github.com/srg-cp/entrehuellas/issues/14) | [HU-14.1 / #43](https://github.com/srg-cp/entrehuellas/issues/43), [HU-14.2 / #44](https://github.com/srg-cp/entrehuellas/issues/44), [HU-14.3 / #45](https://github.com/srg-cp/entrehuellas/issues/45), [HU-14.4 / #46](https://github.com/srg-cp/entrehuellas/issues/46) |
| HU-15 | [#15 — Conservar borradores sin conexión y reintentar envíos](https://github.com/srg-cp/entrehuellas/issues/15) | [HU-15.1 / #47](https://github.com/srg-cp/entrehuellas/issues/47), [HU-15.2 / #48](https://github.com/srg-cp/entrehuellas/issues/48), [HU-15.3 / #49](https://github.com/srg-cp/entrehuellas/issues/49) |
| HU-16 | [#16 — Consultar estadísticas básicas del MVP](https://github.com/srg-cp/entrehuellas/issues/16) | [HU-16.1 / #50](https://github.com/srg-cp/entrehuellas/issues/50), [HU-16.2 / #51](https://github.com/srg-cp/entrehuellas/issues/51) |

Sin dividir: [HU-05 / #5](https://github.com/srg-cp/entrehuellas/issues/5), [HU-06 / #6](https://github.com/srg-cp/entrehuellas/issues/6), [HU-09 / #9](https://github.com/srg-cp/entrehuellas/issues/9) y [HU-13 / #13](https://github.com/srg-cp/entrehuellas/issues/13).

## Fichas de las 39 historias ejecutables

### HU-05 — Publicar un caso de mascota perdida — [#5](https://github.com/srg-cp/entrehuellas/issues/5)

Como propietario, quiero publicar la desaparición de mi mascota con hora, lugar y características para que otras personas puedan ayudar a encontrarla.

- Requisitos: RF-05.
- Sprint: **S3**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo publicar un caso de una mascota que estoy autorizado a gestionar, con fotos, fecha, hora, lugar y características.
- [ ] Solo puede existir un caso perdido activo por mascota; la API rechaza una segunda publicación activa.
- [ ] Puedo elegir el lugar manualmente si deniego el permiso de ubicación.
- [ ] La ficha pública muestra una zona aproximada y no expone domicilio, documentos ni información de salud.
- [ ] Repetir el mismo envío con su clave de idempotencia crea un único caso.
- [ ] Al completar la publicación se confirma el estado activo; si falla, el formulario conserva los datos para reintentar.

**Dependencias**

- #28 — HU-03.1.
- #29 — HU-03.2.
- #30 — HU-04.1.
- #31 — HU-04.2.

**Validación específica**

Con dos usuarios y una mascota con fotos, publicar perdido y reintentar la misma clave. Intentar publicar con usuario ajeno y dos casos activos simultáneos de la misma mascota. Denegar GPS, forzar error y revisar la proyección pública.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

### HU-06 — Publicar una mascota encontrada — [#6](https://github.com/srg-cp/entrehuellas/issues/6)

Como persona que encuentra una mascota, quiero publicar sus fotos y la zona donde la encontré para facilitar que su propietario la identifique.

- Requisitos: RF-06.
- Sprint: **S3**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo publicar un encontrado sin conocer al dueño y sin registrar previamente un perfil de mascota.
- [ ] El formulario permite registrar fotos, rasgos, fecha, hora, zona y custodia opcional.
- [ ] Puedo seleccionar el lugar manualmente y la ficha pública utiliza una ubicación aproximada.
- [ ] La publicación no asigna automáticamente propietario ni vincula la mascota por similitud visual.
- [ ] Un reintento del mismo envío no duplica el caso y los errores permiten conservar los datos.

**Dependencias**

- #20 — HU-01.4.
- #30 — HU-04.1.
- #31 — HU-04.2.
- #5.

Reutilizar el procesamiento seguro de fotos sin exigir al usuario registrar una mascota propia: el encontrado admite pet_id nulo.

**Validación específica**

Publicar encontrado con pet_id nulo, sin dueño ni mascota propia, con fotos y custodia opcional. Denegar GPS, reintentar la misma clave y simular fallo. Comprobar que no se asigna dueño por similitud y que las fotos públicas son seguras.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

### HU-09 — Consultar la ficha del caso desde el navegador — [#9](https://github.com/srg-cp/entrehuellas/issues/9)

Como visitante, quiero abrir el QR o enlace de un caso desde mi navegador para consultar la información y colaborar sin instalar EntreHuellas.

- Requisitos: RF-09.
- Sprint: **S4**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] El enlace abre una ficha utilizable desde un navegador móvil sin instalar la app.
- [ ] La ficha presenta fotos, rasgos, zona aproximada y estado vigente del caso.
- [ ] Un token revocado muestra una página neutral sin revelar información privada.
- [ ] Un caso cerrado muestra su resolución y no admite nuevos avistamientos ordinarios.
- [ ] El QR contiene un identificador opaco; no incluye datos personales en su contenido.
- [ ] La ficha permite acceder al formulario de avistamiento cuando el caso lo admite.

**Dependencias**

- #5.
- #6.

Implementar primero el contrato de ficha/token/estado y apps/platform. Coordinar después el enlace al formulario con #36 y comprobar resolución/bloqueo con #13; estas son verificaciones de integración, no prerrequisitos circulares para empezar la ficha. Hosting y URL estable deben acordarse antes de publicación/impresión de uso real.

**Validación específica**

Abrir un token válido, inexistente y revocado desde un segundo teléfono sin app. Revisar campos públicos y token opaco; tras #13 comprobar resolución/rechazo de reportes y tras #36 probar el enlace al formulario.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

### HU-13 — Cerrar un caso como recuperado — [#13](https://github.com/srg-cp/entrehuellas/issues/13)

Como responsable de una mascota recuperada, quiero cerrar el caso para actualizar su ficha y detener la difusión de búsqueda.

- Requisitos: RF-07.
- Sprint: **S5**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Solo el responsable autorizado puede confirmar la recuperación; un usuario ajeno recibe rechazo.
- [ ] El cierre registra actor, fecha, motivo y evidencia opcional, y actualiza el estado en una operación consistente.
- [ ] El detalle, mapa y ficha pública reflejan el estado resuelto; los carteles existentes enlazan a esa ficha actualizada.
- [ ] Después del cierre dejan de enviarse alertas de búsqueda y se rechazan nuevos avistamientos ordinarios.
- [ ] Un nuevo episodio de desaparición se registra como otro caso conservando el historial anterior.

**Dependencias**

- #5.
- #6.

Implementar cierre atómico sobre el contrato de casos y estados. Comprobar después ficha #9, reportes #36/#37, mapa #33 y alertas #41/#42; no exigir que push esté terminado para implementar cierre. Los demás flujos deben consumir el estado autorizado del servidor. Cerrar este issue solo tras verificar todas las integraciones de sus criterios.

**Validación específica**

Cerrar con responsable, usuario ajeno y dos solicitudes concurrentes. Comprobar historial, mapa y QR ya emitido; rechazar nuevos reportes y alertas de búsqueda. Crear un episodio nuevo y conservar el historial del anterior.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

### HU-01.1 — Registrarme y confirmar mi correo — [#17](https://github.com/srg-cp/entrehuellas/issues/17)

Como persona que crea una cuenta, quiero registrarme con mi nombre, correo y contraseña y confirmar un código para acceder con una identidad verificada.

- Requisitos: RF-01.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] El formulario valida nombre, correo y contraseña/confirmación y muestra errores por campo sin perder los datos necesarios.
- [ ] Si Auth exige confirmación, puedo introducir o pegar seis dígitos, reenviar tras 60 segundos y reintentar códigos incorrectos, vencidos o usados.
- [ ] Solo una sesión válida habilita el recorrido privado; autoconfirmación del servidor también respeta esta regla.
- [ ] El registro crea un único perfil vinculado a Auth; reintentos o accesos posteriores no lo duplican y ningún error expone mensajes internos ni secretos.

**Dependencias**

Sin historias previas; requiere la base/configuración del proyecto.

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Con una cuenta nueva, registrar y confirmar en Android leyendo el correo en PC. Repetir con código incorrecto, vencido y usado, y con Auth autoconfirmado. Comprobar un solo perfil por identidad y ausencia de acceso antes de confirmar.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local y pruebas registradas; pendiente de demostración integrada con Supabase y Android. No equivale a terminado. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.2 — Acceder con correo y contraseña — [#18](https://github.com/srg-cp/entrehuellas/issues/18)

Como usuario registrado, quiero iniciar sesión con correo y contraseña para entrar a mi cuenta.

- Requisitos: RF-01.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Credenciales válidas permiten acceder a mi cuenta y recuperan mi perfil existente sin duplicarlo.
- [ ] Credenciales incorrectas o correo sin confirmar muestran feedback contextual comprensible y permiten reintentar.
- [ ] Durante el ingreso se evita el doble envío y solo la sesión confirmada habilita navegación privada.

**Dependencias**

- [HU-01.1 — #17](https://github.com/srg-cp/entrehuellas/issues/17)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Ingresar con credenciales válidas, contraseña incorrecta y correo sin confirmar. Repetir el toque durante la petición; comprobar una operación y un único perfil.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local y pruebas registradas; pendiente de demostración integrada con Supabase y Android. No equivale a terminado. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.3 — Acceder con Google — [#19](https://github.com/srg-cp/entrehuellas/issues/19)

Como usuario, quiero iniciar sesión mediante Google para acceder sin crear una contraseña adicional.

- Requisitos: RF-01.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] El retorno OAuth en Android funciona con la app abierta y cerrada y solo una sesión válida concede acceso.
- [ ] El primer ingreso vincula un único perfil a la identidad Auth; los siguientes no lo duplican.
- [ ] Cancelar o fallar OAuth deja el acceso disponible con recuperación comprensible; abrir el navegador no cuenta como autenticación.

**Dependencias**

Sin historias previas; requiere la base/configuración del proyecto.

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Completar Google desde Android con app abierta y cerrada; cancelar el navegador y simular fallo de retorno. Reingresar con la misma identidad y comprobar que el perfil no se duplica.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local y pruebas registradas; pendiente de demostración integrada con Supabase y Android. No equivale a terminado. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.4 — Conservar y cerrar mi sesión de forma segura — [#20](https://github.com/srg-cp/entrehuellas/issues/20)

Como usuario autenticado, quiero retomar mi sesión válida y cerrarla cuando lo necesite para controlar el acceso a mis datos.

- Requisitos: RF-01.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Al reiniciar Android se restaura una sesión válida y se consulta el estado de entrada de esa cuenta.
- [ ] Sesiones inválidas o vencidas sin renovación autorizada no permiten consultar ni operar recursos privados; el servidor rechaza credenciales inválidas.
- [ ] Cerrar sesión retira las pantallas y operaciones privadas, incluso mediante rutas directas; si falla se muestra error y reintento.
- [ ] Cambiar de cuenta no conserva datos ni estado privado de la anterior.

**Dependencias**

- [HU-01.2 — #18](https://github.com/srg-cp/entrehuellas/issues/18)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Reiniciar con sesión válida; revocar o invalidar la sesión y solicitar una ruta privada y su operación backend. Cerrar sesión, usar Atrás y cambiar de A a B; comprobar que no aparece información de A.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local y pruebas registradas; pendiente de demostración integrada con Supabase y Android. No equivale a terminado. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.5 — Completar el onboarding de mi cuenta — [#21](https://github.com/srg-cp/entrehuellas/issues/21)

Como usuario que ingresa por primera vez, quiero completar las tres etapas de introducción para conocer el recorrido antes de usar la app.

- Requisitos: RF-01; recorrido de acceso acordado en ADR-004.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Tras login, una cuenta pendiente ve tres etapas sin Omitir y entra a la app solo tras guardar Comenzar en la tercera.
- [ ] La finalización persiste por cuenta tras reiniciar; otra cuenta del dispositivo conserva su propio estado.
- [ ] Un fallo al consultar o guardar no permite saltar el onboarding y ofrece reintento.
- [ ] La RPC comprueba identidad/permisos; una cuenta no puede completar el onboarding de otra.

**Dependencias**

- [HU-01.4 — #20](https://github.com/srg-cp/entrehuellas/issues/20)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Usar A pendiente y B completada en el mismo dispositivo. Completar las tres etapas de A, reiniciar y comprobar persistencia. Forzar fallo de consulta/RPC y probar intento de completar el perfil de B con la sesión de A.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local y pruebas registradas; pendiente de demostración integrada con Supabase y Android. No equivale a terminado. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.6 — Recuperar mi contraseña con un código — [#22](https://github.com/srg-cp/entrehuellas/issues/22)

Como usuario que olvidó su contraseña, quiero verificar un código por correo y establecer una contraseña nueva para recuperar el acceso a mi cuenta.

- Requisitos: RF-01.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] La solicitud no revela si el correo corresponde a una cuenta; permite código de seis dígitos y reenvío tras 60 segundos.
- [ ] Un código válido solicitado en Android puede leerse en PC e introducirse en Android; códigos incorrectos/vencidos/usados permiten recuperación segura.
- [ ] La sesión de recuperación abre Nueva contraseña antes de onboarding/Inicio; contraseña y confirmación cumplen la política del servidor.
- [ ] Tras guardar y salir se cierra la sesión de recuperación y puedo ingresar con la contraseña nueva; cancelar tampoco habilita acceso privado.

**Dependencias**

Sin historias previas; requiere la base/configuración del proyecto.

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Solicitar recuperación en Android, leer el correo en PC y verificar el código en Android. Probar OTP incorrecto/vencido/usado, confirmación distinta y contraseña rechazada; cancelar y terminar el flujo. Reingresar con la nueva contraseña.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local y pruebas registradas; pendiente de demostración integrada con Supabase y Android. No equivale a terminado. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.7 — Consultar y editar mi perfil — [#23](https://github.com/srg-cp/entrehuellas/issues/23)

Como usuario autenticado, quiero consultar y modificar los datos mínimos de mi perfil para mantener mi información de cuenta actualizada.

- Requisitos: RF-01.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Consulto el perfil vinculado a mi identidad y edito los campos permitidos con validación explícita.
- [ ] El guardado se confirma tras respuesta del servidor y persiste al reiniciar; un fallo conserva la edición para reintentar.
- [ ] RLS/grants rechazan lectura y edición del perfil de otra cuenta, incluidas peticiones directas.
- [ ] No puedo alterar desde el cliente identidad, rol ni campos administrados por el servidor.

**Dependencias**

- [HU-01.4 — #20](https://github.com/srg-cp/entrehuellas/issues/20)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Con A y B, editar el perfil de A y reiniciar. Desde B, intentar consultar/modificar el identificador de A y alterar campos administrados por servidor. Cortar conexión al guardar y recuperar la edición.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.8 — Solicitar la baja y consultar su estado — [#24](https://github.com/srg-cp/entrehuellas/issues/24)

Como usuario autenticado, quiero registrar una solicitud de baja y consultar su estado para gestionar la salida de mi cuenta de forma trazable.

- Requisitos: RF-34.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Una sesión verificada permite confirmar la solicitud de baja; el servidor registra solicitante, fecha y estado.
- [ ] Puedo consultar el estado de mi propia solicitud sin acceder a solicitudes ajenas.
- [ ] Un reintento no crea solicitudes activas duplicadas; errores permiten reintentar sin mostrar éxito falso.
- [ ] El flujo explica el alcance de la solicitud sin afirmar eliminación inmediata o completa que no se haya ejecutado.

**Dependencias**

- [HU-01.7 — #23](https://github.com/srg-cp/entrehuellas/issues/23)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Con A, registrar una solicitud y consultar su estado; repetir el mismo envío y comprobar una solicitud activa. Con B, intentar leer o modificar la de A. Probar sesión inválida y fallo de red.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-01.9 — Exportar los datos básicos de mi cuenta — [#25](https://github.com/srg-cp/entrehuellas/issues/25)

Como usuario autenticado, quiero obtener una exportación básica de mis datos para conservar una copia de mi información.

- Requisitos: Gestión de cuenta de HU-01, exportación básica acordada en GUIA_MVP S1.
- Sprint: **S1**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo descargar o compartir desde Android un archivo JSON UTF-8 con mi perfil y mis solicitudes de baja (si existen), incluyendo sus estados. Esta exportación básica de cuenta no depende de implementar mascotas o casos.
- [ ] La exportación incluye únicamente datos autorizados de la cuenta, sin tokens, claves ni datos privados ajenos.
- [ ] Sesión inválida y solicitud de datos ajenos reciben rechazo del servidor.
- [ ] Si falla la generación o entrega puedo reintentar sin afectar mis datos.

**Dependencias**

- [HU-01.7 — #23](https://github.com/srg-cp/entrehuellas/issues/23)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Con A y B con perfiles y solicitudes distintos, exportar A y comprobar el contenido JSON contra sus registros autorizados. Intentar exportar A con sesión de B o inválida. Cancelar la hoja de compartir y reintentar un fallo de generación.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

**Refinamiento y alcance**

Exportación delimitada a datos básicos de cuenta; quedan por implementar la entrega y su validación.

### HU-02.1 — Guardar mis zonas y radios de interés — [#26](https://github.com/srg-cp/entrehuellas/issues/26)

Actualización local, 9 de octubre: implementación de selección manual, radios y operaciones privadas preparada en `feature/interest-zones`; contrato y mapa en [ADR-018](decisiones/018-zonas-manuales-privadas.md). Validación local registrada en ESTADO; migración/demostración Supabase y Android pendientes. Las casillas siguientes permanecen pendientes hasta verificar el recorrido real. No se cambió GitHub ni se completó HU-02.2.

Como usuario, quiero elegir, editar y quitar zonas con su radio para consultar novedades relevantes sin GPS permanente.

- Requisitos: RF-02; RF-16.
- Sprint: **S2**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo seleccionar manualmente una zona, definir su radio y editarla o retirarla.
- [ ] Denegar GPS no bloquea el flujo manual; concederlo es opcional y no activa seguimiento continuo.
- [ ] Mis zonas persisten tras reiniciar y el servidor impide que otro usuario las modifique.
- [ ] Un error de guardado conserva la selección y permite reintentar sin confirmación falsa.

**Dependencias**

- [HU-01.4 — #20](https://github.com/srg-cp/entrehuellas/issues/20)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Denegar GPS, seleccionar dos zonas manuales, modificar el radio y retirar una. Reiniciar; con B intentar modificar una zona de A. Simular fallo de persistencia y comprobar que no se confirma.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local y pruebas registradas; pendiente de activación y demostración con Supabase/Android. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-02.2 — Configurar mis preferencias de alertas — [#27](https://github.com/srg-cp/entrehuellas/issues/27)

Como usuario, quiero elegir tipos y canales de alertas y desactivarlas para controlar qué avisos recibiré.

- Requisitos: RF-02; RF-16.
- Sprint: **S2**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo elegir tipos y canales soportados por el MVP y desactivar su recepción.
- [ ] Las preferencias se conservan al reiniciar y solo su propietario puede modificarlas.
- [ ] La configuración no exige GPS continuo ni afirma que el push funciona antes de integrar HU-12.
- [ ] Se muestran carga y fallo de guardado con reintento contextual.

**Dependencias**

- [HU-02.1 — #26](https://github.com/srg-cp/entrehuellas/issues/26)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Guardar preferencias, reiniciar y comprobar tipos/canales/desactivación. Intentar cambiarlas con otra cuenta y provocar fallo de guardado. Verificar que no se solicita GPS continuo.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-03.1 — Registrar y consultar mis mascotas — [#28](https://github.com/srg-cp/entrehuellas/issues/28)

Como propietario, quiero guardar una mascota y consultar su ficha para preparar la información para un caso.

- Requisitos: RF-03.
- Sprint: **S2**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Registro especie, nombre, sexo, edad aproximada y rasgos; los campos opcionales admiten desconocidos.
- [ ] Los obligatorios se validan con errores por campo y el guardado se confirma solo al persistir en servidor.
- [ ] La mascota queda vinculada a mi cuenta y aparece en mi listado/detalle tras reiniciar.
- [ ] Otro usuario no puede editarla mediante app o peticiones directas; un fallo conserva el formulario.

**Dependencias**

- [HU-01.4 — #20](https://github.com/srg-cp/entrehuellas/issues/20)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Registrar una mascota con obligatorios y opcionales desconocidos; provocar errores por campo y de red. Reiniciar y consultar listado/detalle; intentar editarla desde B.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-03.2 — Editar la ficha de mi mascota con sus fotos — [#29](https://github.com/srg-cp/entrehuellas/issues/29)

Como propietario, quiero actualizar los datos y consultar las fotos de mi mascota para mantener una ficha útil para publicar casos.

- Requisitos: RF-03.
- Sprint: **S2**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo modificar los campos permitidos de una mascota propia con validaciones y persistencia.
- [ ] La ficha integra fotografías validadas y su imagen principal conforme a HU-04.
- [ ] Otra cuenta no puede editar el recurso; un error permite reintentar sin perder cambios.
- [ ] Reiniciar y volver a consultar muestra datos y fotos efectivamente guardados.

**Dependencias**

- [HU-03.1 — #28](https://github.com/srg-cp/entrehuellas/issues/28)
- [HU-04.1 — #30](https://github.com/srg-cp/entrehuellas/issues/30)
- [HU-04.2 — #31](https://github.com/srg-cp/entrehuellas/issues/31)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Editar una mascota propia, consultar fotos y principal cargadas mediante #30/#31 y reiniciar. Probar edición ajena y fallo de guardado preservando cambios.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-04.1 — Agregar fotografías seguras a mi mascota — [#30](https://github.com/srg-cp/entrehuellas/issues/30)

Como propietario, quiero cargar fotografías desde galería o cámara disponible para identificar visualmente a mi mascota.

- Requisitos: RF-03.
- Sprint: **S2**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] La galería funciona aunque se deniegue cámara; si se deniega galería se informa sin bloquear la ficha.
- [ ] Formatos y tamaños no admitidos se rechazan tanto en cliente como en servidor con feedback comprensible.
- [ ] La carga requiere autorización por mascota; otro usuario no puede alterar sus archivos y un fallo admite reintento.
- [ ] Las imágenes y miniaturas públicas eliminan EXIF de ubicación en sus bytes; el procesamiento se verifica con límites reales del runtime.

**Dependencias**

- [HU-03.1 — #28](https://github.com/srg-cp/entrehuellas/issues/28)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Probar cámara/galería y permisos denegados, formatos/tamaños límite y archivos manipulados mediante petición directa. Con otra cuenta intentar cargar/modificar archivos. Descargar los bytes públicos de original/miniatura y verificar ausencia de EXIF de ubicación; comprobar límites del runtime.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-04.2 — Elegir y retirar fotografías de mi mascota — [#31](https://github.com/srg-cp/entrehuellas/issues/31)

Como propietario, quiero seleccionar una foto principal y retirar imágenes para mantener una presentación clara de mi mascota.

- Requisitos: RF-03.
- Sprint: **S2**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo elegir una principal entre mis fotos y verla en la ficha al volver a consultar.
- [ ] Puedo retirar una foto; si era principal se mantiene una regla consistente y visible, sin referencia rota.
- [ ] Solo el propietario puede cambiar principal o eliminar; se respetan políticas de Storage y registros.
- [ ] Fallos permiten reintentar y la selección/eliminación solo se confirma al completarse en servidor.

**Dependencias**

- [HU-04.1 — #30](https://github.com/srg-cp/entrehuellas/issues/30)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Elegir principal, reiniciar, eliminar una secundaria y luego la principal. Comprobar la regla de reemplazo y ausencia de referencias rotas. Repetir las operaciones desde otra cuenta y con fallo de Storage/base de datos.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-07.1 — Consultar y filtrar casos en una lista — [#32](https://github.com/srg-cp/entrehuellas/issues/32)

Como colaborador, quiero consultar casos paginados con filtros para encontrar búsquedas en una zona de interés.

- Requisitos: RF-13.
- Sprint: **S3**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Filtro por perdido/encontrado, especie, estado, distancia y período y abro el detalle.
- [ ] La paginación no repite resultados y distingue vacío, carga y error con reintento.
- [ ] Solo devuelve casos visibles y zona aproximada, sin coordenadas o datos privados.
- [ ] Puedo consultar por zona manual si deniego ubicación.

**Dependencias**

- [#5](https://github.com/srg-cp/entrehuellas/issues/5)
- [#6](https://github.com/srg-cp/entrehuellas/issues/6)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Usar datos reproducibles con casos de ambos tipos, diferentes especies/fechas/estados y un caso oculto. Combinar filtros y páginas y verificar ausencia de duplicados/datos privados. Denegar GPS y provocar vacío/error.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Implementación local del15 de octubre de2026 en feature/explore-case-list. Lista/filtros/paginación y zona manual con PostGIS; estados conservan privacidad previa (resueltos solo del autor). [Ficha](funcionalidades/explorar.md), [ADR-039](decisiones/039-explorar-lista-publica-paginada.md) y ESTADO registran evidencia local. Pendientes activación019/demo Android y verificación hosted. Casillas sin cierre automático ni actualización de GitHub. HU-07.2 continúa pendiente.

### HU-07.2 — Explorar los mismos casos en el mapa — [#33](https://github.com/srg-cp/entrehuellas/issues/33)

Como colaborador, quiero ver en el mapa los casos de mi consulta para comprender su distribución por zona.

- Requisitos: RF-13.
- Sprint: **S3**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Mapa y lista usan los mismos filtros y contrato de consulta geográfica.
- [ ] Los puntos muestran ubicación pública aproximada y permiten abrir el mismo detalle.
- [ ] La selección manual funciona sin permiso de ubicación y no necesita seguimiento continuo.
- [ ] Los errores del proveedor ofrecen recuperación sin exponer coordenadas privadas; se documentan proveedor y condiciones.

**Dependencias**

- [HU-07.1 — #32](https://github.com/srg-cp/entrehuellas/issues/32)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Aplicar la misma consulta de #32 en mapa/lista y comparar identificadores y filtros. Abrir el detalle desde ambos, denegar ubicación y simular fallo del proveedor. Inspeccionar las respuestas para descartar coordenadas privadas.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-08.1 — Generar un cartel PDF con QR legible — [#34](https://github.com/srg-cp/entrehuellas/issues/34)

Como responsable de un caso, quiero generar un cartel con foto y QR para difundir la búsqueda fuera de la app.

- Requisitos: RF-08; RF-37.
- Sprint: **S4**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Incluye foto principal y datos públicos mínimos con QR opaco hacia una URL estable de la ficha.
- [ ] PDF y QR son legibles en otro teléfono y en una impresión de prueba.
- [ ] No contiene domicilio, documentos, salud ni datos privados; un cartel existente enlaza al estado vigente.
- [ ] Si la generación falla, el caso sigue activo y puedo reintentar; Flutter puede generar el PDF sin exigir un worker.

**Dependencias**

- [#5](https://github.com/srg-cp/entrehuellas/issues/5)
- [#6](https://github.com/srg-cp/entrehuellas/issues/6)
- [#9](https://github.com/srg-cp/entrehuellas/issues/9)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Generar cartel desde perdido/encontrado, revisar PDF, escanearlo en otro teléfono y en impresión. Resolver el caso y volver a abrir el mismo QR; provocar error de generación y comprobar caso activo/reintento.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-08.2 — Descargar y compartir mi cartel y enlace — [#35](https://github.com/srg-cp/entrehuellas/issues/35)

Como responsable de un caso, quiero guardar o compartir el PDF y su enlace para hacer llegar la búsqueda a otras personas.

- Requisitos: RF-08; RF-37.
- Sprint: **S4**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo descargar/guardar el cartel e invocar compartir PDF y enlace desde Android.
- [ ] El destinatario abre la URL pública sin instalar la app.
- [ ] Cancelar o fallar el guardado/compartir permite reintentar sin cambiar el caso.
- [ ] Solo se comparte el artefacto público correcto, sin adjuntar archivos o datos privados.

**Dependencias**

- [HU-08.1 — #34](https://github.com/srg-cp/entrehuellas/issues/34)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

En Android guardar y compartir PDF/enlace, cancelar la hoja del sistema y reintentar un fallo. Abrir lo recibido en otro dispositivo sin la app y revisar que no haya adjuntos privados.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-10.1 — Reportar un avistamiento desde la web pública — [#36](https://github.com/srg-cp/entrehuellas/issues/36)

Como visitante, quiero informar cuándo y dónde vi la mascota desde su ficha para colaborar sin instalar la app ni crear cuenta.

- Requisitos: RF-11.
- Sprint: **S4**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Registro hora real, punto manual o ubicación con origen/precisión, comentario y foto opcional; denegar GPS/cámara no impide continuar.
- [ ] El servidor rechaza fecha futura, admite e identifica reporte tardío y valida evidencia pública sin EXIF.
- [ ] La confirmación ocurre tras guardar; repetir la misma clave crea un solo avistamiento y los fallos conservan datos.
- [ ] Caso cerrado/no disponible rechaza reportes ordinarios y el servidor aplica límites de abuso con permisos públicos acotados.

**Dependencias**

- [#9](https://github.com/srg-cp/entrehuellas/issues/9)
- [HU-04.1 — #30](https://github.com/srg-cp/entrehuellas/issues/30)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Desde navegador móvil sin sesión, enviar punto manual y comentario con/sin foto; denegar permisos. Probar fecha futura/tardía, doble envío, caso cerrado/revocado y límite de abuso. Comprobar un registro por clave y los bytes de evidencia pública.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-10.2 — Reportar un avistamiento desde Android — [#37](https://github.com/srg-cp/entrehuellas/issues/37)

Como colaborador, quiero enviar un avistamiento desde la app para aportar evidencia a un caso activo.

- Requisitos: RF-11.
- Sprint: **S4**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] La app permite hora real, comentario, foto opcional y punto manual si se deniega ubicación; galería alternativa a cámara.
- [ ] Comparte validación de fecha, estado e idempotencia con el flujo web sin duplicar reglas del servidor.
- [ ] Conserva los datos al fallar y confirma solo al persistir; doble envío no duplica reportes.
- [ ] El backend rechaza caso cerrado/no disponible y protege los datos y evidencia según el rol.

**Dependencias**

- [HU-10.1 — #36](https://github.com/srg-cp/entrehuellas/issues/36)
- [HU-01.4 — #20](https://github.com/srg-cp/entrehuellas/issues/20)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Repetir los escenarios de #36 desde Android, conservando formulario tras fallo. Enviar dos veces la misma clave y comparar el registro con el backend; denegar GPS/cámara y usar alternativa manual/galería.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-11.1 — Consultar la cronología del caso — [#38](https://github.com/srg-cp/entrehuellas/issues/38)

Como responsable de un caso, quiero ver sus eventos ordenados por hora real para interpretar la evolución de la búsqueda.

- Requisitos: RF-14.
- Sprint: **S5**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Cronología ordena por hora observada y distingue hora de recepción, incluidos reportes tardíos.
- [ ] Muestra evidencia y estado de revisión como conceptos separados.
- [ ] Un avistamiento confirmado no se presenta como ubicación actual garantizada.
- [ ] Solo muestra datos autorizados para el rol, con carga/error/reintento y sin pérdida del historial.

**Dependencias**

- [HU-10.1 — #36](https://github.com/srg-cp/entrehuellas/issues/36)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Cargar eventos cuyo orden de recepción difiere del observado, incluidos tardíos y revisiones sucesivas. Comprobar orden, ambas fechas, evidencia/historial y permisos con responsable/usuario ajeno.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-11.2 — Revisar y clasificar un avistamiento — [#39](https://github.com/srg-cp/entrehuellas/issues/39)

Como responsable de un caso, quiero clasificar evidencia y registrar un motivo para orientar la búsqueda con decisiones trazables.

- Requisitos: RF-12; RF-14.
- Sprint: **S5**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo clasificar útil, dudoso, rechazado o confirmado conforme a las transiciones permitidas.
- [ ] Cada decisión conserva actor, fecha y motivo y mantiene cambios anteriores.
- [ ] El servidor rechaza acciones de usuarios ajenos y estados no permitidos.
- [ ] La cronología refleja la revisión solo tras guardarla; un fallo o conflicto permite recuperación explícita.

**Dependencias**

- [HU-11.1 — #38](https://github.com/srg-cp/entrehuellas/issues/38)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Revisar con responsable autorizado y probar todos los estados permitidos; comprobar actor/motivo/historial. Enviar transición inválida, revisión ajena y cambios concurrentes; verificar recuperación sin perder auditoría.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-12.1 — Seguir y dejar de seguir casos y zonas — [#40](https://github.com/srg-cp/entrehuellas/issues/40)

Como usuario, quiero gestionar qué casos y zonas sigo para recibir novedades pertinentes.

- Requisitos: RF-16; RF-17; RF-18.
- Sprint: **S5**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo seguir y dejar de seguir casos y zonas conforme a mis preferencias guardadas.
- [ ] La suscripción persiste por cuenta y un usuario no modifica la de otro.
- [ ] Los destinatarios se seleccionan en servidor por caso/zona y preferencias, sin GPS continuo.
- [ ] Reintentos no duplican suscripciones y los cambios solo se confirman tras persistir.

**Dependencias**

- [HU-02.1 — #26](https://github.com/srg-cp/entrehuellas/issues/26)
- [HU-02.2 — #27](https://github.com/srg-cp/entrehuellas/issues/27)
- [#5](https://github.com/srg-cp/entrehuellas/issues/5)
- [#6](https://github.com/srg-cp/entrehuellas/issues/6)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Seguir/dejar de seguir caso y zona, reiniciar y repetir una solicitud. Usar preferencias y dos usuarios para comprobar destinatarios y rechazo de modificación ajena, sin GPS continuo.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-12.2 — Consultar mis alertas en una bandeja persistente — [#41](https://github.com/srg-cp/entrehuellas/issues/41)

Como usuario suscrito, quiero consultar novedades guardadas y marcarlas como leídas para recuperar avisos aunque no llegue el push.

- Requisitos: RF-17; RF-18.
- Sprint: **S5**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Un evento pertinente guarda la notificación y su trabajo de entrega antes de intentar push.
- [ ] La bandeja paginada permite marcar leído y abrir el recurso autorizado; otra cuenta no consulta mis alertas.
- [ ] Repetir el procesamiento no duplica notificaciones y no se generan alertas de búsqueda de casos ya cerrados.
- [ ] Los avisos no incluyen datos privados y puedo reintentar la consulta si falla.

**Dependencias**

- [HU-12.1 — #40](https://github.com/srg-cp/entrehuellas/issues/40)
- [#13](https://github.com/srg-cp/entrehuellas/issues/13)
- [HU-10.1 — #36](https://github.com/srg-cp/entrehuellas/issues/36)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Generar el mismo evento dos veces con FCM caído: comprobar una alerta y trabajo guardado, lectura/paginación y navegación autorizada. Con B consultar bandeja de A; cerrar caso y comprobar que no nace otra alerta de búsqueda.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-12.3 — Recibir notificaciones push con reintento — [#42](https://github.com/srg-cp/entrehuellas/issues/42)

Como usuario suscrito, quiero recibir avisos en mi teléfono para enterarme de novedades sin abrir la app.

- Requisitos: RF-17; RF-18.
- Sprint: **S5**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Android registra permiso/token y abre el recurso autorizado desde el aviso.
- [ ] FCM se invoca desde servidor con secretos protegidos y solo después de guardar la alerta y el trabajo.
- [ ] Fallo de FCM o token inválido queda registrado, permite reintento y conserva el aviso en bandeja sin duplicarlo.
- [ ] Los reintentos revisan preferencias/estado del caso y no envían nuevas alertas de búsqueda tras el cierre; el payload no expone datos privados.

**Dependencias**

- [HU-12.2 — #41](https://github.com/srg-cp/entrehuellas/issues/41)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Probar permiso push aceptado/denegado, token válido/inválido y proveedor caído. Reintentar trabajo y comprobar bandeja sin duplicación; cerrar el caso antes del reintento y revisar que no salga una alerta de búsqueda. Abrir la notificación con/sin sesión.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-14.1 — Denunciar contenido con un motivo — [#43](https://github.com/srg-cp/entrehuellas/issues/43)

Como usuario, quiero reportar una publicación o interacción disponible en el MVP para pedir revisión de contenido problemático.

- Requisitos: RF-22.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo indicar recurso, motivo y evidencia pertinente y confirmar solo tras guardar la denuncia.
- [ ] La denuncia conserva actor/fecha/recurso y un reintento no genera reportes duplicados del mismo envío.
- [ ] Solo roles autorizados consultan la evidencia privada; usuarios ajenos no acceden a ella.
- [ ] Denunciar no altera automáticamente el estado operativo ni promete una decisión; un fallo permite reintentar.

**Dependencias**

- [#5](https://github.com/srg-cp/entrehuellas/issues/5)
- [#6](https://github.com/srg-cp/entrehuellas/issues/6)
- [HU-10.1 — #36](https://github.com/srg-cp/entrehuellas/issues/36)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Denunciar un recurso disponible con motivo/evidencia y repetir la clave de envío. Probar fallo de guardado y lectura de evidencia con denunciante, moderador y usuario ajeno. Comprobar que la denuncia no modifica el estado operativo.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-14.2 — Bloquear y desbloquear usuarios — [#44](https://github.com/srg-cp/entrehuellas/issues/44)

Implementación local23/10: [bloqueos móvil/web](funcionalidades/bloqueos-usuarios.md),
SQL034/036 y pruebas. Contacto/foto ocultos entre bloqueados por confirmación
del usuario; QR anónimo conserva acceso. Casillas inferiores
pendientes de aceptación completa; no cerrar por evidencia local.

Como usuario, quiero controlar las interacciones permitidas con otra cuenta para limitar contactos problemáticos.

- Requisitos: RF-23.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Puedo bloquear/desbloquear una cuenta en las interacciones realmente disponibles en el MVP, sin crear un chat nuevo.
- [ ] El bloqueo persiste y las operaciones afectadas aplican la regla en servidor, no solo ocultan un botón.
- [ ] Solo gestiono mis bloqueos; un reintento no duplica relaciones y se comprueba cambio de cuenta.
- [ ] Se comunica el alcance concreto y un fallo permite reintentar sin éxito falso.

**Dependencias**

- [HU-01.4 — #20](https://github.com/srg-cp/entrehuellas/issues/20)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Tras concretar las interacciones afectadas, bloquear/desbloquear A→B y comprobar esas reglas mediante app y solicitudes directas. Reiniciar, cambiar de cuenta y repetir envíos; verificar persistencia y ausencia de exposición ajena.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

**Refinamiento y alcance**

Pendiente de refinamiento: enumerar las interacciones existentes afectadas y precisar el efecto de bloquear/desbloquear. No introducir chat ni bloqueo de funciones críticas implícitamente.

### HU-14.3 — Revisar denuncias y moderar con auditoría — [#45](https://github.com/srg-cp/entrehuellas/issues/45)

Como moderador autorizado, quiero revisar reportes y decidir su visibilidad para atender denuncias de forma trazable.

- Requisitos: RF-22; RF-33.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Una cola mínima permite consultar denuncia/evidencia según permisos y resolverla.
- [ ] Ocultar contenido o suspender un recurso requiere motivo y registra actor, fecha y decisión.
- [ ] Visibilidad queda separada del estado operativo; las consultas públicas excluyen contenido oculto.
- [ ] Servidor y UI rechazan usuarios sin rol; los accesos privados necesarios quedan auditados y los conflictos no borran decisiones.

**Dependencias**

- [HU-14.1 — #43](https://github.com/srg-cp/entrehuellas/issues/43)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Con moderador y usuario ordinario, consultar cola/evidencia y ocultar un recurso con motivo. Comprobar auditoría, exclusión pública y estado operativo conservado. Probar falta de rol y decisiones concurrentes.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-14.4 — Apelar una decisión de moderación — [#46](https://github.com/srg-cp/entrehuellas/issues/46)

Como usuario afectado, quiero presentar una apelación y consultar su respuesta para solicitar una revisión de la decisión.

- Requisitos: RF-33.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Existe una vía mínima para apelar una decisión propia con motivo y consultar su estado.
- [ ] Se vincula a la decisión y conserva historial; solo roles autorizados ven los datos privados.
- [ ] Un moderador autorizado registra respuesta con actor/fecha/motivo sin borrar la decisión original.
- [ ] Reintentos no duplican el mismo envío y usuarios ajenos no pueden apelar ni consultar por mí.

**Dependencias**

- [HU-14.3 — #45](https://github.com/srg-cp/entrehuellas/issues/45)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Apelar una decisión propia y repetir el envío; consultar estado y respuesta autorizada. Intentar apelar/ver una decisión ajena. Comprobar vínculos y conservación de la decisión original y su historial.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-15.1 — Conservar borradores al perder conexión — [#47](https://github.com/srg-cp/entrehuellas/issues/47)

Como usuario, quiero guardar localmente un caso o reporte incompleto para continuar sin perder datos tras reiniciar.

- Requisitos: RF-32.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Borradores de perdido/encontrado/avistamiento conservan campos y referencias de evidencia tras cortar red y reiniciar Android.
- [ ] Se muestran como borradores no publicados y puedo retomarlos.
- [ ] Persisten con Drift/SQLite e identificador estable destinado al envío.
- [ ] Los datos se separan por usuario y cierre/cambio de cuenta no expone borradores ajenos.

**Dependencias**

- [#5](https://github.com/srg-cp/entrehuellas/issues/5)
- [#6](https://github.com/srg-cp/entrehuellas/issues/6)
- [HU-10.2 — #37](https://github.com/srg-cp/entrehuellas/issues/37)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Crear borradores de perdido/encontrado/avistamiento con evidencia, cortar red y reiniciar Android. Retomar los datos, comprobar la clave estable y cambiar A→B/cerrar sesión para verificar aislamiento.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-15.2 — Reintentar mis envíos pendientes sin duplicarlos — [#48](https://github.com/srg-cp/entrehuellas/issues/48)

Como usuario con conexión inestable, quiero reintentar la cola de casos y reportes para publicar una sola vez al recuperar conectividad.

- Requisitos: RF-32.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] La cola persistente conserva payload y clave estable tras reiniciar o perder conexión durante el envío.
- [ ] Distingue borrador, pendiente, fallido y publicado; solo respuesta válida del servidor confirma publicación.
- [ ] Repetir la misma clave no duplica casos/avistamientos; payload incompatible y rechazo requieren resolución explícita.
- [ ] Cierre/cambio de sesión no sincroniza ni muestra envíos de otra cuenta.

**Dependencias**

- [HU-15.1 — #47](https://github.com/srg-cp/entrehuellas/issues/47)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Cortar la conexión antes y después de que el servidor persista el envío; reiniciar y reintentar la misma clave. Probar rechazo/conflicto de payload y cambio de usuario; comprobar una publicación y estados veraces.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-15.3 — Consultar casos guardados sin conexión — [#49](https://github.com/srg-cp/entrehuellas/issues/49)

Como usuario, quiero abrir casos previamente almacenados en caché para consultar información cuando no tenga red.

- Requisitos: RF-32.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Alta.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Casos consultados previamente permanecen accesibles tras perder red y reiniciar.
- [ ] Se informa que la información proviene de caché y puede estar desactualizada.
- [ ] Al volver la red puedo actualizar y se respetan estado/visibilidad/autorización del servidor.
- [ ] Datos privados locales se separan por cuenta y no se exponen al cambiar o cerrar sesión.

**Dependencias**

- [HU-07.1 — #32](https://github.com/srg-cp/entrehuellas/issues/32)
- [HU-01.4 — #20](https://github.com/srg-cp/entrehuellas/issues/20)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Consultar casos, cortar red y reiniciar; comprobar datos cacheados y aviso de desactualización. Cambiar de cuenta; ocultar/cerrar un caso en servidor y actualizar al recuperar red.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-16.1 — Consultar estadísticas agregadas del piloto — [#50](https://github.com/srg-cp/entrehuellas/issues/50)

Como administrador autorizado, quiero consultar conteos por período para evaluar la actividad del MVP.

- Requisitos: RF-35.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Media.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] Consulta casos publicados, avistamientos, cierres y reportes de moderación por período.
- [ ] Solo muestra agregados, sin nombres, salud ni coordenadas exactas.
- [ ] Distingue recuperados, cancelados y archivados y no atribuye automáticamente recuperaciones a la app.
- [ ] Servidor rechaza usuarios sin rol y los conteos coinciden con datos de demostración reproducibles.

**Dependencias**

- [#5](https://github.com/srg-cp/entrehuellas/issues/5)
- [#6](https://github.com/srg-cp/entrehuellas/issues/6)
- [HU-10.1 — #36](https://github.com/srg-cp/entrehuellas/issues/36)
- [#13](https://github.com/srg-cp/entrehuellas/issues/13)
- [HU-14.3 — #45](https://github.com/srg-cp/entrehuellas/issues/45)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Sembrar un conjunto reproducible con publicados, recuperados, cancelados, archivados, avistamientos y denuncias en varios períodos. Comparar conteos esperados, probar rol no autorizado e inspeccionar respuestas agregadas.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

### HU-16.2 — Controlar funciones del piloto con auditoría — [#51](https://github.com/srg-cp/entrehuellas/issues/51)

Como administrador autorizado, quiero habilitar o deshabilitar las funciones acordadas para gestionar la operación sin perder datos.

- Requisitos: RF-40.
- Sprint: **S6**; etapa MVP.
- Prioridad de referencia: Media.
- Estimación: pendiente de planificación.

**Criterios de aceptación**

- [ ] La interfaz mínima y la lista concreta de funciones controlables se acuerdan con el usuario antes de implementar.
- [ ] Un cambio autorizado se aplica en servidor y conserva los datos existentes.
- [ ] Actor, fecha y cambio quedan auditados; usuarios sin rol no consultan controles privados ni los modifican.
- [ ] Los flujos afectados comunican indisponibilidad y conservan consistencia ante reintentos o cambios concurrentes.

**Dependencias**

- [HU-16.1 — #50](https://github.com/srg-cp/entrehuellas/issues/50)

Las dependencias indican el comportamiento o contrato necesario; no exigen cerrar toda la agrupadora original. Las verificaciones que cruzan otras historias se coordinan sin crear ciclos de implementación.

**Validación específica**

Tras acordar funciones controlables e interfaz mínima, desactivar/activar una con rol administrador y probar sus operaciones desde un usuario común. Comprobar rechazo de cambios sin rol, datos conservados, auditoría y concurrencia.

Registrar el escenario, resultado y evidencia en este issue y en docs/ESTADO.md. Ejecutar formato, análisis y pruebas significativas de lo modificado. La evidencia de servicios reales no se sustituye por repositorios ficticios.

**Estado de partida**

Pendiente de implementación. Las casillas permanecen pendientes hasta verificar los criterios completos.

**Refinamiento y alcance**

Pendiente de refinamiento: acordar con el usuario la interfaz mínima y la lista de funciones controlables. No está lista para comprometer implementación hasta cerrar esta decisión.

## Reglas compartidas y definición de terminado

Cumplir docs/REGLAS_ARQUITECTURA.md y docs/REGLAS_UI_UX.md, Flutter/Clean Architecture/MVVM/casos de uso/repositorios y Supabase de ADR-001. Versionar datos/migraciones y comprobar permisos según database/README.md. No añadir infraestructura ni funciones posteriores al MVP implícitamente. La agrupación se expresa con listas/enlaces GitHub; no se crearon relaciones nativas de sub-issue. El campo Status del tablero está sincronizado con las etiquetas de los 51 issues.

Una historia termina con criterios demostrados, código integrado, datos versionados y validados, errores/permisos comprobados, demo reproducible y docs/ESTADO.md actualizado. Pruebas locales con sustitutos no acreditan Auth/RLS/Storage/FCM reales. Cerrar una derivada no cierra su épica.


## Avance local HU-02.2 — 10 de octubre de 2026

Preferencias de alertas / issue #27 implementadas localmente en `feature/alert-preferences`. Recepción general, tres tipos perdidas/encontradas/novedades de casos y canales bandeja/push, sin envío ni permisos; SQL040–043/plan011 privado/versionado según ADR-019. Patch011 y demo Android/Supabase pendientes antes de cerrar aceptación. El estado operativo de GitHub no se modifica por esta nota de desarrollo; la ficha individual distingue snapshot y avance local.

## Sincronización operativa GitHub/Projects — 10 de octubre de 2026

Por autorización del usuario, #27 (preferencias), #30 (carga de fotos), #31 (retirada de fotos) y épica #4 pasan a In progress en etiqueta y Status nativo. #2/#26 siguen In progress con evidencia actualizada: zonas/preferencias ya publicadas en commits5bcb543/006ebc6 y patch010/011 aplicados según usuario. Las fotos son avance parcial; cámara, selección explícita de principal, miniaturas/procesamiento público y validación real siguen pendientes. 51 tarjetas verificadas con etiqueta/Status coincidentes:34 Backlog y17 In progress, sin Ready/In review/Done. PR53 existe para mascotas, con descripción de plantilla; no se infiere aceptación completa ni se modifica ese PR. No se cerraron issues; fichas e índice sincronizados. La aplicación de parches no sustituye demo Android/Supabase autenticada.

Avance posterior de HU-04 del 10 de octubre: en codex/pet-photos están preparados cámara, principal/borrador/reemplazo y servidor de imágenes/miniaturas sin EXIF. ADR-020/plan012 requieren activación conjunta SQL/Edge y demo real antes de Done. Se conserva el snapshot remoto In progress; no se cambia GitHub desde esta implementación.

### Avance local de HU-05 — 10 de octubre de 2026

Issue#5 conserva snapshot remoto Backlog; no se actualizó GitHub en esta tarea. Implementación local de publicación autorizada, ubicación manual, preview/proyección pública y consultas en feature/lost-pet-cases. SQL048–051/plan013 y validación local preparados; aplicar/verificar en Android/Supabase y concurrencia real antes de cerrar. [Ficha funcional](funcionalidades/casos-perdidos.md).

## Avance local de HU-06 — 10 de octubre de 2026

HU-06 / RF-06 / issue#6 implementada localmente en feature/found-pet-cases, con [ficha de encontrados](funcionalidades/casos-encontrados.md). Pendientes activación SQL/handler y demo Android/Supabase; el snapshot de GitHub/Projects no se actualiza ni la historia se cierra por esta implementación. Siguiente funcionalidad de S3: HU-07 / RF-13, lista/mapa con filtros y cercanía en servidor.
