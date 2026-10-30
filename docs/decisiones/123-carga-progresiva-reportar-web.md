# ADR-123: carga progresiva del formulario Reportar web

Fecha: 21/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Contexto y decisión

Reportar ocultaba el formulario completo hasta terminar de restaurar el borrador
y obtener, conjuntamente, mascotas y búsquedas abiertas. Una sola lectura lenta
retrasaba campos estáticos y el montaje del mapa. El usuario autoriza mostrar
el formulario tras comprobar acceso, con carga independiente por componente.

RecoveryScreen conserva la política global previa de cuenta/onboarding. Una vez
montada, muestra el formulario y monta LocationMap; inicia las dos lecturas remotas
y la restauración local en paralelo. Solo durante la restauración local los
campos están deshabilitados para evitar sobrescribir ediciones con un borrador
tardío. El mapa mantiene su skeleton/reintento en el adaptador compartido.

RecoveryViewModel coordina los casos de uso existentes con estado separado de
mascotas y búsquedas: petición activa, lectura confirmada, datos y fallo. Entrega
cada resultado al llegar; un fallo no equivale a lista vacía. FieldSkeleton
compartido ocupa únicamente el selector pendiente. Una actualización conserva
su contenido con shimmer; el reintento vuelve a consultar solo esa fuente,
con bloqueo de duplicados y aviso de error por toast superior.

Los campos de texto, fecha/hora y tipo de reporte no esperan a listas remotas.
Publicar requiere la lista pertinente: mascotas para pérdida propia, búsquedas
para avistamiento/custodia, ninguna de ambas para pérdida comunitaria. La
validación de campos y autorización del servidor siguen en los contratos
existentes. El reintento congelado de una publicación ambigua conserva su payload.

Guardar borrador conserva referencias/versiones/fotos restauradas mientras
su metadata remota no llegó, sin inventarlas ni usarlas para omitir permisos.
Los datos confirmados sustituyen esa metadata al estar disponibles. Respuestas
tardías no restauran datos después de desmontar/cambiar identidad o confirmar
una publicación; los errores de fuentes pendientes no invalidan un recibo guardado.

## Alcance y consecuencias

Solo presentación/estado de Reportar en apps/platform; Explorar y Mis mascotas
conservan su carga existente. Sin nueva caché, SQL, endpoints, permisos, guard por
pantalla ni cambios de Flutter. La transición desde origen y el sistema de
sesión preparado de ADR-121 permanecen. La red puede seguir demorando acceso o
datos; este cambio evita que una lectura independiente bloquee todo el formulario.

## Validación

64 pruebas locales, typecheck y build correctos. Chrome con backend fixture
retiene mascotas, búsquedas y módulo Leaflet a la vez: permite editar campos
antes de liberarlos, entrega mascotas sin esperar búsquedas, monta mapa de forma
independiente y reintenta solo una lista fallida. Verifica preservación de edición,
borrador restaurado/versiones/fotos,390/320px y ausencia de fallos CSP/hidratación.
Regresión de recuperación confirma publicación de los cuatro tipos, fotos,
borrador y reintento ambiguo. No acredita latencia real del backend remoto ni
Safari/Firefox/dispositivos físicos. Evidencia y siguiente paso en ESTADO.
