create or replace function public.list_saved_cases(p_cursor jsonb default null,p_limit integer default 20)
returns jsonb language plpgsql stable security definer set search_path='' set statement_timeout='8s' as $$
declare v_owner uuid:=auth.uid();v_as_of timestamptz:=statement_timestamp();v_after timestamptz;
 v_source text;v_id uuid;v_rows jsonb;v_items jsonb;v_last jsonb;v_next jsonb;
begin
 if v_owner is null then raise exception using errcode='42501',message='saved_case_unauthorized'; end if;
 if p_limit is null or p_limit not between 1 and 50 then raise exception using errcode='22023',message='saved_case_invalid'; end if;
 if p_cursor is not null then
  begin
   if jsonb_typeof(p_cursor)<>'object' or not(p_cursor ?& array['owner','as_of','saved_at','source','id'])
    or (p_cursor->>'owner')::uuid is distinct from v_owner then raise exception 'invalid'; end if;
   v_as_of=(p_cursor->>'as_of')::timestamptz;v_after=(p_cursor->>'saved_at')::timestamptz;
   v_source=p_cursor->>'source';v_id=(p_cursor->>'id')::uuid;
   if v_as_of is null or not isfinite(v_as_of) or v_as_of>statement_timestamp()
    or v_after is null or not isfinite(v_after) or v_after>v_as_of
    or v_source is null or v_source not in ('lost','found') or v_id is null then raise exception 'invalid'; end if;
  exception when others then raise exception using errcode='22023',message='saved_case_cursor_invalid'; end;
 end if;
 with visible as (
  select s.case_id,s.case_source,s.updated_at,r.data from public.saved_cases s
  cross join lateral (
   select x as data from public.read_recovery_pet_case(s.case_id) x where s.case_source='lost'
   union all select x from public.read_recovery_report(s.case_id) x where s.case_source='found'
  ) r
  where s.owner_id=v_owner and s.saved and s.updated_at<=v_as_of
   and (v_after is null or (s.updated_at,s.case_source,s.case_id)<(v_after,v_source,v_id))
  order by s.updated_at desc,s.case_source desc,s.case_id desc limit p_limit+1
 ) select coalesce(jsonb_agg(jsonb_build_object(
  'id',case_id,'source',case_source,'saved_at',updated_at,
  'kind',case when case_source='lost' or data->>'report_kind'='possible_loss' then 'lost'
    when data->>'report_kind'='sighting' then 'sighting' else 'found' end,
  'status',data->>'status','report_kind',coalesce(data->>'report_kind','own_loss'),
  'name',coalesce(data->>'pet_name',''),'species',data->>'species','traits',coalesce(data->>'traits',''),
  'occurred_at',data->'occurred_at','latitude',data->'latitude','longitude',data->'longitude',
  'distance_meters',null,'cover_path',data->'photos'->0->>'path'
 ) order by updated_at desc,case_source desc,case_id desc),'[]'::jsonb) into v_rows from visible;
 select coalesce(jsonb_agg(value order by ordinality),'[]'::jsonb) into v_items
  from jsonb_array_elements(v_rows) with ordinality where ordinality<=p_limit;
 if jsonb_array_length(v_rows)>p_limit then
  v_last=v_items->(p_limit-1);
  v_next=jsonb_build_object('owner',v_owner,'as_of',v_as_of,'saved_at',v_last->'saved_at',
   'source',v_last->>'source','id',v_last->>'id');
 end if;
 return jsonb_build_object('items',v_items,'next_cursor',v_next);
end $$;
