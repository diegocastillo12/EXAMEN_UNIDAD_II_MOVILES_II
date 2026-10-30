# ADR-001: arquitectura de la aplicación

Estado: adoptada. Fecha: 7 de octubre de 2026.

## Contexto

Entre Huellas combina registro de mascotas, casos perdidos y encontrados, avistamientos, seguimiento y recuperación. Los mismos datos participan en varios recorridos y están sujetos a permisos distintos: responsable de una mascota, colaborador, visitante del QR y moderador.

El sistema debe distinguir información pública y privada, conservar borradores sin conexión y tolerar reintentos sin duplicar publicaciones. Estas necesidades afectan las reglas del producto, el acceso a datos y el estado que muestra la aplicación. Su implementación se incorpora por sprints; el diseño debe permitir añadirlas manteniendo una separación clara entre esas responsabilidades.

La aplicación Flutter ya existe en `apps/mobile`. El backend acordado es Supabase. La estructura debe conservar ese proyecto y permitir probar el cliente sin depender de una cuenta o de la disponibilidad del servidor.

## Decisión

Se adopta **Clean Architecture por funcionalidad**, con **MVVM en presentación**, casos de uso en dominio y repositorios/fuentes de datos en data. Riverpod gestiona estado e inyección; go_router gestiona navegación. Supabase se integra mediante adaptadores de datos y se inicializa en bootstrap.

Las operaciones del producto siguen este recorrido:

```text
Pantalla → ViewModel → Caso de uso → Repositorio → Fuente de datos
```

El contrato del repositorio pertenece al dominio. Su implementación y el acceso al SDK pertenecen a data. Bootstrap construye las implementaciones y las inyecta. Los detalles de organización y los límites obligatorios están en [ARQUITECTURA.md](../ARQUITECTURA.md) y [REGLAS_ARQUITECTURA.md](../REGLAS_ARQUITECTURA.md).

## Motivos

### Las reglas del producto deben tener un lugar propio

Publicar un caso, revisar un avistamiento y cerrar una búsqueda son operaciones con reglas y resultados distintos. Los casos de uso permiten expresar esas operaciones y probar su lógica sin widgets ni clientes de Supabase. Las restricciones críticas, como un único caso perdido activo por mascota o la autorización de un cierre, se verifican también en el servidor.

### La interfaz cambia a un ritmo distinto al acceso a datos

Una pantalla puede cambiar su diseño, navegación o mensajes mientras conserva la misma operación de negocio. MVVM separa esas decisiones: la pantalla renderiza y el ViewModel coordina acciones, carga, resultado y error. Esto permite revisar el comportamiento de la interfaz sin mezclar consultas o reglas de persistencia.

### El cliente necesita combinar datos remotos y locales

Los borradores y envíos pendientes requieren almacenamiento local; los datos publicados y permisos dependen del servidor. Los repositorios ofrecen un contrato estable para coordinar esas fuentes. La incorporación prevista de SQLite/Drift queda en data y conserva los límites del dominio y de la UI. Idempotencia y validación de reintentos siguen siendo responsabilidades compartidas con el servidor.

### Los SDK y sus formatos deben quedar encapsulados

Las fuentes de datos concentran llamadas a Supabase. Los DTO representan sus proyecciones y se convierten en entidades antes de entregarse al dominio. Los errores externos se traducen a fallos con significado para la aplicación. Así se evita que una pantalla dependa de tokens, mensajes del proveedor o formatos de respuesta.

### Las pruebas necesitan dependencias sustituibles

La inyección por constructor y providers permite sustituir repositorios o fuentes para comprobar estados, errores y cancelación de suscripciones. Las pruebas unitarias se complementan con pruebas de UI, integración y permisos reales. Poder ejecutar una prueba local no acredita que las políticas remotas estén configuradas correctamente.

### La organización debe acompañar los recorridos del sistema

Agrupar por funcionalidad mantiene juntos los componentes de acceso, mascotas, casos o avistamientos. Las capas dentro de cada funcionalidad hacen explícitas sus dependencias. Los componentes comunes se extraen cuando tienen un uso compartido concreto; esto evita convertir `core` en un módulo que concentre todo el producto.

Riverpod permite utilizar el mismo mecanismo para inyección y estado de presentación. Supabase reúne los servicios de autenticación, base de datos y almacenamiento acordados para el sistema. Se mantiene un backend central mientras los adaptadores delimitan lo que conoce el cliente.

## Alternativas consideradas

| Alternativa | Evaluación |
| --- | --- |
| Llamar a Supabase desde las pantallas | Acopla interfaz, persistencia y formatos externos. Dificulta probar reglas y añadir almacenamiento local. |
| MVVM con acceso directo del ViewModel al repositorio | Reduce intermediarios. En este proyecto se eligen casos de uso para dar una ubicación consistente a operaciones que cruzan recorridos y tienen reglas propias. |
| Carpetas globales de pantallas, modelos y servicios | Separa tipos de archivos, pero distribuye una misma funcionalidad por toda la aplicación. Se elige agrupar primero por funcionalidad y después por capa. |
| API propia desde el inicio | Añade servicios y operación de infraestructura. Se reserva para una necesidad que el backend acordado no resuelva y que justifique una decisión nueva. |

## Consecuencias y límites

- La estructura añade contratos, archivos y mapeos. Su costo se acepta para mantener reglas y dependencias comprobables; se crean componentes cuando tienen una responsabilidad concreta.
- Los cambios de contratos pueden afectar casos de uso, implementaciones y pruebas. Se revisan juntos para conservar su comportamiento.
- Las pantallas estáticas pueden seguir siendo widgets simples. No requieren clases vacías para completar el árbol de carpetas.
- Las pruebas de dependencias detectan parte de las desviaciones; la revisión debe comprobar también responsabilidades, comportamiento y permisos.
- Encapsular Supabase reduce el impacto de sus detalles en el cliente. Sustituir el backend seguiría requiriendo adaptadores, migraciones, políticas e integración; no sería un cambio automático.
- La organización del código ayuda al mantenimiento. Rendimiento, concurrencia, índices, almacenamiento y entrega de notificaciones requieren validación propia conforme se incorporen los flujos.

## Seguimiento

La base de sesión ya utiliza estos límites. Cada incremento debe cumplir las reglas de arquitectura y registrar su evidencia en [ESTADO.md](../ESTADO.md). Los flujos de mascotas, casos, QR, notificaciones y offline se incorporan según [GUIA_MVP.md](../GUIA_MVP.md).

Una modificación de esta decisión se registra en una nueva ADR que indique qué decisión sustituye, el motivo y la transición necesaria. Las normas, la descripción de arquitectura y las comprobaciones afectadas se actualizan en el mismo incremento.
