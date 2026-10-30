param(
    [string]$Device = 'emulator-5554',
    [string]$Account = ''
)

$ErrorActionPreference = 'Stop'
$adbExecutable = Join-Path $env:LOCALAPPDATA 'Android/sdk/platform-tools/adb.exe'
if (-not (Test-Path -LiteralPath $adbExecutable)) {
    throw 'No se encontro adb.exe en el Android SDK local.'
}
$package = 'com.example.flutter_application_entrehuellas'
Write-Host 'Archivos privados guardados por Entre Huellas (APK debug):'
Write-Host "adb -s $Device shell run-as $package find . -name cases.json"
$files = @(& $adbExecutable -s $Device shell run-as $package find . -name cases.json)
if ($LASTEXITCODE -ne 0) {
    throw 'Primero abre Guardados y pulsa Guardar sin conexion con una lista de prueba.'
}
$paths = @($files | ForEach-Object { "$_".Trim() -replace '^\./', '' } | Where-Object {
    $_ -match '^files/offline_saved_cases/[A-Za-z0-9_-]+/cases\.json$'
})
if ($Account) {
    $paths = @($paths | Where-Object { $_ -eq "files/offline_saved_cases/$Account/cases.json" })
}
if ($paths.Count -eq 0) {
    Write-Host 'Todavia no hay una lista guardada para esa cuenta.'
    Write-Host 'Con internet: abre Guardados, agrega favoritos si esta vacio y pulsa Guardar sin conexion.'
    Write-Host 'Espera el aviso Lista guardada sin conexion en este telefono y ejecuta este script otra vez.'
    return
}
if ($paths.Count -gt 1) {
    $paths | ForEach-Object { Write-Host $_ }
    throw 'Hay varias cuentas. Repite con -Account ID_DE_LA_CUENTA_DE_PRUEBA.'
}
$file = $paths[0]
Write-Host "adb -s $Device shell run-as $package cat $file"
$contents = @(& $adbExecutable -s $Device shell run-as $package cat $file)
if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer el archivo privado.' }
$contents | Write-Output
try {
    $envelope = ($contents -join "`n") | ConvertFrom-Json
    if ($envelope.version -eq 2 -and $envelope.algorithm -eq 'AES-256-GCM') {
        $sealedBytes = [Convert]::FromBase64String($envelope.sealed)
        if ($sealedBytes.Length -lt 28) { throw 'Sobre cifrado incompleto.' }
        $iv = [Convert]::ToBase64String([byte[]]$sealedBytes[0..11])
        Write-Host "Formato cifrado AES-256-GCM. IV publico de este guardado: $iv"
        Write-Host 'El archivo no contiene la clave; Android Keystore la custodia.'
    }
} catch {
    Write-Host 'No se pudo interpretar el formato del archivo mostrado.'
}
