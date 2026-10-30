[CmdletBinding()]
param(
    [string]$KeystorePath,
    [string]$KeyAlias = 'entrehuellas',
    [switch]$ExportOnly
)

$ErrorActionPreference = 'Stop'
$mobileRoot = Split-Path $PSScriptRoot -Parent
if (-not $KeystorePath) {
    $KeystorePath = Join-Path $mobileRoot 'android/keystore/entrehuellas-release.jks'
}
$KeystorePath = [IO.Path]::GetFullPath($KeystorePath)
$keytoolCommand = Get-Command keytool -ErrorAction SilentlyContinue
$keytoolPath = if ($keytoolCommand) { $keytoolCommand.Source } else {
    $androidKeytool = Join-Path ${env:ProgramFiles} 'Android/Android Studio/jbr/bin/keytool.exe'
    if (-not (Test-Path -LiteralPath $androidKeytool)) {
        throw 'No se encuentra keytool. Instala JDK 17 o Android Studio y agrega keytool al PATH.'
    }
    $androidKeytool
}

if (-not $ExportOnly) {
    if (Test-Path -LiteralPath $KeystorePath) {
        throw 'El keystore ya existe. No se sobrescribe. Usa -ExportOnly para exportar el existente.'
    }
    New-Item -ItemType Directory -Path (Split-Path $KeystorePath -Parent) -Force | Out-Null
    Write-Host 'Keytool pedira contrasena y datos del certificado. Guarda la contrasena y el alias.'
    Write-Host 'Si usas la misma contrasena para la clave, repitela en ambos secrets de GitHub.'
    & $keytoolPath -genkeypair -v -storetype JKS -keystore $KeystorePath `
        -alias $KeyAlias -keyalg RSA -keysize 3072 -validity 10000
    if ($LASTEXITCODE -ne 0) { throw 'Keytool no pudo generar la firma.' }
}
if (-not (Test-Path -LiteralPath $KeystorePath -PathType Leaf)) {
    throw 'No existe el keystore para exportar.'
}
$exportDirectory = Join-Path $mobileRoot 'build/android-signing'
New-Item -ItemType Directory -Path $exportDirectory -Force | Out-Null
$exportPath = Join-Path $exportDirectory 'keystore-base64.txt'
[IO.File]::WriteAllText($exportPath, [Convert]::ToBase64String([IO.File]::ReadAllBytes($KeystorePath)))
Write-Host "Keystore: $KeystorePath"
Write-Host "Alias: $KeyAlias"
Write-Host "Secret ANDROID_KEYSTORE_BASE64: copia el contenido de $exportPath"
Write-Host 'Respalda keystore, alias y contrasenas fuera del repositorio. Base64 tambien es privado.'
