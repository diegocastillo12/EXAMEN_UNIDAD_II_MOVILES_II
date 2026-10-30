# ADR-017: cambios de fotos como borrador del editor

Fecha: 9 de octubre de 2026. Estado: aceptada por solicitud explícita del usuario. Amplía ADR-012 y conserva ADR-016 para feedback.

## Problema y comportamiento

Retirar una fotografía confirmada desde Editar ejecutaba el borrado remoto inmediatamente. Salir sin guardar no podía recuperar el archivo. El usuario solicita que selección y retirada se preparen localmente y se envíen únicamente al registrar o guardar cambios.

PetPhotosState conserva fotografías confirmadas, nuevas selecciones con bytes/UUID estable y un conjunto de IDs cuya retirada está pendiente. Solo la galería editable aplica esas retiradas y muestra las selecciones nuevas; la ficha consulta el estado confirmado. Descartar vacía ambos tipos de pendientes sin escribir en Storage ni en la base de datos. Las retiradas pendientes cuentan como cambios para habilitar Guardar y confirmar salida. Quitar una selección nueva solo descarta su borrador.

## Guardado, reintentos y límites

PetEditorViewModel valida el formulario antes de ejecutar casos de uso. Tras confirmar metadatos invoca savePendingChanges en PetPhotosViewModel: retira las fotografías marcadas y luego sube las nuevas. Este orden permite reemplazar una foto cuando las tres plazas están ocupadas, conservando el límite protegido del servidor. No se cambia el contrato SQL ni se requiere un patch adicional.

Cada confirmación remota retira únicamente su pendiente. Fallos mantienen el resto para reintentar con los mismos IDs; remove_pet_photo ya admite retirada repetida. El editor no anuncia éxito hasta completar todas las operaciones. Estado ocupado bloquea interacción y envíos duplicados; generación/cuenta y keepAlive conservan la protección de respuestas tardías. Se invalidan ficha/listado después de retiradas confirmadas y al finalizar guardado.

Confirmar Guardar inicia varias operaciones de metadatos, Storage y fotos, sin una transacción distribuida. Ante un fallo pueden quedar cambios confirmados parcialmente; descartar después de ese intento no deshace operaciones ya confirmadas. Garantizar todo o nada requeriría otro contrato y mecanismo de publicación/limpieza en servidor. Este incremento corrige las escrituras previas a la confirmación del usuario, sin afirmar atomicidad ni persistencia offline del borrador.

## Validación

Pruebas de cancelación con fotos confirmadas, eliminación de selección local, reemplazo con tres plazas, validación y fallo de metadatos antes de tocar fotos, retirada fallida/respuesta perdida y reintento, cambio de cuenta y salida por Atrás/glass en dimensiones normal y pequeña con texto ampliado. Sustitutos locales no acreditan Storage remoto ni galería Android real.
