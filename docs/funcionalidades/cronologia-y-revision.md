# Cronología y revisión de avistamientos

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

**Seguimiento actualizado:** HU-11.1/#38 y HU-11.2/#39 aceptadas explícitamente por el usuario el18/10/2026; ambas y la épica #11 están en Done y cerradas en GitHub, verificado por API. Código integrado en main mediante PR60 y CI aprobado. La aceptación funcional sustituye el pendiente de aceptación de las notas anteriores; no se presenta como inspección remota independiente de cada escenario.

Confirmación operativa18/10: tras aplicar026 y recibir los pasos de validación
Android, el usuario confirma «ok perfecto, ya esta». Incremento funcional
HU-11.1/#38 y HU-11.2/#39 finalizado según su comunicación. Sustituye el pendiente
de confirmación del recorrido de las notas anteriores; no es inspección remota
independiente ni evidencia detallada de cada escenario de concurrencia/aislamiento.
Estado de issues/épica GitHub sin modificar.

Confirmación18/10: el usuario indica haber ejecutado patch026. Se registra como
aplicado según su comunicación, sin inspección remota independiente; sustituye
las menciones de activación026 pendiente. Falta actualizar/reiniciar Flutter y
demostrar el recorrido autenticado en Android con datos reales. No requiere
reaplicar026 ni actualizar Nuxt por este incremento.

HU-11.1 / RF-14 / issue #38 y HU-11.2 / RF-12,14 / issue #39.
Implementación local, historias sin cerrar. [ADR-066](../decisiones/066-cronologia-y-revision-privada.md).

## Qué hace y recorrido

El responsable abre una ficha propia, incluso cerrada, y Ver historial. La
cronología ordena publicación/recuperación registradas y avistamientos web/app
por hora del suceso, del más reciente al más antiguo. Un avistamiento abre su
detalle privado: hora observada/recibida, marca tardía, comentario, punto manual
o GPS/precisión y foto opcional mediante Ver foto. Evidencia y revisión aparecen
separadas. Confirmado no garantiza ubicación actual ni recupera/cierra el caso.

En caso abierto el responsable elige Útil, Dudoso, Rechazado o Confirmado,
escribe un motivo y guarda. Solo entonces cambia la clasificación y se añade
una decisión al historial. Volver refresca la cronología conservando contenido.
El caso cerrado permite consultar evidencia e historial, sin nuevas decisiones.

## Reglas y campos

Sin revisar es el estado inicial. Las cuatro clasificaciones admiten cambiar a
otra distinta mientras el caso siga abierto; no se repite el estado ni vuelve
a Sin revisar. Motivo obligatorio de1–500 caracteres, contador interior. Cada
decisión conserva estado anterior/nuevo, actor responsable y fecha servidor.
Todas las revisiones siguen disponibles por páginas de20; cronología20 por
página, con desempate estable cuando dos sucesos comparten hora.

## Persistencia y permisos

`sighting_reviews` privada y append-only mediante RPC, asociada a
`public_sightings` de HU-10. Acceso autenticado únicamente del propietario del
caso; la autorización también protege foto y cada página. No depende de que un
QR siga vigente. Otro usuario no recibe comentario, punto, foto ni revisiones.
Caso eliminado/mascota con eliminación solicitada pierde acceso. Fuente Supabase
encapsula SDK/sesión; repositorio entrega entidades y fallos seguros.
UUID de orden estable, versión esperada y bloqueos evitan doble revisión y
sobrescritura concurrente. La evidencia no se modifica al clasificar.

## Errores y reintentos

Skeleton inicial; refresh de la misma cuenta conserva datos con shimmer. Toast
superior y shake/invalid para errores/validación; botón mantiene Guardar revisión
durante trabajo real y bloquea duplicados. Respuesta ambigua congela orden,
clasificación y motivo: Guardar revisión reintenta exactamente la misma orden.
Conflicto ofrece Actualizar y revisar, conserva texto y exige leer la nueva
versión antes de volver a guardar. Errores de permiso ocultan datos anteriores.
Cambio de cuenta/error de sesión/disposición descartan respuestas tardías;
misma cuenta puede recuperarse tras un error. Salir con formulario pendiente pide
confirmación. No se guarda un borrador offline ni se promete recuperación tras
muerte del proceso.

## Dependencias, activación y validación pendiente

Requiere025 confirmado por el usuario y aplicar
[patch026](../../database/patchs/026_patch_case_timeline.sql), o su
[migración](../../supabase/migrations/20261018002600_case_timeline.sql), y actualizar
Flutter. No hay cambios de servidor Nuxt ni panel autenticado web. Los avisos
públicos previos de found_cases continúan en Avisos de esta búsqueda; no se
convierten ni reclasifican automáticamente en esta cronología privada.

Resultados y capturas locales en [ESTADO](../ESTADO.md). Pendiente demo Android/
Supabase real con avistamientos web y app, foto/punto privados, usuario ajeno,
dos sesiones revisando a la vez, cierre y reintento de una respuesta perdida.
Pruebas PGlite/fakes/renders no acreditan servicios reales. Sin APK nuevo,
SQL remoto, publicación o cambios de GitHub desde este incremento.
