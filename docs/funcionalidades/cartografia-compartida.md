# Cartografía compartida en móvil y web

Actualización21/10/2026: [ADR-129](../decisiones/129-paridad-visual-de-mapas-mobile-web.md)
extiende la paridad a los detalles de los mapas equivalentes. LocationMap usa
el pin location_on negro36 centrado de ZoneMapPicker, altura280/radio22/zoom12,
créditos superiores con objetivos48 y sin controles Leaflet adicionales.
Reportar pérdidas conserva radio0; avistamiento QR y avisos de Reportar muestran
200m con relleno34/255 y borde2. Flechas/Enter/Espacio permiten elegir con teclado;
selección/navegación bloqueadas durante envío y tamaño reajustado tras expansión.
Persistencia/permisos, toast/reintento y filtro solo sobre teselas conservados.
Reportar web también consume el adaptador; Explorar web conserva su lista y aún
no tiene el mapa de resultados con pines de marca de Explorar móvil.
No atribuir a este incremento paridad de recorridos todavía inexistentes.

Implementación20/10/2026 por instrucción del usuario, [ADR-104](../decisiones/104-cartografia-global-mobile-web.md).
Regla visual transversal; no implica paridad funcional de web/móvil ni cierre de HU.

- **Qué hace:** base Positron clara con color intermedio entre Reportar original
  y Explorar anterior. Mitad color fuente/mitad acabado de Explorar, aplicado
  solo a teselas. Pines, círculos, créditos y controles conservan contraste.
- **Recorrido:** móvil reutiliza ZoneMapPicker en Explorar, filtros, ubicaciones,
  reportes, avistamientos/revisión y previas/fichas. Web reutiliza LocationMap en
  Reportar y el formulario real de avistamiento público QR mediante SightingMap;
  no crea mapa de resultados web ni pantallas futuras. Nuevos mapas deben usar estos adaptadores.
- **Reglas:** MapStyle obligatorio en Flutter y maps.css/map-style.svg en Nuxt.
  Matrices sRGB equivalentes, verificadas automáticamente. No overrides locales
  por funcionalidad. Radio, cámara, coordenadas públicas/privadas y selección
  siguen siendo propios de cada operación; no globalizar el panel de Explorar.
- **Persistencia/permisos:** solo presentación, sin Supabase/SQL nuevos. URL de
  proveedor público; nunca enviar sesión o claves de backend a las teselas.
- **Errores/reintento:** mantener toast/reintento y selección manual. Web sin
  URL válida no simula un mapa disponible. Créditos OSM/CARTO enlazados y fuera
  del filtro. Recursos/mapa/listeners se liberan al abandonar el formulario.
- **Dependencias/activación:** MAP_TILE_URL móvil y NUXT_PUBLIC_MAP_TILE_URL web
  con la misma URL Positron y clave pública de teselas del usuario. .env local
  web configurado desde la configuración móvil ignorada. Producción requiere
  configurar esa variable y desplegar; reiniciar Nuxt si el proceso local no
  toma la nueva variable. Sin configurar Flutter conserva fallback OSM de
  desarrollo, también filtrado, que no acredita igualdad de base cartográfica.
- **Validación pendiente:** revisión de mapas reales Android/web con proveedor
  configurado y credenciales/restricciones del entorno publicado. Fixtures no
  acreditan red real o disponibilidad del proveedor. Evidencia local en ESTADO.

Evidencia local:17 pruebas Flutter de mapa/selector/arquitectura y análisis
completo limpios;55 pruebas web más26 de servidor de producción aprobadas.
Typecheck/build Nuxt correctos en directorio de build aislado. Navegador
1440/731/390/320/1920 y320×350/texto200%, selección/GPS denegado, reintento,
CSP/hidratación/créditos y pixel del filtro sobre fixture verificados. Sin
publicación/despliegue ni cierre de historia.
