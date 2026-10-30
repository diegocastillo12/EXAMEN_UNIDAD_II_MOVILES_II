# ADR-049: icono de recarga que acompaña el gesto y se retrae

Estado: aceptada por instrucción explícita del usuario, 15 de octubre de 2026.

Refinamiento solicitado el16 de octubre: superficie del indicador igual al retorno, reutilizando GlassSurface (círculo52/radio26/icono28) con su material/desenfoque/ribete/sombra. Se retira decoración gris propia y se ajusta la posición oculta a52. No cambia gesto/giro/retorno; formato/análisis sin incidencias, sin pruebas/renders ejecutados por instrucción del usuario y revisión Android pendiente.

## Referencia y decisión

El usuario corrige la flecha de ADR-048 y pide investigar el indicador habitual: símbolo de recarga, descenso durante el jalón y regreso al soltar. La referencia oficial de [RefreshIndicator](https://api.flutter.dev/flutter/material/RefreshIndicator-class.html) y su [displacement](https://api.flutter.dev/flutter/material/RefreshIndicator/displacement.html) describe el desplazamiento durante arrastre y posición de espera; el equivalente [CupertinoSliverRefreshControl](https://api.flutter.dev/flutter/cupertino/CupertinoSliverRefreshControl-class.html) reserva espacio durante la actualización. Se conserva el reconocimiento nativo actual, sin migrar los scrolls a slivers.

PullToRefresh sustituye la flecha por Icons.refresh_rounded. El indicador aparece desde arriba y acompaña el desplazamiento vertical primario, con resistencia visual de0.5 y máximo112px. Al soltar con umbral alcanzado se acomoda a64px; gira durante la operación real y al terminar o cancelar se retrae/desvanece en220ms. El giro se detiene al terminar, desmontar o activar movimiento reducido. Un nuevo jalón durante retorno parte de su posición actual.

Por instrucción explícita, este icono de recarga giratorio se permite para el gesto de actualización; no se añaden CircularProgressIndicator, anillos de progreso ni barras. El contenido conservado mantiene ContentRefresh/shimmer; las demás cargas mantienen sus reglas. Movimiento reducido conserva respuesta directa al dedo sin giro ni animación autónoma de retorno.

Solo se observan notificaciones de scroll vertical principal, profundidad0; no cambia el umbral nativo, cancelación, callback de ViewModel, inscripción/ciclo de vida ni bloqueo de duplicados de ADR-048. La semántica Actualizar contenido también ejecuta aparición, carga y retirada aunque no exista un arrastre.

## Compatibilidad y validación

Se revisó fuente instalada de Flutter3.35: RefreshIndicator.noSpinner no llama onStatusChange al entrar a refresh. Se sincroniza explícitamente ese estado al comenzar el callback y se finaliza al resolver su Future para que el giro y la retirada funcionen también desde accesibilidad. Controladores liberados en dispose; sin temporizadores de simulación ni delays de carga artificiales.

Formato y dart analyze del componente sin incidencias. Por instrucción vigente, sin pruebas ejecutadas, renders o build. Pendiente Android/iOS: seguimiento, cancelación, retorno, petición rápida/lenta/fallida, scroll vacío/corto, gesto nuevo durante retorno, accesibilidad y movimiento reducido. No se afirma equivalencia visual exacta con el indicador nativo de cada plataforma.
