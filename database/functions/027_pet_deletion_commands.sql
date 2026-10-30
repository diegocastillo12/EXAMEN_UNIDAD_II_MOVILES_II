-- Only RPCs write pets; client never supplies owner, version or timestamps.
create or replace function public.create_pet_v2(p_id uuid, p_name text, p_species text, p_sex text, p_age_months integer, p_traits text, p_species_detail text, p_size text)
returns setof public.pets language plpgsql security definer set search_path = '' as $$
declare
  v_owner uuid := auth.uid();
  v_pet public.pets;
  v_name text := public.pet_trim(p_name);
  v_traits text := nullif(public.pet_trim(p_traits), '');
  v_detail text := case when p_species='other' then nullif(public.pet_trim(p_species_detail),'') else null end;
begin
  if v_owner is null then raise exception using errcode = '42501', message = 'pet_unauthorized'; end if;
  if p_id is null then raise exception using errcode = '23514', message = 'pet_invalid_id'; end if;
  if exists(select 1 from public.pet_deletions where id=p_id) then raise exception using errcode='40001',message='pet_deleted'; end if;
  perform public.validate_pet_fields(v_name, p_species, p_sex, p_age_months, v_traits);
  if p_species='other' and (v_detail is null or char_length(v_detail)>60) then raise exception using errcode='23514',message='pet_invalid_species_detail'; end if;
  if p_size is not null and p_size not in ('small','medium','large') then raise exception using errcode='23514',message='pet_invalid_size'; end if;
  insert into public.pets(id,owner_id,name,species,sex,age_months,traits,species_detail,size)
  values(p_id,v_owner,v_name,p_species,p_sex,p_age_months,v_traits,v_detail,p_size)
  on conflict(id) do nothing;
  select * into v_pet from public.pets where id = p_id;
  if v_pet.owner_id is distinct from v_owner then raise exception using errcode = '42501', message = 'pet_unauthorized'; end if;
  if v_pet.deletion_requested_at is not null then raise exception using errcode='42501',message='pet_deleting'; end if;
  if v_pet.name is distinct from v_name or v_pet.species is distinct from p_species or v_pet.sex is distinct from p_sex or v_pet.age_months is distinct from p_age_months or v_pet.traits is distinct from v_traits or v_pet.species_detail is distinct from v_detail or v_pet.size is distinct from p_size then
    raise exception using errcode = '40001', message = 'pet_conflict';
  end if;
  return next v_pet;
end;
$$;
create or replace function public.update_pet_v2(p_id uuid, p_expected_version integer, p_name text, p_species text, p_sex text, p_age_months integer, p_traits text, p_species_detail text, p_size text)
returns setof public.pets language plpgsql security definer set search_path = '' as $$
declare
  v_owner uuid := auth.uid();
  v_pet public.pets;
  v_name text := public.pet_trim(p_name);
  v_traits text := nullif(public.pet_trim(p_traits), '');
  v_detail text := case when p_species='other' then nullif(public.pet_trim(p_species_detail),'') else null end;
begin
  if v_owner is null then raise exception using errcode = '42501', message = 'pet_unauthorized'; end if;
  perform public.validate_pet_fields(v_name, p_species, p_sex, p_age_months, v_traits);
  if p_species='other' and (v_detail is null or char_length(v_detail)>60) then raise exception using errcode='23514',message='pet_invalid_species_detail'; end if;
  if p_size is not null and p_size not in ('small','medium','large') then raise exception using errcode='23514',message='pet_invalid_size'; end if;
  select * into v_pet from public.pets where id = p_id and owner_id = v_owner for update;
  if not found then raise exception using errcode = 'P0002', message = 'pet_missing'; end if;
  if v_pet.deletion_requested_at is not null then raise exception using errcode='42501',message='pet_deleting'; end if;
  if p_expected_version is null or p_expected_version < 1 then raise exception using errcode = '40001', message = 'pet_conflict'; end if;
  if v_pet.version <> p_expected_version then
    -- Lost acknowledgement: return the exact acknowledged version without writing again.
    if v_pet.version = p_expected_version + 1 and v_pet.name is not distinct from v_name and v_pet.species is not distinct from p_species and v_pet.sex is not distinct from p_sex and v_pet.age_months is not distinct from p_age_months and v_pet.traits is not distinct from v_traits and v_pet.species_detail is not distinct from v_detail and v_pet.size is not distinct from p_size then
      return next v_pet; return;
    end if;
    raise exception using errcode = '40001', message = 'pet_conflict';
  end if;
  update public.pets set name=v_name,species=p_species,sex=p_sex,age_months=p_age_months,traits=v_traits,species_detail=v_detail,size=p_size,version=version+1,updated_at=clock_timestamp()
  where id=p_id and owner_id=v_owner returning * into v_pet;
  return next v_pet;
end;
$$;

create or replace function public.reserve_pet_photo(p_id uuid,p_pet_id uuid)
returns setof public.pet_photos language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_photo public.pet_photos;
begin
  if v_owner is null then raise exception using errcode='42501',message='photo_unauthorized'; end if;
  perform 1 from public.pets where id=p_pet_id and owner_id=v_owner and deletion_requested_at is null for update;
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
  perform 1 from public.pets p join public.pet_photos ph on ph.pet_id=p.id where ph.id=p_id and p.owner_id=v_owner and p.deletion_requested_at is null for update of p;
  if not found then raise exception using errcode='42501',message='photo_unauthorized'; end if;
  select * into v_photo from public.pet_photos where id=p_id and owner_id=v_owner for update;
  if not found or v_owner is null then raise exception using errcode='42501',message='photo_unauthorized'; end if;
  if not exists(select 1 from storage.objects where bucket_id='pet-photos' and name=v_owner::text||'/'||v_photo.pet_id::text||'/'||p_id::text||'.jpg' and metadata->>'mimetype'='image/jpeg' and (metadata->>'size')::bigint between 4 and 2097152) then
    raise exception using errcode='P0002',message='photo_incomplete';
  end if;
  update public.pet_photos set status='published' where id=p_id returning * into v_photo;
  return next v_photo;
end; $$;

create or replace function public.begin_pet_deletion(p_id uuid,p_expected_version integer)
returns boolean language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_pet public.pets;
begin
  if v_owner is null then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  select * into v_pet from public.pets where id=p_id for update;
  if not found then return false; end if;
  if v_pet.owner_id<>v_owner then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  if p_expected_version is null or p_expected_version<>v_pet.version then raise exception using errcode='40001',message='pet_conflict'; end if;
  update public.pets set deletion_requested_at=coalesce(deletion_requested_at,clock_timestamp()) where id=p_id;
  return true;
end; $$;
create or replace function public.finish_pet_deletion(p_id uuid)
returns void language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_pet public.pets;
begin
  if v_owner is null then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  select * into v_pet from public.pets where id=p_id for update;
  if not found then return; end if;
  if v_pet.owner_id<>v_owner then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  if v_pet.deletion_requested_at is null then raise exception using errcode='42501',message='pet_delete_not_started'; end if;
  if exists(select 1 from storage.objects where bucket_id='pet-photos' and name like v_owner::text||'/'||p_id::text||'/%') then raise exception using errcode='P0002',message='pet_files_remaining'; end if;
  insert into public.pet_deletions(id,owner_id) values(p_id,v_owner) on conflict(id) do nothing;
  delete from public.pets where id=p_id and owner_id=v_owner;
end; $$;
