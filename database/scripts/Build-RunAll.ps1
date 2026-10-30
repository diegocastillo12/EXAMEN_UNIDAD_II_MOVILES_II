[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$databaseRoot = Split-Path -Parent $PSScriptRoot
$plan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/001_auth_profiles.json') -Raw | ConvertFrom-Json
$expectedSources = @(
    'tables/001_create_profiles.sql',
    'functions/002_handle_new_auth_user.sql',
    'functions/003_set_profile_updated_at.sql',
    'triggers/004_profiles_auth_triggers.sql',
    'policies/005_profiles_owner_policies.sql',
    'grants/006_profiles_permissions.sql',
    'tables/007_backfill_existing_profiles.sql'
)
if (($plan.sources -join '|') -ne ($expectedSources -join '|')) {
    throw 'El plan cambió. Revisar cómo repetir cada nueva operación antes de ampliar run_all.'
}
# Validate immutable migrations without rewriting the existing manual patches.
# Generate a specific patch with its own Build-*Patch.ps1 when explicitly needed.
& (Join-Path $PSScriptRoot 'Build-Migration.ps1')
$onboardingPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/002_onboarding.json') -Raw | ConvertFrom-Json
if (($onboardingPlan.sources -join '|') -ne 'tables/008_add_onboarding_completion.sql|functions/009_complete_onboarding.sql') {
    throw 'Revisar repetición de las nuevas operaciones de onboarding.'
}
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/002_onboarding.json'
$avatarPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/004_profile_avatars_managed_storage.json') -Raw | ConvertFrom-Json
if (($avatarPlan.sources -join '|') -ne 'tables/010_create_profile_avatar_bucket.sql|policies/012_profile_avatar_managed_storage.sql') { throw 'Revisar repetición de las operaciones de avatar.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/004_profile_avatars_managed_storage.json'
$petsPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/005_pets.json') -Raw | ConvertFrom-Json
if (($petsPlan.sources -join '|') -ne 'functions/013_pet_text_rules.sql|tables/014_create_pets.sql|indexes/015_pets_owner_created.sql|functions/016_pet_commands.sql|policies/017_pets_owner_policies.sql|grants/018_pets_permissions.sql') { throw 'Revisar repetición de las operaciones de mascotas.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/005_pets.json'
$galleryPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/006_pet_gallery.json') -Raw | ConvertFrom-Json
if(($galleryPlan.sources -join '|') -ne 'tables/019_pet_species_size.sql|functions/020_pet_commands_v2.sql|tables/021_pet_photos.sql|functions/022_pet_photo_commands.sql|tables/023_pet_photo_bucket.sql|policies/024_pet_photo_owner_policies.sql|grants/025_pet_gallery_permissions.sql'){throw 'Revisar repetición del incremento de galería.'}
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/006_pet_gallery.json'

$deletionPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/007_pet_deletion.json') -Raw | ConvertFrom-Json
if(($deletionPlan.sources -join '|') -ne 'tables/026_pet_deletion_marker.sql|functions/027_pet_deletion_commands.sql|policies/028_pet_deletion_storage_guard.sql|grants/029_pet_deletion_permissions.sql'){throw 'Revisar repetición de eliminación de mascotas.'}
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/007_pet_deletion.json'

$archivingPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/008_pet_archiving.json') -Raw | ConvertFrom-Json
if(($archivingPlan.sources -join '|') -ne 'tables/030_pet_archiving.sql|functions/031_pet_lifecycle_commands.sql|triggers/032_pet_case_history_guard.sql|grants/033_pet_lifecycle_permissions.sql'){throw 'Revisar repetición de archivado de mascotas.'}
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/008_pet_archiving.json'

$requiredFieldsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/009_pet_required_fields.json') -Raw | ConvertFrom-Json
if(($requiredFieldsPlan.sources -join '|') -ne 'functions/034_validate_pet_required_fields.sql|triggers/035_pet_required_fields_guard.sql'){throw 'Revisar repetición de validación obligatoria de mascotas.'}
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/009_pet_required_fields.json'
$zonesPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/010_interest_zones.json') -Raw | ConvertFrom-Json
if (($zonesPlan.sources -join '|') -ne 'tables/036_create_interest_zones.sql|functions/037_interest_zone_commands.sql|policies/038_interest_zone_owner_policies.sql|grants/039_interest_zone_permissions.sql') { throw 'Revisar repetición de zonas de interés.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/010_interest_zones.json'
$preferencesPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/011_alert_preferences.json') -Raw | ConvertFrom-Json
if (($preferencesPlan.sources -join '|') -ne 'tables/040_create_alert_preferences.sql|functions/041_save_alert_preferences.sql|policies/042_alert_preferences_owner_policies.sql|grants/043_alert_preferences_permissions.sql') { throw 'Revisar repetición de preferencias de alertas.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/011_alert_preferences.json'
$photoProcessingPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/012_pet_photo_processing.json') -Raw | ConvertFrom-Json
if (($photoProcessingPlan.sources -join '|') -ne 'tables/044_pet_photo_processing.sql|functions/045_pet_photo_processing_commands.sql|policies/046_pet_photo_processing_policies.sql|grants/047_pet_photo_processing_permissions.sql') { throw 'Revisar repetición del procesamiento de fotos.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/012_pet_photo_processing.json'

$lostCasesPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/013_lost_cases.json') -Raw | ConvertFrom-Json
if (($lostCasesPlan.sources -join '|') -ne 'tables/048_lost_cases.sql|functions/049_lost_case_commands.sql|policies/050_lost_case_policies.sql|grants/051_lost_case_permissions.sql') { throw 'Revisar repetición de casos perdidos.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/013_lost_cases.json'

$foundCasesPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/014_found_cases.json') -Raw | ConvertFrom-Json
if (($foundCasesPlan.sources -join '|') -ne 'tables/052_found_cases.sql|functions/053_found_case_commands.sql|policies/054_found_case_policies.sql|grants/055_found_case_permissions.sql') { throw 'Revisar repetición de casos encontrados.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/014_found_cases.json'

$lostCaseLockTimeoutPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/015_lost_case_lock_timeout.json') -Raw | ConvertFrom-Json
if (($lostCaseLockTimeoutPlan.sources -join '|') -ne 'functions/056_lost_case_lock_timeout.sql') { throw 'Revisar repetición del límite de bloqueos de publicación.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/015_lost_case_lock_timeout.json'

$caseCollectionsPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/016_case_collections.json') -Raw | ConvertFrom-Json
if (($caseCollectionsPlan.sources -join '|') -ne 'tables/057_case_deletion.sql|functions/058_case_collection_commands.sql|policies/059_case_deletion_visibility.sql|grants/060_case_collection_permissions.sql') { throw 'Revisar repetición de listas/eliminación de casos.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/016_case_collections.json'

$foundCaseLockTimeoutPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/017_found_case_lock_timeout.json') -Raw | ConvertFrom-Json
if (($foundCaseLockTimeoutPlan.sources -join '|') -ne 'functions/061_found_case_lock_timeout.sql') { throw 'Revisar repetición del límite de bloqueos de encontrados.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/017_found_case_lock_timeout.json'

$notificationsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/027_notifications.json') -Raw | ConvertFrom-Json
if (($notificationsPlan.sources -join '|') -ne 'tables/091_notifications.sql|functions/092_notification_commands.sql|functions/093_push_delivery_commands.sql|triggers/094_notification_events.sql|grants/095_notification_permissions.sql') { throw 'Revisar repetición de seguimiento, bandeja y entrega push.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/027_notifications.json'
$closurePlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/028_case_closure.json') -Raw | ConvertFrom-Json
if (($closurePlan.sources -join '|') -ne 'tables/096_case_closures.sql|functions/097_case_closure_commands.sql|grants/098_case_closure_permissions.sql') { throw 'Revisar repeticion del cierre de casos.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/028_case_closure.json'
$reportsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/029_content_reports.json') -Raw | ConvertFrom-Json
if (($reportsPlan.sources -join '|') -ne 'tables/099_content_reports.sql|functions/100_content_report_commands.sql|grants/101_content_report_permissions.sql') { throw 'Revisar repeticion de denuncias.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/029_content_reports.json'
$moderationPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/030_content_moderation.json') -Raw | ConvertFrom-Json
if (($moderationPlan.sources -join '|') -ne 'tables/102_content_moderation.sql|functions/103_moderation_commands.sql|functions/104_moderation_visibility.sql|grants/105_moderation_permissions.sql') { throw 'Revisar repeticion de moderacion.' }
& (Join-Path $PSScriptRoot 'Build-ModerationPatch.ps1')
$contactPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/031_case_contacts.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/031_case_contacts.json'
$sharingPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/032_case_sharing.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-CaseSharingPatch.ps1')
$appealsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/035_moderation_appeals.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/035_moderation_appeals.json'
$profilePhonePlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/033_profile_contact_phone.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-ProfileContactPhonePatch.ps1')
$userBlocksPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/034_user_blocks.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-UserBlocksPatch.ps1')
$blockedContactsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/036_block_case_contacts.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-BlockCaseContactsPatch.ps1')
$businessConflictsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/037_recovery_business_conflicts.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-RecoveryBusinessConflictsPatch.ps1')
$nestedBusinessConflictsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/038_recovery_nested_business_conflicts.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-RecoveryNestedBusinessConflictsPatch.ps1')
$pilotStatisticsPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/039_pilot_statistics.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-PilotStatisticsPatch.ps1')
$caseMatchingPlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/040_case_matching.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-CaseMatchingPatch.ps1')
function Protect-Creation([string]$Condition, [string]$Sql) {
    return 'do $run_all_object$' + "`n" + 'begin' + "`n" +
        "    if $Condition then`n$Sql`n    end if;`n" +
        'end;' + "`n" + '$run_all_object$;'
}

$recoveryPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/018_recovery_report_links.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/018_recovery_report_links.json'
$explorePlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/019_explore_cases.json') -Raw | ConvertFrom-Json
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/019_explore_cases.json'
$savedCasesPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/020_saved_cases.json') -Raw | ConvertFrom-Json
if (($savedCasesPlan.sources -join '|') -ne 'tables/070_saved_cases.sql|functions/071_saved_case_commands.sql|policies/072_saved_cases_owner_policies.sql|grants/073_saved_cases_permissions.sql') { throw 'Revisar repetición del incremento de casos guardados.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/020_saved_cases.json'
$savedCasesListPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/021_saved_case_list.json') -Raw | ConvertFrom-Json
if (($savedCasesListPlan.sources -join '|') -ne 'indexes/074_saved_cases_order.sql|functions/075_list_saved_cases.sql|grants/076_saved_case_list_permissions.sql') { throw 'Revisar repetición del listado de guardados.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/021_saved_case_list.json'
$postersPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/022_case_posters.json') -Raw | ConvertFrom-Json
if (($postersPlan.sources -join '|') -ne 'tables/077_case_public_links.sql|functions/078_prepare_case_poster.sql|grants/079_case_poster_permissions.sql') { throw 'Revisar repetición de enlaces de cartel.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/022_case_posters.json'
$publicQrPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/023_public_qr_case.json') -Raw | ConvertFrom-Json
if (($publicQrPlan.sources -join '|') -ne 'functions/080_read_qr_case.sql|functions/081_revoke_case_public_link.sql|grants/082_qr_case_permissions.sql') { throw 'Revisar repetición de lectura pública de QR.' }
$publicSightingsPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/024_public_sightings.json') -Raw | ConvertFrom-Json
if (($publicSightingsPlan.sources -join '|') -ne 'tables/083_public_sightings.sql|functions/084_submit_public_sighting.sql|grants/085_public_sighting_permissions.sql') { throw 'Revisar repetición de avistamientos públicos.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/024_public_sightings.json'
$appSightingsPlan = Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/025_app_sightings.json') -Raw | ConvertFrom-Json
if (($appSightingsPlan.sources -join '|') -ne 'tables/086_app_sightings.sql|functions/087_shared_sighting_commands.sql') { throw 'Revisar repetición de avistamientos Android.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/025_app_sightings.json'
$timelinePlan=Get-Content -LiteralPath (Join-Path $databaseRoot 'migration_plans/026_case_timeline.json') -Raw | ConvertFrom-Json
if (($timelinePlan.sources -join '|') -ne 'tables/088_sighting_reviews.sql|functions/089_case_timeline_commands.sql|grants/090_case_timeline_permissions.sql') { throw 'Revisar repetición de cronología/revisión.' }
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/026_case_timeline.json'
& (Join-Path $PSScriptRoot 'Build-Migration.ps1') -Plan 'migration_plans/023_public_qr_case.json'
$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('-- GENERATED by database/scripts/Build-RunAll.ps1. Do not edit independently.')
$lines.Add('-- HU-01 / RF-01,34. Re-runnable bootstrap for the current profiles increment.')
$lines.Add('-- Preserves user data and baseline objects; replays the reviewed onboarding RPC definition.')
$lines.Add('begin;')
$lines.Add("select pg_catalog.pg_advisory_xact_lock(734951, 1);")
$lines.Add(@'

-- IF NOT EXISTS alone does not validate an existing table. Fail before any modification.
do $run_all_validate$
declare
    profile_table oid := pg_catalog.to_regclass('public.profiles');
begin
    if profile_table is not null then
        if not exists (select 1 from pg_catalog.pg_class where oid = profile_table and relkind = 'r')
           or (select count(*) from pg_catalog.pg_attribute
               where attrelid = profile_table and attnum > 0 and not attisdropped) not in (5, 6, 7)
           or exists (select 1 from pg_catalog.pg_attribute where attrelid = profile_table
               and attnum > 0 and not attisdropped and attname not in
               ('id','display_name','city','created_at','updated_at','onboarding_completed_at','contact_phone'))
           or exists (select 1 from pg_catalog.pg_attribute where attrelid = profile_table
               and attname = 'contact_phone' and not attisdropped
               and (atttypid <> 'text'::regtype or attnotnull))
           or exists (select 1 from pg_catalog.pg_attribute where attrelid = profile_table
               and attname = 'onboarding_completed_at' and not attisdropped
               and (atttypid <> 'timestamp with time zone'::regtype or attnotnull))
           or exists (
               select 1 from (values
                   ('id', 'uuid'::regtype, true),
                   ('display_name', 'text'::regtype, false),
                   ('city', 'text'::regtype, false),
                   ('created_at', 'timestamp with time zone'::regtype, true),
                   ('updated_at', 'timestamp with time zone'::regtype, true)
               ) as expected(column_name, column_type, required)
               where not exists (
                   select 1 from pg_catalog.pg_attribute a
                   where a.attrelid = profile_table and a.attname = expected.column_name
                     and a.atttypid = expected.column_type and a.attnotnull = expected.required
                     and a.attnum > 0 and not a.attisdropped
               )
           ) then
            raise exception 'public.profiles has an incompatible structure; review before applying run_all';
        end if;
        if not exists (
            select 1 from pg_catalog.pg_constraint c
            where c.conrelid = profile_table and c.contype = 'p'
              and c.conkey = array[(select attnum from pg_catalog.pg_attribute
                                   where attrelid = profile_table and attname = 'id')]::smallint[]
        ) or not exists (
            select 1 from pg_catalog.pg_constraint c
            where c.conrelid = profile_table and c.contype = 'f'
              and c.confrelid = 'auth.users'::regclass and c.confdeltype = 'c'
              and c.conkey = array[(select attnum from pg_catalog.pg_attribute
                                   where attrelid = profile_table and attname = 'id')]::smallint[]
              and c.confkey = array[(select attnum from pg_catalog.pg_attribute
                                    where attrelid = 'auth.users'::regclass and attname = 'id')]::smallint[]
        ) or (select count(*) from pg_catalog.pg_constraint
              where conrelid = profile_table and contype = 'c' and convalidated
                and conname in ('profiles_display_name_length', 'profiles_city_length')) <> 2 then
            raise exception 'public.profiles is missing expected constraints; review before applying run_all';
        end if;
    end if;
end;
$run_all_validate$;
'@)

foreach ($relativePath in $expectedSources) {
    $sql = [IO.File]::ReadAllText((Join-Path $databaseRoot $relativePath)).Replace("`r`n", "`n").TrimEnd()
    $hashAlgorithm = [Security.Cryptography.SHA256]::Create()
    try { $hash = [BitConverter]::ToString($hashAlgorithm.ComputeHash([Text.Encoding]::UTF8.GetBytes($sql + "`n"))).Replace('-', '').ToLowerInvariant() }
    finally { $hashAlgorithm.Dispose() }
    $lines.Add("`n-- Source: database/$relativePath | normalized SHA256: $hash")
    switch ($relativePath) {
        'tables/001_create_profiles.sql' {
            $lines.Add($sql.Replace('create table public.profiles (', 'create table if not exists public.profiles ('))
        }
        { $_ -like 'functions/*' } {
            $signature = if ($_ -eq 'functions/002_handle_new_auth_user.sql') { 'public.handle_new_auth_user()' } else { 'public.set_profile_updated_at()' }
            $parts = $sql -split '(?m)^revoke all on function ', 2
            if ($parts.Count -ne 2) { throw 'Revisar generación de funciones y sus permisos.' }
            $lines.Add((Protect-Creation "pg_catalog.to_regprocedure('$signature') is null" $parts[0].TrimEnd()))
            $lines.Add('revoke all on function ' + $parts[1])
        }
        'triggers/004_profiles_auth_triggers.sql' {
            foreach ($statement in ($sql -split ';' | Where-Object { $_.Trim() })) {
                if ($statement -notmatch '(?s)^\s*create trigger ([a-z_]+)\s+(?:after|before)\s+insert on ([a-z_.]+)|^\s*create trigger ([a-z_]+)\s+before\s+update on ([a-z_.]+)') { throw 'Trigger no reconocido; revisar su repetición.' }
                $triggerName = if ($Matches[1]) { $Matches[1] } else { $Matches[3] }
                $tableName = if ($Matches[2]) { $Matches[2] } else { $Matches[4] }
                $condition = "not exists (select 1 from pg_catalog.pg_trigger where tgname = '$triggerName' and tgrelid = '$tableName'::regclass and not tgisinternal)"
                $lines.Add((Protect-Creation $condition ($statement.Trim() + ';')))
            }
        }
        'policies/005_profiles_owner_policies.sql' {
            foreach ($statement in ($sql -split ';' | Where-Object { $_.Trim() })) {
                if ($statement -notmatch '^\s*create policy ([a-z_]+)\s+on ([a-z_.]+)') { throw 'Política no reconocida; revisar su repetición.' }
                $condition = "not exists (select 1 from pg_catalog.pg_policy where polname = '$($Matches[1])' and polrelid = '$($Matches[2])'::regclass)"
                $lines.Add((Protect-Creation $condition ($statement.Trim() + ';')))
            }
        }
        default { $lines.Add($sql) } # Reviewed repeatable grants and ON CONFLICT DO NOTHING backfill.
    }
}
foreach ($relativePath in (@($onboardingPlan.sources) + @($avatarPlan.sources) + @($petsPlan.sources) + @($galleryPlan.sources) + @($deletionPlan.sources) + @($archivingPlan.sources) + @($requiredFieldsPlan.sources) + @($zonesPlan.sources) + @($preferencesPlan.sources) + @($photoProcessingPlan.sources) + @($lostCasesPlan.sources) + @($foundCasesPlan.sources) + @($lostCaseLockTimeoutPlan.sources) + @($caseCollectionsPlan.sources) + @($foundCaseLockTimeoutPlan.sources) + @($recoveryPlan.sources) + @($explorePlan.sources) + @($savedCasesPlan.sources) + @($savedCasesListPlan.sources) + @($postersPlan.sources) + @($publicQrPlan.sources) + @($publicSightingsPlan.sources) + @($appSightingsPlan.sources) + @($timelinePlan.sources) + @($notificationsPlan.sources) + @($closurePlan.sources) + @($reportsPlan.sources) + @($moderationPlan.sources) + @($contactPlan.sources) + @($sharingPlan.sources) + @($profilePhonePlan.sources) + @($userBlocksPlan.sources) + @($appealsPlan.sources) + @($blockedContactsPlan.sources) + @($businessConflictsPlan.sources) + @($nestedBusinessConflictsPlan.sources) + @($pilotStatisticsPlan.sources) + @($caseMatchingPlan.sources))) {
    $sql = [IO.File]::ReadAllText((Join-Path $databaseRoot $relativePath)).Replace("`r`n", "`n").TrimEnd()
    $hashAlgorithm = [Security.Cryptography.SHA256]::Create()
    try { $hash = [BitConverter]::ToString($hashAlgorithm.ComputeHash([Text.Encoding]::UTF8.GetBytes($sql + "`n"))).Replace('-', '').ToLowerInvariant() }
    finally { $hashAlgorithm.Dispose() }
    $lines.Add("`n-- Source: database/$relativePath | normalized SHA256: $hash")
    $lines.Add($sql)
}
$lines.Add("`ncommit;")
$outputPath = Join-Path $databaseRoot 'run_all.sql'
$content = ($lines -join "`n") + "`n"
[IO.File]::WriteAllText($outputPath, $content, (New-Object Text.UTF8Encoding($false)))
Write-Output 'Generado database/run_all.sql con perfiles, mascotas, casos, QR, avistamientos, cronología, alertas, contactos, bloqueos, apelaciones, estadísticas y coincidencias (001-010,012-134; fuente011 sustituida).'
