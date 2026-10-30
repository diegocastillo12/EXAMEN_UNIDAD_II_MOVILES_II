# ADR-112: conservar la ficha fotográfica inmersiva

Fecha:20/10/2026. Estado: aceptada por instrucción explícita del usuario.

## Contexto y decisión

El usuario aprueba una propuesta de Ver ficha con tarjetas glass gris perla,
pero pide conservar, renombrar y documentar el diseño implementado actualmente
para reutilizarlo en una funcionalidad futura aún sin definir.

El patrón se llama **Ficha fotográfica inmersiva**. `CasePublicationPreview`
pasa a ser `ImmersivePhotoSheet`, en `immersive_photo_sheet.dart` de
core/presentation/widgets. `CasePreviewGeometry` pasa a ser
`ImmersivePhotoSheetGeometry`, en `immersive_photo_sheet_geometry.dart`.
Se actualizan imports, consumidores y pruebas sin alterar su comportamiento.

## Consecuencias

El componente sigue activo en fichas y vistas previas de perdidos/encontrados.
No se elimina, duplica ni archiva como código muerto. Su sustitución por las
tarjetas aprobadas se realizará en otro incremento. No se crea una ruta o
funcionalidad vacía para reservarlo. La ubicación futura se decidirá según un
uso concreto; el nombre neutral no implica un contrato genérico nuevo.

Dominio, datos, permisos y operaciones permanecen iguales. No hay cambio de
reglas arquitectónicas ni ampliación de HU-05/06/07. La excepción tipográfica
del nombre blanco48/800 de ADR-111 sigue aplicando al componente renombrado.
Las menciones anteriores a CasePublicationPreview documentan el mismo patrón.

Contrato, límites y validación en la
[ficha de reutilización](../funcionalidades/ficha-fotografica-inmersiva.md).
