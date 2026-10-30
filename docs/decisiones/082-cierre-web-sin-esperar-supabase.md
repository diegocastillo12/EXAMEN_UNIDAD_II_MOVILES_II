# ADR-082: cierre de sesión web sin esperar la llamada a Supabase

Fecha:19/10/2026. Autoridad: el usuario detecta demora al cerrar sesión y autoriza
confirmar primero el cierre del navegador y completar la llamada remota sin
bloquear la salida. Trazabilidad HU-01/RF-01,34 y acceso HU-14.3/RF-22,33;
sin nueva historia, permisos o cierre de HU. Complementa ADR-073/078/079/080.

## Problema

Los endpoints de logout borraban cookies y después esperaban el caso de uso
remoto antes de responder. Aunque los headers de borrado ya estaban preparados,
el navegador no los recibía hasta que terminara Supabase o el timeout de5s.
La pantalla limpiaba sus datos al iniciar el cierre, pero la navegación al login
quedaba bloqueada por esa llamada externa.

## Decisión

POST /api/access/logout y /api/moderation/logout eliminan inmediatamente
eh_access en ambos alcances / y /api y eh_moderation en su alcance anterior.
Después componen su caso de uso de logout y registran la promesa con
event.waitUntil de Nitro, con rechazo controlado. Responden {signedOut:true}
sin esperar el resultado remoto. Es confirmación del borrado local de cookies,
no afirmación de revocación remota completada.

Los repositorios/casos de uso conservan sus responsabilidades: liberan su sesión
de petición y delegan en la fuente. La fuente remota conserva scope=local y
timeout5s; no se cambia dominio para fingir que una llamada terminó. Los handlers
son la composición del ciclo de vida HTTP y programan el trabajo de servidor.
No es una promesa suelta del navegador, un worker nuevo ni una cola persistente.
El cliente continúa esperando la confirmación de borrado HTTP antes de navegar;
limpieza visual, invalidación de preparación y aviso entre pestañas siguen
vigentes, sin confiar en borrar una cookie HttpOnly desde JavaScript.

La falta de configuración para el backend tampoco impide eliminar las cookies:
ambos endpoints confirman el cierre local y registran un aviso técnico fijo,
sin tokens/identificadores ni errores externos en la UI. Las comprobaciones de
origen y métodos se ejecutan antes, y solicitudes no autorizadas no borran cookies.

## Consecuencias y límites

La salida depende de la ida/vuelta al servidor web, sin añadir la espera de
Supabase. No se promete latencia cero ante una red lenta o indisponibilidad del
servidor web. Un error de transporte aún no permite confirmar que el navegador
recibió los headers de borrado; la UI conserva su manejo de fallo existente.

El intento remoto sigue sujeto a timeout y a la vida del proceso: waitUntil no
es una garantía de entrega duradera ante caída/reinicio. No se afirma revocación
inmediata de JWT emitidos, que conservan su vencimiento previo; esta limitación
ya existía. No se cierran sesiones móviles ni se añaden refresh tokens.
Sin cambios SQL, Flutter, secretos, variables o despliegue.

## Validación

El fixture permite retener el logout remoto sin resolverlo. Pruebas de producción
exigen recibir200 y borrado de las tres cookies mientras ese trabajo sigue
pendiente, tanto para access como moderation. Cubren también configuración
ausente y rechazo cross-origin sin headers de borrado. Chrome retiene Supabase
y exige llegar al login desde cuenta y moderación con cookies/datos retirados
antes de liberar la respuesta externa. Evidencia y pendientes en ESTADO.
