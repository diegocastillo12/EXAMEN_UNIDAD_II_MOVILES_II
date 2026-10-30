# ADR-111: títulos principales compartidos en móvil y web

Fecha:20/10/2026. Estado: aceptada por instrucción explícita del usuario.

Excepción posterior explícita: [ADR-120](120-restaurar-hero-original-landing.md)
restaura solo #hero-title de landing a su composición original Arial500,
oscuro y tamaño adaptable hasta108px, con mascotas laterales originales.
Sustituye para este título las reglas generales indicadas a continuación.

Excepción local20/10/2026, por petición explícita: el nombre de la ficha del
caso sobre fotografía conserva su diseño anterior a ADR-111: fuente del sistema,
blanco, tamaño48/peso800, altura1.05 y sombra negra suave, máximo dos líneas con
elipsis. Sin cápsula blanca. Solo CasePublicationPreview; los demás títulos
conservan Poppins400/32/gris. Acciones, panel y datos intactos.


Refinamiento posterior20/10: por petición explícita, CollectionHeader ancla sus
títulos al borde superior de la fila, como «Su regreso» en Inicio. Se conserva
la altura mínima56 y el espacio de acciones. Explorar y Mis mascotas comparten
el origen superior/lateral de Inicio también con texto ampliado; sin offsets
negativos ni ajustes independientes por pantalla. Sustituye para estas cabeceras
la nota inferior que dejaba la alineación dependiendo del centrado de la fila.

## Decisión

Todos los títulos principales de pantalla, página y etapa usan **Poppins Regular
400, tamaño base32, gris #454746, interlineado1.25 y tracking0**. En Flutter son
32 unidades lógicas con TextScaler; en web2rem (32px con raíz16), respetando la
ampliación del navegador. No reducir el tamaño en pantallas pequeñas: permitir
saltos de línea y scroll. No imponer mayúsculas ni truncar el título principal.

Aplica a Inicio, Explorar, Mis mascotas, Guardados, listados, formularios,
perfil, preferencias, ubicaciones, fichas, acceso y onboarding móvil; y a los
h1 de landing, acceso, onboarding, cuenta, moderación, QR, avistamientos y
documentos legales web. La regla sustituye los pesos500/700 y los tamaños
especiales48/36 de estos títulos, incluidos los anteriores ADR-074/105.

La marca oficial «entre huellas» es un recurso de identidad, no un título de
página: conserva su lettering. Se conserva el énfasis aprobado de Inicio
«empieza contigo», Poppins600 con degradado #459FF6→#75C9EF, y el mismo tamaño.
Subtítulos, encabezados de tarjetas/diálogos, etiquetas de mapa/navegación,
botones, campos, cuerpo y carteles PDF conservan su jerarquía existente.
No convertir todos los textos grandes o todos los h2 en títulos principales.

## Implementación

Flutter centraliza el estilo en AppTypography.primaryTitle. Lo consumen
CollectionHeader, EntityScreenShell, AppPageLayout, tema y cabeceras específicas.
Guardados lo recibe a través de EntityScreenShell. El nombre principal en el
preview sobre fotografía se muestra directamente sobre la imagen, sin cápsula
blanca ni padding adicional, por corrección explícita posterior del usuario.
Por la excepción posterior explícita, recupera el estilo original blanco48/800
con sombra y máximo dos líneas con elipsis; conserva el scroll del panel.

Nuxt registra typography.css globalmente y sirve Poppins local con licencia
OFL, copiada del mismo archivo móvil. Un único selector para h1 de reader-shell
y landing-page consume tokens de tipografía; se retiran overrides por recorrido,
incluidos legales y responsive. Preload local compartido en SSR, sin proveedor
remoto de fuentes, SDK nuevo ni modificación de acceso/autorización.

Se documenta la misma regla en AGENTS y ambas normas UI/UX. Comprobaciones de
paridad y revisión de layouts con texto ampliado previenen divergencias.

## Consecuencias y validación

Un cambio de tipografía puede cambiar el ajuste de líneas; conservar scroll,
acciones, marca estable, semántica y movimiento reducido. Esta decisión no
unifica márgenes superiores ni tamaños de filas de cabecera: la alineación
vertical sigue dependiendo de su composición.

No añade funcionalidades, HU/RF/issues, datos, permisos ni despliegue. La ficha
de identidad visual y ESTADO registran validación local y revisión física pendiente.
