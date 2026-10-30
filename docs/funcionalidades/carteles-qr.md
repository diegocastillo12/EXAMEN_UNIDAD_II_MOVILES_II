# Carteles PDF y QR

## Aceptación del usuario — 25/10/2026

El usuario confirma que cuenta/acceso, difusión, seguimiento y recuperación ya
fueron validados y solicita actualizar el seguimiento. Se registra su aceptación,
sin atribuir al agente una nueva demo ni un log individual de cada escenario.
Esta nota sustituye los pendientes de validación correspondientes de las notas
históricas; no activa FCM ni acredita baja/exportación sin implementar.

Difusión aceptada: #34/#35 y épica #8 cerrados/Done. Los pendientes históricos de impresión/escaneo y acciones nativas dejan de ser bloqueos de aceptación.

24/10/2026: dominio público actualizado a `https://entrehuellas.app`. Los
endpoints de Supabase y la infraestructura se conservan. Código/configuración
local actualizados; despliegue, retorno OAuth, envío de correo y escaneo de QR
en producción pendientes de comprobación. Los QR/PDF ya distribuidos con el
subdominio anterior necesitan mantener ese host o una redirección de navegación
a la misma ruta y parámetros; el código no regenera documentos existentes.


Ampliación20/10, ADR-115: [Compartir ficha](compartir-ficha.md) permite difusión/descarga de la proyección pública por otros lectores autorizados mediante prepare_case_share/plan032. No altera el permiso de autor de prepare_case_poster ni el generador PDF; reutiliza el mismo enlace QR y respeta revocación. Activación032/Android pendientes, sin cierre de HU.

**Auditoría de seguimiento18/10:** HU-08/#8 y #34/#35 siguen In progress por criterios concretos: impresión/escaneo físico y guardar/compartir/cancelar mediante hojas nativas Android. Generación/lector022/023 ya están confirmados; no mantener la web no disponible como bloqueo genérico.

Actualización16 octubre: [lector público HU-09](ficha-publica-qr.md) implementado
localmente; falta aplicar023 y publicar/comprobar Node/TLS en el dominio acordado.
PUBLIC_CASE_WEB_READY sigue false. No se habilitan carteles reales por la sola
existencia del código web; formulario HU-10.1 e integración remota pendientes.

Módulo case_posters. HU-08.1/#34 y HU-08.2/#35; HU original08/issue#8; RF-08,37. Implementado localmente en feature/pet-poster-qr, sin historia cerrada. [ADR-053](../decisiones/053-carteles-pdf-y-enlaces-qr.md).

## Qué hace y recorrido

Desde una ficha abierta propia, Crear cartel con QR abre una pantalla con retorno glass y entrada compartida. Generar cartel solicita una proyección autorizada, obtiene la foto pública principal y produce una sola página A4. Se conserva el artefacto durante la visita. Generar de nuevo permite reintentar sin modificar el caso.

Imprimir o guardar PDF abre el diálogo nativo de impresión y su opción Guardar como PDF. Compartir PDF entrega exclusivamente el documento generado y la URL; Compartir enlace entrega solo la URL. La app no envía mensajes a destinatarios por sí sola. Cancelar mantiene el documento disponible. El resultado de la hoja no acredita recepción por otra persona.

## Reglas y campos

Solo el autor de un caso activo, visible y con foto procesada seleccionada. Incluye pérdida propia/comunitaria y encontrado independiente anterior; avisos vinculados conservan su búsqueda de destino. PDF con nombre o especie cuando falta nombre, especie/tamaño/sexo disponibles, fecha y rasgos; foto sin EXIF, QR con margen blanco y enlace legible. Nombre/rasgos extensos se ajustan sin truncar. Sin ubicación exacta, referencia privada, contacto, salud, documentos, URLs firmadas o tokens de sesión.

URL acordada por el usuario: `https://entrehuellas.app/c/<slug opaco>`. El PDF es una instantánea y pide consultar la ficha para ver cambios. El mismo slug permanece entre generaciones y tras cierre; una revocación nunca se deshace generando de nuevo. Antes de exportar se verifica de nuevo el servidor; cambios en la ficha imprimible exigen regenerar.

## Persistencia y permisos

Tabla case_public_links por origen+caso, privada con RLS/sin acceso directo de cliente. RPC prepare_case_poster autenticada y validada por autor/estado/fotos. El PDF y la foto procesada viven en memoria del flujo; no se escriben originales ni una cola offline. El temporal del plugin de compartir contiene solo el artefacto público.

## Errores y reintentos

Toast superior para validación, error, cancelación y resultado; skeleton inicial y LoadingShimmer en la acción real. Doble envío bloqueado y respuestas tardías descartadas por identidad/ciclo de vida. Error de generación conserva posibilidad de reintentar; ningún fallo cambia el estado del caso. Fallos de exportación conservan el PDF cuando sigue válido; estado/revisión/permisos inválidos retiran las acciones hasta regenerar. No se anuncia éxito ante cancelación o resultado nativo desconocido.

## Dependencias y activación

Aplicar [patch022](../../database/patchs/022_patch_case_posters.sql) o [migración022](../../supabase/migrations/20261016002200_case_posters.sql), tras001–021 y fotos procesadas operativas. Fuentes077–079/plan022; generadores Build-CasePostersPatch/Build-RunAll. No aplicar patches antiguos encima del contrato nuevo.

PUBLIC_CASE_WEB_URL usa el dominio indicado; PUBLIC_CASE_WEB_READY permanece false. La generación/exportación se bloquea antes de crear enlaces hasta activar una ficha pública real de HU-09. GET/ del dominio devolvió404 en esta revisión; no se da por publicada la web ni se modificó DNS/hosting. Variables públicas en el ejemplo de configuración, sin credenciales. pdf/printing/share_plus y fuentes incluidas requieren próxima recompilación nativa para probar hojas del sistema; el usuario indica que no hace falta APK todavía.

## Validación y pendiente

SQL local de permisos A/B/anónimo, repetición, origen, principal, revocación y cierre. Tests de repositorio/ViewModel/UI para configuración, URL, exportación/cancelación/reintento/cuenta y accesibilidad. PDFs perdidos/encontrados/extremo renderizados y QR decodificados; texto extremo completo comprobado con extracción. Capturas de pantalla390×844 y320×350/texto2/movimiento reducido con datos de prueba; evidencia y cifras en ESTADO.

Pendiente aplicación remota022; ficha web y lectura de estado vigente sin app; prueba de QR en otro móvil/impresión; guardar/compartir/cancelar con plugins nativos; permisos/concurrencia hosted. Sin APK, despliegue, cierre de historia o afirmación de demo integrada.
