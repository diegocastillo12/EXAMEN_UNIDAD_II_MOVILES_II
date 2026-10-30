# ADR-080: preparar el destino de acceso antes del clic

Fecha:19/10/2026. Autoridad: el usuario considera insuficiente el feedback de
espera en landing y autoriza preparar el destino previamente y reutilizar la
comprobación durante el salto. HU-01/RF-01,34; sin ampliar MVP ni cerrar historias.
Complementa ADR-079 y sustituye su ausencia de reutilización cliente de sesión.

## Decisión

Landing consulta mediante AccountViewModel/AccessAccount al montar, sin bloquear
la página ni consultar datos privados desde SSR. El enlace inicialmente válido
/iniciar-sesion cambia a /inicio o /bienvenida según la sesión confirmada. El
router precarga los componentes de ese destino. Un fallo conserva el acceso
normal y su reintento; sin JavaScript permanece la redirección de servidor.

AccountSessionTransport, en data de access, comparte el resultado de GET
/api/access/session entre repositorios de la misma aplicación del navegador:
preparación, middleware global y pantalla de llegada no repiten la misma lectura.
El transporte compone respuestas independientes para cada consumidor y agrupa
lecturas concurrentes. Cada repositorio conserva su actor para ligar operaciones.
No se comparten ViewModels ni estado mutable de pantallas.

Reutilización máxima15s y nunca más allá de expiresAt. Ausencia confirmada401
se reutiliza máximo5s; fallos de servidor/red no se conservan. La landing visible
vuelve a consultar cada10s y al recuperar foco/visibilidad; oculta no hace polling.
Todo timer/listener/subscripción de pantalla se libera al salir. La precarga de
componentes es oportunista: fallar no bloquea navegar.

Bootstrap crea el transporte por aplicación, sin variable global de módulo,
localStorage, cookie nueva ni payload SSR. Las instancias SSR están aisladas
por petición y no consultan sesión desde landing. En navegador se invalida por
foco/visibilidad, mensajes eh-access, antes y después de login/logout/onboarding/
OAuth y ante401/409 de operaciones. Moderación recibe el mismo transporte desde
bootstrap para que su logout también invalide, sin imports entre features.
Al desmontar la app se cierra el canal y se retiran listeners/estado.

Una invalidación durante una lectura descarta la respuesta anterior con409;
el middleware global permite una nueva comprobación de identidad, una sola vez,
para resolver carreras de broadcasts sin navegar usando datos descartados.
No se cachean consultas de permisos de gestión ni operaciones de producto:
servidor/RLS y permisos por petición permanecen como autoridad.

## Experiencia y límites

Con la sesión preparada el clic apunta directamente al destino y no espera otra
API de sesión. Si se pulsa antes de preparar, la comprobación caducó, cambia la
cuenta o hay fallo de red, puede existir espera real; NavigationLink conserva
su feedback y la política global evita mostrar login o cuentas incorrectas.
No se promete latencia cero ni se eliminan tiempos de carga de datos de producto.

La proyección propia de cuenta vive brevemente en memoria del cliente que ya
podía consultarla; se conserva la separación de datos públicos/privados en SSR.
Una revocación sin evento local puede tardar hasta15s en reflejarse en el enlace,
pero las operaciones siempre autorizan en servidor y las de moderación vuelven
a comprobar permiso. Sin cambios SQL, Flutter, configuración remota o despliegue.

## Validación

Pruebas de transporte verifican deduplicación, TTL/vencimiento, errores,401,
invalidation, aislamiento por app y ausencia de caché de permisos. Chrome retiene
la preparación para probar clic temprano y verifica que preparación/guard/pantalla
comparten una consulta; luego bloquea cualquier nueva API de sesión al pulsar un
enlace preparado y exige llegada al destino correcto. Regresiones de acceso,
caducidad/pestañas/logout, política global, landing y moderación en ESTADO.
