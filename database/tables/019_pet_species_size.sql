alter table public.pets add column if not exists species_detail text;
alter table public.pets add column if not exists size text;
do $$ begin
  if not exists(select 1 from pg_catalog.pg_constraint where conrelid='public.pets'::regclass and conname='pets_species_detail_check') then
    alter table public.pets add constraint pets_species_detail_check check(species_detail is null or (species='other' and char_length(species_detail) between 1 and 60 and species_detail=public.pet_trim(species_detail)));
  end if;
  if not exists(select 1 from pg_catalog.pg_constraint where conrelid='public.pets'::regclass and conname='pets_size_check') then
    alter table public.pets add constraint pets_size_check check(size is null or size in ('small','medium','large'));
  end if;
end; $$;
-- Legacy other-species rows may remain unspecified; all new v2 writes validate detail.
