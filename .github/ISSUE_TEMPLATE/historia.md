---
name: Historia del MVP
about: Un comportamiento del producto con criterios verificables
title: "[HU-XX] "
labels: ""
assignees: ""
---

## Resultado para el usuario

Como ... quiero ... para ...

## Trazabilidad

- Tipo: historia de usuario ejecutable (una épica agrupa historias, no cuenta como otra entrega)
- Historia: HU-XX
- Derivada, si corresponde: HU-XX.n (identificador independiente del número GitHub)
- Agrupadora, si corresponde: #issue-original
- Requisitos: RF-XX
- Sprint: Sx
- Prioridad y justificación:
- Estimación: pendiente hasta acordarla sobre esta entrega
- Dependencias:

Para historias derivadas, definir un resultado demostrable y sus dependencias concretas, sin exigir terminar toda una agrupadora. No separar pantalla/backend/pruebas en historias sin valor de usuario. La agrupadora conserva los criterios originales y enlaza sus derivadas; no contar su esfuerzo dos veces.

## Criterios de aceptación

- [ ] Comportamiento observable.
- [ ] Errores y permisos pertinentes.

## Validación

Datos de prueba, usuarios autorizados/no autorizados y evidencia esperada.

Describir un escenario específico reproducible: condiciones iniciales, acción, resultado esperado y errores/permisos pertinentes. No acreditar servicios reales solo con repositorios sustituidos.

## Refinamiento pendiente

Identificar las reglas o decisiones de producto aún sin concretar. Resolverlas antes de comprometer la implementación; no ocultarlas detrás de criterios vagos.

## Terminado cuando

Criterios demostrados, código integrado, cambios de datos versionados y validados, errores/permisos comprobados, demo reproducible y docs/ESTADO.md actualizado. No sumar el esfuerzo de la épica y sus historias.

## Trabajo técnico

Tareas suficientes para completar la historia; mantener la historia como unidad de resultado.

Respetar `docs/REGLAS_ARQUITECTURA.md`. Identificar las capas afectadas y las comprobaciones de contratos, errores y permisos que corresponden al flujo. Registrar una decisión en `docs/decisiones` si la historia cambia los límites de arquitectura.
