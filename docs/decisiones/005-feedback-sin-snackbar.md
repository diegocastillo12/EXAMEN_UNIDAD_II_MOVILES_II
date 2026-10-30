# ADR-005: feedback contextual sin SnackBar

Estado: adoptada. Fecha: 7 de octubre de 2026.

## Decisión

Por instrucción explícita del usuario, el proyecto no utiliza **SnackBar**. La regla aplica a todas las funcionalidades y componentes de la app, incluidos wrappers o paquetes que lo muestren. No sustituirlo por un toast o una barra inferior equivalente para eludir esta decisión. Un cambio futuro requiere una decisión versionada y actualización de reglas/comprobaciones.

La elección responde a la dirección visual del proyecto: el feedback permanece junto a la acción o campo correspondiente, sin una notificación inferior transitoria que ocupe espacio de los controles. No se establece como recomendación universal para otras aplicaciones.

## Aplicación al login

- Credenciales incorrectas: marcar ambos inputs si el servidor no distingue cuál falló. No mostrar una barra ni repetir un párrafo general.
- Validación local o correo no confirmado: marcar el campo correspondiente, con pista breve cuando sea necesaria.
- Borde de error e iconos en color danger; outline de 3.5 px. El fondo del input permanece igual al normal.
- Shake breve, limpieza al editar y respeto de animaciones desactivadas. Conservar información semántica accesible; no depender únicamente del color.
- Fallos del servicio: mensaje breve dentro del formulario, sin señalar las credenciales como incorrectas.

El ViewModel decide el campo/tipo de fallo. Los widgets representan ese estado; las fronteras con dominio y SDK no cambian.

## Validación y límites

La prueba de reglas escanea los archivos Dart de `lib` y rechaza referencias al componente y sus APIs de presentación. La revisión de dependencias complementa esa comprobación para wrappers externos. Las pruebas del formulario verifican grosor de borde, fondo conservado, campo correcto y preferencias de movimiento. Resultados en [ESTADO.md](../ESTADO.md).

## Evolución posterior — 8 de octubre de 2026

Por nueva instrucción explícita del usuario, [ADR-007](007-confirmacion-toast-superior.md) sustituye la prohibición general de toast únicamente para confirmaciones de éxito mediante aviso superior propio. En Perfil reemplaza «Perfil actualizado.» permanente. SnackBar y equivalentes inferiores continúan prohibidos; errores y validación conservan esta decisión. La autorización está delimitada y documentada, no es una excepción implícita.

ADR-009 amplía por solicitud explícita del usuario el toast superior propio a errores de foto de perfil; las demás validaciones/errores conservan esta regla. No permite SnackBar ni equivalentes inferiores.

ADR-013 amplía por nueva instrucción explícita del usuario los errores autorizados en toast superior a eliminación de mascotas. Los fallos de esta operación dejan de aparecer debajo de tarjetas; los demás errores mantienen este documento.
