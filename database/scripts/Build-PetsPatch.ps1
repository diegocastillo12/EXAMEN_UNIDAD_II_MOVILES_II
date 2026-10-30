[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$databaseRoot = Split-Path -Parent $PSScriptRoot
$repositoryRoot = Split-Path -Parent $databaseRoot
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/005_pets.json'
$migrationPath = Join-Path $repositoryRoot 'supabase/migrations/20261008000500_pets.sql'
$patchDirectory = Join-Path $databaseRoot 'patchs'
$null = New-Item -ItemType Directory -Path $patchDirectory -Force
$header = "-- GENERATED manual patch; regenerate with database/scripts/Build-PetsPatch.ps1.`n-- HU-03.1/RF-03 and metadata editing part of HU-03.2. Execute entire file in development SQL Editor.`n"
$sql = [IO.File]::ReadAllText($migrationPath).Replace("`r`n", "`n")
[IO.File]::WriteAllText((Join-Path $patchDirectory '005_patch_pets.sql'), $header + $sql, (New-Object Text.UTF8Encoding($false)))
Write-Output 'Generado database/patchs/005_patch_pets.sql.'
