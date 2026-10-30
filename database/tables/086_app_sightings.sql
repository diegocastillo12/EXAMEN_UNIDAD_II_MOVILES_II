-- A sighting belongs to a case even when no QR has been generated.
alter table public.public_sightings drop constraint if exists public_sightings_case_source_case_id_fkey;
alter table public.public_sightings add column if not exists reporter_id uuid references auth.users(id);
-- Case existence/visibility is checked under row locks by the shared command.
