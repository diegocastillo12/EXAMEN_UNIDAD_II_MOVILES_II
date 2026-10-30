# Coincidencias entre casos de mascotas

## Corrección del runtime de imágenes Linux —25/10/2026

El log alojado aportado por el usuario acredita500 en
`/api/app/matching/searches`: `sharp` no encuentra `libvips-cpp.so.8.18.7`.
Reproducido en Ubuntu x64: la disposición versionada de Nitro altera las rutas
relativas ELF de las dependencias nativas. El hook de compilación conserva los
paquetes nativos completos como hermanos dentro de cada versión de `sharp`,
incluida la versión transitiva de Transformers, sin cambiar versiones/modelo.
Las dependencias opcionales se incluyen explícitamente en Docker; una prueba
de decodificación JPEG/redimensionado de ambas versiones bloquea la construcción
si falla el runtime final. CI también comprueba el paquete generado.

`sharp` y Transformers se importan al procesar fotos, dentro del manejo de
errores del encoder. Listar búsquedas, autenticar y revisar resultados ya
indexados no requieren cargar el motor. Una dependencia nativa indisponible al
comparar devuelve503 seguro/reintentable, en lugar de500 durante la apertura.
Regresión con carga nativa bloqueada y prueba del modelo real en Linux aprobadas;
validaciones completas en [ESTADO](../ESTADO.md). Reconstrucción/despliegue y
confirmación en el servidor alojado pendientes; no requiere reaplicar040 ni
acredita precisión de identificación.

25/10: usuario confirma patch040 ejecutado en Supabase. Sin reaplicación ni
verificación remota independiente por esta confirmación. Modelo configurado
para desarrollo local; demo con dos cuentas/evaluación/integración pendientes.
Las menciones inferiores a aplicación040 pendiente son historial anterior.

## Implementación local —25/10/2026

**HU-25/#71 y HU-26/#72 en `feature/case-matching`, sin activación remota,
dataset evaluado ni cierre de historias.** [ADR-138](../decisiones/138-motor-visual-local-y-hallazgos-independientes.md)
concreta modelo, candidatos, persistencia y límites de ADR-137.

### Recorrido y reglas actuales

Android: Inicio → Buscar coincidencias → elegir búsqueda propia/comunitaria
activa → Buscar coincidencias → hasta cinco sugerencias → Ver ficha → Coincide
o Descartar. Web: Inicio → `/coincidencias`, con el mismo contrato; ficha en
`/casos/encontrados/:id` o `/casos/perdidos/:id`. Revisión humana persistida,
sin asignar dueño, vincular automáticamente publicaciones ni confirmar recuperación.

El usuario aprueba expresamente el hallazgo independiente: Android desde Inicio
y web desde Reportar → «Encontré una mascota y no sé de quién es». Exige1–3
fotos procesadas, especie/tipo si Otra, rasgos hasta200, fecha/hora y ubicación/
referencia. Tamaño/sexo/custodia opcionales, sin datos inventados. Los avisos
vinculados permanecen y los registros antiguos no se reclasifican.
El nuevo tipo conserva cartel/QR, compartir, seguimiento, avistamientos y
cronología mediante los adaptadores y permisos existentes; el lector no obtiene
facultades de autor.

Fuente: búsqueda activa/visible del responsable, propia o comunitaria.
Candidatos: hallazgos `independent_found` y anteriores `legacy_found` activos de
la misma especie, excluyendo bloqueos/retirados/ocultos/cerrados. No se presenta
un aviso ya ligado a una búsqueda como descubrimiento. La interfaz dice «Posible
coincidencia», nunca porcentaje de identidad. Comparación explícita, sin push.

### Persistencia, permisos y reintentos

Plan040/fuentes128–134: índices por foto/hash/revisión/modelo y revisiones
append-only con UUID estable. Tablas sin grants directos; RPC de matching solo
servidor. Identidad verificada en Auth/cookie antes de derivar el actor y
responsable/visibilidad/bloqueos revalidados en SQL. Vectores, rutas Storage y
UUID de propietarios no llegan al cliente. Cierre/retirada/moderación/cambios
de foto invalidan índices; lecturas y escrituras rechazan snapshots obsoletos.
Repetir una orden anterior no revierte una decisión posterior.

CLIP local q8,512 componentes, revisión y hashes fijados. Sin enviar fotos a
proveedores externos. Seis fotos nuevas por petición; los índices se reutilizan.
«Continuar comparación» distingue un resultado incompleto. Piloto de hasta100
candidatos elegibles: error si se excede, sin truncado silencioso. Ranking
visual/geografía/tiempo exploratorio, sin umbral calibrado.

Toast superior, skeleton inicial y shimmer compartido en trabajo real; mismo
contenido durante refresh de la misma cuenta. Vacío, incompleto y error son
distintos. Revocación/cambio de identidad descarta estado y respuestas tardías.
Fallo del motor no bloquea publicaciones, QR ni avistamientos. UUID de revisión
ambigua conservado al reintentar. Cupo de comparación separado del envío de reportes.

### Activación y evaluación

1. Revisar/aplicar **todo** [patch040](../../database/patchs/040_patch_case_matching.sql)
   en desarrollo después de039, sin reaplicar el acumulativo. Generadores:
   `Build-CaseMatchingPatch.ps1` y `Build-RunAll.ps1`.
2. Nuxt local: `npm run model:prepare`; configurar el directorio absoluto mostrado
   en `MATCH_MODEL_DIRECTORY`, solo servidor. `npm run model:smoke` comprueba el
   encoder y `node scripts/check-matching-model-server.mjs` el servidor construido
   con modelo real/backend de prueba. Docker empaqueta pesos fijados de unos89MB,
   Node24/bookworm-slim CPU y omite CUDA. No descarga durante peticiones.
3. Actualizar web y Android juntos. Android usa `PUBLIC_CASE_WEB_URL` existente;
   no incorpora el modelo al APK. Sin worker, cron, inferencia externa ni FCM.
4. Demo con dos cuentas/datos autorizados: publicar hallazgo, comparar, revisar,
   retirar/bloquear/cerrar y reintentar. Sin SQL/despliegue remoto desde este chat.

`npm run model:evaluate -- ruta/manifiesto.json` requiere un manifiesto local con
`provenance`, `license`, `entries`; cada entrada incluye `authorized:true`,
`identity`, `split` (`development`/`test`), `role` (`query`/`gallery`), `species`,
`file`, `occurredAt`, `latitude` y `longitude` aproximadas. Imágenes locales sin
duplicados y sin identidades compartidas entre desarrollo/prueba. Informa
Recall@5, errores top1, negativos con sugerencias y latencia; marca si alcanza50
identidades de prueba. No inventa un dataset ni acredita precisión por un smoke.

Evidencia local y resultados en [ESTADO](../ESTADO.md). Pendientes:040/demo alojada,
dataset autorizado/evaluación, aceptación, Android físico, contenedor Linux
(Docker Engine local no disponible), CI remota e integración. Fixtures y renders
no equivalen a servicio alojado ni identificación fiable de mascotas reales.

## Plan inicial —historial anterior a la implementación

25/10/2026: **incluido expresamente en el MVP**, sin implementar. HU-25/HU-26,
RF-19/RF-20 originales del Plan Maestro v2. [ADR-137](../decisiones/137-coincidencias-visuales-en-el-mvp.md).
No confundir números de HU con los issues #25/#26 de cuenta/zonas.

## Qué hace y recorrido previsto

Desde un caso autorizado, consultar hasta cinco publicaciones posiblemente
coincidentes, abrir sus fichas y confirmar/descartar la sugerencia. Comparación
de fotografías combinada con especie, zona y tiempo; explicación de señales
disponibles. Revisión humana, sin atribuir identidad cierta o propiedad y sin
confirmar recuperación automáticamente. No es una capacidad activa hoy.

## Reglas y campos

HU-25: fotos autorizadas, representación visual versionada, estado de proceso
y reintentos. HU-26: par de casos, versión del ranking, señales explicativas
y revisión autorizada persistida. El esquema final aún no está decidido.
Agrupar fotos por caso; no presentar el score como certeza porcentual.
No inventar raza/sexo ni descartar solo por raza inferida o sexo desconocido.

## Persistencia y permisos

Contrato y migración pendientes; servidor autoriza lectura y revisión según
cuenta, visibilidad y estado vigente. No exponer coordenadas exactas, originales
privados, contactos no autorizados ni derivados visuales con permisos más amplios.
Cambios de fotos, retirada/cierre/ocultamiento y bloqueo invalidan candidatos.
Una revisión no modifica propietario ni sustituye el cierre explícito existente.

## Errores y reintentos

Publicación disponible aunque falle el modelo. Proceso reintentable e idempotente;
resultado vacío distinguido de procesamiento pendiente y error. Toast superior,
skeleton/shimmer y lifecycle compartidos al implementar. Sin resurrección de
datos por respuestas tardías ni conservación entre identidades distintas.

## Dependencias y activación

Fotos seguras, publicaciones, ficha y permisos actuales. Definir candidatos
reales con búsquedas comunitarias y avisos vinculados: un aviso ya asociado no
es un hallazgo independiente. Si se necesitan hallazgos independientes, acordar
su contrato sin reclasificar publicaciones previas. Modelo/licencia, ejecución,
coste, almacenamiento, umbrales y recorrido móvil/web pendientes de refinamiento.
Sin activación de Firebase, servicios externos o workers por esta planificación.

## Validación pendiente

Todas las pruebas de esta capacidad están pendientes. Evaluación con datos
autorizados e identidades de mascotas separadas, distractores, Recall@5, falsos
positivos y latencia; no basta repetir la misma fotografía. Pruebas de permisos,
reintentos, cierre/retirada, aislamiento y demo aceptada. No se promete precisión
ni se activan avisos automáticos de identidad sin evidencia y decisión explícita.
