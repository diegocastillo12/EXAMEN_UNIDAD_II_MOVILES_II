# ADR-023: feedback de reportes en toast superior

Estado: aceptada por instrucción explícita del usuario. Fecha: 10 de octubre de 2026.

## Contexto y decisión

El usuario reiteró «NADA DE TEXTO en la ui todo al toast» mostrando el rechazo de fotos no verificadas bajo Publicar caso. La explicación de un error, validación o resultado debe mostrarse en el toast superior compartido. Esta instrucción sustituye la exigencia anterior de feedback contextual y el criterio de limitar el toast a excepciones enumeradas. Se mantienen etiquetas, datos, instrucciones de privacidad, estados de publicaciones y acciones reales de recuperación.

Este incremento corrige todos los flujos de reportes perdidos/encontrados: formulario, vista previa, publicación, consultas/refresco y fotos. Los campos conservan invalid/ShakeField sin errorText ni mensajes debajo. La confirmación de publicación también usa toast; Ver ficha pública permanece disponible. Las pantallas de otras funcionalidades que todavía usan feedback contextual requieren adaptación a esta norma al intervenir sus flujos; esta entrega no declara completada una migración global.

## Implementación y consecuencias

CaseScreenShell recibe aviso, identificador e indicador de error desde presentación y aloja ConfirmationToastHost fuera de cover/stagger. Los ViewModels conservan sus fallos/errorId y validación; no cambian contratos, permisos ni persistencia. Cada intento fallido puede repetir el aviso; edición/cambio de identidad limpia el estado anterior. Consultas conservan skeleton, datos durante refresh y acciones Reintentar. La imagen fallida conserva espacio con icono y explica el fallo mediante el mismo componente superior.

Overlay, timer, cierre y anuncio accesible siguen el ciclo de vida compartido. Un nuevo aviso sustituye al toast visible, incluso si proviene de otro host de la misma pantalla; retirar el host anterior no cierra el nuevo aviso. Se evita apilar el fallo de foto detrás del rechazo de publicación. El toast no concede publicación ni convierte un fallo de lectura en vacío. No se usa SnackBar ni una barra inferior.

## Validación

Las pruebas de ambos reportes comprueban que el rechazo se presenta fuera del scroll, cierre, expiración y repetición. El rechazo photosUnverified se reproduce expresamente. Comprobación estática impide errorText y Text(FailureLabel) en pantallas de reportes. Renders normales y pequeños con texto ampliado y resultados se registran en ESTADO. La confirmación del usuario sobre patch014 y copia/extracción del paquete no acredita una nueva publicación autenticada ni el reinicio de functions.
