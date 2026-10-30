# ADR-033: coherencia de formularios de reportes

Estado: aceptado por instrucción explícita del usuario. Fecha: 11 de octubre de 2026.

## Motivo

La revisión de efectos de ADR-031 dejó controles extra en hallazgo: coordenadas manuales, lectura del punto, recuperación técnica permanente y enlace de lista dentro del formulario. El usuario exige corregir la inconsistencia con perdido.

## Decisión

Eliminar esos controles del recorrido normal y los controladores/parsing de coordenadas de presentación. La selección queda en mapa, con las mismas instrucciones de privacidad y referencia privada que perdido. CaseLocationFields en core contiene la única composición de cabecera/instrucciones/mapa/referencia, con campos invalidados, shake y stagger por órdenes aportados por el flujo. Callbacks entregan cambios al ViewModel; coordenadas siguen internas, con contratos y validación backend intactos.

Galerías y fecha/hora reutilizan componentes existentes. Unificar etiqueta de fotos y separación de acciones. Conservar la consulta de lista solo ante respuesta ambigua, como perdido. No eliminar custodia/descripción del hallazgo ni exigir mascota propia: las diferencias del dominio se mantienen. Recuperación de foto en las capas existentes conserva su contrato; este incremento elimina su acción permanente en pantalla y no añade una recuperación automática.

## Validación y consecuencias

50 pruebas relevantes aprobadas y flutter analyze sin incidencias. Creación desde Inicio/+ en ambas funcionalidades comprueba bloque compartido, controles técnicos ausentes, coordenadas conservadas internamente por selección en mapa y nombre de acción permanente retirado. Renders normales y pequeños revisados; Android autenticado pendiente. Sin cambios de esquema/SDK/dependencias ni permiso de despliegue.
