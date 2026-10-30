# ADR-086: fondo móvil compartido con la web interior

La paleta/degradado vertical se sustituye por ADR-088 tras rechazo visual y nueva
referencia del usuario. Se conservan integración, alcance y fronteras descritos aquí.

Fecha:19/10/2026, America/Lima. Estado: implementado localmente por solicitud del usuario.

## Decisión

El usuario extiende a móvil la regla de fondo del resto de la web (ADR-083):
degradado vertical azul pastel #E5EFFF al0%, gris frío #F5F7FA al55% y blanco
#FFFFFF al100%, sin crema. Sustituye el fondo blanco exterior anterior de Flutter.
La landing web conserva su tratamiento propio; no se modifica apps/platform.

AppPageBackground declara una sola paleta/degradado en core/presentation.
AppScaffold pinta esa base detrás de un Scaffold transparente, fuera del ajuste
de teclado y las áreas seguras. Se aplica al arranque Flutter, preparación de
cuenta, acceso/registro/contraseña, onboarding, Inicio, perfil, preferencias,
ubicaciones y EntityScreenShell (mascotas, reportes, guardados, avisos y otras
pantallas existentes). El mapa inmersivo conserva su cartografía por encima;
su carga/error hereda el fondo común. Fotografías y fichas inmersivas conservan
sus superficies; tarjetas, campos, modales, menús y paneles no se recolorean.

CoverReveal usa el degradado compartido; OriginPageTransition interpola desde
el color del control de origen hacia los tres colores finales. Se conservan
duraciones, clip, geometría, navegación, interacción y movimiento reducido.
Las cabeceras siguen fuera del stagger. El fondo base es estático: no se
introducen luces/orbes animados que no existían en móvil; ADR-083 conserva esos
efectos donde ya se usan en web, como capa independiente.

## Límites y validación

Cambio solo de presentación, sin SDK/dependencias, estado, dominio, datos, SQL,
permisos o nuevas HU/RF. No implica cierre de historias. El fondo acompaña el
viewport y no se desplaza con los listados. Con teclado no se recalcula la altura
del degradado, pues se pinta fuera del Scaffold que redimensiona el contenido.
El splash nativo previo a Flutter conserva sus recursos existentes.

Verificar formato/análisis, regresiones existentes de acceso/cuenta/onboarding,
Inicio, arranque, transiciones y arquitectura. Revisar renders390×844 y tamaños
pequeños/texto2 con los harness existentes. Evidencia y límites en ESTADO y
[ficha](../funcionalidades/fondos-mobile.md).
