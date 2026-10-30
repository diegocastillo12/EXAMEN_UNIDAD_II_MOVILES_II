# ADR139 Cifrado de lista offline con Android Keystore

Fecha:30/10/2026. Estado: implementado localmente por solicitud del punto2
del examen U2 tipo4. Alcance: archivo de favoritos guardado manualmente en
Android, sin ampliar HU ni afirmar cifrado global de todas las cachés existentes.

## Decisión

AES256/GCM/NoPadding nativo con clave por cuenta generada y custodiada por
AndroidKeyStore. Android genera IV96 nuevo en cada cifrado; tag128 y AAD con
propósito, versión y cuenta. Leer requiere clave existente, sin generarla al
fallar. Ninguna clave exportada a Dart, archivo, código ni configuración.

Dominio/repositorio/casos de uso permanecen. SavedListFileSource recibe una
interfaz de cifrado sin Flutter y escribe solo el sobre cifrado; el texto JSON
se mantiene en memoria. Puente MethodChannel en app, inyectado desde main,
transporta datos sin negocio. MainActivity registra el canal; Kotlin separado
realiza Keystore/criptografía en ejecutor serial fuera del hilo UI.

Mismo cases.json, sobre version2/algorithm/sealed. Sealed es base64 de
IV12bytes+ciphertext+tag16bytes. Metadatos del algoritmo e IV son públicos.
No hay fallback a texto claro ni migración silenciosa de esquema1. Reinstalación
limpia exigida por el examen elimina archivo y temporales anteriores; requiere
nuevo login y guardado. No se exportan datos privados del backend.

## Validación y límites

16 pruebas Flutter aprobadas; las de archivo usan un cifrador simulado para
verificar almacenamiento/fallback y no acreditan AES. Tres pruebas instrumentadas
Android aprobadas con Keystore real: IV distinto, descifrado con nueva instancia,
clave no exportable, alteración de IV/tag rechazada y cuenta sin clave sin crearla.
APK debug compila; app desinstalada y reinstalada en emulator-5554. Demostración
real con cuenta, copia cifrada, modo avión y captura ADB pendiente del usuario.
No se afirma hardware-backed en emulador ni seguridad global frente a root o
instrumentación del proceso. Protección de recientes, exclusión del backup y
borrado por usuario corresponden al punto3; no se implementan por arrastre.

Referencia de API: https://developer.android.com/reference/android/security/keystore/KeyGenParameterSpec.Builder
