# Toast móvil compartido

Actualizado: 19/10/2026. Core/presentation de apps/mobile. Mejora transversal
solicitada por el usuario; sin nueva HU/issue ni cierre de historias.

## Qué hace y recorrido

ConfirmationToastHost muestra errores, validación y resultados en la parte
superior de sus pantallas existentes. Entra desde fuera de la pantalla, sigue
el dedo/ratón y sale hacia arriba al descartarlo. Un gesto corto o cancelado
retorna; hacia abajo ofrece resistencia. Se conserva cierre por toque,
teclado/Escape y acción semántica. Los mensajes extensos permiten scroll; el
icono sigue admitiendo arrastre en ese caso.

## Reglas y campos

confirmed/message/noticeId/isError/child/actionLabel/onAction conservados.
Un nuevo noticeId repite el anuncio; rerenders ordinarios no lo repiten.
Un solo aviso visible, incluso con hosts anidados. Acabado y tiempos iguales
a web: glass/radio28/blur18, texto14/peso400, icono32/20, máximo360/márgenes24,
safe-area+12; entrada480ms, salida240ms y retorno420ms. Límite de altura30%
del viewport/hasta220, scroll y espacio disponible con teclado conservados.
Descarte:40px arriba o12px con velocidad media>0.45px/ms. Hacia abajo máximo18px.
6500ms de duración, pausada al sostener y reiniciada al devolver el aviso.
Sin transiciones con movimiento reducido. La fuente sigue siendo la móvil.

## Persistencia, permisos y dependencias

No persiste ni consulta datos; no modifica permisos. Estado de presentación
mediante overlay, controladores Flutter y timer locales. Reemplazo/desmontaje
liberan recursos y rechazan eventos/callbacks del aviso retirado. Se aplica a
los consumidores existentes sin cambios de ViewModels ni API pública.
[ADR-096](../decisiones/096-toast-mobile-igual-web.md), referencia [web](toast-web.md).

## Errores y reintentos

Conserva mensajes y reglas de cada funcionalidad. Arrastrar sobre la acción no
la ejecuta. Tocar la acción descarta primero y ejecuta una vez tras la salida;
no ejecutar callbacks tardíos si se reemplazó/desmontó el aviso. Anuncios
accesibles y texto ampliado conservados.

## Validación y pendientes

33 comprobaciones específicas aprobadas:16 del toast, arquitectura,
preferencias, avatar y harness visual. Otras54 de consumidores aprobadas:
perdidos/encontrados, editor de mascotas, carteles y Explorar. Se usa el define
existente AMBIENT_BACKGROUND_MOTION=false para estabilizar el fondo ambiental,
sin desactivar las animaciones del toast. Capturas normales/pequeñas/texto2 en
apps/mobile/build/ui-preview/mobile-toast, revisadas visualmente. Formato,
flutter analyze y git diff --check finales aprobados.

La suite completa no se acredita: intentos generales con timeouts del fondo,
agotamiento de hilos/memoria y fallos en origin_page_transition_test fuera del
toast. Falta comprobar el gesto en dispositivo Android/iPhone físico. Sin nuevo
APK, instalación, SQL, backend o cambios remotos.
