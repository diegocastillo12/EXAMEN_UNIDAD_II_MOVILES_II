# ADR-029: apertura de fichas desde la tarjeta y acciones de recuperación

Estado: aceptada por instrucción del usuario. Fecha: 11 de octubre de 2026.

## Problema

Mascotas abría la ficha con OriginPageTransition desde la tarjeta, mientras los casos perdidos/encontrados usaban NoTransitionPage. Los cuatro recorridos de consulta de casos añadían una acción permanente Volver a consultar sin una necesidad concreta. El usuario exige consistencia al abrir fichas y retirar esa acción de toda la UI.

## Decisión

entityDetailPage, en app/navigation, compone la misma apertura y retorno para mascotas y casos. Con origen de tarjeta usa OriginPageTransition compartido:320ms de entrada y260ms de retorno, duración cero con movimiento reducido. Sin tarjeta (enlace directo/confirmación de guardado) conserva navegación directa; no inventa un origen.

ManagedCaseCollection entrega ID y rectángulo global de la tarjeta. Las pantallas de lista pasan ese origen al router mediante extra; presentation no importa app. Las rutas de mascotas conservan sus extras de guardado/inspección. Datos y capacidades de cada ficha siguen gobernados por su ViewModel y contratos actuales.

Se retira la acción permanente Volver a consultar de ambas listas y fichas. Reintentar aparece cuando hay error inicial o fallo de actualización; no se añade otro botón/icono permanente para sustituir el texto retirado. Las operaciones confirmadas conservan la invalidación de sus consumidores y la consulta al abrir cada ficha.

## Validación

Regresiones de navegación real en ambas funcionalidades: apertura desde el rectángulo observado, retorno durante skeleton, conservación de tarjeta/posición y movimiento reducido. Pruebas existentes de mascotas conservan apertura, cierre, edición, inspección y confirmaciones. Escaneo de arquitectura impide reintroducir el texto retirado en lib. Capturas390×844 y320×350 texto2, evidencia completa en ESTADO. Sin cambios de esquema, permisos o despliegue.
