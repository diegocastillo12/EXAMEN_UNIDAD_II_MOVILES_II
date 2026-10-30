create or replace function public.reserve_pet_photo(p_id uuid,p_pet_id uuid)
returns setof public.pet_photos language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_photo public.pet_photos;
begin
  if v_owner is null then raise exception using errcode='42501',message='photo_unauthorized'; end if;
  perform 1 from public.pets where id=p_pet_id and owner_id=v_owner for update;
  if not found then raise exception using errcode='42501',message='photo_unauthorized'; end if;
  select * into v_photo from public.pet_photos where id=p_id;
  if found then
    if v_photo.owner_id<>v_owner or v_photo.pet_id<>p_pet_id then raise exception using errcode='42501',message='photo_unauthorized'; end if;
    return next v_photo; return;
  end if;
  if (select count(*) from public.pet_photos where pet_id=p_pet_id)>=3 then raise exception using errcode='23514',message='photo_limit'; end if;
  insert into public.pet_photos(id,pet_id,owner_id) values(p_id,p_pet_id,v_owner) returning * into v_photo;
  return next v_photo;
end; $$;
create or replace function public.publish_pet_photo(p_id uuid)
returns setof public.pet_photos language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_photo public.pet_photos;
begin
  select * into v_photo from public.pet_photos where id=p_id and owner_id=v_owner for update;
  if not found or v_owner is null then raise exception using errcode='42501',message='photo_unauthorized'; end if;
  if not exists(select 1 from storage.objects where bucket_id='pet-photos' and name=v_owner::text||'/'||v_photo.pet_id::text||'/'||p_id::text||'.jpg' and metadata->>'mimetype'='image/jpeg' and (metadata->>'size')::bigint between 4 and 2097152) then
    raise exception using errcode='P0002',message='photo_incomplete';
  end if;
  update public.pet_photos set status='published' where id=p_id returning * into v_photo;
  return next v_photo;
end; $$;
create or replace function public.remove_pet_photo(p_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_photo public.pet_photos;
begin
  if v_owner is null then raise exception using errcode='42501',message='photo_unauthorized'; end if;
  select * into v_photo from public.pet_photos where id=p_id and owner_id=v_owner for update;
  if not found then return; end if;
  if exists(select 1 from storage.objects where bucket_id='pet-photos' and name=v_owner::text||'/'||v_photo.pet_id::text||'/'||p_id::text||'.jpg') then raise exception using errcode='P0002',message='photo_file_remaining'; end if;
  delete from public.pet_photos where id=p_id and owner_id=v_owner;
end; $$;
