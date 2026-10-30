# ADR-035: alternar el origen de la búsqueda dentro del formulario

Estado: aceptada por la corrección solicitada por el usuario. Fecha: 11 de octubre de 2026.

## Problema

Mi mascota/Otra mascota reemplazaba la ruta del editor. Desmontaba su estado, volvía a consultar datos y repetía skeleton/apertura, además de pedir descartar para alternar. El usuario espera seleccionar una opción del mismo formulario.

## Decisión

App compone LostReportScreen con los dos editores independientes y sus ViewModels. La composición permanece en app: no se importa presentación/data entre funcionalidades ni se lleva conocimiento de funcionalidades a core. Cada ViewModel conserva un borrador diferente y sus UUID/campos/fotos/fecha parcial durante la vida de la ruta. Las dos entradas existentes usan esa composición; no cambian backend ni reglas de publicación.

El título, retorno y TwoOptionFilter permanecen montados. EntityScreenShell/CaseScreenShell admiten un encabezado persistente fuera del efecto. Alternar es selección local dentro de la etapa form; no reinicia cover/stagger ni navega/refresca providers. Por corrección explícita del usuario, el cuerpo cambia inmediatamente, sin fade ni transición entre opciones. La entrada inicial y pasos revisión/confirmación conservan cover seguido de stagger. El timeline de formulario admite las12 posiciones de ambos cuerpos, evitando reiniciar su entrada al alternar.

La lista de mascotas se prepara una vez al entrar y se conserva al alternar. Otra mascota necesita sesión, sin catálogo remoto. Skeleton corresponde únicamente a datos inicialmente pendientes, limitado al cuerpo, con selector disponible; no se simula carga por seleccionar. Cambios de identidad mantienen el borrado/guards existentes de los ViewModels. Estado retenido no es borrador offline ni persistencia entre visitas.

Alternar conserva datos sin pedir descarte. Trabajo de fotos/envío o respuesta ambigua impide cambiar de opción. Al salir, se consideran ambos borradores: confirmación si hay datos sin publicar y descarte comunitario mediante su caso de uso; fallo permanece en pantalla y muestra feedback del editor afectado. Los controllers reconstruidos se sincronizan con el estado conservado sin sobrescribir selección durante edición normal.

## Validación y límites

Regresiones comprueban entrada por ambas rutas, misma instancia del selector/ruta, ausencia de skeleton durante el cambio, ninguna consulta repetida, conservación de UUID/campos/fecha parcial y texto ampliado/movimiento reducido. Suite/análisis y límites en ESTADO. No requiere nueva migración o Edge Function; la activación SQL018 del flujo anterior sigue pendiente si aún no fue aplicada. Android autenticado con red/fotos reales pendiente.
