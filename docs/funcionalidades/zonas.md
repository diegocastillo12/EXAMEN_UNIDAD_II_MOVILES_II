# Ubicaciones de interés privadas

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

Corrección20/10/2026: la consulta conserva el subárbol de transición al resolver
datos, vacío o error; skeleton sin cortina/stagger y resultado sin segunda
entrada. Cambios lista/editor conservan cover/stagger y edición/refresh mantienen
su comportamiento.24 regresiones nuevas compartidas con preferencias; suite
ampliada61/61 con fondo animado desactivado para pumpAndSettle y análisis limpio.
Sin cambios de persistencia/permisos. Evidencia en [ESTADO](../ESTADO.md);
revisión Android autenticado pendiente.

**Auditoría de seguimiento18/10:** HU-02.1/#26 y épica #2 en Done: implementación integrada,010 confirmado y evidencia posterior. No se conserva integración en main como pendiente. El seguimiento de ubicaciones corresponde a HU-12 y no bloquea esta entrega de configuración.

18/10/2026: HU-12 añade Seguir zona/Dejar de seguir por slot compuesto en router,
sin importar presentation de notifications. Zona existente no se sigue de forma
automática. Eliminada deja de seleccionar destinatarios; preferencias siguen
controlando recepción. [Seguimiento y alertas](seguimiento-y-alertas.md);027 pendiente.

Recarga por gesto (ajuste16 de octubre): indicador reutiliza GlassSurface52/radio26/icono28 igual al retorno. Conserva gesto/giro/retirada y bloqueo al editar. Formato/análisis sin incidencias; sin pruebas/renders por instrucción vigente, revisión Android pendiente.

Refinamiento del gesto: icono de recarga sigue el jalón, gira durante actualización real y retorna al terminar/cancelar, con movimiento reducido respetado. Edición conserva bloqueo de gesto. [ADR-049](../decisiones/049-indicador-recarga-y-retorno.md). Análisis estático sin incidencias; sin nuevas pruebas por instrucción del usuario, pendiente revisión Android.

Actualización del15 de octubre: jalar desde el borde superior y soltar reemplaza Actualizar ubicaciones. Lista conservada con ContentRefresh, sin franja fina anterior; gesto disponible con vacío/lista corta y deshabilitado durante edición, guardado/eliminación o refresh. Reintentos conservados. [ADR-048](../decisiones/048-actualizar-listas-al-jalar.md). Formato/análisis sin incidencias; sin pruebas ejecutadas por instrucción del usuario, gesto Android pendiente.

Ajuste del15 de octubre: por instrucción del usuario, etiquetas y mensajes Zona/Zonas pasan a Ubicación/Ubicaciones. Se conservan módulo/rutas/contratos/datos/reglas de esta ficha; el archivo mantiene su enlace. Solo formato/análisis, sin ejecutar pruebas por instrucción vigente. [ADR-047](../decisiones/047-ubicacion-actual-y-radio-inicial.md).

Cambio visual del 15 de octubre de 2026: por instrucción explícita del usuario,
ZoneMapPicker deja de mostrar el texto de atribución y su botón/enlace en todas
sus instancias (zonas, formularios y fichas de reportes). Se eliminan las opciones
de configuración de ese texto/enlace. El proveedor de teselas sigue siendo el
existente; sus condiciones de atribución quedan pendientes de resolver antes de
distribuir, según CONFIGURACION. Selección, círculo y reintento se conservan.

Módulo: `interest_zones`. HU-02.1 / RF-02,16;
[issue #26](../backlog/026-HU-02.1.md).

## Qué hace y cómo se usa

Desde Perfil se consultan, crean, editan y eliminan zonas propias. Cada zona
tiene nombre, centro y radio. El usuario toca el mapa para elegir el punto,
puede mover/zoom y ve el círculo de alcance. También puede introducir coordenadas
manualmente, incluso si falla el servicio de mapas.

No requiere permiso GPS ni obtiene ubicación del dispositivo. Lima es el
encuadre inicial del mapa, no una posición inferida ni guardada automáticamente.
Las zonas no se asocian a una mascota concreta ni publican coordenadas de casos.

## Reglas y persistencia

Nombre obligatorio de1–60 puntos de código; latitud −85..85, longitud −180..180
y radio100–50000 metros. Se exige seleccionar un punto explícito y rechazan
valores no finitos. Dominio y SQL comparten estos límites.

Las RPC obtienen la cuenta de la sesión, usan UUID estable y versión esperada.
El reintento idéntico reconoce el resultado sin duplicar ni incrementar de nuevo;
el incompatible produce conflicto. Eliminación conserva una marca para impedir
que un envío antiguo recree la zona. Datos privados y sin escritura directa cliente.

Error conserva el borrador. Consultar versión actual o descartar cambios requiere
confirmación cuando se perdería edición. Refresco conserva contenido con progreso;
cambio de cuenta oculta datos previos. No existe cola offline persistente.

## Dependencias y validación

Patch010, repositorio Supabase y mapa flutter_map con proveedor configurable.
La selección por coordenadas permite continuar sin teselas; no hay seguimiento
GPS, descarga masiva de mapas ni búsqueda geográfica de casos en este incremento.
El usuario reportó aplicación del parche y validación de HU-02 en ESTADO;
consultar allí la evidencia concreta, sin convertirla en prueba de casos/alertas.

Comprobar persistencia, edición/eliminación, coordenadas manuales, conflictos y
aislamiento entre cuentas. [ADR-018](../decisiones/018-zonas-manuales-privadas.md),
[ESTADO](../ESTADO.md) y [CONFIGURACION](../CONFIGURACION.md).


## Reutilización visual — 10 de octubre de 2026

Confirmaciones delegadas al diálogo completo confirmActionDialog de core, con acciones de geometría/alineación y adaptación compartidas, sin layouts propios. En reportes, terminar carga conserva la entrada del skeleton y no dispara cover/stagger nuevos; vista previa y confirmación conservan su transición. Validación local y límites en ESTADO; no cambia persistencia/permisos ni cierra la historia remota.


## Área inferior del scroll — 10 de octubre de 2026

El layout utiliza ScrollSafeArea compartido: contenido visible hasta el borde inferior, espacio del gesto dentro del padding final y acciones flotantes protegidas. No se recorta el viewport dejando una franja blanca fija. Teclado conserva acceso a campos/acciones. No cambia persistencia ni operaciones; [ADR-025](../decisiones/025-scroll-continuo-area-gesto.md) y ESTADO registran pruebas locales y comprobación nativa pendiente.

## Corrección de consistencia — 11 de octubre de 2026

Carga, selección de campos/punto, guardado y eliminación usan toast, marcas invalid y shake. Decoración y superficie de mapa compartidas; acciones de reintento/conflicto se conservan.

Carga mediante skeleton/shimmer y refresh conservado sin indicadores circulares/lineales. Véanse [ADR-027](../decisiones/027-feedback-global-toast-shimmer.md), [ADR-028](../decisiones/028-consistencia-fronteras-y-reutilizacion.md) y [ESTADO](../ESTADO.md) para evidencia local y pendientes. Esta corrección no cierra por sí sola la HU ni acredita pruebas remotas/Android autenticadas.
