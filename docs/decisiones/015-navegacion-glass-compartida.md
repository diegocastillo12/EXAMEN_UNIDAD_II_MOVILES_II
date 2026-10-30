# ADR-015: navegación de pantalla con glass compartido

Fecha: 9 de octubre de 2026, America/Lima. Estado: aceptada por instrucción explícita del usuario.

## Contexto y decisión

El retorno glass de la ficha estaba aislado; Registrar/Editar conservaban flecha plana y cabecera opaca. El usuario pide el mismo tratamiento y convertirlo en regla general de UI.

Los controles superiores para volver o cerrar una pantalla reutilizan GlassNavigationButton de core: círculo52, radio26, icono28, tooltip y callback existentes; GlassSurface conserva el acabado de navegación. Usar chevrón para volver y X para cerrar. Superponer el control al scroll sin franja opaca; respetar insets, espacio inicial e interacción. No cambiar destinos ni reglas de dominio. La regla se aplica a navegación de pantallas; controles de formulario, retirada de fotos y cierres de paneles/modales conservan sus responsabilidades.

## Consecuencias e implementación

PetScreenShell usa siempre el retorno flotante, sin opción de flecha plana. Perfil comparte el botón y lo fija sobre el scroll. AppPageLayout comparte el cierre glass en su overlay existente. No extender glass a todos los campos o acciones de negocio.

REGLAS_UI_UX, DISENO_UI, ARQUITECTURA y AGENTS registran esta norma. Verificación: navegación de mascotas/Perfil/acceso, arquitectura y renders normales/pequeños. Pruebas locales no acreditan blur ni rendimiento Android.
