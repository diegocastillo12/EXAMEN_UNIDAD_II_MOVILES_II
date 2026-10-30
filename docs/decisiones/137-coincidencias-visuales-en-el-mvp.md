# ADR-137: coincidencias entre publicaciones como diferencial del MVP

Actualización25/10: implementación local en `feature/case-matching` y selección
técnica documentada en [ADR-138](138-motor-visual-local-y-hallazgos-independientes.md).
El usuario aprueba expresamente hallazgos independientes junto a avisos vinculados.
Las menciones inferiores a Backlog/selección pendiente registran la decisión
inicial; activación, evaluación y aceptación siguen pendientes.

Fecha: 25/10/2026, America/Lima. Estado: alcance aceptado por el usuario;
implementación y selección técnica pendientes. HU-25/HU-26, RF-19/RF-20.

## Contexto

El Plan Maestro v2 presenta sugerencias perdido/encontrado con revisión humana
como diferencial (página 3), RF-19/RF-20 (7), motor visual (17), HU-25/HU-26
(27) y demo (33), pero las ubica en V1/S10. La guía local del MVP abarca
HU-01 a HU-16 y había diferido toda IA. El usuario confirma expresamente que
el match es central y solicita incorporarlo al MVP el 25/10/2026.

## Decisión

Incluir HU-25 y HU-26 originales, sin renumerarlas ni confundirlas con issues
#25/#26 (exportación y zonas). Conservar RF-19/RF-20 y crear su seguimiento
en GitHub sin duplicar historias existentes. Prioridad alta, Backlog hasta
refinar contratos, modelo, candidatos elegibles y evaluación; sin plazo prometido.

HU-25 entrega indexación versionada de fotos autorizadas y procesamiento
reintentable sin bloquear publicación. HU-26 entrega hasta cinco candidatos
por caso, combinando similitud visual, zona y tiempo, con explicación y revisión
humana persistida. Score técnico no equivale a porcentaje de identidad. Una
confirmación no asigna propietario ni cierra o recupera automáticamente el caso.

## Fronteras y refinamiento

Mantener Clean Architecture por funcionalidad, Flutter/Nuxt/Supabase, autorización
en servidor y separación pública/privada. Modelo, licencia, ejecución, recursos,
conservación de derivados, umbrales y alcance móvil/web se definen antes de
implementar. Esta decisión no introduce workers de IA, Redis, ASP.NET ni servicios
externos; si se necesitan, documentar una decisión técnica posterior explícita.

El flujo actual distingue búsquedas propias/comunitarias y avisos ya vinculados.
Definir candidatos perdido/encontrado con ese modelo: un aviso ligado al caso
no se presenta como descubrimiento independiente. No reclasificar registros
antiguos ni reintroducir formularios de hallazgos independientes por inferencia.

Evaluar con imágenes autorizadas, identidades separadas y distractores;
documentar Recall@5, falsos positivos y latencia. No habilitar avisos automáticos
de identidad sin evaluación y decisión explícita. Fallo del motor conserva
publicación, búsqueda, QR y colaboración existentes. Retirada, cierre, bloqueo
y permisos deben invalidar candidatos no disponibles.

## Consecuencias y límites

La exclusión general de IA del MVP tiene esta excepción explícita. Adopción,
chat, salud y demás ampliaciones conservan su planificación; FCM sigue pospuesto.
La aprobación no acredita código, datos migrados, precisión, despliegue ni cierre
del MVP. Criterios y pendientes en la [ficha](../funcionalidades/coincidencias-de-casos.md).
