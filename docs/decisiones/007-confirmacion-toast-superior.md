# ADR-007: confirmación de éxito con toast superior propio

Fecha: 8 de octubre de 2026. Estado: aceptada por instrucción explícita del usuario.

## Contexto y decisión

El usuario rechaza el texto permanente «Perfil actualizado.» bajo Guardar cambios y solicita un toast propio para confirmar acciones. Esta instrucción sustituye la prohibición general de toast de ADR-005 únicamente para confirmaciones de éxito. SnackBar y barras inferiores equivalentes siguen prohibidos; errores y validación permanecen junto al campo/acción y no desaparecen por temporizador.

Crear ConfirmationToastHost en core/presentation: aviso flotante superior con estética iOS solicitada por el usuario: cápsula de ancho ajustado al texto, cristal claro neutro, icono y texto carbón #24282A, sin X visible. Se cierra al tocarlo o mediante acción semántica de dismiss. Perfil lo utiliza con «Cambios guardados» solo cuando el servidor confirmó persistencia. Se retira el texto de éxito del flujo del formulario y no se cambia su altura por la confirmación.

Duración normal 3 segundos, 6 con accessibleNavigation; entrada local de 180 ms mediante fade/desplazamiento leve, sin movimiento con animaciones desactivadas. Respeta margen superior del sistema, ancho máximo 360, texto ampliado y liveRegion. La animación local del aviso no sustituye cover/stagger de pantalla ni reinicia sus efectos.

## Ciclo de vida y límites

La pantalla posee overlay y timer. Mostrar una sola vez al pasar de operación no confirmada a confirmada, nunca por reconstrucción o carga de datos ya guardados. Nueva edición retira la confirmación anterior; cierre, desmontaje o cambio de identidad elimina overlay/timer. No almacenar avisos globales ni arrastrarlos a otra cuenta/pantalla. No requiere paquetes externos y no expone respuestas del SDK.

Se aplica ahora a éxito de edición de Perfil; no se reemplaza automáticamente feedback de otros flujos, errores o confirmaciones que requieren acciones posteriores. La separación de dominio/infraestructura/presentación y la regla de carga con shimmer no cambian.

## Verificación

Comprobar éxito tras servidor, ausencia en fallos, no duplicación por rebuild, cierre/expiración y limpieza al desmontar. Revisar normal/pequeño con escala 2, movimiento reducido, contraste y aviso fuera del flujo. Mantener comprobación automática que prohíbe el componente inferior y sus APIs. Actualizar AGENTS, reglas UI/arquitectura y diseño/estado junto con esta decisión.

## Ampliación explícita: error de foto

ADR-009 sustituye la limitación de este documento solo para fallos de foto de perfil, por solicitud posterior del usuario: el mismo toast superior muestra icono de error, mensaje seguro y guía para reintentar desde avatar. No muestra check de éxito. Los demás errores/validación permanecen contextuales; ciclo de vida, expiración, no repetición por rebuild y limpieza por pantalla se conservan.
