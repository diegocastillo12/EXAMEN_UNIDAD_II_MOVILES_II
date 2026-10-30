
create or replace function public.can_write_pet_photo_path(p_name text) returns boolean language plpgsql security definer set search_path='' as $$
begin
  -- The parent lock makes Storage metadata writes serialize with begin/finish.
  perform 1 from public.pet_photos ph join public.pets p on p.id=ph.pet_id where ph.owner_id=auth.uid() and p.owner_id=auth.uid() and p.deletion_requested_at is null and p_name=ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg' for share of p;
  return found;
end;
$$;
do $$ begin
  if not exists(select 1 from pg_catalog.pg_policy where polrelid='storage.objects'::regclass and polname='pet_photos_write_guard') then
    create policy pet_photos_write_guard on storage.objects as restrictive for insert to authenticated with check(bucket_id<>'pet-photos' or public.can_write_pet_photo_path(name));
  end if;
  if not exists(select 1 from pg_catalog.pg_policy where polrelid='storage.objects'::regclass and polname='pet_photos_update_guard') then
    create policy pet_photos_update_guard on storage.objects as restrictive for update to authenticated using(bucket_id<>'pet-photos' or public.can_write_pet_photo_path(name)) with check(bucket_id<>'pet-photos' or public.can_write_pet_photo_path(name));
  end if;
end; $$;
