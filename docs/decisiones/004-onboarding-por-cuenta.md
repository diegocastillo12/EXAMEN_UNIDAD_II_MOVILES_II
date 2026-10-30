# ADR-004: onboarding después de autenticar, persistido por cuenta

Estado: adoptada. Fecha: 7 de octubre de 2026.

Actualización del recorrido, 8 de octubre de 2026: por instrucción del usuario se retira Omitir. La decisión inicial de permitir omitir queda sustituida por avanzar hasta la tercera etapa y usar Comenzar. Se conserva la RPC, la finalización por cuenta y el historial existente; no se reinician fechas ya guardadas. Tres indicadores muestran progreso sobre una acción de ancho completo con flecha derecha. Las pruebas de omisión pasan a verificar finalización desde la última etapa y reintento ante fallo.

## Contexto y decisión

El usuario establece login como primera pantalla y un onboarding de tres etapas después del primer ingreso. Se elimina la bienvenida pública y la pantalla intermedia “Tu cuenta”. Una sesión restaurada puede abrir directamente el destino que corresponde a la cuenta.

La finalización se registra en `public.profiles.onboarding_completed_at`. “Omitir” y “Comenzar” consumen el mismo caso de uso y RPC. Solo la sesión propietaria puede completarlo, con fecha generada en servidor; la llamada repetida conserva la fecha. No se concede actualización directa de esa columna. Si no se completó ni omitió, el siguiente ingreso vuelve a ofrecerlo: salir de la app a mitad no lo marca finalizado.

El router usa el estado de un ViewModel de entrada para proteger login/onboarding/app. Una lectura fallida no se interpreta como finalización ni permite saltar al inicio. Un guardado fallido mantiene la pantalla con reintento. El estado está asociado a la cuenta; otras cuentas del mismo teléfono conservan su propio recorrido.

## Motivos y consecuencias

Un indicador local por instalación se perdería al reinstalar y podría mezclar cuentas. El perfil remoto conserva el criterio entre dispositivos. Esta consulta añade un estado breve de carga y necesita conexión para confirmar el recorrido; el manejo offline general permanece en su sprint.

Las ilustraciones son tres PNG independientes derivados del mockup mediante image_gen, según la revisión visual solicitada por el usuario. La referencia y prompts se conservan con los assets; reemplazan los recortes previos del tablero. Los textos y controles son widgets reales. La marca compartida se mantiene en core. No se añaden entidades vacías para un resultado booleano ni lógica del SDK en presentación.

Las cuentas existentes sin fecha verán este onboarding una vez hasta completarlo u omitirlo. No se infiere finalización de la fecha de creación de Auth ni de un número de inicios de sesión.

La evolución SQL se guarda en 008–009 y una nueva migración. Se amplía expresamente la generación repetible de ADR-003 sin modificar el historial inicial. La activación remota requiere aplicar el SQL actualizado.

## Validación

Pruebas de navegación por sesión/cuenta, recorrido de tres etapas, omitir, reintentos, regreso de una cuenta completada, sesión restaurada y texto ampliado. Pruebas PostgreSQL locales de RPC, aislamiento y prohibición de reiniciar la fecha. Capturas de las tres páginas y evidencia real en ESTADO; ejecución remota/Android pendiente salvo lo informado por el usuario.
