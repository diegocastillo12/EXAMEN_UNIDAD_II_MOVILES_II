# Borradores locales de reportes

Estado24/10: **Done**, [#47 cerrado](https://github.com/srg-cp/entrehuellas/issues/47).
Integración original PR66 y aceptación final con PR67/CI aprobado. La evidencia
Android siguiente corresponde a emulador y reinicio de proceso.

HU-15.1 / RF-32 / issue #47 · S6 · Android primero.
[ADR-131](../decisiones/131-borradores-locales-por-cuenta.md).

## Qué hace y recorrido

Conserva el formulario incompleto de mascota perdida propia, búsqueda comunitaria,
aviso de mascota encontrada y avistamiento. Al editar se guarda automáticamente;
al salir se espera su escritura. La siguiente visita recupera el mismo borrador.
Perfil → Borradores reúne únicamente los de la cuenta y este dispositivo; Retomar
abre el editor y contexto originales, incluso con sus dependencias remotas caídas.
Los formularios muestran Borrador / Sin publicar; no se confunde con un caso activo.
Descartar usa la confirmación compartida. Un envío con resultado incierto conserva
el comando original y se resuelve reintentando; en encontrado, el descarte conserva la RPC que confirma que no hay publicación activa antes de retirar el borrador local.

## Campos y reglas

UUID estable, fecha y hora independientes/incompletas, referencia de lugar y punto
privado; mascota seleccionada/versión/fotos seleccionadas para perdido; especie,
rasgos, tamaño/sexo/custodia y fotos nuevas para búsquedas/avisos; comentario,
ubicación/precisión y foto para avistamiento. Las fotos nuevas conservan bytes y
su identificador, sin depender de archivos temporales. Las de mascotas conservan
referencias y metadatos, sin URLs firmadas duraderas ni descarga offline de fichas.

Un borrador por cuenta/contexto. La vista de edición y los resultados tardíos se
separan por identidad. El borrador conserva el contenido exacto antes del envío;
una respuesta incierta se recupera congelada. El servidor sigue autorizando cada
intento y comprobando versión, fotos, estado y reglas de bloqueo.

## Persistencia y permisos

Drift/SQLite local esquema 1, base `report_drafts.sqlite` en soporte privado Android;
campos y evidencia se reemplazan atómicamente. Lecturas/escrituras/borrados ordenados.
Una confirmación antigua solo elimina el UUID correspondiente. Cuenta/contexto se
filtran antes de restaurar. No se almacenan credenciales, contacto ni perfiles ajenos.
Base/auxiliares excluidos del backup/transferencia Android. No hay esquema o despliegue
Supabase nuevo. Salir/cambiar cuenta conserva datos aislados; descartar elimina el
borrador propio; confirmar publicación lo retira; borrar datos/desinstalar los elimina.

El acceso global puede recuperar una bienvenida confirmada de esa misma cuenta
ante un fallo de transporte. La caché no autentica ni concede permisos y respeta
una respuesta remota negativa. Una cuenta nueva requiere conexión/bienvenida.

## Errores y reintentos

Un error de lectura no se convierte en borrador vacío ni sobrescribe el anterior.
Fallo de escritura conserva el formulario, muestra toast superior y permite
Reintentar guardado local; salir y publicar esperan una escritura confirmada.
Un fallo remoto conserva el UUID para el mismo reintento. Publicar confirmado puede
dejar el comando local si falla su borrado; reenviarlo confirma el mismo resultado.
Skeleton en lectura inicial, shimmer en acciones locales y sin dobles acciones.

## Dependencias y activación

Sin variables ni servicios nuevos. Dependencias nativas Drift, path/path_provider
y sqlite3_flutter_libs incluidas en pubspec/lock y registros de plugins. Requiere
actualizar el cliente Android; la web Nuxt conserva sus recorridos actuales.
La cola automática HU-15.2 se documenta en [envíos pendientes](envios-pendientes.md).
No entrega HU-15.3 (fichas/mapas en caché).

## Validación acreditada —23/10/2026

La ampliación final detectó timeouts de conflicto remoto.037/038 fueron aplicados
por el usuario y la suite estricta pasa6/6: perdido y preparación/publicación de
búsqueda rechazan contenido incompatible, sin timeout. Cuatro SQL focalizadas
verifican repetición y conservación de ajustes/ACL; regresión completa en ESTADO.
La cola local sigue rechazando la mutación por huella antes de enviar.

La regresión final compartida con HU-15.2 pasa575/575 pruebas Flutter,56/56 SQL
locales después de038 y análisis sin incidencias. Se conservan los renders previos390×844 y
320×350/texto200%, sin atribuirles aprobación visual del usuario. Resultados de
la integración de cola en [envíos pendientes](envios-pendientes.md) y ESTADO.

En la app normal instalada en Pixel_9a/Android16/API36, Perfil→Borradores/Envíos
sigue accesible sin red incluso si falla la consulta remota de perfil. Se crea un
borrador QA desde el formulario, se confirma Salir y se recupera tras force-stop
con modo avión y Wi-Fi apagado: Retomar conserva exactamente la referencia
QA_native_offline_20261023. Se descarta por la confirmación del producto; no había
borradores anteriores y no se modifica el caso activo de la mascota existente.

Después, búsqueda comunitaria QA con foto elegida por el picker Android y
normalizada por el código real: Publicar sin red conserva comando y bytes en la
cola, que sobrevive a force-stop/reapertura. Al recuperar red, sincronización
automática publica el mismo UUID/huella y limpia el borrador. Servidor real de
desarrollo confirma un resultado con una foto; el caso QA se retira desde Mis
reportes y deja de ser público. Sin cambios de datos originales ni logout de la
sesión que ya tenía el emulador.

El smoke previo con base separada aprueba WRITE→force-stop→READ sin red. Nuevo
tool/offline_queue_native_validation.dart aprueba10 checks nativos: migración1→2
preserva fecha parcial y3×2MiB de evidencia con hash completo, aislamiento A/B,
conflicto del mismo UUID, dos conexiones/una reclamación, nonce anterior, backoff,
cancelación protegida y8MiB de evidencia de avistamiento. Sus datos son sintéticos
y se eliminan al terminar; no prueba cámara física. Mediciones observadas en
emulador:682ms migración/lectura6MiB,709ms enqueue6MiB y1296ms guardar/leer8MiB.

Seis pruebas remotas usan dos identidades confirmadas, JPEG procesado por el
servidor, respuesta perdida tras commit, reintento idempotente, aislamiento,
rechazo de autoría y revocación de la sesión de prueba. No se cambia la contraseña
de B ni se cierran otras sesiones. Configuración de prueba solo en archivo local
ignorado por Git. Fixtures QA retirados/archivados con las APIs del producto;
auditoría/recibos permanecen según contrato.

Logs y herramientas reproducibles en la ficha de envíos y CONFIGURACION. La app
normal profile x64 queda instalada al terminar; Wi-Fi y modo avión restaurados.
La UI se verifica con workaround gráfico del emulador (ANGLE, sin Vulkan/Impeller,
render software por extras) sin cambiar Manifest ni el producto. No se acredita
teléfono físico, todos los drivers, reinicio completo del dispositivo ni fallos
físicos de almacenamiento. Los bloqueos anteriores de APK/demo quedan sustituidos
para lo aquí comprobado. El24/10 el usuario autoriza integración/cierre de #47;
se tramita con CI y auditoría GitHub, sin nueva afirmación de teléfono físico.
