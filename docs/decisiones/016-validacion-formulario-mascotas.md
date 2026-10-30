# ADR-016: campos obligatorios y feedback del editor de mascotas

Estado: aceptada por instrucción explícita del usuario. Fecha: 9 de octubre de 2026, America/Lima.

## Contexto

El usuario solicita pulir Registrar mascota: ampliar el selector de fotos como en la ficha, exigir tamaño/edad/rasgos además de nombre/especie, limitar rasgos a200 caracteres con contador y mostrar validaciones mediante shake danger y toast superior, sin textos de error bajo los campos. Esta instrucción sustituye los opcionales de ADR-010/012 y amplía el feedback autorizado de ADR-005/007/009/013 únicamente en el editor de mascotas.

## Decisión

- Registrar y Editar comparten reglas de guardado: nombre1–80, especie válida, tipo1–60 si Otra, tamaño obligatorio, edad entera0–600 meses y rasgos/descripcion1–200 después de trim. Sexo sigue siendo opcional; el borrador nuevo comienza en Macho y permite No lo sé (null). El valor por defecto no cuenta como edición; fichas existentes conservan su sexo original, incluido null.
- AppSelectField muestra Seleccionar como placeholder cuando no tiene valor. No incorpora ese placeholder como opción seleccionable; cancelar conserva el estado. Especie comienza sin selección.
- PetPhotoGallery del editor usa cuadrados de hasta160, igual que la ficha, con scroll horizontal, radio22 y selección/retirada/reintentos existentes. Fotos siguen opcionales; máximo tres. Skeleton acompaña tamaño.
- Dominio reúne todos los campos inválidos y valida de nuevo en CreatePet/UpdatePet. ViewModel convierte texto de edad y evita llamadas al repositorio ante validación; errorId identifica intentos nuevos. Editar limpia solo la marca del campo editado y conserva el borrador.
- Cada campo inválido usa ShakeField y borde/texto/icono danger del login, manteniendo superficie neutra. Sin errorText visible debajo, filas de error ni indicadores adicionales. ConfirmationToastHost superior explica validación/fallos de guardado y fotos del editor; conflicto ofrece Ver ficha actual y conserva borrador. Errores de la galería de consulta en la ficha mantienen su feedback contextual anterior. Esta autorización no cambia el feedback de otras funcionalidades.
- AppFieldSurface/AppTextField/AppSelectField permiten invalid sin errorText. El contador va dentro del marco de rasgos y empieza0/200. Formateador, dominio y PostgreSQL cuentan puntos de código Unicode, evitando partir pares UTF-16; composición IME activa no se trunca hasta confirmarse. Valores antiguos de más de200 se conservan al leer; deben corregirse al guardar.
- ConfirmationToastHost muestra también un error ya presente al montarse, con el mismo overlay/timer, dismiss y limpieza al desmontar. PetPhotosState añade errorId para repetir avisos de fallos iguales. Movimiento reducido evita shake/expansión y mantiene información accesible.

## Servidor y transición de datos existentes

Plan009 genera migración20261009000900_pet_required_fields.sql y patch009 desde fuentes034–035, sin reescribir SQL aplicado. Trigger before insert/update de columnas de metadatos impone las nuevas reglas además de RPC/RLS/grants existentes. No modifica datos ni inventa edad/tamaño/rasgos. Las fichas antiguas incompletas siguen consultándose; editar metadatos requiere completarlas. Archive/restore/delete actualizan columnas de ciclo de vida y no activan esta validación. Se conserva autorización, bloqueo de fila, ID estable/versionado y reintentos.

Se eligió el trigger sobre columnas concretas frente a constraints globales NOT VALID: esas constraints también impedirían actualizar el ciclo de vida de fichas antiguas incompletas. El trigger no concede escrituras directas a cliente. Build-RunAll incorpora el guard al final y su repetición conserva datos existentes.

## Validación y límites

Pruebas Flutter cubren campos ausentes/inválidos, todos los errores juntos, contador/pegado Unicode/IME, placeholder, sexo opcional, intentos repetidos, borrador, guardado/reintentos, errores de fotos, movimiento reducido, salida y dependencias. Renders normales y320×350 con texto2 incluyen formulario, foto pendiente, contador y errores. SQL local con PGlite comprueba permisos, límites, reintentos, datos antiguos y reejecución. Las pruebas de incrementos SQL anteriores se ejecutan sobre su contrato anterior; el contrato vigente tiene su prueba propia.

No acredita rendimiento Android ni activación remota en Supabase. Despliegue pendiente de autorización de la tarea correspondiente; estado y próximo paso en ESTADO.
