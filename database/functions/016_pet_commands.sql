-- Only RPCs write pets; client never supplies owner, version or timestamps.
create or replace function public.create_pet(p_id uuid, p_name text, p_species text, p_sex text, p_age_months integer, p_traits text)
returns setof public.pets language plpgsql security definer set search_path = '' as $$
declare
  v_owner uuid := auth.uid();
  v_pet public.pets;
  v_name text := public.pet_trim(p_name);
  v_traits text := nullif(public.pet_trim(p_traits), '');
begin
  if v_owner is null then raise exception using errcode = '42501', message = 'pet_unauthorized'; end if;
  if p_id is null then raise exception using errcode = '23514', message = 'pet_invalid_id'; end if;
  perform public.validate_pet_fields(v_name, p_species, p_sex, p_age_months, v_traits);
  insert into public.pets(id,owner_id,name,species,sex,age_months,traits)
  values(p_id,v_owner,v_name,p_species,p_sex,p_age_months,v_traits)
  on conflict(id) do nothing;
  select * into v_pet from public.pets where id = p_id;
  if v_pet.owner_id is distinct from v_owner then raise exception using errcode = '42501', message = 'pet_unauthorized'; end if;
  if v_pet.name is distinct from v_name or v_pet.species is distinct from p_species or v_pet.sex is distinct from p_sex or v_pet.age_months is distinct from p_age_months or v_pet.traits is distinct from v_traits then
    raise exception using errcode = '40001', message = 'pet_conflict';
  end if;
  return next v_pet;
end;
$$;
create or replace function public.update_pet(p_id uuid, p_expected_version integer, p_name text, p_species text, p_sex text, p_age_months integer, p_traits text)
returns setof public.pets language plpgsql security definer set search_path = '' as $$
declare
  v_owner uuid := auth.uid();
  v_pet public.pets;
  v_name text := public.pet_trim(p_name);
  v_traits text := nullif(public.pet_trim(p_traits), '');
begin
  if v_owner is null then raise exception using errcode = '42501', message = 'pet_unauthorized'; end if;
  perform public.validate_pet_fields(v_name, p_species, p_sex, p_age_months, v_traits);
  select * into v_pet from public.pets where id = p_id and owner_id = v_owner for update;
  if not found then raise exception using errcode = 'P0002', message = 'pet_missing'; end if;
  if p_expected_version is null or p_expected_version < 1 then raise exception using errcode = '40001', message = 'pet_conflict'; end if;
  if v_pet.version <> p_expected_version then
    -- Lost acknowledgement: return the exact acknowledged version without writing again.
    if v_pet.version = p_expected_version + 1 and v_pet.name is not distinct from v_name and v_pet.species is not distinct from p_species and v_pet.sex is not distinct from p_sex and v_pet.age_months is not distinct from p_age_months and v_pet.traits is not distinct from v_traits then
      return next v_pet; return;
    end if;
    raise exception using errcode = '40001', message = 'pet_conflict';
  end if;
  update public.pets set name=v_name,species=p_species,sex=p_sex,age_months=p_age_months,traits=v_traits,version=version+1,updated_at=clock_timestamp()
  where id=p_id and owner_id=v_owner returning * into v_pet;
  return next v_pet;
end;
$$;
