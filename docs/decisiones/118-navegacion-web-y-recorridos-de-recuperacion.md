# ADR-118: navegación web y recorridos de recuperación

Fecha: 20/10/2026, America/Lima. Estado: aceptada por petición explícita del usuario.

## Contexto

El usuario solicita la barra de navegación de móvil en platform y confirma que
también deben incorporarse Explorar, Mis mascotas y Reportar. Sustituye el alcance
anterior limitado al inicio web de ADR-073, sin afirmar paridad completa.

## Decisión

La cuenta web comparte UserNavigation: cápsula glass flotante con Inicio,
Explorar y Mis mascotas, selección azul degradada y círculo independiente de
Reportar con nueve puntos. Se adapta a escritorio y móvil, con nombres accesibles,
tooltip, teclado, área segura y espacio final para que el contenido pueda
desplazarse por encima de la barra. La marca permanece en SiteHeader.
Acceso, onboarding, landing, legales, QR y tarea de moderación conservan sus
recorridos; revisión sigue en Inicio y autorizada por permisos.

Rutas /explorar, /mis-mascotas y /reportar registradas como account en la política
única SSR/cliente. AccountScreen admite contenido por slot, compuesto por páginas:
access no importa presentación de recovery. RecoveryScreen observa su ViewModel;
casos de uso y contratos en shared/features/recovery/domain; adaptadores HTTP e
IndexedDB en data; plugin y utilidades Nitro componen implementaciones.

Explorar entrega lista pública autorizada, filtros y paginación. Mis mascotas
entrega consulta propia, alta, edición y adición de fotos verificadas. Reportar
entrega pérdida propia, posible pérdida, avistamiento y custodia vinculados a
búsqueda existente. Reutiliza RPC/Edge/RLS móviles, LocationMap y feedback
compartidos. No añade SQL ni despliega backend por arrastre.

Cada API revalida cuenta/onboarding. Escrituras y lecturas JSON vinculan actor
esperado; origen y límites se verifican en servidor. Token solo en cookie cifrada
HttpOnly y llamadas servidor-servidor con clave publicable/JWT del usuario.
Las fotos se decodifican y recodifican sin EXIF antes de pasar al verificador
existente. Proxy fotográfico revalida sesión y proyección permitida, sin URLs
firmadas, rutas de almacenamiento ni datos privados en el cliente.

Reportes usan UUID estable y RPC deduplicadas; respuesta incierta congela datos
para reintentar el mismo envío. Guardar borrador es una acción explícita local
en IndexedDB por cuenta, con fotos y mismo UUID; lectura válida hasta siete días.
No es publicación ni sincronización automática. La confirmación remota elimina
el borrador local cuando el almacenamiento está disponible. Navegar con cambios
pendientes requiere confirmar descarte; cierre/recarga usa aviso del navegador.

## Consecuencias y validación

No se entregan por arrastre mapa de resultados, ficha web autenticada completa,
gestión de galería/archivo/baja de mascotas, seguimiento o paridad global con móvil.
La lista propia tiene un límite inicial de 100 mascotas. Las búsquedas disponibles
son las del contrato existente; la autorización de publicación permanece en SQL.

Pruebas unitarias, arquitectura, servidor de producción con backend fixture y QA
Chrome se registran en ESTADO. Falta integración con datos/cuentas reales y revisión
en dispositivos físicos. No hay publicación, migración aplicada ni cierre de HU.
