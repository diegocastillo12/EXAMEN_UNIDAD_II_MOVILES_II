# Casos guardados

24/10, HU-15.3: Guardados incorpora por composición Consultados en este dispositivo,
independiente de favoritos remotos. Las fichas abiertas se conservan con datos/fotos
públicos por cuenta para consulta sin red; marcar favorito por sí solo no descarga
una ficha no consultada. Las notas anteriores sin descarga offline son historia
previa a este incremento. [Contrato/evidencia](fichas-sin-conexion.md).

Título principal20/10/2026: Poppins Regular400, base32 y gris #454746 mediante
el estilo global; sustituye tipografía anterior de cabeceras principales.
Reglas y validación en [identidad visual](identidad-visual.md) y
[ADR-111](../decisiones/111-titulos-principales-poppins-mobile-web.md). Sin cambios
de recorrido, datos, permisos o activación; revisión física Android pendiente.

Confirmación del usuario16 de octubre: patch021 aplicado y recorrido de guardar/Guardados probado con resultado correcto («ya esta el patch ese, si permite guardar ya lo probe y todo esta bien»). Sustituye el pendiente de activación021 en notas anteriores; evidencia comunicada por el usuario, sin inspección remota independiente ni certificación adicional de permisos/concurrencia.

Corrección de recarga16 de octubre: PullToRefresh usa Stack sin recorte para que el indicador glass que entra desde coordenadas negativas no quede cortado durante el descenso/retirada. En Home envuelve toda la composición, incluida LiquidNavigation, y pinta el indicador al final sobre cabecera/contenido/acciones. Sin cambiar gesto, material o tiempos. Formato y análisis estático sin incidencias; sin pruebas/renders/build por instrucción vigente, revisión visual Android pendiente.

Corrección16 de octubre: el guard de sesión del router omitía /home/saved-cases y redirigía a /home al pulsar el marcador. Se permite explícitamente esa ruta solo cuando EntryDestination.home está resuelto; acceso/onboarding/recuperación mantienen sus controles. Se conserva OriginPageTransition existente. Formato y análisis estático de router sin incidencias; sin pruebas por instrucción del usuario y sin verificación Android. Pendiente revisar apertura/retorno en dispositivo;021 sigue pendiente para cargar el listado.

Ajuste vigente del16 de octubre: el marcador compacto de Explorar abre la pantalla independiente Guardados en /home/saved-cases. Reutiliza OriginPageSource/OriginPageTransition mediante entityEditorPage: expansión desde el icono y retorno al origen al cerrar, con movimiento reducido respetado. Sustituye el cambio de vista en la cabecera y la segunda pulsación. SavedCasesScreen reutiliza EntityScreenShell con retorno glass y cover→stagger, SavedCasesSection y PullToRefresh; scroll siempre desplazable incluso con lista vacía. Explorar permanece debajo con filtros/posición conservados. Sin cambios SQL;021 sigue pendiente de aplicación y revisión Android.

Módulo saved_cases. Ampliación explícita del16 de octubre de2026 de HU-07/RF-13, sin issue asignado. Patch020 aplicado según confirmación posterior del usuario; sin comprobación remota independiente ni historia cerrada. [ADR-050](../decisiones/050-casos-guardados-por-cuenta.md).

## Qué hace y recorrido

**Recorrido vigente:** Explorar → marcador pequeño junto al título → Guardados. Sin selector de secciones; marcador lleno y título Guardados, segunda pulsación vuelve a Explorar conservando filtros cercanos. Misma grilla, páginas20/Ver más, jalar para actualizar y apertura de ficha; al volver se refresca para reflejar guardados retirados. Solo cuenta actual y casos todavía visibles, sin filtro de radio/GPS. Estado de error distinto de vacío; datos conservados en refresco. Requiere nuevo [patch021](../../database/patchs/021_patch_saved_case_list.sql) tras020; no aplicado aún. [ADR-051](../decisiones/051-guardados-en-explorar-y-ciudad-con-sugerencias.md) amplía el recorrido inicial solo por ficha. Sin pruebas ejecutadas por instrucción vigente; validación remota/Android pendiente.

Entrar a una ficha pública disponible muestra marcador glass arriba a la derecha. Vacío: Guardar caso; lleno: Quitar de guardados. Estado consultado por cuenta al abrir y cambio confirmado únicamente tras servidor. Se recupera al volver/reiniciar una vez activado020. Disponible en origen lost/found, incluidas búsquedas comunitarias y avisos anteriores. El listado de021 no añade seguimiento/push ni descarga offline. Guardar no garantiza acceso posterior a un caso retirado/oculto.

## Reglas y campos

Referencia origen de almacenamiento + UUID, marca saved y versión; ausencia false/versión0. Elección independiente por cuenta. No guarda datos de mascota, fotos, coordenadas ni documentos; sin contadores públicos. Botón glass52, tooltip/semántica, shimmer real y sin reiniciar animación del contenido.

## Persistencia y permisos

Tabla Supabase saved_cases, RLS/grants de propietario y RPC autenticadas read_saved_case/set_saved_case, sin DML directo cliente. Guardar verifica proyecciones vigentes, sin ampliar permisos de resueltos/retirados. Clave incluye origen; quitar conserva tombstone/versionado y borrar cuenta elimina marcas.

## Errores y reintentos

Toast superior. Fallo de lectura permite reconsulta, sin cambiar estado desconocido. Fallo de escritura conserva marca confirmada y estado deseado/versión para repetir sin duplicar. Conflicto requiere reconsulta. Bloqueo de doble envío y descarte de respuestas de otra identidad/desmontaje. Sin éxito simulado ni reintentos automáticos/offline.

## Dependencias y activación

Requiere sesión y secuencia001–019; activar [migración020](../../supabase/migrations/20261016002000_saved_cases.sql) o [patch020](../../database/patchs/020_patch_saved_cases.sql). Fuentes070–073/plan020, generadores Build-SavedCasesPatch/Build-RunAll. Router compone botón mediante slots, SDK en data_sources e inyección bootstrap/main. Sin020 el marcador informa error de consulta.

## Validación y pendientes

Formato/análisis Flutter sin incidencias y SQL generado. Por petición del usuario no se ejecutan pruebas SQL/Flutter ni builds/renders. Aplicación de020 confirmada por el usuario, sin inspección remota del agente. Pendientes permisos A/B/anónimo, visibilidad/concurrencia/repetición, reinicio/cuenta, error/reintento y revisión Android/pequeño/texto ampliado; [ESTADO](../ESTADO.md). No cierra HU-07/HU-12/HU-15.3.
