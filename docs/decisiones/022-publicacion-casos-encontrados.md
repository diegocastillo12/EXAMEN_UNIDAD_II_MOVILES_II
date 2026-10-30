# ADR-022: publicación de mascotas encontradas sin perfil previo

Estado: aceptada para implementación local de HU-06 / RF-06 / issue #6, 10 de octubre de 2026. Activación remota pendiente.

## Contexto

El reporte encontrado debe funcionar aunque la persona no tenga mascotas registradas ni conozca a su dueño. HU-05 depende de una mascota propia; reutilizar su tabla o registrar una mascota ficticia introduciría propiedad incorrecta. Las fotos deben conservar el procesamiento seguro de ADR-020 y la separación pública/privada de ADR-021.

## Decisión

- `found_cases` guarda el reportero en `owner_id`; no representa al dueño de la mascota. `pet_id` permanece nulo y una restricción impide asociarlo en este incremento. No hay asociación visual automática, adopción, entrega ni asignación de dueño.
- El dominio `found_cases` tiene contratos y casos de uso propios. Presentation usa sus ViewModels y providers declarativos; bootstrap inyecta data. Selector/normalización de fotos y shell visual compartidos pasan a core, con compatibilidad de los imports existentes de mascotas y perdidos.
- El formulario mantiene fotos y metadatos en memoria hasta enviar. Vista previa explícita de campos públicos y bytes normalizados, antes de cualquier exposición. `prepare_found_case` reserva UUID de reporte y selección de 1–3 fotos; el SDK orquesta procesamiento y publicación detrás del repositorio. El cliente no declara fotos verificadas.
- Se amplía el endpoint existente `pet-photo-process` con `x-found-case-id`, incompatible con `x-pet-id`. Auth valida sesión y acceso del reportero antes de leer/decodificar bytes. RPC de preparación/confirmación de fotos son exclusivas de servicio; fijan UUID/hash, autorizan selección y comprueban ambos objetos. Reutiliza el mismo procesador real que orienta, decodifica, elimina EXIF/GPS y genera JPEG limitado. Solo se almacenan derivados sanitizados, en dos buckets privados separados: `found-photo-renditions` y `found-photo-thumbnails`.
- `publish_found_case` bloquea reporte y valida selección, atestación de fotos, campos, fecha/punto y actor. Repetición idéntica devuelve el mismo caso; solicitud distinta tras publicar produce conflicto. Publicación y evento se confirman en una transacción. La creación de draft/cuota se serializa por reportero con advisory lock. No existe restricción de un encontrado por mascota, porque no conocemos su identidad.
- Proyección pública por `read_public_found_case`: especie/tipo, tamaño/sexo opcionales, rasgos, fecha, custodia opcional, centro de celda de 0.01 grados y fotos verificadas seleccionadas de un caso activo. No contiene perfil del reportero, referencia privada ni coordenadas exactas. RLS y grants limitan fuente/columnas, y guards de Storage impiden escrituras cliente y lectura de pendientes incluso con políticas permisivas adicionales. El dueño del envío puede leer los archivos necesarios para borrarlos. URLs firmadas duran 300 s; la revocación no recupera copias ni invalida inmediatamente firmas vigentes.
- Respuesta ambigua conserva exactamente UUID, metadatos y bytes. Impide cambiar el envío hasta reintentar o confirmar su descarte. Rechazos conocidos de validación/fotos permiten corregir; al preparar la selección siguiente, fotos retiradas quedan inaccesibles para terceros y el adaptador elimina sus bytes. Tombstones de fotos impiden reutilizar ID con contenido distinto.
- Descarte de draft: RPC marca fotos retiradas, cliente borra ambos buckets, RPC verifica ausencia y conserva tombstones privados de reporte/fotos con estado discarded. Impiden resucitar el UUID y mantienen autorización para limpiar escrituras tardías del worker. list_my_found_cases oculta descartados limpios y vuelve a mostrarlos como limpieza pendiente si reaparecen bytes; el handler retira bytes parciales si detecta una reserva retirada. No permite descartar un caso publicado. Mis encontrados lista activos/resueltos y drafts para poder limpiar pendientes tras reiniciar; no presenta un draft como publicación ni permite abrirlo como ficha pública. El límite de seguridad es 10 drafts por cuenta y 30 reservas de foto por draft, incluidas retiradas; descartar libera su cuota. No hay limpieza automática ni cola offline en este incremento.

## Consecuencias y validación

Aplicar plan014/patch014 sobre013 y actualizar el handler desplegado, manteniendo privados los buckets. No es necesaria otra Edge Function ni cambio de router self-hosted. El generador de paquete local incluye el handler actualizado y el procesador/WASM existente.

El borrador de metadatos/bytes no sobrevive al cierre del proceso; HU-15 incorpora la cola local. Los drafts remotos sirven para limpieza, no para recuperar campos que todavía no fueron publicados. Fotos/rasgos pueden contener información visible privada; la vista previa advierte revisarla, sin atribuir al borrado EXIF una ocultación de contenido visual.

La ubicación es manual, sin solicitar GPS; mapas/filtros/cercanía siguen HU-07 y PostGIS. La app protege sus rutas por sesión/onboarding; proyección SQL pública es independiente de la futura web. Cierre/reencuentro sigue HU-13, notificaciones HU-12, QR HU-08/09. Cambiar las invariantes de vínculo/cierre requiere otra migración.

Pruebas locales: dominio, ViewModels, SDK HTTP, flujo real de rutas, renders de dos tamaños, RLS/grants A/B/anónimo, repetición, atestación y limpieza. PGlite representa metadata de Storage y comandos seriales; demostrar concurrencia con PostgreSQL independiente, bytes Storage y Android/Supabase desplegado antes de cerrar #6. Resultados en [ESTADO](../ESTADO.md).
