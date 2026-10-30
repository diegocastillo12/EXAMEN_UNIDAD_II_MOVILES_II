create or replace function public.owns_pet_photo_rendition(p_name text,p_read boolean)
returns boolean language sql stable security definer set search_path='' as $$
    select exists(select 1 from public.pet_photos ph join public.pets p on p.id=ph.pet_id
        where ph.owner_id=auth.uid() and p.owner_id=auth.uid()
        and p_name=ph.owner_id::text||'/'||ph.pet_id::text||'/'||ph.id::text||'.jpg'
        -- Storage DELETE also needs SELECT visibility. A removing/deleting
        -- owner's metadata remains readable until cleanup finishes.
        and ((p_read and ph.status='published' and ph.processed_at is not null)
             or ph.status='removing' or p.deletion_requested_at is not null));
$$;
do $$ begin
    if not exists(select 1 from pg_catalog.pg_policy where polrelid='storage.objects'::regclass and polname='pet_renditions_owner_read') then
        create policy pet_renditions_owner_read on storage.objects for select to authenticated using(bucket_id in ('pet-photo-renditions','pet-photo-thumbnails') and public.owns_pet_photo_rendition(name,true));
        create policy pet_renditions_owner_delete on storage.objects for delete to authenticated using(bucket_id in ('pet-photo-renditions','pet-photo-thumbnails') and public.owns_pet_photo_rendition(name,false));
        create policy pet_renditions_read_guard on storage.objects as restrictive for select to authenticated using(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails') or public.owns_pet_photo_rendition(name,true));
        create policy pet_renditions_delete_guard on storage.objects as restrictive for delete to authenticated using(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails') or public.owns_pet_photo_rendition(name,false));
        create policy pet_legacy_photos_delete_guard on storage.objects as restrictive for delete to authenticated using(bucket_id<>'pet-photos' or public.owns_pet_photo_rendition(name,false));
        create policy pet_renditions_insert_guard on storage.objects as restrictive for insert to authenticated with check(bucket_id not in ('pet-photos','pet-photo-renditions','pet-photo-thumbnails'));
        create policy pet_renditions_update_guard on storage.objects as restrictive for update to authenticated using(bucket_id not in ('pet-photos','pet-photo-renditions','pet-photo-thumbnails')) with check(bucket_id not in ('pet-photos','pet-photo-renditions','pet-photo-thumbnails'));
        create policy pet_renditions_anon_guard on storage.objects as restrictive for all to anon using(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails')) with check(bucket_id not in ('pet-photo-renditions','pet-photo-thumbnails'));
    end if;
end; $$;
