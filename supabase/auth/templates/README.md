# Correos de verificación por código

Plantillas de Confirm signup (`confirm_signup.html`) y Reset password (`recovery.html`) para Entre Huellas. Usan `{{ .Token }}`: Auth genera/valida el código; Flutter nunca lo genera ni lo calcula. No contienen enlaces de confirmación.

Estos archivos son fuentes versionadas, no acreditan despliegue. En Supabase administrado se puede revisar/copiar cada cuerpo en su plantilla de Auth. En el servicio autohospedado con Dokploy, servir cada HTML desde una URL accesible por el contenedor Auth y configurar `GOTRUE_MAILER_TEMPLATES_CONFIRMATION` y `GOTRUE_MAILER_TEMPLATES_RECOVERY` con las URLs reales; no usar rutas de Windows como URLs. Verificar que Compose transmita esas variables antes de redesplegar el servicio. No hay URLs de hosting inventadas en este incremento.

El servicio debe generar seis dígitos (`GOTRUE_MAILER_OTP_LENGTH=6` en la configuración efectiva de Auth autohospedado). Mantener caducidad y límites de envío/verificación en servidor. Los límites del cliente no reemplazan esos controles. Si el correo actual ya muestra un código de seis dígitos, la app puede verificarlo sin instalar estas plantillas; estas simplifican la orientación al usuario.

Referencias: [variables de plantilla](https://supabase.com/docs/guides/auth/auth-email-templates), [plantillas autohospedadas](https://supabase.com/docs/guides/self-hosting/custom-email-templates), [configuración de Docker](https://github.com/supabase/supabase/blob/master/docker/CONFIG.md). Procedimiento y pruebas remotas pendientes en [CONFIGURACION.md](../../../docs/CONFIGURACION.md).
