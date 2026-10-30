# ADR-109: priorizar la última búsqueda de ubicación

Fecha:20/10/2026. Estado: aceptada por instrucción del usuario.

Corrección posterior: [ADR-110](110-buscador-parcial-y-tiempo-de-respuesta.md)
restaura600ms por instrucción del usuario y amplía timeout HTTP a20s tras
reproducir respuestas válidas después de12s. Cancelación y descarte se conservan.

## Motivo

El usuario observa6–9 segundos para seleccionar sugerencias. La implementación
esperaba600ms y serializaba la última consulta detrás de la petición anterior.
Eso acumulaba espera al seguir escribiendo. Las mediciones del entorno también
mostraron latencia del proveedor: Chiclayo con/sin PE tardó5,6–8s en tres pares;
una consulta posterior PE tuvo primer byte a9,75s y cero redirecciones. No se
atribuye esa latencia al filtro ni se promete respuesta inferior a3s.

## Decisión

Debounce300ms, conservando mínimo3 caracteres para sugerencias automáticas y
envío explícito por teclado. Editar cancela inmediatamente la consulta anterior;
tras la pausa se inicia la última sin esperar la finalización anterior. Peticiones
idénticas activas se deduplican. Resultados/errores antiguos nunca pisan el estado
actual, incluso si el transporte termina tarde. Selección, cierre del buscador,
cambio de cuenta y disposición cancelan trabajo y temporizadores pendientes.

PlaceSearchCancellation es un contrato concreto de dominio sin Flutter/SDK.
SearchPlaces/repositorio/fuente lo reciben por operación; no hay cancelación
global que afecte otros campos. Data traduce la señal a http.AbortableRequest,
reutiliza el cliente inyectado y aborta también al vencer el timeout12s. Ninguna
respuesta cancelada entra en caché; búsquedas completadas conservan30 entradas,
5min y separación de modos. Se conserva PE en servidor y verificación local.

## Consecuencias y validación

Presentación controla foco/estado, dominio expresa cancelación, infraestructura
resuelve el aborto HTTP. Sin nuevo proveedor, SQL, credenciales o dependencias.
Sin modificar mapa, overlay, permisos o alcance de historias.

Pruebas deterministas: la petición reciente arranca a300ms con la anterior aún
pendiente, cancelación inmediata, error tardío ignorado en ambos modos, señal
HTTP efectiva, caché tras cancelación, limpieza/desmontaje. Regresiones de places,
overlay, Explorar, Perfil, Reportar y arquitectura; resultados en ESTADO.
Pendiente Android y latencia del servicio real. El incremento elimina esperas
evitables del cliente; el tiempo de respuesta del proveedor sigue siendo variable.
