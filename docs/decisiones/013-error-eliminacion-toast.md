# ADR-013: errores de eliminación en toast superior

Fecha: 9 de octubre de 2026. Estado: aceptada por instrucción explícita del usuario.

El usuario rechaza el error textual bajo una mascota tras intentar eliminarla y solicita usar el toast existente. Se extiende el alcance de ADR-007/009 únicamente a fallos de eliminación de mascotas; los demás errores/validaciones conservan su feedback contextual de ADR-005.

PetsSection presenta fallo o éxito mediante ConfirmationToastHost, sin texto ni bloque de error bajo la fila. Fallo genérico indica reintento al deslizar. En conflicto, el toast informa que la ficha cambió e incluye Actualizar lista, que invoca la recarga del ViewModel. La mascota permanece visible tras fallo y la confirmación previa a borrar sigue siendo obligatoria. No se reemplaza el error por éxito ni se oculta un conflicto.

Cada resultado tiene noticeId para anunciar también errores consecutivos aunque las transiciones de trabajo terminen antes del siguiente frame. El toast conserva posición superior, icono de error, cierre al tocar, expiración, accesibilidad, movimiento reducido y disposición por pantalla/identidad. La acción opcional cierra el aviso antes de recargar. Nunca utilizar SnackBar ni barra inferior equivalente.

La confirmación usa dos botones de geometría y tipografía compartidas: mínimo 48, fuente 14/peso 600, radio 18, padding 8. Anchos iguales, fila si caben; con texto ampliado se apilan y comparten altura suficiente para no truncar etiquetas. Cancelar mantiene borde neutro; Eliminar mascota usa danger suave. La diferencia de importancia se comunica por color, no por tamaño.

Validar cancelación, confirmación real, fallo/reintento, avisos repetidos, acción de conflicto y limpieza del overlay; revisar capturas normal/pequeña con texto ampliado. Sin cambios en autorización, repositorios o SQL.
