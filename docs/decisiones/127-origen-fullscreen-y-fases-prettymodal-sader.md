# ADR-127: origen fullscreen y fases PrettyModal de Sader

Estado: aceptada por instrucción explícita del usuario,21/10/2026.

Complemento posterior ADR-128: por petición explícita, añade identidad móvil
negra/icono/radio al abrir y cerrar y aplica fade/blur solo al cuerpo. Sustituye
la eliminación de relleno/radio y el fade de toda la superficie descritos aquí.

El usuario aprueba la sección anterior detrás, pero exige que la expansión
cubra toda la pantalla y reproduzca la transformación progresiva de PrettyModal.
Esta precisión sustituye la apertura sin fade/blur y el destino limitado al main
de ADR-126; conserva la ruta anterior retenida, acceso y guards existentes.

Se copia de Sader pretty-modal.tsx: Flip.getState(origen), Flip.from/Flip.to con
targets, scale:true, CustomEase original y duración0.7s. De globals.css se copia
la geometría pretty-modal-fullscreen (100dvw/100dvh, max del viewport, margin0,
radius0) y el keyframe pretty-modal-opening: opacity0/blur10px → opacity1/blur0,
500ms cubic-bezier(0.56,0.27,0,1). Se conservan sus keyframes de cierre. No se
inventa una espera al50%: el cambio percibido resulta del solapamiento del morph
y fade/blur originales, mientras el disparador y sección anterior siguen detrás.

Se eliminan la interpolación propia de relleno negro y de radio. Vue integra
el motor con la ruta, sin recrear React ni convertir la operación en modal:
la superficie real ocupa el viewport durante el morph y recorta sus datos.
El cuerpo conserva las coordenadas/layout finales dentro de esa superficie.
Un espaciador sin contenido conserva altura/scroll mientras la superficie está
fija; se elimina al terminar/cancelar. Después se restaura el layout normal de
página sin salto del contenido. Marca y barra persistentes siguen fuera del
movimiento; la cabecera conserva su geometría y se pinta por encima.

No se copian roles, colores ni funcionalidades de Sader (tray/minimizar/drag).
Se mantienen los colores de Entre Huellas y su política global de acceso.
Reducción de movimiento omite el efecto; resize real, identidad/desmontaje y
fallos liberan estilos, espaciador y ruta retenida. Los avisos sin cambio real
de viewport siguen sin interrumpir. Perfil/Alertas y Flutter no se modifican;
se conserva la excepción web de ADR-125/126, sin afirmar paridad global.

Validar ambos controles, rect inicial, fade/blur copiados, destino al viewport
completo, contenido escalado, sección anterior detrás, ausencia de salto al
restaurar layout, cierre, reducido, reaperturas, borrador, resize e identidad.
Evidencia local de dev/build y pendientes en ESTADO; sin SQL, permisos, HU/RF
nuevas ni despliegue.
