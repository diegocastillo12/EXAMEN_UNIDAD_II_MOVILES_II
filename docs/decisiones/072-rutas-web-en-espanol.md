# ADR-072: rutas web visibles en español

Fecha:19/10/2026. Estado: aprobada; login y legales migrados por ADR-073.
Autoridad: instrucción explícita del usuario. Complementa ADR-058/063/071.
Sin nueva HU, RF o issue ni cierre de historias.

## Contexto y alternativas

Entre Huellas se dirige a usuarios hispanohablantes. La plataforma combina
rutas visibles en inglés (/login, /terms, /privacy) y español (/moderacion).
Se considera mantener inglés, traducir todos los contratos técnicos o separar
las rutas de navegación de los contratos de integración. Se adopta la última
alternativa para dar coherencia a la navegación y conservar compatibilidad.

## Decisión

Las rutas de navegación visibles de apps/platform se escriben en español,
en minúsculas, con guiones entre palabras, sin tildes ni ñ. Los parámetros
conservan sus identificadores opacos; no se traducen IDs, UUID ni tokens.
La raíz / sigue siendo la landing pública.

| Recorrido | Ruta canónica objetivo |
| --- | --- |
| Iniciar sesión | /iniciar-sesion |
| Crear cuenta | /crear-cuenta |
| Inicio de usuario | /inicio |
| Explorar | /explorar |
| Mis mascotas | /mis-mascotas |
| Ficha de mascota | /mascotas/:id |
| Mis reportes | /mis-reportes |
| Perfil | /perfil |
| Moderación | /moderacion |
| Administración | /administracion |
| Términos | /terminos |
| Privacidad | /privacidad |

La tabla fija nomenclatura cuando se implemente cada recorrido; no autoriza
crear páginas vacías ni afirma que las funciones de usuario/administración
estén implementadas. Las rutas no conceden permisos: se mantienen las
comprobaciones de sesión, propiedad y rol en servidor en cada operación.

Código, identificadores de base de datos y endpoints internos pueden permanecer
en inglés, conforme a sus convenciones actuales. Se conserva /c/:token como
contrato público QR corto. Los endpoints /api, callbacks OAuth y deep links
móviles son contratos de integración; no se traducen por esta regla ni se cambian
sus cookies, scopes, parámetros o allowlists implícitamente.

## Transición y consecuencias

Actualización19/10: [ADR-073](073-acceso-general-web-y-gestion-por-permisos.md)
implementa /iniciar-sesion, /terminos y /privacidad, con redirecciones308 desde
/login, /terms y /privacy. /inicio y /bienvenida son recorridos reales de cuenta;
los demás ejemplos de la tabla siguen siendo nombres objetivo al implementarse.
El texto siguiente describe el alcance documental original de esta decisión.

Esta decisión es documental: no cambia rutas ni despliegues ahora.
Cuando se migren /login, /terms y /privacy, sus equivalentes canónicos serán
/iniciar-sesion, /terminos y /privacidad. Conservar redirecciones desde las
rutas anteriores, los parámetros necesarios del flujo (por ejemplo reason)
y destinos fijos internos, sin redirecciones externas controlables por usuario.
Actualizar conjuntamente enlaces, navegación, middleware, retornos de sesión,
respuestas de callback y pruebas que dependan de las rutas cambiadas.
Las notas históricas conservan las rutas comprobadas en su fecha; no se deben
reescribir como si la migración ya hubiera ocurrido.

## Validación

Este incremento comprueba coherencia documental, enlaces locales nuevos y
git diff --check. No requiere build ni pruebas de aplicación al no cambiar código.
La futura migración deberá verificar navegación directa, redirecciones antiguas,
parámetros de error/cancelación/cierre, login/logout/expiración, retorno OAuth,
documentos legales, SSR y autorización. La evidencia local se distinguirá de
la confirmación remota. No hay cambios SQL, asignación de roles o despliegue.
