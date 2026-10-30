# ADR-019: preferencias privadas de alertas por cuenta

Fecha: 10 de octubre de 2026. Estado: aceptado para HU-02.2 / RF-02,16 / issue #27.

## Contexto y alcance

HU-02.2 requiere configurar tipos y canales, pausar recepción y conservar elecciones por cuenta. La entrega de notificaciones pertenece a HU-12 / S5. Tener zonas no acredita casos, bandeja, permisos Android ni un proveedor push disponible.

## Decisión

`features/alert_preferences` sigue Clean Architecture por funcionalidad y MVVM. ReadAlertPreferences y SaveAlertPreferences expresan lectura/guardado mediante contratos independientes de plataforma. DTO/fuente Supabase encapsulan proyección y RPC; pantalla/widgets observan ViewModel autoDispose y estado inmutable. Bootstrap/main componen implementaciones; providers declaran contratos y casos de uso.

Catálogo acotado al MVP: mascotas perdidas y encontradas en zonas elegidas, y novedades (avistamientos/cierre) de casos seguidos. Canales: bandeja en la app y notificaciones del teléfono (push). Solo se guardan preferencias; la pantalla explica que la recepción se habilitará al disponer de alertas. Sin email/SMS, GPS, permisos, tokens, envío ni bandeja vacía ficticia. HU-12 deberá implementar y verificar recepción efectiva.

Cuenta sin fila confirmada: recepción pausada, tres tipos seleccionados, bandeja seleccionada y push desmarcado, sin escritura al consultar. Un fallo de lectura no se convierte en esos valores iniciales. La UI permite preparar elecciones mientras está pausada. El interruptor general prevalece; pausarlo conserva tipos/canales. Activar requiere al menos un tipo y un canal, también validado en servidor.

`alert_preferences`: owner_id como clave estable (FK Auth/cascade), booleanos explícitos y versión positiva. No duplica radios/coordenadas. Lectura limitada a columnas propias mediante grants/proyección y RLS restrictiva; sin DML cliente ni acceso anónimo. RPC SECURITY DEFINER con search_path vacío obtiene actor de auth.uid(), serializa por cuenta y bloquea fila. No acepta propietario arbitrario.

Versión cero representa primera escritura. Guardado con versión vigente cambia versión; guardado sin cambios conserva versión/fechas. Reintento con selección idéntica y versión anterior reconoce respuesta perdida sin alterar datos. Comando incompatible o demasiado antiguo produce conflicto. Cuenta, versión esperada y selección completa identifican el comando estable; no hace falta otro UUID por preferencia. Sin cola offline en este incremento.

ViewModel conserva borrador/versión tras fallo, bloquea envíos/ediciones durante operación y descarta respuestas tardías por cuenta/generación; keepAlive solo en escritura. Refresh conserva contenido con progreso fino y pide confirmación si reemplaza borrador; fallo conserva selección. Salir/descartar confirma pérdida de cambios. Conflictos ofrecen consulta actual con descarte explícito. Cambio/error de identidad oculta datos anteriores y limpia éxito; misma identidad posterior al error recupera lectura.

UI: glass flotante, cover seguido de stagger, skeleton inicial, LoadingShimmer con etiqueta estable y éxito superior confirmado. Fallos contextuales. Modal de descarte/origen extraído a core; zonas mantiene wrapper compatible, sin imports de presentación entre funcionalidades.

## Consecuencias y validación

HU-12 consultará recepción/tipos/canales vigentes al generar avisos y antes de reintentar entrega. Pausar no borra elecciones ni avisos existentes. Push sigue persistiendo aviso/trabajo antes del proveedor; la preferencia de bandeja no autoriza omitir ese registro. Casos cerrados no generan nuevas búsquedas. Esta configuración no sustituye permisos Android ni autoriza casos privados.

SQL040–043/plan011 generan migración, patch y run_all. Pruebas verifican permisos entre cuentas/anónimo, columnas, restricciones, versión/conflicto/reintentos, repetición y cascade. Flutter verifica contratos, recuperación, cambios de cuenta, estado, adaptador SDK y recorridos normales/pequeños. Aplicación remota y demo Android deben demostrarse antes de cerrar HU-02.2. Resultados concretos en ESTADO.
