# ADR-057 — Ficha QR ligera y proxy privado de lectura

Fecha:16 de octubre de2026. Estado: aceptada para implementación local.
Trazabilidad: HU-09 / RF-09 / issue #9, S4; depende del contrato de carteles022.

## Contexto y decisión

El visitante necesita leer el QR sin Flutter ni cuenta. La RLS de filas no basta
para ocultar columnas y las rutas de fotos contienen UUID privados. Se crea
`apps/platform`: cliente HTML/CSS/ES modules y adaptador HTTP Node22 de lectura,
sin librerías de producción ni una API general nueva. Supabase conserva reglas,
persistencia y autorización. Se mantiene Android y su ubicación existente.

Clean Architecture también en web: dominio puro con entidades/casos de uso y
contrato; data con fuentes REST y repositorios; presentación ViewModel/vista DOM;
bootstrap y rutas en app. No se trasladan secretos a JavaScript público.
Esta elección concreta el componente web de ADR-001; no introduce ASP.NET,
SignalR, Redis, workers ni reglas de producto en el servidor de transporte.

Fuentes080–082, plan023: `read_qr_case` ejecutable solo por service_role devuelve
proyección permitida y descriptores de rendiciones procesadas, exclusivamente
al servidor. El proxy valida bucket/path/bytes y reconsulta vigencia antes de
servir la foto. La respuesta al navegador excluye UUID privados, contacto,
coordenadas exactas, referencia privada y URLs Storage. Sin grants anónimos nuevos.
`revoke_case_public_link` es solo del autor autenticado y no reactiva enlaces.

Activo muestra fotos/rasgos/zona pública redondeada/estado; cerrado muestra estado
y fecha del evento de resolución sin ficha privada. No se inventa un motivo
«recuperado» que el contrato no registra. Revocado, eliminado e inexistente
comparten una página neutral. Se conserva la política de ocultar datos de casos
cerrados ajenos. Actualización manual, al volver a pestaña y cada60s visible;
no se promete retirada instantánea de contenido ya descargado.

La web comparte marca real/tokens/áreas táctiles/retorno glass de galería,
cover→stagger, skeleton, shimmer y toast superior mediante componentes DOM
reutilizados por sus estados. No importa widgets Flutter entre plataformas.
No se añade un mapa de teselas: el enlace externo usa solo la zona pública.

## Consecuencias y verificación

Necesita hosting Node y secreto servidor, TLS y proxy sin caché/logs de tokens;
no basta subir archivos estáticos. Cabeceras restrictivas, límites de bytes,
tiempo, concurrencia y solicitudes en memoria. Varias réplicas requieren límite
adicional del proxy. No se garantiza protección contra ataques distribuidos.
No almacenar tokens/IPs ni incluir analytics. No se promete borrar copias ajenas.

Pruebas locales de contratos/HTTP/ViewModel/fronteras y SQL/PostGIS; revisión
Chrome móvil/pequeño/texto ampliado documentada en ESTADO. Supabase hosted,
Storage real, dominio/TLS, segundo teléfono y Safari siguen por comprobar.
HU-10.1/#36 aportará el formulario; sin acción vacía mientras no exista.
HU-09 no se cierra por este incremento. PUBLIC_CASE_WEB_READY continúa false.
