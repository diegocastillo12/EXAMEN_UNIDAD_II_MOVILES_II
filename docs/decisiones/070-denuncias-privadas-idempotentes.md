# ADR-070: denuncias privadas con recibo estable

Fecha: 18/10/2026. Estado: implementada localmente; activación029 pendiente.
Trazabilidad: HU-14.1 / RF-22; issue #43. No incluye las otras derivadas de HU-14.

## Decisión y motivo

Android permite denunciar publicaciones de casos perdidos, búsquedas comunitarias,
avisos y reportes anteriores desde su ficha, y avistamientos privados desde su
revisión. El recurso queda fijado por navegación, con autorización independiente
en servidor; no se permite enumerar recursos privados mediante el formulario.

Se reutilizan las proyecciones vigentes para comprobar acceso a casos/avisos.
El avistamiento privado exige acceso del responsable a la cronología del caso.
El motivo es texto obligatorio hasta500 caracteres Unicode y la evidencia escrita
es opcional hasta1000. No se adjuntan archivos ni se copian puntos/fotos privados
del recurso a la denuncia. Es una entrega de recepción, sin decisión automática,
ocultamiento, bloqueo de usuarios, apelaciones o bandeja administrativa.

`content_reports` conserva UUID de envío, actor autenticado, clase/UUID del
recurso, motivo, evidencia y fecha del servidor. La RPC serializa la orden y
devuelve el recibo original ante el mismo reintento. Contenido incompatible
produce conflicto y otro actor no puede reutilizar la orden. El recibo permanece
consultable/repetible tras retirar el recurso; un envío nuevo exige visibilidad.
No se añade una clave foránea polimórfica que elimine la evidencia con el recurso.

RLS y revocación de grants impiden lecturas/escrituras directas, incluso a
service_role. `read_content_report` solo permite al denunciante consultar su
propio envío o a un revisor asignado explícitamente por servidor. La tabla
`content_report_reviewers` no admite autoasignación ni usa metadatos editables
del usuario. No se crea ningún revisor por defecto. La gestión operativa de
revisores/cola pertenece a las siguientes historias de moderación; esta entrega
solo establece y prueba la autorización de lectura, sin pantallas ficticias.

## Arquitectura y experiencia

`content_reports` separa dominio/caso de uso/repositorio, fuente/DTO/repositorio,
providers declarativos y pantalla/estado/ViewModel autoDispose. Bootstrap/main
inyectan implementaciones. App/router compone slots en fichas/revisión, sin
imports de presentation/data entre funcionalidades. Servidor autoriza cada envío.

CaseScreenShell conserva glass, cabecera, cover/stagger; campos/contadores,
ValidationSurface, toast, skeleton y shimmer son compartidos. La confirmación
solo aparece tras recibo persistido. Durante respuesta ambigua se congelan UUID y
contenido; reintento conserva ambos y bloquea doble envío. Salir con borrador o
resultado ambiguo requiere confirmación. Cambio/error de sesión oculta datos y
descarta respuestas tardías; recuperación de la misma cuenta crea estado limpio.

## Consecuencias y validación

Plan029/fuentes099–101 después de028 confirmado por el usuario. Migración/patch
se generan mediante scripts versionados; run_all se regenera y prueba repetible.
No se modifica SQL028 aplicado. Firebase/FCM está fuera del alcance por ADR-068
y ratificación expresa del usuario; no forma parte de activación ni aceptación.

Pruebas locales: límites Unicode, permisos, denegación de escalada, lectura de
revisor/revocación, UUID estable/conflicto, recurso retirado, ciclo de vida intacto,
sesión/disposición, navegación real y renders normal/pequeño con texto ampliado.
PGlite usa una conexión; las solicitudes simultáneas se encolan y no certifican
contención hosted multiconexión. Resultados finales en ESTADO.
