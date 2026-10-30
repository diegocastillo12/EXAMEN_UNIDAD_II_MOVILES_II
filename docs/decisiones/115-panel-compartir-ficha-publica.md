# ADR-115: compartir ficha desde un panel blanco

Fecha:20/10/2026. Estado: aceptada por instrucción explícita del usuario.

Referencia visual en [mockup](../../mockups/compartir-ficha-referencia.png).
La X que aparece en esa imagen se elimina por la corrección posterior del usuario.

## Composición aprobada

Botón glass Compartir junto a Guardar en la cabecera de la ficha. Panel inferior
blanco opaco con esquinas28 y tirador; sin glass en el panel ni en sus opciones.
Sin X por corrección explícita del usuario: esta decisión sustituye la regla
general de cierre con X solo en este panel. Cierra mediante arrastre, toque
fuera o Atrás, con alternativa accesible de descarte propia de la ruta modal.

Fila superior de tres opciones: Copiar enlace en círculo azul/icono blanco,
WhatsApp verde y Facebook azul, con sus etiquetas. Tras el separador, Descargar
y Denunciar son dos círculos grises contiguos con iconos oscuros, sin etiquetas
visibles; conservan tooltip y semántica. Descargar significa cartel público PDF
y abre la opción nativa de impresión/Guardar como PDF existente, sin asegurar
que el archivo ya se haya guardado. Denunciar abre el formulario existente.
No se envían mensajes ni publicaciones automáticamente.

Scroll/área segura en alturas pequeñas y texto ampliado, movimiento reducido
sin animación modal. LoadingShimmer solo en la acción activa, sin spinner, puntos
suspensivos o etiquetas cambiantes. Toast superior para resultado/error real.
Un fallo conserva el panel para reintentar; cancelar no confirma descarga/envío.

## Arquitectura

Se amplía case_posters con SharePublicCase, CaseShareRepository y ViewModel/
estado propios de compartir. Se reutilizan PosterPayload, PosterContent y el
generador PDF saneado; no se reutiliza el permiso exclusivo de autor de
prepare_case_poster. Data encapsula RPC, Storage, launcher y exportador nativo.
Bootstrap inyecta el puente Clipboard como callback, igual que las fuentes de
fuentes tipográficas; ninguna dependencia Flutter en data o dominio.
Router compone CaseShareButton mediante un builder de presentación de ficha
y el callback de denuncia; no hay imports presentation/data entre features.

## Enlace y autorización

Nueva RPC autenticada prepare_case_share, plan032/fuentes110–111. Exige búsqueda
activa, visible y con foto pública procesada que el lector QR pueda mostrar.
Admite pérdida propia/comunitaria y encontrado independiente anterior, según
el contrato QR actual. Los avisos vinculados de avistamiento/custodia, fichas
cerradas, sin foto, eliminadas u ocultadas no generan un enlace de otra ficha
ni un destino ficticio; reciben error de disponibilidad y conservan Denunciar.

La RPC deriva el dueño real del caso al crear case_public_links; un lector no
se convierte en autor. Reutiliza el slug por origen+caso y jamás reactiva una
revocación. No amplía grants directos de tablas/Storage, ni el lector QR anónimo.
prepare_case_poster sigue siendo exclusivo del autor. La proyección de compartir
excluye coordenadas, referencia privada, contacto, correo y credenciales.

Las salidas a Clipboard/WhatsApp/Facebook contienen solo la URL HTTPS /c/:token;
ninguna URL firmada de Storage. Se reutilizan PUBLIC_CASE_WEB_URL y
PUBLIC_CASE_WEB_READY; configuración inválida impide incluso preparar el enlace.
Se vuelve a validar revisión/enlace/sesión antes de entregar datos al dispositivo.
Cambiar cuenta descarta resultados anteriores y cada operación bloquea doble envío.
La publicación final queda bajo control del usuario en la aplicación externa.

## Alcance y activación

Ampliación explícita de HU-07/HU-08, RF-08/13/37, sin issue nuevo ni cierre de HU.
No incorpora chat interno, SDK social, nuevas dependencias, contacto en QR/PDF,
descarga offline ni permisos administrativos. ImmersivePhotoSheet se conserva.
Migración/patch032 requieren031 en la secuencia de instalación; no aplicado
remotamente. Pruebas locales y límites en ESTADO y la
[ficha funcional](../funcionalidades/compartir-ficha.md).
