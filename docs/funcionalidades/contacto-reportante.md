# Contacto del reportante por caso

23/10, alcance HU-14.2 confirmado por usuario: patch035 después de034 oculta
nombre/teléfono/foto entre cuentas bloqueadas, en cualquiera de los sentidos.
RPC y Storage reutilizan `case_contact_visible`; autor y terceros autorizados
conservan permisos. No modifica el consentimiento ni publica contacto nuevo al
desbloquear. Flutter revalida consultas después de una mutación de bloqueo,
incluida respuesta ambigua. URLs firmadas previas pueden durar60s; no se recuperan
datos/fotos ya obtenidos. [Bloqueos](bloqueos-usuarios.md), activación remota pendiente.

Selector20/10, ADR-117: teléfono de contacto usa InternationalPhoneField compartido con Perfil, bandera/prefijo y número nacional, búsqueda local en español. Conserva sugerencia completa, consentimiento por caso/foto, reintentos y formato SQL; no requiere otro patch.

Actualización20/10, ADR-116: sugerencia del celular privado del perfil únicamente
al autor mediante read_case_contact.suggested_phone. Requiere patch033 después de032;
031 ya contiene el contacto/consentimiento por caso. Sin contacto automático.

Refinamiento visual20/10 de ADR-113: tarjeta y controles SMS/teléfono usan el acabado frosted compartido, con iconos azules22 y objetivos52. Se suavizan borde y sombra para acercarlos al mockup; datos, consentimiento y operaciones permanecen iguales.

Ampliación explícita20/10 de HU-05/06/07 y RF-05/06/13, sin issue nuevo ni cierre
de historias. Implementación local, activación remota pendiente. [ADR-114](../decisiones/114-contacto-publico-por-caso.md).

## Recorrido y campos

Después de publicar, el autor abre su ficha y elige Compartir mi contacto.
Activa Compartir contacto en esta ficha; indica nombre público2–80 caracteres
y teléfono internacional (+ y8–15 dígitos). Puede usar el nombre sugerido de su
propio perfil y, con el incremento033, su celular privado como sugerencia; no se activa consentimiento automáticamente. Cambiar/eliminar el celular del perfil no modifica el número ya publicado en esta ficha.
Compartir mi foto de perfil es independiente y desactivado inicialmente. Se
usa la foto almacenada actual si existe; en otro caso, inicial del nombre real.
Guardar contacto no vuelve a publicar el caso ni cambia sus campos.

Los demás lectores ven la tarjeta con nombre/teléfono y foto autorizados.
SMS y teléfono abren las aplicaciones del dispositivo tras revalidar visibilidad.
No son chat interno ni llamada/envío automáticos. El autor puede editar y retirar
el contacto desde la ficha activa. Al cerrar/ocultar/eliminar el caso, el contacto
deja de publicarse; el registro privado puede conservarse con el ciclo del caso.

## Persistencia y permisos

Tabla case_contacts por origen+UUID, dueño derivado de auth.uid()/caso, enabled,
nombre, teléfono, share_photo y versión. RLS sin grants directos; solo RPC
autenticadas. El nombre sugerido solo se devuelve al autor; no se exponen otros
campos privados de profiles. Contacto/foto exigen acceso al caso activo visible.
No se incorpora contacto a QR, web anónima, carteles o notificaciones.

Foto: política SELECT acotada en profile-avatars. Escrituras conservan aislamiento
incluso con otra política permisiva amplia. Firma60s, no bucket público. Retirar
permiso impide nuevas lecturas/firmas; una URL ya emitida puede durar60s y las
imágenes descargadas no se recuperan. No se publica la foto externa de Google.

## Errores y reintentos

Todo feedback en toast superior; nombre/teléfono inválidos mantienen ShakeField.
El payload/version se congela durante guardado y tras respuesta ambigua. Reintentar
usa el mismo comando; servidor deduplica el reintento exacto. CAS evita pisar una
edición intermedia. Conflicto/permisos ofrecen Consultar contacto. Formulario
conservado ante fallos; no hay confirmación de éxito antes de respuesta válida.
ViewModel autoDispose por caso/cuenta descarta terminaciones de otra identidad.
Sin permisos/contacto no aparece una tarjeta ficticia. Error de lectura permite
reintentar sin ocultar los datos públicos del animal. Error opcional de foto usa
inicial; fallo al abrir SMS/marcador usa toast y conserva contacto.

## Dependencias, activación y validación

Feature case_contacts con entidades/contrato/casos de uso, ViewModel/estado/UI,
DTO/repositorio/fuente SDK y providers declarativos. Bootstrap/main inyectan,
router compone el slot sin importar presentation/data entre features.
Plan031/fuentes106–109/migración20261020003100_case_contacts.sql requieren030;
patch generado en database/patchs/031_patch_case_contacts.sql. Generadores
Build-Migration.ps1, Build-CaseContactsPatch.ps1 y Build-RunAll.ps1.

Validaciones locales: dominio/normalización, consentimiento, operaciones reales
del ViewModel con adaptador simulado, reintento ambiguo/doble envío/cambio de
cuenta, layouts normal/pequeño texto2, SQL/PostGIS entre usuarios, restricciones,
versiones, revocación, Storage de solo lectura y repetición de migración/bundle.
Resultados en docs/ESTADO.md. Falta aplicar031 en Supabase y probar firma/foto,
revocación, marcador/SMS y layouts en Android físico. Sin despliegue ni datos
de ejemplo insertados en cuentas reales.
