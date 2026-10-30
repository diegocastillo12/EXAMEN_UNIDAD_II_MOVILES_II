# ADR-110: búsqueda parcial y tiempo de respuesta del proveedor

Fecha:20/10/2026. Estado: aceptada por corrección explícita del usuario.

## Evidencia

Ante errores repetidos con Tacna/Lima, se probó el cliente Dart y la fuente
reales: con el presupuesto12s ambas consultas vencían antes de recibir datos.
La comparación de GET anterior y AbortableRequest obtuvo los mismos1705 bytes,
HTTP200, en13,95s y13,88s respectivamente. No se atribuye el fallo a la señal de
cancelación ni a la pausa de escritura. Una consulta sin PE también tardó15,87s.

La fuente real devolvió cinco sugerencias PE para `tacn` en13,42s y para `tacna`
en14,37s. El servicio acepta el nombre incompleto: no hace falta exigir el nombre
exacto, añadir comodines ni inventar resultados. El timeout impedía recibirlos.

## Decisión

Por instrucción del usuario, restaurar debounce600ms (sustituye300ms de ADR-109).
Mantener cancelación de peticiones obsoletas y descarte de respuestas tardías.
Ampliar el presupuesto HTTP completo de12 a20s: permite respuestas observadas de
13–16s y conserva aborto al vencer el límite. Una cancelación al editar sigue
siendo inmediata; ampliar el presupuesto no crea cola ni reintento automático.

Mantener texto parcial sin exigir igualdad con el nombre de la sugerencia;
mínimo3 caracteres automático y2 por envío explícito. PE continúa como filtro
del proveedor y comprobación del país recibido; Ciudad conserva su modo.
Sin otro proveedor, SQL, permisos, datos simulados ni cambios visuales.

## Validación y límites

Pruebas de respuesta parcial Tacna para `tacn` después15s en ambos modos, aborto
del proveedor sin respuesta a20s y arranque de la búsqueda reciente a600ms sin
esperar la anterior. Regresiones y resultados en ESTADO.

La ampliación corrige el corte prematuro; no acelera al proveedor ni acredita
latencia inferior3s. Pendiente Android/red del usuario. Una migración de proveedor
requiere evaluar cobertura parcial/Perú, disponibilidad y condiciones con datos
reales; esta corrección no realiza esa migración.
