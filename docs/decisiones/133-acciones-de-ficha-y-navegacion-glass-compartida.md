# ADR-133: acciones de ficha y navegación glass compartida

Fecha: 23/10/2026. Estado: aceptada por instrucción explícita del usuario.
Alcance: presentación Flutter de ficha pública perdida/encontrada; refinamiento
de HU-07/08 y acciones existentes de seguimiento/bloqueo, sin cierre de historias.

## Problema

La ficha usa el botón glass compartido pero fija sus propios offsets laterales8,
frente a24 del shell de entidades. Compartir también se desplaza por el hueco de
Guardar. Reutilizar apariencia no garantiza una posición coherente.

## Decisión

Cabecera con Volver y Compartir únicamente. Favorito pasa al panel Compartir
ficha mediante Añadir a favoritos/Quitar de favoritos; Seguir caso/Dejar de
seguir y Bloquear/Desbloquear se trasladan al mismo panel. Se conserva el panel
blanco opaco sin X, canales sociales, PDF y denuncia con su diseño anterior.
Corrección explícita posterior del usuario: Favoritos/Seguir/Bloquear tienen el
mismo formato que Descargar/Denunciar y van junto a ellos debajo del separador.
PanelActionButton concentra círculo gris56/icono26, tooltip y etiqueta semántica,
sin texto visible. Wrap centra las acciones y permite varias filas en ancho pequeño.
Se conserva scroll y los reintentos de bloqueo también usan este formato.

GlassNavigationBar en core posee la geometría de navegación flotante: margen
superior seguro+4, laterales24 simétricos, acciones alineadas y retorno existente.
CasePublicScreenShell y EntityScreenShell la consumen fuera del scroll y de las
animaciones de contenido. No migra implícitamente todas las pantallas.

Router inyecta widgets por slots; case_posters no importa presentación de guardados,
notificaciones o bloqueos. Las pantallas entregan la elegibilidad de seguimiento
según el tipo real del caso, conservando las condiciones anteriores. Cada acción
reutiliza su ViewModel/caso de uso/repositorio, estados y reintentos. Bloquear
mantiene confirmación y refresco de contactos; no aparece contra uno mismo.

## Consecuencias y validación

Se sustituyen las posiciones y el botón Guardar de cabecera de ADR-113/115;
no cambia SQL, privacidad, contacto, QR ni autorización. Los recorridos Reportar
avistamiento y La vi o la encontré se conservan: la conversación previa no pide
implementarlos de otra forma en este incremento. Sin paridad web nueva.

Validar geometría de ambos shells con insets, estabilidad al hacer scroll,
apertura/cierre del panel, acciones y reintentos, tamaños390×844 y320×350/texto200%,
movimiento normal/reducido y fronteras arquitectónicas. Evidencia en ESTADO.
Revisión Android real y aprobación visual del usuario pendientes.
