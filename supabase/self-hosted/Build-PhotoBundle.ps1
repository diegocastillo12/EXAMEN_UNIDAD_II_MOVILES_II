param([string]$ComposePath)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$photoRoot = Join-Path $repoRoot 'supabase/functions/pet-photo-process'
$wasmPath = Join-Path $photoRoot 'assets/magick.wasm'
if (-not (Test-Path -LiteralPath $wasmPath)) {
    throw 'Preparar magick.wasm antes de generar el paquete.'
}
$outputRoot = Join-Path $repoRoot 'work/dokploy-photos'
$bundleRoot = Join-Path $outputRoot 'functions'
$bundlePhotoRoot = Join-Path $bundleRoot 'pet-photo-process'
New-Item -ItemType Directory -Force -Path (Join-Path $bundlePhotoRoot 'assets'), (Join-Path $bundleRoot 'main') | Out-Null
foreach ($fileName in @('index.ts', 'processor.ts', 'deno.json', 'deno.lock')) {
    Copy-Item -LiteralPath (Join-Path $photoRoot $fileName) -Destination $bundlePhotoRoot -Force
}
Copy-Item -LiteralPath $wasmPath -Destination (Join-Path $bundlePhotoRoot 'assets/magick.wasm') -Force
foreach ($fileName in @('index.ts', 'router.ts')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot "main/$fileName") -Destination (Join-Path $bundleRoot 'main') -Force
}
Copy-Item -LiteralPath (Join-Path $photoRoot 'deno.json') -Destination (Join-Path $bundleRoot 'deno.json') -Force
$archivePath = Join-Path $outputRoot 'entrehuellas-functions.tar.gz'
& tar -czf $archivePath -C $outputRoot functions
if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar el paquete.' }

if ($ComposePath) {
    $compose = Get-Content -LiteralPath $ComposePath -Raw
    if ($compose -match '(?m)^  functions:' -or $compose -match '(?m)^  functions-deno-cache:') {
        throw 'El Compose ya contiene functions o functions-deno-cache; revisar sin duplicar.'
    }
    if ([regex]::Matches($compose, '(?m)^volumes:\s*\r?$').Count -ne 1) {
        throw 'Se esperaba un único bloque volumes raíz.'
    }
    $snippet = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'functions.compose.yml') -Raw
    $snippet = ($snippet -split '# Añadir functions-deno-cache:')[0].TrimEnd()
    $compose = [regex]::Replace($compose, '(?m)^volumes:\s*\r?$', $snippet + "`n`nvolumes:`n  functions-deno-cache:")
    $composePathOut = Join-Path $outputRoot 'compose.dokploy.yml'
    [System.IO.File]::WriteAllText($composePathOut, $compose, [System.Text.UTF8Encoding]::new($false))
    Write-Output "Compose preparado: $composePathOut"
}
Write-Output "Paquete preparado: $archivePath"
