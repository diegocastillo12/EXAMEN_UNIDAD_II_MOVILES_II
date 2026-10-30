# ADR-027: feedback global en toast y carga con shimmer

Estado: aceptada por instrucción explícita del usuario. Fecha: 11 de octubre de 2026.

## Motivo

El usuario pide resolver las inconsistencias actuales y extiende la indicación de ADR-023 a toda la app: errores, validación y resultados en el toast superior, sin mensajes debajo de inputs ni loaders convencionales.

## Decisión

ConfirmationToastHost es el único lugar para mensajes de operaciones y validación en acceso, recuperación, onboarding, perfil, mascotas, zonas, preferencias y reportes. Los inputs mantienen invalid, borde danger, semántica y ShakeField; su API compartida ya no acepta errorText. No se añaden helperText ni textos explicativos de validación debajo. Las etiquetas, contadores interiores, estados confirmados e instrucciones de privacidad siguen describiendo el producto.

La carga inicial usa skeleton con LoadingShimmer. Las acciones conservan su etiqueta con shimmer solo durante una operación real. ContentRefresh conserva contenido y geometría durante refresh explícito, aplica shimmer y mantiene la semántica del contenido; no lo anuncia como botón. Se prohíben indicadores circulares y lineales de progreso en presentación. Movimiento reducido conserva el efecto estático.

El toast pertenece al ciclo de vida de la pantalla y se elimina al corregir el estado, cerrar, caducar o desmontar. Notices repetidos requieren una identidad nueva. El área del aviso está acotada por el espacio del overlay y teclado; mensajes largos con texto ampliado se recorren mediante scroll con scrollbar visible. El aviso se cierra tocando su superficie; no ocupa toda la pantalla. Las acciones de reintento se conservan.

## Consecuencias y comprobaciones

Sustituye las restricciones contextuales de ADR-005/007/009/013/016/023 y el indicador fino de ADR-011 en materia de feedback/carga; no altera reglas de dominio, permisos ni estados de producto. Las decisiones anteriores conservan su historia. architecture_test recorre también core e impide errorText/helperText e indicadores de progreso convencionales. Se comprueban errores, reintento, limpieza, geometría, texto ampliado y movimiento reducido; evidencia en ESTADO.
