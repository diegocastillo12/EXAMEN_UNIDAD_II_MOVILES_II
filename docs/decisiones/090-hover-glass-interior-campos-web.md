# ADR-090: hover glass fino en campos web

Fecha: 19/10/2026. Estado: aceptada por petición explícita del usuario.

El usuario pide un hover glass delgado para los inputs. Se define una sola
regla de presentación en reader-shell para campos de texto, textarea y select:
borde #8FA9C4, reflejo blanco/azulado e iluminación inset2px.
No cambia fondo base, dimensiones, padding, etiquetas ni iconos; no hay halo
exterior. Transición180ms en borde/sombra, respetando movimiento reducido.

Se limita a hover:hover/pointer:fine y campos habilitados, editables, sin error
y sin foco. Al enfocar prevalece el contorno interior de ADR-089. Disabled,
readonly, errores, checkbox/radio/range/file y dispositivos táctiles conservan
sus estados. Landing queda fuera de reader-shell y conserva su estilo.

Se evita duplicar estilos por funcionalidad o añadir backdrop-filter al campo:
un reflejo interior fino satisface la petición sin alterar superficies o capas.
Sin cambios de dominio, datos, accesibilidad de foco, Flutter o despliegue.
Build y QA de navegador/estados se registran en ESTADO.

Corrección posterior del usuario19/10: el primer hover era casi imperceptible.
Se aumenta contraste del borde (antes #CAD6E3), ribete de1 a2px y opacidad del
reflejo, con azul visible al extremo inferior. Mantener las mismas exclusiones,
geometría y prioridad de foco/error; no añadir sombra externa.
