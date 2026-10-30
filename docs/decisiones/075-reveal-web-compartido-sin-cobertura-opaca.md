# ADR-075: reveal web compartido sin cobertura opaca

Fecha: 19/10/2026. Estado: aceptada por corrección explícita del usuario.

## Problema

El usuario reporta un rectángulo crema antes del stagger en Inicio y exige
corregir su origen compartido. La utilidad global .reveal::before pintaba
#fffbeF durante240ms; ocho grupos de inicio, moderación, QR y avistamientos
seguían usándola tras las correcciones individuales de login/onboarding.

## Decisión

Retirar la utilidad .reveal, su pseudo-elemento y los keyframes cover/arrive.
StaggerReveal comparte useStaggerReveal (opacidad, blur y desplazamiento;
850ms y separación90ms) para las entradas generales. Conserva la etiqueta
HTML original, clases, eventos y formularios nativos. Captura solo los hijos
directos de la entrada: editar, actualizar o añadir contenido no repite el efecto.
Login y onboarding conservan sus grupos explícitos y parámetros aprobados del
mismo composable. Cabeceras persistentes permanecen fuera de la animación.

No crear capas de color que tapen contenido para revelar la web. Esta decisión
sustituye cover→stagger de ADR-006 para estos recorridos web; Flutter conserva
su implementación y la landing su clip-path aprobado, sin cobertura opaca.
Movimiento reducido muestra contenido inmediatamente. El QR SSR sin JavaScript
activa una hoja externa mediante noscript para mantener el contenido visible,
respetando CSP sin habilitar estilos inline. Cancelar frames/watchers al desmontar.

## Consecuencias y validación

Sin cambios de negocio, permisos, persistencia, backend ni Flutter.
Guardia automática impide reintroducir clases .reveal y la antigua utilidad.
QA de navegador debe observar fotogramas intermedios, ausencia de pseudo-capa,
orden del stagger, movimiento reducido, responsive, SSR sin JS, actualizaciones
y envío nativo de formularios. Se registra evidencia ejecutada en ESTADO.
