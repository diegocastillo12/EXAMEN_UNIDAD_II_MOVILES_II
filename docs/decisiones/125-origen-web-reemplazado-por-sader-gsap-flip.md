# ADR-125: reemplazar el motor de navegación desde origen por Sader

Estado: aceptada por instrucción explícita reiterada del usuario,21/10/2026.

Corrección posterior: [ADR-126](126-contenido-dentro-de-expansion-y-ruta-anterior-visible.md)
sustituye la fase de contenido oculto hasta100% por contenido escalado visible
desde el origen y conservación de la ruta anterior detrás durante apertura.
Las descripciones de esa fase a continuación son historial de esta decisión.

## Motivo e instrucción

El usuario rechaza las sucesivas aproximaciones del motor web: las capturas
muestran accesos de Inicio superpuestos al reporte. Exige copiar y reemplazar
el efecto por el código de sader-panel y precisa que el contenido nuevo no se
vea hasta que el componente termine de abrirse. Las comprobaciones anteriores
de recorte/matrices no acreditaron el resultado que veía en su pestaña.

## Decisión

Se elimina de la navegación web la captura/clonado de páginas, hold/previous,
la superficie paralela y las animaciones WAAPI calculadas a mano. Se incorpora
GSAP3.15.0 (misma dependencia que Sader) y se copia el núcleo de PrettyModal de
`apps/sader-panel/src/components/ui/pretty-modal.tsx`: Flip.getState sobre el
origen, data-flip-id compartido, Flip.from/Flip.to, scale:true, duración0.7s y
CustomEase `M0,0 C0.305,0.206 0.116,0.567 0.3,0.8 0.394,0.921 0.491,1 1,1`.
Se conservan sus keyframes de cierre de globals.css, acotando los selectores
a la superficie web. En apertura, la superficie tiene opacidad1 y sin blur,
como la variante shell de expand-intact-modal.tsx de Sader: el fade desde0
de PrettyModal ocultaba precisamente los primeros fotogramas con forma de botón.
Vue adapta mounting/estado de React.

OriginPageSurface envuelve el contenido vivo. Flip anima ESE componente, no
una copia ni un panel que destapa un formulario separado. El cuerpo conserva
layout pero se oculta con visibility y opacity durante toda la apertura;
se revela únicamente al finalizar, por la precisión explícita del usuario.
Tamaño final congelado durante el morph para que lecturas tardías no lo alteren.
La marca y navegación persistentes permanecen fuera de la superficie.

Aclaración posterior21/10: el usuario señala que no percibe la apertura de
Reportar. El mismo degradado de página sobre un cuerpo oculto no aporta contraste.
La superficie única debe nacer con el relleno/radio del control real; Flip
interpela el radio y una interpolación de color en su misma timeline disuelve
el relleno linealmente hasta transparencia. Así se ve crecer sin anticipar el
formulario ni introducir un cambio brusco de fondo al terminar. Se mantienen
geometría/curva/duración de Sader y la instrucción de contenido al100%.

El retorno ejecuta Flip.to antes de desmontar/cambiar ruta, como PrettyModal.
Terminada la contracción, la pantalla queda oculta hasta el commit de ruta,
equivalente a dialog.close(); restaurar estilos no puede hacerla reaparecer.
Si se cancela la navegación se restaura; en cierre local se restaura después
de aplicar el nuevo estado sobre la superficie que sigue montada.
El hook visual compartido de router corre después de los guards de salida;
no añade políticas de acceso por pantalla ni sustituye autorización. Cancelar
un formulario conserva el estado y no lanza una contracción. Foco, inercia,
resize/preferencia, desmontaje e identidad deben quedar limpios.

Corrección posterior21/10: un aviso de visualViewport.resize sin cambio real
de dimensiones no debe finalizar la entrada. El listener anterior ejecutaba
onComplete incluso ante ese aviso y mostraba el formulario de inmediato.
Se compara tamaño de ventana, altura visual y escala, ignorando variaciones
de ancho visual por scrollbars. Comprobar también duración/crecimiento real,
sin pausar GSAP, con aviso inducido durante el cambio de ruta.

## Alcance y excepción explícita a ADR-124

Esta nueva instrucción prevalece para el motor compartido de navegación web
(Reportar, editores de mascotas, entrada de revisión y sus retornos):0.7s y
revelado al100%, en vez de320/260ms y65%. Se registra la divergencia autorizada
con móvil; Flutter no se cambia en este incremento. Perfil/Alertas usan otro
motor ya existente y conservan ADR-124. Tampoco se cambia MorphPanel de campos.
No se afirma paridad global ni una auditoría completa de animaciones.

Solo presentación y dependencia de animación; sin React, nuevas operaciones,
datos, permisos, SQL, rutas vacías, HU/issues o despliegue.

## Validación requerida

Comprobar ambos disparadores, primer rect real, superficie visible y sin blur
desde0/2/5/10/15%, contenido oculto incluso99%,
ausencia de copias y aparición al100%; retorno con el componente aún montado,
reaperturas reales, movimiento reducido, resize/identidad/desmontaje y guard
de borrador cancelado. Desarrollo5173 y build con backend fixture, sin usar
la sesión/datos reales. Evidencia y pendientes en ESTADO y transiciones-web.
