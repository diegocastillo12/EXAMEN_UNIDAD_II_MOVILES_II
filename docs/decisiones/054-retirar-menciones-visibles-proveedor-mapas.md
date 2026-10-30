# ADR-054: retirar menciones visibles del proveedor de mapas

Fecha:16 de octubre de2026, America/Lima. Estado: aplicado por instrucción explícita del usuario.

El usuario exige retirar las menciones visibles del proveedor cartográfico. Se eliminan el crédito/enlace del mapa de resultados, el crédito/enlace del buscador compartido de ubicaciones/ciudades y los mensajes asociados a esos enlaces. Se retira el slot de atribución de ZoneMapPicker al quedar sin consumidores, sin sustituirlo por otro crédito visible.

Esta instrucción sustituye las decisiones anteriores de incluir atribución en la UI descritas en ADR-042/051/052. Las configuraciones técnicas y los contratos de consulta conservan su funcionamiento; las referencias documentales anteriores quedan como historial. No se modifica el trabajo de carteles en curso ni se genera APK.

Validación: escaneo sin menciones o enlaces del proveedor en lib/features y lib/core/presentation; formato y análisis sin incidencias. Pruebas focalizadas de mapa/lista/búsqueda/recuperación y arquitectura, con resultados en ESTADO.
