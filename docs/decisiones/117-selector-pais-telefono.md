# ADR-117: selector de país y prefijo telefónico compartido

Fecha:20/10/2026. Estado: aceptada por petición explícita del usuario.

## Decisión

InternationalPhoneField en core/presentation/widgets se reutiliza en Perfil y
Contacto del reportante. Selector con bandera y prefijo, número nacional separado.
Países en español, búsqueda local por nombre (sin tildes), ISO o prefijo. Panel
blanco opaco con tirador, cierre por Atrás/toque fuera/gesto; respeta área segura,
teclado, texto ampliado, scroll y movimiento reducido. No añade X.
Perú/+51 es la selección inicial de un campo vacío; elegir país sin número no
crea un valor ni activa consentimiento. En anchos pequeños/texto ampliado se
apilan selector y número. Las banderas son recursos vectoriales locales y el
nombre/prefijo tienen semántica; no dependen del soporte de emojis del sistema.

El catálogo/localización proviene de country_picker2.0.28, las banderas de
circle_flags5.0.1 con flutter_svg ya usado por el proyecto. Versiones fijadas en
pubspec y lock, sin SDK telefónico, permisos, peticiones de red ni selección por
GPS/IP. Referencias de proveedor:
[country_picker](https://pub.dev/packages/country_picker) y
[circle_flags](https://pub.dev/packages/circle_flags).

## Contrato y límites

El controller externo conserva el número internacional completo; los ViewModels,
casos de uso y SQL no cambian. Se puede pegar un número completo, sin duplicar el
prefijo; se conservan ceros nacionales. Al cambiar país se conserva la parte
nacional. Un número vacío sigue vacío. No se alteran datos existentes al montar
el control, cancelar el selector o recibir una recarga externa.

Si un prefijo corresponde a varios países, se conserva la elección explícita
actual cuando aplica; al leer un número sin país identificable se muestra globo
y prefijo hasta elegir, evitando asignar una bandera arbitraria. El país ISO es
selección de presentación, no se persiste separadamente. Un prefijo no reconocido
se conserva completo para no truncar datos. No valida titularidad ni longitud
nacional por país: la validación de dominio/servidor + y8–15 dígitos sigue vigente.
Errores en toast superior con ShakeField; permisos/privacidad y consentimiento por
caso/foto intactos. No cambia el número de contactos publicados al editar perfil.

## Activación y validación

No requiere patch SQL adicional a031–033 ya preparados. Actualizar dependencias
Flutter mediante pub get. Widget compartido administra controllers/foco/modal y
libera listeners; disabled/busy bloquean selector y edición. Pruebas y renders
normal/pequeño con texto2/teclado, búsquedas, cancelación, campos vacíos, pegado,
prefijos compartidos/desconocidos, ceros iniciales, cambio de controller y
persistencia de perfil/contacto. Resultados en ESTADO. Android físico pendiente.
