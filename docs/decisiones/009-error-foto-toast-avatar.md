# ADR-009: foto desde avatar y fallo con toast superior

Fecha: 8 de octubre de 2026. Estado: aceptada por instrucción explícita del usuario.

El usuario solicita retirar Añadir/Cambiar foto y el mensaje permanente bajo esa acción. Perfil usa únicamente el avatar de 72 con distintivo de cámara y etiqueta accesible para abrir galería. LoadingShimmer cubre ese control durante selección/subida, sin acciones duplicadas. Si la subida falla y conserva bytes, tocar el avatar reintenta el mismo objeto; si no hay selección válida, abre galería de nuevo. El formulario conserva nombre/ciudad/correo.

Por autorización explícita, se amplían ADR-005/007 solo para errores de foto de perfil: usar el componente superior existente con icono de error danger suave y mensaje seguro, sin marca de éxito. Se limpia al reintentar/cambiar cuenta/cerrar pantalla y expira como el toast existente; un nuevo fallo después de reintento se anuncia otra vez. Sin mensajes del SDK, SnackBar ni barra inferior. Los demás errores y validaciones permanecen contextuales.

La recuperación excepcional de selección Android mantiene Guardar foto recuperada/Descartar: no publicar automáticamente una selección pendiente al iniciar. Estos controles no aparecen en el estado habitual. La recuperación conserva ese carácter explícito también ante fallo de su envío.

Comprobar selección/reintento desde avatar, bloqueo de duplicados, aviso de error fuera del layout y expiración, éxito solo tras respuesta confirmada, limpieza por identidad/desmontaje y renders normales/pequeños con texto ampliado. No altera Storage, SQL ni el alcance de HU-01.7.
