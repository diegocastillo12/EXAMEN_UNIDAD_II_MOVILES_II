# Expansión desde origen con identidad del control

Patrón de movimiento aprobado visualmente por el usuario el21/10/2026.
Referencia vigente: [ADR-128](../decisiones/128-identidad-mobile-en-origen-web-fullscreen.md).
Combina la expansión fullscreen de Sader con la identidad del botón de móvil.

## Experiencia que debe conservarse

El usuario reconoce que el destino nace del control que acaba de pulsar. La
superficie del botón, negra en Reportar, se estira desde su posición y radio
reales hasta ocupar toda la pantalla. El icono conserva su tamaño y permanece
centrado dentro de esa superficie mientras se transforma en el contenido.

La sección anterior sigue visible detrás durante la apertura. El contenido
nuevo está dentro del contorno creciente, escalado y recortado por él; su entrada
es progresiva durante el recorrido. Al terminar ya está presentado, sin un
segundo reveal ni salto a la posición final. La marca y barra permanecen estables.

Al cerrar se contrae el componente aún montado, reaparece la identidad del
control con su tamaño original y se recuperan su color, posición y radio. El
control original se oculta solo durante el morph para evitar verlo duplicado;
se restaura al finalizar o cancelar.

## Cuándo reutilizarlo

Usarlo para abrir una pantalla o un editor desde un control con superficie e
identidad reconocibles, cuando interesa expresar continuidad entre ambos.
Reportar desde nueve puntos y el acceso negro de Inicio son la referencia
aprobada. Registrar/Editar mascota ya reutilizan el motor para cambios locales.

El color, radio e icono se toman del control real: no imponer nueve puntos ni
negro a otros controles. La geometría final de este patrón es fullscreen; un
popover compacto necesita el patrón correspondiente. Perfil/Alertas mantienen
su contrato propio de ADR-124. Esta guía no ordena migrar otros recorridos ni
modifica Flutter; nuevas aplicaciones se validan individualmente.

Una entrada directa o recarga no inventa un origen. Los estados de carga/error,
permisos, confirmación de borrador y operaciones reales siguen siendo los de
la funcionalidad. La animación no debe esperar a que acaben todas las consultas.

## Contrato de movimiento

| Parte | Regla vigente |
| --- | --- |
| Geometría | Rect real del control → viewport completo `100dvw × 100dvh`; retorno al mismo origen. |
| Duración | Apertura y cierre:700ms. |
| Curva de geometría | CustomEase de Sader: `M0,0 C0.305,0.206 0.116,0.567 0.3,0.8 0.394,0.921 0.491,1 1,1`. |
| Superficie | Visible desde el primer fotograma; el color fuente se transforma al fondo de página con la geometría. Sin fade/blur global. |
| Radio | Radio real →0; inverso al cerrar. Se calcula en coordenadas visuales compensando ambos ejes de escala para recuperar el círculo sin esquinas. |
| Identidad fuente | Icono al tamaño original, centrado dentro del contorno, sin estiramiento. Se desvanece hasta45% con easeInOutCubic; fase invertida al cerrar. |
| Cuerpo al abrir | Opacidad0/blur10px → opacidad1/blur0 en500ms; `cubic-bezier(0.56,0.27,0,1)`. |
| Cuerpo al cerrar | Blur0→32px en500ms, `cubic-bezier(0.37,0.35,0,1)`; opacidad1→0 en700ms, `cubic-bezier(0.56,0.27,0,1)`. |
| Composición | Fade/blur solo sobre el cuerpo de destino; superficie e identidad fuente conservan nitidez. Cuerpo e identidad viven dentro del mismo recorte. |

Las fases se solapan; no hay una pausa inventada a mitad del recorrido ni una
aparición del formulario al100%. Tampoco se combina con otro fade de ruta,
cover o stagger de entrada que vuelva a ocultar/revelar el mismo contenido.
Conservar los parámetros compartidos al reutilizar, sin ajustes por pantalla.

## Cómo integrarlo en Nuxt

Reutilizar los componentes y coordinador existentes; no copiar el motor por
funcionalidad ni añadir otra instancia global.

| Pieza existente | Responsabilidad |
| --- | --- |
| [NavigationLink](../../apps/platform/app/components/NavigationLink.vue) con `origin` | Captura el control y navega por el router con todos sus guards; conserva clic modificado y nueva pestaña. |
| [OriginActionButton](../../apps/platform/app/components/OriginActionButton.vue) | Abre un editor local mediante el callback real de la funcionalidad. |
| [OriginPageSurface](../../apps/platform/app/components/OriginPageSurface.vue) | Única superficie activa que envuelve el cuerpo real de la página. Ya incluida en `AccountScreen` y `ModerationScreen`; no anidarla otra vez. |
| [OriginTransitionHost](../../apps/platform/app/components/OriginTransitionHost.vue) | Singleton de `app.vue`: GSAP Flip, superficie fullscreen, identidad y limpieza. |
| `origin_transition` y `navigation_motion` | Coordinan apertura, retorno, identidad de cuenta y navegación. |
| Hooks de `NuxtPage` en `app.vue` | Conservan el DOM saliente durante apertura y lo liberan después; sin snapshots de páginas. |

Ejemplo de enlace a una ruta implementada, conservando el estilo del acceso:

```vue
<NavigationLink to="/reportar" origin class="home-shortcut">
  Reportar
</NavigationLink>
```

Ejemplo del editor local existente; `editPet` es la acción real de esa pantalla:

```vue
<OriginActionButton variant="primary" :action="() => editPet()">
  Registrar mascota
</OriginActionButton>
```

Para cerrarlo, resolver antes el guard de borrador y usar
`await motion.closeLocal(() => { editor.value = false; })`, donde `motion` es
`useNuxtApp().$originTransition`. No desmontar el editor antes de esa llamada.
Para retorno entre rutas, usar el router existente: el hook compartido anima
antes del commit. No crear un guard de acceso por pantalla ni invocar GSAP desde
el ViewModel. Negocio, persistencia y autorización permanecen en sus capas.

## Accesibilidad y limpieza

Respetar `prefers-reduced-motion`: navegación/cambio local inmediato, sin morph
ni identidad temporal. Durante movimiento, el cuerpo no recibe interacción; la
vista saliente y copia visual del icono quedan fuera del árbol accesible.
El foco debe seguir siendo utilizable al terminar, volver o cancelar.

Se copia solo la identidad visual del control en memoria, nunca páginas o
formularios completos. No persistir HTML ni datos privados en almacenamiento.
Finalización, cancelación, cambio de cuenta y desmontaje deben retirar identidad,
referencias, espaciador y estilos, restaurando control/cabecera e interacción.
Resize real cancela con limpieza; un aviso de `visualViewport` sin cambio real
no debe saltarse la animación. La geometría responsive y texto ampliado deben
conservar estas reglas.

## Comprobación al aplicarlo en otro lugar

- Revisar fotogramas de apertura0/5/15/45/99/100% y cierre50/75/95% con movimiento normal; una captura final no prueba el efecto.
- Comprobar identidad al tamaño original, color/radio del control, destino fullscreen y contenido dentro del contorno; sin duplicado del control ni salto al finalizar.
- Verificar que el cierre recupera el origen correcto y restaura el control, sin identidad temporal residual.
- Revisar escritorio,390/320px, texto200%, scroll, reapertura, borrador cancelado, resize real, cambio de cuenta y movimiento reducido.
- Conservar foco, nombre accesible y semántica de enlaces/botones; comprobar las operaciones reales de la funcionalidad.

Referencias automatizadas existentes:
`apps/platform/scripts/check-origin-continuity-browser.mjs` y
`apps/platform/scripts/check-navigation-motion-browser.mjs`, con fixture sin
sesión/datos reales. Capturas locales en
`apps/mobile/build/ui-preview/web-origin-sader`; son evidencia de revisión,
no assets de producción ni documentación portátil.

La aprobación visual del usuario corresponde a Reportar web. La evidencia
técnica previa cubre Chrome en los tamaños documentados en
[ESTADO](../ESTADO.md); Safari/Firefox/dispositivo físico siguen pendientes.
Reutilizar el patrón no equivale a dar por auditadas todas las animaciones.
