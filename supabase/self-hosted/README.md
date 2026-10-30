# Activación de fotos en Dokploy

La instalación de Entre Huellas compartida el 10 de octubre de 2026 tiene
Auth, Kong, Storage, PostgREST, Studio, Meta y Postgres, pero no functions.
Patch012 fue aplicado según el usuario; no instala el servicio ni el WASM.

`functions.compose.yml` se añade a services. Añadir `functions-deno-cache:`
al bloque volumes raíz existente. Usa las variables ANON_KEY y SERVICE_ROLE_KEY
del servidor, sin copiarlas a Flutter. La imagen se fija a edge-runtime1.76.2,
versión consultada en el Compose oficial; su funcionamiento aquí aún requiere
prueba remota. No publicar puerto9000 ni añadir dominio independiente en Dokploy.

Preparar magick.wasm como indica ../functions/pet-photo-process/README.md.
Desde raíz: `./supabase/self-hosted/Build-PhotoBundle.ps1`.
El parámetro opcional `-ComposePath <archivo>` genera también una copia del
Compose con functions y su volumen, conservando los servicios originales.
El resultado ignorado por Git está en work/dokploy-photos. No empaqueta claves,
node_modules, caché, pruebas ni configuración de Flutter.

Antes de instalar, localizar el volumen real en el host, sin volcar env:

```bash
docker inspect entrehuellas-supabase-bmcwgm-kong-1 --format '{{range .Mounts}}{{println .Source "->" .Destination}}{{end}}'
docker exec entrehuellas-supabase-bmcwgm-kong-1 grep -n -A 18 'name: functions-v1' /home/kong/temp.yml
```

La ruta al directorio `api` mostrada por inspect permite identificar su padre
`volumes`; no asumir una ruta de Dokploy. Copiar el tar.gz al host por SCP/SFTP
y extraerlo en ese directorio padre de api (creará functions). Comprobar antes
si existe functions y conservar su contenido. No reemplazar routers de una
instalación con otras funciones: este router solo admite pet-photo-process.

Comprobar que Kong envía /functions/v1/ a http://functions:9000/ y preserva
Authorization. Si la ruta no existe, preparar la adición sobre su fuente
kong.yml actual, conservando rutas y transformación de claves existentes.
No reemplazar todo Kong por un ejemplo de otra versión.

Diagnóstico aportado posteriormente por el usuario: el bind mount es
`/etc/dokploy/compose/entrehuellas-supabase-bmcwgm/files/volumes/api/kong.yml`.
Ya existe functions-v1 hacia `http://functions:9000/`, strip_path true,
prefijo `/functions/v1/` y plugin cors sin transformación local de Authorization.
No hace falta añadir ni reemplazar esa ruta para esta activación.
El destino del paquete es por tanto
`/etc/dokploy/compose/entrehuellas-supabase-bmcwgm/files/volumes/`:
el tar.gz crea allí `functions/main` y `functions/pet-photo-process`.
Antes de extraer, conservar una copia si ese directorio functions ya existe.
Subir el paquete desde Windows con SCP/SFTP a `/root/entrehuellas-functions.tar.gz`;
usar la IP/dominio real empleado para SSH, no asumir que el dominio de la API
acepta SSH. Después de extraer, guardar el Compose completo generado en Dokploy
y desplegar. Inspeccionar logs y hacer POST anónimo al endpoint:401 verifica
solo el router; aún se necesita una foto autenticada para probar el worker/WASM.

Una vez copiados los archivos y revisada esa ruta, guardar el Compose preparado
en Dokploy y desplegar. Consultar logs de functions y comprobar que no hay
BOOT_ERROR/imports/WASM ausente. El main crea un worker aislado de la función,
con import map explícito para las dependencias fijadas. El handler valida
Auth.getUser y propietario; el router no reemplaza esa autorización. Solo se
transmiten las tres variables de Supabase necesarias al worker. Límite inicial
256MiB y60s: ajustar según medición remota, no afirmar cuotas por prueba local.

Primero probar que POST sin sesión responde401 (no404/502/503). Esto verifica
ruta/router pero no que el worker decodifique. Con sesión de usuario, probar
subida real, principal/reinicio/retirada, separación A/B y EXIF/GPS de salidas.
El servidor procesa automáticamente al subir desde Flutter; nadie ejecuta
magick.wasm por separado. No hay despliegue remoto realizado por el agente.

### Corrección de archivo estático al crear el worker

La primera subida remota falló con NotFound bajo
`/var/tmp/sb-compile-edge-runtime/pet-photo-process/assets/magick.wasm`, pese
a existir el WASM en el bind mount. Edge Runtime compila la función en un FS
virtual: main/index.ts debe pasar `staticPatterns` a userWorkers.create,
incluyendo el archivo `/home/deno/functions/pet-photo-process/assets/magick.wasm`.
El código y paquete ahora lo incluyen. La ruta absoluta evita depender del cwd.
No cambiar processor.ts a una ruta absoluta: debe seguir leyendo junto a su
módulo dentro del FS virtual. No es necesario reaplicar SQL ni modificar Kong.

Para una instalación existente, subir solo el main/index.ts corregido por SCP
a un archivo temporal en /root, conservar copia del main anterior, reemplazar
`files/volumes/functions/main/index.ts` en el host y reiniciar el contenedor
functions. La confirmación exige volver a guardar una foto desde Android;
HTTP401 sin sesión no arranca ese worker ni comprueba el WASM.

Referencia de la versión desplegada:
[staticPatterns en edge-runtime1.76.2](https://github.com/supabase/edge-runtime/blob/v1.76.2/examples/main/index.ts),
[inclusión en ESZIP](https://github.com/supabase/edge-runtime/blob/v1.76.2/crates/deno_facade/eszip/mod.rs).

Referencias: [funciones autohospedadas](https://supabase.com/docs/guides/self-hosting/self-hosted-functions),
[Compose oficial](https://github.com/supabase/supabase/blob/master/docker/docker-compose.yml).
# Recuperación de conexiones de PostgREST

**Indicación retirada para el incidente actual:** el usuario objetó los pasos operacionales y no se ejecutó un reinicio por el agente. No seguir el reinicio como próximo paso sobre las capturas existentes. La lectura de fotos se recuperó mediante reconsulta Android; publicación y causa definitiva siguen pendientes. El script se conserva como artefacto de la propuesta anterior, no como activación obligatoria ni reparación confirmada.

Para el incidente de publicación bloqueada del10 de octubre, `restart-rest-connections.sh` reinicia solo el contenedor con labels de proyecto `entrehuellas-supabase-bmcwgm` y servicio `rest`. Exige una única coincidencia en ejecución e imagen postgrest/postgrest; si falla la selección, muestra nombres/imágenes y no reinicia otro servicio. Ejecutar en el servidor con Bash y acceso Docker. Interrumpe trabajo API pendiente y revierte transacciones no confirmadas de las conexiones cerradas; publicaciones confirmadas se conservan. No usar un redeploy completo ni modificar Compose/credenciales para esta recuperación. El patch015 ya fue aplicado según el usuario; no repetir SQL ni subir fotos. Después comprobar diagnóstico sin cadena, consultar Mis casos y probar una publicación una sola vez. Reinicio preparado, no ejecutado remotamente por el agente; origen definitivo del bloqueo pendiente.
