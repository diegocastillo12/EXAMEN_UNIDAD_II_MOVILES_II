# ADR-138: motor visual local y hallazgos independientes

Fecha:25/10/2026, America/Lima. HU-25/#71 y HU-26/#72, RF-19/RF-20.
Implementación local de ADR-137; activación y evaluación del piloto pendientes.
Hallazgo independiente reutiliza HU-06/RF-06 como prerrequisito explícito de
matching, sin renumerar historias ni reabrir por arrastre su entrega anterior.

## Decisión de producto

El usuario aprueba expresamente publicar «Encontré una mascota y no sé de quién
es» sin seleccionar una búsqueda. Se incorpora `independent_found` junto a
`possible_loss`, `sighting`, `with_reporter` y `legacy_found`. No se reclasifican
registros existentes. Hallazgo independiente exige fotos propias procesadas,
especie, rasgos, fecha/hora y ubicación/referencia; no tiene destino ni mascota
identificada. Custodia es opcional, elegida por el reportante; ausencia no se
interpreta como «está conmigo». Datos públicos aproximados y permisos actuales
se conservan. Avisos vinculados mantienen su comportamiento.

Primera entrega: responsable de una búsqueda propia/comunitaria activa y visible
elige su búsqueda y solicita coincidencias. Candidatos son hallazgos independientes
nuevos y encontrados anteriores activos de la misma especie. No se presenta un
aviso ya vinculado como descubrimiento ni se atribuye propietario por similitud.
Se muestran hasta cinco casos, no cinco fotos del mismo caso. El tipo nuevo
reutiliza permisos y proyecciones de cartel/QR, compartir, seguimiento,
avistamientos y cronología (fuente134), sin asignar permisos de autor al lector. Confirmar/descartar
guarda la revisión humana y no cierra, recupera ni asigna propietario.

## Modelo y ejecución

Se usa el encoder visual CLIP ViT-B/32 convertido a ONNX, cuantizado q8, mediante
`@huggingface/transformers`3.8.1 en el servidor Nuxt/Node existente, con CPU.
Modelo `Xenova/clip-vit-base-patch32`, revisión fija
`d15189d7028b43f1d3e65039190477f6af591c2a`; versión local
`clip-vit-b32-d15189d-q8-v1`. Vector normalizado de512 componentes por foto.
Preparación224×224 y salida de `CLIPVisionModelWithProjection`; no detector de
animales, entrenamiento propio ni identificación biométrica individual.

Pesos ONNX89.117.001 bytes; SHA256
`583fd1110a514667812fee7d684952aaf82a99b959760c8d7dca7e0ab9839299`.
Script de preparación y carga verifican también los hashes de configuración.
`MATCH_MODEL_DIRECTORY` es solo servidor. Descarga explícita de pesos públicos
al preparar/construir; ejecución sin descargas remotas y sin enviar fotos a
proveedores de inferencia. Caché global solo de pesos, no cuentas ni imágenes.
Docker pasa a Node24/bookworm-slim para el runtime nativo Linux/glibc y empaqueta
pesos fijados. No requiere GPU; CI omite descarga de CUDA. Contenedor Linux no
comprobado localmente si Docker Engine no está disponible.

No se crea worker, cron, Redis, ASP.NET ni otro servicio. La indexación ocurre
al solicitar la comparación, fuera del envío de publicaciones. Se procesan hasta
seis fotos faltantes por petición, reutilizando índices persistidos; «Continuar
comparación» completa lotes posteriores. Inferencia serializada por proceso.
Piloto acotado a100 candidatos elegibles; si se supera, error reintentable,
sin truncar silenciosamente ni afirmar un ranking exhaustivo.

Ranking exploratorio versionado:85% similitud coseno,10% proximidad suave
`exp(-distancia/50000m)` y5% compatibilidad temporal `exp(-días/90)`.
No filtro duro por distancia/tiempo, raza inferida o sexo desconocido. Pesos no
calibrados; score interno no se muestra como probabilidad. La UI siempre dice
«Posible coincidencia» y pide revisión. No se activan avisos automáticos.

## Arquitectura, persistencia y seguridad

Funcionalidad `case_matching` en Flutter y `matching` en Nuxt con dominio,
contratos/casos de uso, DTO/fuentes/repositorios y ViewModels; bootstrap/plugins
componen. Páginas/router componen otras funcionalidades sin imports cruzados de
presentation/data. Cabecera reutilizable `EntityPageHeader` para las dos nuevas
vistas web. Rutas web `/coincidencias` y `/casos/encontrados|perdidos/:id`, política
global account SSR/cliente; motores de origen existentes y movimiento reducido.

Plan040, fuentes128–134: índices y revisiones privadas sin grants directos;
RPC de lectura/indexación/revisión solo service_role. El servidor verifica la
identidad por sesión web vinculada al actor o token Android validado en Auth,
nunca por decodificar un JWT ni por `p_actor` enviado por el cliente.
El servidor deriva ese actor y autoriza el responsable/visibilidad actual en SQL.
Vectores, rutas Storage y UUID de propietarios no forman parte del resultado UI.

Snapshot versionado de caso/fotos, hash de contenido y modelo; md5 es etiqueta
de revisión, no autorización. Escrituras verifican snapshot vigente y normalización;
locks y relectura final rechazan resultados obsoletos. Cierre, retirada, cambio
de fotos y moderación invalidan índices; bloqueos excluyen candidatos en cada
lectura. Revocación/cambio de cuenta elimina estado UI y resultados tardíos.
Revisiones append-only con UUID de orden estable: repetir una orden antigua no
sobrescribe una decisión más reciente ni fabrica un segundo cierre.

## Evaluación y límites

Scripts reproducibles de preparación, smoke técnico, servidor construido con
modelo real/backend de prueba y evaluación con manifiesto local autorizado.
La evaluación separa identidades entre desarrollo/prueba, rechaza fotos repetidas
y registra Recall@5, errores top1, negativos con sugerencias y latencia.
La meta exploratoria del plan requiere al menos50 identidades; no hay dataset
ni resultado de precisión acreditados todavía. Pruebas con ilustraciones o
canarios sintéticos solo acreditan ejecución y contratos.

Referencias primarias: [modelo ONNX](https://huggingface.co/Xenova/clip-vit-base-patch32),
[implementación/licencia MIT de CLIP](https://github.com/openai/CLIP/blob/main/LICENSE),
[model card y límites](https://github.com/openai/CLIP/blob/main/model-card.md),
[Transformers.js](https://huggingface.co/docs/transformers.js/v3.8.1/en/index),
[runtime Node](https://onnxruntime.ai/docs/get-started/with-javascript/node.html).
