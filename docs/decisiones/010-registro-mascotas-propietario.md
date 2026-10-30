# ADR-010: registro y edición de mascotas propias

Fecha: 9 de octubre de 2026. Estado: aceptada dentro del incremento solicitado por el usuario.

## Alcance

HU-03.1 / RF-03, issue #28, entrega listado, registro y ficha de mascotas propias. Se incorpora también edición de metadatos de HU-03.2 / issue #29 por autorización explícita; esa historia permanece incompleta hasta integrar fotos de HU-04. No añadir fotos/cámara simuladas, casos, eliminación, zonas ni datos ficticios al producto. Campos: nombre y especie obligatorios; sexo, edad aproximada en meses y rasgos opcionales. Especies dog/cat/other; sexo male/female o desconocido. Nombre 1–80 puntos de código, edad 0–600 meses o desconocida, rasgos hasta 500; trim Unicode y cadenas opcionales vacías convertidas a null. UI comunica restricciones únicamente junto al campo ante error.

## Contrato de datos

Tabla privada public.pets con dueño, UUID, campos, versión y fechas administradas por servidor. RLS permite consultar solo mascotas de auth.uid(). Roles cliente sin INSERT/UPDATE/DELETE directos; RPC create_pet/update_pet SECURITY DEFINER, search_path vacío, propietario validado con auth.uid(), campos validados y EXECUTE solo authenticated. Sin datos públicos de mascota expuestos en este incremento; QR tendrá proyección separada.

UUID generado una vez por borrador, conservado en reintentos. create_pet deduplica el mismo identificador/payload y rechaza identidad o payload incompatibles. update_pet bloquea la fila y exige expected_version; una respuesta perdida puede reintentarse con idéntico payload y versión anterior inmediata, sin incrementar de nuevo ni cambiar fecha. Otra edición concurrente produce conflicto, nunca sobrescritura silenciosa. Ver ficha actual conserva el borrador mientras se consulta lo guardado. No existe aún cola offline persistente; la selección/campos quedan en memoria mientras vive el editor.

## Capas y presentación

Feature pets con entidades/contrato/casos de uso independientes; DTO/fuente Supabase/repositorio en data; ViewModels autoDispose para listado/detalle/editor y estado explícito. Bootstrap/main inyectan el repositorio. Home recibe PetsSection por composición de app/router, sin import de presentación entre funcionalidades. Rutas privadas /home/pets/new, /home/pets/:id y edit. UUID y generaciones impiden aplicar respuestas de otra identidad; keepAlive temporal solo durante escritura y liberado en finally permite refrescar listado tras cerrar editor.

Fondo blanco, paleta carbón y superficies neutras; componentes de inputs/botón/shimmer/shake existentes. Cabecera persistente fuera de cover y stagger posterior en grupos de formulario. No reiniciar efectos con edición/teclado; errores contextuales y éxito con toast existente después de persistencia confirmada. Selección de especie/sexo admite texto ampliado; áreas táctiles accesibles por scroll. Listado vacío solo tras consulta satisfactoria, error distinto con reintento.

## Verificación y despliegue

Fuentes SQL 013–018, plan 005, migración y patch manual generados; se preserva historial previo. Pruebas locales de roles, normalización/Unicode, reintentos, versiones, cuenta diferente, dominio/ViewModels/contrato SDK y navegación normal/pequeña. Los sustitutos y PostgreSQL local no acreditan despliegue Supabase ni sesión/reinicio Android. Aplicar patch de desarrollo y demostrar con dos cuentas antes de cerrar #28; #29 además requiere fotografías.
