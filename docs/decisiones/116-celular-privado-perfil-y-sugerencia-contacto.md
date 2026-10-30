# ADR-116: celular privado de perfil y sugerencia de contacto por caso

Fecha:20/10/2026. Estado: aceptada por petición del usuario de completar el celular del perfil y el contacto de quienes crean casos.

## Decisión

Perfil móvil incorpora Celular de contacto opcional, con teclado telefónico y autofill,
misma superficie/espaciado de los campos existentes. Nombre, ciudad y celular se
confirman juntos mediante UpdateProfile. Se admite vacío (null); se eliminan espacios,
paréntesis y guiones de presentación y se exige + y8–15 dígitos, primero distinto de0.
Es validación de formato internacional, sin verificación de titularidad por SMS.
No se deduce un número del correo, Google, país o datos antiguos.

profiles.contact_phone permanece privado mediante RLS de propietario y grants por
columna. Ningún lector ajeno ni anónimo obtiene el celular del perfil. read_case_contact
extiende su proyección con suggested_phone solo para el autor. case_contacts consume
la sugerencia desde su propia RPC/DTO; no importa presentación/data de profile.

Al crear el contacto de una ficha se precargan nombre y celular propios disponibles;
Compartir contacto en esta ficha y Compartir mi foto de perfil siguen desactivados.
El usuario confirma el dato publicable y el consentimiento por caso. Un contacto ya
publicado conserva su número aunque se cambie/elimine el del perfil. Puede editarse
o retirarse desde la ficha. Guardar un perfil no modifica ni publica casos.
QR anónimo, carteles PDF y enlaces sociales conservan sus proyecciones sin contacto.

## Arquitectura y entrega

AccountProfile/ProfileDto, contratos de repositorio/fuente, UpdateProfile,
ProfileViewModel/estado y ProfileEditor transportan el nuevo campo. Se conserva
borrador durante fallo, bloqueo de doble envío, descarte, recarga y protección frente
a cambios de identidad. Cambiar foto/ciudad conserva también el borrador telefónico.
Error de formato usa ShakeField y toast superior; sin mensaje de error debajo.
La explicación visible de privacidad es una instrucción, no feedback de error.

Plan033/fuentes112–114, migración20261020003300_profile_contact_phone.sql y patch033
se generan mediante Build-Migration/Build-ProfileContactPhonePatch/Build-RunAll.
No se reescribe031: contacto por caso ya preparado allí;032 añade compartir;
033 añade este celular. Aplicar en orden después de030, solamente los pendientes.
El validador del bundle reconoce la nueva columna nullable text y mantiene rechazo
de estructuras incompatibles. Repetir bundle/patch no borra números ni consentimientos.

## Validación y límites

Pruebas de normalización/errores/borrado, persistencia/reintento/identidad, adaptación
normal/320px con texto2, SDK simulado y permisos SQL con dos cuentas. Comprobar
que la sugerencia privada nunca implica consentimiento y que el contacto publicado
no sigue modificaciones del perfil. Resultados en ESTADO. Aplicación hosted,
reingreso y teclado/autofill en Android físico pendientes; sin despliegue.
