# ADR-087: registro y recuperación por código en la web

Fecha: 19/10/2026. Estado: aceptada por autorización explícita del usuario.

## Contexto

El acceso web general incluía login/OAuth/cierre/onboarding, pero faltaban los
recorridos ya existentes en móvil para crear cuenta, confirmar correo y recuperar
contraseña. El usuario autoriza trasladarlos conservando cuenta/datos y UI web.
Incremento HU-01/RF-01,34; no implica cerrar historias ni paridad global web/móvil.

## Decisión y fronteras

Rutas /crear-cuenta y /recuperar-contrasena con política guest, y
/restablecer-contrasena con política recovery. Todas se registran en la política
única de ADR-079; middleware servidor y cliente validan antes de montar el destino.
El puente de sesiones antiguas acepta estos destinos guest mediante una lista
cerrada, sin URL externas. Una cuenta autenticada conserva onboarding por cuenta.

CredentialScreen observa CredentialViewModel; los casos de uso concretos validan
nombre<=120, correo<=254, contraseña8–1024 sin trim, coincidencia y código6 cifras.
Los repositorios/fuentes encapsulan Auth HTTP (signup, verify, resend, recover,
GET/PUT user) con clave publicable solo en servidor. Nombre se guarda como
full_name mediante el mismo contrato/trigger de móvil. No se crean usuarios con
API administrativa ni se asignan roles. La composición reside en plugin/utilidad
servidor; dominio no conoce Vue, Nitro ni SDK. DTO elimina tokens/atributos extra.

Registro confirmado establece la cookie general existente después de revalidar
usuario y perfil. Acepta también sesión directa si Auth tiene autoconfirmación.
Sin sesión confirmada se presenta código; correo existente conserva resultado
pendiente indistinguible. Recuperación no revela la existencia del correo.

La cookie eh_credentials es HttpOnly, SameSite=Strict, path / y Secure en HTTPS,
cifrada AES-GCM con AAD distinto al de eh_access/moderación. Guarda email,
propósito, id aleatorio, espera de reenvío y vencimiento local. Tras verify de
recovery guarda el token exclusivamente en esa cookie; nunca crea eh_access.
El JSON solo proyecta progreso/email/id/fechas, sin tokens. No se serializa el
progreso en SSR ni en almacenamiento del navegador. Las contraseñas/códigos
permanecen en el formulario y se limpian al avanzar/salir; no van a ViewModels.

Pendiente dura máximo30min; capacidad de cambio máximo10min, limitada por el
JWT de Auth. Son límites locales, no una afirmación del vencimiento del OTP.
El cambio exige propósito/id correctos, capacidad vigente y usuario Auth del
mismo actor. Confirmar o cancelar borra la cookie e intenta cerrar esa sesión.
Login, OAuth confirmado y logout retiran cookies de flujo anteriores. La salida
local no promete revocación inmediata de JWT; los vencimientos de Auth rigen.

## Feedback, reintentos y alternativas

Se elige código como móvil, reutilizando plantillas con .Token y sin callback
nuevo o enlaces que transporten tokens en la URL. Conservar callback OAuth
existente. No migrar los recorridos a SDK cliente, localStorage o service_role.

UI reutiliza marca responsive de acceso, fondo frío/orbe, LoginInput, GlassNavigationButton,
StaggerReveal, skeleton, ActionButton/shimmer y TopToast; no mensajes de error
bajo inputs ni acciones vacías. Marca fuera del stagger, scroll/texto ampliado y
movimiento reducido. Reenvío espera60s y se valida también contra cookie en
servidor; Auth y rate limits siguen siendo autoridad. No reintentar escrituras
automáticamente; error conserva etapa/entrada y permite reintentar explícitamente.
Una respuesta perdida tras confirmar puede dejar OTP consumido o contraseña ya
cambiada: ofrecer regreso al login/reenvío, sin afirmar rollback ni idempotencia.
Una pestaña con id anterior recibe conflicto sin borrar el flujo más reciente.

## Activación y validación

Sin SQL, variables nuevas, Flutter, cambios de SMTP o despliegue. Reutiliza
SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, MODERATION_SESSION_SECRET y PUBLIC_WEB_ORIGIN.
Auth debe permitir registro/correo, contraseña>=8, OTP6, SMTP/plantillas existentes.
Pendiente demo con correo real y configuración efectiva; no se contactó Auth remoto.
Pruebas de dominio/repositorios/VM, endpoints de producción, política SSR/SPA y
Chrome con fixture; resultados y límites exactos en ESTADO.

Referencias primarias contrastadas: [verifyOtp](https://supabase.com/docs/reference/javascript/auth-verifyotp),
[contrato Auth](https://github.com/supabase/auth/blob/master/openapi.yaml),
[plantillas](https://supabase.com/docs/guides/auth/auth-email-templates).
