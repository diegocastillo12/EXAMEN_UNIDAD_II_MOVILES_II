# Registro, edición y ciclo de vida de mascotas

Alineación20/10/2026: CollectionHeader ancla el título al borde superior de
la fila, conservando mínimo56 y espacio de acciones. Explorar y Mis mascotas
comparten la posición inicial de «Su regreso»; se elimina el desplazamiento8
por centrado vertical. Regresión de navegación con fuentes reales en390×844
y320×350/texto2 aprobada. Sin cambio de tipografía, datos o permisos.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

Título de sección20/10/2026: «Mis mascotas» pasa a peso400 y gris #454746,
como «Su regreso», conservando sans-serif del sistema y tamaño32. Estilo
compartido con Explorar; sustituye el peso500 indicado el19/10 para este título.
Sin cambios de datos/permisos; revisión visual Android pendiente.

Corrección20/10/2026: Especie y Sexo (opcional) reutilizan AppSelectField con
una sola entrada: apertura del panel y después stagger, sin cortina interior
azul/blanca. Se conserva cabecera, selección, desconocido, cancelación, scroll,
texto ampliado y movimiento reducido.20 pruebas de selector/arquitectura/
consistencia aprobadas; cuatro regresiones nuevas de tiempos y ambas etiquetas.
Sin cambios de dominio/datos; revisión visual Android pendiente. Véase [ESTADO](../ESTADO.md).

19/10/2026: título Mis mascotas en peso500 mediante CollectionHeader compartido,
por petición del usuario para igualar el peso de Inicio web. Tamaño32 y
composición existentes conservados. Revisión visual Android pendiente.

**Seguimiento18/10:** HU-03/#3 y HU-03.1/#28, HU-03.2/#29 en Done y cerradas
en GitHub tras corregir la clasificación cuestionada por el usuario. Registro,
consulta y edición con fotos implementados e integrados; las notas históricas de
fotos/patch no describen trabajo faltante actual. Sin pruebas nuevas por este ajuste.

Estado vacío compartido18/10/2026: el layout existente se extrae a
core/presentation/widgets/collection_empty_state.dart para reutilizarlo en
Explorar. Mascotas aporta textos Activas/Archivadas y Registrar mascota solo
en Activas; icono, tipografías, espaciados y ancho máximo del botón se conservan.
No importa presentación de otras funcionalidades ni cambia datos/permisos.

Consistencia de cabeceras18/10/2026: CollectionHeader fija altura mínima56
para sus filas, alineando el origen de Mis mascotas y Explorar aunque sus
acciones tengan distinto tamaño. Mantiene la reserva del+ durante carga/vacío
y la adaptación de texto ampliado. Regresión integrada comprueba ambas
secciones con fuentes reales; sin cambios de persistencia o permisos.

Corrección18/10/2026: la cabecera reserva desde la carga el espacio del botón+
compacto, también cuando la lista queda vacía. Así el título y los filtros
conservan posición/ancho al recibir mascotas o desaparecer la última; se
mantiene la adaptación compartida a ancho pequeño y texto ampliado. El espacio
vacío no contiene una acción ni un botón accesible. Sin cambios de datos o
permisos. Regresión de carga→lista→vacío en390×844 y320×350/texto2 aprobada;
revisión Android pendiente.

Corrección de recarga (16 octubre): se reprodujo pérdida de estado al activar/desactivar el shimmer compartido, porque alternaba la estructura que envuelve las tarjetas. LoadingShimmer mantiene ahora estable el árbol y solo cambia pintura/semántica/bloqueo cuando corresponde. Una prueba del gesto real confirma una sola consulta adicional, bloqueo de otro gesto durante trabajo y la misma instancia de tarjeta antes/durante/después, sin skeleton de recarga. No se encontró duplicación de consultas en esa prueba; revisión en dispositivo pendiente. Sin cambios de repositorios, permisos ni SQL.

Recarga por gesto (ajuste16 de octubre): indicador reutiliza GlassSurface52/radio26/icono28 igual al retorno. Conserva selección de lista, giro, retirada y movimiento reducido. Formato/análisis sin incidencias; sin pruebas/renders por instrucción vigente, revisión Android pendiente.

Refinamiento del gesto: icono de recarga sigue el jalón, gira durante actualización real y retorna al terminar/cancelar, con movimiento reducido respetado. Conserva lista Activas/Archivadas y shimmer. [ADR-049](../decisiones/049-indicador-recarga-y-retorno.md). Análisis estático sin incidencias; sin nuevas pruebas por instrucción del usuario, pendiente revisión Android.

Actualización del15 de octubre: jalar desde el inicio de Mis mascotas y soltar refresca la lista seleccionada (Activas/Archivadas), incluso vacía/corta; conserva contenido con shimmer y espera su consulta real. No duplica operación durante carga/eliminación y mantiene acciones de reintento. [ADR-048](../decisiones/048-actualizar-listas-al-jalar.md). Formato/análisis sin incidencias; sin pruebas ejecutadas por instrucción del usuario, revisión Android pendiente.

Módulo: `pets`. HU-03 / RF-03; issues
[#28](../backlog/028-HU-03.1.md) y [#29](../backlog/029-HU-03.2.md).

## Qué hace y cómo se usa

Mis mascotas separa Activas y Archivadas. Permite registrar una mascota,
consultar su ficha, editar metadatos y [gestionar sus fotos](fotos-mascotas.md).
La ficha permite archivar/restaurar; el listado ofrece eliminación por swipe
con confirmación. Archivar conserva ficha y fotos, y restaurar devuelve la
mascota a Activas. Registrar una mascota aún no publica un caso perdido.

## Campos y reglas

| Campo | Regla al guardar |
| --- | --- |
| Nombre | Obligatorio,1–80 puntos de código Unicode |
| Especie | Perro, gato u otra; Otra requiere tipo concreto de1–60 |
| Tamaño | Pequeño, mediano o grande; obligatorio |
| Edad | Obligatoria; almacenamiento en meses,0–600 |
| Rasgos | Obligatorios,1–200; contador dentro del campo |
| Sexo | Opcional; Macho como selección inicial del editor |

La validación se aplica antes de escribir y también en SQL. Las fichas antiguas
incompletas no reciben datos inventados: al editar metadatos deben completarse;
se mantienen sus operaciones de ciclo de vida autorizadas.

Cada borrador tiene UUID estable para reintentar creación sin duplicar mascota.
Edición usa versión esperada para detectar cambios concurrentes. Un error conserva
el borrador; éxito solo tras confirmar el guardado. No hay cola offline persistente
ni promesa de transacción única entre metadatos y archivos.

## Privacidad, archivo y eliminación

La ficha y sus fotos pertenecen a la cuenta, con restricciones de servidor.
Archivar se rechaza cuando hay casos activos. Eliminar se rechaza si existe
historial o casos activos; el flujo marca baja, limpia archivos y verifica
la limpieza antes de finalizar. Un fallo no se presenta como eliminación exitosa.
S3 deberá actualizar los indicadores de casos en la misma transacción.

En Registrar/Editar, validación, guardado y fotos usan shake danger y toast
superior sin mensajes debajo; eliminación sigue ADR-013. Los demás recorridos
conservan sus reglas de feedback.

## Dependencias y validación

CreatePet, UpdatePet, ListMyPets, ReadPet, ArchivePet, RestorePet y DeletePet.
RPC versionadas, RLS y Storage; [configuración](../CONFIGURACION.md).
Verificar creación/edición, cancelación, reintento, conflictos, archivo/restauración,
eliminación fallida y aislamiento A/B. Evidencia y pendientes en [ESTADO](../ESTADO.md).

## Integración con HU-05

La publicación local de un caso perdido actualiza historial permanente, contador activo y versión de mascota en la misma transacción. Con caso activo no puede archivarse; con historial no puede eliminarse definitivamente. Patch013/activación y demo real pendientes. El reporte vuelve a consultar ficha/fotos para usar la versión vigente; ver [Casos perdidos](casos-perdidos.md).


## Reutilización visual — 10 de octubre de 2026

Confirmaciones delegadas al diálogo completo confirmActionDialog de core, con acciones de geometría/alineación y adaptación compartidas, sin layouts propios. En reportes, terminar carga conserva la entrada del skeleton y no dispara cover/stagger nuevos; vista previa y confirmación conservan su transición. Validación local y límites en ESTADO; no cambia persistencia/permisos ni cierra la historia remota.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Corrección de consistencia — 11 de octubre de 2026

Errores de carga y ciclo de vida usan toast con reintento. Las listas activas/archivadas y detalle observados se actualizan por notificación de dominio al confirmar un cambio de reporte perdido; fallos no notifican.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.

## Apertura y acciones de consulta — 11 de octubre

La ficha usa la apertura/retorno compartidos desde la tarjeta real (ADR-029), con movimiento reducido y navegación directa sin origen cuando corresponde. Los casos no presentan una acción permanente de volver a consultar; Reintentar aparece únicamente ante un fallo real. Se preservan guardado/inspección de mascotas, borrado/estados de casos, sus permisos y la invalidación tras operaciones confirmadas. Evidencia y límites en ESTADO.


## Casos con la referencia aprobada de Mascotas — 11 de octubre de 2026

Por instrucción del usuario, la UI de Mascotas se conserva y se reutiliza en Casos. EntityScreenShell y entityEditorPage extraen su contenedor/apertura existentes: mismos márgenes, navegación glass y cover→stagger, fuente visual del botón y retorno. Registrar perdido/encontrado desde Reportar o+ usa esa misma transición; todos los campos, fotos, instrucciones y acciones participan del timeline existente, sin reiniciarlo por edición/teclado/selección. PhotoAddTile y SizeChoiceSelector comparten las implementaciones aprobadas; Encontrados conserva tamaño/sexo/custodia opcionales y los contratos del reporte. Listados usan cabecera/grupo de contenido con entrada compartida, sin count por registro. No se altera el panel de ficha inmersiva solicitado en ADR-030. Véase [ADR-031](../decisiones/031-casos-reutilizan-ui-mascotas.md).

Validación local: suite completa309 pruebas aprobadas;8 regresiones nuevas repetidas tras reforzar el descarte en tamaños390×844/320×350 texto2 y movimiento reducido. Renders revisados en build/ui-preview/case-creation. Pendiente revisar Android autenticado con fotos/teselas reales; la aprobación visual no cierra historias ni confirma backend remoto.
