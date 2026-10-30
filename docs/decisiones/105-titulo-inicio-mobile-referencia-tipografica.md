# ADR-105: tipografía del título de Inicio móvil

Fecha:20/10/2026. Estado: aceptada por instrucción explícita del usuario.

Actualización posterior20/10 por instrucciones explícitas: título sin tarjeta
glass y tamaño32 (tras26). La nueva referencia solicita degradado horizontal
en la segunda frase: #459FF6→#75C9EF. Primera frase conserva gris/peso400,
segunda peso600. Dos textos con ShaderMask solo sobre el remate, agrupados
con etiqueta semántica completa; ajuste natural y ampliación conservados.
Descripción pasa debajo de la ilustración dentro de su tarjeta glass.
Esta actualización sustituye tamaño23, azul plano y composición anteriores.

El usuario solicita aplicar al título «Su regreso empieza contigo» el estilo
de su captura: formas geométricas suaves, comienzo ligero y remate más grueso.
Se usa Poppins como aproximación visual, sin afirmar identificar la fuente
original. Primera línea «Su regreso» gris #454746/peso400; segunda «empieza
contigo» azul #459FF6/peso600. Tamaño23 e interlineado1.25.

Excepción local a la fuente del sistema en REGLAS_UI_UX: solo este título.
Los dos pesos se empaquetan en Flutter con licencia OFL, procedentes de
https://github.com/google/fonts/tree/main/ofl/poppins. No hay descarga de
fuentes en ejecución ni dependencia nueva. Text.rich conserva ampliación,
ajuste natural de líneas y una etiqueta accesible con la frase completa.
La tarjeta conserva GlassSurface y su entrada compartida.

No cambia arquitectura, navegación, persistencia ni alcance de historias.
Validación y revisión nativa pendiente se registran en ESTADO e Inicio.
