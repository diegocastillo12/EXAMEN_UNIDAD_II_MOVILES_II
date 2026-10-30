# ADR-136: estadísticas agregadas del piloto y permiso de administrador

Fecha: 24/10/2026, America/Lima. Estado: aceptada para implementación por el
usuario. Trazabilidad: HU-16.1 / RF-35 / #50; épica HU-16 / #16.

## Contexto y decisión

Después de integrar HU-15, el usuario autoriza avanzar con las estadísticas.
Se implementa `/administracion/estadisticas` exclusivamente en Nuxt, dentro
de la aplicación existente. No entrega controles de HU-16.2/#51.

`platform_administrators` declara el permiso independiente de
`content_report_reviewers`: un moderador no hereda administración ni viceversa.
Asignación solo mediante operación privilegiada de servidor; no hay pantalla,
endpoint, metadata editable ni seed que otorgue el permiso. La política global
SSR/cliente incorpora `administrator`; cada consulta vuelve a autorizarse en SQL.
Cookies/tokens conservan sus contratos y no se amplían perfiles públicos.

`statistics` organiza contratos/casos de uso, DTO/repositorios/fuentes y ViewModel.
Plugins y Nitro componen las dependencias. Inicio compone el acceso por un slot
de AccountScreen, sin imports entre presentaciones de funcionalidades.

La RPC recibe fechas inclusivas de calendario, de 2000 a 2099, con máximo366 días.
Las convierte en `[inicio, día siguiente al fin)` en America/Lima y devuelve
solo siete conteos y el período/zona. Una sentencia usa la misma instantánea
para todas las métricas. Se cuentan eventos registrados, no fechas declaradas
de desaparición/avistamiento. Borradores y preparaciones nunca son publicaciones.

El usuario confirma expresamente esta clasificación para estadísticas:

- Recuperación: recibo `case_closures`, en su `closed_at`. No inferir de resolved.
- Cancelación: retirada de una publicación sin recuperación registrada.
- Archivo: retirada posterior a una recuperación registrada.

Cancelación/archivo usan `deleted_at`; la existencia de un recibo anterior o
simultáneo determina la clasificación. No modifica estados operativos ni inventa
motivos históricos. Una recuperación y su archivo pueden corresponder a períodos
distintos; no son categorías sumables como casos únicos. Las publicaciones se
cuentan aunque después se retiren u oculten. No se atribuye la recuperación a
Entre Huellas. No se reconstruyen recuperaciones antiguas sin recibo.

## Consecuencias y verificación

Plan039/fuentes125–127 generan migración y patch039, sin reescribir historial.
Tabla de permisos con RLS y sin acceso directo de clientes; RPC autenticadas
con comprobación de pertenencia y search_path vacío. Ningún grant de lectura
de casos privados adicional. JWT de usuario exclusivamente en servidor Nuxt.

La UI reutiliza marca, títulos, fechas, skeleton, toast, shimmer y expansión
desde origen existentes; se verifica esta integración y no se declara auditoría
global ni aprobación visual del usuario.

Pruebas SQL reproducibles de permisos, repetición, límites y conteos; pruebas
de dominio/DTO/ViewModel/transporte y servidor Nuxt construido; navegador normal,
reducido, responsive y texto ampliado. La validación alojada requiere aplicar039,
asignar una cuenta administradora explícitamente y contrastar datos reales.
El cierre de #50 queda pendiente de activación/demo e integración.
