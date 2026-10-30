# Activar inicio de sesión con Facebook

Incremento solicitado el 17 de octubre de 2026: HU-01 / RF-01,34,
issue #1 (no es una historia nueva). Código Flutter preparado; activación
de Meta/Auth y prueba Android real pendientes.

## Cómo funciona en Entre Huellas

Continuar con Facebook abre la autorización web mediante Supabase Auth.
Facebook devuelve la autorización al servidor; Supabase la valida y devuelve
la sesión a `entrehuellas://login-callback/`. La app observa esa sesión y
aplica el onboarding por cuenta existente. Abrir el navegador no concede acceso.

Se reutilizan SignIn, repositorio, fuente Supabase y ViewModel del login.
No se incorpora SDK nativo de Facebook ni una contraseña de Facebook a Flutter.
No se requieren migraciones SQL nuevas para elegir otro proveedor de Auth;
perfil/onboarding dependen de los contratos ya instalados.

## 1. Crear la aplicación en Meta

En [Meta for Developers](https://developers.facebook.com/apps/), crear una app
de Entre Huellas con el caso de uso de autenticación mediante Facebook Login.
Los nombres del panel pueden variar. Habilitar `public_profile` y `email` para
pruebas: Supabase necesita el correo. No solicitar acceso a publicaciones,
amigos ni otros datos ajenos al inicio de sesión.

En Facebook Login → Settings → Valid OAuth Redirect URIs registrar exactamente
el callback del Auth autohospedado del proyecto:

```text
https://entrehuellas-supabase.kormind.com/auth/v1/callback
```

Confirmar que sigue siendo el dominio público efectivo del servidor antes de
guardarlo. Este callback es distinto del enlace móvil: Meta vuelve al servidor,
y el servidor vuelve a la app. No autorizar la ruta duplicada
`/auth/v1/auth/v1/callback` detectada anteriormente con Google.

Obtener **App ID** y **App Secret** en Settings → Basic. El secreto se introduce
solo en el panel privado del servidor; no pegarlo en el chat, Git ni dart-define.

## 2. Configurar Supabase en Dokploy

Esta instalación es autohospedada. En el Compose existente, dentro de
`services.auth.environment`, añadir estas entradas conservando las demás:

```yaml
GOTRUE_EXTERNAL_FACEBOOK_ENABLED: "true"
GOTRUE_EXTERNAL_FACEBOOK_CLIENT_ID: ${FACEBOOK_CLIENT_ID}
GOTRUE_EXTERNAL_FACEBOOK_SECRET: ${FACEBOOK_SECRET}
GOTRUE_EXTERNAL_FACEBOOK_REDIRECT_URI: https://entrehuellas-supabase.kormind.com/auth/v1/callback
```

En Environment privado de Dokploy, definir `FACEBOOK_CLIENT_ID` con el App ID y
`FACEBOOK_SECRET` con el App Secret. Verificar que Compose los transmite al
servicio Auth: añadirlos solo al panel no los incorpora automáticamente.
El callback explícito evita depender de una concatenación de API_EXTERNAL_URL.
No modificar a ciegas esa variable compartida.

Conservar `entrehuellas://login-callback/` en `GOTRUE_URI_ALLOW_LIST` junto a los
retornos existentes. Aplicar/recrear el servicio Auth cuando se autorice el
despliegue; no hace falta reinstalar la base de datos. Esta tarea no ha accedido
a Dokploy ni ha modificado su configuración.

Si en otro entorno se usa Supabase administrado, activar Facebook en
Authentication → Sign In / Providers con App ID/App Secret, copiar su callback
real a Meta y añadir el retorno móvil en URL Configuration → Redirect URLs.

## 3. Probar y habilitar para usuarios reales

En modo Development de Meta, añadir una cuenta con rol de prueba y aceptar la
invitación. Comprobar en Android: autorizar, regresar, completar onboarding,
cerrar sesión y volver a entrar. Una cuenta que ya completó onboarding debe
volver a Inicio; otra nueva debe ver las tres etapas.

Comprobar también cancelación/permiso denegado, falta de correo confirmado,
proveedor deshabilitado, red interrumpida y retorno con la app abierta/cerrada.
Ante fallo no debe aparecer una sesión ni filtrarse detalles del SDK; debe
permitirse reintentar. Probar cuentas existentes con el mismo correo para
verificar el comportamiento real de vinculación de Auth, sin fusionar perfiles
por nombre ni prometer equivalencia entre correos distintos.

Antes de abrirlo al público, completar los requisitos que muestre Meta:
política de privacidad pública, instrucciones de eliminación de datos y demás
campos requeridos; revisar disponibilidad de los permisos para usuarios sin rol
y publicar la app en Live. Meta puede exigir revisión/verificación según el
caso y permisos. No se han creado ni publicado esos documentos en esta tarea.

## Evidencia y límites

Las pruebas locales verifican selección del proveedor, URL/retorno móvil,
ausencia de sesión al abrir OAuth, error de lanzamiento y reintento, bloqueo
de envíos y layout normal/pequeño con texto ampliado. No sustituyen la prueba
real de Meta, correo, callback ni permisos entre cuentas. Consultar
[ESTADO](ESTADO.md) para el resultado ejecutado y
[la ficha de acceso](funcionalidades/acceso.md) para el recorrido completo.

Referencias consultadas el 17 de octubre de 2026:
[Facebook en Supabase](https://supabase.com/docs/guides/auth/social-login/auth-facebook),
[OAuth autohospedado](https://supabase.com/docs/guides/self-hosting/self-hosted-oauth).
