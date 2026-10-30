# ADR-028: consistencia de fronteras, estados y componentes

Estado: aceptada en la corrección solicitada. Fecha: 11 de octubre de 2026.

## Problema

La revisión R01–R10 detectó datos de mascotas obsoletos tras borrar reportes, acoplamiento de onboarding a ViewModels de auth, comprobaciones incompletas y duplicaciones de fotos/galería/fecha/proyección/refresh.

## Decisión

La colaboración entre funcionalidades pasa por dominio y providers declarativos, nunca por presentation/data ajena. EntryViewModel consume el contrato de sesión compartido y CheckOnboarding; EntryExitViewModel consume SignOut. Las comprobaciones incluyen core, prohíben core→features y presentation/data entre funcionalidades, y permiten app como composición.

PetChanges es un servicio de dominio Dart puro, propiedad del scope, sin caché ni estado de servidor. NotifyPetChanged emite solo tras una mutación confirmada que afecta a una mascota. Lista, archivadas y detalle observados se suscriben por cuenta/mascota y liberan suscripciones. Se vuelve a consultar al repositorio; no se inventa una versión local. No sustituye sincronización remota/realtime.

PetPhotosState copia y protege listas/conjuntos; PetPhotoDraft copia y protege bytes. Generación UUID, fecha de casos, aproximación pública, preparación de fotos, superficies de validación, galería y refresh se comparten en core. Las galerías nativas mantienen sus distintos contextos de recuperación; la preparación de píxeles comparte límites, orientación, limpieza y JPEG. La proyección de preview está en estado; las reglas de publicación siguen en dominio. retainedRead coordina exclusivamente finalización/fallo de lectura para la identidad/generación vigente. Los ViewModels y estados específicos se conservan sin herencia ni repositorio base genérico.

Publicar/descartar encontrados tienen plazo de operación de90s y de petición de30s. Un timeout libera busy y conserva el draft congelado para reintentar el mismo ID/bytes; no demuestra cancelación de una petición remota. SQL061 configura lock_timeout=5s en seis operaciones de escritura sin reescribir fuentes aplicadas ni modificar permisos. Plan017 genera la migración20261011001700; run_all incorpora el nuevo origen.

## Validación y límites

Regresiones de sincronización, inmutabilidad, timeout/reintento, identidad, arquitectura y UI; pruebas SQL de repetición/permisos y Edge de fotos. Se añade CI de SQL/Edge, sin publicación ni ejecución remota por esta tarea. Migración017 requiere activación en desarrollo junto con las anteriores; ver ESTADO y CONFIGURACION.
