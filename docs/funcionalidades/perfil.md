# Perfil y fotografía de cuenta

21/10: Perfil web recupera expansión/retorno desde el avatar,320/260ms,
easeInOutCubic y fases de OriginPageTransition móvil, según regla global
[ADR-124](../decisiones/124-paridad-animaciones-mobile-web.md). El contenido se
conserva hasta finalizar cierre; foco/scroll y cancelaciones verificados con
fotogramas normales, además de movimiento reducido. Consulta/datos intactos.

21/10, web: cabecera de Inicio/Explorar/Mis mascotas/Reportar con avatar circular
y panel glass Tu cuenta. Muestra nombre, correo y ciudad reales de sesión;
consulta la foto almacenada en profile-avatars mediante proxy privado del mismo
origen, sin URL firmada/token cliente ni publicación de teléfono/perfil. No
espera esa foto para mostrar la cabecera; iniciales mientras llega o si falta.
El proxy valida identidad/onboarding/actor y limita ruta/tamaño/JPEG. Sin foto
guardada no usa URLs externas de redes sociales. Esta entrega es de consulta,
no incorpora edición/foto/ciudad/teléfono web. Datos privados y consentimiento
por caso conservados. Evidencia local en ESTADO; sin cambios SQL ni despliegue.

Selector20/10, ADR-117: el celular usa bandera/prefijo y número nacional separados mediante InternationalPhoneField compartido. Perú inicial para vacíos, búsqueda por país/ISO/prefijo y pegado internacional. Guarda el mismo número completo privado; sin nuevo SQL. Prefijos compartidos sin país identificado muestran globo hasta elegir. Validación y Android en ESTADO.

Celular20/10, [ADR-116](../decisiones/116-celular-privado-perfil-y-sugerencia-contacto.md):
campo opcional privado con código de país (+ y8–15 dígitos). Normaliza espacios,
guiones/paréntesis; vacío elimina el valor. Se guarda con nombre/ciudad y se conserva
al cambiar foto, descartar, reintentar y cambiar sesión según el estado existente.
No es un número verificado por SMS. La instrucción de privacidad permanece visible.

Sirve como sugerencia al autor en [Contacto del reportante](contacto-reportante.md),
sin activar publicación/foto automáticamente. Modificar/eliminar el celular del
perfil no modifica contactos ya publicados; se editan/retiran por ficha.
Plan033/fuentes112–114, patch033 después de032 (contacto por caso requiere031).
Activación remota y Android físico pendientes. Pruebas/resultados en ESTADO.

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

20/10/2026: el gesto de actualización de Inicio recarga el perfil mediante
ProfileViewModel.retry/ReadProfile existentes, esperando el resultado real.
Avatar conserva información durante refresh explícito de la misma cuenta;
Inicio gestiona el fallo con toast y Reintentar. Sin nuevo contrato/backend.
Prueba de consulta e iniciales conservadas aprobada, además de8 pruebas de
perfil. Fixtures de toast esperan6500ms más animación. Android pendiente.

**Auditoría de seguimiento18/10:** HU-01.7/#23 en Done: edición/foto/ciudad y reglas de acceso entregadas e integradas, con regresiones y CI aprobados. Se retira la nota inicial de falta de PR/integración; no se afirma una escritura remota nueva ni una inspección hosted durante la auditoría.

Confirmación posterior16 de octubre: Flutter38946521408 de c727b2f pasa en Linux con339 pruebas, incluidos guardado de perfil y navegación normal/pequeña que fallaban antes. Se sustituye el pendiente de CI de la nota siguiente; no equivale a comprobación de permisos o guardado remoto de perfil.

Validación16 de octubre: se corrigen fixtures de CI para seleccionar Cusco con selectCity antes de comprobar fallo/reintento de guardado, e inyectar GPS de prueba al recorrer Explorar→Perfil. Se conserva la validación de ciudad y el feedback de producción.18 pruebas de perfil/navegación/Explorar y suite completa339 aprobadas localmente; CI Linux pendiente de volver a ejecutar al publicar. Véase ESTADO para evidencia y límites.

Ciudad (16 octubre): reutiliza places, el mismo autocompletado de Ubicación en modo ciudad. Debounce600ms/mínimo3, selección obligatoria para texto nuevo; vacío opcional y valor antiguo sin cambiar conservados. UpdateProfile recibe citySelected explícito; edición/guardado/foto/fallo conservan esa condición y Descartar restituye valor/limpia sugerencias. Guarda nombre/región/país≤120, sin coordenadas nuevas ni cambios SQL del perfil. Router compone el widget por slot, sin import de otra presentación. No es validación de catálogo oficial en servidor. Formato/análisis sin incidencias; sin pruebas ejecutadas por instrucción del usuario, cobertura/Android pendientes. [ADR-051](../decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md).

Ajuste del15 de octubre: acceso visible Ubicaciones de interés en lugar de Zonas de interés; rutas y permisos conservados. Formato/análisis, sin nuevas pruebas por instrucción del usuario. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

Módulo: `profile`. HU-01.7 / RF-01; [issue #23](../backlog/023-HU-01.7.md).

## Qué hace y cómo se usa

Desde el avatar se accede al perfil. Permite consultar el correo de la sesión,
editar nombre visible, ciudad y celular de contacto opcional, elegir una foto propia desde galería y acceder
a zonas de interés y preferencias de alertas. El correo es de solo lectura.
La fotografía de cuenta es independiente de las fotos de cada mascota.

## Reglas, persistencia y errores

Nombre y ciudad son opcionales, de hasta120 puntos de código Unicode cada uno;
se recortan extremos y un vacío se guarda como null. UpdateProfile escribe
nombre, ciudad y celular y comprueba que la fila confirmada corresponda a la cuenta.
No permite editar propietario, roles ni finalización de onboarding.

La selección de imagen se normaliza a JPEG y se limita a2MiB. El avatar se
guarda en Storage privado y se muestra mediante acceso autorizado; la recuperación
de una selección interrumpida se vincula a la misma cuenta. No se transfieren
pendientes de imagen a otro usuario al cambiar sesión.

Carga inicial mediante skeleton; refresco conserva contenido con progreso fino.
Errores, validación y resultados usan toast superior compartido y ShakeField según
ADR-027. El éxito se anuncia tras confirmación. Los cambios se conservan para
reintentar cuando corresponde y se descartan resultados tardíos de otra identidad.

## Dependencias y validación

ReadProfile, UpdateProfile y ChangeProfilePhoto consumen repositorios; las fuentes
encapsulan Supabase y selección nativa. Los enlaces a zonas/preferencias los
compone el router. Depende de SQL de perfil/avatar y reglas privadas de Storage.

Verificar actualización, galería cancelada/interrumpida, sesión A/B y reapertura.
Validación acreditada y pendientes: [ESTADO](../ESTADO.md).
Decisiones: [ADR-008](../decisiones/008-avatar-privado-cuenta.md) y
[ADR-009](../decisiones/009-error-foto-toast-avatar.md).


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Corrección de consistencia — 11 de octubre de 2026

Consulta, edición, errores de campos y cierre de sesión usan toast. La preparación del avatar delega en el normalizador compartido, manteniendo el recorte512 y la recuperación nativa por cuenta.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.

20/10/2026: Ciudad comparte el filtro de sugerencias de Perú (petición PE y
verificación del código recibido). Conserva ciudades anteriores y selección
explícita para texto nuevo. [Ficha](ubicaciones-buscador.md), ADR-107.
