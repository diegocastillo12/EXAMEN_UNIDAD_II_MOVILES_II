# ADR-043: desplegable anclado y distancia en Explorar

Estado: aceptada por instrucción explícita del usuario, 15 de octubre de 2026.

Actualización: [ADR-044](044-filtros-transicion-control-center.md) sustituye el blur inmediato, intensidad del velo y cover/stagger descritos aquí para este desplegable; mantiene el anclaje, cards y distancia.

## Motivo y decisión

El usuario aclara que Filtrar casos debe desplegarse desde su posición y quedar sobre la grilla, sin empujarla ni abrir una ventana centrada. También pide una sola insignia y distancia en lugar de especie.

FilterExpansion<T> compartido conserva la cápsula y monta su editor mediante OverlayPortal y un enlace de composición al borde inferior del disparador. El desplegable tiene el ancho del control, superficie neutra, radio28 y scroll propio limitado al espacio disponible, considerando teclado e insets. Por ajuste posterior explícito del usuario, el fondo lleva desenfoque suave (sigma4) y velo negro al12%; el editor se pinta encima y permanece nítido. El efecto solo existe mientras está abierto y el área exterior conserva cierre al tocarla y etiqueta accesible. Conserva SelectionPillSurface/FilterChoiceGroup y cover→stagger con movimiento reducido. Se cierra al tocar fuera, pulsar Atrás o aplicar; cerrar sin aplicar descarta el borrador. El portal pertenece al widget y desaparece al desmontarlo/cambiar cuenta. Aplicar ya no desplaza el scroll del listado.

Las cards muestran solamente el estado Abierto/Resuelto en la esquina superior derecha. Perdida/Encontrada/Avistamiento son tipos de reporte, conservados en filtros y ficha. Bajo la imagen se muestra nombre (Sin nombre si falta), sin especie ni fecha. Con distancia devuelta por el servidor: A 4 km, redondeada a kilómetros enteros, o A menos de 1 km. Sin centro de búsqueda o distancia válida se omite esa línea; no se infiere GPS ni se inventa distancia. La proximidad sigue siendo aproximada respecto a la zona pública del caso.

Sustituye las decisiones de despliegue dentro del scroll y doble badge de ADR-042. Mantiene su búsqueda de lugares, mapa y radio; sin cambios de dominio, SQL, permisos ni activación019.

## Validación

Por petición explícita del usuario no se ejecutan pruebas en este ajuste. Se aplica formato Dart y revisión estática del cambio. Se actualiza la expectativa existente para que abrir filtros conserve la posición de las cards, sin ejecutar la prueba. Pendiente revisión visual en Android, incluido teclado, texto ampliado, scroll interno y cierre. Las pruebas anteriores documentadas no acreditan este nuevo desplegable.
