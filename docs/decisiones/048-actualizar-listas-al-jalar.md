# ADR-048: actualizar listas al jalar hacia abajo

Estado: aceptada por instrucción explícita del usuario, 15 de octubre de 2026.

Actualización20/10 por petición explícita: Inicio también habilita el gesto.
Recarga real del perfil de cabecera mediante callback inyectado por router a
HomeScreen; ProfileViewModel reutiliza ReadProfile. HomeViewModel coordina
duplicados y fallo/reintento con toast, ignorando errores tras cambiar sección.
Avatar conserva datos durante refresh de la misma identidad. Las tarjetas
editoriales siguen fijas; no hay temporizadores de carga simulada. Esta nota
sustituye la exclusión anterior de Inicio. Sin nuevo dominio, SQL o permisos.

Actualización visual: [ADR-049](049-indicador-recarga-y-retorno.md) sustituye la flecha por icono de recarga con seguimiento/retorno y giro durante actualización real. Se conserva integración, callbacks y alcance de esta decisión.

## Decisión y recorrido

Se retira el icono de actualizar de Explorar y el botón ordinario Actualizar ubicaciones. Explorar, Mis mascotas (Activas/Archivadas) y Ubicaciones de interés actualizan al jalar hacia abajo desde el borde superior y soltar al alcanzar el umbral. AlwaysScrollableScrollPhysics permite hacerlo con pocos elementos o vacío; soltar antes del umbral cancela sin consultar. No se pretende refrescar formularios, gestos horizontales ni scroll de desplegables/mapas.

PullToRefresh compartido usa RefreshIndicator.noSpinner para reconocer el gesto, con flecha que cambia de orientación al armarse y LoadingShimmer durante trabajo real. Sin spinner, barra de progreso o texto visible de carga. Movimiento reducido respetado y acción semántica Actualizar contenido para accesibilidad. El contenido conserva datos y geometría durante refresh mediante los ViewModels y ContentRefresh/PetRefreshProgress existentes. En ubicaciones se sustituye además la franja fina anterior por ContentRefresh sobre la lista.

Explorar conserva centro/radio/filtros y renueva la primera página. Mis mascotas refresca exclusivamente la lista seleccionada y espera su Future real. Ubicaciones conserva sus datos y deshabilita el gesto mientras hay borrador, guardado/eliminación u otra actualización. Se mantienen acciones Reintentar/recuperación ante fallos; no se convierten formularios en superficies de refresco. Inicio sin colección remota no registra una acción ficticia.

## Fronteras y ciclo de vida

El scroll principal pertenece a HomeScreen; PullToRefreshTarget permite a la funcionalidad visible registrar un callback de su ViewModel mediante un scope compartido de presentación. Core no conoce features/providers/repositorios. La inscripción pertenece al widget, se retira al desmontar y no elimina una inscripción más reciente. La superficie de Inicio se identifica por sección para descartar el gesto al cambiarla. Ubicaciones usa el mismo componente con callback directo sobre su scroll propio.

Se atienden solo notificaciones verticales del scroll principal, profundidad0 y gesto desde el borde. No se duplican solicitudes durante una operación. Los ViewModels conservan sus validaciones de identidad, descarte de respuestas y feedback superior de fallos. Sin cambios de dominio, API, SQL, permisos, persistencia o filtros.

## Validación

Formato y flutter analyze --no-pub sin incidencias. Después de añadir la acción semántica, dart analyze del componente compartido sin incidencias tras incorporar su import explícito. Por petición del usuario no se ejecutan pruebas ni renders/build. Pendiente Android: umbral/cancelación, listas vacías/cortas/largas, Activas/Archivadas, filtros y paginación, errores, cuenta/sección, movimiento reducido, accesibilidad y ausencia de captura de gestos anidados.
