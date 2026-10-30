# ADR-121: navegación web sin esperas repetidas

Fecha: 20/10/2026. Estado: aceptada por la solicitud explícita de mejorar la
respuesta al cambiar de sección. Complementa ADR-079/080 y sustituye solo los
tiempos de entrada generales de ADR-075/119.

## Problema

AccountScreen anunciaba su identidad mediante BroadcastChannel en cada montaje.
El transporte de la propia pestaña recibía ese aviso e invalidaba la preparación
de sesión de 15 segundos. Además, cada montaje comenzaba con checking/skeleton,
incluso después de validar la ruta, y consultaba permisos de gestión en todas
las secciones. El stagger general de 850ms + 90ms por elemento añadía demora
perceptiva y podía solaparse con una expansión desde origen.

## Decisión

- BroadcastChannel anuncia cambios de identidad/onboarding/cierre, no montajes.
  Se mantienen invalidación por foco/visibilidad, escrituras, conflictos y avisos.
- El transporte de data permite leer su proyección ya validada, solo dentro del
  plazo original de 15s y del vencimiento del token. Bootstrap la inyecta como
  estado inicial opcional del ViewModel y vincula el repositorio al actor.
  No hay caché adicional ni ampliación del plazo; permisos nunca se cachean.
- La hidratación inicial conserva el mismo skeleton que SSR. La inicialización
  desde la proyección preparada solo aplica después de hidratar, en navegación
  cliente. No se serializan perfiles, sesiones ni credenciales en el payload.
- La política global sigue validando antes de montar cada destino protegido.
  AccountScreen evita repetir esa carga cuando recibe una proyección vigente;
  programa vencimiento también con sesión inicial y consulta gestión solo en Inicio.
- NavigationLink prepara código y sesión por intención de puntero/foco/toque.
  UserNavigation prepara código de sus cuatro destinos; no descarga datos privados
  ni concede acceso. Pulsar la ruta exacta actual no reinicia consultas/animaciones.
  Se conservan enlaces, clics modificados y confirmaciones de cambios pendientes.
- StaggerReveal general usa 240ms, separación35ms y máximo140ms de retraso:
  entrada completa hasta380ms aun con listas largas, sin blur. Si hay transición
  desde origen activa, esta revela el contenido sin otra entrada simultánea.
  Onboarding/login conservan sus parámetros propios; movimiento reducido y QR
  sin JavaScript siguen legibles. Marca y barra conservan composición y efectos.
- Identidad/perfil se consultan en paralelo con el mismo token privado; no se
  devuelve perfil antes de validar identidad y fila propia. Mascotas/búsquedas
  del formulario también se leen en paralelo, conservando descarte al salir.

## Validación y límites

Pruebas de TTL, invalidación, vínculo de actor, identidad pendiente y respuestas
tardías; QA de navegador reproducible en
apps/platform/scripts/check-navigation-performance-browser.mjs. Comparación del
build anterior y posterior con backend fixture y250ms añadidos a cada consulta
de sesión: seis navegaciones pasan de seis consultas extra a cero. La medición
de encabezados incluye clic y comprobación del navegador; no es un percentil
de usuarios reales ni un resultado de producción. Resultados finales en ESTADO.

No elimina la latencia real de las operaciones ni evita revalidar al vencer el
plazo. Sin cambios SQL, despliegue, autorización por operación o alcance del MVP.
