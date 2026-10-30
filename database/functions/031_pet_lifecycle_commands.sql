create or replace function public.archive_pet(p_id uuid, p_expected_version integer)
returns setof public.pets language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_pet public.pets;
begin
  if v_owner is null then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  select * into v_pet from public.pets where id=p_id for update;
  if not found then raise exception using errcode='P0002',message='pet_missing'; end if;
  if v_pet.owner_id<>v_owner then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  if v_pet.deletion_requested_at is not null then raise exception using errcode='42501',message='pet_deleting'; end if;
  if v_pet.active_case_count>0 then raise exception using errcode='23514',message='pet_active_case'; end if;
  if p_expected_version is null or p_expected_version<1 then raise exception using errcode='40001',message='pet_conflict'; end if;
  if v_pet.archived_at is not null then
    if p_expected_version=v_pet.version or p_expected_version+1=v_pet.version then return next v_pet; return; end if;
    raise exception using errcode='40001',message='pet_conflict';
  end if;
  if p_expected_version<>v_pet.version then raise exception using errcode='40001',message='pet_conflict'; end if;
  update public.pets set archived_at=clock_timestamp(),version=version+1,updated_at=clock_timestamp()
    where id=p_id returning * into v_pet;
  return next v_pet;
end; $$;

create or replace function public.restore_pet(p_id uuid, p_expected_version integer)
returns setof public.pets language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_pet public.pets;
begin
  if v_owner is null then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  select * into v_pet from public.pets where id=p_id for update;
  if not found then raise exception using errcode='P0002',message='pet_missing'; end if;
  if v_pet.owner_id<>v_owner then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  if v_pet.deletion_requested_at is not null then raise exception using errcode='42501',message='pet_deleting'; end if;
  if p_expected_version is null or p_expected_version<1 then raise exception using errcode='40001',message='pet_conflict'; end if;
  if v_pet.archived_at is null then
    if p_expected_version=v_pet.version or p_expected_version+1=v_pet.version then return next v_pet; return; end if;
    raise exception using errcode='40001',message='pet_conflict';
  end if;
  if p_expected_version<>v_pet.version then raise exception using errcode='40001',message='pet_conflict'; end if;
  update public.pets set archived_at=null,version=version+1,updated_at=clock_timestamp()
    where id=p_id returning * into v_pet;
  return next v_pet;
end; $$;

-- Replace the 007 commands in this new increment; never rewrite applied SQL.
-- Validate BEFORE Storage cleanup, so a case-backed pet never loses its photos.
create or replace function public.begin_pet_deletion(p_id uuid,p_expected_version integer)
returns boolean language plpgsql security definer set search_path='' as $$
declare v_owner uuid:=auth.uid(); v_pet public.pets;
begin
  if v_owner is null then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  select * into v_pet from public.pets where id=p_id for update;
  if not found then return false; end if;
  if v_pet.owner_id<>v_owner then raise exception using errcode='42501',message='pet_unauthorized'; end if;
  if v_pet.case_history_at is not null or v_pet.active_case_count>0 then raise exception using errcode='23514',message='pet_has_case_history'; end if;
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
  if v_pet.case_history_at is not null or v_pet.active_case_count>0 then raise exception using errcode='23514',message='pet_has_case_history'; end if;
  if v_pet.deletion_requested_at is null then raise exception using errcode='42501',message='pet_delete_not_started'; end if;
  if exists(select 1 from storage.objects where bucket_id='pet-photos' and name like v_owner::text||'/'||p_id::text||'/%') then raise exception using errcode='P0002',message='pet_files_remaining'; end if;
  insert into public.pet_deletions(id,owner_id) values(p_id,v_owner) on conflict(id) do nothing;
  delete from public.pets where id=p_id and owner_id=v_owner;
end; $$;

create or replace function public.protect_pet_case_history()
returns trigger language plpgsql set search_path='' as $$
begin
  if tg_op='DELETE' then
    if old.case_history_at is not null or old.active_case_count>0 then raise exception using errcode='23514',message='pet_has_case_history'; end if;
    return old;
  end if;
  if old.case_history_at is not null and new.case_history_at is distinct from old.case_history_at then raise exception using errcode='23514',message='pet_history_immutable'; end if;
  if old.deletion_requested_at is not null and (new.case_history_at is distinct from old.case_history_at or new.active_case_count<>old.active_case_count or new.archived_at is distinct from old.archived_at) then raise exception using errcode='42501',message='pet_deleting'; end if;
  return new;
end; $$;
