# ADR140 Protección de pantalla y borrado local del examen U2

Fecha:30/10/2026. Solicitud explícita: punto3 del examen tipo4. No cierra HU ni
amplía funcionalidades del MVP fuera de este incremento académico Android.

## Decisión

Desactivar respaldo con allowBackup=false y excluir todos los dominios privados,
preferencias, bases y archivos externos en reglas pre31, cloud-backup y
device-transfer. Keystore sigue fuera del archivo y no se exporta.

Proteger la ruta de Guardados con FLAG_SECURE y, desde API33, desactivar la
miniatura de recientes mientras se muestre. Puente en app y coordinador nativo
por leases: adquirir antes de montar contenido; liberar al desmontar, incluyendo
adquisición que termine después de cancelar la ruta. Ante fallo no renderizar
contenido sensible. Conservar transiciones/tiempos compartidos. Al salir de esa
ruta se restauran capturas para Perfil y demás pantallas.

Perfil recibe un slot de acción compuesto por app, sin importar presentación de
saved_cases. Borrar datos de este teléfono confirma explícitamente la eliminación
de todas las listas offline del examen y sus claves de este dispositivo. Cuenta,
favoritos remotos, otras cachés y borradores no forman parte de ese borrado; el
diálogo delimita listas y claves. La operación de dominio ClearOfflineLists exige
actor autenticado, y ViewModel observa identidad/ciclo de vida sin mensajes de
éxito tardíos de otra cuenta.

La fuente serializa guardar/leer/borrar. Primero elimina claves del namespace
de listas, después carpeta offline_saved_cases con temporales. Un guardado ya
iniciado no puede recrear la copia después del borrado. Fallo parcial se comunica
por toast y permite reintento; operación repetida es idempotente. Sin llamadas
de borrado al backend ni exportación de claves al canal.

## Evidencia y límites

24 pruebas Flutter aprobadas, análisis limpio y6 instrumentadas Android reales:
criptografía/aislamiento/borrado de claves, leases de FLAG_SECURE y configuración
instalada de respaldo y exclusiones. Tests nativos de borrado usan namespace
aislado para conservar la clave real del usuario. Revisión visual del botón a
390×844 y320×844/texto200%, cancelación/confirmación con componentes compartidos.

Puntos1–2 demostrados por el usuario y evidencia local preservada antes de
proteger pantalla. Pendientes capturas reales del punto3: recientes vacío,
captura del emulador bloqueada, Perfil después de borrar y ADB sin cases.json.
No se prueba transferencia cloud/dispositivo real ni se declara cifrada toda la
persistencia del producto. FLAG_SECURE limita capturas Android, no cámaras externas
ni capturas del sistema operativo anfitrión sobre la ventana del emulador.

Referencias oficiales:
https://developer.android.com/identity/data/autobackup
https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE
