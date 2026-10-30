# ADR-131: borradores locales por cuenta en Android

Fecha: 23/10/2026, America/Lima. Estado: implementado localmente; validación Android pendiente.
Trazabilidad: HU-15.1 / RF-32 / issue #47, sprint S6.

## Contexto

El usuario autoriza continuar con HU-15.1 después de dar por resuelto OAuth.
Los editores de perdido, búsqueda comunitaria, aviso de encontrado y avistamiento
retenían datos solo durante su visita. Sus UUID y comandos congelados ya protegen
los reintentos ambiguos y deben sobrevivir al proceso. La consulta remota de
bienvenida impedía llegar a los formularios al reiniciar sin conexión.

## Decisión

- `offline_drafts` tiene entidad, contratos/casos de uso y providers declarativos.
  Los editores colaboran mediante ese dominio y sus providers; cada presentación
  convierte su propio estado, sin imports de otra presentación/data.
- Drift/SQLite nativo, esquema local 1, en el directorio privado de soporte de la
  app. Clave compuesta cuenta/contexto; un borrador por contexto, varios destinos
  de avisos/avistamientos. Escrituras/lecturas/borrado ordenados y reemplazo atómico.
  Sin migración Supabase ni reescritura de SQL remoto. SQLite se empaqueta con
  sqlite3_flutter_libs porque el conjunto de dependencias resuelve Drift 2.31.
- Se conservan UUID, campos parciales de fecha/hora, coordenada privada, referencias
  de fotos propias y bytes de evidencia nueva. Las URLs firmadas de mascotas no
  se persisten. La instantánea de mascota conserva su versión; el servidor valida
  de nuevo fotos, versión, permisos y estado al enviar.
- Antes de una operación remota se confirma la escritura local del comando exacto.
  Una respuesta incierta mantiene su UUID/contenido congelado, también al recuperar.
  Confirmar publicación retira únicamente ese UUID. Una limpieza local fallida
  puede dejar el mismo comando recuperable; su reintento sigue siendo idempotente.
- Salir conserva el borrador; descartar requiere confirmación y elimina solo el
  borrador mostrado. Un comando incierto no se descarta solo en local; encontrado conserva la RPC que confirma que no hay publicación activa antes de eliminarlo. Los controles
  reutilizan confirmación, toast superior, skeleton y shimmer reales. Perfil enlaza
  a Borradores y permite retomar destinos sin consultar antes su ficha remota.
- La comprobación global de bienvenida conserva su fuente remota. Su adaptador
  guarda únicamente el resultado confirmado por cuenta en SharedPreferences.
  Ante ClientException/timeout y misma identidad, solo un `true` confirmado permite
  recuperar la entrada. Respuestas negativas/errores de servidor no usan fallback.
  No es sesión ni caché de roles/permisos; cada operación conserva autorización
  remota. No habilita acceso anónimo, nueva cuenta ni omisión de onboarding.
- La base y sus auxiliares quedan excluidos del backup y traslado Android. No
  contiene tokens, teléfonos ni datos de contacto; el aislamiento de UI/consultas
  es por cuenta. No se afirma cifrado adicional ni resistencia a dispositivo rooteado.

## Consecuencias y límites

HU-15.1 no activa cola/envío automático (HU-15.2), caché de casos (HU-15.3), mapas
sin conexión ni paridad web. La app conserva su sesión guardada y requiere una
bienvenida previamente confirmada para entrar sin red. Las evidencias locales
se eliminan al descartar/publicar; salir o cambiar cuenta las conserva aisladas
para volver con la misma cuenta. Desinstalar/borrar datos elimina los borradores.
Una terminación durante una escritura todavía no confirmada no equivale a un
checkpoint completado. Los bytes se guardan junto a los campos en la transacción;
el rendimiento con máximos de fotos queda pendiente de medición Android.

## Validación

Reapertura de archivo SQLite, UUID/fecha parcial/evidencia binaria, orden de
escrituras, corrupción sin reemplazo, cuenta/contexto, recuperación antes de
peticiones remotas, comando congelado/reintento, fallo de disco y caché de
bienvenida. Evidencia final y límites en ESTADO y ficha de funcionalidad.
