create or replace function public.read_saved_case(p_source text,p_case_id uuid)
returns jsonb language plpgsql stable security definer set search_path='' set statement_timeout='8s' as $$
declare v_saved boolean;v_version integer;
begin
 if auth.uid() is null then raise exception using errcode='42501',message='saved_case_unauthorized'; end if;
 if p_source is null or p_source not in ('lost','found') or p_case_id is null then
  raise exception using errcode='22023',message='saved_case_invalid'; end if;
 select saved,version into v_saved,v_version from public.saved_cases
  where owner_id=auth.uid() and case_source=p_source and case_id=p_case_id;
 return jsonb_build_object('saved',coalesce(v_saved,false),'version',coalesce(v_version,0));
end $$;

create or replace function public.set_saved_case(p_source text,p_case_id uuid,p_saved boolean,p_expected_version integer)
returns jsonb language plpgsql security definer set search_path='' set lock_timeout='5s' set statement_timeout='8s' as $$
declare v_owner uuid:=auth.uid();v_row public.saved_cases;v_exists boolean;v_visible boolean;v_version integer;
begin
 if v_owner is null then raise exception using errcode='42501',message='saved_case_unauthorized'; end if;
 if p_source is null or p_source not in ('lost','found') or p_case_id is null or p_saved is null
  or p_expected_version is null or p_expected_version < 0 or p_expected_version >= 2147483647 then
  raise exception using errcode='22023',message='saved_case_invalid'; end if;
 -- Serialize even the first insertion; origin prevents UUID collisions across case tables.
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_owner::text||':'||p_source||':'||p_case_id::text,0));
 select * into v_row from public.saved_cases
  where owner_id=v_owner and case_source=p_source and case_id=p_case_id for update;
 v_exists:=found;
 -- Retrying the same confirmed choice is a no-op, preserving version and timestamps.
 if v_exists and v_row.saved=p_saved then
  return jsonb_build_object('saved',v_row.saved,'version',v_row.version);
 end if;
 v_version:=case when v_exists then v_row.version else 0 end;
 if v_version<>p_expected_version then
  raise exception using errcode='40001',message='saved_case_conflict'; end if;
 -- Saving requires current visibility; removing an existing marker is always allowed.
 if p_saved or not v_exists then
  if p_source='lost' then
   select exists(select 1 from public.read_recovery_pet_case(p_case_id)) into v_visible;
  else
   select exists(select 1 from public.read_recovery_report(p_case_id)) into v_visible;
  end if;
  if not v_visible then raise exception using errcode='P0002',message='saved_case_unavailable'; end if;
 end if;
 if v_exists then
  update public.saved_cases set saved=p_saved,version=version+1,updated_at=clock_timestamp()
   where owner_id=v_owner and case_source=p_source and case_id=p_case_id returning * into v_row;
 else
  insert into public.saved_cases(owner_id,case_source,case_id,saved)
   values(v_owner,p_source,p_case_id,p_saved) returning * into v_row;
 end if;
 -- Unsave retains a private tombstone so delayed opposite retries cannot restore it.
 return jsonb_build_object('saved',v_row.saved,'version',v_row.version);
end $$;
