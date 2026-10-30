-- Service-only command: identity is validated by Auth in the Edge Function.
create or replace function public.prepare_pet_photo(p_owner uuid,p_pet_id uuid,p_id uuid,p_hash text)
returns setof public.pet_photos language plpgsql security definer set search_path='' as $$
declare v_photo public.pet_photos;
begin
    if p_owner is null or p_id is null or p_hash is null or p_hash !~ '^[0-9a-f]{64}$' then
        raise exception using errcode='23514',message='photo_invalid';
    end if;
    perform 1 from public.pets where id=p_pet_id and owner_id=p_owner and deletion_requested_at is null for update;
    if not found then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    if exists(select 1 from public.pet_photo_deletions where id=p_id) then
        raise exception using errcode='40001',message='photo_deleted';
    end if;
    select * into v_photo from public.pet_photos where id=p_id for update;
    if found then
        if v_photo.owner_id<>p_owner or v_photo.pet_id<>p_pet_id then raise exception using errcode='42501',message='photo_unauthorized'; end if;
        if v_photo.status='removing' or (v_photo.content_hash is not null and v_photo.content_hash<>p_hash) then raise exception using errcode='40001',message='photo_conflict'; end if;
        -- Legacy conversion requires explicit resubmission; it never becomes public by migration.
        if v_photo.content_hash is null then
            update public.pet_photos set content_hash=p_hash where id=p_id returning * into v_photo;
        end if;
        return next v_photo; return;
    end if;
    if (select count(*) from public.pet_photos where pet_id=p_pet_id)>=3 then raise exception using errcode='23514',message='photo_limit'; end if;
    insert into public.pet_photos(id,pet_id,owner_id,content_hash) values(p_id,p_pet_id,p_owner,p_hash) returning * into v_photo;
    return next v_photo;
end; $$;

create or replace function public.complete_pet_photo_processing(p_owner uuid,p_id uuid,p_hash text)
returns setof public.pet_photos language plpgsql security definer set search_path='' as $$
declare v_photo public.pet_photos; v_path text;
begin
    perform 1 from public.pets p join public.pet_photos ph on ph.pet_id=p.id
        where ph.id=p_id and p.owner_id=p_owner and p.deletion_requested_at is null for update of p;
    if not found then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    select * into v_photo from public.pet_photos where id=p_id and owner_id=p_owner for update;
    if not found then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    if v_photo.status='removing' or v_photo.content_hash is distinct from p_hash then raise exception using errcode='40001',message='photo_conflict'; end if;
    v_path:=p_owner::text||'/'||v_photo.pet_id::text||'/'||p_id::text||'.jpg';
    if (select count(*) from storage.objects where name=v_path and (
        (bucket_id='pet-photo-renditions' and metadata->>'mimetype'='image/jpeg' and (metadata->>'size')::bigint between 4 and 2097152) or
        (bucket_id='pet-photo-thumbnails' and metadata->>'mimetype'='image/jpeg' and (metadata->>'size')::bigint between 4 and 262144)
    ))<>2 then raise exception using errcode='P0002',message='photo_incomplete'; end if;
    update public.pet_photos set status='published',processed_at=coalesce(processed_at,clock_timestamp()) where id=p_id returning * into v_photo;
    if not exists(select 1 from public.pet_photos where pet_id=v_photo.pet_id and is_primary) then
        update public.pet_photos set is_primary=true where id=p_id returning * into v_photo;
        update public.pets set photo_selection_version=photo_selection_version+1 where id=v_photo.pet_id;
    end if;
    return next v_photo;
end; $$;

create or replace function public.list_pet_photos(p_pet_id uuid)
returns table(id uuid,pet_id uuid,owner_id uuid,status text,is_primary boolean,processed_at timestamptz,selection_version integer)
language plpgsql security definer set search_path='' as $$
begin
    if auth.uid() is null or not exists(select 1 from public.pets where pets.id=p_pet_id and pets.owner_id=auth.uid()) then
        raise exception using errcode='42501',message='photo_unauthorized';
    end if;
    return query select ph.id,ph.pet_id,ph.owner_id,ph.status,ph.is_primary,ph.processed_at,p.photo_selection_version
        from public.pet_photos ph join public.pets p on p.id=ph.pet_id
        where ph.pet_id=p_pet_id and ph.owner_id=auth.uid() order by ph.is_primary desc,ph.created_at,ph.id;
end; $$;

create or replace function public.set_primary_pet_photo(p_pet_id uuid,p_photo_id uuid,p_expected_version integer)
returns void language plpgsql security definer set search_path='' as $$
declare v_pet public.pets;
begin
    select * into v_pet from public.pets where id=p_pet_id and owner_id=auth.uid() and deletion_requested_at is null for update;
    if not found then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    if not exists(select 1 from public.pet_photos where id=p_photo_id and pet_id=p_pet_id and owner_id=auth.uid() and status='published') then
        raise exception using errcode='42501',message='photo_unauthorized';
    end if;
    if p_expected_version is null or p_expected_version<0 then raise exception using errcode='40001',message='photo_conflict'; end if;
    if v_pet.photo_selection_version<>p_expected_version then
        if v_pet.photo_selection_version=p_expected_version+1 and exists(select 1 from public.pet_photos where id=p_photo_id and is_primary) then return; end if;
        raise exception using errcode='40001',message='photo_conflict';
    end if;
    if exists(select 1 from public.pet_photos where id=p_photo_id and is_primary) then return; end if;
    update public.pet_photos set is_primary=false where pet_id=p_pet_id and is_primary;
    update public.pet_photos set is_primary=true where id=p_photo_id;
    update public.pets set photo_selection_version=photo_selection_version+1 where id=p_pet_id;
end; $$;

create or replace function public.begin_pet_photo_removal(p_id uuid,p_pet_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_photo public.pet_photos; v_next uuid;
begin
    perform 1 from public.pets where id=p_pet_id and owner_id=auth.uid() for update;
    if not found then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    select * into v_photo from public.pet_photos where id=p_id for update;
    if not found then return; end if;
    if v_photo.pet_id<>p_pet_id or v_photo.owner_id<>auth.uid() then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    update public.pet_photos set status='removing',is_primary=false where id=p_id;
    if v_photo.is_primary then
        select id into v_next from public.pet_photos where pet_id=p_pet_id and status='published' order by created_at,id limit 1;
        update public.pet_photos set is_primary=true where id=v_next;
        update public.pets set photo_selection_version=photo_selection_version+1 where id=p_pet_id;
    end if;
end; $$;

create or replace function public.remove_pet_photo(p_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_photo public.pet_photos;
begin
    if auth.uid() is null then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    perform 1 from public.pets p join public.pet_photos ph on ph.pet_id=p.id where ph.id=p_id and ph.owner_id=auth.uid() for update of p;
    select * into v_photo from public.pet_photos where id=p_id for update;
    if not found then return; end if;
    if v_photo.owner_id<>auth.uid() then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    if v_photo.status<>'removing' then raise exception using errcode='40001',message='photo_removal_not_started'; end if;
    if exists(select 1 from storage.objects where bucket_id in ('pet-photos','pet-photo-renditions','pet-photo-thumbnails') and name=v_photo.owner_id::text||'/'||v_photo.pet_id::text||'/'||p_id::text||'.jpg') then
        raise exception using errcode='P0002',message='photo_file_remaining';
    end if;
    insert into public.pet_photo_deletions(id,pet_id,owner_id) values(p_id,v_photo.pet_id,v_photo.owner_id) on conflict(id) do nothing;
    delete from public.pet_photos where id=p_id;
end; $$;

-- New uploads cannot use the old client-controlled publish path.
create or replace function public.publish_pet_photo(p_id uuid)
returns setof public.pet_photos language plpgsql security definer set search_path='' as $$
begin
    raise exception using errcode='42501',message='photo_processing_required';
end; $$;

create or replace function public.finish_pet_deletion(p_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_pet public.pets;
begin
    if v_owner is null then raise exception using errcode='42501',message='pet_unauthorized'; end if;
    select * into v_pet from public.pets where id=p_id for update;
    if not found then return; end if;
    if v_pet.owner_id<>v_owner then raise exception using errcode='42501',message='pet_unauthorized'; end if;
    if v_pet.case_history_at is not null or v_pet.active_case_count>0 then raise exception using errcode='23514',message='pet_has_case_history'; end if;
    if v_pet.deletion_requested_at is null then raise exception using errcode='42501',message='pet_delete_not_started'; end if;
    if exists(select 1 from storage.objects where bucket_id in ('pet-photos','pet-photo-renditions','pet-photo-thumbnails') and name like v_owner::text||'/'||p_id::text||'/%') then raise exception using errcode='P0002',message='pet_files_remaining'; end if;
    insert into public.pet_deletions(id,owner_id) values(p_id,v_owner) on conflict(id) do nothing;
    delete from public.pets where id=p_id;
end; $$;
