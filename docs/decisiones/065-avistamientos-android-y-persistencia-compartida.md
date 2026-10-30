# ADR-065: avistamientos Android con persistencia compartida

Fecha: 18/10/2026. Estado: aceptada para HU-10.2 / RF-11 / issue #37.

## Contexto

Android ya permite avisos públicos vinculados mediante `found_cases` (ADR-034).
El avistamiento de HU-10.2 necesita comentario/foto opcionales y evidencia privada,
con las mismas reglas de fecha, estado e idempotencia que la web (ADR-064).
No se convierte un avistamiento privado en aviso público ni se modifica el
recorrido anterior de custodia. Cronología/revisión autorizada corresponde a HU-11.

## Decisión

`apps/mobile/features/sightings` separa dominio, providers declarativos, ViewModel,
estado, pantalla, DTO, repositorio y fuente de datos. Bootstrap inyecta la
implementación; router fija caso y origen desde la ficha. No se importa UI/data
de otras funcionalidades. Reutiliza shell glass, cover/stagger, fecha/hora,
mapa, galería, toast, shake y shimmer. Título breve «La vi» evita dividir palabras
en 320×350 con texto 200%. El acceso se llama «Reportar avistamiento».

La app envía multipart con sesión de usuario a Nuxt, en
`POST /api/app/cases/{lost|found}/{id}/sightings`. El servidor verifica el bearer
contra Supabase Auth; no acepta identidad del formulario ni tokens decodificados
sin verificar. Rechaza usuarios anónimos, Origin de navegador y solicitudes
cross-site. Reutiliza límites de cuerpo/tiempo/concurrencia y procesamiento
sharp de la web: JPEG saneado, sin EXIF, máximo 1280px/1MiB. No añade secretos
al cliente ni habilita acceso directo a evidencia o a tablas.

Plan025/fuentes086–087 extrae `persist_sighting`, sin EXECUTE para ningún rol
cliente ni service_role. Solo las RPC SECURITY DEFINER web/app la invocan. Las
dos comparten validación, bloqueo del caso, límites y escritura atómica. La RPC
app solo acepta llamadas service_role del servidor, que aporta el actor verificado.
`public_sightings.reporter_id` conserva la cuenta. Hash y actor forman parte de
la comprobación del reintento para impedir que otra cuenta recupere un recibo.
La web conserva revocación y visibilidad del QR mediante su wrapper existente.

Se elimina la FK hacia `case_public_links`: un avistamiento Android no exige
haber generado un cartel. Los comandos validan origen/existencia/vigencia bajo
bloqueos sobre casos/mascotas. Casos y enlaces se retiran lógicamente; la evidencia
privada permanece asociada por origen e ID incluso tras revocar un QR. No se
añade política de lectura para HU-11 por anticipación. La eliminación física o
retención de esta evidencia requerirá una operación explícita posterior.

## Alternativas y consecuencias

Reutilizar `found_cases` publicaría la evidencia y conservaría campos obligatorios
incompatibles. Crear otro backend de avistamientos duplicaría invariantes. Permitir
que Android llame directamente a la RPC de servidor expondría credenciales o
permitiría saltar el saneamiento de imágenes. Por ello se mantiene el adaptador
Nuxt, con el coste y límites de bytea documentados en ADR-064.

El UUID y payload quedan congelados tras un resultado ambiguo. El usuario
reintenta la misma orden; solo el recibo del servidor confirma éxito. La denegación
GPS permite el mapa; cancelar cámara conserva la foto anterior y galería disponible.
Cambio de cuenta descarta resultados tardíos y datos privados. Borrador en memoria:
no se promete recuperación tras muerte del proceso ni cola offline de HU-15.

## Activación y evidencia

Aplicar025 después de024 y desplegar servidor/app compatibles. No se reescriben
migraciones anteriores. Generadores producen migración, patch y run_all.
Pruebas SQL locales cubren roles, dos actores, reintentos, fecha, cierre, ausencia
de QR y repetición. Tests Flutter cubren sesión, rechazo, doble envío y GPS/manual;
tests Nuxt verifican Auth, multipart, saneamiento y ruta HTTP compilada.
Resultados finales y límites de Android/servicio remoto en [ESTADO](../ESTADO.md).
