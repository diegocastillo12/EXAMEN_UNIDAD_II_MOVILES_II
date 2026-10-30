# ADR-089: foco interior en los campos web

Fecha: 19/10/2026. Estado: aceptada por referencia explícita del usuario.

El usuario conserva la señal de foco pero pide que crezca hacia dentro del campo,
sin el aro exterior separado. La referencia solo define el foco; no se copian
el tema oscuro ni el corte de borde de su etiqueta.

main.css declara en reader-shell outline2px/#3C537B con offset−2px para inputs
de texto, textarea y select con focus-visible. aria-invalid=true usa #B53F48.
Se retira el offset exterior específico de LoginInput; todos sus recorridos
heredan la regla. Checkbox/radio/range/file y botones/enlaces conservan su foco.
El outline no modifica ancho, alto, padding ni posición del contenido. La
landing conserva sus estilos propios al quedar fuera de reader-shell.

Se prefiere outline con offset negativo a aumentar border-width, que podría
cambiar el área de contenido, y a eliminar el foco accesible. En colores
forzados el navegador conserva la representación nativa del outline.

Validación de build, foco por clic/teclado, geometría estable, color de error
y revisión visual móvil/escritorio registrada en ESTADO. Sin cambios de datos,
sesión, Flutter, SMTP, despliegue o cierre de HU.
