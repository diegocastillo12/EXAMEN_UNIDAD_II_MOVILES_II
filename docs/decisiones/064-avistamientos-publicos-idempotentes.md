# ADR-064 — Avistamientos públicos desde la ficha QR

Fecha: 18/10/2026. Estado: implementada localmente; activación remota pendiente.
Trazabilidad: HU-10.1, RF-11, issue #36. Requiere 001–023.

## Decisión y recorrido

La página Nuxt compone CaseReader y SightingForm mediante un slot; no hay imports
de presentation entre funcionalidades. Dominio `sightings` contiene contratos,
SubmitSighting, LocateSighting, datos y validación, sin Vue/Nuxt/SDK. ViewModel
gestiona envío, selección/GPS, errores, disposición y reintento. Plugins y
server/utils componen implementaciones HTTP, navegador y Supabase por petición.
No hay estado de visitante global. No se modifica el flujo Android HU-10.2.

Un visitante de un QR activo puede aportar fecha/hora observadas, punto manual
o GPS con origen/precisión, comentario opcional de hasta 500 caracteres y una
foto opcional. La ubicación inicial aproximada del caso nunca cuenta como punto
elegido. Denegar GPS/cámara permite mapa manual/galería/sin foto. Solo un recibo
persistido confirma éxito. No se cierra la búsqueda ni se inventa un reportero
autenticado para reutilizar `found_cases.owner_id`.

## Persistencia, privacidad y reintentos

Fuentes 083–085/plan024 crean `public_sightings` y RPC `submit_public_sighting`,
ejecutable exclusivamente por service_role. Sin grants de lectura/escritura
directa para navegador, usuarios o servicio; la función SECURITY DEFINER posee
la operación. El backend valida fecha desde 2000, no futura, coordenadas,
precisión y estado vigente bajo bloqueo. Observaciones de más de 24 horas se
marcan tardías, conservando fecha observada y recibida. Este umbral se hace
explícito y puede evolucionar con una nueva migración.

La clave UUID del formulario y un hash canónico de sus datos/foto original
deduplican el envío. Cambiar datos con la misma clave da conflicto. Tras una
respuesta ambigua, el ViewModel conserva y bloquea el payload; reintenta exactamente
ese envío. Un recibo ya guardado puede recuperarse después del cierre; un enlace
revocado siempre rechaza la operación. Los bloqueos de caso/enlace coordinan
con resolución/revocación. No se implementa cola offline ni persistencia de
borrador entre recargas/cierre del navegador (HU-15).

El servidor verifica firma de JPEG/PNG/WebP, decodifica con sharp 0.35.5
(máximo 24 millones de píxeles), rechaza animación, reorienta y recodifica JPEG
sin EXIF/XMP a máximo 1280px y 1 MiB. Original de hasta 8 MiB solo en memoria.
SQL valida tamaño y firma del derivado; la decodificación la garantiza el
adaptador de servidor autorizado, nunca una afirmación del navegador.

Se elige bytea privado para esta única evidencia acotada: permite confirmar
metadatos y foto en la misma transacción, sin cargas huérfanas ni una transacción
distribuida con Storage. Aumenta tamaño de base/backups; revisar volumen y costes
antes de escalar y migrar a Storage con protocolo de confirmación si procede.
No se publican bytes, comentarios, punto exacto ni hashes en la ficha QR.
La revisión de avistamientos/cronología y su proyección autorizada pertenecen
a HU-11; no se declara esa integración entregada por persistir este incremento.

## Abuso y exposición HTTP

POST solo en `/api/c/<token>/sightings`, origen exacto configurado mediante
PUBLIC_WEB_ORIGIN y sin credenciales/cookies de visitante. Sin CORS abierto.
Límite de 9 MiB por cuerpo y 15s de recepción; máximo cuatro escrituras en vuelo
por proceso, diez intentos por minuto/IP y límites previos de lectura conservados.
La RPC añade límites persistentes compartidos por réplicas: cinco confirmaciones
por diez minutos/HMAC de IP y treinta por hora/caso. Reintentos idénticos no gastan
presupuesto. IP sin almacenar: HMAC con clave de servidor, nunca hash aportado
por el cliente; proxies solo si sus pares están expresamente configurados.
Rotar la clave cambia el pseudónimo; no es una garantía de identidad personal.

Los permisos de navegador habilitan geolocalización/cámara solo para el propio
origen. Leaflet reutiliza el proveedor de teselas actual; CSP permite únicamente
su host de imágenes además de self, conservando nonce sin unsafe-inline ni eval.
Se mantienen las condiciones del proveedor pendientes antes de distribución.

## Presentación y activación

Se aplica ADR-063 a WebShell/ActionButton/QR y formulario: crema, Arial, marca
en minúsculas, cápsulas azules/celestes, glass, toast y shimmer compartidos.
No se importa UI de landing. Cabecera fuera de entrada y formulario por etapa;
editar/refrescar no repite entrada. Invalidez/Shake y semántica, sin errores
bajo campos. Movimiento reducido, teclado, 320px/texto200% y cierre del aviso.

Aplicar patch024 generado en desarrollo después de023, configurar origen HTTPS
exacto y desplegar conjuntamente SQL/web. No habilitar por evidencia de mocks.
Validación local y límites reales en ESTADO y ficha de avistamientos web.
La revisión detecta contraste insuficiente en blanco/degradado azul aprobado
(1.97–3.62:1); se conserva esa elección explícita y se registra el pendiente
de adaptación accesible, sin una excepción ni certificación AA implícitas.
