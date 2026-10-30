# Ilustración de comunidad

Archivo utilizado por la app: `community_pets.png`, 1536×1024, PNG con canal alfa. Recurso decorativo de Inicio y Acceso y cuenta.

La referencia es `mockups/Entre Huellas_ personajes 3D premium.png`. Se extrajo la pareja principal de cachorro pastor alemán y gato angora blanco, eliminando la composición de la lámina. El original se conserva. Método: herramienta integrada `image_gen`, modo de edición/extracción, `transparent_background: true`. Se comprobó transparencia en las esquinas y se revisó su composición sobre las tarjetas.

## Prompt de producción

```text
Use case: background-extraction. Edit target: the provided Entre Huellas mascot reference board. Extract ONLY the large German shepherd puppy and white angora kitten pair located on the LEFT of the board, preserving their original premium soft 3D appearance, poses, colors and expressions. Remove all text, logos, labels, divider lines, swatches, extra character poses, UI framing and the entire white background. Create one clean full-body cutout of that exact puppy waving alongside that exact fluffy white kitten, both seated together, generously framed with no cropped ears, paws or tails. Actual transparent alpha background. No new objects, no clothing changes, no lettering. This is a production illustration asset for a mobile pet recovery app card, not a mockup.
```

El recurso está incluido explícitamente en pubspec.yaml. Una variante futura se guarda como archivo nuevo y se revisa en la UI antes de sustituir el recurso consumido.

## Confirmación de correo

`dog_with_envelope.png`: PNG RGBA de 1254 × 1254 generado con **image_gen integrado**, con transparencia real, sin redimensionar ni recomprimir. Referencias: la mascota de Revisa tu correo (segunda pantalla de la fila inferior de `mockups/Entre huellas_ bienvenida y cuenta-1.png`) y `assets/onboarding/dog_waving.png` para conservar identidad y estilo. Reconstrucción generada, no recorte determinista del mockup. El prompt exacto se conserva en [email_generation_prompt.txt](email_generation_prompt.txt).

`RegistrationConfirmation` sustituye el icono por esta ilustración decorativa en un área de 240 × 240 con `BoxFit.contain`, excluida de semántica. Los textos y acciones siguen siendo widgets reales; la confirmación usa ahora un código OTP de seis dígitos (actualización del 8 de octubre). Render revisado en `build/ui-preview/register_confirmation.png` y viewport 320 × 350 con escala de texto 2 en `register_confirmation_small.png`.
