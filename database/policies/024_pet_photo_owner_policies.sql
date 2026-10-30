alter table public.pet_photos enable row level security;
create or replace function public.owns_pet_photo_path(p_name text) returns boolean language sql stable security definer set search_path='' as $$
  select exists(select 1 from public.pet_photos ph join public.pets p on p.id=ph.pet_id where p.owner_id=auth.uid() and ph.owner_id=auth.uid() and p_name=ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg');
$$;
do $$ begin
  if not exists(select 1 from pg_catalog.pg_class where oid='storage.objects'::regclass and relrowsecurity) then raise exception 'Storage RLS must already be enabled'; end if;
  if not exists(select 1 from pg_catalog.pg_policy where polrelid='public.pet_photos'::regclass and polname='pet_photos_select_own') then
    create policy pet_photos_select_own on public.pet_photos for select to authenticated using(owner_id=(select auth.uid()));
  end if;
  if not exists(select 1 from pg_catalog.pg_policy where polrelid='storage.objects'::regclass and polname='pet_photos_account_guard') then
    create policy pet_photos_account_guard on storage.objects as restrictive for all to authenticated using(bucket_id<>'pet-photos' or public.owns_pet_photo_path(name)) with check(bucket_id<>'pet-photos' or public.owns_pet_photo_path(name));
  end if;
  if not exists(select 1 from pg_catalog.pg_policy where polrelid='storage.objects'::regclass and polname='pet_photos_anon_guard') then
    create policy pet_photos_anon_guard on storage.objects as restrictive for all to anon using(bucket_id<>'pet-photos') with check(bucket_id<>'pet-photos');
  end if;
  if not exists(select 1 from pg_catalog.pg_policy where polrelid='storage.objects'::regclass and polname='pet_photos_objects_own') then
    create policy pet_photos_objects_own on storage.objects for all to authenticated using(bucket_id='pet-photos' and public.owns_pet_photo_path(name)) with check(bucket_id='pet-photos' and public.owns_pet_photo_path(name));
  end if;
end; $$;
