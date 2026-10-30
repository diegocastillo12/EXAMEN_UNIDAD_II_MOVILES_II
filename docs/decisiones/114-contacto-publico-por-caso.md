# ADR-114: contacto del reportante con permiso por caso

Fecha:20/10/2026. Estado: aceptada por elección explícita «Añadir también los datos de contacto».

## Decisión y alcance

Se incorpora case_contacts como funcionalidad móvil, con MVVM, dominio, casos
de uso concretos, repositorio, DTO y fuente Supabase/acciones del dispositivo.
Bootstrap/main inyectan la implementación. Router compone CaseContactPanel en
un slot de las fichas; no hay imports de presentación entre funcionalidades.
No se amplían consultas de perfiles privados ni las proyecciones QR/web.

El autor registra su contacto **desde la ficha publicada** mediante Compartir
mi contacto. Es un guardado separado de publicar el caso: no promete atomicidad
entre ambas operaciones ni añade una repetición de publicación. Nombre público
editable y teléfono internacional requieren habilitar Compartir contacto en esta
ficha; la foto de perfil almacenada requiere una segunda elección independiente.
No se obtiene el teléfono de Auth ni se comparte información por defecto.
Se puede editar o retirar el contacto mientras se consulta el caso activo.
Inicial real del nombre como alternativa si no hay foto almacenada/autorizada.

## Servidor y privacidad

Plan031, fuentes106–109, exige030. Tabla case_contacts sin grants directos,
RLS habilitada y RPC autenticadas read_case_contact/set_case_contact. Autor
resuelto mediante auth.uid() y la propiedad real del caso; no viene del cliente.
Las lecturas de contacto/foto exigen una ficha activa visible, incluida moderación
y acceso a los destinos de avisos. Cerrada, eliminada u oculta deja de exponerlo.
No se publica correo, perfil completo, coordenada privada ni ID de autor adicional.

Nombre2–80 sin controles, teléfono + seguido de8–15 dígitos y versión validados
en dominio/servidor. El comando bloquea el caso y usa CAS. Un reintento exacto de
versión anterior devuelve el resultado sin reescribir; cambios intermedios causan
conflicto. La UI congela el envío ante fallo ambiguo y permite reintentarlo;
conflicto/permiso requieren consultar de nuevo. Cambiar identidad oculta el estado
anterior e invalida respuestas tardías.

Foto opcional: Storage privado profile-avatars conserva escritura solo del autor.
El guard restrictivo ALL anterior se separa por operación: solo SELECT acepta
la autorización de un contacto visible. No cambia privacidad de otros avatares.
URL firmada60s; retirar el permiso bloquea nuevas firmas, pero una URL ya emitida
puede funcionar hasta su vencimiento y una imagen ya descargada no se recupera.
Se comparte la foto de perfil actual guardada, no una copia ni foto externa OAuth.

Los iconos abren SMS y el marcador telefónico del dispositivo, sin chat propio
ni llamada automática. Revalidan permiso antes de abrir. Fallos usan el toast;
no se confirma que un mensaje se haya enviado ni que una llamada se haya realizado.

## Activación y consecuencias

Generar mediante Build-Migration/Build-CaseContactsPatch y Build-RunAll, sin
reescribir SQL aplicado. Validación local PostgreSQL/PostGIS y Flutter en ESTADO;
activación hosted/Storage, llamadas/SMS reales y Android físico pendientes.
No desplegado. Ampliación explícita de HU-05/06/07, RF-05/06/13, sin issue nuevo
asignado ni cierre de historias. Detalles en
[contacto del reportante](../funcionalidades/contacto-reportante.md).
