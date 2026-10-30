[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$databaseRoot = Split-Path -Parent $PSScriptRoot
$repositoryRoot = Split-Path -Parent $databaseRoot
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/004_profile_avatars_managed_storage.json'
$migrationPath = Join-Path $repositoryRoot 'supabase/migrations/20261008000400_profile_avatars_managed_storage.sql'
$patchDirectory = Join-Path $databaseRoot 'patchs'
$null = New-Item -ItemType Directory -Path $patchDirectory -Force
$patchPath = Join-Path $patchDirectory '004_patch_profile_avatars.sql'
$header = "-- GENERATED manual patch; regenerate with database/scripts/Build-AvatarPatch.ps1.`n-- Execute ALL content in Supabase SQL Editor, role postgres, without selecting fragments.`n-- Replaces failed 20261008000300 avatar setup; also repeatable if already configured.`n"
$sql = [IO.File]::ReadAllText($migrationPath).Replace("`r`n", "`n")
[IO.File]::WriteAllText($patchPath, $header + $sql, (New-Object Text.UTF8Encoding($false)))
Write-Output 'Generado database/patchs/004_patch_profile_avatars.sql.'
