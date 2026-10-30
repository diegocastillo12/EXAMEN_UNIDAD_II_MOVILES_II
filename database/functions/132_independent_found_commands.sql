-- Apply reviewed, bounded edits to current definitions, preserving deployed fixes,
-- grants and function signatures. Repetition is safe and does not touch case data.
do $independent_found_commands$
declare v_name text; v_function regprocedure; v_definition text; v_updated text;
begin
 foreach v_name in array array['prepare_recovery_report','publish_recovery_report'] loop
  select p.oid::regprocedure into strict v_function from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.proname=v_name;
  v_definition=pg_get_functiondef(v_function::oid);
  if strpos(v_definition,'''independent_found''')>0 then continue; end if;
  v_updated=replace(v_definition,'''possible_loss'',''sighting'',''with_reporter''','''possible_loss'',''independent_found'',''sighting'',''with_reporter''');
  v_updated=replace(v_updated,'p_report_kind=''possible_loss''','p_report_kind in (''possible_loss'',''independent_found'')');
  v_updated=replace(v_updated,'p_report_kind<>''possible_loss''','p_report_kind not in (''possible_loss'',''independent_found'')');
  if v_name='publish_recovery_report' then
   if strpos(v_updated,'when p_report_kind=''sighting'' then ''not_with_me'' else null end,p_photo_ids')=0 then
    raise exception 'Unexpected custody projection in independent found publication'; end if;
   v_updated=replace(v_updated,'when p_report_kind=''sighting'' then ''not_with_me'' else null end,p_photo_ids',
    'when p_report_kind=''sighting'' then ''not_with_me'' when p_report_kind=''independent_found'' then p_custody else null end,p_photo_ids');
  end if;
  if v_updated=v_definition or strpos(v_updated,'independent_found')=0 then raise exception 'Unexpected independent found contract: %',v_name; end if;
  execute v_updated;
 end loop;
 -- Visibility/Storage allow the new explicitly independent type. No new table grants.
 foreach v_name in array array['read_recovery_report','can_read_found_photo'] loop
  select p.oid::regprocedure into strict v_function from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public' and p.proname=v_name;
  v_definition=pg_get_functiondef(v_function::oid);
  if strpos(v_definition,'''independent_found''')>0 then continue; end if;
  v_updated=replace(v_definition,'''legacy_found'',''possible_loss''','''legacy_found'',''possible_loss'',''independent_found''');
  if v_updated=v_definition then raise exception 'Unexpected found visibility contract: %',v_name; end if;
  execute v_updated;
 end loop;
end;
$independent_found_commands$;

create or replace function public.list_my_match_searches(p_actor uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_result jsonb;
begin
 if p_actor is null or not exists(select 1 from public.profiles where id=p_actor and onboarding_completed_at is not null) then
  raise exception using errcode='42501',message='matching_forbidden'; end if;
 select coalesce(jsonb_agg(jsonb_build_object('source',c.source,'id',c.id,'name',s.data->>'name','species',s.data->>'species')
  order by c.created_at desc,c.id),'[]'::jsonb) into v_result
 from (
  select 'lost'::text source,id,created_at from public.lost_cases where owner_id=p_actor and status='active' and deleted_at is null
  union all
  select 'found',id,published_at from public.found_cases where owner_id=p_actor and report_kind='possible_loss' and status='active' and deleted_at is null
 ) c cross join lateral (select public.match_case_snapshot(p_actor,c.source,c.id) data) s where s.data is not null;
 return v_result;
end $$;
revoke all on function public.list_my_match_searches(uuid) from public,anon,authenticated,service_role;
grant execute on function public.list_my_match_searches(uuid) to service_role;
